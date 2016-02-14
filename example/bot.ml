open Lwt
open Cohttp
open Cohttp_lwt_unix

open Telegram.Api

module MyBot = Mk (struct
  open Chat
  open Command
  open Message

  let token = [%blob "../bot.token"]

  let commands =
    let say_hi = function
      | {chat} -> SendMessage (chat.id, "Hi", None, None) in
    [{name = "say_hi"; description = "Say hi!"; enabled = true; run = say_hi}]
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
