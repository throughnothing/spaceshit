
-module(ss_player).





-export([

    create/1,
    get_info/1,
    default_info/0,
    add_opponent/2

]).



default_info() ->

    [ { x, 0 },
      { y, 0 }, 
      { rotation, 0 } ].


player_core_loop(Socket) ->

    receive

        get_info ->
          X = get(x),
          Y = get(y),
          Rotation = get(rotation),
          io:format("x: ~w, y: ~w, rotation: ~w~n", [X, Y, Rotation]),
          [ { x, X },
            { y, Y },
            { rotation, Rotation } ];

        { add_opponent, P } ->
            put(opponent, P);

        { get_opponent } ->
            get(opponent);

        { tcp, _Socket, Data } ->
            handle_data(Data),
            player_core_loop(_Socket);
    
        terminate ->
            gen_tcp:send(Socket, ss_packet:goodbye()),
            gen_tcp:close(Socket),
            ok
    
    end.

handle_data(Data) ->
    
    io:format("~n~w~n", [Data]),
    
    todo.

get_info(Pid) ->
  Pid ! get_info,
  ok.

add_opponent(Pid, P) ->
  io:format("My opponent is: ~w~n", [ P ]),
  Pid ! { add_opponent, P},
  ok.


start_player_loop(Socket) ->
    
    put(x, 0),
    put(y, 0),
    put(speed, 0),
    put(rotation, 0),
    player_core_loop(Socket).


create(FromSocket) ->
    spawn(fun() -> start_player_loop(FromSocket) end).


