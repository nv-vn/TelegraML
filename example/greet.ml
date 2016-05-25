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

let () = MyBot.run ()
