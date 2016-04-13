# TelegraML

OCaml implementation of the Telegram Bot API

## Documentation:

Full OCamldoc-generated documentation is available [here](http://nv-vn.github.io/TelegraML/).

## Getting Started:

### Send "Hello, world" message

```ocaml
open Lwt
open Telegram.Api

module MyBot = Mk (struct
  include BotDefaults
  let token = [%blob "../bot.token"]
end)

let () =
  Lwt_main.run begin
    MyBot.send_message ~chat_id:(int_of_string [%blob "../chat.id"])
                       ~text:"Hello, world"
                       ~reply_to:None
                       ~reply_markup:None
    >>= fun _ -> return ()
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

* Most of the data types
* Most of the methods
* File uploading

### What doesn't?

* No webhooks
* Missing most 2.0 API features
* Can't currently disable notifications for sent messages

### Implemented Types:

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
* `Update`
* `File`
* `InputFile`
* `ReplyKeyboardMarkup`
* `KeyboardButton`
* `ReplyKeyboardHide`
* `ForceReply`
* `InlineQuery`
* `InlineQueryResult`
* `InlineQueryResultArticle`
* `InlineQueryResultPhoto`
* `InlineQueryResultGif`
* `InlineQueryResultMpeg4Gif`
* `InlineQueryResultVideo`
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
* `getUserProfilePhotos`
* `getFile`
* `sendChatAction`
* `getUpdates`
* `answerInlineQuery`
