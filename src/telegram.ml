(** The base module for the API, equivalent to [TelegramApi] *)
module Api = struct
  include TelegramApi
end

(** A module that exposes convenience functions for bot actions, equivalent to [TelegramActions] *)
module Actions = struct
  include TelegramActions
end

(** Default options for a bot, if no configuration is needed. Warning: You still need to provide an API key *)
module BotDefaults : Api.BOT = struct
  let token = ""
  let command_postfix = None

  let commands = []
  let inline _(*query*) = Api.Command.Nothing
  let callback _(*query*) = Api.Command.Nothing

  let new_chat_member _ _ = Api.Command.Nothing
  let left_chat_member _ _ = Api.Command.Nothing
  let new_chat_title _ _ = Api.Command.Nothing
  let new_chat_photo _ _ = Api.Command.Nothing
  let delete_chat_photo _ = Api.Command.Nothing
  let group_chat_created _ = Api.Command.Nothing
  let supergroup_chat_created _ = Api.Command.Nothing
  let channel_chat_created _ = Api.Command.Nothing
  let migrate_to_chat_id _ _ = Api.Command.Nothing
  let migrate_from_chat_id _ _ = Api.Command.Nothing
  let pinned_message _ _ = Api.Command.Nothing
end
