//==========================================================================//
// baseSpell.
//
// Base class for spell projectiles.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class baseSpell extends Projectile; 

//== Imports ==//
#exec Texture Import File=Textures\Icons\defaultSpellIcon.PNG	GROUP=Icons Name=defaultSpellIcon COMPRESSION=3 UPSCALE=1 Mips=0 Flags=2	// Import default spell icon

//== Debug ==//
var bool bUseDebugMode;

//== Spell Info ==//
var float SpellCharge;		// Amount the spell has been charged, value between 0.0 and 1.0
var float SpellLifeTime;	// Lifetime of the spell
var Texture SpellIcon;		// Icon of the spell
var ESpellType SpellType;	// Type of the spell

//== Movement ==/
var() float SeekSpeed;		// Speed to seek at
var Vector CurrentDir;		// Movement direction
var Vector TargetOffset;	// Offset from target

//== ParticleFX ==//
var(VisualFX) ParticleFX		fxFlyParticleEffect;			// Flying particle actor
var(VisualFX) Class<ParticleFX> fxFlyParticleEffectClass;		// Flying particle class to spawn

var(VisualFX) ParticleFX		fxHitParticleEffect;			// Hit particle actor
var(VisualFX) Class<ParticleFX> fxHitParticleEffectClass;		// Hit particle class to spawn

var(VisualFX) ParticleFX		fxHitWallParticleEffect;		// Hit wall particle actor
var(VisualFX) Class<ParticleFX> fxHitWallParticleEffectClass;	// Hit wall particle class to spawn

var(VisualFX) ParticleFX 		fxReactParticleEffect;			// React particle actor
var(VisualFX) Class<ParticleFX> fxReactParticleEffectClass;		// React particle class to spawn

//== Sounds ==//
var Sound CastSound;				// Cast sound
var string SpellIncantation;		// Spell incantation name
var string QuietSpellIncantation;	// Quiet incantation name

//== Actor References ==//
var Actor TargetActor;		// Target actor reference
var baseWand SpellWand;		// Casting wand reference
var harry PlayerHarry;		// Harry reference



//=========
// Events
//=========

// Called right after gameplay starts
event PostBeginPlay()
{
	// Call parent post begin play behavior
	Super.PostBeginPlay();

	// Get Harry reference
	PlayerHarry = harry(Level.PlayerHarryActor);

	// Set current direction to our rotation
	CurrentDir = vector(Rotation);
}

// On tick
event Tick (float DeltaTime)
{
	// If the decreased lifetime is less than 0.0
	if ( (SpellLifeTime -= DeltaTime) < 0.0 )
	{
		// If using debug mode, log that we're out of lifetime
		if ( bUseDebugMode )
		{
			PlayerHarry.ClientMessage("Spell " $ string(self) $ " LifeTime is up!");
		}

		// Handle spell shutdown
		OnSpellShutdown();

		// Destroy self
		Destroy();
	}
}

// Called when actor goes out of bounds
// Set to do nothing, so spells don't get killed if they clip OOB
event FellOutOfWorld();

// Called when destroyed
event Destroyed()
{
	// If we have a ref to the wand, subtract self from wand's casted spell list
	if ( SpellWand != None )
	{
		SpellWand.SubtractFromCastedSpellList(self);
	}

	// If we have a flying particle, shut it down
	if ( fxFlyParticleEffect != None )
	{
		fxFlyParticleEffect.Shutdown();
	}

	// Handle spell shutdown
	OnSpellShutdown();
}


//=======
// Init
//=======

