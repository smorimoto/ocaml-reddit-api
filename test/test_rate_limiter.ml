open! Core
open! Async
open! Import

let gen_http_header_date time =
  let zone = Time_ns.Zone.utc in
  let date, ofday = Time_ns.to_date_ofday ~zone time in
  let day_of_week = Date.day_of_week date in
  let year = Date.year date in
  let month = Date.month date in
  let day = Date.day date in
  let ({ hr; min; sec; _ } : Time_ns.Span.Parts.t) = Time_ns.Ofday.to_parts ofday in
  sprintf
    "%3s, %2d %3s %4d %02d:%02d:%02d GMT"
    (Day_of_week.to_string day_of_week |> String.lowercase |> String.capitalize)
    day
    (Month.to_string month)
    year
    hr
    min
    sec
;;

let%expect_test _ =
  let time = Time_ns.of_string "2015-10-21 07:28:00Z" in
  printf "%s\n" (gen_http_header_date time);
  [%expect "Wed, 21 Oct 2015 07:28:00 GMT"];
  return ()
;;

let build_header ~server_time ~limit_remaining =
  let reset_time =
    let interval = Time_ns.Span.of_string "10m" in
    let base = Time_ns.epoch in
    Time_ns.next_multiple ~interval ~base ~after:server_time ()
  in
  let until_reset = Time_ns.diff reset_time server_time in
  let headers =
    Cohttp.Header.of_list
      [ "Date", gen_http_header_date server_time
      ; "X-Ratelimit-Remaining", Int.to_string limit_remaining
      ; "X-Ratelimit-Reset", Int.to_string (Time_ns.Span.to_int_sec until_reset)
      ]
  in
  Cohttp.Response.make ~headers ()
;;

