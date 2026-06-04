//==========================================================================//
// FlyingFordLightning.
//
// Lightning obstacle actor intended for use during the scrapped Flying Ford mini-game.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class FlyingFordLightning extends HiddenHPawn;

//= Constants =//
const BOOL_DEBUG_AI= false;

//= General Variables =//
var() int iLightningLoops;		// The number of times to change the car's direction
var() float fTimeBetweenchanges;// The amount of time between each direction change
var() float fLightningViolence;	// How violent the lightning is
var() name stormName;			// Name of the lightning zone we belong to

var bool bTouch;				// Are we being touched
var FlyingFordDirector Director;// Reference to Ford director


//=========
// Events
//=========

// Called after gameplay starts, get flying ford director
event PostBeginPlay()
{
	foreach AllActors(Class'FlyingFordDirector',Director)
	{
		break;
	}
}

// Called when touched by an actor
event Touch (Actor Other)
{
	// If other is Harry
	if ( Other.IsA('harry') )
	{
		// If not touching
		if ( !bTouch )
		{
			// Set that we're touching
			bTouch = True;

			// Call touch event on director
			Director.OnTouchEvent(self,Other);
		}
	}
}

// Called when untouched by an actor
event UnTouch (Actor Other)
{
	// Call parent behavior
	Super.UnTouch(Other);

	// If other is Harry
	if ( Other.IsA('harry') )
	{
		// Call untouch event on director
		Director.OnUnTouchEvent(self,Other);
	}
}

// Called when bumped by an actor
event Bump (Actor Other)
{
	// If in debug mode, log that we've been bumped
	if ( BOOL_DEBUG_AI )
	{
		PlayerHarry.ClientMessage("I have been bumped ");
	}

	// Redirect to Touch
	Touch(Other);
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	fLightningViolence=5.00

	iLightningLoops=15

	fTimeBetweenchanges=0.20

	Tag="FlyingFordLightning"

	CollisionRadius=35.00

	CollisionHeight=32.00

	bCollideActors=True

	bCollideWorld=True
}