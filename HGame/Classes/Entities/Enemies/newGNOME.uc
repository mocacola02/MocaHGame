//==========================================
//
//	GNOME. Initially rewritten 12/03/2025
//
//==========================================

class GNOME extends HEnemy;

var() class<HCollectible> GoodieClass;	// Moca: What collectible class should GNOME seek out
var() int MaxGoodies;					// Moca: Maximum number of Goodies (aka beans by default) we can carry

var() int MinGoodiesToSteal;			// Moca: Minimum number of Goodies that we will make Harry drop on attack
var() int MaxGoodiesToSteal;			// Moca: Maximum number of Goodies that we will make Harry drop on attack

var int CurrentGoodies;

var(Sound) Sound GetOffSound;
var(Sound) Sound HurtSound;
var(Sound) Sound TalkSound;
var(Sound) Sound DieSound;
var(Sound) Sound ThrownSound;
var(Sound) Sound CrashSound;

// Animations
var(Animation) Name CarryIdle;
var(Animation) Name CarryTaunt1;
var(Animation) Name CarryTaunt2;

var(Animation) Name DownIdle;
var(Animation) Name DownDizzy;

var(Animation) Name Eat;
var(Animation) Name EatLoop;
var(Animation) Name GetUp;
var(Animation) Name Angry;
var(Animation) Name KnockedBack;
var(Animation) Name GrabGoodie;

var(Animation) Name RunCarryObj;
var(Animation) Name RunAttack;
var(Animation) Name RunScared;

var(Animation) Name TauntJump;
var(Animation) Name TauntAss;

var(Animation) Name AttackBite;
var(Animation) Name Throw;



event PreBeginPlay()
{
	super.PreBeginPlay();

	if ( MinGoodiesToSteal > MaxGoodiesToSteal )
	{
		MaxGoodiesToSteal = MinGoodiesToSteal;
	}
}

event Bump(Actor Other)
{
	super.Bump(Other);

	if ( Other == PlayerHarry && IsInState('stateChaseHarry') )
	{
		MugHarry();
	}
}

event Landed(vector HitNormal)
{
	super.Landed(HitNormal);
	StopMoving();
	SetCollisionSize(MapDefault.CollisionRadius,MapDefault.CollisionHeight);
	GotoState('stateStunned');
}

function bool ReachedMaxGoodies()
{
	return MaxGoodies >= GetInventoryCount();
}

function Actor FindNearestTarget()
{
	local Horklumps NearestHork;
	local HCollectible NearestGoodie;
	local float HorkDist;
	local float BeanDist;

	NearestHork = Horklumps(GetNearestActorOfClass(Class'Horklumps',SightRadius));
	NearestGoodie = HCollectible(GetNearestActorOfClass(GoodieClass,SightRadius));

	if ( NearestHork != None && NearestGoodie != None )
	{
		HorkDist = GetDistanceFromActor(NearestHork);
		BeanDist = GetDistanceFromActor(NearestGoodie);
		if ( HorkDist < BeanDist )
		{
			return NearestHork;
		}
		else
		{
			return NearestGoodie;
		}
	}
	else
	{
		if ( NearestHork != None )
		{
			return NearestHork;
		}
		else
		{
			return NearestGoodie;
		}
	}
}

function PlayGetOffSound()
{
	PlayEnemySound(GetOffSound);
}

function PlayHurtSound()
{
	PlayEnemySound(HurtSound);
}

function Yap()
{
	PlayEnemySound(TalkSound);
}

function PlayDieSound()
{
	PlayEnemySound(DieSound);
}

function PlayThrownSound()
{
	PlayEnemySound(ThrownSound);
}

function PlaySoundCrash()
{
	PlayEnemySound(CrashSound);
}

function DropTheLoad()
{ 
	SpitOutActor(GoodieClass,CurrentGoodies);

	if ( HeldActor != None )
	{
		HeldActor.Destroy();
	}
}

function MakeHarryDropLoad(int GoodieCount)
{
	if ( GoodieCount == 0 )
	{
		return;
	}

	PlayerHarry.DropTheLoad(GoodieCount);
}

function PickupGoodie(Actor Goodie)
{
	if ( Goodie.IsA('HCollectible') )
	{
		PickupObject(Goodie);
		CurrentGoodies++;
		CurrentGoodies = Clamp(CurrentGoodies,0,MaxGoodies);
	}
}

function bool DoesHarryHaveGoodie()
{
	local int ItemCount;

	ItemCount = GetGlobalInt(GoodieClass.Default.ItemGroupName);

	return ItemCount > 0;
}

function MugHarry()
{
	local int DropAmount;

	Print("GIMME THEM " $ GoodieClass.Name $ "s BOYYYY");
	if ( MinGoodiesToSteal >= 0 && MaxGoodiesToSteal > 0 )
	{
		DropAmount = Clamp(Rand(MaxGoodiesToSteal), MinGoodiesToSteal, MaxGoodiesToSteal);
		PlayerHarry.SpitOutActor(DropAmount);
	}

	PlayerHarry.TakeDamage(BumpDamage,self,Location,Velocity,'GnomeDamage');
}

function InteractionPushed(vector HitLocation, optional vector Momentum)
{
	GotoState('stateHit');
}

function PlayerCutCapture()
{
	GotoState('stateJustStandThere');
}

state stateJustStandThere
{
	begin:
		StopMoving();
		PlayAnim(GetCurrentIdleAnim,1.0,0.5);
}

defaultproperties
{
	PickupBone="GNOME R Hand"
	RunAnimName="runNormal"
	IdleAnimations(0)="sidestep"
	IdleAnimations(1)="Look"
	IdleAnimations(2)="Breath"
	IdleAnimations(3)="introangry"
	IdleAnimations(4)="tauntass"
	IdleAnimations(5)="eat"
	IdleAnimations(6)="idlecarryobject"
	IdleAnimations(7)="carry_taunt1"

	CarryIdle="idlecarryobject"
	CarryTaunt1="carry_taunt1"
	CarryTaunt2="carry_taunt2"
	DownIdle="downbreath"
	DownDizzy="downdizzy"
	Eat="eat"
	EatLoop="eatloop"
	GetUp="GetUp"
	Angry="introangry"
	KnockedBack="knockback"
	GrabGoodie="Pickup"
	RunCarryObj="runcarryobject"
	RunAttack="runattack"
	RunScared="runscared"
	TauntJump="tauntjump"
	TauntAss="tauntass"
	AttackBite="runattackbite"
	Throw="throw"

}