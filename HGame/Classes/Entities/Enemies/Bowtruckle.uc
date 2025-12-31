//==========================================
//
//	Bowtruckle. Initially rewritten 11/27/2025 - 12/02/2025
//
//==========================================

class Bowtruckle extends HEnemy;

var(Combat) float TauntProbability;				// Moca: How likely is the Bowtruckle to taunt? 1.0 means always taunts first, 0.0 never taunts, 0.5 is a 50/50 chance, etc.

var(Sound) Sound TauntSound;					// Moca: Sound to play on taunt
var(Sound) Sound AttackSound;					// Moca: Sound to play on attack
var(Sound) Sound ThrowSound;					// Moca: Sound to play on throw
var(Sound) Sound HurtSound;						// Moca: Sound to play when hurt

// Twig
var(Combat) class<HProjectile> ObjectToThrow;	// Moca: What object should Bowtruckle throw at its target? Normally this is its twig projectile

var(Combat) int TwigDamage;						// Moca: How much damage should twigs/whatever thrown object do to its target?

var(Combat) float TwigAccuracyFar;				// Moca: How accurate is our aim when aiming at a far off target? 1.0 means perfect accuracy, 0.0 means horrible accuracy
var(Combat) float TwigAccuracyNear;				// Moca: How accurate is our aim when aiming at a nearby target? 1.0 means perfect accuracy, 0.0 means horrible accuracy

var(Combat) float TwigScale;					// Moca: What size scale should the twig be? 2.0 = double size, etc. This also affects collision size
var(Combat) float TwigThrowDelay;				// Moca: How long do we have to wait before throwing another twig?

var(Combat) float TwigThrownTime;				// Moca: How long does it take the twig to land?
var(Combat) float TwigGravity;					// Moca: What gravity force should be applied to the twig?

var(Combat) float TwigNearMaxRange;				// Moca: Maximum range for TwigAccuracyNear to be used instead of TwigAccuracyFar
var(Combat) float ChargeRange;					// Moca: Maximum range where the Bowtruckle will charge at Harry instead of throwing? Should be lower than TwigCloseRange

var HProjectile ThrownObj;						// Moca: Actor reference to the thrown object (twig)

// Death
var(Combat) class<Actor> DroppedObject;
var(Combat) int DroppedObjectAmount;
var(Combat) float DroppedObjectRangeMin;			// Moca: Minimum range from the death position the dropped item can fly out to
var(Combat) float DroppedObjectRangeMax;			// Moca: Maximum range from the death position the dropped item can fly out to

// Wander
var(Movement) float MinWanderDelay;				// Moca: Minimum time in seconds to wait before wandering to a new spot
var(Movement) float MaxWanderDelay;				// Moca: Maximum time in seconds to wait before wandering to a new spot

// FX
var(Display) class<ParticleFX> TwigFX;			// Moca: What particles to attach to the thrown object? Leave blank to use the thrown class' default particles



function SpawnTwig()
{
	local Vector ObjSize;

	ThrownObj = Spawn(ObjectToThrow,self);

	if ( ThrownObj == None )
	{
		return;
	}

	ObjSize = vect(CollisionRadius,CollisionHeight,CollisionWidth);

	ThrownObj.SetCollision(False,False,False);
	ThrownObj.SetCollisionSize(ObjSize.X * TwigScale, ObjSize.Y * TwigScale, ObjSize.Z * TwigScale);
	ThrownObj.DrawScale = TwigScale;
	ThrownObj.bRotateToDesired = False;
	ThrownObj.AttachToOwner('bip01 R Hand');
	HeldActor = ThrownObj;
}

function ThrowTwig()
{
	local Vector ThrowPosition;
	local float DistanceFromHarry;

	DistanceFromHarry = GetDistanceFromActor(PlayerHarry);

	if ( DistanceFromHarry > TwigNearMaxRange )
	{
		ThrowPosition = ComputeTrajectoryByTime(ThrownObj.Location,PlayerHarry.Location,TwigThrownTime,TwigGravity);
		ThrowPosition = GetNearbyLocationWithSpread(ThrowPosition,TwigAccuracyFar);
	}
	else if ( DistanceFromHarry > ChargeRange )
	{
		ThrowPosition = ComputeTrajectoryByTime(ThrownObj.Location,PlayerHarry.Location,TwigThrownTime,TwigGravity);
		ThrowPosition = GetNearbyLocationWithSpread(ThrowPosition,TwigAccuracyNear);
	}
	else
	{
		GotoState('stateChaseHarry');
		return;
	}

	ThrowObject(ThrowPosition,True,True);
}

function DropBark()
{
	local int i;
	local Actor A;
	local float Angle;
	local float Length;

	for ( i = 0; i < DroppedObjectAmount; i++ )
	{
		A = Spawn(DroppedObject,,,Location + vect(0,0,30),RotRand());
		Angle = RandRange(0.0,6.0);

		A.Velocity.X = Length * Cos(Angle);
		A.Velocity.Y = Length * Sin(Angle);
		A.Velocity.Z = 100.0 + FRand() * 100;
	}
}

function ThrowObject(Vector ThrowVelocity, bool bCollideActors, bool bCollideWorld)
{
	HeldActor.SetPhysics(PHYS_Falling);
	HeldActor.AnimBone = 0;
	HeldActor.SetCollision(bCollideActors);
	HeldActor.bCollideWorld = bCollideWorld;
	HeldActor.Velocity = ThrowVelocity;
	HeldActor.SetOwner(None);
	HeldActor = None;
}

