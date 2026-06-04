//==========================================================================//
// LargeFireball.
//
// Large fireball that explodes into smaller fireballs.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class FireballLarge extends HiddenHPawn;

var bool bTouch;					// Can we be touched
var float fLifetime;				// How long we live
var float GrenadeRadius;			// Radius to activate the grenade from
var float GrenadeExplosionGravity;	// Gravity force for grenade explosion
var float iDamage;					// How much damage to deal
var float smallDamage;				// How much damage small fireballs should deal
var(VisualFX) ParticleFX fxGrenadeParticleEffect;	// Grenade particle actor


//=========
// Events
//=========

// Called after gameplay begins
event PostBeginPlay()
{
	SetTimer(fLifetime,False);
	fxGrenadeParticleEffect = Spawn(Class'Crabfire3');
}

// Called when timer times out, shoots fireballs
event Timer()
{
	ShootFireballs();
}

// Called when touched by an actor
event Touch (Actor Other)
{
	if ( Pawn(Other) == Instigator )
	{
		return;
	}
	if ( (Other == PlayerHarry) && (bTouch == True) )
	{
		Other.TakeDamage(iDamage,None,vect(0.0,0.0,0.0),vect(0.0,0.0,0.0),'None');
		SetTimer(0.2,False);
		bTouch = False;
	}
	PlaySound(Sound'spell_hit',SLOT_Interact,1.0,False,2000.0,1.0);
}

// Called when bumped by an actor, redirects to Touch
event Bump (Actor Other)
{
	Touch(Other);
}


//======================
// Projectile Handling
//======================

// Shoots smaller fireballs
function ShootFireballs()
{
	local int I, NumFireballs;
	local float GrenadeRadius, grenadeDamage, ratio;
	local Vector fireball_locn, harrys_head, currentLoc;
	local Rotator rotate_fireball, currentRot;
	local Crabfire Fireball;
	local FireballGrenadeCenter centerFire;
	local spellFireSmall smallFire;
	
	// Set head position to Harry's location
	harrys_head 			= PlayerHarry.Location;

	// Add Harry's half height so we're positioned at his head
	harrys_head.Z 	   	   += PlayerHarry.CollisionHeight / 2;

	// Set number of fireballs to spawn to 10
	NumFireballs 			= 10;

	// Set fireball rotation to face harry's head
	rotate_fireball 		= rotator(harrys_head - Location);

	// Zero out the rotation roll
	rotate_fireball.Roll 	= 0;

	// Increase pitch by 163840 rotation units (aka 2.5 full rotations... instead of just rotating 0.5 rotations... what were you doing KW, this is horrendous)
	rotate_fireball.Pitch  += (65536 * 10) / 4;

	// The distance between us and Harry is less than the grenade radius
	if ( VSize(PlayerHarry.Location - Location) < GrenadeRadius )
	{
		// Shake the camera
		PlayerHarry.ShakeView(0.3,200.0,200.0);

		// Get a ratio based on how close Harry is to us (the further Harry is in our radius, the larger ratio is)
		ratio 			= VSize(PlayerHarry.Location - Location) / GrenadeRadius;

		// Set damage to be our base damage minus our base damage times the ratio is, aka decrease damage based on how far Harry is
		grenadeDamage 	= iDamage - (iDamage * ratio);

		// Deal damage to Harry
		PlayerHarry.TakeDamage(grenadeDamage,None,vect(0.0,0.0,0.0),vect(0.0,0.0,0.0),'None');
	}

	// For each fireball we want to spawn (10 of them)
	for(i = 0; i < NumFireballs; i++)
	{
		// Rotate fireball around a full rotation and add random variation
		rotate_fireball.Yaw 				= (65536 / NumFireballs) * I + Rand(10000);

		// Set fireball location 5 units above our current position
		fireball_locn 						= Location + vect(0.00,0.00,5.00);

		// Spawn a small fireball
		smallFire 							= Spawn(Class'spellFireSmall',Owner,,fireball_locn,rotate_fireball);

		// Set the new fireball's damage to our desired small damage
		smallFire.iDamage 					= smallDamage;

		// Set the new fireball's gravity to our desired explosion gravity
		smallFire.GrenadeExplosionGravity 	= GrenadeExplosionGravity;
	}
	
	// Set current location to the old location
	currentLoc = OldLocation;

	// Set current rotation to our rotation
	currentRot = Rotation;

	// Shutdown the grenade particles
	fxGrenadeParticleEffect.Shutdown();

	// Destroy self, not sure why we're calling before spawning the center
	Destroy();
	
	// There used to be an empty for loop here, I removed it for cleanliness. See older version if needed.

	// Spawn the grenade center
	centerFire 			= Spawn(Class'FireballGrenadeCenter',Owner,,currentLoc,currentRot);

	// Set the grenade center's damage
	centerFire.iDamage 	= iDamage;
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