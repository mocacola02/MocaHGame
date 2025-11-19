//================================================================================
// SpellCursor.
//================================================================================

class SpellCursor extends HActor;

var Actor aPossibleTarget;
var Actor CurrentTarget;
var Vector TraceDirection;
var Vector TraceStart;
var Vector TraceEnd;
var Vector vLastValidHitPos;
var float CursorRange;
var bool bInvisibleCursor;
var globalconfig bool bSpellCursorAlwaysOn;
var Vector vTargetOffset; 
var bool bHitSomething;
var GestureSprite SpellGesture;
var Vector vGestureOffset;
var float fFinalGestureDistance;
var BaseCam PlayerCam;
var class<ParticleFX> IdleFX;
var class<ParticleFX> SeekingFX;
var class<ParticleFX> LockedFX;
var ParticleFX IdleParticles;
var ParticleFX SeekingParticles;
var ParticleFX LockedParticles;

event PreBeginPlay()
{
	PlayerHarry = harry(Level.PlayerHarryActor);

	InitDependencies();

	SpellGesture = Spawn(Class'GestureSprite');
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
	if (SeekingParticles != None)
	{
		SeekingParticles.Shutdown();
	}
	if (LockedParticles != None)
	{
		LockedParticles.Shutdown();
	}

	Super.Destroyed();
}

function InitDependencies()
{
	if (PlayerHarry != None)
	{
		PlayerCam = PlayerHarry.Cam;
	}

	SpellGesture = Spawn(Class'GestureSprite');
	IdleParticles = Spawn(IdleFX);
	SeekingParticles = Spawn(SeekingFX);
	LockedParticles = Spawn(LockedFX);
}

function bool IsLockedOn()
{
	return CurrentTarget != None;
}

function SetLOSDistance (float fNewDistance)
{
	if ( fNewDistance <= 0 )
	{
		fNewDistance = Default.CursorRange;
	}

	CursorRange = fNewDistance;
	PlayerHarry.ClientMessage("SpellCursor: Set spell distance to " $ string(fNewDistance));
}

function WetTexture GetGestureTexture (class<baseSpell> SpellClass)
{
	if (SpellClass == None)
	{
		return None;
	}

	return SpellClass.Default.SpellGesture;
}

function TurnOnSpellGestureFX (class<baseSpell> SpellClass, Vector vLocation, float FXSize)
{
	if ( CurrentTarget == None )
	{
		return;
	}

	SpellGesture.SetLocation(vLocation);
	SpellGesture.SetRotation(PlayerHarry.Rotation);
	SpellGesture.Texture = GetGestureTexture(SpellType);
	SpellGesture.DrawScale = FXSize;
}

function bool CanCameraSeeYouInFOV (int rOutsideFOV, Vector Pos)
{
	local Vector vNormal;
	local Vector Dir;
	local Rotator OutsideFOV;

	Dir = Pos - PlayerCam.Location;

	if ( CurrentTarget.IsA('spellTrigger') && spellTrigger(CurrentTarget).bHitJustFromFront &&  !IsHarryFacingTarget(CurrentTarget) )
	{
		return False;
	}

	if ( VSize(Dir) > CursorRange * 1.25 )
	{
		return False;
	}

	OutsideFOV.Yaw = PlayerCam.Rotation.Yaw - rOutsideFOV;
	vNormal = vector(OutsideFOV);

	if ( vNormal Dot Dir > 0.0 )
	{
		OutsideFOV.Yaw = PlayerCam.Rotation.Yaw + rOutsideFOV;
		vNormal = vector(OutsideFOV);

		if ( vNormal Dot Dir > 0.0 )
		{
			return True;
		}
	}

	return False;
}

function bool IsHarryFacingTarget (Actor aTarget)
{
	local float fDotProduct;
	local Vector X;
	local Vector Y;
	local Vector Z;

	GetAxes(aTarget.Rotation,X,Y,Z);

	fDotProduct = PlayerCam.vForward Dot X;

	PlayerHarry.cm("TraceDirection = " $ string(TraceDirection) $ " dot =" $ string(fDotProduct));

	return !(fDotProduct >= 0.0);
}

