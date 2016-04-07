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

[example](https://github.com/nv-vn/TelegraML/tree/master/example)

[glgbot](https://github.com/nv-vn/glgbot)

## API Status:

### What works?

* Most of the data types
* Most of the methods
* File uploading

### What doesn't?

* No webhooks

### Implemented Types:

* `User`
* `Chat`
* `Message` (minus: `new_chat_participant`, `left_chat_participant`, `new_chat_title`, `new_chat_photo`, `delete_chat_photo`, `group_chat_created`, `supergroup_chat_created`, `channel_chat_created`, `migrate_to_chat_id`, and `migrate_from_chat_id`)
* `PhotoSize`
* `Audio`
* `Document`
* `Sticker`
* `Video`
* `Voice`
* `Contact`
* `Location`
* `UserProfilePhotos`
* `Update`
* `File`
* `InputFile`
* `ReplyKeyboardMarkup`
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
