-module(ss_network).

-export([

    listen_on/3,
    start/0,
    stop/1,

%%%%%%%%%%%%%%%%%%%%
%%%%% internal %%%%%
%%%%%%%%%%%%%%%%%%%%
    handle_player/2,
    internal_listen_on/2,
    internal_listen_loop/1

]).

internal_listen_on(TheIP, ThePort) ->
    io:format("listening on socket: ~p~n", [ThePort]),
    { ok, ListeningSocket } = gen_tcp:listen(ThePort,
        [ binary, {active, false }, {reuseaddr, true}, {packet,0 } ] ),% {ip, TheIP}]),
    ListeningSocket
.

fn (ListeningSocket) ->
    io:format("listen socket: ~p~n", [ListeningSocket]),
    RetVal = gen_tcp:accept(ListeningSocket),
    case RetVal of
        {ok, ServerSocket } ->
            ServerSocket;
        {error, Reason} ->
            io:format("Can't Listen cause Reason = ~p~n", [Reason]),
            not_ok
end
.

internal_listen_loop(ListeningSocket) ->
    %{ ok, ServerSocket } = gen_tcp:accept(ListeningSocket),
    ServerSocket = fn (ListeningSocket),
    io:format("    + accepted socket at ~w~n", [ServerSocket]),
    spawn(fun() -> internal_listen_loop(ServerSocket ) end),
    spawn( fun() -> handle_player(ListeningSocket, [] ) end)
.
    %spawn(fun() -> handle_player(ServerSocket, [] ) end),
    %internal_listen_loop(ListeningSocket).

handle_player( Socket, PlayerPid ) ->
    inet:setopts(Socket, [{active,once}]),
    io:format("Call handle_player~n"),
    receive
        {tcp, Socket, Msg } ->
            io:format("Server received : ~p~n", [Msg]),
            gen_tcp:send(Socket, Msg ),
            handle_player(Socket, PlayerPid);
        {tcp, Socket, <<"join", _/binary>> } ->
            Pid = handle_new_server(Socket),
            handle_player( Socket, Pid );
        {tcp, Socket, <<"quit", _/binary >>} ->
            io:format("Closed socket"),
            gen_tcp:close(Socket)
    end.
        %{tcp, Socket, "join" } ->
            %Pid = handle_new_server(Socket),
            %handle_player( Socket, Pid );

        %%{tcp, Socket, <<"info", _/binary >>} ->
        %{tcp, Socket, "info" } ->
            %gen_tcp:send(Socket,  ss_player:get_info(PlayerPid));

       %{tcp, Socket, <<"part", _/binary >>} ->
            %gen_tcp:close(Socket)
            %.

handle_new_server(ServerSocket) ->

    PlayerPid = ss_player:create(ServerSocket),
    MatchMakerPID = get(matchmaker),
    ss_matchmaker:add_player(MatchMakerPID, PlayerPid).

spawn_listen_process(IP, Port) ->
    spawn(fun() -> internal_listen_loop(internal_listen_on(IP, Port)) end).

network_core_loop() ->

    receive

        { listen, IP, Port } ->
            spawn_listen_process(IP, Port),
            network_core_loop();

        terminate ->
            io:format("Network core loop exiting~n"),
            %gen_tcp:close(Socket),
            ok
    end.

listen_on(ServerPid, IP, Port) ->

    io:format("  ! Beginning network listen on ~w ~w to ~w~n", [IP,Port,ServerPid]),
    ServerPid ! { listen, IP, Port },
    ok.

start() ->

    io:format("  + ss_network starting~n"),
    spawn(fun() -> network_core_loop() end).

stop(WhichServer) ->

    WhichServer ! terminate,
    ok.

