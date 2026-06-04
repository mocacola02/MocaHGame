//==========================================================================//
// FlyingFordHedwig.
//
// Hedwig actor intended for use during the scrapped Flying Ford mini-game.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class FlyingFordHedwig extends HiddenHPawn;

//= Consts =//
const BOOL_DEBUG_AI= false;	// Should debug logging be printed

//= General Variables =//
var bool bTouch;		// Are we being touched
var Director Director;	// Reference to Director


//=========
// Events
//=========

// Called after gameplay starts, searches for and sets director ref
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
	// If we're not being touched
	if ( !bTouch )
	{
		// Set that we're being touched
		bTouch = True;

		// Call touch event on director
		Director.OnTouchEvent(self,Other);
	}
}

// Called when untouched by an actor
event UnTouch (Actor Other)
{
	// Set that we're no longer touched
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


//=====================
// Default Properties
//=====================

defaultproperties
{
	bHidden=False

	bTrailerSameRotation=True

	bTrailerPrePivot=True

	Tag="FlyingFordHedwig"

	DrawType=DT_Mesh

	Mesh=SkeletalMesh'HPModels.skowlbarnMesh'

	DrawScale=1.20

	CollisionRadius=35.00

	CollisionHeight=32.00
}