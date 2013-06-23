
-module(ss_matchmaker).

-export([

    matchmaker_core_loop/0,

    add_player/2,
    remove_player/1,
    start/0,
    stop/1
]).

      

matchmaker_core_loop() ->

  receive

    {add_player, P} ->
      GetP = get(player),
      io:format("Added Player ~w~n", [ P ]),
      if
        GetP == undefined -> put(player, P);
        true -> match(GetP, P),
            erase(player)
      end,
      matchmaker_core_loop();

    remove_player ->
      erase(player),
      matchmaker_core_loop();

    terminate ->
      ok

  end.

match(P1, P2) ->
  io:format("Matching ~w and ~w~n", [P1, P2]),
  ss_player:add_opponent(P1, P2),
  ss_player:add_opponent(P2, P1),
  ss_match:start_match_loop(P1, P2),
  ok.

add_player(Pid, P) ->
  io:format("Adding Player ~w ~n", [ P ]),
  Pid ! { add_player, P },
  ok.

remove_player(Pid) ->
  Pid ! remove_player,
  ok.

start() ->
  spawn(fun() -> matchmaker_core_loop() end).

stop(MatchmakerPid) ->
  MatchmakerPid ! terminate,
  ok.
