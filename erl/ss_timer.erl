
-module(ss_timer).


-export([

    start/2,
    stop/0
    timer_loop/1,
    core_loop/2
]).


stop() ->
    ok.

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
            TimerPid()
    end.


start(TickLength, TickAction) ->

    spawn(fun() -> core_loop(TickLength, spawn(fun() -> timer_loop(TickAction) end)) end).

