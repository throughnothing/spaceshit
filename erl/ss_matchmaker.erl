
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

match(_P1, _P2) ->
  matching.

add_player(Pid, P) ->
  Pid ! { add_player, P },
  ok.

remove_player(Pid, P) ->
  Pid ! { remove_player, P },
  ok.

stop(WhichMatch) ->

  WhichMatch ! terminate,
  ok.