// Initiate spell
function InitSpell (Actor CastedBy, Actor CastedAt, optional Vector CastedAtOffset, optional float CastedChargeAmount, optional baseWand CastedFromWand)
{
	// Set owner to the actor that casted us
	SetOwner(CastedBy);

	// Set the target actor to the casted at actor
	TargetActor = CastedAt;

	// Set the target offset to the casted at offset
	TargetOffset = CastedAtOffset;

	// Set spell wand to the casting wand
	SpellWand = CastedFromWand;

	// If we have no flying particle actor AND we have a flying particle class
	if ( (fxFlyParticleEffect == None) && (fxFlyParticleEffectClass != None) )
	{
		// Spawn particle actor
		fxFlyParticleEffect = Spawn(fxFlyParticleEffectClass);

		// Set location and rotation to our location and rotation
		fxFlyParticleEffect.SetLocation(Location);
		fxFlyParticleEffect.SetRotation(Rotation);
	}

	// Set charge to the given charge amount
	SetSpellCharge(CastedChargeAmount);

	// If in debug mode, log the init spell results
	if ( bUseDebugMode )
	{
		PlayerHarry.ClientMessage("InitSpell: " $ string(self) $ " owner: " $ string(Owner) $ " target: " $ string(TargetActor) $ " charge: " $ string(SpellCharge) $ " speed: " $ string(Speed));
	}

	// Call on spell init
	OnSpellInit();
}

// Called after InitSpell
// Overridden in children classes
function OnSpellInit();

// Called when the spell shuts down
function OnSpellShutdown();

// Set debug mode
function SetDebugMode (bool bOn)
{
	bUseDebugMode = bOn;
}

// Play the proper incantation sound on Harry
function PlayIncantationSound (Actor Instigator)
{
	if ( Instigator.IsA('harry') )
	{
		harry(Instigator).HandleSpellIncantationSound(SpellType);
	}
	else if ( Instigator.IsA('HPawn') )
	{
		HPawn(Instigator).HandleSpellIncantationSound(SpellType);
	}
}

// Called when spell hits Harry
function bool OnSpellHitHarry (Actor aHit, Vector HitLocation)
{
  return False;
}

// Called when spell hits HPawn
function bool OnSpellHitHPawn (Actor aHit, Vector HitLocation)
{
  return False;
}

// Called when spell hits a wall
function bool OnSpellHitWall (Actor aWall, Vector HitNormal)
{
  fxHitWallParticleEffect = Spawn(fxHitWallParticleEffectClass,self,,Location);
  return True;
}

// Called on hit wall
simulated function HitWall (Vector HitNormal, Actor Wall)
{
	// If wall is of class GridMover
	if ( Wall.IsA('GridMover') )
	{
		// If in debug mode, log that we hit a grid mover
		if ( bUseDebugMode )
		{
			PlayerHarry.ClientMessage("Spell: " $ string(self) $ " HitWall GridMover: " $ string(Wall));
		}

		// Create the spell hit effects
		CreateHitEffects(Wall,Location);
	}
	// Otherwise
	else
	{
		// If in debug mode, log that we hit a wall
		if ( bUseDebugMode )
		{
			PlayerHarry.ClientMessage("Spell: " $ string(self) $ " HitWall Other: " $ string(Wall));
		}

		// If we shouldn't process hitting the wall, return
		if ( !OnSpellHitWall(Wall,HitNormal) )
		{
			return;
		}
	}

	// Shut down spell and destroy
	OnSpellShutdown();
	Destroy();
}

function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( bUseDebugMode )
	{
		PlayerHarry.ClientMessage("Spell::ProcessTouch : " $ string(self) $ " other :" $ string(Other));
	}

	if ( (Other == Owner) || Other.IsA('baseSpell') || Other.IsA('ParticleFX') )
	{
		if ( bUseDebugMode )
		{
			PlayerHarry.ClientMessage("Spell: " $ string(self) $ " *INVALID* Touch to :" $ string(Other) $ "will not die yet.");
		}
		return;
	}
	else if ( Other.IsA('harry') )
	{
		if ( False == OnSpellHitHarry(Other,HitLocation) )
		{
			if ( bUseDebugMode )
			{
				PlayerHarry.ClientMessage("Spell:" $ string(self.Name) $ " *INVALID* Touch to Harry:" $ string(Other.Name) $ " NOT RELEVANT, OnSpellHitHarry() returned false!");
			}
			
			return;
		}

		if ( bUseDebugMode )
		{
			PlayerHarry.ClientMessage("Spell: " $ string(self) $ " VALID Touch to Harry:" $ string(Other) $ " SpellCharge: " $ string(SpellCharge));
		}

		CreateHitEffects(Other,HitLocation);
	}
	else if ( Other.IsA('HPawn') )
	{
		if ( False == OnSpellHitHPawn(Other,HitLocation) )
		{
			if ( bUseDebugMode )
			{
				PlayerHarry.ClientMessage("Spell:" $ string(self.Name) $ " *INVALID* Touch to HPAWN:" $ string(Other.Name) $ " NOT RELEVANT, OnSpellHitHPawn() returned false!");
			}
			return;
		}
		
		if ( bUseDebugMode )
		{
			PlayerHarry.ClientMessage("Spell: " $ string(self) $ " VALID Touch to HPAWN:" $ string(Other) $ " SpellCharge: " $ string(SpellCharge));
		}

		HPawn(Other).OnSpellHit(self,HitLocation);
		CreateHitEffects(Other,HitLocation);
	}
	else if ( Other.IsA('spellTrigger') )
	{
		if ( bUseDebugMode )
		{
			PlayerHarry.ClientMessage("Spell: " $ string(self) $ " VALID Touch to spellTrigger:" $ string(Other));
		}

		CreateHitEffects(Other,HitLocation);
	}
	else
	{
		if ( bUseDebugMode )
		{
			PlayerHarry.ClientMessage("Spell: " $ string(self) $ " Touched ***UNCLASSIFIED***:" $ string(Other));
		}
	}

	SetPhysics(PHYS_None);
	OnSpellShutdown();
	Destroy();
}

