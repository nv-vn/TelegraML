open Telegram.Api
open Telegram.Actions

module MyBot = Mk (struct
  open Command
  open InlineQuery

  include Telegram.BotDefaults

  let token = [%blob "../bot.token"]

  let new_chat_member {Chat.id} {User.first_name} =
    send_message ~chat_id:id "Hello, %s" first_name
end)

let () = MyBot.run ()
