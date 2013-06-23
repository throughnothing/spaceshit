
-module(ss_match).





-export([

    create/1

]).





match_core_loop() ->

  receive

  end.




start_match_core_loop(P1, P2) ->
  put(player1) = P1,
  put(player2) = P2,
  match_core_loop().


