(* types of vals that can be sent over channels *)
type payload =
  | Int
  | Bool
  | String
  | Unit

(* finite binary session types *)
type t =
  | End
  | Send of payload * t
  | Recv of payload * t

(* protocol expected by other endpoint *)
let rec dual = function
  | End -> End
  | Send (ty, cont) -> Recv (ty, dual cont)
  | Recv (ty, cont) -> Send (ty, dual cont)
