//==========================================================================//
// FireballGrenadeCenter.
//
// Grenade fireball center. Used as the "center" fireball when FireballLarge explodes.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class FireballGrenadeCenter extends HiddenHPawn;

var bool bTouch;		// Can we be touched
var float fLifetime;	// How long we live
var float iDamage;		// How much damage to deal
var(VisualFX) ParticleFX fxGrenadeParticleEffect;	// Grenade particle actor


//=========
// Events
//=========

// Called after gameplay starts
event PostBeginPlay()
{
	// Set timer based on life time
	SetTimer(fLifetime,False);

	// Spawn grenade particle FX
	fxGrenadeParticleEffect = Spawn(Class'Crabfireball');
}

// Called when timer times out
event Timer()
{
	// Shutdown particles
	fxGrenadeParticleEffect.Shutdown();

	// Destroy self
	Destroy();
}

// Called when touched by an actor
event Touch (Actor Other)
{
	// If other is our instigator, ignore and return
	if ( Pawn(Other) == Instigator )
	{
		return;
	}

	// If other is Harry and we can touch
	if ( (Other == PlayerHarry) && (bTouch) )
	{
		// Deal damage
		Other.TakeDamage(iDamage,None,vect(0.0,0.0,0.0),vect(0.0,0.0,0.0),'None');

		// Set timer to 0.2 seconds
		SetTimer(0.2,False);

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


//=========
// States
//=========

// Default begin state, does nothing
auto state stateBegin
{
}


//=====================
// Default Properties
//=====================

defaultproperties
{
    bTouch=True

    fLifetime=2.50

    DrawType=DT_None

    CollisionRadius=10.00

    CollisionHeight=10.00

    bCollideActors=True

    bCollideWorld=True

}