//Taken from somwhere

//Runs only once, and only on the server
if !(isServer) exitWith {};

//Intialization. All units will be spawned. The spawnpoints will cycle if shorter then number of units.
_spawnPoints = ["marker_0"];
_unitGroups;


//
_spawnPointsLength = count _spawnPoints;

//Add for loop at some point

_unksSpawnPosition = getMarkerPos _spawnPoints select 0