static function Texture GetSpellIcon()
{
  return Default.SpellIcon;
}

function bool IsRelevantToMover()
{
  return True;
}

function ScaleParticles (ParticleFX FX, float Scale)
{
  FX.ParticlesPerSec.Base = FX.Default.ParticlesPerSec.Base * Scale;
  FX.SourceHeight.Base = FX.Default.SourceHeight.Base * Scale;
  FX.SourceWidth.Base = FX.Default.SourceWidth.Base * Scale;
  FX.SourceDepth.Base = FX.Default.SourceDepth.Base * Scale;
  FX.SizeWidth.Base = FX.Default.SizeWidth.Base * Scale;
  FX.SizeLength.Base = FX.Default.SizeLength.Base * Scale;
  FX.AngularSpreadWidth.Base = FX.Default.AngularSpreadWidth.Base * Scale;
  FX.AngularSpreadHeight.Base = FX.Default.AngularSpreadHeight.Base * Scale;
  FX.SpinRate.Base = FX.Default.SpinRate.Base * Scale;
}

function CreateHitEffects (Actor ActorHit, Vector vHitLocation)
{
  //local float Scale;
  local float lTime;

  if ( ImpactSound != None )
  {
    // PlaySound(ImpactSound,0,1.0,False,2000.0,1.0);
	PlaySound( ImpactSound, SLOT_None,  1.0, false, 2000.0, 1);
  }
  if ( bUseDebugMode )
  {
    PlayerPawn(Instigator).ClientMessage("Spell::CreateHitEffects using hitFXClass = " $ string(fxHitParticleEffectClass) $ " reactFXClass = " $ string(fxReactParticleEffectClass));
  }
  if ( fxHitParticleEffectClass != None )
  {
    fxHitParticleEffect = Spawn(fxHitParticleEffectClass);
    fxHitParticleEffect.SetLocation(vHitLocation);
    fxHitParticleEffect.SetRotation(fxHitParticleEffect.Default.Rotation);
    fxHitParticleEffect.SetOwner(ActorHit);
    if ( fxHitParticleEffect.IsA('duelRictusempra_hit') || fxHitParticleEffect.IsA('duelMimblewimble_hit') )
    {
      if ( fxHitParticleEffect.IsA('duelRictusempra_hit') )
      {
        duelRictusempra_hit(fxHitParticleEffect).HitActor = ActorHit;
      } else //{
        if ( fxHitParticleEffect.IsA('duelMimblewimble_hit') )
        {
          duelMimblewimble_hit(fxHitParticleEffect).HitActor = ActorHit;
        }
      //}
      if ( ActorHit.IsA('harry') )
      {
        lTime = PlayerHarry.fTimeAfterHit;
      } else //{
        if ( ActorHit.IsA('Duellist') )
        {
          lTime = Duellist(PlayerHarry.DuelOpponent).fTimeAfterHit;
        }
		
		fxHitParticleEffect.LifeTime.Base = Max(1.0, lTime); //UTPT didn't add this -AdamJD
    }
	
	//UTPT didn't add this -AdamJD
	if( SpellCharge > 0 && SpellWand != None )
	{
		ScaleParticles(fxHitParticleEffect, SpellWand.GetChargeParticleFXScale(SpellCharge));
	}
  }
  
  //UTPT didn't add this -AdamJD
  if( fxReactParticleEffectClass != None )
  {
	  fxReactParticleEffect = spawn(fxReactParticleEffectClass);
	  fxReactParticleEffect.SetLocation(vHitLocation);
	  fxReactParticleEffect.SetRotation(fxHitParticleEffect.Default.Rotation);
	  fxReactParticleEffect.SetOwner(ActorHit);
	  fxReactParticleEffect.SourceWidth.Base = HProp(ActorHit).collisionRadius;
  }
}

