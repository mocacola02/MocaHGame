//================================================================================
// baseWand.
//================================================================================

class baseWand extends HWeapon; 

var bool bChargeSpells; // Moca: Should we charge spells instead of aiming

var float ChargeLevel;
var float ChargeSpeed;
var float MinCharge;
var float MaxCharge;
var Sound ChargeSound;

var Sound AimStartSFX;
var Sound AimLoopSFX;

var Vector WandTipOffset;

var class<baseSpell> CurrentSpell;
var class<baseSpell> ForcedSpell;

var ParticleFX ChargeParticles;

var LumosLight LumosGlow;

//-------------------------------------
// Events
//-------------------------------------

event PostBeginPlay()
{
	Super.PostBeginPlay();

	LumosGlow = Spawn(Class'LumosLight',self,,Location);
	Cursor = PlayerHarry.Cursor;
}

event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if (ChargeParticles != None)
	{
		ChargeParticles.SetLocation(Location + WandTipOffset);
	}
}

event Destroyed()
{
	if ( LumosGlow != None )
	{
		LumosGlow.Destroy();
	}

	if ( ChargeParticles != None)
	{
		ChargeParticles.Shutdown();
	}
	
	Super.Destroyed();
}

//-------------------------------------
// Main Actions
//-------------------------------------

function PrimaryFireAction()
{
	if (bChargeSpells && CurrentSpell != None)
	{
		GotoState('stateCharge');
	}

	bPointing = True;
	
	PlayerHarry.ResetFired();
	HPConsole(Player.Console).ResetSpace();

	PlayerHarry.HarryAnimChannel.GotoStateCasting();
	PlayerHarry.HarryAnimType = AT_Combine;
}

function SecondaryFireAction()
{
	if ( Cursor.CurrentTarget != None && Cursor.CurrentTarget.SpellVulnerableTo != None)
	{
		FireSpell();
	}
}

function Vector GetTraceOffset()
{
	local Vector FinalOffset;

	if ( PlayerHarry.bInDuelingMode )
	{
		return vector(PlayerHarry.Rotation) * CursorRange;
	}

	return PlayerHarry.Cam.vForward * (PlayerHarry.Cam.CurrentSet.fLookAtDistance + CursorRange);
}

function BecomeItem()
{
	Super.BecomeItem();
	bHidden = False;
}

function StartParticles(class<ParticleFX> FX)
{
	ChargeParticles = Spawn(FX,,,Location + WandTipOffset,Rotation);
	ChargeParticles.Attach
}

function StopParticles()
{
	if (ChargeParticles != None)
	{
		ChargeParticles.Shutdown();
	}
}

function UpdateTarget(Actor NewTarget)
{
	super.UpdateTarget(NewTarget);

	if (ForcedSpell != None)
	{
		print("Ignoring UpdateTarget, we're Forcing Spell " $ string(ForcedSpell));
		return;
	}

	if (NewTarget != None)
	{
		CurrentSpell = NewTarget.SpellVulnerableTo;
	}
	else
	{
		CurrentSpell = None;
	}
}

function SetForcedSpell(class<baseSpell> NewSpell)
{
	ForcedSpell = NewSpell;
}

function EndCharge();
function FireSpell();

//-------------------------------------
// States
//-------------------------------------

auto state stateIdle;

state stateAim
{
	event BeginState()
	{
		StopParticles();
		StartParticles(CurrentSpell.Default.FlyingParticleFX);

		PlaySound(AimStartSFX, SLOT_Interact, 1.0);
		PlaySound(AimLoopSFX, SLOT_Misc, 0.7, [Loop] true);
	}

	event EndState()
	{
		StopSound(AimLoopSFX, SLOT_Misc, 0.2);
		StopParticles();
	}

	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		if (!PlayerHarry.bAltFire)
		{
			if (CurrentSpell != None)
			{
				GotoState('stateFire');
			}
		}
	}
}

state stateCharge
{
	event BeginState()
	{
		StopParticles();
		StartParticles(CurrentSpell.Default.ChargeParticleFX);

		ChargeLevel = 0.0;
		ChargeSpeed = CurrentSpell.ChargeSpeed;
		MinCharge = CurrentSpell.MinCharge;
		MaxCharge = CurrentSpell.MaxCharge;
		ChargeSound = CurrentSpell.ChargeSound;\
		PlaySound(ChargeSound,SLOT_Interact,0.01,[Loop] true);
	}

	event EndState()
	{
		StopParticles();
		StopSound(ChargeSound,SLOT_Interact,0.2);
	}

	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		if (!PlayerHarry.bAltFire)
		{
			EndCharge();
		}

		if (ChargeLevel < MaxCharge)
		{
			local float ChargeVolume;

			ChargeLevel += ChargeSpeed * DeltaTime;
			ChargeLevel = FClamp(ChargeLevel, 0.0, MaxCharge);

			ChargeParticles.SizeWidth = ChargeLevel * ChargeParticles.Default.SizeWidth;
			ChargeParticles.SizeLength = ChargeLevel * ChargeParticles.Default.SizeLength;

			ChargeVolume = ChargeLevel / MaxCharge;
			ChargeVolume = FClamp(ChargeVolume, 0.0, 1.0);
			ModifySound(SOUND_Volume, ChargeVolume, ChargeLevel, SLOT_Interact);
		}
	}

	function EndCharge(optional bool bDamaged)
	{
		if (ChargeLevel >= MinCharge && !bDamaged)
		{
			GotoState('stateFire');
		}
		else
		{
			ChargeLevel = 0.0;
			GotoState('stateIdle');
		}
	}
}

state stateFire
{
	event BeginState()
	{
		HarryAnimChannel.GotoStateCast();
	}

	function FireSpell()
	{
		local baseSpell FiredSpell;

		if (ForcedSpell != None)
		{
			FiredSpell = Spawn(ForcedSpell,,,Location + WandTipOffset);
		}
		else
		{
			FiredSpell = Spawn(CurrentSpell,,,Location + WandTipOffset);
		}
		
		FiredSpell.TargetActor = CurrentTarget;
		FiredSpell.FinalCharge = FClamp(ChargeLevel,FiredSpell.MinCharge,FiredSpell.MaxCharge);
	}
}

defaultproperties
{
    ChargeParticleFXClass=Class'HPParticle.Skurge_fly'

    PickupAmmoCount=1

    FireOffset=(X=0.00,Y=-6.00,Z=-7.00)

    DeathMessage="%k inflicted magic damage upon %o with the %w."

    AutoSwitchPriority=0

    InventoryGroup=1

    PickupMessage="You got Harry's wand"

    ItemName="Wand"

    ThirdPersonMesh=SkeletalMesh'HPModels.WandMesh'

    Mesh=SkeletalMesh'HPModels.WandMesh'

    CollisionRadius=28.00

    CollisionHeight=8.00

    Mass=50.00
	
	bRespectHidden=true

	WandTipOffset=(X=0.0,Y=0.0,Z=20.0)

	AimStartSFX=Sound'HPSounds.Magic_sfx.Spell_aim'
	AimLoopSFX=Sound'HPSounds.Magic_sfx.spell_loop_nl'
}
