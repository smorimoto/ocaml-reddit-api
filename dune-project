(lang dune 2.8)

(generate_opam_files true)

(name reddit_api)

(version 0.2.1)

(source (github leviroth/ocaml-reddit-api))

(license MIT)

(authors "Levi Roth")

(maintainers levimroth@gmail.com)

(package
  (name     reddit_api_kernel)
  (synopsis "OCaml types for Reddit's API")
  (depends
    (odoc :with-doc)
    (cohttp      (>= 5.0.0))
    (core_kernel (>= v0.14.0))
    (ezjsonm     (>= 1.2.0))))

(package
  (name reddit_api_async)
  (synopsis "Async connection and utility functions for Reddit's API")
  (depends
    (odoc :with-doc)
    (expect_test_helpers_async (and (>= v0.14.0) (< v0.15.0) :with-test))
    (async             (and (>= v0.14.0) (< v0.15.0)))
    (async_ssl         (and (>= v0.14.0) (< v0.15.0)))
    (cohttp-async      (>= 5.0.0))
    (core              (and (>= v0.14.0) (< v0.15.0)))
    (ezjsonm           (>= 1.2.0))
    (reddit_api_kernel (=  :version))
    (sequencer_table   (and (>= v0.14.0) (< v0.15.0)))))
