
-module(ss_packet).





-export([

    parse/1,

    join_stall/0,
    position_frame/5

]).





join_stall() ->

    <<253>>.





position_frame(ObjType, ObjNum, X, Y, R) ->

    <<4, ObjType:8, ObjNum:8, X:32/float, Y:32/float, R:32/float>>.





parse(<<0,0>>) ->

    { join, as_player };

parse(<<0,1>>) ->

    { join, as_observer };





parse(<<1>>) ->

    part;





parse(<<2, SignedToSpeed:8/signed-integer>>) ->

    { set_speed, SignedToSpeed };





parse(<<3, RelativeAngleInRadians:32/float>>) ->

    { turn, RelativeAngleInRadians };





parse(<<4>>) ->

    fire.

