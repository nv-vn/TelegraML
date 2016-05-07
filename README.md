# TelegraML

An OCaml library for creating bots for [Telegram Messenger](https://telegram.org/).
Bots are built using the official API provided by Telegram. The documentation can be viewed [here](https://core.telegram.org/bots/api#inline-mode-methods).

## Introduction:

Before creating a bot, it's recommended that you read through [this page](https://core.telegram.org/bots), which outlines some of the basic usage of bots and the process of registering and managing your bots.

The API is designed to make heavy use of OCaml's module system to provide a configurable template for creating new bots, with optional higher-level representations of features such as commands or inline responses.
All bots are created as modules, by instantiating the `Telegram.Api.Mk` functor, which will generate a module for using your bot directly.
The direct commands can be accessed as members of the module, with the API's methods in `snake_case` with `~named` arguments.
However, when using the higher-level APIs (for the inline responses or commands), it may be useful to reuse the same command generically across different bots. As a result, the commands/inline response functions are expected to return values of the `Telegram.Api.Command.action`.
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
end
```

Note that this example loads the files "chat.id" and "bot.token" from
the surrounding directory to use as the `chat_id` and `token`.

## Demos, examples, and users:

[hello world](https://github.com/nv-vn/TelegraML/tree/master/example/helloworld.ml) - Send "Hello, world" to a chat

[example](https://github.com/nv-vn/TelegraML/tree/master/example/bot.ml) - Responds to /say_hi, tests getting user profile pictures

[inline](https://github.com/nv-vn/TelegraML/tree/master/example/inline.ml) - Inline bot test

[glgbot](https://github.com/nv-vn/glgbot) - Some groupchat utilities: saved quotes, correcting messages, music jukebox, cute cat pics, and more

If you're using TelegraML and you'd like your bot listed here, feel free to open a PR to list it
here with a link and a short description.

## API Status:

### What works?

* File uploading
* Inline replies
* Custom keyboards
* Most of the data types
* Most of the methods

### What doesn't?

* No webhooks
* Missing some of the 2.0 inline mode API changes

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
* `unbanChatMember`
* `sendChatAction`
* `getUpdates`
* `answerCallbackQuery`
* `editMessageText`
* `editMessageCaption`
* `editMessageReplyMarkup`
* `answerInlineQuery`
