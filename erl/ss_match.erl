
-module(ss_match).





-export([

    create/2,
    join/2,
    get_info/1

]).



match_core_loop() ->

  receive

    { join, Spectator } ->
      put(spectator, Spectator);


    get_info ->
      P1 = get(player1),
      P2 = get(player2),
      [ { player1, P1 },
        { player2, P2 } ]

  end.



join(Pid, Spectator) ->
  Pid ! { join, Spectator },
  ok.


get_info(Pid) ->
  Pid ! get_info,
  ok.



match_core_loop() ->

  receive

  end.




start_match_core_loop(P1, P2) ->
  put(player1, P1),
  put(player2, P2),
  match_core_loop().

create(P1, P2) ->
  start_match_core_loop(P1, P2).
