//==========================================================================//
// FlyingFordPathGuide.
//
// Hidden actor that follows the flying Ford spline and used as
// an offset for the car itself.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class FlyingFordPathGuide extends HiddenHPawn;

//= Constants =//
const BOOL_DEBUG_AI= false;

//= General Variables =//
var float AirSpeedNormal;	// Normal air speed
var name PathName;			// Name of path to follow
var Director Director;		// Ref to director


//=========
// Events
//=========

// Called after gameplay ends, gets the director and sets collision to none
event PostBeginPlay()
{
	foreach AllActors(Class'Director',Director)
	{
		break;
	}

	SetCollision(False,False,False);
}

// Called when touched by an actor, calls parent behavior. Not really necessary, could be removed
event Touch (Actor Other)
{
	Super.Touch(Other);
}

// Called when untouched by an actor, calls parent behavior. Not really necessary, could be removed
event UnTouch (Actor Other)
{
	Super.UnTouch(Other);
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


//=========
// States
//=========

// Default flying state
auto state startFlying
{
	// Begin label
	begin:
		// Follow spline path of name PathName at a speed of AirSpeedNormal
		FollowSplinePath(PathName,AirSpeedNormal,0.0);
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	Tag="FlyingFordPathGuide"

	DrawType=DT_Mesh

	Mesh=SkeletalMesh'HPModels.skfirecrabMesh'

	CollisionRadius=200.00

	CollisionHeight=50.00
}