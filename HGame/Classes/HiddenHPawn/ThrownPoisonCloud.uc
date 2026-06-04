//==========================================================================//
// ThrownPoisonCloud.
//
// Poison cloud emitted from a thrown Horklump that damages Harry.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class ThrownPoisonCloud extends HiddenHPawn;

//= Constants =//
const BOOL_DEBUG_AI= false;	// Should we do debug logging

//= General Variables =//
var bool bCanBeThrown;	// Can we be thrown
var bool bCanBeTouched;	// Can we be touched
var bool bTouch;		// Are we being touched
var float fLifetime;	// Our lifetime
var float timeSafe;		// Never used


//=========
// Events
//=========

// Called before gameplay starts
event PreBeginPlay()
{
	// Calls parent behavior
	Super.PreBeginPlay();

	// Disable collision
	SetCollision(False,False,False);
}

// Called after gameplay starts
event PostBeginPlay()
{
	local HPawn Pawn;
	local Vector vTargetDir;

	// Set lifetime timer
	SetTimer(fLifetime,False);

	// For all HPawn actors
	foreach AllActors(Class'HPawn',Pawn)
	{
		// If pawn is Harry and we can be touched
		if ( (Pawn == PlayerHarry) && (bCanBeTouched) )
		{
			// Make it so we can't be touched
			bCanBeTouched = False;

			// If we're not in a cutscene
			if ( !baseHUD(PlayerHarry.myHUD).bCutSceneMode )
			{
				// If in debug mode, log that we're dealing damage
				if ( BOOL_DEBUG_AI )
				{
					PlayerHarry.ClientMessage(" Take Damage  to Harry Instigated By : " $ string(self));
				}

				// Deal damage
				Pawn.TakeDamage(1,Pawn(Owner),Location,Velocity * 1,'PoisonCloud');
			}
		}

		// If we can be thrown
		if ( bCanBeThrown )
		{
			// If we're not in a cutscene
			if ( !baseHUD(PlayerHarry.myHUD).bCutSceneMode )
			{
				// Calculate direction from pawn to self
				vTargetDir = Location - Pawn.Location;

				// If direction size is less than our enlarged collision radius plus the pawn collision radius
				if ( VSize(vTargetDir) < CollisionRadius * 4 + Pawn.CollisionRadius )
				{
					// If in debug mode, log that we've hit
					if ( BOOL_DEBUG_AI )
					{
						PlayerHarry.ClientMessage(string(self) $ " Hit " $ string(Pawn));
					}

					// Tell pawn its been hit by PoisonCloud
					Pawn.HitByThrownObject(1,Pawn,Location,Velocity * 1,'PoisonCloud');
				}
			}
		}
	}

	// Play hit sound
	PlaySound(Sound'spell_hit',SLOT_Interact,1.0,False,2000.0,1.0);
}

// On timer time out, destroy self
event Timer()
{
	Destroy();
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bTouch=True

	fLifetime=1.50

	bCanBeThrown=True

	bCanBeTouched=True

	attachedParticleClass(0)=Class'HPParticle.Hork04'

	DrawType=DT_None

	CollisionRadius=25.00

	CollisionHeight=32.00

	bCollideWorld=True
}