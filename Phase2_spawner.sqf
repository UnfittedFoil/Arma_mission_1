/*
 * Author: UnfittedFoil
 * Description: Allows enemies for Phase 2 of a mission to begin spawning upon a trigger being activated
*/

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
 *   _squadLeads: Array of paired units and weights that will be the first(lead) unit spawned for a squad
 *   _totalUnits: Total number of units a squad should posses
 *   _squadUnits: Array of paired units and weights that can be spawned in the squad
 *   _location: Coordinates for where the squad should be spawned.
 *   _uniforms: Set of alternate uniforms that units can be spawned with. Can be nil
 *
 * Returns:
 *   group that has been defined
 */
 
// initialize basic group (v11.19.21)
_spawnGroup = {
  params ["_side", "_spawnableSquadLeads", "_totalUnits", "_squadLeads", "_location", "_uniforms"];
  
  _group = createGroup [_side, true];
  private _enemy = _group createUnit [selectRandomWeighted _spawnableSquadLeads, _location, [], 5, "NONE"];
  // Change uniform
  if !(isNil "_uniforms") then {
    _enemy forceAddUniform selectRandomWeighted _uniforms;
  };

  // Add units to group
  for "_i" from 2 to _totalUnits do {
    _enemy = _group createUnit [selectRandomWeighted _squadLeads, _location, [], 5, "NONE"];
    // Change uniform
    if !(isNil "_uniforms") then {
      _enemy forceAddUniform selectRandomWeighted _uniforms;
    };
  };

  // Set AI Tasks
  // Set start tasks (rush towards players)
  private _wp = _group addWaypoint [position player, 50];
  _wp setWaypointType "SAD";
  // Set final task (search for players)
  _wp = _group addWaypoint [getMarkerPos _wp, 500];
  _wp setWayPointType "SCRIPTED";
  _wp setWaypointScript "\z\lambs\addons\wp\scripts\fnc_wpHunt.sqf";

  _group
};

/* Name: proposeSpawnLocation
 * Description: Proposes a spawn point that is near a group of players. The group position is determined by the centroid of the group. A vector of their approximate movement over 5 seconds is generated
 *
 * Variables used....
 *   _players: Array of players that the enemies should spawn by.
 *   _spawnRangeDist: the min and max distance from the player centroid that the spawn should occur.
 *   _spawnRangeAngl: the min and max angular distance from movement direction that the spawn should occur.
 *
 * Returns:
 *   coordinates for the proposed spawn.
 */
_proposeSpawnLocation = {
  params ["_players", "_spawnRangeDist", "_spawnRangeAngl"];
  
  //// Find initial average player position
  _totalPos = [0,0];
  _totalPlayers = count _players;
	
  {
    _player = _x;
    _playerPos = getPos _x;
    _totalPos set [0, (_totalPos select 0) + (_playerPos select 0)];
    _totalPos set [1, (_totalPos select 1) + (_playerPos select 1)];	  
  }forEach _players;

  _averagePosStart = _totalPos apply{ _x / _totalPlayers};
  
  //// Find average player position 5 seconds later
  sleep 5;
    
  _totalPos = [0,0];
  _totalPlayers = count _players;
    
  {
    _player = _x;
    _playerPos = getPos _x;
    _totalPos set [0, (_totalPos select 0) + (_playerPos select 0)];
    _totalPos set [1, (_totalPos select 1) + (_playerPos select 1)];	  
  }forEach _players;
    
  _averagePosEnd = _totalPos apply{ _x / _totalPlayers};

  //// Process these to find player direction as polar coordinates
  _movementCo = [(_averagePosEnd select 0) - (_averagePosStart select 0), (_averagePosEnd select 1) - (_averagePosStart select 1)];
	
  _movementDirection = atan ((_averagePosEnd select 0) / (_averagePosEnd select 1));
  // inverse Tangent can only determine an angle between +- 90 degrees. If Y is negative though, the range should be  from 90-270, and adding 180 in these cases will correctly map these values.
  if ((_movementCo select 1) < 0) then { 
    _movementDirection = _movementDirection + 180;
  };
  
  //// Determine spawn location based average player position and   
  _spawnDirection = _movementDirection + (random _spawnRangeAngl);  
  _spawnDistance = random _spawnRangeDist;

  _spawnLocation = [0, 0];
  _spawnLocation set [0, (_averagePosEnd select 0) + _spawnDistance * sin(_spawnDirection)];
  _spawnLocation set [1, (_averagePosEnd select 1) + _spawnDistance * cos(_spawnDirection)];
  
  _spawnLocation
};
////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * Wave 1
 * Light quick reacting wave
*/
////////////////////////////////////////////////////////////////////////////////////////////////////
// Parameters.
_spawnedSquads = 5;
_spawnDistance = [150, 200, 250];
_spawnAngle = [-60, 0, 60];

