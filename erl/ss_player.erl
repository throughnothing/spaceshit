
-module(ss_player).





-export([

    create/1,
    add_opponent/2

]).






player_core_loop(Socket) ->

    receive

        { add_opponent, P } ->
            put(opponent, P);

        { get_opponent, P } ->
            get(opponent);

        { tcp, _Socket, Data } ->
            handle_data(Data),
            player_core_loop(_Socket);
    
        terminate ->

            ServerSocket = socket,
            gen_tcp:send(ServerSocket, ss_packet:goodbye()),
            gen_tcp:close(ServerSocket),
            ok
    
    end.

handle_data(Data) ->
    
    io:format("~n~w~n", [Data]),
    
    todo.



add_opponent(Pid, P) ->
  io:format("My opponent is: ~w~n", [ P ]),
  Pid ! { add_opponent, P},
  ok.


start_player_loop(Socket) ->

    player_core_loop(Socket).


create(MatchMakerPID) ->
    ss_matchmaker:add_player(MatchMakerPID, self()),

    spawn(fun() -> start_player_loop(fromSocket) end).

