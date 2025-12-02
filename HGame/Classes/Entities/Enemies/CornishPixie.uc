//==========================================
//
//	CornishPixie. Initially rewritten 12/02/2025
//
//==========================================

class CornishPixie extends HEnemy;

var(Sound) Sound ChatterSound;
var(Sound) Sound AttackSound;
var(Sound) Sound HurtSound;
var(Sound) Sound BiteSound;
var(Sound) Sound WingLoopSound;

var() bool bWaitForTrigger;		// Moca: Should this Pixie wait to be triggered before flying? 

var() float BiteRadius;			// Moca: Max distance in which we can bite Harry
var() float MaxChaseDistance;	// Moca: If Harry gets further than this, pixie stops chasing

var() int HitsToDie;			// Moca: How many hits does it take to kill this pixie?

var float FlyDuration;

var Vector TempHome;

var ParticleFX FlyingParticles;

event PreBeginPlay()
{
	super.PreBeginPlay();

	if ( FlyDuration <= 0.0 )
	{
		FlyDuration = Default.AirSpeed / AirSpeed;
	}

	FlyingParticles = Spawn(Class'HPParticle.PixieFlying',self,,Location);
	FlyingParticles.bEmit = False;
}

event Landed(vector HitNormal)
{
	Super.Landed(HitNormal);
	GotoState('stateHitGround');
}

event Trigger(Actor Other, Pawn EventInstigator)
{
	super.Trigger(Other, EventInstigator);

	GotoState('stateLoopSplinePath');
}

function Yap()
{
	if ( ChatterSound != None && IsIsState('stateLoopSplinePath') )
	{
		PlaySound(ChatterSound, SLOT_Talk,RandRange(0.75,1.0), [Pitch] RandRange(0.8,1.2));

		SetTimer(RandRange(1.0,6.0),false,'Yap');
	}
}

function PlayAttackSound()
{
	if ( AttackSound != None )
	{
		PlaySound(AttackSound, SLOT_Talk,RandRange(0.75,1.0), [Pitch] RandRange(0.8,1.2));
	}
}

function PlayHurtSound()
{
	if ( HurtSound != None )
	{
		PlaySound(HurtSound, SLOT_Talk,RandRange(0.75,1.0), [Pitch] RandRange(0.8,1.2));
	}
}

function PlayBiteSound()
{
	if ( BiteSound != None )
	{
		PlaySound(BiteSound, SLOT_Interact,RandRange(0.75,1.0), [Pitch] RandRange(0.8,1.2));
	}
}

function ToggleFlyingParticles(bool bEnableParticles)
{
	FlyingParticles.bEmit = bEnableParticles;
}

function bool CanAttack()
{
	return AttitudeToPlayer == ATTITUDE_Hate && bIsHuntingHarry && bSeesHarry && !IsInState('stateLoopSplinePath') && ( CurrentSuspicion >= RequiredSuspicion );
}

function DoAttack()
{
	GotoState('stateChaseHarry');
}

function GetTempHome()
{
	local InterpolationPoint NewHome;
	NewHome = GetNearestActorOfClass(Class'InterpolationPoint');

	if ( NewHome != None )
	{
		TempHome = NewHome.Location;
	}
	else
	{
		TempHome = HomeLocation;
	}
}

auto state stateIdle
{
	begin:
		if ( !bWaitForTrigger )
		{
			SleepForTick();
			GotoState('stateLoopSplinePath');
		}
}

state stateLoopSplinePath
{
	event BeginState()
	{
		LoopAnim('Fly');
		AmbientSound = WingLoopSound;
		ToggleFlyingParticles(true);
		FollowSplinePath();
		SetTimer(RandRange(1.0,6.0),false,'Yap');
	}

	event EndState()
	{
		DestroyControllers();
		SetPhysics(PHYS_Flying);
		bCollideWorld = True;
		ToggleFlyingParticles(false);
	}
}

state stateChaseHarry
{
	event BeginState()
	{
		DoFlyToActor(PlayerHarry,vect(0,0,0),MOVE_TYPE_LINEAR,FlyDuration,true);
	}

	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		local float DistFromHarry;

		DistFromHarry = GetDistanceFromActor(PlayerHarry);

		if ( DistFromHarry > MaxChaseDistance )
		{
			GotoState('stateGoHome');
		}

		if ( DistFromHarry <= BiteRadius )
		{
			GotoState('stateBite');
		}
	}
}

state stateBite
{
	begin:
		PlayAnim('Attack',3.0);
		sleep(0.3);
		PlayBiteSound();
		Sleep(0.1);
		PlayerHarry.TakeDamage(DamageToDeal,Self,Location,Velocity,'Pixie');
		GotoState('stateGoHome');
}

state stateGoHome
{
	event BeginState()
	{
		DoFlyTo(GetTempHome(),MOVE_TYPE_LINEAR,FlyDuration,true);
	}

	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		if ( GetDistanceFromVector(TempHome) <= 32.0 )
		{
			GotoState('stateLoopSplinePath');
		}
	}
}

state stateStunned
{
	event BeginState()
	{
		if ( TotalSpellHitCount >= HitsToDie )
		{
			GotoState('stateFalling');
		}
	}

	begin:
		DestroyControllers();
		StopMoving();
		PlayHurtSound();
		PlayAnim('stun');
		FinishAnim();

		GotoState(LastValidState);
}

state stateFalling
{
	event Timer()
	{
		GotoState('stateHitGround');
	}

	begin:
		LoopAnim('stunspin');
		Sleep(0.15);
		bCollideWorld = True;
		SetPhysics(PHYS_Walking);
		SetTimer(10.0,false);
}

state stateHitGround
{
	begin:
		PlaySound(Sound'horklump_mushroom_head_explode');
		Spawn(Class'PixieExplode',,,Location);
		bHidden = True;
		Sleep(0.1);
		GotoState('stateDestroy');
}

defaultproperties
{
	ChatterSound=MultiSound'PIX_Talk'
	AttackSound=MultiSound'PIX_Attack'
	HurtSound=MultiSound'PIX_Ouch'
	BiteSound=MultiSound'PIX_Bite'
	WingLoopSound=Sound'HPSounds.Critters_sfx.PIX_wingflap_loop'

	BiteRadius=50.0
	MaxChaseDistance=800.0

	HitsToDie=1

	DamageToDeal=2

	SpellInteractions(0)=(SpellClass=Class'spellRictusempra',SpellInteraction=INT_Stun)
	IdleAnimations(0)=Fly
	
	WalkAnimName=Fly
	RunAnimName=Fly

	SightRadius=400.0
	AirSpeed=120.0

	bBlockActors=False
	CollisionHeight=20.0
	CollisionRadius=30.0
	SoundRadius=75.0

	Physics=PHYS_Flying
}