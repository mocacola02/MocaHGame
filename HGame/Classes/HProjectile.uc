class HProjectile extends Projectile;

enum HitWallReaction
{
	HW_Break,
	HW_Bounce,
	HW_Fall,
	HW_Custom,
};

var int MinAccuracy;
var int MaxAccuracy;

var float TimeToLive;

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

var HitWallReaction ReactionOnHitWall;

var Actor TargetActor;

var harry PlayerHarry;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	PlayerHarry = harry(Level.PlayerHarryActor);
	SetTimer(TimeToLive,false);
}

event HitWall(vector HitNormal, actor HitWall)
{
	DetermineReaction();
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

function ReactBreak(vector HitNormal, actor HitWall)
{
	HitWallParticles = Spawn(HitWallParticleFX,,,Location);
	GotoState('stateDestroy');
}

function ReactBounce(vector HitNormal, actor HitWall);

function ReactFall(vector HitNormal, actor HitWall)
{
	SetPhysics(PHYS_Falling);
	Velocity = Vect(0,0,0);
	Acceleration = Vect(0,0,0);
}

function ReactCustom(vector HitNormal, actor HitWall);

// Moca: I'm adding this since 1) I'm used to print() in Godot lmfao and 2) I can have it clearly mark the "speaker" of the message
function Print(string msg, optional bool BothLogs)
{
	if (msg == "")
	{
		return;
	}

	if (BothLogs)
	{
		CMAndLog(string(self) $ " says: " $ msg);
	}
	else
	{
		Log(string(self) $ " says: " $ msg);
	}
}

auto state stateFlying{}

state stateDestroy
{
	begin:
		SleepForTick();
		Destroy();
}

defaultproperties
{
	TransientSoundVolume=1.0
}