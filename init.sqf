/*
 * Author: UnfittedFoil
 * Description: Mission_1 init file
*/

if !(isServer) exitWith {};	 // Runs only once, and only on the server

_setBriefing = {
	_situation = "
					Outrage over the Altis government's efforts to crackdown on civil disobedience resulting from recent changes to local trade laws has resulted in an insurgence. The first large scale attack launched by the insurgents was the raid of Kalithea port almost a year ago. Six months following the raid, NATO officially backed the Altis government and deployed a small contingent of troops to assist in peacekeeping. Most of these troops were deployed to Gravia air base and the area around due to its central location on the island.
					<br/>
					<br/>
					We have been contracted to recover a man by the name Liang Ng from NATO custody. Our contact believes that Liang Ng is currently being held in a NATO controlled compound in the city of Pyrgos,  this has been confirmed by the observation team. To our knowledge these are the only NATO soldiers in Pyrgos.
					<br/>
					<br/>
					Liang Ng is an infamous smuggler in the area, and had been a primary source of military equipment for the insurgents. NATO learned of his involvement with the insurgents and ambushed Liang during one of his deals. NATO likely plans to move Liang off island to distance him from any potential help.
					<br/>
					<br/>
					Initial observations of the facility found that there are around 20 nato guards, and the scouting team found an unattended package containing a few NATO MXs and 6.5mm ammo. The package also contained a few grenade launchers which is perfect since the intern Gary sourced 40mm HE grenade rounds instead of the requested v40 grenades.
					<br/>
					<br/>
					As predicted by our contact and confirmed by Gary, as of 22:12, NATO forces at the airport are being distracted by something. This will be our best opportunity to retrieve the hostage.
				 ";
	_mission = "
					Retrieve Liang Ng from NATO custody at mark <marker name =""marker_23"">NATO Compound</marker>and return him back to <marker name=""marker_25"">Base</marker>. Try to avoid civilian casualties. In the event something happens to the vehicles, alternate extraction has been prepared <marker name=""marker_27"">KamAZ Transport</marker>
				";
	_execution = "
					<br/>
					1) Retrieve the Liang and ensure his compliance.
					<br/>
					2. Return to base with the Liang.	
				";

	_x createDiaryRecord ["Diary", ["Execution", _execution]];
	_x createDiaryRecord ["Diary", ["Mission", _mission]];
	_x createDiaryRecord ["Diary", ["Situtation", _situation]];
};

_setBriefing forEach allPlayers;


////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * Phases Setup
*/
////////////////////////////////////////////////////////////////////////////////////////////////////

// Phase 1 involves assaulting a NATO compound to reach the captive Liang Ng
startPhase1 = {
	_taskDescription = "Find Liang Ng in the compound marked NATO COMPOUND. Remember that there it is unknown how compliant Liang will be with his rescue, nor is his compliance needed for the recue";
	[true, "tsk1", [_taskDescription, "Find Liang Ng", "Marker_23"], "Marker_23"] call BIS_fnc_taskCreate;
};

// Phase 2 involves extricating from a town as new enemies begin a Search and Destroy mission for the players
startPhase2 = {
	["tsk1", "SUCCEEDED"] call BIS_fnc_taskSetState;
	_taskDescription = "Bring Liang Ng back to base. No need to remove the handcuffs.";
	[true, "tsk2", [_taskDescription, "return with Liang Ng", "Liang_Room"], "Liang_Room"] call BIS_fnc_taskCreate;
	[] execVM "Phase2_spawner.sqf";
};

// Phase 3 Wraps up the mission in the event not all alive players return. Completion causes a mission complete screen
startPhase3 = {
	returnedEarly = FALSE;
	Base_Area setTriggerStatements [
									"allPlayers select {alive _x} findIf {!(_x inArea thisTrigger)} == -1",
									"returnedEarly = TRUE;",
									""
									];
	_handle = [] spawn {
		sleep 2; // 2 seconds for the trigger to update
		if (returnedEarly) then{
			call closeOut;
		}
		else{
			_taskDescription = "No objectives left, everyone return to base";
			[true, "tsk3", [_taskDescription, "RTB", "Marker_25"], "Marker_25"] call BIS_fnc_taskCreate;
			Base_Area setTriggerStatements [
									"allPlayers select {alive _x} findIf {!(_x inArea thisTrigger)} == -1",
									"returnedEarly = TRUE;",
									"[""tsk3"", ""SUCCEEDED""] call BIS_fnc_taskSetState;call closeOut;"
									];
		};
	};
};

// close out the mission
closeOut = {
	// Ending dependent on if Liang lived
	_handle = [] spawn {
		_win = "tsk2" call BIS_fnc_taskCompleted;
		sleep 8;
		["temp1", _win, true, _win] call BIS_fnc_endMission;
	}
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
	  if( !alive _x) then { continue; }; 
	  _player = _x;
	  _currentLighting = getLightingAt _player;
      _player setVariable ["currentLighting", _currentLighting, owner _player];
	} forEach (allPlayers);
	sleep 3;
  };
};

// Dylans' Garrison script
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
//Add the Garrison script to all units
{
	if(_x getVariable "garrisonUnit" == TRUE) then {
		_x call holdPosition;
	};
}forEach allUnits;

call startPhase1;