function SetSpellDirection (Vector Dir)
{
  CurrentDir = Normal(Dir);
  DesiredRotation = rotator(CurrentDir);
  SetRotation(DesiredRotation);
  fxFlyParticleEffect.SetRotation(DesiredRotation);
}

function Vector GetTargetHitLocation()
{
  return TargetActor.Location + TargetOffset;
}

function UpdateRotationWithSeeking (float fTimeDelta)
{
  local Vector TargetDir;

  if ( TargetActor == None )
  {
    return;
  }
  TargetDir = Normal(GetTargetHitLocation() - Location);
  CurrentDir += (TargetDir - CurrentDir) * FMin(1.0,SeekSpeed * fTimeDelta);
  CurrentDir = Normal(CurrentDir);
  DesiredRotation = rotator(CurrentDir);
  SetRotation(DesiredRotation);
  Velocity = CurrentDir * Speed;
}

function SetSpellCharge (float fNewCharge)
{
  //local float Scale;

  SpellCharge = fNewCharge;
  if ( (SpellCharge > 0) && (SpellWand != None) )
  {
    ScaleParticles(fxFlyParticleEffect,SpellWand.GetChargeParticleFXScale(SpellCharge));
  }
}

function Reflect (Actor aNewOwner, float fNewCharge, float fNewSpeed)
{
  local Pawn PawnOwner;

  if ( SpellWand != None )
  {
    SpellWand.SubtractFromCastedSpellList(self);
  }
  if ( aNewOwner.IsA('Pawn') )
  {
    PawnOwner = Pawn(aNewOwner);
    if ( PawnOwner.Weapon.IsA('baseWand') )
    {
      SpellWand = baseWand(PawnOwner.Weapon);
      SpellWand.AddToCastedSpellList(self);
    }
  }
  TargetActor = Owner;
  SetOwner(aNewOwner);
  SetSpellCharge(fNewCharge);
  SetSpellDirection(GetTargetHitLocation() - Location);
  Speed = fNewSpeed;
  Velocity = CurrentDir * Speed;
  SpellLifeTime = Default.SpellLifeTime;
  LifeSpan = Default.LifeSpan;
  if ( bUseDebugMode )
  {
    PlayerHarry.ClientMessage("*Spell REFLECTED by " $ string(aNewOwner) $ ", new owner = " $ string(Owner) $ " new target: " $ string(TargetActor) $ " new charge: " $ string(SpellCharge) $ " new speed: " $ string(Speed));
  }
}

defaultproperties
{
    SpellIcon=Texture'HGame.Icons.defaultSpellIcon'

    SpellLifeTime=8.00

    SeekSpeed=7.00

    fxHitWallParticleEffectClass=Class'HPParticle.DustCloud02_small'

    Speed=500.00

    Damage=5.00

    ImpactSound=Sound'HPSounds.Magic_sfx.spell_hit'

    bNetTemporary=False

    // RemoteRole=2
	RemoteRole=ROLE_SimulatedProxy

    LifeSpan=10.00

    // Style=3
	Style=STY_Translucent 

    DrawScale=0.30

    bUnlit=True

    CollisionRadius=2.00

    CollisionHeight=2.00

    bProjTarget=True

    // LightType=1
	LightType=LT_Steady

    // LightEffect=13
	LightEffect=LE_NonIncidence

    LightBrightness=201

    LightHue=165

    LightSaturation=72

    LightRadius=10

    bFixedRotationDir=True
}
