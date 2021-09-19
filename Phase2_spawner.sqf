
/*
 * Author: UnfittedFoil
 * Description: Allows enemies for Phase 2 of a mission to begin spawning upon a trigger being activated.
 *
 *
*/

if !(isServer) exitWith {};		//Runs only once, and only on the server
systemChat "Trigger Activated"; 	//DEBUG. Allows for the confirmation of the activation of the trigger

////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * Functions
*/
////////////////////////////////////////////////////////////////////////////////////////////////////
/* Name: spawnGroup
 * Description: Creates groups of enemies at defined spawn points spawn points and sends groups towards players
 *
 * Variables used....
 *   _side: side the unit belogs to. Examples keywords, "EAST", "WEST", "Independent".
 *   _spawnableSquadLeads: Array of paired units and weights that will be the first(lead) unit spawned for a squad.
 *   _totalUnitsPerGroup: Total number of units a squad should posses
 *   _spawnableUnits: Array of paired units and weights that can be spawned in the squad
 *   _marker: Marker defining where to spawn the units
 *   _uniforms: Special for variation. Set of uniforms that units can be spawned with.
 *
 * Varibles set...
 *   _group(Returned): group that has been defined
 */
 
_spawnGroup = {
	//initialize basic group
	_group = createGroup [independent, true];
	private _enemy = _group createUnit [selectRandomWeighted _spawnableSquadLeads, getMarkerPos _marker, [], 5, "NONE"];
	if !(isNil "_uniforms") then{
		_enemy forceAddUniform selectRandomWeighted _uniforms; //##Changes uniform.
	};
	
	//Add units to group
	for "_i" from 2 to _totalUnitsPerGroup do{
		_enemy = _group createUnit [selectRandomWeighted _spawnableUnits, getMarkerPos _marker, [], 5, "NONE"];
		if !(isNil "_uniforms") then{
			_enemy forceAddUniform selectRandomWeighted _uniforms; //##Changes uniform.
		};
	};
	
	//Set AI Tasks
		//Set start tasks(Rush towards players)
	private _wp = _group addWaypoint [position player, 50];
	_wp setWaypointType "SAD";
		//Set final task (Search for players)
	_wp = _group addWaypoint [getMarkerPos _wp, 500];
	_wp setWayPointType "SCRIPTED";
	_wp setWaypointScript "\z\lambs\addons\wp\scripts\fnc_wpHunt.sqf";
	
	_group

};

////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * Wave 1
*/
////////////////////////////////////////////////////////////////////////////////////////////////////
//Parameters.
_spawnPoints = [
				"spawn_marker_1_0",
				"spawn_marker_1_1",
				"spawn_marker_1_2",
				"spawn_marker_1_3",
				"spawn_marker_1_4"
				];
_totalUnitsPerGroup = 4;	
_spawnableSquadLeads= ["I_C_Soldier_Bandit_6_F", 1];
_spawnableUnits = [
					"I_C_Soldier_Bandit_4_F", .50,	//Rifleman
					"I_C_Soldier_Bandit_7_F", .50	//Rifleman
					];
_uniforms = [
				"U_I_C_Soldier_Bandit_1_F", 1,
				"U_I_C_Soldier_Bandit_2_F", 1, 
				"U_I_C_Soldier_Bandit_3_F", 1, 
				"U_I_C_Soldier_Bandit_4_F", 1, 
				"U_I_C_Soldier_Bandit_5_F", 1, 
				"U_I_C_Soldier_Bandit_6_F", 1,
				"U_C_Man_Casual_1_F", 1, 
				"U_C_Man_Casual_2_F", 1, 
				"U_C_Man_Casual_3_F", 1, 
				"U_C_Man_Casual_4_F", 1, 
				"U_C_Man_Casual_5_F", 1, 
				"U_C_Man_Casual_6_F", 1, 
				"U_C_PoloShirt_blue_F", 1, 
				"U_C_PoloShirt_burgundy_F", 1, 
				"U_C_PoloShirt_redwhite_F", 1, 
				"U_C_PoloShirt_salmon_F", 1, 
				"U_C_PoloShirt_striped_F", 1, 
				"U_C_PoloShirt_tricolor_F", 1, 
				"U_C_E LooterJacket_1_F", 1, 
				"U_I_L_Uniform_01_tshirt_black_F", 1, 
				"U_I_L_Uniform_01_tshirt_olive_F", 1, 
				"U_I_L_Uniform_01_tshirt_skull_F", 1, 
				"U_I_L_Uniform_01_tshirt_sport_F", 1
			];

//Wave 1 spawn
for "_i" from 0 to count _spawnPoints-1 do{
	_marker = _spawnPoints select _i;
	call _spawnGroup;
};

////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * Wave 2
*/
////////////////////////////////////////////////////////////////////////////////////////////////////
//Parameters.
_spawnPoints = [
				"spawn_marker_2_0",
				"spawn_marker_2_1",
				"spawn_marker_2_2",
				"spawn_marker_2_3",
				"spawn_marker_2_4"
				];
_totalUnitsPerGroup = 6;	
_spawnableSquadLeads= ["I_C_Soldier_Bandit_6_F", 1];
_spawnableUnits = [
					"I_C_Soldier_Bandit_1_F", .15,	//Medic
					"I_C_Soldier_Bandit_2_F", .20,	//Launcher
					"I_C_Soldier_Bandit_4_F", .30,	//Rifleman
					"I_C_Soldier_Bandit_7_F", .35	//Rifleman
					];

//Wave 2 spawn
sleep 480;
for "_i" from 0 to count _spawnPoints-1 do{
	_marker = _spawnPoints select _i;
	call _spawnGroup;
};