
-module(ss_player).





-export([

    create/1

]).





handle_data(Data) ->
    
    io:format("~n~w~n", [Data]),
    
    todo.





player_loop(Socket) ->

    receive

        { tcp, _Socket, Data } ->
            handle_data(Data),
            player_loop(Socket);
    
        terminate ->

            gen_tcp:send(ServerSocket, ss_packet:goodbye()),
            gen_tcp:close(ServerSocket).
            ok
    
    end.





start_player_loop(Socket) ->

    player_loop(Socket).





create(FromSocket) ->

    spawn(fun() -> start_player_loop(FromSocket) end).

