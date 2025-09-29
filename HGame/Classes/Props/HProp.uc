//================================================================================
// HProp.
//================================================================================

class HProp extends HPawn;

var bool bBounceIntoPlaceTiming;
var() bool bBounceIntoPlace;
var float BounceIntoPlaceTimeout;
var() array<Sound> BounceSounds;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	if ( bBounceIntoPlace )
	{
		GotoState('BounceIntoPlace');
	}
}

state BounceIntoPlace
{
	function BeginState()
	{
		bBounce = True;
		SetPhysics(PHYS_Falling);
		bBounceIntoPlaceTiming = False;
		BounceIntoPlaceTimeout = 5.0;
	}
	
	function Tick (float DeltaTime)
	{
		local Rotator NewRotation;
	
		Super.Tick(DeltaTime);
		NewRotation = Rotation;
		NewRotation.Yaw += 30000 * DeltaTime;
		NewRotation.Yaw = NewRotation.Yaw & 65535;
		SetRotation(NewRotation);
		if ( bBounceIntoPlaceTiming )
		{
			BounceIntoPlaceTimeout -= DeltaTime;
		}
	}
	
	function HitWall (Vector HitNormal, Actor Wall)
	{
		Velocity *= 0.5;
		Velocity = MirrorVectorByNormal(Velocity,HitNormal);
		bBounceIntoPlaceTiming = True;
		if ( bBounceIntoPlaceTiming && (BounceIntoPlaceTimeout >= 0) )
		{
			if ( (Abs(Velocity.Z) > 10) && (BounceSounds.Length > 0) )
			{
				local Sound SoundBounce;
				SoundBounce = BounceSounds[Rand(BounceSounds.Length)];

				PlaySound(SoundBounce,,Abs(Velocity.Z) / 100,,);
			}
		}
	}
	
	loop:
		Sleep(1.0);
		goto ('Loop');
}

defaultproperties
{
	bGestureFaceHorizOnly=False

	AmbientGlow=75

	bBlockCamera=True
}
