(lang dune 2.0)
(name telegraml)
(implicit_transitive_deps false)

(generate_opam_files true)
(source (github nv-vn/telegraml))
(maintainers "nv-vn <nv@cock.li>")
(authors "nv-vn <nv@cock.li>")

(package
 (name telegraml)
 (synopsis "Telegram Bot API bindings for OCaml")
 (documentation https://github.com/nv-vn/telegraml)
 (depends
   alcotest
   batteries
   cohttp
   cohttp-lwt
   cohttp-lwt-unix
   fmt
   logs
   lwt
   uri
   (yojson (>= "1.6.0"))))