function UpdateCursor (optional bool bJustStopAtClosestPawnOrWall)
{
	local Actor aHitActor;
	local bool bHitActor;
	local Vector vFirstHitPos;
	local Vector vHitNormal;
	local Vector vHitLocation;
	local float fDotProduct;

	bHitSomething = False;

	TraceStart = PlayerCam.CamTarget.Location;

	if ( PlayerHarry.bInDuelingMode )
	{
		TraceEnd = PlayerHarry.Location + (vector (PlayerHarry.Rotation) * CursorRange);
	}
	else if ( PlayerHarry.bHarryUsingSword )
	{
		TraceEnd = PlayerCam.Location + (vector (PlayerCam.Rotation + PlayerHarry.AimRotOffset) * (PlayerCam.CurrentSet.fLookAtDistance + CursorRange));
	}
	else
	{
		TraceEnd = PlayerCam.Location + (PlayerCam.vForward * (PlayerCam.CurrentSet.fLookAtDistance + CursorRange));
	}

	TraceDirection = Normal(TraceEnd - TraceStart);

	aHitActor = Trace(vHitLocation,vHitNormal,TraceEnd,PlayerCam.Location);

	if ( (aHitActor != None) && !aHitActor.IsA('harry') )
	{
		bHitSomething = True;
		TraceEnd = vHitLocation + (TraceDirection * 5.0);
	}

	foreach TraceActors(Class'Actor',aHitActor,vHitLocation,vHitNormal,TraceEnd,TraceStart)
	{
		if ( aHitActor == Owner || aHitActor.IsA('harry') ||  (!aHitActor.IsA('Pawn') &&  !aHitActor.IsA('GridMover') &&  !aHitActor.IsA('spellTrigger')) )
		{
			continue;
		}

		if (  !bHitActor &&  !aHitActor.bHidden )
		{
			bHitActor = True;
			vFirstHitPos = vHitLocation;
		}

		if ( aHitActor.SpellVulnerableTo == None )
		{
			continue;
		}

		if ( PlayerHarry.IsSpellInBook(aHitActor.SpellVulnerableTo) || (bJustStopAtClosestPawnOrWall) )
		{
			if ( aHitActor.IsA('spellTrigger') )
			{
				if( !spellTrigger(aHitActor).bInitiallyActive || (spellTrigger(aHitActor).bHitJustFromFront &&  !IsHarryFacingTarget(aHitActor)) )
				{
					continue;
				}
			}

			if (  !bJustStopAtClosestPawnOrWall )
			{
				aPossibleTarget = aHitActor;
				vTargetOffset = vHitLocation - aPossibleTarget.Location;
			}

			vLastValidHitPos = vHitLocation;
		}

		TraceEnd = vHitLocation;
		break;
	}

	if ( aPossibleTarget == None && bHitActor )
	{
		TraceEnd = vFirstHitPos;
	}

	if ( CurrentTarget == None )
	{
		MoveSmooth((TraceEnd - (TraceDirection * 8.0)) - Location);

		if ( aPossibleTarget != None )
		{
			SpellGesture.SetLocation(TraceEnd);
		}
	}
}

function bool LookForTarget()
{
	if ( aPossibleTarget == None )
	{
		return False;
	}

	if ( aPossibleTarget == CurrentTarget )
	{
		return True;
	}

	LockOn(aPossibleTarget);
	return True;
}

function UnLock()
{
	if ( CurrentTarget == None )
	{
		return;
	}

	StopLockedOnSoundLoop();
	aPossibleTarget = None;
	CurrentTarget = None;
	SpellGesture.bHidden = True;
}

