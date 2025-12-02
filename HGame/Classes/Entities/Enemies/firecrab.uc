//==========================================
//
//	Firecrab. Initially rewritten 11/25/2025
//
//==========================================

class Firecrab extends HEnemy;

//-------------------------------------
// Combat
//-------------------------------------
var(Combat) class<HProjectile> ProjectileToFire;

var(Combat) bool bNoCharge;

var(Combat) float FireRange;
var(Combat) float MinFireDelay;
var(Combat) float MaxFireDelay;
var(Combat) float ChargeDuration;

var(Combat) int ShotsPerCharge;
var(Combat) int MinAccuracy;
var(Combat) int MaxAccuracy;

var int CurrentShots;
var float FireCooldown;
var HProjectile FiredProjectile;

//-------------------------------------
// Movement
//-------------------------------------
var(Movement) vector FallingRotationRate;
var(Movement) float MinOnBackTime;
var(Movement) float MaxOnBackTime;

var bool bSpeen;

//-------------------------------------
// Sound
//-------------------------------------
var(Sound) bool bDoTheRoar;
var(Sound) Sound RoarSound;
var(Sound) Sound PreAttackSound;
var(Sound) Sound AttackSound;
var(Sound) Sound HitSound;
var(Sound) Sound HurtSound;
var(Sound) Sound FlipSound;
var(Sound) Sound LandSound;



//-------------------------------------
// Events
//-------------------------------------
event PostBeginPlay()
{
	Super.PostBeginPlay();
	DefaultRotRate = RotationRate;
}

event Landed (Vector HitNormal)
{
	Super.Landed(HitNormal);

	if ( (FallDistance > 25) )
	{
		Print("Fall distance greater than 25. Stay Flipped");
		PlayLandSound();
		GotoState('stateStayFlipped');
	}

	Print("How far did I fall : " $ string(FallDistance));
}

//-------------------------------------
// Audio
//-------------------------------------
function PlayHitSound()
{
	if ( PushedSound != None )
	{
		PlaySound(PushedSound, SLOT_Interact,RandRange(0.75,1.0), [Pitch] RandRange(0.8,1.2));
	}

	if ( HurtSound != None )
	{
		PlaySound(PushedSound, SLOT_Talk,RandRange(0.75,1.0), [Pitch] RandRange(0.8,1.2));
	}
}

function PlayFlipSound()
{
	if ( FlipSound != None )
	{
		PlaySound(FlipSound, SLOT_Interact,RandRange(0.75,1.0), [Pitch] RandRange(0.8,1.2));
	}
}

function PlayLandSound()
{
	if ( LandSound != None )
	{
		PlaySound(LandSound, SLOT_Interact,RandRange(0.75,1.0), [Pitch] RandRange(0.8,1.2));
	}
}

function PlayRoarSound()
{
	if ( RoarSound != None )
	{
		PlaySound(RoarSound, SLOT_Talk,RandRange(0.75,1.0), [Pitch] RandRange(0.8,1.2));
	}
}

function PlayPreAttackSound()
{
	if ( PreAttackSound != None )
	{
		PlaySound(PreAttackSound, SLOT_Interact,RandRange(0.75,1.0), [Pitch] RandRange(0.8,1.2));
	}
}

function PlayAttackSound()
{
	if ( AttackSound != None )
	{
		PlaySound(AttackSound, SLOT_Interact,RandRange(0.75,1.0), [Pitch] RandRange(0.8,1.2));
	}
}

//-------------------------------------
// Interaction
//-------------------------------------
function HitByThrownObject (int Damage, HPawn InstigatedBy, Vector HitLocation, Vector Momentum, name ObjectType)
{
	CurrentSpellHitCount = 0.0;
	CurrentPushDirection = GetPushDirection(HitLocation,Momentum);
	GotoState('statePushed');
}


//-------------------------------------
// Falling
//-------------------------------------
function EnableSpeen()
{
	bRotateToDesired = False;

	Rotation.Roll += NINETY_DEG;

	LoopAnim('onback');

	RotationRate = FallingRotationRate;
	bFixedRotationDir = True;
}

function DisableSpeen()
{
	RotationRate = MapDefault.RotationRate;
	bFixedRotationDir = MapDefault.bFixedRotationDir;
	bRotateToDesired = MapDefault.bRotateToDesired;
	GotoState('stateFlipped');
}

function Vector GetLedgePushDir()
{
    local Vector OutDir;
	local Vector End;
	local Vector HitLocation;
	local Vector HitNormal;

    OutDir = GetForwardVector();
    End = Location + OutDir * 50;

    if ( !FastTrace(End + vect(0,0,-50), End) )
    {
        HitLocation = End;
        return GetPushDirection(HitLocation);
    }

    return vect(0,0,0);
}

state stateFalling
{
	event BeginState()
	{
		HighestZ = Location.Z;
		EnableSpeen();
		DisableAttack();
	}

	event HitWall (Vector HitNormal, Actor Wall)
	{
		Super.HitWall(HitNormal,Wall);
		Acceleration = vect(0,0,0);
		Velocity = vect(0,0,0);
	}
}

//-------------------------------------
// Flipped States
//-------------------------------------
state stateStunned
{
	event BeginState()
	{
		DisableAttack();
	}

	begin:
		SetVulnerableSpell(GetInteractionSpell(INT_Push));
		
		PlayHitSound();

		if ( PushedAnim != '' )
		{
			PlayAnim(PushedAnim);
		}

		if ( OnALedge(Location) )
		{
			GotoState('stateFallOverLedge');
		}
		else
		{
			FinishAnim();
			PlayLandSound();
			GotoState('stateFlipped');
		}
}