function PlayTauntSound()
{
	if ( TauntSound != None )
	{
		PlaySound(TauntSound, SLOT_Talk,RandRange(0.75,1.0), [Pitch] RandRange(0.8,1.2));
	}
}

function PlayAttackSound()
{
	if ( AttackSound != None )
	{
		PlaySound(AttackSound, SLOT_Talk,RandRange(0.75,1.0), [Pitch] RandRange(0.8,1.2));
	}
}

function PlayThrowSound()
{
	if ( ThrowSound != None )
	{
		PlaySound(ThrowSound, SLOT_Talk,RandRange(0.75,1.0), [Pitch] RandRange(0.8,1.2));
	}
}

function PlayHurtSound()
{
	if ( HurtSound != None )
	{
		PlaySound(HurtSound, SLOT_Talk,RandRange(0.75,1.0), [Pitch] RandRange(0.8,1.2));
	}
}

function DoAttack()
{
	local float RandFloat;
	local Vector DistanceFromHarry;

	DistanceFromHarry = GetDistanceFromActor(PlayerHarry);

	if ( DistanceFromHarry > SightRadius )
	{
		GotoState('stateIdle');
		return;
	}

	if ( DistanceFromHarry > ChargeRange )
	{
		RandFloat = FRand();

		if ( TauntProbability >= RandFloat )
		{
			GotoState('stateTaunt');
		}
		else
		{
			Gotostate('stateThrowTwig');
		}
	}
	else
	{
		GotoState('stateChaseHarry');
	}
}

state stateChaseHarry
{
	begin:
		if ( bSeesHarry )
		{
			Goto('freechase');
		}
		else
		{
			Goto('navchase');
		}
	
	freechase:
		while ( bSeesHarry )
		{
			MoveToward(PlayerHarry);
			SleepForTick();
		}

		if ( !bFollowUpSearch )
		{
			Goto(PostChaseState);
		}
	
	navchase:
		while ( IsSuspicious() )
		{
			NextNavP = NavigationPoint(FindPathToward(PlayerHarry));
			MoveToward(DestNavP);

			SleepForTick();

			if ( bSeesHarry )
			{
				Goto('freechase');
			}
		}
}

auto state stateIdle
{
	loop:
		MoveTo(GetRandomNearbyLocation(HomeLocation,,true));

		Sleep(RandRange(MinWanderDelay,MaxWanderDelay));

		if ( MaxDistanceFromHome > 0.0 && GetDistanceFromVector(HomeLocation) > MaxDistanceFromHome )
		{
			NextState = 'stateIdle';
			GotoState('stateGoHome');
		}

		SleepForTick();
}

state stateTaunt
{
	begin:
		StopMoving();
		TurnToward(PlayerHarry);
		PlayTauntSound();
		PlayAnim('Taunt');
		FinishAnim();
		GotoState('stateIdle');
}

state stateAttackHarry
{
	begin:
		StopMoving();
		TurnToward(PlayerHarry);
		PlayAttackSound();
		PlayAnim('React');
		FinishAnim();
		MoveTo(GetRandomNearbyLocation(Location,,true));
		SleepForTick();
		Gotostate('stateIdle');
}

state stateThrowTwig
{
	begin:
		StopMoving();
		TurnToward(PlayerHarry);
		SpawnTwig();
		PlayThrowSound();
		PlayAnim('Attack');
		Sleep(0.5);

		ThrowTwig();

		Sleep(ThrowDelay);

		GotoState('stateIdle');
}

state stateDie
{
	begin:
		PlayHurtSound();
		StopMoving();
		SetVulnerableSpell(None);
		Spawn(DiedFX,,,Location);

		SpitOutActor(DroppedObject,DroppedObjectAmount);

		if ( HeldActor != None )
		{
			HeldActor.Destroy();
		}

		bHidden = True;

		Sleep(GetSoundDuration(HurtSound));
		GotoState('stateDestroy');
}




defaultproperties
{
	SpellInteractions(0)=(SpellClass=Class'spellDiffindo',SpellInteraction=INT_Damage)
	DamageToDeal=1

	TauntProbability=0.5

	TauntSound=MultiSound'BOW_Taunt'
	AttackSound=MultiSound'BOW_Attack'
	ThrowSound=MultiSound'BOW_Surprise'
	HurtSound=MultiSound'BOW_Ouch'

	ObjectToThrow=class'BowtruckleTwig'

	TwigDamage=2

	TwigAccuracyFar=0.5
	TwigAccuracyNear=0.5

	TwigScale=1.0
	TwigThrowDelay=1.5

	TwigThrownTime=1.5
	TwigGravity=-256.0

	TwigNearMaxRange=256.0
	ChargeRange=128.0

	DroppedObject=Class'WiggentreeBark'
	DroppedObjectAmount=1
	DroppedObjectRangeMin=30.0
	DroppedObjectRangeMax=60.0

	MinWanderDelay=2.0
	MaxWanderDelay=3.0

	TwigFX=Class'HPParticle.Sticks1'

	GroundSpeed=220.0
	SightRadius=512.0
	SpellVulnerableTo=Class'spellDiffindo'
	Mesh=SkeletalMesh'HPModels.skBowtruckleMesh'
	Drawscale=1.2
	CollisionRadius=18.0
	CollisionHeight=42.0

	PostChaseState=stateGoHome
}