function LockOn (Actor TargetActor)
{
	local float fTargetWidth;
	local float fTargetHeight;
	local float fTargetDepth;
	local Vector dwh;

	if ( TargetActor.CollideType == CT_AlignedCylinder  || TargetActor.CollideType == CT_OrientedCylinder || TargetActor.CollisionWidth == 0 )
	{
		dwh = Vec(TargetActor.CollisionRadius,TargetActor.CollisionRadius,TargetActor.CollisionHeight);
	}
	else
	{
		dwh = Vec(TargetActor.CollisionRadius,TargetActor.CollisionWidth,TargetActor.CollisionHeight);
	}

	fTargetDepth = dwh.X * 2.2 * TargetActor.SizeModifier;
	fTargetWidth = dwh.Y * 2.2 * TargetActor.SizeModifier;
	fTargetHeight = dwh.Z * 2.2 * TargetActor.SizeModifier;

	if ( (TargetActor == None) || (PlayerHarry == None) || (PlayerHarry.Weapon == None) )
	{
		return;
	}

	if ( fTargetDepth < fTargetWidth )
	{
		fFinalGestureDistance = (fTargetDepth *0.5f) + 2.0 + TargetActor.GestureDistance;
	}
	else
	{
		fFinalGestureDistance = (fTargetWidth *0.5f) + 2.0 + TargetActor.GestureDistance;
	}

	baseWand(PlayerHarry.Weapon).ChooseSpell(TargetActor.SpellVulnerableTo);

	CurrentTarget = TargetActor;

	if ( CurrentTarget.bGestureFaceHorizOnly )
	{
		vGestureOffset =  -(Vec(fFinalGestureDistance,0.0,0.0));
		TurnOnSpellGestureFX(TargetActor.eVulnerableToSpell,TargetActor.Location + TargetActor.CentreOffset + (vGestureOffset >> PlayerHarry.Rotation),fFinalGestureDistance * TargetActor.SizeModifier);
	}
	else
	{
		vGestureOffset = Normal(PlayerHarry.Location - CurrentTarget.Location) * fFinalGestureDistance;
		TurnOnSpellGestureFX(TargetActor.eVulnerableToSpell,TraceEnd,fFinalGestureDistance * TargetActor.SizeModifier);
	}

	SetSparklesLockedOn(fTargetWidth,fTargetHeight,fTargetDepth);
	SetRotation(TargetActor.Rotation);
	StartLockedOnSoundLoop();
}

function StartLockedOnSoundLoop()
{
	PlaySound(Sound'spell_target_nl3',SLOT_Misc);
	PlaySound(Sound'spell_targetloop',SLOT_Interact, [Loop] True);
}

function StopLockedOnSoundLoop()
{
	StopSound(Sound'spell_targetloop',SLOT_Interact);
}

function TurnSparklesOff()
{
}

function SetSparklesIdle()
{
	ParticlesPerSec.Base = IdleFX.Default.ParticlesPerSec.Base;
	SourceWidth.Base = IdleFX.Default.SourceWidth.Base;
	SourceHeight.Base = IdleFX.Default.SourceHeight.Base;
	SourceDepth.Base = IdleFX.Default.SourceDepth.Base;
	Speed.Base = IdleFX.Default.Speed.Base;
	Lifetime.Base = IdleFX.Default.Lifetime.Base;
	SizeWidth.Base = IdleFX.Default.SizeWidth.Base;
	SizeLength.Base = IdleFX.Default.SizeLength.Base;
	SizeEndScale.Base = IdleFX.Default.SizeEndScale.Base;
	SpinRate.Base = IdleFX.Default.SpinRate.Base;
	SpinRate.Rand = IdleFX.Default.SpinRate.Rand;
	ParticlesAlive = IdleFX.Default.ParticlesAlive;
	ColorStart.Base.R = IdleFX.Default.ColorStart.Base.R;
	ColorStart.Base.G = IdleFX.Default.ColorStart.Base.G;
	ColorStart.Base.B = IdleFX.Default.ColorStart.Base.B;
	ColorEnd.Base.R = IdleFX.Default.ColorEnd.Base.R;
	ColorEnd.Base.G = IdleFX.Default.ColorEnd.Base.G;
	ColorEnd.Base.B = IdleFX.Default.ColorEnd.Base.B;
}

