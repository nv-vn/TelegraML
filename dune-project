(lang dune 2.0)
(name y2k-telegraml)
(implicit_transitive_deps false)

(generate_opam_files true)
(source (github y2k/telegraml))
(maintainers "y2k <itwisterlx@gmail.com>")
(authors "y2k <itwisterlx@gmail.com>")

(package
 (name y2k-telegraml)
 (synopsis "Telegram Bot API bindings for OCaml")
 (documentation https://github.com/y2k/telegraml)
 (depends alcotest fmt logs))
