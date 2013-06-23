
-module(ss_timer).





-export([

    start/1,
    stop/0

]).





timer_loop(TickAction) ->

    receive 
        act ->
            TickAction(),
            timer_loop(TickAction);
            
        terminate ->
            ok
    end.





core_loop(TickLength, TimerPid) ->

    receive 
        terminate ->
            TimerPid ! terminate,
            ok
    after 
        TickLength ->
            TickAction(),
            timer_loop()
    end.





start(TickLength, TickAction) ->

    spawn(fun() -> core_loop(TickLength, spawn(fun() -> timer_loop(TickAction) end)) end).