function SetSparklesSeeking()
{
	ParticlesPerSec.Base = SeekingFX.Default.ParticlesPerSec.Base;
	SourceWidth.Base = SeekingFX.Default.SourceWidth.Base;
	SourceHeight.Base = SeekingFX.Default.SourceHeight.Base;
	SourceDepth.Base = SeekingFX.Default.SourceDepth.Base;
	AngularSpreadWidth.Base = SeekingFX.Default.AngularSpreadWidth.Base;
	AngularSpreadHeight.Base = SeekingFX.Default.AngularSpreadHeight.Base;
	Speed.Base = SeekingFX.Default.Speed.Base;
	Lifetime.Base = SeekingFX.Default.Lifetime.Base;
	SizeWidth.Base = SeekingFX.Default.SizeWidth.Base;
	SizeWidth.Rand = SeekingFX.Default.SizeWidth.Rand;
	SizeLength.Base = SeekingFX.Default.SizeLength.Base;
	SizeLength.Rand = SeekingFX.Default.SizeLength.Rand;
	SizeEndScale.Base = SeekingFX.Default.SizeEndScale.Base;
	SpinRate.Base = SeekingFX.Default.SpinRate.Base;
	SpinRate.Rand = SeekingFX.Default.SpinRate.Rand;
	Attraction.X = SeekingFX.Default.Attraction.X;
	Attraction.Y = SeekingFX.Default.Attraction.Y;
	ParticlesAlive = SeekingFX.Default.ParticlesAlive;
	ColorStart.Base.R = SeekingFX.Default.ColorStart.Base.R;
	ColorStart.Base.G = SeekingFX.Default.ColorStart.Base.G;
	ColorStart.Base.B = SeekingFX.Default.ColorStart.Base.B;
	ColorEnd.Base.R = SeekingFX.Default.ColorEnd.Base.R;
	ColorEnd.Base.G = SeekingFX.Default.ColorEnd.Base.G;
	ColorEnd.Base.B = SeekingFX.Default.ColorEnd.Base.B;
}

function SetSparklesLockedOn (float fTargetWidth, float fTargetHeight, float fTargetDepth)
{
	ParticlesPerSec.Base = LockedFX.Default.ParticlesPerSec.Base;
	SourceWidth.Base = fTargetWidth;
	SourceHeight.Base = fTargetHeight;
	SourceDepth.Base = fTargetDepth;
	AngularSpreadWidth.Base = LockedFX.Default.AngularSpreadWidth.Base;
	AngularSpreadHeight.Base = LockedFX.Default.AngularSpreadHeight.Base;
	Speed.Base = LockedFX.Default.Speed.Base;
	Lifetime.Base = LockedFX.Default.Lifetime.Base;
	SizeWidth.Base = LockedFX.Default.SizeWidth.Base;
	SizeWidth.Rand = LockedFX.Default.SizeWidth.Rand;
	SizeLength.Base = LockedFX.Default.SizeLength.Base;
	SizeLength.Rand = LockedFX.Default.SizeLength.Rand;
	SizeEndScale.Base = LockedFX.Default.SizeEndScale.Base;
	SpinRate.Base = LockedFX.Default.SpinRate.Base;
	SpinRate.Rand = LockedFX.Default.SpinRate.Rand;
	Attraction.X = LockedFX.Default.Attraction.X;
	Attraction.Y = LockedFX.Default.Attraction.Y;
	ParticlesAlive = LockedFX.Default.ParticlesAlive;
	bRotateToDesired = LockedFX.Default.bRotateToDesired;
	ColorStart.Base.R = LockedFX.Default.ColorStart.Base.R;
	ColorStart.Base.G = LockedFX.Default.ColorStart.Base.G;
	ColorStart.Base.B = LockedFX.Default.ColorStart.Base.B;
	ColorEnd.Base.R = LockedFX.Default.ColorEnd.Base.R;
	ColorEnd.Base.G = LockedFX.Default.ColorEnd.Base.G;
	ColorEnd.Base.B = LockedFX.Default.ColorEnd.Base.B;
}

function TurnTargetingOn()
{
}

function TurnTargetingOff()
{
	UnLock();
	GotoState('stateIdle');
}

auto state stateIdle
{
	function BeginState()
	{
		SetSparklesIdle();

		if (  !bSpellCursorAlwaysOn || bInvisibleCursor )
		{
			EnableEmission(False);
		}
	}
	
	function Tick (float fTimeDelta)
	{
		UpdateCursor(PlayerHarry.bHarryUsingSword);

		if ( bHitSomething )
		{
			ColorStart.Base.R = 255;
			ColorStart.Base.G = 255;
			ColorStart.Base.B = 0;
		}
		else
		{
			ColorStart.Base.R = 255;
			ColorStart.Base.G = 0;
			ColorStart.Base.B = 0;
		}
	}
	
	function TurnTargetingOn()
	{
		GotoState('stateSeeking');
	}
}

