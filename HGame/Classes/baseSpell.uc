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


//==================
// Init & Shutdown
//==================

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


//==================
// Effects
//==================

// Scales a given ParticleFX system to a given scale
function ScaleParticles (ParticleFX FX, float Scale)
{
	FX.ParticlesPerSec.Base = 		FX.Default.ParticlesPerSec.Base * Scale;
	FX.SourceHeight.Base = 			FX.Default.SourceHeight.Base * Scale;
	FX.SourceWidth.Base = 			FX.Default.SourceWidth.Base * Scale;
	FX.SourceDepth.Base = 			FX.Default.SourceDepth.Base * Scale;
	FX.SizeWidth.Base = 			FX.Default.SizeWidth.Base * Scale;
	FX.SizeLength.Base = 			FX.Default.SizeLength.Base * Scale;
	FX.AngularSpreadWidth.Base = 	FX.Default.AngularSpreadWidth.Base * Scale;
	FX.AngularSpreadHeight.Base = 	FX.Default.AngularSpreadHeight.Base * Scale;
	FX.SpinRate.Base = 				FX.Default.SpinRate.Base * Scale;
}

// Spawn hit particle effects
function CreateHitEffects (Actor ActorHit, Vector vHitLocation)
{
	local float lTime;

	// If we have an impact sound, play it
	if ( ImpactSound != None )
	{
		PlaySound( ImpactSound, SLOT_None,  1.0, false, 2000.0, 1);
	}

	// If in debug mode, log that we're creating FX
	if ( bUseDebugMode )
	{
		PlayerPawn(Instigator).ClientMessage("Spell::CreateHitEffects using hitFXClass = " $ string(fxHitParticleEffectClass) $ " reactFXClass = " $ string(fxReactParticleEffectClass));
	}

	// If we have a hit particle class
	if ( fxHitParticleEffectClass != None )
	{
		// Spawn the particles
		fxHitParticleEffect = Spawn(fxHitParticleEffectClass);

		// Set the particle location to our hit location
		fxHitParticleEffect.SetLocation(vHitLocation);

		// Make sure the particle rotation is its default rotation
		fxHitParticleEffect.SetRotation(fxHitParticleEffect.Default.Rotation);

		// Set owner to the hit actor
		fxHitParticleEffect.SetOwner(ActorHit);
		
		// If FX is duel rictu or duel mimble hit particle class
		if ( fxHitParticleEffect.IsA('duelRictusempra_hit') || fxHitParticleEffect.IsA('duelMimblewimble_hit') )
		{
			// If rictu hit class, set hit actor to our hit actor
			if ( fxHitParticleEffect.IsA('duelRictusempra_hit') )
			{
				duelRictusempra_hit(fxHitParticleEffect).HitActor = ActorHit;
			}
			// Otherwise, if mimble hit class, set hit actor to our hit actor
			else if ( fxHitParticleEffect.IsA('duelMimblewimble_hit') )
			{
				duelMimblewimble_hit(fxHitParticleEffect).HitActor = ActorHit;
			}

			// If hit actor is Harry, set our lifetime to Harry's fTimeAfterHit
			if ( ActorHit.IsA('harry') )
			{
				lTime = PlayerHarry.fTimeAfterHit;
			}
			// Otherwise, if hit actor is a Duellist, set our lifetime to Duellist's fTimeAfterHit
			else if ( ActorHit.IsA('Duellist') )
			{
				lTime = Duellist(PlayerHarry.DuelOpponent).fTimeAfterHit;
			}
			
			// Set new lifetime
			fxHitParticleEffect.LifeTime.Base = Max(1.0, lTime);
		}
		
		// If spell charge is larger than 0 and we have a wand, scale particles based on charge
		if( SpellCharge > 0 && SpellWand != None )
		{
			ScaleParticles(fxHitParticleEffect, SpellWand.GetChargeParticleFXScale(SpellCharge));
		}
	}
	
	// If we have a react particle fx class
	if( fxReactParticleEffectClass != None )
	{
		// Spawn react particles
		fxReactParticleEffect = spawn(fxReactParticleEffectClass);

		// Set particle location to hit location
		fxReactParticleEffect.SetLocation(vHitLocation);

		// Make sure the particle rotation is its default rotation
		fxReactParticleEffect.SetRotation(fxHitParticleEffect.Default.Rotation);

		// Set particle owner to hit actor
		fxReactParticleEffect.SetOwner(ActorHit);

		// Set the particle source width to the hit actor's collision radius
		fxReactParticleEffect.SourceWidth.Base = HProp(ActorHit).CollisionRadius;
	}
}