_side = independent;
_totalUnitsPerGroup = 6;
_spawnableSquadLeads= ["I_C_Soldier_Bandit_6_F", 1]; //// UGL
_spawnableUnits = [
					"I_C_Soldier_Bandit_4_F", 50, // Rifleman
					"I_C_Soldier_Bandit_7_F", 50  // Rifleman
];
// Assortment of civilian like uniforms
_uniforms = [
				"U_I_C_Soldier_Bandit_1_F",        1,
				"U_I_C_Soldier_Bandit_2_F",        1,
				"U_I_C_Soldier_Bandit_3_F",        1,
				"U_I_C_Soldier_Bandit_4_F",        1,
				"U_I_C_Soldier_Bandit_5_F",        1,
				"U_I_C_Soldier_Bandit_6_F",        1,
				"U_C_Man_Casual_1_F",              1,
				"U_C_Man_Casual_2_F",              1,
				"U_C_Man_Casual_3_F",              1,
				"U_C_Man_Casual_4_F",              1,
				"U_C_Man_Casual_5_F",              1,
				"U_C_Man_Casual_6_F",              1,
				"U_C_PoloShirt_blue_F",            1,
				"U_C_PoloShirt_burgundy_F",        1,
				"U_C_PoloShirt_redwhite_F",        1,
				"U_C_PoloShirt_salmon_F",          1,
				"U_C_PoloShirt_striped_F",         1,
				"U_C_PoloShirt_tricolor_F",        1,
				"U_C_E LooterJacket_1_F",          1,
				"U_I_L_Uniform_01_tshirt_black_F", 1,
				"U_I_L_Uniform_01_tshirt_olive_F", 1,
				"U_I_L_Uniform_01_tshirt_skull_F", 1,
				"U_I_L_Uniform_01_tshirt_sport_F", 1
];
// Wave 1 spawn
/*
{
  _marker = _x;
  call _spawnGroup;
  sleep 80; //Staggers unit spawns by 80 seconds
} forEach _spawnPoints;
*/

for "_i" from 0 to _spawnedSquads do{
  _alivePlayers = allPlayers select {alive _x};    // All living players
  _location = [_alivePlayers, _spawnDistance, _spawnAngle] call _proposeSpawnLocation;
  [_side, _spawnableSquadLeads, _totalUnitsPerGroup, _spawnableUnits, _location, _uniforms] call _spawnGroup;
  sleep 80; //Staggers unit spawns by 80 seconds
};

sleep 80;  // 8 minutes for spawning group, total of 8 minutes since the start

////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * Wave 2
 * Moderate testing force
*/
////////////////////////////////////////////////////////////////////////////////////////////////////
// Parameters
_spawnedSquads = 4;
_spawnDistance = [150, 200, 250];
_spawnAngle = [-60, 0, 60];

_totalUnitsPerGroup = 8;
_spawnableSquadLeads= ["I_C_Soldier_Bandit_6_F", 1]; // UGL
_spawnableUnits = [
					"I_C_Soldier_Bandit_1_F", 15, // Medic
					"I_C_Soldier_Bandit_2_F", 20, // Launcher
					"I_C_Soldier_Bandit_4_F", 30, // Rifleman
					"I_C_Soldier_Bandit_7_F", 35  // Rifleman
];
// Wave 2 spawn
for "_i" from 0 to _spawnedSquads do{
  _alivePlayers = allPlayers select {alive _x};    // All living players
  _location = [_alivePlayers, _spawnDistance, _spawnAngle] call _proposeSpawnLocation;
  call _spawnGroup;
  sleep 120; //Staggers unit spawns by 2 minutes each
};

sleep 90; // 9.5 minutes from previous group, 17.5 minutes from start

////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * Wave 3
 * Scary heavily armed counter
*/
////////////////////////////////////////////////////////////////////////////////////////////////////
// Parameters
_spawnedSquads = 3;
_spawnDistance = [150, 200, 250];
_spawnAngle = [-60, 0, 60];

_totalUnitsPerGroup = 12;
_spawnableSquadLeads= ["I_C_Soldier_Para_4_F", 1]; // Machine Gunner
_spawnableUnits = [
					"I_C_Soldier_Para_1_F", 10, // Rifleman
					"I_C_Soldier_Para_2_F", 10, // Rifleman
					"I_C_Soldier_Para_3_F", 15, // Medic
					"I_C_Soldier_Para_4_F", 10, // Machine Gunner
					"I_C_Soldier_Para_5_F", 20, // Launcher
					"I_C_Soldier_Para_6_F", 25, // UGL
					"I_C_Soldier_Para_7_F", 10  // Rifleman
];
_uniforms = nil;

// Wave 3 spawn
for "_i" from 0 to _spawnedSquads do{
  _alivePlayers = allPlayers select {alive _x};    // All living players
  _location = [_alivePlayers, _spawnDistance, _spawnAngle] call _proposeSpawnLocation;
  call _spawnGroup;
  sleep 100
};

sleep 0; // 5 minutes from previous group, 22.5 from start