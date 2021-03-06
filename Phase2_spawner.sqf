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
 * Description: Creates groups of enemies at provided location and sends groups towards players
 *
 * Variables used....
 *   _side: side the unit belogs to. Examples keywords, "EAST", "WEST", "Independent".
 *   _spawnableSquadLeads: Array of paired units and weights that will be the first(lead) unit spawned for a squad
 *   _totalUnits: Total number of units a squad should posses
 *   _squadUnits: Array of paired units and weights that can be spawned in the squad
 *   _location: Coordinates for where the squad should be spawned.
 *   _uniforms: Set of alternate uniforms that units can be spawned with. Can be nil
 *
 * Returns:
 *   group that has been defined
 */
 
// initialize basic group (v12.2.21)
_spawnGroup = {
  params ["_side", "_spawnableSquadLeads", "_totalUnits", "_squadUnits", "_location", "_uniforms"];
  
  _validPlayers =  allPlayers select { alive _x && {_x inArea Pyrgos_Area}};
  if (count _validPlayers == 0) exitWith {};
  _playerPosition = selectRandom _validPlayers;

  _group = createGroup [_side, true];
  private _enemy = _group createUnit [selectRandomWeighted _spawnableSquadLeads, _location, [], 5, "NONE"];
  // Change uniform
  if !(isNil "_uniforms") then {
    _enemy forceAddUniform selectRandomWeighted _uniforms;
  };

  // Add units to group
  for "_i" from 2 to _totalUnits do {
    _enemy = _group createUnit [selectRandomWeighted _squadUnits, _location, [], 5, "NONE"];
    // Change uniform
    if !(isNil "_uniforms") then {
      _enemy forceAddUniform selectRandomWeighted _uniforms;
    };
  };

  // Set AI Tasks
  // Set start tasks (rush towards players)
  private _wp = _group addWaypoint [_playerPosition, 50];
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
  // Visibility Threshold for if a player can see a location
  visibilityThreshold = 0.2; // 1 is fully visible, 0 is presumbly not visible. This needs play testing to determine.
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
  
  //// Determine spawn location based average player position and direction. If the spot is visibile reroll. If no spot is found after 50 attempts, use the last one. (Yes bad, but a better system requires more loops)
  _spawnLocation = [0, 0];
  for "_i" from 0 to 50 do{
  
    _spawnDirection = _movementDirection + (random _spawnRangeAngl);  
	_spawnDist = random _spawnRangeDist;
  
	
    _spawnLocation set [0, (_averagePosEnd select 0) + _spawnDist * sin(_spawnDirection)];
    _spawnLocation set [1, (_averagePosEnd select 1) + _spawnDist * cos(_spawnDirection)];
    
    //check if spawn location is visible
    _visible = false;
    {
	  systemChat str (_spawnLocation + [0]);
	  _visibleToPlayer = (([objNull, "VIEW"] checkVisibility [eyepos _x, ATLToASL (_spawnLocation + [0])]) > visibilityThreshold);
	  
	  // Way of saying the position is visible if it was visible to this player or a previous player
	  _visible = _visible || _visibleToPlayer;
	  
    }forEach _players;
    if !(_visible) then {break};
  };
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
_spawnDistance = [140, 150, 160];
_spawnAngle = [-20, 0, 20];

_side = independent;
_totalUnitsPerGroup = 4;
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

for "_i" from 0 to _spawnedSquads do{
  _alivePlayers = allPlayers select {alive _x};    // All living players
  // Exit if the players have left the area
  if (_alivePlayers findIf {(_x inArea Pyrgos_Area)} == -1) exitWith {
    systemChat "Players have left the Pyrgos_Area";
  };
  
  _location = [_alivePlayers, _spawnDistance, _spawnAngle] call _proposeSpawnLocation;
  [_side, _spawnableSquadLeads, _totalUnitsPerGroup, _spawnableUnits, _location, _uniforms] call _spawnGroup;
  sleep 50; //Staggers unit spawns by 80 seconds
};

sleep 30;  // 3 minutes for spawning group, total of 8 minutes since the start

////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * Wave 2
 * Light quick reacting wave
*/
////////////////////////////////////////////////////////////////////////////////////////////////////
// Parameters
_spawnedSquads = 5;
_spawnDistance = [150, 200, 250];
_spawnAngle = [-40, 0, 40];

_totalUnitsPerGroup = 6;

// Wave 2 spawn
for "_i" from 0 to _spawnedSquads do{
  _alivePlayers = allPlayers select {alive _x};    // All living players
  // Exit if the players have left the area
  if (_alivePlayers findIf {(_x inArea Pyrgos_Area)} == -1) exitWith {
    systemChat "Players have left the Pyrgos_Area";
  };
  
  _location = [_alivePlayers, _spawnDistance, _spawnAngle] call _proposeSpawnLocation;
  [_side, _spawnableSquadLeads, _totalUnitsPerGroup, _spawnableUnits, _location, _uniforms] call _spawnGroup;
  sleep 50; //Staggers unit spawns by 2 minutes each
};

sleep 50;  // 8 minutes for spawning group, total of 8 minutes since the start

////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * Wave 3
 * Moderate testing force
*/
////////////////////////////////////////////////////////////////////////////////////////////////////
// Parameters
_spawnedSquads = 4;
_spawnDistance = [200, 250, 300];
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
  // Exit if the players have left the area
  if (_alivePlayers findIf {(_x inArea Pyrgos_Area)} == -1) exitWith {
    systemChat "Players have left the Pyrgos_Area";
  };
  
  _location = [_alivePlayers, _spawnDistance, _spawnAngle] call _proposeSpawnLocation;
  [_side, _spawnableSquadLeads, _totalUnitsPerGroup, _spawnableUnits, _location, _uniforms] call _spawnGroup;
  sleep 120; //Staggers unit spawns by 2 minutes each
};

sleep 90; // 9.5 minutes from previous group, 17.5 minutes from start

////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * Wave 4
 * Scary heavily armed counter
*/
////////////////////////////////////////////////////////////////////////////////////////////////////
// Parameters
_spawnedSquads = 3;


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
  // Exit if the players have left the area
  if (_alivePlayers findIf {(_x inArea Pyrgos_Area)} == -1) exitWith {
    systemChat "Players have left the Pyrgos_Area";
  };
  
  _location = [_alivePlayers, _spawnDistance, _spawnAngle] call _proposeSpawnLocation;
  [_side, _spawnableSquadLeads, _totalUnitsPerGroup, _spawnableUnits, _location, nil] call _spawnGroup;
  sleep 100
};

sleep 0; // 5 minutes from previous group, 22.5 from start