// Sets spell charge and scales particles based on the given value
function SetSpellCharge (float fNewCharge)
{
	// Update spell charge
	SpellCharge = fNewCharge;

	// If spell charge is larger than 0 and we have a wand, scale the particles based on the new scale
	if ( (SpellCharge > 0) && (SpellWand != None) )
	{
		ScaleParticles(fxFlyParticleEffect,SpellWand.GetChargeParticleFXScale(SpellCharge));
	}
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


//============
// Spell Hit
//============

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

// Called when on Touch event or when baseWand handles an AutoHit
function ProcessTouch (Actor Other, Vector HitLocation)
{
	// If in debug mode, log that we're calling this
	if ( bUseDebugMode )
	{
		PlayerHarry.ClientMessage("Spell::ProcessTouch : " $ string(self) $ " other :" $ string(Other));
	}

	// If we hit our owner, a spell, or a particle system
	if ( (Other == Owner) || Other.IsA('baseSpell') || Other.IsA('ParticleFX') )
	{
		// If in debug mode, log that we had an invalid touch
		if ( bUseDebugMode )
		{
			PlayerHarry.ClientMessage("Spell: " $ string(self) $ " *INVALID* Touch to :" $ string(Other) $ "will not die yet.");
		}

		// Return and do nothing
		return;
	}
	// Otherwise, if we hit Harry
	else if ( Other.IsA('harry') )
	{
		// Handle hit Harry behavior, and if it returns false
		if ( !OnSpellHitHarry(Other,HitLocation) )
		{
			// If in debug mode, log that we can't hit Harry
			if ( bUseDebugMode )
			{
				PlayerHarry.ClientMessage("Spell:" $ string(self.Name) $ " *INVALID* Touch to Harry:" $ string(Other.Name) $ " NOT RELEVANT, OnSpellHitHarry() returned false!");
			}
			
			// Return and do nothing
			return;
		}

		// If in debug mode, log that we can hit Harry
		if ( bUseDebugMode )
		{
			PlayerHarry.ClientMessage("Spell: " $ string(self) $ " VALID Touch to Harry:" $ string(Other) $ " SpellCharge: " $ string(SpellCharge));
		}

		// Create hit effects
		CreateHitEffects(Other,HitLocation);
	}
	// Otherwise, if we hit an HPawn
	else if ( Other.IsA('HPawn') )
	{
		// Handle hit HPawn behavior, and if it returns false
		if ( !OnSpellHitHPawn(Other,HitLocation) )
		{
			// If in debug mode, log that we can't hit HPawn
			if ( bUseDebugMode )
			{
				PlayerHarry.ClientMessage("Spell:" $ string(self.Name) $ " *INVALID* Touch to HPAWN:" $ string(Other.Name) $ " NOT RELEVANT, OnSpellHitHPawn() returned false!");
			}

			// Return and do nothing
			return;
		}
		
		// If in debug mode, log that we can hit HPawn
		if ( bUseDebugMode )
		{
			PlayerHarry.ClientMessage("Spell: " $ string(self) $ " VALID Touch to HPAWN:" $ string(Other) $ " SpellCharge: " $ string(SpellCharge));
		}

		// Call spell hit behavior on the hit HPawn
		HPawn(Other).OnSpellHit(self,HitLocation);

		// Create hit effects
		CreateHitEffects(Other,HitLocation);
	}
	// If we hit a spellTrigger
	else if ( Other.IsA('spellTrigger') )
	{
		// If in debug mode, log that we can hit it
		if ( bUseDebugMode )
		{
			PlayerHarry.ClientMessage("Spell: " $ string(self) $ " VALID Touch to spellTrigger:" $ string(Other));
		}

		// Create hit effects
		CreateHitEffects(Other,HitLocation);
	}
	// Otherwise
	else
	{
		// If in debug mode, log that we hit some other thing
		if ( bUseDebugMode )
		{
			PlayerHarry.ClientMessage("Spell: " $ string(self) $ " Touched ***UNCLASSIFIED***:" $ string(Other));
		}
	}

	// Set our physics to none
	SetPhysics(PHYS_None);

	// Prepare to shutdown
	OnSpellShutdown();

	// Destroy self
	Destroy();
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


//=================
// Spell Movement
//=================

// Set the spell's direction
function SetSpellDirection (Vector Dir)
{
	// Set current direction to the normalized dir
	CurrentDir = Normal(Dir);

	// Set our desired rotation to rotate towards dir
	DesiredRotation = rotator(CurrentDir);

	// Set our rotation to our desired rotation
	SetRotation(DesiredRotation);

	// Set the particle's rotation to our desired rotation
	fxFlyParticleEffect.SetRotation(DesiredRotation);
}

// Returns the target hit location
function Vector GetTargetHitLocation()
{
	return TargetActor.Location + TargetOffset;
}

// Update our rotation while seeking towards target
function UpdateRotationWithSeeking (float DeltaTime)
{
	local Vector TargetDir;

	// If we have no target actor, return and do nothing
	if ( TargetActor == None )
	{
		return;
	}

	// Get our target direction
	TargetDir = Normal(GetTargetHitLocation() - Location);

	// Set our current direction towards our target direction, accounting for SeekSpeed
	CurrentDir += (TargetDir - CurrentDir) * FMin(1.0,SeekSpeed * DeltaTime);
	
	// Normalize our direction
	CurrentDir = Normal(CurrentDir);

	// Set our desired rotation to rotate towards the current direction
	DesiredRotation = rotator(CurrentDir);

	// Set our rotation to our desired rotation
	SetRotation(DesiredRotation);

	// Set our velocity to the current direction adjusted for our speed
	Velocity = CurrentDir * Speed;
}

// Reflects the direction of the spell back towards the previous owner
function Reflect (Actor aNewOwner, float fNewCharge, float fNewSpeed)
{
	local Pawn PawnOwner;

	// If we have a wand, subtract ourselves from the casted spell list
	if ( SpellWand != None )
	{
		SpellWand.SubtractFromCastedSpellList(self);
	}
	
	// If the new owner is a Pawn
	if ( aNewOwner.IsA('Pawn') )
	{
		// Set our pawn owner to the new pawn
		PawnOwner = Pawn(aNewOwner);

		// If pawn's weapon is a wand
		if ( PawnOwner.Weapon.IsA('baseWand') )
		{
			// Update our wand reference
			SpellWand = baseWand(PawnOwner.Weapon);

			// Add ourselves to the wand's casted spell list
			SpellWand.AddToCastedSpellList(self);
		}
	}

	// Set target actor to our owner
	TargetActor = Owner;

	// Set our owner to now be our new owner
	SetOwner(aNewOwner);

	// Set spell charge to the new charge
	SetSpellCharge(fNewCharge);

	// Set our new spell direction
	SetSpellDirection(GetTargetHitLocation() - Location);

	// Set our new speed
	Speed = fNewSpeed;

	// Calculate our velocity
	Velocity = CurrentDir * Speed;

	// Reset our lifetime
	SpellLifeTime = Default.SpellLifeTime;

	// Reset our lifespan
	LifeSpan = Default.LifeSpan;

	// If in debug mode, log that we reflected
	if ( bUseDebugMode )
	{
		PlayerHarry.ClientMessage("*Spell REFLECTED by " $ string(aNewOwner) $ ", new owner = " $ string(Owner) $ " new target: " $ string(TargetActor) $ " new charge: " $ string(SpellCharge) $ " new speed: " $ string(Speed));
	}
}


//================
// Misc. Helpers
//================

// Returns the spell's default spell icon
static function Texture GetSpellIcon()
{
	return Default.SpellIcon;
}

// Returns whether or not this spell is relevant to movers
function bool IsRelevantToMover()
{
	return True;
}

// Set debug mode
function SetDebugMode (bool bOn)
{
	bUseDebugMode = bOn;
}


//=====================
// Default Properties
//=====================

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

	RemoteRole=ROLE_SimulatedProxy

	LifeSpan=10.00

	Style=STY_Translucent 

	DrawScale=0.30

	bUnlit=True

	CollisionRadius=2.00

	CollisionHeight=2.00

	bProjTarget=True

	LightType=LT_Steady

	LightEffect=LE_NonIncidence

	LightBrightness=201

	LightHue=165

	LightSaturation=72

	LightRadius=10

	bFixedRotationDir=True
}

//=====================================================================================================
// This class was originally written 03/29/2002.
// March 29th is Piano Day!
// - Moca, 6/2/2026
//=====================================================================================================