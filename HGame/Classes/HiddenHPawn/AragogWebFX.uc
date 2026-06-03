//==========================================================================//
// AragogWebFX.
//
// Hidden actor that manages the ParticleFX for Aragog's web.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class AragogWebFX extends HiddenHPawn;

//= Particle FX =//
var(VisualFX) ParticleFX fxHitParticleEffect;				// Hit particle actor
var(VisualFX) Class<ParticleFX> fxHitParticleEffectClass;	// Hit particle class to spawn
var(VisualFX) ParticleFX fxReactParticleEffect;				// React particle actor
var(VisualFX) Class<ParticleFX> fxReactParticleEffectClass;	// React particle class to spawn


//=========
// Events
//=========

// Called on trigger, goes to triggered state
event Trigger (Actor Other, Pawn EventInstigator)
{
	GotoState('stateTriggered');
}


//=========
// States
//=========

// Default idle state, does nothing
auto state stateIdle
{
}

// Triggered state
state stateTriggered
{
	// Begin label
	begin:
		// Spawn particle fx
		fxHitParticleEffect = Spawn(fxHitParticleEffectClass,,,Location);
		fxReactParticleEffect = Spawn(fxReactParticleEffectClass,,,Location);

		// Wait for 0.2 seconds
		Sleep(0.2);

		// Shutdown particle fx
		fxHitParticleEffect.Shutdown();
		fxReactParticleEffect.Shutdown();

		// Become hidden
		bHidden = True;
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	fxReactParticleEffectClass=Class'HPParticle.WebDustAragog'

	Style=STY_Translucent

	Mesh=SkeletalMesh'HPModels.skAragogWebMesh'
}