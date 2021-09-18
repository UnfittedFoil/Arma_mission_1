
/*
 * Author: UnfittedFoil
 * Description: Allows enemies to begin spawning upon a trigger being activated.
 *
 *
*/
//Runs only once, and only on the server
if !(isServer) exitWith {};
systemChat "Trigger Activated"; //DEBUG. Allows for the confirmation of the activation of the trigger


//Parameters. All units will be spawned. The spawnpoints will cycle if shorter then number of units.
_spawnPoints = ["spawn_marker_0"];
_spawnableSquadLeads= ["I_C_Soldier_Bandit_6_F", 1]
_spawnableUnits = [
					"I_C_Soldier_Bandit_4_F", .50,	//Rifleman
					"I_C_Soldier_Bandit_7_F", .50	//Rifleman
					];


//Derived parameteres
_spawnPointsLength = count _spawnPoints;


//INPROGRESS: Creates groups of enemies at designated spawn points
//CURRENT: Spawns a single unit in a new group.
//TODO: Spawn a small group

_group = createGroup [independent, true];

_marker = _spawnPoints select 0;
_unit = _spawnableUnits select 0;
_enemy = _group createUnit [_unit, getMarkerPos _marker, [], 5, "NONE"];





