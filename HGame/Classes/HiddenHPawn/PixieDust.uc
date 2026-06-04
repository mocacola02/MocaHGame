//==========================================================================//
// PixieDust.
//
// Intended to handle the pixie dust FX and a few other
// things on the CornishPixie actor. Never actually used.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class PixieDust extends HiddenHPawn;

//= Constants =//
const BOOL_DEBUG_AI= false;	// Should we log debug info

//= General Variables =//
var() int sleepyInterval;	// How much time to add to Harry's sleepy timer

var bool bCanBeTouched;		// Can we be touched?
var bool bTouch;			// Are we being touched?
var float fLifetime;		// Our life time
var float timeSafe;			// Never used


//=========
// Events
//=========

// Called after gameplay begins
event PostBeginPlay()
{
	// Set timer based on lifetime
	SetTimer(fLifetime,False);

	// Allow us to collide with world
	bCollideWorld = True;
}

// Called when timer times out, destroys self
event Timer()
{
	Destroy();
}

// Called when touched by actor
event Touch (Actor Other)
{
	// If other is Harry and we can be touched
	if ( (Other == PlayerHarry) && (bCanBeTouched) )
	{
		// Disable being touched
		bCanBeTouched = False;

		// If we're not in a cutscene, add to Harry's sleepy timer
		if ( !baseHUD(PlayerHarry.myHUD).bCutSceneMode )
		{
			PlayerHarry.SleepyAnimTimerAdd(sleepyInterval);
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


//=====================
// Default Properties
//=====================

defaultproperties
{
	bTouch=True

	fLifetime=5.00

	bCanBeTouched=True

	sleepyInterval=2

	attachedParticleClass(0)=Class'HPParticle.PixieGroundDust'

	Physics=PHYS_Falling

	DrawType=DT_None

	CollisionRadius=25.00

	CollisionHeight=32.00

	bCollideActors=True

	bCollideWorld=True

	Mass=10.00
}