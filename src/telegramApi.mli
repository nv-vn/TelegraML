open Yojson.Safe

(** Specifies the API used for creating Telegram bots, defined {{:https://core.telegram.org/bots/api} here.} *)

(** An exception thrown if some rules specified in the API are invalidated by incorrectly formatted data of some type *)
exception ApiException of string

(** This module deals with the parse mode used for formatting certain messages according to markup languages *)
module ParseMode : sig
  (** Represents the mode used for formatting text sent to the user (bold, italics, fixed-width, or inline URLs) *)
  type parse_mode = Markdown | Html

  (** Get the string representation of a [parse_mode] *)
  val string_of_parse_mode : parse_mode -> string
end

module User : sig
  (** Represents a user profile *)
  type user = {
    id         : int;
    first_name : string;
    last_name  : string option;
    username   : string option
  }

  (** Create a [user] in a concise manner *)
  val create : id:int -> first_name:string -> ?last_name:string option -> ?username:string option -> unit -> user
  (** Read a [user] out of some JSON *)
  val read : json -> user
end

(** Used to represent private messages, groupchats, and other types of Telegram chats *)
module Chat : sig
  (** The type of groupchat that the bot is in *)
  type chat_type = Private | Group | Supergroup | Channel

  (** Turn a string into a [chat_type] *)
  val read_type : string -> chat_type

  (** Represents a chat where messages can be sent or received *)
  type chat = {
    id         : int;
    chat_type  : chat_type;
    title      : string option;
    username   : string option;
    first_name : string option;
    last_name  : string option
  }

  (** Create a [chat] in a concise manner *)
  val create : id:int -> chat_type:chat_type -> ?title:string option -> ?username:string option -> ?first_name:string option -> ?last_name:string option -> unit -> chat
  (** Read a [chat] out of some JSON *)
  val read : json -> chat
end

(** Used for handling, loading, and sending outgoing files in messages *)
module InputFile : sig
  (** Loads a file (by filename) and returns the raw bytes inside of it *)
  val load : string -> string Lwt.t
  (** Used to format data as HTTP [multipart/form-data]
      Takes:
      - A list of fields to be included in the form data as a pair of strings (name, value)
      - A tuple of: {ul
        {li The name of the data field}
        {li The path to the file/the file's name}
        {li The mime type of the file}}
      - A string to be used as a boundary to split different parts of the data; ideally, this text should not be present in the raw data of the file being sent
      @return The formatted string to use as the HTTP body (make sure to correctly format the headers for multipart/form-data) *)
  val multipart_body : (string * string) list -> string * string * string -> string -> string Lwt.t
end

(** Used to represent formatting options for a message's text *)
module MessageEntity : sig
  (** The type of formatting to apply to the text *)
  type entity_type =
    | Mention
    | Hashtag
    | BotCommand
    | Url
    | Email
    | Bold
    | Italic
    | Code
    | Pre
    | TextLink of string
    | TextMention of User.user

  (** Takes the [url] and [user] fields of the record and the [type] field, then creates a value of type entity_type based on that *)
  val entity_type_of_string : string option -> User.user option -> string -> entity_type

  (** Represents the message entity inside of the message *)
  type message_entity = {
    entity_type : entity_type;
    offset      : int;
    length      : int
  }

  (** Create a [message_entity] in a concise manner *)
  val create : entity_type:entity_type -> offset:int -> length:int -> unit -> message_entity
  (** Read a [message_entity] out of some JSON *)
  val read : Yojson.Safe.json -> message_entity
end

(** Used to represent an individual button on a custom keyboard *)
module KeyboardButton : sig
  (** Represents the button's data *)
  type keyboard_button = {
    text             : string;
    request_contact  : bool option;
    request_location : bool option
  }

  (** Create a [keyboard_button] in a concise manner *)
  val create : text:string -> ?request_contact:bool option -> ?request_location:bool option -> unit -> keyboard_button
  (** Prepare an outgoing [keyboard_button] by serializing it to JSON *)
  val prepare : keyboard_button -> Yojson.Safe.json
end

(** Used to represent an individual button on a custom inline keyboard *)
module InlineKeyboardButton : sig
  (** Represents the button's data *)
  type inline_keyboard_button = {
    text                : string;
    url                 : string option;
    callback_data       : string option;
    switch_inline_query : string option
  }

  (** Create an [inline_keyboard_button] in a concise manner *)
  val create : text:string -> ?url:string option -> ?callback_data:string option -> ?switch_inline_query:string option -> unit -> inline_keyboard_button
  (** Prepare an outgoing [inline_keyboard_button] by serializing it to JSON *)
  val prepare : inline_keyboard_button -> Yojson.Safe.json
end

(** Markup options for users to reply to sent messages *)
module ReplyMarkup : sig
  (** Represents the custom keyboard type *)
  type reply_keyboard_markup = {
    keyboard          : KeyboardButton.keyboard_button list list;
    resize_keyboard   : bool option;
    one_time_keyboard : bool option;
    selective         : bool option
  }

  (** Represents a custom inline keyboard *)
  type inline_keyboard_markup = {
    inline_keyboard : InlineKeyboardButton.inline_keyboard_button list list
  }

  (** Represents the request to hide a keyboard *)
  type reply_keyboard_hide = {
    selective : bool option
  }

  (** Represents the request to force a reply *)
  type force_reply = {
    selective : bool option
  }

  (** Represents all possible reply markup options *)
  type reply_markup =
    | ReplyKeyboardMarkup of reply_keyboard_markup
    | InlineKeyboardMarkup of inline_keyboard_markup
    | ReplyKeyboardHide of reply_keyboard_hide
    | ForceReply of force_reply

  val prepare : reply_markup -> json

  (** Create a [ReplyKeyboardMarkup : reply_markup] in a concise way *)
  val create_reply_keyboard_markup : keyboard:KeyboardButton.keyboard_button list list -> ?resize_keyboard:bool option -> ?one_time_keyboard:bool option -> ?selective:bool option -> unit -> reply_markup

  (** Create an [InlineKeyboardMarkup : reply_markup] in a concise way *)
  val create_inline_keyboard_markup : inline_keyboard:InlineKeyboardButton.inline_keyboard_button list list -> unit -> reply_markup

  (** Create a [ReplyKeyboardHide : reply_markup] in a concise way *)
  val create_reply_keyboard_hide : ?selective:bool option -> unit -> reply_markup

  (** Create a [ForceReply : reply_markup] in a concise way *)
  val create_force_reply : ?selective:bool option -> unit -> reply_markup
end

(** This module is used for all images sent in chats *)
module PhotoSize : sig
  (** Represents any kind of image sent in a message or used as a thumbnail, profile picture, etc. *)
  type photo_size = {
    file_id   : string;
    width     : int;
    height    : int;
    file_size : int option
  }

  (** Create a [photo_size] in a concise manner *)
  val create : file_id:string -> width:int -> height:int -> ?file_size:int option -> unit -> photo_size
  (** Read a [photo_size] out of some JSON *)
  val read : json -> photo_size

  (** This module is used to deal with outgoing photo messages *)
  module Out : sig
    (** Represents the outgoing photo message. Note that the [photo] field can either be an existing file id or the raw bytes from a file *)
    type photo_size = {
      chat_id              : int;
      photo                : string;
      caption              : string option;
      disable_notification : bool;
      reply_to_message_id  : int option;
      reply_markup         : ReplyMarkup.reply_markup option
    }

    (** Create a [photo_size] in a concise manner *)
    val create : chat_id:int -> photo:string -> ?caption:string option -> ?disable_notification:bool -> ?reply_to:int option -> ?reply_markup:ReplyMarkup.reply_markup option -> unit -> photo_size
    (** Prepare a [photo_size] for sending -- used in the case of a file id *)
    val prepare : photo_size -> string
    (** Prepare a [photo_size] for sending -- used in the case of the raw bytes *)
    val prepare_multipart : photo_size -> string -> string Lwt.t
  end
end

module Audio : sig
  (** Represents an audio message (mp3) *)
  type audio = {
    file_id   : string;
    duration  : int;
    performer : string option;
    title     : string option;
    mime_type : string option;
    file_size : int option
  }

  (** Create an [audio] in a concise manner *)
  val create : file_id:string -> duration:int -> ?performer:string option -> ?title:string option -> ?mime_type:string option -> ?file_size:int option -> unit -> audio
  (** Read an [audio] out of some JSON *)
  val read : json -> audio

  (** This module is used to deal with outgoing audio messages *)
  module Out : sig
    (** Represents the outgoing audio message. Note that the [audio] field can either be an existing file id or the raw bytes from a file *)
    type audio = {
      chat_id              : int;
      audio                : string;
      duration             : int option;
      performer            : string;
      title                : string;
      disable_notification : bool;
      reply_to_message_id  : int option;
      reply_markup         : ReplyMarkup.reply_markup option
    }

    (** Create an [audio] in a concise manner *)
    val create : chat_id:int -> audio:string -> ?duration:int option -> performer:string -> title:string -> ?disable_notification:bool -> ?reply_to:int option -> ?reply_markup:ReplyMarkup.reply_markup option -> unit -> audio
    (** Prepare an [audio] for sending -- used in the case of a file id *)
    val prepare : audio -> string
    (** Prepare an [audio] for sending -- used in the case of the raw bytes *)
    val prepare_multipart : audio -> string -> string Lwt.t
 end
end

module Document : sig
  (** Represents a general file sent in a message *)
  type document = {
    file_id   : string;
    thumb     : PhotoSize.photo_size option;
    file_name : string option;
    mime_type : string option;
    file_size : int option
  }

  (** Create a [document] in a concise manner *)
  val create : file_id:string -> ?thumb:PhotoSize.photo_size option -> ?file_name:string option -> ?mime_type:string option -> ?file_size:int option -> unit -> document
  (** Read a [document] out of some JSON *)
  val read : json -> document

  (** This module is used to deal with outgoing documents *)
  module Out : sig
    (** Represents the document voice message. Note that the [document] field can either be an existing file id or the raw bytes from a file *)
    type document = {
      chat_id              : int;
      document             : string;
      disable_notification : bool;
      reply_to_message_id  : int option;
      reply_markup         : ReplyMarkup.reply_markup option
    }

    (** Create a [document] in a concise manner *)
    val create : chat_id:int -> document:string -> ?disable_notification:bool -> ?reply_to:int option -> ?reply_markup:ReplyMarkup.reply_markup option -> unit -> document
    (** Prepare a [document] for sending -- used in the case of a file id *)
    val prepare : document -> string
    (** Prepare a [document] for sending -- used in the case of the raw bytes *)
    val prepare_multipart : document -> string -> string Lwt.t
  end
end

module Sticker : sig
  (** Represents sticker messages *)
  type sticker = {
    file_id   : string;
    width     : int;
    height    : int;
    thumb     : PhotoSize.photo_size option;
    emoji     : string option;
    file_size : int option
  }

  (** Create a [sticker] in a concise manner *)
  val create : file_id:string -> width:int -> height:int -> ?thumb:PhotoSize.photo_size option -> ?emoji:string option -> ?file_size:int option -> unit -> sticker
  (** Read a [sticker] out of some JSON *)
  val read : json -> sticker

  (** This module deals with outgoing sticker messages *)
  module Out : sig
    (** Represents the outgoing sticker message. Note that the [sticker] field can either be an existing file id or the raw bytes from a file *)
    type sticker = {
      chat_id              : int;
      sticker              : string;
      disable_notification : bool;
      reply_to_message_id  : int option;
      reply_markup         : ReplyMarkup.reply_markup option
    }

    (** Create a [sticker] in a concise manner *)
    val create : chat_id:int -> sticker:string -> ?disable_notification:bool -> ?reply_to:int option -> ?reply_markup:ReplyMarkup.reply_markup option -> unit -> sticker
    (** Prepare a [sticker] for sending -- used in the case of a file id *)
    val prepare : sticker -> string
    (** Prepare a [sticker] for sending -- used in the case of the raw bytes *)
    val prepare_multipart : sticker -> string -> string Lwt.t
  end
end

module Video : sig
  (** Represents a video file sent in a message *)
  type video = {
    file_id   : string;
    width     : int;
    height    : int;
    duration  : int;
    thumb     : PhotoSize.photo_size option;
    mime_type : string option;
    file_size : int option
  }

  (** Create a [video] in a concise manner *)
  val create : file_id:string -> width:int -> height:int -> duration:int -> ?thumb:PhotoSize.photo_size option -> ?mime_type:string option -> ?file_size:int option -> unit -> video
  (** Read a [video] out of some JSON *)
  val read : json -> video

  (** This module deals with outgoing video messages *)
  module Out : sig
    (** Represents the outgoing video message. Note that the [video] field can either be an existing file id or the raw bytes from a file *)
    type video = {
      chat_id              : int;
      video                : string;
      duration             : int option;
      caption              : string option;
      disable_notification : bool;
      reply_to_message_id  : int option;
      reply_markup         : ReplyMarkup.reply_markup option
    }

    (** Create a [video] in a concise manner *)
    val create : chat_id:int -> video:string -> ?duration:int option -> ?caption:string option -> ?disable_notification:bool -> ?reply_to:int option -> ?reply_markup:ReplyMarkup.reply_markup option -> unit -> video
    (** Prepare a [video] for sending -- used in the case of a file id *)
    val prepare : video -> string
    (** Prepare a [video] for sending -- used in the case of the raw bytes *)
    val prepare_multipart : video -> string -> string Lwt.t
  end
end

module Voice : sig
  (** Represents a voice message (ogg) *)
  type voice = {
    file_id   : string;
    duration  : int;
    mime_type : string option;
    file_size : int option
  }

  (** Create a [voice] in a concise manner *)
  val create : file_id:string -> duration:int -> ?mime_type:string option -> ?file_size:int option -> unit -> voice
  (** Read a [voice] out of some JSON *)
  val read : json -> voice

  (** This module is used to deal with outgoing voice messages *)
  module Out : sig
    (** Represents the outgoing voice message. Note that the [voice] field can either be an existing file id or the raw bytes from a file *)
    type voice = {
      chat_id              : int;
      voice                : string;
      duration             : int option;
      disable_notification : bool;
      reply_to_message_id  : int option;
      reply_markup         : ReplyMarkup.reply_markup option
    }

    (** Create a [voice] in a concise manner *)
    val create : chat_id:int -> voice:string -> ?duration:int option -> ?disable_notification:bool -> ?reply_to:int option -> ?reply_markup:ReplyMarkup.reply_markup option -> unit -> voice
    (** Prepare a [voice] for sending -- used in the case of a file id *)
    val prepare : voice -> string
    (** Prepare a [voice] for sending -- used in the case of the raw bytes *)
    val prepare_multipart : voice -> string -> string Lwt.t
  end
end

module Contact : sig
  (** Represents a contact shared in a message *)
  type contact = {
    phone_number : string;
    first_name   : string;
    last_name    : string option;
    user_id      : int option
  }

  (** Create a [contact] in a concise manner *)
  val create : phone_number:string -> first_name:string -> ?last_name:string option -> ?user_id:int option -> unit -> contact
  (** Read a [contact] out of some JSON *)
  val read : json -> contact

  (** This module deals with outgoing contact messages *)
  module Out : sig
    (** Represents the outgoing contact message *)
    type contact = {
      chat_id              : int;
      phone_number         : string;
      first_name           : string;
      last_name            : string option;
      disable_notification : bool;
      reply_to_message_id  : int option;
      reply_markup         : ReplyMarkup.reply_markup option
    }

    (** Create a [contact] in a concise manner *)
    val create : chat_id:int -> phone_number:string -> first_name:string -> ?last_name:string option -> ?disable_notification:bool -> ?reply_to:int option -> ?reply_markup:ReplyMarkup.reply_markup option -> unit -> contact
    (** Prepare a [contact] for sending *)
    val prepare : contact -> string
  end
end

module Location : sig
  (** Represents a location sent by a user in terms of longitude/latitude coordinates *)
  type location = {
    longitude : float;
    latitude  : float
  }

  (** Create a [location] in a concise manner *)
  val create : longitude:float -> latitude:float -> unit -> location
  (** Read a [location] out of some JSON *)
  val read : json -> location

  (** This module deals with outgoing location messages *)
  module Out : sig
    (** Represents the outgoing location message *)
    type location = {
      chat_id              : int;
      latitude             : float;
      longitude            : float;
      disable_notification : bool;
      reply_to_message_id  : int option;
      reply_markup         : ReplyMarkup.reply_markup option
    }

    (** Create a [location] in a concise manner *)
    val create : chat_id:int -> latitude:float -> longitude:float -> ?disable_notification:bool -> ?reply_to:int option -> ?reply_markup:ReplyMarkup.reply_markup option -> unit -> location
    (** Prepare a [location] for sending *)
    val prepare : location -> string
  end
end

module Venue : sig
  (** Represents an event venue in a chat *)
  type venue = {
    location      : Location.location;
    title         : string;
    address       : string;
    foursquare_id : string option
  }

  (** Create a [venue] in a concise manner *)
  val create : location:Location.location -> title:string -> address:string -> ?foursquare_id:string option -> unit -> venue
  (** Read a [venue] out of some JSON *)
  val read : Yojson.Safe.json -> venue

  module Out : sig
    type venue = {
      chat_id              : int;
      latitude             : float;
      longitude            : float;
      title                : string;
      address              : string;
      foursquare_id        : string option;
      disable_notification : bool;
      reply_to_message_id  : int option;
      reply_markup         : ReplyMarkup.reply_markup option
    }

    (** Create a [venue] in a concise manner *)
    val create : chat_id:int -> latitude:float -> longitude:float -> title:string -> address:string -> ?foursquare_id:string option ->  ?disable_notification:bool -> reply_to:int option -> reply_markup:ReplyMarkup.reply_markup option -> unit -> venue
    (** Prepare a [venue] for sending *)
    val prepare : venue -> string
  end
end

module UserProfilePhotos : sig
  (** Represents a user's profile pictures, each in multiple sizes *)
  type user_profile_photos = {
    total_count : int;
    photos      : PhotoSize.photo_size list list
  }

  (** Create [user_profile_photos] in a concise manner *)
  val create : total_count:int -> photos:PhotoSize.photo_size list list -> unit -> user_profile_photos
  (** Read [user_profile_photos] out of some JSON *)
  val read : Yojson.Safe.json -> user_profile_photos
end

module Message : sig
  (** Represents a message in a chat. Note that [photo] should be a list of [PhotoSize.photo_size]s if it exists *)
  type message = {
    message_id              : int;
    from                    : User.user option;
    date                    : int;
    chat                    : Chat.chat;
    forward_from            : User.user option;
    forward_from_chat       : Chat.chat option;
    forward_date            : int option;
    reply_to_message        : message option;
    edit_date               : int option;
    text                    : string option;
    entities                : MessageEntity.message_entity list option;
    audio                   : Audio.audio option;
    document                : Document.document option;
    photo                   : PhotoSize.photo_size list option;
    sticker                 : Sticker.sticker option;
    video                   : Video.video option;
    voice                   : Voice.voice option;
    caption                 : string option;
    contact                 : Contact.contact option;
    location                : Location.location option;
    venue                   : Venue.venue option;
    new_chat_member         : User.user option;
    left_chat_member        : User.user option;
    new_chat_title          : string option;
    new_chat_photo          : PhotoSize.photo_size list option;
    delete_chat_photo       : bool option;
    group_chat_created      : bool option;
    supergroup_chat_created : bool option;
    channel_chat_created    : bool option;
    migrate_to_chat_id      : int option;
    migrate_from_chat_id    : int option;
    pinned_message          : message option
  }

  (** Create a [message] in a concise manner *)
  val create : message_id:int -> ?from:User.user option -> date:int -> chat:Chat.chat -> ?forward_from:User.user option -> ?forward_from_chat:Chat.chat option -> ?forward_date:int option -> ?reply_to:message option -> ?edit_date:int option -> ?text:string option -> ?entities:MessageEntity.message_entity list option -> ?audio:Audio.audio option -> ?document:Document.document option -> ?photo:PhotoSize.photo_size list option -> ?sticker:Sticker.sticker option -> ?video:Video.video option -> ?voice:Voice.voice option -> ?caption:string option -> ?contact:Contact.contact option -> ?location:Location.location option -> ?venue:Venue.venue option -> ?new_chat_member:User.user option -> ?left_chat_member:User.user option -> ?new_chat_title:string option -> ?new_chat_photo:PhotoSize.photo_size list option -> ?delete_chat_photo:bool option -> ?group_chat_created:bool option -> ?supergroup_chat_created:bool option -> ?channel_chat_created:bool option -> ?migrate_to_chat_id:int option -> ?migrate_from_chat_id:int option -> ?pinned_message:message option -> unit -> message
  (** Read a [message] out of some JSON *)
  val read : json -> message

  (** Get the first name of the user who sent the message *)
  val get_sender_first_name : message -> string
  (** Get the username of the user who sent the message *)
  val get_sender_username : message -> string
  (** Get a formatted name for the user who sent the message: first name, with the username in parentheses if it exists *)
  val get_sender : message -> string
end

(** This module is used for downloadable files uploaded to the Telegram servers *)
module File : sig
  (** Represents the information returned by [getFile] for the file_id *)
  type file = {
    file_id   : string;
    file_size : int option;
    file_path : string option
  }

  (** Create a [file] in a concise manner *)
  val create : file_id:string -> ?file_size:int option -> ?file_path:string option -> unit -> file
  (** Read a [file] out of some JSON *)
  val read : Yojson.Safe.json -> file

  (** Download the file from Telegram's servers if it exists *)
  val download : string -> file -> string Lwt.t option
end

(** This module is used for dealing with the results returned by clicking on callback buttons on inline keyboards *)
module CallbackQuery : sig
  (** Represents the reply from the callback query *)
  type callback_query = {
    id                : string;
    from              : User.user;
    message           : Message.message option;
    inline_message_id : string option;
    data              : string
  }

  (** Create a [callback_query] in a concise manner *)
  val create : id:string -> from:User.user -> ?message:Message.message option -> ?inline_message_id:string option -> data:string -> unit -> callback_query
  (** Read a [callback_query] out of some JSON *)
  val read : Yojson.Safe.json -> callback_query
end

(** This module is used to deal with information about an individual member of a chat *)
module ChatMember : sig
  (** Represents the user's role in the chat *)
  type status = Creator | Administrator | Member | Left | Kicked

  (** Extract the status out of a string *)
  val status_of_string : string -> status

  (** Represents the chat member object (the user itself and their status) *)
  type chat_member = {
    user : User.user;
    status : status
  }

  (** Create a [chat_member] in a concise manner *)
  val create : user:User.user -> status:status -> unit -> chat_member
  (** Read a [chat_member] out of some JSON *)
  val read : Yojson.Safe.json -> chat_member
end

(** This module is used to deal with the content being sent as the result of an inline query *)
module InputMessageContent : sig
  (** Represents the content of a text message to be sent as the result of an inline query *)
  type text = {
    message_text             : string;
    parse_mode               : ParseMode.parse_mode option;
    disable_web_page_preview : bool
  }
  (** Represents the content of a location message to be sent as the result of an inline query *)
  type location = {
    latitude  : float;
    longitude : float
  }
  (** Represents the content of a venue message to be sent as the result of an inline query *)
  type venue = {
    latitude      : float;
    longitude     : float;
    title         : string;
    address       : string;
    foursquare_id : string option
  }
  (** Represents the content of a contact message to be sent as the result of an inline query *)
  type contact = {
    phone_number : string;
    first_name   : string;
    last_name    : string option
  }
  (** Represents the content of a message to be sent as the result of an inline query *)
  type input_message_content =
    | Text of text
    | Location of location
    | Venue of venue
    | Contact of contact

  (** Create a [Text : input_message_content] in a concise manner *)
  val create_text : message_text:string -> ?parse_mode:ParseMode.parse_mode -> ?disable_web_page_preview:bool -> unit -> input_message_content
  (** Create a [Location : input_message_content] in a concise manner *)
  val create_location : latitude:float -> longitude:float -> unit -> input_message_content
  (** Create a [Venue : input_message_content] in a concise manner *)
  val create_venue : latitude:float -> longitude:float -> title:string -> address:string -> ?foursquare_id:string -> unit -> input_message_content
  (** Create a [Contact : input_message_content] in a concise manner *)
  val create_contact : phone_number:string -> first_name:string -> ?last_name:string -> unit -> input_message_content

  (** Prepare [input_message_content] for sending by converting it to JSON *)
  val prepare : input_message_content -> Yojson.Safe.json
end


(** This module is used for InlineQuery bots *)
module InlineQuery : sig
  (** Represents incoming messages for an InlineQuery bot *)
  type inline_query = {
    id     : string;
    from   : User.user;
    query  : string;
    offset : string
  }

  (** Create an [inline_query] in a concise manner *)
  val create : id:string -> from:User.user -> query:string -> offset:string -> unit -> inline_query
  (** Read an [inline_query] out of some JSON *)
  val read : Yojson.Safe.json -> inline_query

  (** Represents the reply to an InlineQuery bot if one is requested *)
  type chosen_inline_result = {
    result_id : string;
    from      : User.user;
    query     : string
  }

  (** Read a [chosen_inline_query] out of some JSON *)
  val read_chosen_inline_result : Yojson.Safe.json -> chosen_inline_result

  (** This module is used to deal with outgoing replies to inline queries for an InlineQuery bot *)
  module Out : sig
    (** Represents an article sent as a reply *)
    type article = {
      id                       : string;
      title                    : string;
      input_message_content    : InputMessageContent.input_message_content;
      reply_markup             : ReplyMarkup.reply_markup option;
      url                      : string option;
      hide_url                 : bool option;
      description              : string option;
      thumb_url                : string option;
      thumb_width              : int option;
      thumb_height             : int option
    }
    (** Represents a photo (jpeg) sent as a reply *)
    type photo = {
      id                       : string;
      photo_url                : string;
      thumb_url                : string;
      photo_width              : int option;
      photo_height             : int option;
      title                    : string option;
      description              : string option;
      caption                  : string option;
      reply_markup             : ReplyMarkup.reply_markup option;
      input_message_content    : InputMessageContent.input_message_content option
    }
    (** Represents a gif sent as a reply *)
    type gif = {
      id                       : string;
      gif_url                  : string;
      gif_width                : int option;
      gif_height               : int option;
      thumb_url                : string;
      title                    : string option;
      caption                  : string option;
      reply_markup             : ReplyMarkup.reply_markup option;
      input_message_content    : InputMessageContent.input_message_content option
    }
    (** Represents a gif sent as a reply, but converted to an mp4 video file *)
    type mpeg4gif = {
      id                       : string;
      mpeg4_url                : string;
      mpeg4_width              : int option;
      mpeg4_height             : int option;
      thumb_url                : string;
      title                    : string option;
      caption                  : string option;
      reply_markup             : ReplyMarkup.reply_markup option;
      input_message_content    : InputMessageContent.input_message_content option
    }
    (** Represents a video sent as a reply *)
    type video = {
      id                       : string;
      video_url                : string;
      mime_type                : string;
      thumb_url                : string;
      title                    : string;
      caption                  : string option;
      video_width              : int option;
      video_height             : int option;
      video_duration           : int option;
      description              : string option;
      reply_markup             : ReplyMarkup.reply_markup option;
      input_message_content    : InputMessageContent.input_message_content option
    }
    (** Represents an audio file (mp3) sent as a reply *)
    type audio = {
      id                    : string;
      audio_url             : string;
      title                 : string;
      performer             : string option;
      audio_duration        : int option;
      reply_markup          : ReplyMarkup.reply_markup option;
      input_message_content : InputMessageContent.input_message_content option
    }
    (** Represents a voice recording (ogg) sent as a reply *)
    type voice = {
      id                    : string;
      voice_url             : string;
      title                 : string;
      voice_duration        : int option;
      reply_markup          : ReplyMarkup.reply_markup option;
      input_message_content : InputMessageContent.input_message_content option
    }
    (** Represents a generic file/document (.pdf/.zip supported) sent as a reply *)
    type document = {
      id                    : string;
      title                 : string;
      caption               : string option;
      document_url          : string;
      mime_type             : string;
      description           : string option;
      reply_markup          : ReplyMarkup.reply_markup option;
      input_message_content : InputMessageContent.input_message_content option;
      thumb_url             : string option;
      thumb_width           : int option;
      thumb_height          : int option
    }
    (** Represents a location on a map (usually the user's location) *)
    type location = {
      id                    : string;
      latitude              : float;
      longitude             : float;
      title                 : string;
      reply_markup          : ReplyMarkup.reply_markup option;
      input_message_content : InputMessageContent.input_message_content option;
      thumb_url             : string option;
      thumb_width           : int option;
      thumb_height          : int option
    }
    (** Represents a venue for an event set by the user *)
    type venue = {
      id                    : string;
      latitude              : float;
      longitude             : float;
      title                 : string;
      address               : string;
      foursquare_id         : string option;
      reply_markup          : ReplyMarkup.reply_markup option;
      input_message_content : InputMessageContent.input_message_content option;
      thumb_url             : string option;
      thumb_width           : int option;
      thumb_height          : int option
    }
    (** Represents contact info for a user being sent *)
    type contact = {
      id                    : string;
      phone_number          : string;
      first_name            : string;
      last_name             : string option;
      reply_markup          : ReplyMarkup.reply_markup option;
      input_message_content : InputMessageContent.input_message_content option;
      thumb_url             : string option;
      thumb_width           : int option;
      thumb_height          : int option
    }
    (** Represents a photo, which has already been uploaded to the Telegram servers, sent as a reply *)
    type cached_photo = {
      id                       : string;
      photo_file_id            : string;
      title                    : string option;
      description              : string option;
      caption                  : string option;
      reply_markup             : ReplyMarkup.reply_markup option;
      input_message_content    : InputMessageContent.input_message_content option
    }
    (** Represents a gif, which has already been uploaded to the Telegram servers, sent as a reply *)
    type cached_gif = {
      id                       : string;
      gif_file_id              : string;
      title                    : string option;
      caption                  : string option;
      reply_markup             : ReplyMarkup.reply_markup option;
      input_message_content    : InputMessageContent.input_message_content option
    }
    (** Represents a gif, which has already been uploaded to the Telegram servers, sent as a reply, but converted to an mp4 video file *)
    type cached_mpeg4gif = {
      id                       : string;
      mpeg4_file_id            : string;
      title                    : string option;
      caption                  : string option;
      reply_markup             : ReplyMarkup.reply_markup option;
      input_message_content    : InputMessageContent.input_message_content option
    }
    (** Represents a link to a sticker stored on the Telegram servers *)
    type cached_sticker = {
      id                    : string;
      sticker_file_id       : string;
      reply_markup          : ReplyMarkup.reply_markup option;
      input_message_content : InputMessageContent.input_message_content option
    }
    (** Represents a file (PDF or ZIP), which has already been uploaded to the Telegram servers, sent as a reply *)
    type cached_document = {
      id                    : string;
      title                 : string;
      document_file_id      : string;
      description           : string option;
      caption               : string option;
      reply_markup          : ReplyMarkup.reply_markup option;
      input_message_content : InputMessageContent.input_message_content option
    }
    (** Represents a video, which has already been uploaded to the Telegram servers, sent as a reply *)
    type cached_video = {
      id                       : string;
      video_file_id            : string;
      title                    : string;
      description              : string option;
      caption                  : string option;
      reply_markup             : ReplyMarkup.reply_markup option;
      input_message_content    : InputMessageContent.input_message_content option
    }
    (** Represents a voice recording (OGG), which has already been uploaded to the Telegram servers, sent as a reply *)
    type cached_voice = {
      id                    : string;
      voice_file_id         : string;
      title                 : string;
      reply_markup          : ReplyMarkup.reply_markup option;
      input_message_content : InputMessageContent.input_message_content option
    }
    (** Represents an audio clip (MP3), which has already been uploaded to the Telegram servers, sent as a reply *)
    type cached_audio = {
      id                    : string;
      audio_file_id         : string;
      reply_markup          : ReplyMarkup.reply_markup option;
      input_message_content : InputMessageContent.input_message_content option
    }

    (** Represents all the replies that can be given to an inline query *)
    type inline_query_result =
      | Article of article
      | Photo of photo
      | Gif of gif
      | Mpeg4Gif of mpeg4gif
      | Video of video
      | Audio of audio
      | Voice of voice
      | Document of document
      | Location of location
      | Venue of venue
      | Contact of contact
      | CachedPhoto of cached_photo
      | CachedGif of cached_gif
      | CachedMpeg4Gif of cached_mpeg4gif
      | CachedSticker of cached_sticker
      | CachedDocument of cached_document
      | CachedVideo of cached_video
      | CachedVoice of cached_voice
      | CachedAudio of cached_audio

    (** Create an [Article : inline_query_result] in a concise manner *)
    val create_article : id:string -> title:string -> input_message_content:InputMessageContent.input_message_content -> ?reply_markup:ReplyMarkup.reply_markup -> ?url:string -> ?hide_url:bool -> ?description:string -> ?thumb_url:string -> ?thumb_width:int -> ?thumb_height:int -> unit -> inline_query_result
    (** Create a [Photo : inline_query_result] in a concise manner *)
    val create_photo : id:string -> photo_url:string -> thumb_url:string -> ?photo_width:int -> ?photo_height:int -> ?title:string -> ?description:string -> ?caption:string -> ?reply_markup:ReplyMarkup.reply_markup -> ?input_message_content:InputMessageContent.input_message_content -> unit -> inline_query_result
    (** Create a [Gif : inline_query_result] in a concise manner *)
    val create_gif : id:string -> gif_url:string -> ?gif_width:int -> ?gif_height:int -> thumb_url:string -> ?title:string -> ?caption:string -> ?reply_markup:ReplyMarkup.reply_markup -> ?input_message_content:InputMessageContent.input_message_content -> unit -> inline_query_result
    (** Create an [Mpeg4Gif : inline_query_result] in a concise manner *)
    val create_mpeg4gif : id:string -> mpeg4_url:string -> ?mpeg4_width:int -> ?mpeg4_height:int -> thumb_url:string -> ?title:string -> ?caption:string -> ?reply_markup:ReplyMarkup.reply_markup -> ?input_message_content:InputMessageContent.input_message_content -> unit -> inline_query_result
    (** Create a [Video : inline_query_result] in a concise manner *)
    val create_video : id:string -> video_url:string -> mime_type:string -> thumb_url:string -> title:string -> ?caption:string -> ?video_width:int -> ?video_height:int -> ?video_duration:int -> ?description:string -> ?reply_markup:ReplyMarkup.reply_markup -> ?input_message_content:InputMessageContent.input_message_content -> unit -> inline_query_result
    (** Create an [Audio : inline_query_result] in a concise manner *)
    val create_audio : id:string -> audio_url:string -> title:string -> ?performer:string -> ?audio_duration:int -> ?reply_markup:ReplyMarkup.reply_markup -> ?input_message_content:InputMessageContent.input_message_content -> unit -> inline_query_result
    (** Create a [Voice : inline_query_result] in a concise manner *)
    val create_voice : id:string -> voice_url:string -> title:string -> ?voice_duration:int -> ?reply_markup:ReplyMarkup.reply_markup -> ?input_message_content:InputMessageContent.input_message_content -> unit -> inline_query_result
    (** Create a [Document : inline_query_result] in a concise manner *)
    val create_document : id:string -> title:string -> ?caption:string -> document_url:string -> mime_type:string -> ?description:string -> ?reply_markup:ReplyMarkup.reply_markup -> ?input_message_content:InputMessageContent.input_message_content -> ?thumb_url:string -> ?thumb_width:int -> ?thumb_height:int -> unit -> inline_query_result
    (** Create a [Location : inline_query_result] in a concise manner *)
    val create_location : id:string -> latitude:float -> longitude:float -> title:string -> ?reply_markup:ReplyMarkup.reply_markup -> ?input_message_content:InputMessageContent.input_message_content -> ?thumb_url:string -> ?thumb_width:int -> ?thumb_height:int -> unit -> inline_query_result
    (** Create a [Venue : inline_query_result] in a concise manner *)
    val create_venue : id:string -> latitude:float -> longitude:float -> title:string -> address:string -> ?foursquare_id:string -> ?reply_markup:ReplyMarkup.reply_markup -> ?input_message_content:InputMessageContent.input_message_content -> ?thumb_url:string -> ?thumb_width:int -> ?thumb_height:int -> unit -> inline_query_result
    (** Create a [Contact : inline_query_result] in a concise manner *)
    val create_contact : id:string -> phone_number:string -> first_name:string -> ?last_name:string -> ?reply_markup:ReplyMarkup.reply_markup -> ?input_message_content:InputMessageContent.input_message_content -> ?thumb_url:string -> ?thumb_width:int -> ?thumb_height:int -> unit -> inline_query_result
    (** Create a [CachedPhoto : inline_query_result] in a concise manner *)
    val create_cached_photo : id:string -> photo_file_id:string -> ?title:string -> ?description:string -> ?caption:string -> ?reply_markup:ReplyMarkup.reply_markup -> ?input_message_content:InputMessageContent.input_message_content -> unit -> inline_query_result
    (** Create a [CachedGif : inline_query_result] in a concise manner *)
    val create_cached_gif : id:string -> gif_file_id:string -> ?title:string -> ?caption:string -> ?reply_markup:ReplyMarkup.reply_markup -> ?input_message_content:InputMessageContent.input_message_content -> unit -> inline_query_result
    (** Create a [CachedMpeg4Gif : inline_query_result] in a concise manner *)
    val create_cached_mpeg4gif : id:string -> mpeg4_file_id:string -> ?title:string -> ?caption:string -> ?reply_markup:ReplyMarkup.reply_markup -> ?input_message_content:InputMessageContent.input_message_content -> unit -> inline_query_result
    (** Create a [CachedSticker : inline_query_result] in a concise manner *)
    val create_cached_sticker : id:string -> sticker_file_id:string -> ?reply_markup:ReplyMarkup.reply_markup -> ?input_message_content:InputMessageContent.input_message_content -> unit -> inline_query_result
    (** Create a [CachedDocument : inline_query_result] in a concise manner *)
    val create_cached_document : id:string -> title:string -> document_file_id:string -> ?description:string -> ?caption:string -> ?reply_markup:ReplyMarkup.reply_markup -> ?input_message_content:InputMessageContent.input_message_content -> unit -> inline_query_result
    (** Create a [CachedVideo : inline_query_result] in a concise manner *)
    val create_cached_video : id:string -> video_file_id:string -> title:string -> ?description:string -> ?caption:string -> ?reply_markup:ReplyMarkup.reply_markup -> ?input_message_content:InputMessageContent.input_message_content -> unit -> inline_query_result
    (** Create a [CachedVoice : inline_query_result] in a concise manner *)
    val create_cached_voice : id:string -> voice_file_id:string -> title:string -> ?reply_markup:ReplyMarkup.reply_markup -> ?input_message_content:InputMessageContent.input_message_content -> unit -> inline_query_result
    (** Create a [CachedAudio : inline_query_result] in a concise manner *)
    val create_cached_audio : id:string -> audio_file_id:string -> ?reply_markup:ReplyMarkup.reply_markup -> ?input_message_content:InputMessageContent.input_message_content -> unit -> inline_query_result
    (** Prepare an [inline_query_result] for sending *)
    val prepare : inline_query_result -> Yojson.Safe.json
  end
end

(** Actions that can be sent as user statuses *)
module ChatAction : sig
  (** Represents all recognized chat actions *)
  type action =
    | Typing
    | UploadPhoto
    | RecordVideo
    | UploadVideo
    | RecordAudio
    | UploadAudio
    | UploadDocument
    | FindLocation

  (** Gets the string representation of the action, for use in JSON *)
  val to_string : action -> string
end

module Update : sig
  (** Stores the info for updates to a chat/group *)
  type update =
    | Message of int * Message.message
    | EditedMessage of int * Message.message
    | InlineQuery of int * InlineQuery.inline_query
    | ChosenInlineResult of int * InlineQuery.chosen_inline_result
    | CallbackQuery of int * CallbackQuery.callback_query

  (** Read an [update] out of some JSON *)
  val read : json -> update

  (** Get the [update_id] out of an arbitrary [update] object *)
  val get_id : update -> int
end

(** Used for representing results of various actions where a success or failure can occur. Contains helper functions to implement a monadic and functorial interface. *)
module Result : sig
  (** Stores the return value if a function succeeded or a string if the function failed *)
  type 'a result = Success of 'a | Failure of string

  (** Raise a normal value into a [Success : result] *)
  val return : 'a -> 'a result

  (** Take the value of the result, if it succeeded, or the other argument by default and return that *)
  val default : 'a -> 'a result -> 'a

  (** Bind [Success]es through the given function *)
  val (>>=) : 'a result -> ('a -> 'b result) -> 'b result

  (** Map [Success]es through the given function *)
  val (<$>) : ('a -> 'b) -> 'a result -> 'b result
end

module Command : sig
  (** The actions that can be used by the bot's commands *)
  type action =
    | Nothing
    | GetMe of (User.user Result.result -> action)
    | SendMessage of int * string * bool * int option * ReplyMarkup.reply_markup option
    | ForwardMessage of int * int * bool * int
    | SendChatAction of int * ChatAction.action
    | SendPhoto of int * string * string option * bool * int option * ReplyMarkup.reply_markup option * (string Result.result -> action)
    | ResendPhoto of int * string * string option * bool * int option * ReplyMarkup.reply_markup option
    | SendAudio of int * string * string * string * bool * int option * ReplyMarkup.reply_markup option * (string Result.result -> action)
    | ResendAudio of int * string * string * string * bool * int option * ReplyMarkup.reply_markup option
    | SendDocument of int * string * bool * int option * ReplyMarkup.reply_markup option * (string Result.result -> action)
    | ResendDocument of int * string * bool * int option * ReplyMarkup.reply_markup option
    | SendSticker of int * string * bool * int option * ReplyMarkup.reply_markup option * (string Result.result -> action)
    | ResendSticker of int * string * bool * int option * ReplyMarkup.reply_markup option
    | SendVideo of int * string * int option * string option * bool * int option * ReplyMarkup.reply_markup option * (string Result.result -> action)
    | ResendVideo of int * string * int option * string option * bool * int option * ReplyMarkup.reply_markup option
    | SendVoice of int * string * bool * int option * ReplyMarkup.reply_markup option * (string Result.result -> action)
    | ResendVoice of int * string * bool * int option * ReplyMarkup.reply_markup option
    | SendLocation of int * float * float * bool * int option * ReplyMarkup.reply_markup option
    | SendVenue of int * float * float * string * string * string option * bool * int option * ReplyMarkup.reply_markup option
    | SendContact of int * string * string * string option * bool * int option * ReplyMarkup.reply_markup option
    | GetUserProfilePhotos of int * int option * int option * (UserProfilePhotos.user_profile_photos Result.result -> action)
    | GetFile of string * (File.file Result.result -> action)
    | GetFile' of string * (string option -> action)
    | DownloadFile of File.file * (string option -> action)
    | KickChatMember of int * int
    | LeaveChat of int
    | UnbanChatMember of int * int
    | GetChat of int * (Chat.chat Result.result -> action)
    | GetChatAdministrators of int * (ChatMember.chat_member list Result.result -> action)
    | GetChatMembersCount of int * (int Result.result -> action)
    | GetChatMember of int * int * (ChatMember.chat_member Result.result -> action)
    | AnswerCallbackQuery of string * string option * bool
    | AnswerInlineQuery of string * InlineQuery.Out.inline_query_result list * int option * bool option * string option
    | EditMessageText of [`ChatMessageId of string * int | `InlineMessageId of string] * string * ParseMode.parse_mode option * bool * ReplyMarkup.reply_markup option
    | EditMessageCaption of [`ChatMessageId of string * int | `InlineMessageId of string] * string * ReplyMarkup.reply_markup option
    | EditMessageReplyMarkup of [`ChatMessageId of string * int | `InlineMessageId of string] * ReplyMarkup.reply_markup option
    | GetUpdates of (Update.update list Result.result -> action)
    | PeekUpdate of (Update.update Result.result -> action)
    | PopUpdate of bool * (Update.update Result.result -> action)
    | Chain of action * action

  (** This type is used to represent available commands. The [name] field is the command's name (without a slash) and the [description] field is the description to be used in the help message. [run] is the function called when invoking the command. *)
  type command = {
    name            : string;
    description     : string;
    mutable enabled : bool;
    run             : Message.message -> action
  }

  (** Tests to see whether an update from the update queue invoked a command *)
  val is_command : Update.update -> bool

  (** Takes an optional postfix for commands (/cmd@bot), a message, known to represent a command, and a list of possible commands. These values are used to find the matching command and return the actions that it should perform *)
  val read_command : string option -> Message.message -> command list -> action

  (** Reads a single update and, given a list of commands, matches it to a correct command that can be invoked.  Takes an optional postfix for commands (/cmd@bot) as the first parameter *)
  val read_update : string option -> Update.update -> command list -> action

  (** Turns a string into the args list that a command may choose to work with *)
  val tokenize : string -> string list

  (** [with_auth ~command] makes a [command] only run when the caller is an admin in the chat *)
  val with_auth : command:(Message.message -> action) -> Message.message -> action
end

(** BOT is strictly used for customization of a TELEGRAM_BOT module. Once your customizations have been applied, pass it into Api.Mk to create
    the usable TELEGRAM_BOT interface. *)
module type BOT = sig
  (** The API token to use for the bot. Warning: please load this in when the bot starts or use ppx_blob to load this in at compile-time and add the blob to your .gitignore *)
  val token : string

  (** An optional postfix to require after commands, usually the bots username (so /hello@mybot will be ignored by @yourbot) *)
  val command_postfix : string option

  (** The list of commands that the bot will be able to use *)
  val commands : Command.command list

  (** The function to call on inline queries *)
  val inline : InlineQuery.inline_query -> Command.action

  (** The function to call on callback queries *)
  val callback : CallbackQuery.callback_query -> Command.action

  (** Called whenever a new user is added to or joins a chat *)
  val new_chat_member : Chat.chat -> User.user -> Command.action

  (** Called whenever a user leaves a chat *)
  val left_chat_member : Chat.chat -> User.user -> Command.action

  (** Called when the title for a chat is changed *)
  val new_chat_title : Chat.chat -> string -> Command.action

  (** Called whenever a new chat photo is set or the current one is changed *)
  val new_chat_photo : Chat.chat -> PhotoSize.photo_size list -> Command.action

  (** Called whenever a chat's photo gets deleted *)
  val delete_chat_photo : Chat.chat -> Command.action

  (** Called whenever a chat turns into a group chat *)
  val group_chat_created : Chat.chat -> Command.action

  (** Called whenever a chat turns into a supergroup chat *)
  val supergroup_chat_created : Chat.chat -> Command.action

  (** Called whenever a chat turns into a channel *)
  val channel_chat_created : Chat.chat -> Command.action

  (** Called whenever a chat migrates to a new chat id *)
  val migrate_to_chat_id : Chat.chat -> int -> Command.action

  (** Called whenever a chat has been migrated from another chat id *)
  val migrate_from_chat_id : Chat.chat -> int -> Command.action

  (** Called whenever a certain message is pinned for a chat *)
  val pinned_message : Chat.chat -> Message.message -> Command.action
end

(** TELEGRAM_BOT represents the interface to a running bot *)
module type TELEGRAM_BOT = sig
  (** The base url for all connections to the API *)
  val url : string

  (** A list of all commands supported by the bot *)
  val commands : Command.command list

  (** The inline query handler for the bot *)
  val inline : InlineQuery.inline_query -> Command.action

  (** The callback query handler for the bot *)
  val callback : CallbackQuery.callback_query -> Command.action

  (** Get the user information for the bot; use to test connection to the Telegram server *)
  val get_me : User.user Result.result Lwt.t

  (** Send a text message to a specified chat *)
  val send_message : chat_id:int -> text:string -> ?disable_notification:bool -> reply_to:int option -> reply_markup:ReplyMarkup.reply_markup option -> unit Result.result Lwt.t

  (** Forwards any message from one chat to another (can be same chat) *)
  val forward_message : chat_id:int -> from_chat_id:int -> ?disable_notification:bool -> message_id:int -> unit Result.result Lwt.t

  (** Send an action report to the chat, to show that a command will take some time *)
  val send_chat_action : chat_id:int -> action:ChatAction.action -> unit Result.result Lwt.t

  (** Send a new image file (jpeg/png) to a specified chat. Note that [photo] refers to the file's name to send. *)
  val send_photo : chat_id:int -> photo:string -> ?caption:string option -> ?disable_notification:bool -> reply_to:int option -> reply_markup:ReplyMarkup.reply_markup option -> string Result.result Lwt.t

  (** Send an existing image file (jpeg/png) to a specified chat. Note that [photo] refers to the file's id on the Telegram servers. *)
  val resend_photo : chat_id:int -> photo:string -> ?caption:string option -> ?disable_notification:bool -> reply_to:int option -> reply_markup:ReplyMarkup.reply_markup option -> unit Result.result Lwt.t

 (** Send a new audio file (mp3) to a specified chat. Note that [audio] refers to the file's name to send. *)
  val send_audio : chat_id:int -> audio:string -> performer:string -> title:string -> ?disable_notification:bool -> reply_to:int option -> reply_markup:ReplyMarkup.reply_markup option -> string Result.result Lwt.t

  (** Send an existing audio file (mp3) to a specified chat. Note that [audio] refers to the file's id on the Telegram servers. *)
  val resend_audio : chat_id:int -> audio:string -> performer:string -> title:string -> ?disable_notification:bool -> reply_to:int option -> reply_markup:ReplyMarkup.reply_markup option -> unit Result.result Lwt.t

  (** Send a new document file to a specified chat. Note that [document] refers to the file's name to send. *)
  val send_document : chat_id:int -> document:string -> ?disable_notification:bool -> reply_to:int option -> reply_markup:ReplyMarkup.reply_markup option -> string Result.result Lwt.t

  (** Send an existing document file to a specified chat. Note that [document] refers to the file's id on the Telegram servers. *)
  val resend_document : chat_id:int -> document:string -> ?disable_notification:bool -> reply_to:int option -> reply_markup:ReplyMarkup.reply_markup option -> unit Result.result Lwt.t

  (** Send a new sticker file (webp) to a specified chat. Note that [sticker] refers to the file's name to send. *)
  val send_sticker : chat_id:int -> sticker:string -> ?disable_notification:bool -> reply_to:int option -> reply_markup:ReplyMarkup.reply_markup option -> string Result.result Lwt.t

  (** Send an existing sticker file (webp) to a specified chat. Note that [sticker] refers to the file's id on the Telegram servers. *)
  val resend_sticker : chat_id:int -> sticker:string -> ?disable_notification:bool -> reply_to:int option -> reply_markup:ReplyMarkup.reply_markup option -> unit Result.result Lwt.t

  (** Send a new video file (mp4/mov/webm) to a specified chat. Note that [video] refers to the file's name to send. *)
  val send_video : chat_id:int -> video:string -> ?duration:int option -> ?caption:string option -> ?disable_notification:bool -> reply_to:int option -> reply_markup:ReplyMarkup.reply_markup option -> string Result.result Lwt.t

  (** Send an existing video (mp4/mov/webm) file to a specified chat. Note that [video] refers to the file's id on the Telegram servers. *)
  val resend_video : chat_id:int -> video:string -> ?duration:int option -> ?caption:string option -> ?disable_notification:bool -> reply_to:int option -> reply_markup:ReplyMarkup.reply_markup option -> unit Result.result Lwt.t

  (** Send a new voice message (ogg) to a specified chat. Note that [voice] refers to the file's name to send. *)
  val send_voice : chat_id:int -> voice:string -> ?disable_notification:bool -> reply_to:int option -> reply_markup:ReplyMarkup.reply_markup option -> string Result.result Lwt.t

  (** Send an existing voice message (ogg) to a specified chat. Note that [voice] refers to the file's id on the Telegram servers. *)
  val resend_voice : chat_id:int -> voice:string -> ?disable_notification:bool -> reply_to:int option -> reply_markup:ReplyMarkup.reply_markup option -> unit Result.result Lwt.t

  (** Send a location to a specified chat *)
  val send_location : chat_id:int -> latitude:float -> longitude:float -> ?disable_notification:bool -> reply_to:int option -> reply_markup:ReplyMarkup.reply_markup option -> unit Result.result Lwt.t

  (** Send a venue to a specified chat *)
  val send_venue : chat_id:int -> latitude:float -> longitude:float -> title:string -> address:string -> foursquare_id:string option -> ?disable_notification:bool -> reply_to:int option -> reply_markup:ReplyMarkup.reply_markup option -> unit Result.result Lwt.t

  (** Send a contact to a specified chat *)
  val send_contact : chat_id:int -> phone_number:string -> first_name:string -> last_name:string option -> ?disable_notification:bool -> reply_to:int option -> reply_markup:ReplyMarkup.reply_markup option -> unit Result.result Lwt.t

  (** Get a given user's profile pictures *)
  val get_user_profile_photos : user_id:int -> offset:int option -> limit:int option -> UserProfilePhotos.user_profile_photos Result.result Lwt.t

  (** Get the information for a file that's been uploaded to Telegram's servers by the [file_id] *)
  val get_file : file_id:string -> File.file Result.result Lwt.t

  (** Download a file that's been uploaded to Telegram's servers by the [file_id] *)
  val get_file' : file_id:string -> string option Lwt.t

  (** Download a file that's been uploaded to Telegram's servers by the [file] *)
  val download_file : file:File.file -> string option Lwt.t

  (** Kick/ban a given user from the given chat *)
  val kick_chat_member : chat_id:int -> user_id:int -> unit Result.result Lwt.t

  (** Leave a chat manually to stop receiving messages from it *)
  val leave_chat : chat_id:int -> unit Result.result Lwt.t

  (** Unban a given user from the given chat *)
  val unban_chat_member : chat_id:int -> user_id:int -> unit Result.result Lwt.t

  (** Get the info for a given chat *)
  val get_chat : chat_id:int -> Chat.chat Result.result Lwt.t

  (** Get the list of admins for a given chat *)
  val get_chat_administrators : chat_id:int -> ChatMember.chat_member list Result.result Lwt.t

  (** Get the number of members in a given chat *)
  val get_chat_members_count : chat_id:int -> int Result.result Lwt.t

  (** Get information about a certain member in the given chat *)
  val get_chat_member : chat_id:int -> user_id:int -> ChatMember.chat_member Result.result Lwt.t

  (** Answer a callback query sent from an inline keyboard *)
  val answer_callback_query : callback_query_id:string -> ?text:string option -> ?show_alert:bool -> unit -> unit Result.result Lwt.t

  (** Answers between 1 to 50 inline queries *)
  val answer_inline_query : inline_query_id:string -> results:InlineQuery.Out.inline_query_result list -> ?cache_time:int option -> ?is_personal:bool option -> ?next_offset:string option -> unit -> unit Result.result Lwt.t

  (** Edit an existing message, selected by either the chat id, the message id, or the inline message id *)
  val edit_message_text : ?chat_id:string option -> ?message_id:int option -> ?inline_message_id:string option -> text:string -> parse_mode:ParseMode.parse_mode option -> disable_web_page_preview:bool -> reply_markup:ReplyMarkup.reply_markup option -> unit -> unit Result.result Lwt.t

  (** Edit the caption of an existing message, selected by either the chat id, the message id, or the inline message id *)
  val edit_message_caption : ?chat_id:string option -> ?message_id:int option -> ?inline_message_id:string option -> caption:string -> reply_markup:ReplyMarkup.reply_markup option -> unit -> unit Result.result Lwt.t

  (** Edit the reply markup of an existing message, selected by either the chat id, the message id, or the inline message id. Use [None] to remove the reply markup *)
  val edit_message_reply_markup : ?chat_id:string option -> ?message_id:int option -> ?inline_message_id:string option -> reply_markup:ReplyMarkup.reply_markup option -> unit -> unit Result.result Lwt.t

  (** Get a list of all available updates that the bot has received *)
  val get_updates : Update.update list Result.result Lwt.t

  (** Get the first available update from the update queue *)
  val peek_update : Update.update Result.result Lwt.t

  (** Get the first available update from the update queue and mark it as read (deletes the update) *)
  val pop_update : ?run_cmds:bool -> unit -> Update.update Result.result Lwt.t

  (** Run the bot with a default main loop, optionally logging the output to stdout *)
  val run : ?log:bool -> unit -> unit
end

(** Generate a bot's interface to allow for direct calls to functions *)
module Mk : functor (B : BOT) -> TELEGRAM_BOT
