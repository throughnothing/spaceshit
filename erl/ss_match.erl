
-module(ss_match).





-export([

    create/1

]).





start_match_core_loop(P1, P2) ->
  put(player1) = P1,
  put(player2) = P2,
  match_core_loop().


