//==========================================================================//
// FlyingFordTown.
//
// Marks that the Ford is in a town area and can be seen.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class FlyingFordTown extends HiddenHPawn;

//= Constants =//
const BOOL_DEBUG_AI= false;

//= General Variables =//
var bool bTouch;
var Director Director;


//=========
// Events
//=========

// Called after gameplay begins, gets ref to director
event PostBeginPlay()
{
	foreach AllActors(Class'Director',Director)
	{
		break;
	}
}

// Called when touched by an actor
event Touch (Actor Other)
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

// Called when untouched by an actor
event UnTouch (Actor Other)
{
	// Set that we're not touching
	bTouch = False;

	// Call untouch event on director
	Director.OnUnTouchEvent(self,Other);
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

defaultproperties
{
	Tag="FlyingFordTown"

	bCollideWhenPlacing=True

	CollisionRadius=500.00

	CollisionHeight=32.00

	bCollideActors=True

	bCollideWorld=True
}