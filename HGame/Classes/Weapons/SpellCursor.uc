//================================================================================
// SpellCursor.
//================================================================================

class SpellCursor extends HActor;

var globalconfig bool bSpellCursorAlwaysOn;
var bool bCursorActive;
var float CursorRange;

// Particles
var class<ParticleFX> IdleFX;
var class<ParticleFX> LockedFX;
var ParticleFX IdleParticles;
var ParticleFX LockedParticles;

// Misc. References
var GestureSprite SpellGesture;
var BaseCam PlayerCam;
var HWeapon PlayerWeapon;


//-------------------------------------
// Init & Events
//-------------------------------------

event PostBeginPlay()
{
	Super.PostBeginPlay();
	InitDependencies();
}

function InitDependencies()
{
	if (PlayerHarry != None)
	{
		PlayerCam = PlayerHarry.Cam;
		PlayerWeapon = PlayerHarry.Weapon;
	}

	SpellGesture = Spawn(Class'GestureSprite');
	IdleParticles = Spawn(IdleFX);
	LockedParticles = Spawn(LockedFX);
}

event Destroyed()
{
	if ( SpellGesture != None )
	{
		SpellGesture.Destroy();
	}

	if (IdleParticles != None)
	{
		IdleParticles.Shutdown();
	}

	if (LockedParticles != None)
	{
		LockedParticles.Shutdown();
	}

	Super.Destroyed();
}

//-------------------------------------
// Main Functions
//-------------------------------------

function StartSeeking()
{
	GotoState('stateSeeking');
}

function StopSeeking()
{
	GotoState('stateIdle');
}

function LockOn()
{
	GotoState('stateLocked');
}

function Unlock()
{
	if ( bCursorActive )
	{
		GotoState('stateSeeking');
	}
	else
	{
		GotoState('stateIdle');
	}
}

//-------------------------------------
// States
//-------------------------------------

state stateIdle
{
	event BeginState()
	{
		IdleParticles.bEmit = False;
		LockedParticles.bEmit = False;
	}

	event Tick(float DeltaTime);
}

state stateSeeking
{
	event BeginState()
	{
		IdleParticles.bEmit = True;
	}
	
	event EndState()
	{
		IdleParticles.bEmit = False;
	}

	event Tick(float DeltaTime)
	{
		UpdateCursor();
	}

	function UpdateCursor()
	{
		local Vector TraceStart;
		local Vector TraceEnd;
		local Vector TraceDirection;

		local Actor HitActor;
		local Vector TraceHitLoc;
		local Vector TraceHitNormal;

		local bool bHitSomething;

		TraceStart = PlayerCam.CamTarget.Location;

		TraceEnd = PlayerHarry.Location + GetTraceOffset();

		SetLocation(TraceEnd);

		TraceDirection = Normal(TraceEnd - TraceStart);

		foreach TraceActors(Class'Actor', HitActor, TraceHitLoc, TraceHitNormal, TraceEnd, TraceStart)
		{
			if ( HitActor == Owner || HitActor.IsA('harry') )
			{
				continue;
			}

			PlayerWeapon.UpdateTarget(HitActor);
			bHitSomething = True;
		}

		if (!bHitSomething)
		{
			PlayerWeapon.UpdateTarget(None);
		}
	}
}

state stateLocked
{
	event BeginState()
	{
		LockedParticles.bEmit = True;
	}
	
	event EndState()
	{
		LockedParticles.bEmit = False;
	}
}


//-------------------------------------
// Default Properties
//-------------------------------------

defaultproperties
{
    CursorRange=512.00

    Rotation=(Pitch=16640,Yaw=0,Roll=0)

    bRotateToDesired=True

	IdleFX=Class'IdleCursor'
	LockedFX=Class'LockedCursor'
}
