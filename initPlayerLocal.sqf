if (!hasInterface || isDedicated) exitWith {};

waitUntil { !isNull player };

player setVariable ["currentLighting", [[0,0,0], 0, [0,0,0], 0]];

_background = "
Fifteen months ago, as part of a transnational free trade efort, the
island nation of Altis, along with eighty-three other countries,
entered into a trade agreement. This was a defeat for a
constituency of the workers on the island, mostly in the logging and
fishing industries, who had been embroiled in protests against the
agreement for the previous month; but this defeat only escalated the
actions undertaken by the increasingly organised protesters.
Recognizing the lack of protection as a threat to their relatively
comfortable lives, a keen sense of desperation mixed with the
already present furor.
<br/>
<br/>
As the level of violence on the streets grew, the government applied
more actively hostile measures. However, a failure to contain and
demoralise the protesters, and a failure to really disrupt their
organisational capacity, meant that this only outraged citizens and
delegitimized the government further, and what had been networks of
activists and protesters would soon act as cover for the cells of a
newborn insurgency.
<br/>
<br/>
The first large scale attack launched by the insurgents was the raid
of Kalithea port -- almost a year ago. During the raid, a docked cargo
ship was scuttled, destroying almost all goods on board. After six
months of an active insurgency on Altis, NATO officially backed the
government and deployed a small contingent of troops to assist in
peacekeeping. Most of these troops were deployed to the centrally
located Gravia air base.";
_situation = "
We have been contracted to recover a man by the name Liang Ng from
NATO custody. Our contact believes that Liang Ng is currently being
held in a guarded compound in the city of Pyrgos; we have received
tentative identification of Liang by an observation team. To our
knowledge these are the only NATO soldiers in Pyrgos.
<br/>
<br/>
Liang Ng is an infamous smuggler in the area, and had been a primary
source of military equipment for the insurgents. NATO learned of his
involvement with the insurgents, ambushed, and captured Liang during
one of his deals. They likely plan to move Liang off island.
<br/>
<br/>
Initial observations of the facility found that there are around
twenty guards present. A contact of ours, codename Geiserich, has
sourced MX-pattern rifles and 40mm grenades, which will be made
availble for use during the mission, in addition to our usual AR-15 and
AUG-pattern rifles.
<br/>
<br/>
We have intel that suggests the batallion stationed at Gravia will be
preoccupied at around 2200 hours tonight. This will be our best
opportunity to retrieve the hostage.";
_mission = "
Retrieve Liang Ng from NATO custody at mark
<marker name=""marker_23"">NATO Compound</marker>
 and return him back to <marker name=""marker_25"">Base</marker>.
<br/>
<br/>
Try to avoid civilian casualties.
<br/>
<br/>
In the event something happens to the vehicles, alternate extraction
has been prepared:
<marker name=""marker_27"">KamAZ Transport</marker>.";
_execution = "
1. Retrieve the Liang and ensure his compliance.
<br/>
<br/>
2. Return to base with the Liang.";

player createDiaryRecord ["Diary", ["Execution", _execution]];
player createDiaryRecord ["Diary", ["Mission", _mission]];
player createDiaryRecord ["Diary", ["Situtation", _situation]];
player createDiaryRecord ["Diary", ["Background", _background]];

[] spawn { waitUntil { call selectBriefing } };

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
  
  _scriptHandle = [_unit] spawn {
    params ["_unit"];
    _startCamo = player getUnitTrait "camouflageCoef";
    while {true} do {
      if (!alive _unit) exitWith {};
  
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

selectBriefing = {
  private _idd = switch (true) do {
    case (!isNull findDisplay 37):  {37};  // RscDisplayServerGetReady
    case (!isNull findDisplay 53):  {53};  // RscDisplayClientGetReady
    case (!isNull findDisplay 52):  {52};  // RscDisplayServerGetReady
    case (!isNull findDisplay 312): {312}; // RscDisplayCurator
    case (!isNull findDisplay 12):  {12}; // RscDisplayMainMap
    default {nil};
  };

  if (isNil "_idd") exitWith {false};

  private _display = findDisplay _idd;
  private _subjects = _display displayCtrl 1001;
  private _records = _display displayCtrl 1002;

  for "_i" from 0 to (lbSize _subjects - 1) do {
      if ((_subjects lbData _i) == "Diary") exitWith {
        _subjects lnbSetCurSelRow _i;
      };
  };

  _records lnbSetCurSelRow 0;

  true
};

player call adjustCamo;
