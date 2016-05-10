(** The base module for the API, equivalent to [TelegramApi] *)
module Api = struct
  include TelegramApi
end

(** Default options for a bot, if no configuration is needed. Warning: You still need to provide an API key *)
module BotDefaults : Api.BOT = struct
  let token = ""
  let commands = []
  let inline query = Api.Command.Nothing
end
