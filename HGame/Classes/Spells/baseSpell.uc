//================================================================================
// baseSpell.
//================================================================================

class baseSpell extends HProjectile; 

var class<ParticleFX> FlyingParticleFX;
var class<ParticleFX> HitParticleFX;
var class<ParticleFX> HitWallParticleFX;
var class<ParticleFX> ReactParticleFX;
var class<ParticleFX> ChargeParticleFX;
var class<ParticleFX> MiscParticleFX;

var ParticleFX FlyingParticles;
var ParticleFX HitParticles;
var ParticleFX HitWallParticles;
var ParticleFX ReactParticles;
var ParticleFX ChargeParticles;
var ParticleFX MiscParticles;


// Charge variables. Only the default values are used in baseWand
var float ChargeSpeed; 			// Moca: How much charge to gain over a second Def: 1.0
var float MinCharge;
var float MaxCharge;			// Moca: Maximum charge Def: 2.5
var Sound ChargeSound;

var float FinalCharge;	// Moca: Charge after spawned from baseWand

var Vector CurrentDirection;
var float SeekSpeed;

var name SpellName;

var Texture SpellIcon;
var Texture SpellGesture;

var Actor TargetActor;
var baseWand SpellWand;


//-------------------------------------
// Events
//-------------------------------------

event FellOutOfWorld();

event PostBeginPlay()
{
	Super.PostBeginPlay();
	OnSpellInit();
}

event Tick (float DeltaTime)
{
	if ( (LifeTime -= DeltaTime) < 0 )
	{
		OnSpellShutdown();
		Destroy();
	}

	Seek(DeltaTime);
}

event HitWall (Vector HitNormal, Actor Wall)
{
	OnHitWall(Wall);
	Destroy();
}

event Landed(vector HitNormal)
{
	HandleHit(Location,true);
}

event Destroyed()
{
	if (FlyingParticles != None)
	{
		FlyingParticles.Shutdown();
	}

	if (ReactParticles != None)
	{
		ReactParticles.Shutdown();
	}

	if (ChargeParticles != None)
	{
		ChargeParticles.Shutdown();
	}

	if (MiscParticles != None)
	{
		MiscParticles.Shutdown();
	}
}

//-------------------------------------
// Main Functions
//-------------------------------------

function Seek();

function OnSpellInit()
{
	PlaySound(SpawnSound);
	FlyingParticles = Spawn(FlyingParticleFX,,,Location,Rotation);
	FlyingParticles.SetBase(self);
	Velocity = vector(Rotation) * Speed;
	CurrentDir = vector(Rotation);
}

function ProcessTouch(Actor Other, Vector HitLocation)
{
	local Pawn Instigator;

	if (SpellWand.Owner.IsA('Pawn'))
	{
		Instigator = Pawn(SpellWand.Owner);
	}

	Other.TakeDamage(Damage,Instigator,Location,Velocity,SpellName);
}

function OnHitWall(Actor Wall)
{
	switch(Wall.Class)
	{
		case Class'GridMover': ProcessTouch(Wall,Location); break;
		default: HandleHit(Location,true); break;
	}
}

function HandleHit(Vector HitLocation, optional bool bHitWall)
{
	if (bHitWall)
	{
		HitWallParticles = Spawn(HitWallParticleFX,,,HitLocation);
	}
	else
	{
		HitParticles = Spawn(HitParticleFX,,,HitLocation);
		PlaySound(ImpactSound);
	}

	Destroy();
}

function bool IsRelevantToMover()
{
	return True;
}

function Vector GetTargetLocation(Actor Target)
{
	return Target.Location;
}

//-------------------------------------
// States
//-------------------------------------

auto state stateFlying
{
	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);
		Seek(DeltaTime);
	}

	function Seek(float DeltaTime)
	{
		local Vector TargetDirection;

		if ( TargetActor  == None )
		{
			return;
		}

		TargetDirection = Normal(GetTargetLocation(TargetActor) - Location);

		CurrentDirection += (TargetDirection - CurrentDirection) * FMin(1.0, SeekSpeed * DeltaTime);
		CurrentDirection = Normal(CurrentDirection);

		DesiredRotation = rotator(CurrentDirection);
		SetRotation(DesiredRotation);

		Velocity = CurrentDirection * Speed;
	}
}

//-------------------------------------
// Default Properties
//-------------------------------------

defaultproperties
{
	CollisionRadius=2.0
    CollisionHeight=2.0

	Damage=5.0

	ChargeSpeed=1.0
	MaxCharge=2.5

	Speed=500.0
    SeekSpeed=7.0

	LifeSpan=8.0

	bFixedRotationDir=True
	bProjTarget=True
	bUnlit=True

	Style=STY_Translucent 

	SpellIcon=Texture'HGame.Icons.defaultSpellIcon'

    fxHitWallParticleEffectClass=Class'HPParticle.DustCloud02_small'

	SpawnSound=Sound'HPSounds.Magic_sfx.Skurge_fly'
    ImpactSound=Sound'HPSounds.Magic_sfx.spell_hit'	

	SpellName=MissingNo
}
