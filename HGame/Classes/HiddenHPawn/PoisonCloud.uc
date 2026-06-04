//==========================================================================//
// PoisonCloud.
//
// Poison cloud that damages Harry after a Horklump emits gas.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class PoisonCloud extends HiddenHPawn;

//= Constants =//
const BOOL_DEBUG_AI= false;	// Should we print debug info

//= General Variables =//
var bool bCanBeThrown;		// Can we be thrown
var bool bCanBeTouched;		// Can we be touched
var bool bTouch;			// Are we being touched
var float fLifetime;		// Our lifetime
var float timeSafe;			// Never used
var float waitTime;			// Time we've been waiting
var float collideRadius;	// Our collision radius
var float iDamage;			// How much damage to deal
var float DamageInterval;	// How often we can damage


//=========
// Events
//=========

// Called after gameplay begins, sets lifetime timer
event PostBeginPlay()
{
	SetTimer(fLifetime,False);
}

// On tick
event Tick (float DeltaTime)
{
	// Call parent behavior
	Super.Tick(DeltaTime);

	// Increment our waiting time
	waitTime += DeltaTime;

	// If wait time exceeds the damage interval
	if ( waitTime > DamageInterval )
	{
		// Reset wait time
		waitTime = 0.0;

		// Allow us to be touched
		bCanBeTouched = True;
	}

	// Dunno why KW did it this way when they could've just set a flag on Touch and Untouch
	// If the distance between ourselves and Harry is less than or equal to Harry's radius plus our radius
	if ( VSize(Location - PlayerHarry.Location) <= PlayerHarry.CollisionRadius + CollisionRadius )
	{
		// If we can be touched
		if ( bCanBeTouched )
		{
			// Make it so we can't be touched
			bCanBeTouched = False;

			// If we're not in a cutscene, deal damage
			if ( !baseHUD(PlayerHarry.myHUD).bCutSceneMode )
			{
				PlayerHarry.TakeDamage(iDamage,Pawn(Owner),Location,Velocity * 1,'PoisonCloud');
			}
		}
	}
}

// Called on timer time out, destroys self
event Timer()
{
	Destroy();
}

// Called when touched by actor
event Touch (Actor Other)
{
	local HPawn HPawnHit;

	// If other is not Harry and we can be touched AND other is a HPawn AND other is not a PoisonCloud AND other is not a ThrownPoisonCloud AND other is not a HorklumpsHead AND other is not a HorklumpsStem AND we can be thrown
	if ( !((Other == PlayerHarry) && (bCanBeTouched)) && Other.IsA('HPawn') &&  !Other.IsA('PoisonCloud') &&  !Other.IsA('ThrownPoisonCloud') &&  !Other.IsA('HorklumpsHead') &&  !Other.IsA('HorklumpsStem') && (bCanBeThrown) )
	{
		// If we're not in a cutscene
		if ( !baseHUD(PlayerHarry.myHUD).bCutSceneMode )
		{
			// Set hit HPawn to other
			HPawnHit = HPawn(Other);

			// If in debug mode, log what we hit
			if ( BOOL_DEBUG_AI )
			{
				PlayerHarry.ClientMessage(string(self) $ " Hit something : " $ string(HPawnHit));
			}

			// Tell HPawn that it was hit by a PoisonCloud
			HPawnHit.HitByThrownObject(1,HPawnHit,Location,Velocity * 1,'PoisonCloud');
		}
	}

	// Play hit sound
	PlaySound(Sound'spell_hit',SLOT_Interact,1.0,False,2000.0,1.0);
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


//========
// Audio
//========

// Play a cloud sound
function playCloudSound()
{
	local int randNum;
	local Sound cloudSound;

	// Get a random int between 0 and 5
	randNum = Rand(6);

	// Switch cloud sound based on random number
	switch (randNum)
	{
		case 0:
			cloudSound = Sound'ss_COS_venomland_01E';
			break;
		case 1:
			cloudSound = Sound'ss_COS_venomland_02E';
			break;
		case 2:
			cloudSound = Sound'ss_COS_venomland_03E';
			break;
		case 3:
			cloudSound = Sound'ss_COS_venomland_04E';
			break;
		case 4:
			cloudSound = Sound'ss_COS_venomland_05E';
			break;
		case 5:
			cloudSound = Sound'ss_COS_venomland_06E';
			break;
		default:
			cloudSound = Sound'ss_COS_venomland_01E';
			break;
	}

	// Play the selected sound
	PlaySound(cloudSound,SLOT_None,RandRange(0.6,1.0),,3000.0,RandRange(0.5,1.6),,False);
}


//=========
// States
//=========

// Default starting state
auto state StartHere
{
	// Begin label
	begin:
		// Set collision size to the collide radius and the default collision height
		SetCollisionSize(collideRadius,Default.CollisionHeight);

		// Play a cloud sound
		playCloudSound();
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bTouch=True

	fLifetime=1.50

	bCanBeTouched=True

	iDamage=1.00

	DamageInterval=0.50

	attachedParticleClass(0)=Class'HPParticle.Hork01'

	DrawType=DT_None

	CollisionRadius=35.00

	CollisionHeight=32.00

	bCollideActors=True

	bCollideWorld=True
}