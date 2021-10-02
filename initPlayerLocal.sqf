if (!hasInterface || isDedicated) exitWith {};

waitUntil { !isNull player };

player setVariable ["currentLighting", [[0,0,0], 0, [0,0,0], 0]];

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

////////////////////////////////////////////////////////////////////////////////
/*
 * Functions
 */
////////////////////////////////////////////////////////////////////////////////

/*
 * Determines total nearby chemlights. Determines if there are any nearby
 * chemlights. IR chemlights are excluded as it will be assumed (faslsely at
 * times) that enemies are unable to see IR light.
 */
nearChemlights = {
    params ["_player"];
    _distance = 5; // Distance chemlighs can be from players

    private _total = 0;
    {
        private _throwable = _x;
        private _throwableClass = typeOf _throwable;

        private _effect = getText (configFile >> "CfgAmmo" >> _throwableClass >> "effectsSmoke");
        if (isNil "_effect") then { continue; };

        private _effectClass = (configFile >> _effect);
        if !(isClass _effectClass) then { continue; };

        private _lightClass = _effectClass >> "Light1";
        if !(isClass _lightClass) then { continue; };

        private _cfgLights = getText (_lightClass >> "type");
        if (isNil "_cfgLights") then { continue; };

        private _cfgLightsClass = configFile >> "CfgLights" >> _cfgLights;
        if !(isClass _cfgLightsClass) then { continue; };

        //IR chemlights have an intensity of 0. This filters out IR chemlights.
        private _intensity = getNumber (_cfgLightsClass >> "intensity");
        if (_intensity <= 0) then { continue; };
        
        _total = _total + 1; //Runs if no other conditions where tripped.
    } forEach (_player nearObjects ["GrenadeHand", _distance]);

    _total;
};

/*
 * Adjusts the visibility of units to the AI. NOTE that the server should be
 * running a script to set the player "currentLighting" to the value the server
 * gets for getLighting at the player location
 */
adjustCamo = {

  params ["_unit"];
  
  //private _scriptHandle = _unit getVariable "holdScriptHandle";
  //if (!isNil "_scriptHandle" && {!scriptDone _scriptHandle}) exitWith {};
  _scriptHandle = [_unit] spawn {
    params ["_unit"];
    _startCamo = player getUnitTrait "camouflageCoef";
    while {true} do {
      if (!alive _unit) exitWith {};
      //_light = (getLightingAt player) select 3; 
  
      // At around 25.0, a person is nearly as visible as in 1,000 light. They can be identified as hostile pretty clearly
      _lighting = player getVariable["currentLighting" , nil];
      _lighting = 25.0 min (_lighting select 3);
      _lightOn = player isFlashlightOn (currentWeapon player);
      _chemlights = player call nearChemlights;


      ///// camo calculation function  
      if (_lightOn) then{
        _lighting = 15 max _lighting;
        _lighting = _lighting + 5;  // This applies an additional visibility penalty
      } else {
        if (_chemlights > 0) then {
        _lighting = 12.5 max _lighting;
        };
      };
      _modifier = 0.15 + (_lighting * 0.034);  // values should be 1 at 25; 0.5 at 0
      
      /////
      player setUnitTrait ["camouflageCoef", _startCamo * _modifier];
      sleep 3;
    };
  };
};

player call adjustCamo;
