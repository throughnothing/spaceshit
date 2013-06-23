
-module(ss_serv).





-export([

    init_server_core_loop/1,

    start/0,
      start/1,
      
    stop/1

]).





default_options() ->

    [ { auto_listen, false            },
      { port,        8008             }, 
      { ip,          {0,0,0,0}        },
      { name,        "Default server" } ].





init_server_core_loop(Options) ->

    Auto = proplists:get_value(auto_listen, Options),
    
    if 
        (Auto == true) -> 
            IP   = proplists:get_value(ip, Options),
            Port = proplists:get_value(ip, Options),
            self() ! {listen,IP,Port} 
    end,

    server_core_loop().





server_core_loop() ->

    receive
    
        { listen, IP, Port } ->
            ss_network:listen_on(self(),IP,Port),
            server_core_loop();
    
        terminate ->
            ok
    
    end.





start() ->

    start(default_options()).





start(Options) -> 

    spawn(fun() -> init_server_core_loop(Options) end).





stop(WhichServer) ->

    WhichServer ! terminate,
    ok.