state statePushed
{
	event BeginState()
	{
		DisableAttack();
	}

	begin:
		Acceleration = CurrentPushDirection;
		Velocity = CurrentPushDirection;

		PlayHitSound();

		if ( PushedAnim != '' )
		{
			PlayAnim(PushedAnim);
			FinishAnim();
			PlayLandSound();
		}
		else
		{
			Sleep(1.0);
		}

		if ( OnALedge(Location) )
		{
			GotoState('stateFallOverLedge');
		}
		else
		{
			GotoState('stateFlipped');
		}
}

state stateFallOverLedge
{
	event BeginState()
	{
		DisableAttack();
	}

	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		if ( Physics == PHYS_Falling )
		{
			GotoState('stateFalling');
		}

		MoveSmooth(GetLedgePushDir() * DeltaTime * 2);
	}
}

state stateStayFlipped
{
	begin:
		DisableAttack();
		SetVulnerableSpell(GetInteractionSpell(INT_Push));
		LoopAnim('onback');
}

state stateUnflip
{
	begin:
		SetVulnerableSpell(GetInteractionSpell(INT_Stun));

		PlayAnim('recover');

		while ( AnimFrame < 0.74 )
		{
			SleepForTick();
		}

		PlayLandSound();

		FinishAnim();
		PlayAnim('look');
		FinishAnim();
		EnableAttack();
		GotoState('statePatrol');
}

//-------------------------------------
// Attack
//-------------------------------------
function bool CanAttack()
{
	return AttitudeToPlayer == ATTITUDE_Hate && Physics == PHYS_Walking;
}

function DoAttack()
{
	GotoState('stateAlerted');
}

function AimBooty()
{
	SetRotation(GetBootyDirection(true));
}

function rotator GetBootyDirection(optional bool bYawOnly)
{
	local rotator NewRot;
	NewRot = rotator(GetDirectionAwayFromActor(HatedTarget));

	if ( bYawOnly )
	{
		NewRot.Pitch = 0;
		NewRot.Roll = 0;
	}

	return NewRot;
}

state stateAlerted
{
	begin:
		StopMoving();

		if ( bDoTheRoar )
		{
			PlayRoarSound();
			PlayAnim('roar');
			FinishAnim();
		}

		GotoState('stateAiming');
}

state stateAiming
{
	event BeginState()
	{
		if ( bNoCharge )
		{
			GotoState('stateFire');
		}
	}

	event Tick(float DeltaTime)
	{
		AimBooty();
	}

	begin:
		PlayPreattackSound();
		PlayAnim('preattack');

		if ( ChargeDuration == 0 )
		{
			FinishAnim();
		}
		else
		{
			Sleep(ChargeDuration);
		}

		if ( bSeesHarry )
		{
			GotoState('stateFire');
		}
}

state stateFire
{
	function FireWeapon()
	{
		PlayAnim('Attack');
		CurrentShots++;
		FiredProjectile = Spawn(ProjectileToFire);
		FiredProjectile.MinAccuracy = MinAccuracy;
		FiredProjectile.MaxAccuracy = MaxAccuracy;
		FiredProjectile.TargetActor = HatedTarget;
	}

	begin:
		AimBooty();

		FireWeapon();

		FireCooldown = RandRange(MinFireDelay,MaxFireDelay);

		if ( FireCooldown <= 0.0001 )
		{
			FinishAnim();
		}
		else
		{
			Sleep(FireCooldown);
		}

		if ( CurrentShots > ShotsPerCharge )
		{
			CurrentShots = 0;

			if ( bSeesHarry )
			{
				if ( bCanStrafe )
				{
					GotoState('stateStrafe');
				}

				GotoState('stateAiming');
			}
			
			GotoState('statePatrol');
		}

		Goto('begin');
}

state stateStrafe
{
	begin:
		GotoState('stateAiming');
}

//-------------------------------------
// Cutscene
//-------------------------------------
state stateCutCapture
{
	event BeginState()
	{
		GotoState('statePatrol');
	}
}




//-------------------------------------
// Default Properties
//-------------------------------------
defaultproperties
{
    RoarSound=Sound'HPSounds.Critters_sfx.firecrab_roar'
    AttackSound=Sound'HPSounds.Critters_sfx.firecrab_attack'
	HurtSound=Sound'HPSounds.Critters_sfx.firecrab_ouch_multi'

	ProjectileToFire=class'spellFireSmall'
    FireRange=400.00
	MinFireDelay=0.5
	MaxFireDelay=1.25

	SpellInteractions(0)=(SpellClass=Class'spellRictusempra',SpellInteraction=INT_Stun)
	SpellInteractions(1)=(SpellClass=Class'spellFlipendo',SpellInteraction=INT_Push)

	PushedAnim=flip2back
	PushedSound=Sound'HPSounds.Critters_sfx.firecrab_hit'
	FlipSound=Sound'HPSounds.Critters_sfx.firecrab_unflip_multi'
	LandSound=Sound'HPSounds.Critters_sfx.SPI_large_LandOnBack'

	FootstepSoundSet=class'FootstepFirecrab'
	StepDistance=8.0
	StepThreshold=4.0

	bAffectedByCarriedActor=True

    GroundSpeed=60.00

    AirSpeed=60.00

    AccelRate=4000.00

    SightRadius=600.00

    PeripheralVision=1.00

    BaseEyeHeight=20.00

    EyeHeight=20.00

    IdleAnimName=breath

    RunAnimName=Walk

    SpellVulnerableTo=class'spellRictusempra'

    Mesh=SkeletalMesh'HPModels.skfirecrabMesh'

	TransientSoundRadius=10000

    DrawScale=2.00

    AmbientGlow=110

    Mass=130.00

    RotationRate=(Pitch=100000,Yaw=100000,Roll=100000)

	FallingRotationRate=(Pitch=2500,Yaw=5000,Roll=4000)
}
