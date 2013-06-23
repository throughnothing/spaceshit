-module(ss_physics).

%magnitude & location angle in radians
-record( vector, { x,y, speed, angle } ).

-export([
    produce_frame/1,
    move_object/1,
    detect_collisions/2
]).

detect_collisions(Obj1, Obj2) ->
    %Obj1 & %Obj2 are vectors
    false.

% TODO: don't do this here, let each object calculate themselves,
% and bullets should probably 'target'?
move_object(Obj) ->

    NewX = Obj#vector.x + (Obj#vector.speed * math:sin(Obj#vector.angle)),
    NewX = Obj#vector.x + (Obj#vector.speed * math:cos(Obj#vector.angle))
.

produce_frame(OldFrame) ->

    % todo physics here, then return new frame

    OldFrame.  % until replaced, universe is static
