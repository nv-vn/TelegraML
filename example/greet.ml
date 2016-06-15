open Telegram.Api

module MyBot = Mk (struct
  open Command
  open InlineQuery

  include Telegram.BotDefaults

  let token = [%blob "../bot.token"]

  let new_chat_member {Chat.id} {User.first_name} =
    SendMessage (id, "Hello, " ^ first_name, false, None, None)
end)

let () = MyBot.run ()
