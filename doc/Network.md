Network protocol
================

After connecting to the server on port 9000, the client sends a JOIN command
indicating whether it is a player or spectator. The server automatically matches
up the clients with a game and begins sending INFO commands when the game starts.

Packets
-------

integer, float and string mean the obvious things. All values are encoded using
little-endian and all angles are given in radians.

|Command|Sent by|Format|
|-------|:-----:|-----:|
|INFO|Server|`{'cmd':'info','type':string,'id':integer,'x':float,'y':float,'z':float,'angle':float}`|
|DELETE|Server|`{'cmd':'delete','type':string,'id':integer}`|
|JOIN|Client|`{'cmd':'join','type':string}`|
|PART|Client|`{'cmd':'part'}`|
|THRUST|Client|`{'cmd':'thrust'}`|
|TURN|Client|`{'cmd':'turn','dir':string}`|
|FIRE|Client|`{'cmd':'fire'}`|