let%expect_test _ =
  let ( ^: ) hr min = Time_ns.add Time_ns.epoch (Time_ns.Span.create ~hr ~min ()) in
  let time_source = Time_source.create ~now:(00 ^: 00) () in
  let rate_limiter =
    Rate_limiter.by_headers ~time_source:(Time_source.read_only time_source)
  in
  let print () =
    print_s
      [%sexp
        { is_ready : bool = Rate_limiter.is_ready rate_limiter
        ; rate_limiter : Rate_limiter.t
        ; time : Time_ns.t = Time_source.now time_source
        }]
  in
  print ();
  [%expect
    {|
    ((is_ready true)
     (rate_limiter
      (By_headers
       ((ready (())) (time_source <opaque>) (reset_event ())
        (server_side_info ()))))
     (time (1970-01-01 00:00:00.000000000Z))) |}];
  (* Initially we can permit one request. *)
  let%bind () = Rate_limiter.permit_request rate_limiter in
  print ();
  [%expect
    {|
    ((is_ready false)
     (rate_limiter
      (By_headers
       ((ready ()) (time_source <opaque>) (reset_event ()) (server_side_info ()))))
     (time (1970-01-01 00:00:00.000000000Z))) |}];
  (* Receiving a response allows us to send another request. *)
  Rate_limiter.notify_response
    rate_limiter
    (build_header ~server_time:(00 ^: 00) ~limit_remaining:1);
  let%bind () = Rate_limiter.permit_request rate_limiter in
  print ();
  [%expect
    {|
    ((is_ready false)
     (rate_limiter
      (By_headers
       ((ready ()) (time_source <opaque>) (reset_event (<opaque>))
        (server_side_info
         (((remaining_api_calls 0) (reset_time (1970-01-01 00:10:00.000000000Z))))))))
     (time (1970-01-01 00:00:00.000000000Z))) |}];
  (* Receiving a response for the same reset period will not increase our limit remaining. *)
  Rate_limiter.notify_response
    rate_limiter
    (build_header ~server_time:(00 ^: 01) ~limit_remaining:3);
  print ();
  [%expect
    {|
    ((is_ready false)
     (rate_limiter
      (By_headers
       ((ready ()) (time_source <opaque>) (reset_event (<opaque>))
        (server_side_info
         (((remaining_api_calls 0) (reset_time (1970-01-01 00:10:00.000000000Z))))))))
     (time (1970-01-01 00:00:00.000000000Z))) |}];
  (* Moving to the next period increases our remaining limit. *)
  Rate_limiter.notify_response
    rate_limiter
    (build_header ~server_time:(00 ^: 10) ~limit_remaining:10);
  print ();
  [%expect
    {|
    ((is_ready true)
     (rate_limiter
      (By_headers
       ((ready (())) (time_source <opaque>) (reset_event (<opaque>))
        (server_side_info
         (((remaining_api_calls 10)
           (reset_time (1970-01-01 00:20:00.000000000Z))))))))
     (time (1970-01-01 00:00:00.000000000Z))) |}];
  (* Exhausting the remaining limit causes us to be not-ready. *)
  let%bind () =
    Deferred.repeat_until_finished 10 (function
        | 0 -> return (`Finished ())
        | n ->
          let%bind () = Rate_limiter.permit_request rate_limiter in
          return (`Repeat (n - 1)))
  in
  print ();
  [%expect
    {|
    ((is_ready false)
     (rate_limiter
      (By_headers
       ((ready ()) (time_source <opaque>) (reset_event (<opaque>))
        (server_side_info
         (((remaining_api_calls 0) (reset_time (1970-01-01 00:20:00.000000000Z))))))))
     (time (1970-01-01 00:00:00.000000000Z))) |}];
  (* Advancing the time allows us to send another request. *)
  let%bind () = Time_source.advance_by_alarms time_source ~to_:(00 ^: 20) in
  print ();
  [%expect
    {|
    ((is_ready true)
     (rate_limiter
      (By_headers
       ((ready (())) (time_source <opaque>) (reset_event (<opaque>))
        (server_side_info
         (((remaining_api_calls 0) (reset_time (1970-01-01 00:20:00.000000000Z))))))))
     (time (1970-01-01 00:20:00.000000000Z))) |}];
  (* Advancing past the reset time before we receive a response does not result
     in a double reset. *)
  let%bind () = Rate_limiter.permit_request rate_limiter in
  Rate_limiter.notify_response
    rate_limiter
    (build_header ~server_time:(00 ^: 20) ~limit_remaining:1);
  let%bind () = Rate_limiter.permit_request rate_limiter in
  print ();
  [%expect
    {|
    ((is_ready false)
     (rate_limiter
      (By_headers
       ((ready ()) (time_source <opaque>) (reset_event (<opaque>))
        (server_side_info
         (((remaining_api_calls 0) (reset_time (1970-01-01 00:30:00.000000000Z))))))))
     (time (1970-01-01 00:20:00.000000000Z))) |}];
  let%bind () = Time_source.advance_by_alarms time_source ~to_:(00 ^: 30) in
  print ();
  [%expect
    {|
    ((is_ready true)
     (rate_limiter
      (By_headers
       ((ready (())) (time_source <opaque>) (reset_event (<opaque>))
        (server_side_info
         (((remaining_api_calls 0) (reset_time (1970-01-01 00:30:00.000000000Z))))))))
     (time (1970-01-01 00:30:00.000000000Z))) |}];
  let%bind () = Rate_limiter.permit_request rate_limiter in
  Rate_limiter.notify_response
    rate_limiter
    (build_header ~server_time:(00 ^: 29) ~limit_remaining:1);
  let%bind () = Time_source.advance_by_alarms time_source ~to_:(00 ^: 31) in
  print ();
  [%expect
    {|
    ((is_ready false)
     (rate_limiter
      (By_headers
       ((ready ()) (time_source <opaque>) (reset_event (<opaque>))
        (server_side_info
         (((remaining_api_calls 0) (reset_time (1970-01-01 00:30:00.000000000Z))))))))
     (time (1970-01-01 00:31:00.000000000Z))) |}];
  return ()
;;
