
-module(ss_player).





-export([

    create/1

]).





player_loop(Socket) ->

    receive
    
        terminate ->
            ok
    
    end.





create(FromSocket) ->

    spawn(fun() -> player_loop(FromSocket) end).
