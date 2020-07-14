open! Core
open! Async
open! Import
open Ocaml_reddit

let%expect_test "submit" =
  with_cassette "submit" ~f:(fun connection ->
      let title = "Test post title" in
      let subreddit = Subreddit_name.of_string "ThirdRealm" in
      let%bind id, uri =
        Api.Exn.submit
          connection
          ~title
          ~subreddit
          ~kind:(Self (Markdown "This is a post body."))
      in
      print_s
        [%message
          "Submission attributes" (id : Thing.Link.Id.t) ~uri:(Uri.to_string uri : string)];
      [%expect
        {|
        ("Submission attributes" (id hmjghn)
         (uri https://www.reddit.com/r/ThirdRealm/comments/hmjghn/test_post_title/)) |}])
;;