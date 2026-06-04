//==========================================================================//
// FlyingFordWindTrigger.
//
// Triggers wind during the scrapped flying Ford mini-game.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class FlyingFordWindTrigger extends HiddenHPawn;

//= Constants =//
const BOOL_DEBUG_AI= false;

//= General Variables =//
var bool bTouch;				// Are we being touched
var FlyingFordDirector Director;// Ref to director


//=========
// Events
//=========

// Called after gameplay begins
event PostBeginPlay()
{
	// Call parent behavior
	Super.PostBeginPlay();

	// Get director
	foreach AllActors(Class'FlyingFordDirector',Director)
	{
		break;
	}
}

// Called when touched by actor
event Touch (Actor Other)
{
	local FlyingFordWind Wind;

	// Call parent behavior
	Super.Touch(Other);

	// If other is Harry
	if ( Other.IsA('harry') )
	{
		// If not being touched
		if ( !bTouch )
		{
			// Set that we're being touched
			bTouch = True;

			// Call touch event on director
			Director.OnTouchEvent(self,Other);

			// Set wind as our owner casted as FlyingFordWind
			Wind = FlyingFordWind(Owner);

			// If we have wind, start wind
			if ( Wind != None )
			{
				Wind.StartWind();
			}
		}
	}
}

// Called when untouched by actor
event UnTouch (Actor Other)
{
	local FlyingFordWind Wind;

	// Call parent behavior
	Super.UnTouch(Other);

	// If other is Harry
	if ( Other.IsA('harry') )
	{
		// Set that we're not being touched
		bTouch = False;

		// Call untouch event on director
		Director.OnUnTouchEvent(self,Other);

		// Set wind as our owner casted as FlyingFordWind
		Wind = FlyingFordWind(Owner);

		// If we have wind, stop wind
		if ( Wind != None )
		{
			Wind.StopWind();
		}
	}
}

// Called when bumped by actor
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


//=========
// States
//=========

// Default begin state
auto state triggerBegin
{
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bHidden=False

	Tag="FlyingFordWindTrigger"

	CollisionRadius=0.00

	CollisionHeight=400.00

	bCollideActors=True

	bCollideWorld=True
}