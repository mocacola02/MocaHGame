//================================================================================
// baseWand.
//================================================================================

class baseWand extends HWeapon; 

var class<baseSpell> CurrentSpell;
var LumosLight LumosGlow;
var float SpellCharge;
var float SpellChargeTime;
var float ChargeParticlesMinSize;
var float ChargeParticlesMaxSize;
var ParticleFX ChargeParticles;
var class<ParticleFX> ChargeParticleFXClass;
var bool bGlowingWand;
var bool bInstantFire;
var baseSpell LastCastedSpell;
var float AutoHitDistance;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	LumosGlow = Spawn(Class'LumosLight',self,,Location);

	if (LumosGlow == None)
	{
		cm("ERROR: Could not spawn LumosGlow.");
	}
}

event Destroyed()
{
	if ( LumosGlow != None )
	{
		LumosGlow.Destroy();
	}

	StopGlowingWand();
	
	Super.Destroyed();
}

function PrimaryFireAction()
{
	CastSpell();
}

function StartGlowingWand (Class<baseSpell> GlowSpellClass)
{
	if ( fxChargeParticles != None )
	{
		fxChargeParticles.Destroy();
	}

	ChargeParticles = Spawn(GetChargeParticleClass(GlowSpellClass));
	ChargeParticles.bEmit = True;
	bGlowingWand = True;
}

function StopGlowingWand()
{
	bGlowingWand = False;
	if ( ChargeParticles != None )
	{
		ChargeParticles.Destroy();
	}
}

function StartChargingSpell (bool bChargeSpell, optional Class<baseSpell> ChargeSpellClass, optional float ChargeDuration)
{
	//bSpellCharges = bChargeSpell;

	StopGlowingWand();

	if (ChargeDuration <= 0)
	{
		ChargeDuration = Default.ChargeDuration;
	}

	if ( ChargeSpellClass != None )
	{
		ChargeParticles = Spawn(GetChargeParticleClass(ChargeSpellClass));
	}
	else
	{
		ChargeParticles = Spawn(Default.ChargeParticleFXClass);
		ChargeParticles.SizeWidth.Base = ChargeParticlesMinSize;
		ChargeParticles.SizeLength.Base = ChargeParticlesMinSize;
	}

	ChargeParticles.EnableEmission(True);

	SpellChargeTime = ChargeDuration;
	SpellCharge = 0.0;
}

function StopChargingSpell()
{
	//bSpellCharges = False;
	//fSpellChargeTime = 0.0;

	SpellCharge = 0.0;

	if ( bGlowingWand )
	{
		ScaleParticles(ChargeParticles,1.0);
	}
	else
	{
		ChargeParticles.Shutdown();
	}
}

function Class<ParticleFX> GetChargeParticleClass (Class<baseSpell> spellClass)
{
	local class<ParticleFX> fxClass;
	fxClass = spellClass.Default.SpellFX.ChargeParticleClass;

	if ( fxClass == None )
	{
		fxClass = Class'Flip_fly';
	}

	return fxClass;
}

function SetCurrentSpell (Class<baseSpell> spellClass, optional bool bForceSelection)
{
	if ( Owner.IsA('harry') )
	{
		if ( harry(Owner).IsSpellInBook(spellClass) || bForceSelection )
		{
			CurrentSpell = spellClass;
		}
	}
	else
	{
		CurrentSpell = spellClass;
	}
}

function float GetChargeParticleFXScale (float fCharge)
{
	if ( fCharge > 1.0 )
	{
		return fSpellChargeEndScale + fCharge;
	}
	else
	{
		return ChargeParticlesMinSize + (ChargeParticlesMaxSize - ChargeParticlesMinSize) * fCharge;
	}
}

function SetInstantFire (bool in_bInstantFire)
{
	bInstantFire = in_bInstantFire;
}

function Vector GetWandEndPoint()
{
	return Pawn(Owner).WeaponLoc - (Vec(0.0,0.0,20.0) >> Pawn(Owner).WeaponRot);
}

function ScaleParticles (ParticleFX FX, float Scale)
{
	FX.ParticlesPerSec.Base = ChargeParticlesMinSize * Scale;
	FX.SourceHeight.Base = ChargeParticlesMinSize * Scale;
	FX.SourceWidth.Base = ChargeParticlesMinSize * Scale;
	FX.SourceDepth.Base = ChargeParticlesMinSize * Scale;
	FX.SizeWidth.Base = ChargeParticlesMinSize * Scale;
	FX.SizeLength.Base = ChargeParticlesMinSize * Scale;
	FX.AngularSpreadWidth.Base = ChargeParticlesMinSize * Scale;
	FX.AngularSpreadHeight.Base = ChargeParticlesMinSize * Scale;
	FX.SpinRate.Base = ChargeParticlesMinSize * Scale;
}

event Tick (float DeltaTime)
{
	local Vector WandEndPoint;
	local float Scale;

	Super.Tick(DeltaTime);

	if ( (Pawn(Owner) != None) && (Pawn(Owner).Weapon == self) )
	{
		if ( ChargeParticles.bEmit || LumosGlow.bLumosOn )
		{
			if ( bSpellCharges && (fSpellCharge < 1.0) )
			{
				local float SpellChargeScaled;

				SpellCharge = FClamp(SpellCharge + DeltaTime, 0.0, SpellChargeTime)
				SpellChargeScaled = SpellCharge / SpellChargeTime;

				ScaleParticles(ChargeParticles,GetChargeParticleFXScale(SpellChargeScaled));
			}

			WandEndPoint = GetWandEndPoint();
			
			if ( fxChargeParticles != None )
			{
				ChargeParticles.SetLocation(WandEndPoint);
			}
		}
	}

	if ( LumosGlow.bLumosOn )
	{
		LumosGlow.UpdateLocation(WandEndPoint);
	}

	if (bPointing && PlayerHarry.HarryAnimChannel.IsCasting() && PlayerHarry.bAltFire == 0)
	{
		StopAimSound();

		if (PlayerHarry.IsDueling())
		{
			if (CurrentSpell == class'spellDuelExpelliarmus')
			{
				PlaySound(class'spellDuelExpelliarmus'.Default.CastSound);
			}
		}
	}
}

