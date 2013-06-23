
-module(ss_network).





-export([

    listen_on/3,

    start/0,
    stop/1,

%%%%%%%%%%%%%%%%%%%%
%%%%% internal %%%%%
%%%%%%%%%%%%%%%%%%%%

    internal_listen_on/2,
    internal_listen_loop/1

]).





internal_listen_on(TheIP, ThePort) ->

    Options = [ {ip, TheIP} ],

    { ok, ListeningSocket } = gen_tcp:listen(ThePort, Options),
    ListeningSocket.





internal_listen_loop(ListeningSocket) ->

    { ok, ServerSocket } = gen_tcp:accept(ListeningSocket),
    io:format("    + accepted socket at ~w~n", [ServerSocket]),
    handle_new_server(ServerSocket),
    internal_listen_loop(ListeningSocket).





handle_new_server(ServerSocket) ->

    gen_tcp:send(ServerSocket, "\nHello there\n\n\n"),
    gen_tcp:close(ServerSocket).





spawn_listen_process(IP, Port) ->

    spawn(fun() -> internal_listen_loop(internal_listen_on(IP, Port)) end).





network_core_loop() ->

    receive
    
        { listen, IP, Port } -> 
            spawn_listen_process(IP, Port),
            network_core_loop();
    
        terminate ->
            io:format("Network core loop exiting~n"),
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

