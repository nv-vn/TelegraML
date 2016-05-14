open Lwt
open Telegram.Api

module MyBot = Mk (struct
  open Command
  open InlineQuery

  include Telegram.BotDefaults

  let token = [%blob "../bot.token"]

  (* This code is really ugly, but because of the way record namespacing works we need to use the right modules *)
  let new_chat_member chat user = SendMessage (Chat.(chat.id), "Hello, " ^ User.(user.first_name), false, None, None)
end)

let rec main () =
  let open Lwt in
  let process = function
    | Result.Success _ -> return ()
    | Result.Failure e ->
      if e <> "Could not get head" then (* Ignore "no updates" error *)
        Lwt_io.printl e
      else return () in
  let rec loop () = MyBot.pop_update () >>= process >>= loop in
  (* Sometimes we get exceptions when the connection/SSL gets messed up *)
  try Lwt_main.run (loop ())
  with _ -> main ()

let _ = main ()
