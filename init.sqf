/*
 * Author: UnfittedFoil
 * Description: Mission_1 init file
 *
 *
*/

if !(isServer) exitWith {};		//Runs only once, and only on the server

_setBriefing = {
	_situation = "
					Outrage over the government's efforts to crackdown on civil disobedience over recent trade laws has resulted in an insurgence. The first large scale attack starting the war was the raid of the Kalithea port during November of 1934. Six months into the war NATO has officially backed the Altis government and deployed a small contingent of troops to assist in peacekeeping, deploying most of their troops to the Gravia airbase due to it's central location on the island.
					<br/>
					<br/>
					We have been contracted to recover a man by the name Liang Ng from NATO custody. Our contact has confirmed that Liang Ng is currently being held in a NATO controlled compound in the city of Pyrgos. To our knowledge, these are the only NATO soldiers in Pyrgos.
					<br/>
					<br/>
					Liang Ng is a well known Smugler in the area, and had been supplying the local resistance with  military equipment. NATO learned of his involvement and managed to set a trap for him. NATO likely plans to move Liang off island to make any rescue by the resistence less likely.
					<br/>
					<br/>
					Initial observation operations of the facility found that there is around 10 nato guards, the area is reguraly patrolled by part of the group, and the team managed to acquire a package containing a few NATO weapons and 6.5mm ammo. The package also contained a few grenade launchers which is perfect since the intern Gary acquired 40m HE grenade rounds instead of v40 grenades.
					<br/>
					<br/>
					As predicted by our contact and confirmed by Gary, as of 01:42, NATO forces at the airport are being distracted likely by the resistance. This will be our best opportunity to retrieve the hostage.
				 ";
	_mission = "
					Retrieve Liang Ng from NATO custody at mark <marker name =""marker_23"">NATO Compound</marker>and return him back to <marker name=""marker_25"">Base</marker>
				";
	_execution = "
					* Keep civilian casualties to a minimium.
					<br/>
					1. Retrieve the hostage and ensure their compliance.
					<br/>
					2. Return to base with the hostage.
					<br/> 
					- Alternate extraction methods are listed below.
					<br/>
					--- Alt extract A: <marker name=""marker_27"">KamAZ Transport(Seats 17)</marker>
					<br/>
					--- Alt extract B: You have been equiped with boots
					<br/>
					--- Alt extract C: <marker name=""marker_26"">Rescue Boat(seats 5)</marker>
				";

	_x createDiaryRecord["Diary",["Execution", _execution]];
	_x createDiaryRecord["Diary",["Mission", _mission]];
	_x createDiaryRecord["Diary",["Situtation", _situation]];
};

_setBriefing forEach allPlayers;

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
startPhase3 = { 
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
	//Ending dependent on if Liang lived
	_win = "tsk2" call BIS_fnc_taskCompleted;
	["temp1", _win, true, _win] call BIS_fnc_endMission;
};


////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * Initial Setup
*/
////////////////////////////////////////////////////////////////////////////////////////////////////

call startPhase1;