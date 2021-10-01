if (!hasInterface || isDedicated) exitWith {};

waitUntil { !isNull player };

if !(missionNamespace getVariable ["allPlayersReady", false]) then {
	[] spawn {
		waitUntil { getClientStateNumber > 9 };
		// Let the server know we're ready to go
		player setVariable ["playerReady", true, 2];

		waitUntil { missionNamespace getVariable ["allPlayersReady", false] };

		sleep 6;

    [
			parseText "<t font='PuristaBold' size='2.4'>PMC Pyrgos Rescue</t>",
			true, nil, 7, 1, 0
		] call BIS_fnc_textTiles;
	};
};