state stateSeeking
{
  function BeginState()
  {
    if (  !bInvisibleCursor )
    {
      EnableEmission(True);
    }
    SetSparklesSeeking();
  }
  
  function EndState()
  {
  }
  
  function Tick (float fTimeDelta)
  {
    UpdateCursor(PlayerHarry.bHarryUsingSword);
    if ( bHitSomething )
    {
      ColorStart.Base.R = 255;
      ColorStart.Base.G = 255;
      ColorStart.Base.B = 0;
    } else {
      ColorStart.Base.R = 255;
      ColorStart.Base.G = 0;
      ColorStart.Base.B = 0;
    }
    if ( LookForTarget() )
    {
      GotoState('stateLockedOn');
    }
  }
  
  begin:
  if ( bDebugMode )
  {
    PlayerHarry.ClientMessage("BeginState -> StateSeeking");
  }
}

state stateLockedOn
{
  function Tick (float fTimeDelta)
  {
    UpdateCursor();
    if (  !LookForTarget() &&  !CanCameraSeeYouInFOV(10923,CurrentTarget.Location) )
    {
      UnLock();
      GotoState('stateSeeking');
    }
    SetLocation(CurrentTarget.Location);
    if ( (CurrentTarget != None) && CurrentTarget.bGestureFaceHorizOnly )
    {
      SpellGesture.SetLocation(CurrentTarget.Location + CurrentTarget.CentreOffset + (vGestureOffset >> PlayerHarry.Rotation));
      SpellGesture.bHidden = False;
    } else //{
      if ( aPossibleTarget != None )
      {
        if ( SpellGesture.bHidden && aPossibleTarget == CurrentTarget )
        {
          SpellGesture.SetLocation(TraceEnd);
          SpellGesture.bHidden = False;
        } else {
          SpellGesture.MoveSmooth((TraceEnd - SpellGesture.Location) * 10.0 * fTimeDelta);
        }
        vTargetOffset = SpellGesture.Location - Location;
      } else //{
        if ( CurrentTarget != None )
        {
          vGestureOffset = Normal(PlayerHarry.Location - CurrentTarget.Location) * fFinalGestureDistance;
          SpellGesture.MoveSmooth(((CurrentTarget.Location + CurrentTarget.CentreOffset + vGestureOffset) - SpellGesture.Location) * 8.0 * fTimeDelta);
          vTargetOffset = SpellGesture.Location - Location;
        }
      // }
    // }
    if ( bHitSomething || CurrentTarget != None )
    {
      ColorStart.Base.R = 255;
      ColorStart.Base.G = 255;
      ColorStart.Base.B = 0;
    } else {
      ColorStart.Base.R = 255;
      ColorStart.Base.G = 0;
      ColorStart.Base.B = 0;
    }
  }
  
  begin:
  if ( bDebugMode )
  {
    PlayerHarry.ClientMessage("BeginState -> StateLockedOn ( " $ string(CurrentTarget) $ " )");
  }
}

defaultproperties
{
    CursorRange=512.00
	
    ParticlesPerSec=(Base=20.00,Rand=0.00)

    SourceWidth=(Base=100.00,Rand=0.00)

    SourceHeight=(Base=100.00,Rand=0.00)

    SourceDepth=(Base=100.00,Rand=0.00)

    AngularSpreadWidth=(Base=2.00,Rand=0.00)

    AngularSpreadHeight=(Base=2.00,Rand=0.00)

    Speed=(Base=5.00,Rand=0.00)

    Lifetime=(Base=2.00,Rand=0.00)

    ColorStart=(Base=(R=0,G=0,B=255,A=0),Rand=(R=0,G=0,B=0,A=0))

    ColorEnd=(Base=(R=0,G=0,B=255,A=0),Rand=(R=0,G=0,B=0,A=0))

    SizeWidth=(Base=2.00,Rand=10.00)

    SizeLength=(Base=2.00,Rand=10.00)

    SizeEndScale=(Base=-0.50,Rand=0.00)

    SpinRate=(Base=1.00,Rand=20.00)

    Attraction=(X=10.00,Y=10.00,Z=0.00)

    ParticlesAlive=10

    Textures(0)=Texture'HPParticle.hp_fx.Particles.Sparkle_1'

    Rotation=(Pitch=16640,Yaw=0,Roll=0)

    bRotateToDesired=True

	bEmit=False
}
