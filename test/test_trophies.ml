open! Core
open! Async
open! Import
open Ocaml_reddit

let%expect_test _ =
  with_cassette "trophies" ~f:(fun connection ->
      let%bind trophies = Api.Exn.trophies connection in
      print_s [%message "" (trophies : Thing.Award.t list)];
      [%expect
        {|
        (trophies
         (((award_id Null) (description Null)
           (icon_40 (String https://www.redditstatic.com/awards2/3_year_club-40.png))
           (icon_70 (String https://www.redditstatic.com/awards2/3_year_club-70.png))
           (id Null) (name (String "Three-Year Club")) (url Null))
          ((award_id (String o)) (description Null)
           (icon_40
            (String https://www.redditstatic.com/awards2/verified_email-40.png))
           (icon_70
            (String https://www.redditstatic.com/awards2/verified_email-70.png))
           (id (String 1qr5eq)) (name (String "Verified Email")) (url Null)))) |}])
;;