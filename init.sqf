/*
 * Author: UnfittedFoil
 * Description: Mission_1 init file
*/

if !(isServer) exitWith {};     // Runs only once, and only on the server

////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * Phases Setup
*/
////////////////////////////////////////////////////////////////////////////////////////////////////

// Phase 1 involves assaulting a NATO compound to reach the captive Liang Ng
startPhase1 = {
    _taskDescription = "Find Liang Ng. Remember: it is unknown how compliant Liang will be with his rescue.";
    [true, "tsk1", [_taskDescription, "Find Liang Ng", "Marker_23"], "Marker_23"] call BIS_fnc_taskCreate;
};

// Phase 2 involves extricating from a town as new enemies begin a Search and Destroy mission for the players
startPhase2 = {
    ["tsk1", "SUCCEEDED"] call BIS_fnc_taskSetState;
    _taskDescription = "Bring Liang Ng back to base. No need to remove the handcuffs.";
    [true, "tsk2", [_taskDescription, "Return with Liang Ng", "Liang_Room"], "Liang_Room"] call BIS_fnc_taskCreate;
    [] execVM "Phase2_spawner.sqf";
};

// Phase 3 Wraps up the mission in the event not all alive players return. Completion causes a mission complete screen
startPhase3 = {
  returnedEarly = false;
  Base_Area setTriggerStatements [
                                  "allPlayers select {alive _x} findIf {!(_x inArea thisTrigger)} == -1",
                                  "returnedEarly = true;",
                                  ""
                                  ];
  _handle = [] spawn {
    sleep 2; // 2 seconds for the trigger to update
    if (returnedEarly) then {
      call closeOut;
    } else {
      _taskDescription = "No objectives left, return to base";
      [true, "tsk3", [_taskDescription, "RTB", "Marker_25"], "Marker_25"] call BIS_fnc_taskCreate;
      Base_Area setTriggerStatements [
                                      "allPlayers select {alive _x} findIf {!(_x inArea thisTrigger)} == -1",
                                      "[""tsk3"", ""SUCCEEDED""] call BIS_fnc_taskSetState;call closeOut;",
                                      ""
                                      ];
    };
  };
};

// close out the mission
closeOut = {
  // Ending dependent on if Liang lived
  _handle = [] spawn {
    _win = "tsk2" call BIS_fnc_taskState;
    systemChat str _win;
    sleep 8;
    if(_win == "SUCCEEDED") then {
      ["MissionComplete", true, 3, true] remoteExec ["BIS_fnc_endMission", 0, true];
      systemChat "Mission Complete";
    }
    else{
      ["MissionFailed", false, 3, false] remoteExec ["BIS_fnc_endMission", 0, true];
      systemChat "Mission Failed";
    };
  };
};


////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * Initial Setup
*/
////////////////////////////////////////////////////////////////////////////////////////////////////


// This will be added to the JIP queue, and removed if Liang is deleted
{
  waitUntil { !isNil "ace_interact_menu_fnc_removeActionFromClass" };
  {
    [typeOf Liang, 0, _x] call ace_interact_menu_fnc_removeActionFromClass;
  } forEach [
    ["ACE_MainActions", "ACE_RemoveHandcuffs"],
    ["ACE_MainActions", "ACE_TeamManagement", "ACE_GetDown"],
    ["ACE_MainActions", "ACE_TeamManagement", "ACE_SendAway"]
  ];
} remoteExec ["call", 0, Liang];

Liang setVariable ["ace_medical_allowUnconsciousness", true, true];
Liang setVariable ["ace_medical_damageThreshold", 32 * ace_medical_playerDamageThreshold, true];


[] spawn {
  waitUntil {
    allPlayers findIf {
      !(_x getVariable ["playerReady", false])
    } == -1 && {
      getClientStateNumber > 9
    };
  };
  missionNamespace setVariable ["allPlayersReady", true, true];
};

// Updates player lighting variable based on the lighting on the server.
[] spawn {
  while {true} do {
    {
      if (!alive _x) then { continue; };
      _player = _x;
      _currentLighting = getLightingAt _player;
      _player setVariable ["currentLighting", _currentLighting, owner _player];
    } forEach (allPlayers);
    sleep 3;
  };
};

// Garrison script
holdPosition = {
  params ["_unit"];

  doStop vehicle _unit;
  _unit disableAI "PATH";

  private _scriptHandle = _unit getVariable "holdScriptHandle";
  if (!isNil "_scriptHandle" && {!scriptDone _scriptHandle}) exitWith {};

  _scriptHandle = [_unit] spawn {
    params ["_unit"];
    while {true} do {
      if (!alive _unit) exitWith {};

      // "Un-leash" the unit if it knows of any nearby hostiles
      if (
          {
            (_x select 3) > 0 // Hostile units
          } count (_unit nearTargets 30) > 0
      ) exitWith {
        _unit enableAI "PATH";
        _unit doFollow (leader _unit);
        _unit forceSpeed -1;
      };

      // Stagger wakeup times so as not to hammer the server all at once
      sleep (5 + random 1);
    };
  };

  _unit setVariable ["holdScriptHandle", _scriptHandle];
};

// Add the Garrison script to appropriate units
{
	if (_x getVariable ["garrisonUnit", false]) then {
		[_x] call holdPosition;
	};
} forEach allUnits;

civDeathCounter = 0;

["Civilian", "Killed", {
  params ["_unit"];
  civDeathCounter = civDeathCounter + 1;
}] call CBA_fnc_addClassEventHandler;

// Allow Zeus to edit stuff
[] spawn {
    while { true } do {
        {
            _x addCuratorEditableObjects [entities [[], ["Logic"], true, true], true];
        } forEach allCurators;
        sleep 60;
    };
};

call startPhase1;
