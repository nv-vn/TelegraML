open TelegramApi.Command

(* Action combinators *)

(** Chains two commands together (do one, then the other) *)
let (/+) c1 c2 = Chain (c1, c2)

(** Pipes one command into the next (do one, and use its result) *)
let (/>) c1 f = c1 ~and_then:f

(** Finish a sequence of commands using [(/>)] *)
let finish = fun _ -> Nothing

(** Sequence a list of commands in the provided order *)
let sequence cmds =
  List.fold_right (/+) cmds Nothing
(** Examples:
    - [command /> fun _ -> command2 /> finish]
    - [command /+ command2]
    - [sequence [
        command;
        command2
      ]] *)

(* Normal actions *)

let nothing = Nothing

let get_me ~and_then = GetMe and_then

let send_message ~chat_id ?(disable_notification=false) ?reply_to ?reply_markup =
  Printf.ksprintf
    (fun s ->
       SendMessage (chat_id, s, disable_notification, reply_to, reply_markup))

let forward_message ~chat_id ~from_chat_id ?(disable_notification=false) ~message_id =
  ForwardMessage (chat_id, from_chat_id, disable_notification, message_id)

let send_chat_action ~chat_id action =
  SendChatAction (chat_id, action)

let send_photo ~chat_id ?caption ?(disable_notification=false) ?reply_to ?reply_markup photo ~and_then =
  SendPhoto (chat_id, photo, caption, disable_notification, reply_to, reply_markup, and_then)

let resend_photo ~chat_id ?caption ?(disable_notification=false) ?reply_to ?reply_markup photo =
  ResendPhoto (chat_id, photo, caption, disable_notification, reply_to, reply_markup)

let send_audio ~chat_id ~performer ~title ?(disable_notification=false) ?reply_to ?reply_markup audio ~and_then =
  SendAudio (chat_id, audio, performer, title, disable_notification, reply_to, reply_markup, and_then)

let resend_audio ~chat_id ~performer ~title ?(disable_notification=false) ?reply_to ?reply_markup audio =
  ResendAudio (chat_id, audio, performer, title, disable_notification, reply_to, reply_markup)

let send_document ~chat_id ?(disable_notification=false) ?reply_to ?reply_markup document ~and_then =
  SendDocument (chat_id, document, disable_notification, reply_to, reply_markup, and_then)

let resend_document ~chat_id ?(disable_notification=false) ?reply_to ?reply_markup document =
  ResendDocument (chat_id, document, disable_notification, reply_to, reply_markup)

let send_sticker ~chat_id ?(disable_notification=false) ?reply_to ?reply_markup sticker ~and_then =
  SendSticker (chat_id, sticker, disable_notification, reply_to, reply_markup, and_then)

let resend_sticker ~chat_id ?(disable_notification=false) ?reply_to ?reply_markup sticker =
  ResendSticker (chat_id, sticker, disable_notification, reply_to, reply_markup)

let send_video ~chat_id ?duration ?caption ?(disable_notification=false) ?reply_to ?reply_markup video ~and_then =
  SendVideo (chat_id, video, duration, caption, disable_notification, reply_to, reply_markup, and_then)

let resend_video ~chat_id ?duration ?caption ?(disable_notification=false) ?reply_to ?reply_markup video =
  ResendVideo (chat_id, video, duration, caption, disable_notification, reply_to, reply_markup)

let send_voice ~chat_id ?(disable_notification=false) ?reply_to ?reply_markup voice ~and_then =
  SendVoice (chat_id, voice, disable_notification, reply_to, reply_markup, and_then)

let resend_voice ~chat_id ?(disable_notification=false) ?reply_to ?reply_markup voice =
  ResendVoice (chat_id, voice, disable_notification, reply_to, reply_markup)

let send_location ~chat_id ?(disable_notification=false) ?reply_to ?reply_markup ~latitude ~longitude =
  SendLocation (chat_id, latitude, longitude, disable_notification, reply_to, reply_markup)

let send_venue ~chat_id ?(disable_notification=false) ?reply_to ?reply_markup ~latitude ~longitude ~title ~address ~foursquare_id =
  SendVenue (chat_id, latitude, longitude, title, address, foursquare_id, disable_notification, reply_to, reply_markup)

let send_contact ~chat_id ?(disable_notification=false) ?reply_to ?reply_markup ~phone_number ~first_name ~last_name =
  SendContact (chat_id, phone_number, first_name, last_name, disable_notification, reply_to, reply_markup)

let get_user_profile_photos ?offset ?limit user_id ~and_then =
  GetUserProfilePhotos (user_id, offset, limit, and_then)

let get_file file_id ~and_then =
  GetFile (file_id, and_then)

let get_file' file_id ~and_then =
  GetFile' (file_id, and_then)

let download_file file ~and_then =
  DownloadFile (file, and_then)

let kick_chat_member ~chat_id ~user_id =
  KickChatMember (chat_id, user_id)

let leave_chat ~chat_id =
  LeaveChat chat_id

let unban_chat_member ~chat_id ~user_id =
  UnbanChatMember (chat_id, user_id)

let get_chat ~chat_id ~and_then =
  GetChat (chat_id, and_then)

let get_chat_administrators ~chat_id ~and_then =
  GetChatAdministrators (chat_id, and_then)

let get_chat_members_count ~chat_id ~and_then =
  GetChatMembersCount (chat_id, and_then)

let get_chat_member ~chat_id ~user_id ~and_then =
  GetChatMember (chat_id, user_id, and_then)

let answer_callback_query ?text ?(show_alert=false) id =
  AnswerCallbackQuery (id, text, show_alert)

let answer_inline_query ?cache_time ?is_personal ?next_offset id results =
  AnswerInlineQuery (id, results, cache_time, is_personal, next_offset)

let edit_message_text ~id ?parse_mode ?(disable_web_page_preview=false) ?reply_markup =
  Printf.ksprintf (fun s ->
      EditMessageText (id, s, parse_mode, disable_web_page_preview, reply_markup))

let edit_message_caption ~id ?reply_markup =
  Printf.ksprintf (fun s ->
      EditMessageCaption (id, s, reply_markup))

let edit_message_reply_markup ~id ~reply_markup =
  EditMessageReplyMarkup (id, Some reply_markup)

let get_updates ~and_then =
  GetUpdates and_then

let peek_update ~and_then =
  PeekUpdate and_then

(* TODO: Add run_commands option *)
let pop_update ~and_then =
  PopUpdate and_then
