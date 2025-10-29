//================================================================================
// LumosLight.
//================================================================================

class LumosLight extends HActor;

var bool bLumosOn;
var bool bInfiniteLumos;

var float LumosTimeToTurnOff;
var float LumosTime;

var class<ParticleFX> ParticleClass;
var ParticleFX Particles;

var harry PlayerHarry;


singular simulated function Touch (Actor Other)
{
}

function ProcessTouch (Actor Other, Vector HitLocation)
{
}

function HitWall (Vector HitNormal, Actor Wall)
{
}

function Explode (Vector HitLocation, Vector HitNormal)
{
}

function bool EncroachingOn (Actor Other)
{
	return False;
}

function bool IsRelevantToMover()
{
	return False;
}

function PreBeginPlay()
{
	PlayerHarry = harry(Level.PlayerHarryActor);
	Disable('Tick');
}

event Destroyed()
{
	TurnOff();

	if ( Particles != None )
	{
		Particles.Destroy();
	}
}

event FellOutOfWorld()
{
}

function ScaleParticles (float Scale)
{
	Scale = FClamp(Scale,0.0,1.0);
	LightRadius = 5 + (10 * Scale);
	Particles.SizeWidth.Base = Particles.Default.SizeWidth.Base * Scale;
	Particles.SizeLength.Base = Particles.Default.SizeLength.Base * Scale;
}

function Tick (float DeltaTime)
{
	if ( !bLumosOn )
	{
		return;
	}

	LumosTime += DeltaTime;
	
	if ( bInfiniteLumos )
	{
		ScaleParticles(0.75 - (0.5 * Abs(Sin(LumosTime * 0.25))));
		return;
	}
	else if ( LumosTime > LumosTimeToTurnOff )
	{
		LumosTime = LumosTimeToTurnOff;
		TurnOff();
	}

	ScaleParticles(1.0 - (LumosTime / LumosTimeToTurnOff));
}

function UpdateLocation (Vector NewLocation)
{
	SetLocation(NewLocation);
	Particles.SetLocation(NewLocation);
}

function TurnOn()
{
	local Actor A;

	LumosTime = 0.0;

	if ( bLumosOn )
	{
		return;
	}

	bLumosOn = True;

	Enable('Tick');

	TurnDynamicLightOn();

	foreach AllActors(Class'Actor',A)
	{
		A.OnLumosOn();
	}

	if ( Particles != None )
	{
		Particles.Destroy();
	}

	Particles = Spawn(ParticleClass,[SpawnOwner]self,,[SpawnLocation]Location);
	Particles.EnableEmission(True);
}

function TurnOff()
{
	local Actor A;

	LumosTime = LumosTimeToTurnOff;

	bLumosOn = False;

	Disable('Tick');

	TurnDynamicLightOff();

	foreach AllActors(Class'Actor',A)
	{
		A.OnLumosOff();
	}

	if ( Particles != None )
	{
		Particles.Destroy();
	}
}

function TurnDynamicLightOn()
{
	LightType = LT_Steady;
}

function TurnDynamicLightOff()
{
	LightType = LT_None;
}

defaultproperties
{
    LumosTimeToTurnOff=30.00

	ParticleClass=Class'LumosLightFX'

	RemoteRole=ROLE_SimulatedProxy

	DrawType=DT_Mesh

	Style=STY_Translucent

    Texture=None

	Physics=PHYS_None
	
	bCollideActors=False

	bBlockActors=False

	bBlockPlayers=False
}