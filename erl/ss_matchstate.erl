
-module(ss_matchstate).





-export([

    create/2

]).





core_loop() ->

    receive
    
        { create, P1, P2 } ->


        terminate ->
            ok
    
    end.

