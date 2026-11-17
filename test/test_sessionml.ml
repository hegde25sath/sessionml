open Sessionml.Session_type

let gen_payload = QCheck.Gen.oneof_list [Int; Bool; String; Unit]

let rec gen_session n =
  let open QCheck.Gen in
  if n <= 0 then
    return End
  else
    let rest = gen_session (n - 1) in
    oneof_weighted [
      (1, return End);
      (2, map2
            (fun ty s -> Send (ty, s))
            gen_payload rest);
      (2, map2
            (fun ty s -> Recv (ty, s))
            gen_payload rest);
    ]

let arb_session =
  QCheck.make
    (QCheck.Gen.sized (fun n -> gen_session (min n 20)))

let test_duality =
  QCheck.Test.make
    ~name:"dual of dual is identity"
    ~count:500
    arb_session
    (fun s -> dual (dual s) = s)

let () =
  QCheck_runner.run_tests_main [test_duality]