function FlashChargeParticles (Class<ParticleFX> fxClass)
{
	ChargeParticles.Destroy();
	ChargeParticles = Spawn(fxClass);
}

function CastSpell (optional Actor aTarget, optional Vector aTargetOffset, optional Class<baseSpell> spellClass)
{
	local bool bUseWeaponForProjRot;

	if ( aTarget == self )
	{
		bUseWeaponForProjRot = True;
		aTarget = None;
	}

	if ( spellClass != None )
	{
		CurrentSpell = spellClass;
	}
	else if ( bAutoSelectSpell && (aTarget != None) )
	{
		ChooseSpell(aTarget.eVulnerableToSpell);
	}

	if ( CurrentSpell == None )
	{
		return;
	}

	LastCastedSpell = baseSpell(FireSpell(CurrentSpell,AltProjectileSpeed,False,bUseWeaponForProjRot,aTarget));
	LastCastedSpell.InitSpell(Owner,aTarget,aTargetOffset,fSpellCharge,self);
	LastCastedSpell.PlayIncantationSound(Owner);

	StopChargingSpell();

	if ( aTarget.IsA('HPawn') && (VSize(Location - aTarget.Location) < AutoHitDistance) )
	{
		LastCastedSpell.ProcessTouch(aTarget,aTarget.Location);
	}
	else if ( aTarget.IsA('harry') )
	{
		if ( PlayerHarry.Difficulty == DifficultyMedium )
		{
			LastCastedSpell.Speed *= 1.8;
		}
		else if ( PlayerHarry.Difficulty == DifficultyHard )
		{
			LastCastedSpell.Speed *= 2.5;
		}
	}
}

function PrimaryFireAction()
{
	bPointing = True;
	
	PlayerHarry.ResetFired();
	HPConsole(Player.Console).ResetSpace();

	PlayerHarry.HarryAnimChannel.GotoStateCasting();
	PlayerHarry.HarryAnimType = AT_Combine;

	StartAimSound();
}

function StartAimSound()
{

}

function StopAimSound()
{

}

function Projectile FireSpell (Class<Projectile> ProjClass, float ProjSpeed, bool bWarn, optional bool bUseWeaponForProjRot, optional Actor aTarget)
{
	local Vector vStart;
	local Vector vEnd;
	local float fDistance;
	local Rotator R;
	local Projectile proj;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);

	vStart = Pawn(Owner).WeaponLoc + (Vec(0.0,0.0,20.0) >> Pawn(Owner).WeaponRot);

	if ( bUseWeaponForProjRot )
	{
		R = Pawn(Owner).WeaponRot;
	}
	else
	{
		if ( Owner.IsA('harry') )
		{
			R = harry(Owner).Cam.Rotation;
		}
		else
		{
			R = Pawn(Owner).Rotation;
		}
	}

	proj = Spawn(ProjClass,Owner,,vStart,R);

	if ( aTarget.IsA('BossRailMove') )
	{
		baseSpell(proj).SeekSpeed *= 0.25;
	}

	if ( proj == None )
	{
		if ( Pawn(Owner).IsA('PlayerPawn') )
		{
			vStart = PlayerPawn(Owner).Location + Vec(0.0,0.0,PlayerPawn(Owner).EyeHeight);
		}
		else if ( Pawn(Owner).IsA('Pawn') )
		{
			vStart = Pawn(Owner).Location;
		}

		proj = Spawn(ProjClass,Owner,,vStart,R);
	}

	return proj;
}

function bool IsLumosOn()
{
	return PlayerHarry.bLumosOn;
}

function LumosTurnOn()
{
	LumosGlow.TurnOn();
}

function LumosTurnOff()
{
	Lumosglow.TurnOff();
}

function Texture GetSpellIcon()
{
	if ( CurrentSpell != None )
	{
		return CurrentSpell.Default.SpellIcon;
	}
	else
	{
		return None;
	}
}

function Inventory SpawnCopy (Pawn Other)
{
	local Inventory Copy;

	Copy = Super.SpawnCopy(Other);
	return Copy;
}

function BecomeItem()
{
	Super.BecomeItem();
	bHidden = False;
}

function BecomePickup()
{
	Super.BecomePickup();
}

defaultproperties
{
    bAutoSelectSpell=True

    AutoHitDistance=128.00

    ChargeParticleFXClass=Class'HPParticle.Skurge_fly'

    PickupAmmoCount=1

    FireOffset=(X=0.00,Y=-6.00,Z=-7.00)

    DeathMessage="%k inflicted magic damage upon %o with the %w."

    AutoSwitchPriority=4

    InventoryGroup=0

    PickupMessage="You got Harry's wand"

    ItemName="Wand"

    ThirdPersonMesh=SkeletalMesh'HPModels.WandMesh'

    Mesh=SkeletalMesh'HPModels.WandMesh'

    CollisionRadius=28.00

    CollisionHeight=8.00

    Mass=50.00
	
	// Metallicafan212:	Needed to restore base UE1 behavior to weapons
	bRespectHidden=true

}
