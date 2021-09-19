
/*
 * Author: UnfittedFoil
 * Description: Allows enemies to begin spawning upon a trigger being activated.
 *
 *
*/

if !(isServer) exitWith {};		//Runs only once, and only on the server
systemChat "Trigger Activated 2"; 	//DEBUG. Allows for the confirmation of the activation of the trigger


//Parameters. All units will be spawned. The spawnpoints will cycle if shorter then number of units.
_spawnPoints = [
				"spawn_marker_0",
				"spawn_marker_1",
				"spawn_marker_2",
				"spawn_marker_3",
				"spawn_marker_4"
				];
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
_totalUnits = 4;


//Derived parameteres
_spawnPointsLength = count _spawnPoints;


//Creates groups of enemies at designated spawn points
_spawnGroup = {
	//initialize basic group
	_group = createGroup [independent, true];
	_enemy = _group createUnit [selectRandomWeighted _spawnableSquadLeads, getMarkerPos _marker, [], 5, "NONE"];
	_enemy forceAddUniform selectRandomWeighted _uniforms; //##Changes uniform.
	
	//Add units to group
	for "_i" from 2 to _totalUnits do{
		_enemy = _group createUnit [selectRandomWeighted _spawnableUnits, getMarkerPos _marker, [], 5, "NONE"];
		_enemy forceAddUniform selectRandomWeighted _uniforms; //##Changes uniform.
	};
	
	//Set AI Tasks
		//Set start tasks(Rush towards players)
	_wp = _group addWaypoint [position player, 50];
	_wp setWaypointType "SAD";
		//Set final task (Search for players)
	_wp = _group addWaypoint [getMarkerPos _wp, 500];
	_wp setWayPointType "SCRIPTED";
	_wp setWaypointScript "\z\lambs\addons\wp\scripts\fnc_wpHunt.sqf";

};

//Wave 1 spawn
for "_i" from 0 to count _spawnPoints-1 do{
	_marker = _spawnPoints select _i;
	call _spawnGroup;
}