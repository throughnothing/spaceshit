
-module(ss_matchmaker).

-export([
    matchmaker_core_loop/1,

    add_player/2,
    remove_player/2,
    stop/1
]).

      

matchmaker_core_loop(Options) ->

  receive

    {add_player, P} ->
      GetP = get(player),
      io:format("Added Player ~w~n", [ P ]),
      if
        GetP == undefined -> put(player, P);
        true -> match(GetP, P),
            erase(player)
      end,
      matchmaker_core_loop(Options);

    {remove_player, P} ->
      erase(player),
      matchmaker_core_loop(Options);

    { PID, match, P1, P2 } ->
      matchmaker_core_loop(Options);

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

remove_player(Pid, P) ->
  Pid ! { remove_player, P },
  ok.

stop(WhichMatch) ->

  WhichMatch ! terminate,
  ok.
