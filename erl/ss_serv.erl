
-module(ss_serv).





-export([

    default_options/0,

    listen_on/3,

    internal_listen_on/2,
    internal_listen_loop/1,

    start/0,
      start/1,
      
    stop/1

]).





default_options() ->

    [ { auto_listen, false            }
      { port,        8008             }, 
      { ip,          {0,0,0,0}        },
      { name,        "Default server" } ].





internal_listen_on(TheIP, ThePort) ->

    Options = [ {ip, TheIP} ],

    { ok, ListeningSocket } = gen_tcp:listen(ThePort, Options),
    ListeningSocket.





internal_listen_loop(ListeningSocket) ->

    { ok, ServerSocket } = gen_tcp:accept(ListeningSocket),
    handle_new_server(ServerSocket),
    internal_listen_loop(ListeningSocket).





handle_new_server(ServerSocket) ->

    gen_tcp:send(ServerSocket, "\nHello there\n\n\n"),
    gen_tcp:close(ServerSocket).





spawn_listen_process(IP, Port) ->

    spawn(fun() -> internal_listen_loop(internal_listen_on(IP, Port)) end).





server_core_loop(Options) ->

    receive
    
        { PID, listen, IP, Port } -> 
            spawn_listen_process(IP, Port),
            server_core_loop(Options);
    
        { PID, start_server } -> 
            % todo
            server_core_loop(Options);
    
        terminate ->
            ok
    
    end.





listen_on(Pid, IP, Port) ->

    Pid ! { self(), listen, IP, Port },
    ok.





start() ->

    start(default_options()).





start(Options) -> 

    spawn(fun() -> server_core_loop(Options) end).





stop(WhichServer) ->

    WhichServer ! terminate,
    ok.

