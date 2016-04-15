module MyBot = Telegram.Api.Mk (struct
  include Telegram.BotDefaults
  let token = [%blob "../bot.token"]
end);;

Lwt_main.run begin
  MyBot.send_message ~chat_id:(int_of_string [%blob "../chat.id"])
                     ~text:"Hello, world"
                     ~reply_to:None
                     ~reply_markup:None
end
