//==========================================================================//
// Direction.
//
// Handles mini-game, puzzle, etc. behavior.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class Director extends Actor;

var harry PlayerHarry;	// Reference to Harry
var baseConsole Console;// Reference to console



//=================
// Event Handling
//=================

// Called before gameplay starts
event PreBeginPlay()
{
	// Call parent behavior
	Super.PreBeginPlay();
	
	// Search for actor of class harry and set that as PlayerHarry
	foreach AllActors(Class'harry',PlayerHarry)
	{
		break;
	}
}

// On touch, log that a given Pawn touched a given Actor
function OnTouchEvent (Pawn Subject, Actor Object)
{
	PlayerHarry.ClientMessage(string(Subject.Name) $ " touched " $ string(Object.Name));
}

// On untouch, log that a given Pawn untouched a given Actor
function OnUnTouchEvent (Pawn Subject, Actor Object)
{
	PlayerHarry.ClientMessage(string(Subject.Name) $ " untouched " $ string(Object.Name));
}

// On bump, log that a given Pawn bumped a given Actor
function OnBumpEvent (Pawn Subject, Actor Object)
{
	PlayerHarry.ClientMessage(string(Subject.Name) $ " bumped " $ string(Object.Name));
}

// On hit, log that a given Pawn hit an obstacle
function OnHitEvent (Pawn Subject)
{
	PlayerHarry.ClientMessage(string(Subject.Name) $ " hit an obstacle");
}

// On take damage, log that a given Pawn take given damage
function OnTakeDamage (Pawn Subject, int Damage, Pawn InstigatedBy, name DamageType)
{
	PlayerHarry.ClientMessage(string(Subject.Name) $ " took '" $ string(DamageType) $ "' damage");
}

// On cutscene, log that a given cutscene tag triggered us
function OnCutSceneEvent (name CutSceneTag)
{
	PlayerHarry.ClientMessage("CutScene " $ string(CutSceneTag) $ " triggered Director");
}

// On trigger, log that a given Actor triggered us with a given Pawn
function OnTriggerEvent (Actor Other, Pawn EventInstigator)
{
	PlayerHarry.ClientMessage(string(Other) $ " triggered Director with " $ string(EventInstigator));
}

// On trigger
event Trigger (Actor Other, Pawn EventInstigator)
{
	local CutScene CutScene;

	// Set cutscene to the Other actor cast as a cutscene
	CutScene = CutScene(Other);
	
	// If we have a cutscene, call OnCutSceneEvent
	if ( CutScene != None )
	{
		OnCutSceneEvent(CutScene.Tag);
	}
	// Otherwise, call OnTriggerEvent
	else
	{
		OnTriggerEvent(Other,EventInstigator);
	}
}


//========================
// Player Event Handling
//========================

// Called on player possessed, logs that we possessed and updates console
function OnPlayerPossessed()
{
	Log("Player possessed");
	Console = baseConsole(PlayerHarry.Player.Console);
}

// Called on player's TravelPostAccept, logs that player processed it
function OnPlayerTravelPostAccept()
{
	Log("Player processed TravelPostAccept event");
}

// Called on player dying, logs that player is dying
function OnPlayerDying()
{
	PlayerHarry.ClientMessage("Player dying...");
}

// Called on player death, logs that player died
function OnPlayersDeath()
{
  PlayerHarry.ClientMessage("Director: Player died");
}

// Called on action key pressed, logs that key was pressed
function OnActionKeyPressed()
{
  PlayerHarry.ClientMessage("Action key pressed");
}


//====================
// Cutscene Handling
//====================

// Called on cut capture, always returns true
function bool OnCutCapture()
{
	return True;
}

// Called on cut release, always returns true
function bool OnCutRelease()
{
	return True;
}

// Processes a cut command
function bool CutCommand (string Command, optional string cue, optional bool bFastFlag)
{
	local string sActualCommand;

	// Parse the actual command from the command string
	sActualCommand = ParseDelimitedString(Command," ",1,False);

	// If command is Capture, call OnCutCapture
	if ( sActualCommand ~= "Capture" )
	{
		return OnCutCapture();
	}
	// Otherwise, if command is Release, call OnCutRelease
	else if ( sActualCommand ~= "Release" )
	{
		return OnCutRelease();
	}
	// Otherwise
	else
	{
		// Log that we received an unknown command
		PlayerHarry.ClientMessage("Director received an unknown cut-command");
		
		// Attempt calling command on parent class
		return Super.CutCommand(Command,cue,bFastFlag);
	}
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bHidden=True

	Tag=Director

	Texture=Texture'Engine.S_Flag'

	DrawScale=3.00
}
