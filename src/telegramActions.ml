open TelegramApi.Command

(* TODO: These names suck, we need something more descriptive *)
let (@/>) c1 c2 = Chain (c1, c2)
let (@/<) c1 c2 = c1 ~and_then:c2

let nothing = Nothing

let get_me ~and_then = GetMe and_then

let send_message ~chat_id text ?(disable_notifications=false) ?reply_to ?reply_markup =
  Printf.ksprintf
    (fun s ->
       SendMessage (chat_id, s, disable_notifications, reply_to, reply_markup)) text

(* TODO: Should message_id be a named argument? *)
let forward_message ~chat_id ~from_chat_id ?(disable_notifications=false) ~message_id =
  ForwardMessage (chat_id, from_chat_id, disable_notifications, message_id)
