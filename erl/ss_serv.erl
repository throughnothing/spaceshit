-module(ss_serv).

-export([
    default_options/0,
    init_server_core_loop/1,
    start/0,
    start/1,
    stop/0,
    stop/1

]).

default_options() ->

    [ { auto_listen, true             },
      { port,        8008             },
      { ip,          {0,0,0,0}        },
      %{ ip,          {10,1,175,209}        },
      { name,        "Default server" } ].

init_server_core_loop(Options) ->

    io:format("- initting server core loop~n"),

    ss_network:start(),
    MatchMakerPid = ss_matchmaker:start(),
    %ss_timer:start(),

    Auto = proplists:get_value(auto_listen, Options),
    put(network, proplists:get_value(net, Options)),
    put(matchmaker, MatchMakerPid),
    case Auto of

        true ->
            self() ! {listen, proplists:get_value(ip, Options), proplists:get_value(port, Options)};

        false ->
            ok

    end,

    io:format("  - server core loop beginning~n"),

    server_core_loop().

server_core_loop() ->

    receive

        { listen, IP, Port } ->
            Net = get(network),
            io:format("    - server core loop issuing a listen on ~w~n", [Net]),
            ss_network:listen_on(Net,IP,Port),
            server_core_loop();

        terminate ->
            io:format("stopping server!"),
            ok

    end.

start() ->
    start([]).

start(Options) ->

    FinalOpts = ss_util:merge_settings(Options, default_options()),
    io:format("Starting with options~n  ~p~n", [FinalOpts]),

    Net = ss_network:start(),
    io:format("  - Net is ~w~n", [Net]),

    Pid = spawn(fun() -> init_server_core_loop(FinalOpts ++ [{net, Net}]) end),
    put(server, Pid)
.

stop() ->
    stop(get(server)).

stop(WhichServer) ->

    io:format("Stopping server.~n"),

    WhichServer ! terminate.

