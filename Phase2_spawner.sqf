
/*
 * Author: UnfittedFoil
 * Description: Allows enemies to begin spawning upon a trigger being activated.
 *
 *
*/

if !(isServer) exitWith {};		//Runs only once, and only on the server
systemChat "Trigger Activated 2"; 	//DEBUG. Allows for the confirmation of the activation of the trigger


//Parameters. All units will be spawned. The spawnpoints will cycle if shorter then number of units.
_spawnPoints = ["spawn_marker_0"];
_spawnableSquadLeads= ["I_C_Soldier_Bandit_6_F", 1];
_spawnableUnits = [
					"I_C_Soldier_Bandit_4_F", .50,	//Rifleman
					"I_C_Soldier_Bandit_7_F", .50	//Rifleman
					];
_totalUnits = 4;


//Derived parameteres
_spawnPointsLength = count _spawnPoints;


//INPROGRESS: Creates groups of enemies at designated spawn points
//CURRENT: Spawn a small group
//TODO: Edit clothes and weapons to add variety to hostiles

_group = createGroup [independent, true];

_marker = _spawnPoints select 0;
_enemy = _group createUnit [selectRandomWeighted _spawnableSquadLeads, getMarkerPos _marker, [], 5, "NONE"];
for "_i" from 2 to _totalUnits do{
	_enemy = _group createUnit [selectRandomWeighted _spawnableUnits, getMarkerPos _marker, [], 5, "NONE"];
};





