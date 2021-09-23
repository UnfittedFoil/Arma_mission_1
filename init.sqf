/*
 * Author: UnfittedFoil
 * Description: Mission_1 init file
 *
 *
*/

if !(isServer) exitWith {};		//Runs only once, and only on the server

systemChat "Init Started";
////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * Phases Setup
*/
////////////////////////////////////////////////////////////////////////////////////////////////////

//Phase 1 involves assaulting a NATO compound to reach the captive Liang Ng
startPhase1 = {
	_taskDescription = "Find Liang Ng in the compound marked NATO COMPOUND. Remember that there it is unknown how compliant Liang will be with his rescue, nor is his compliance needed for the recue";
	[TRUE, "tsk1", [_taskDescription, "Find Liang Ng", "Marker_23"], "Marker_23"] call BIS_fnc_taskCreate;
};

//Phase 2 involves extricating from a town as new enemies begin a Search and Destroy mission for the players
startPhase2 = {
	["tsk1", "SUCCEEDED"] call BIS_fnc_taskSetState;
	_taskDescription = "Bring Liang Ng back to base. No need to remove the handcuffs.";
	[TRUE, "tsk2", [_taskDescription, "return with Liang Ng", "Liang_Room"], "Liang_Room"] call BIS_fnc_taskCreate;
	[]execVM "Phase2_spawner.sqf";
};

//Phase 3 Wraps up the mission in the event not all alive players return. Completion causes a mission complete screen
startPhase3 = {   //Liang was extracted successfully
	Base_Area setTriggerStatements [
									"count (allPlayers select {alive _x && _x inArea thisTrigger}) isEqualTo count allPlayers;",
									"call closeOut",
									""
									];
	_taskDescription = "No objectives left, everyone return to base";
	[TRUE, "tsk3", [_taskDescription, "RTB", "Marker_25"], "Marker_25"] call BIS_fnc_taskCreate;
};

//close out the mission
closeOut = {
	_win = "tsk2" call BIS_fnc_taskCompleted;
	["temp1", _win, true, _win] call BIS_fnc_endMission;
};


////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * Initial Setup
*/
////////////////////////////////////////////////////////////////////////////////////////////////////

call startPhase1