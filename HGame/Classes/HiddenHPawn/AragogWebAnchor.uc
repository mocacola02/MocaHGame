//==========================================================================//
// AragogAttendentSpawner.
//
// Spawns SpiderAttendents with configurable parameters.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class AragogWebAnchor extends HiddenHPawn;

//= General Variables =//
var() int iLocation;	// Location index
var Sound HitSound;		// Sound to play when hit
var Aragog Spider;		// Reference to Aragog

//= Particle FX =//
var(VisualFX) ParticleFX fxHitParticleEffect;				// Hit particle actor
var(VisualFX) Class<ParticleFX> fxHitParticleEffectClass;	// Hit particle class to spawn
var(VisualFX) ParticleFX fxReactParticleEffect;				// React particle actor
var(VisualFX) Class<ParticleFX> fxReactParticleEffectClass;	// React particle class to spawn
var(VisualFX) ParticleFX fxHitMeParticleEffect;				// Hit me particle actor
var(VisualFX) Class<ParticleFX> fxHitMeParticleEffectClass;	// Hit me particle class to spawn


//=========
// Events
//=========

// Called after gameplay begins
event PostBeginPlay()
{
	// Call parent behavior
	Super.PostBeginPlay();

	// Find and set Aragog reference
	foreach AllActors(Class'Aragog',Spider)
	{
		break;
	}
}


//=================
// Spell Handling
//=================

// Handle Diffindo spell
function bool HandleSpellDiffindo (optional baseSpell spell, optional Vector vHitLocation)
{
	// Make us no longer vulnerable to spells
	eVulnerableToSpell = SPELL_None;

	// Let Aragog know we got hit
	Spider.AnchorHitBySpell(iLocation);

	// Go to hit by spell state
	GotoState('HitBySpell');

	// Return that spell hit was successful
	return True;
}


//=========
// States
//=========

// Hit by spell state
state HitBySpell
{
	// Begin label
	begin:
		// Set hit sound to ss_ara_incendiohit_0005
		HitSound = Sound'ss_ara_incendiohit_0005';

		// Play hit sound
		PlaySound(HitSound,SLOT_None,RandRange(0.7,1.0),,150000.0,RandRange(0.8,1.0),,False);

		// Spawn hit and react particles
		fxHitParticleEffect = Spawn(fxHitParticleEffectClass,,,Location);
		fxReactParticleEffect = Spawn(fxReactParticleEffectClass,,,Location);

		// Wait for 0.1 seconds
		Sleep(0.1);

		// Shutdown particles
		fxHitParticleEffect.Shutdown();
		fxReactParticleEffect.Shutdown();

		// Kill attached particle FX
		killAttachedParticleFX(0.0);

		// Become hidden
		bHidden = True;
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	fxHitParticleEffectClass=Class'HPParticle.WebFxBase'

	fxReactParticleEffectClass=Class'HPParticle.WebDustBase'

	attachedParticleClass(0)=Class'HPParticle.Diffindo_WebFx'

	bHidden=False

	eVulnerableToSpell=SPELL_Diffindo

	DrawType=DT_Mesh

	Mesh=SkeletalMesh'HPModels.skAragogWebBaseMesh'

	CollisionRadius=40.00

	CollisionHeight=110.00

	bCollideActors=True

	bCollideWorld=True

	bBlockActors=True

	bBlockPlayers=True
}