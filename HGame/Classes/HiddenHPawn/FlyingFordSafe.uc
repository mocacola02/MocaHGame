//==========================================================================//
// FlyingFordSafe.
//
// Marks that the Ford is in a safe area (can't be seen).
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class FlyingFordSafe extends HiddenHPawn;

//= Constants =//
const BOOL_DEBUG_AI= false;

//= General Variables =//
var bool bTouch;		// Are we being touched
var Director Director;	// Ref to director


//=========
// Events
//=========

// When gameplay starts, get director ref
event PostBeginPlay()
{
	foreach AllActors(Class'Director',Director)
	{
		break;
	}
}

// When touched by an actor
event Touch (Actor Other)
{
	// If not touching
	if ( !bTouch )
	{
		// Set that we're being touched
		bTouch = True;

		// Call touch event on Director
		Director.OnTouchEvent(self,Other);
	}
}

// When untouched by an actor
event UnTouch (Actor Other)
{
	// Set that we're not being touched
	bTouch = False;

	// Call untouch event on Director
	Director.OnUnTouchEvent(self,Other);
}

// When bumped by an actor
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
	Tag="FlyingFordSafe"

	bCollideWhenPlacing=True

	CollisionRadius=35.00

	CollisionHeight=32.00

	bCollideActors=True

	bCollideWorld=True
}