Network protocol
================

After connecting to the server on port 9000, the client sends a JOIN command
indicating whether it is a player or spectator. The server automatically matches
up the clients with a game and begins sending INFO commands when the game starts.

Packets
-------

integer, float and string mean the obvious things. All values are encoded using
little-endian and all angles are given in radians.

|Command|Sent by|Format|Description|
|-------|-------|------|-----------|
|INFO|Server|`{'cmd':'info','type':string,'id':integer,'x':float,'y':float,'z':float,'angle':float}`|An object's state has been changed. `type` can be `spaceship` or `bullet`.|
|DELETE|Server|`{'cmd':'delete','type':string,'id':integer}`|An object has been deleted.|
|JOIN|Client|`{'cmd':'join','type':string}`|A client is joining. `type` can be `player` or `spectator`.|
|PART|Client|`{'cmd':'part'}`|A client is leaving.|
|THRUST|Client|`{'cmd':'thrust','dir':string}`|Set thruster state. `dir` can be `forward` or `off`.|
|TURN|Client|`{'cmd':'turn','dir':string}`|Set rotational state. `dir` can be `cw` or `ccw`.|
|FIRE|Client|`{'cmd':'fire'}`|Fire a bullet.|
