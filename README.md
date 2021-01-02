# TelegraML

An OCaml library for creating bots for [Telegram Messenger](https://telegram.org/).
Bots are built using the official API provided by Telegram. The documentation can be viewed [here](https://core.telegram.org/bots/api).

## Introduction:

Before creating a bot, it's recommended that you read through [this page](https://core.telegram.org/bots), which outlines some of the basic usage of bots and the process of registering and managing your bots.

The API is designed to make heavy use of OCaml's module system to provide a configurable template for creating new bots, with optional higher-level representations of features such as commands, chat events, or inline responses.
All bots are created as modules, by instantiating the `Telegram.Api.Mk` functor, which will generate a module for using your bot directly.
The direct commands can be accessed as members of the module, with the API's methods in `snake_case` with `~named` arguments.
However, when using the higher-level APIs (for the inline responses, chat events, or commands), it may be useful to reuse the same command generically across different bots. As a result, the commands/inline response functions are expected to return values of the `Telegram.Api.Command.action`.
Using this type, the command is represented as an abstract data type. These commands are named in `CamelCase`, but they are equivalent to those directly accessible through the module. Note that the arguments are not named, so read the official documentation or the type signatures of the equivalent functions in order to understand what each argument represents.

If you need to get around the restrictions of using the `action` type to encode the responses, you can use the peek_update function to view the update before it's removed from the queue and process it manually.
Note that the `Telegram.Api.Command` module provides convenience functions for helping you parse incoming commands manually if necessary.

## Documentation:

Full OCamldoc-generated documentation is available [here](http://nv-vn.github.io/TelegraML/).

## Getting Started:

### Send "Hello, world" message

```ocaml
module MyBot = Telegram.Api.Mk (struct
  include Telegram.BotDefaults
  let token = [%blob "../bot.token"]
end);;

Lwt_main.run begin
  MyBot.send_message ~chat_id:(int_of_string [%blob "../chat.id"])
                     ~text:"Hello, world"
                     ~disable_notification:true
                     ~reply_to:None
                     ~reply_markup:None
                     ~parse_mode:None
                     ~disable_web_page_preview:false
end
```

Note that this example loads the files "chat.id" and "bot.token" from
the surrounding directory to use as the `chat_id` and `token`.

### Custom Message Parsing

By default, your bot will only respond to commands/callbacks. This will be fixed in the future as part of a rewrite of the library, but as of now you have to opt-in to a custom parser by watching updates by hand:

```ocaml
module MyBot = Telegram.Api.Mk(struct
  include Telegram.BotDefaults
  let token = (* blah blah blah *)
end)

(* Process the update and decide what to do with it/where to send it to *)
let process = function
  | Result.Success (Update.Message (id, message_info)) ->
    (* Do stuff with the message *)
  | _ -> return ()
  | Result.Failure e ->
    if e <> "Could not get head" then (* Don't spam when there's no updates *)
      Lwt_io.printl e
    else return ()

(* Repeatedly run the `process` function on each new update *)
let () =
  let rec loop () =
    MyBot.pop_update ~run_cmds:false () >>= process >>= loop in
  while true do (* Recover from errors if an exception is thrown *)
    try Lwt_main.run @@ loop ()
    with _ -> ()
  done
```

## Demos, examples, and users:

[hello world](https://github.com/nv-vn/TelegraML/tree/master/example/helloworld.ml) - Send "Hello, world" to a chat

[example](https://github.com/nv-vn/TelegraML/tree/master/example/bot.ml) - Responds to /say_hi, tests getting user profile pictures

[inline](https://github.com/nv-vn/TelegraML/tree/master/example/inline.ml) - Inline bot test

[greet](https://github.com/nv-vn/TelegraML/tree/master/example/greet.ml) - Chat event test

[glgbot](https://github.com/nv-vn/glgbot) - Some groupchat utilities: saved quotes, correcting messages, music jukebox, cute cat pics, and more

[telegraml-dashboard](https://github.com/nv-vn/telegraml-dashboard) - Tool for auto-generating web dashboards for your bots

[telegram-rpg](https://github.com/nv-vn/telegram-rpg)

If you're using TelegraML and you'd like your bot/extension/tutorial listed here, feel free to open a PR to list it
here with a link and a short description.

## API Status:

### What works?

* File uploading
* Inline replies
* Custom keyboards
* All of the data types
* Most of the methods (everything but `set_webhook`)

### What doesn't?

* No webhooks

### Extra features:

* Modular interface makes writing extensions simple (see [telegraml-dashboard](https://github.com/nv-vn/telegraml-dashboard))
* High-level interface for commands (`Telegram.Api.BOT.commands : Telegram.Api.Command.command list`)
  + Tons of convenience functions for parsing commands, etc.
  + Can exclude commands meant for other bots (`Telegram.Api.BOT.command_postfix : string option`)
  + Admin-only command authorization (`Telegram.Api.Command.with_auth : command:Telegram.Api.Command.command -> Telegram.Api.Command.action`)
  + Global command enabling/disabling
  + Combinators for composing complex actions sequences (`/>`, etc.)
* High-level chat event handling (`Telegram.Api.BOT.new_chat_member : Telegram.Api.Chat.chat -> Telegram.Api.User.user -> Telegram.Api.Command.action`, etc.)
* High-level inline mode bindings (`Telegram.Api.BOT.inline : Telegram.Api.InlineQuery.inline_query -> Telegram.Api.Command.action`)
* Default `Telegram.Api.TELEGRAM_BOT.run : ?log:bool -> unit -> unit` function for easy event loop setup
* Asynchronous, Lwt-based I/O

### Implemented Types:

* `Update`
* `User`
* `Chat`
* `Message`
* `MessageEntity`
* `PhotoSize`
* `Audio`
* `Document`
* `Sticker`
* `Video`
* `Voice`
* `Contact`
* `Location`
* `Venue`
* `UserProfilePhotos`
* `File`
* `ReplyKeyboardMarkup`
* `KeyboardButton`
* `ReplyKeyboardHide`
* `InlineKeyboardMarkup`
* `InlineKeyboardButton`
* `CallbackQuery`
* `ForceReply`
* `ChatMember`
* `InputFile`
* `InlineQuery`
* `InlineQueryResult`
* `InlineQueryResultArticle`
* `InlineQueryResultPhoto`
* `InlineQueryResultGif`
* `InlineQueryResultMpeg4Gif`
* `InlineQueryResultVideo`
* `InlineQueryResultAudio`
* `InlineQueryResultVoice`
* `InlineQueryResultDocument`
* `InlineQueryResultLocation`
* `InlineQueryResultVenue`
* `InlineQueryResultContact`
* `InlineQueryResultCachedPhoto`
* `InlineQueryResultCachedGif`
* `InlineQueryResultCachedMpeg4Gif`
* `InlineQueryResultCachedSticker`
* `InlineQueryResultCachedDocument`
* `InlineQueryResultCachedVideo`
* `InlineQueryResultCachedVoice`
* `InlineQueryResultCachedAudio`
* `InputMessageContent`
* `InputTextMessageContent`
* `InputLocationMessageContent`
* `InputVenueMessageContent`
* `InputContactMessageContent`
* `ChosenInlineResult`

### Implemented methods:

* `getMe`
* `sendMessage`
* `forwardMessage`
* `sendPhoto`
* `sendAudio`
* `sendDocument` (uses only mime-type `text/plain`)
* `sendSticker`
* `sendVideo`
* `sendVoice`
* `sendLocation`
* `sendVenue`
* `sendContact`
* `getUserProfilePhotos`
* `getFile`
* `kickChatMember`
* `leaveChat`
* `unbanChatMember`
* `getChat`
* `getChatAdministrators`
* `getChatMembersCount`
* `getChatMember`
* `sendChatAction`
* `getUpdates`
* `answerCallbackQuery`
* `editMessageText`
* `editMessageCaption`
* `editMessageReplyMarkup`
* `answerInlineQuery`
