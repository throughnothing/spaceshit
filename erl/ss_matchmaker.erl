
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
      matchmaker_core_loop(Options);

    {remove_player, P} ->
      matchmaker_core_loop(Options);

    { PID, match, P1, P2 } ->
      io:format("hello~n"),
      nothing,
      matchmaker_core_loop(Options);

    terminate ->
      ok

  end.

add_player(Pid, P) ->
  GetP = get(player),
  io:format("dog~n"),
  if
    GetP == undefined -> put(player, P);
    true -> Pid ! { self(), match, GetP, P },
        erase(player)
  end,
  Pid ! { add_player, P },
  ok.

remove_player(Pid, P) ->
  erase(player),
  Pid ! { remove_player, P },
  ok.

stop(WhichMatch) ->

  WhichMatch ! terminate,
  ok.
