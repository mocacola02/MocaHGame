//==========================================================================//
// Fireball.
//
// Fireball actor, able to bounce and deal damage.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class Fireball extends HiddenHPawn;

var bool bTouch;		// Can we be touched?
var float fLifetime;	// How long we live
var Vector CurrentDir;	// Current movement direction


//=========
// Events
//=========

// Called after gameplay starts, sets timer using fLifetime
event PostBeginPlay()
{
	SetTimer(fLifetime,False);
}

// Called when timer times out, destroys self
event Timer()
{
	Destroy();
}

// Called when touched by an actor
event Touch (Actor Other)
{
	// If other is our instigator, ignore it and return
	if ( Pawn(Other) == Instigator )
	{
		return;
	}

	// If other is Harry and we can touch
	if ( (Other == PlayerHarry) && (bTouch) )
	{
		// Deal damage to other
		Other.TakeDamage(5,None,vect(0.0,0.0,0.0),vect(0.0,0.0,0.0),'None');

		// Don't allow touch anymore
		bTouch = False;
	}

	// Play hit sound
	PlaySound(Sound'spell_hit',SLOT_Interact,1.0,False,2000.0,1.0);
}

// Called when bumped by an actor, redirects to Touch
event Bump (Actor Other)
{
	Touch(Other);
}

// Called when hitting a wall, calls to bounce
event HitWall (Vector HitNormal, Actor HitWall)
{
	bounce(HitNormal);
}


//===========
// Movement
//===========

// Bounce by mirroring our velocity
function bounce (Vector HitNormal)
{
	// Set location to our old location
	SetLocation(OldLocation);

	// Decrease our velocity slightly
	Velocity *= 0.9;

	// Mirror our velocity based on the wall normal
	Velocity = MirrorVectorByNormal(Velocity,HitNormal);

	// Set current direction to our rotation
	CurrentDir = Vector(Rotation);

	// Add hit normal to our direction
	CurrentDir += HitNormal;

	// Set rotation to our calculated direction
	SetRotation(rotator(CurrentDir));
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bTouch=True

	fLifetime=3.00

	attachedParticleClass(0)=Class'HPParticle.Crabfire2'

	attachedParticleClass(1)=Class'HPParticle.CrabSmoke'

	attachedParticleOffset(0)=(X=0.00,Y=0.00,Z=-32.00)

	DrawType=DT_None

	CollisionRadius=10.00

	CollisionHeight=22.00

	bCollideActors=True

	bCollideWorld=True
}