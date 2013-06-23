
-module(ss_player).





-export([

    create/1

]).





player_core_loop(Socket) ->

    receive
        
      { add_opponent, P } ->
          put(opponent, P).
    
        terminate ->
            ok
    
    end.



add_opponent(Pid, P) ->
  io:format("My opponent is: ~w~n", [ P ]),
  Pid ! { add_opponent, P},
  ok.


create(FromSocket) ->
    ss_matchmaker:add_player(MatchMakerPID, self()),

    spawn(fun() -> player_loop(FromSocket) end).
