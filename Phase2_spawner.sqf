//Runs only once, and only on the server
if !(isServer) exitWith {};

systemChat "Trigger Activated";
//Parameters. All units will be spawned. The spawnpoints will cycle if shorter then number of units.
_spawnPoints = ["spawn_marker_0"];
_spawnableUnits = ["I_C_Soldier_Bandit_4_F"];


//
_spawnPointsLength = count _spawnPoints;

//Add for loop at some point

_group = createGroup [independent, true];

_marker = _spawnPoints select 0;
_unit = _spawnableUnits select 0;
_enemy = _group createUnit [_unit, getMarkerPos _marker, [], 5, "NONE"];





