
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


//INPROGRESS: Creates groups of enemies at designated spawn points
//CURRENT: Edit clothes to add variety to hostiles
//TODO: Send group to hunt players

_group = createGroup [independent, true];

_marker = _spawnPoints select 0;
_enemy = _group createUnit [selectRandomWeighted _spawnableSquadLeads, getMarkerPos _marker, [], 5, "NONE"];
_enemy forceAddUniform selectRandomWeighted _uniforms; //##Changes uniform.

for "_i" from 2 to _totalUnits do{
	_enemy = _group createUnit [selectRandomWeighted _spawnableUnits, getMarkerPos _marker, [], 5, "NONE"];
	
	_enemy forceAddUniform selectRandomWeighted _uniforms; //##Changes uniform.
};





