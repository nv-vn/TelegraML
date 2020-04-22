exception ApiException of string

let rec get_field target = function
  | `Assoc [] -> raise (ApiException "Could not read JSON field!")
  | `Assoc (x::_) when fst x = target -> snd x
  | `Assoc (_::xs) -> get_field target (`Assoc xs)
  | _ -> raise (ApiException "Invalid field access!")

let rec get_opt_field target = function
  | `Assoc [] -> None
  | `Assoc (x::_) when fst x = target -> Some (snd x)
  | `Assoc (_::xs) -> get_opt_field target (`Assoc xs)
  | _ -> raise (ApiException "Invalid field access!")

let (>>=) x f = match x with
  | Some x -> f x
  | None -> None

let (>>>=) v (x,f) = match v,x with
  | None, Some x -> Some (f x)
  | _ -> v

let (<$>) f x = match x with
  | Some x -> Some (f x)
  | None -> None

let the_string = function
  | `String string -> string
  | _ -> raise (ApiException "Type assertion failed!")

let this_string x = `String x

let the_int = function
  | `Int int -> int
  | _ -> raise (ApiException "Type assertion failed!")

let this_int x = `Int x

let the_bool = function
  | `Bool bool -> bool
  | _ -> raise (ApiException "Type assertion failed!")

let this_bool x = `Bool x

let the_float = function
  | `Float float -> float
  | _ -> raise (ApiException "Type assertion failed!")

let this_float x = `Float x

let the_list = function
  | `List list -> list
  | _ -> raise (ApiException "Type assertion failed!")

let this_list xs = `List xs

let the_assoc = function
  | `Assoc assoc -> assoc
  | _ -> raise (ApiException "Type assertion failed!")

let this_assoc x = `Assoc x

let (+?) xs = function
  | (_, None) -> xs
  | (name, Some y) -> xs @ [name, y]

module Result = struct
  type 'a result = Success of 'a | Failure of string

  let return x = Success x

  let default x = function
    | Success x -> x
    | Failure _ -> x

  let (>>=) x f = match x with
    | Success x -> f x
    | Failure err -> Failure err

  let (<$>) f = function
    | Success x -> Success (f x)
    | Failure err -> Failure err
end

let hd_ = function
  | [] -> Result.Failure "Could not get head"
  | x::_ -> Result.Success x
