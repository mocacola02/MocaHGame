//==========================================================================//
// FlyingFordWind.
//
// Marks that the Ford is in a windy area.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class FlyingFordWind extends HiddenHPawn;

//= Constants =//
const BOOL_DEBUG_AI= false;

//= General Variables =//

var() float violence;		// How violent/intense is the wind?
var() float triggerRadius;	// Radius to trigger wind at
var() float triggerHeight;	// Height to trigger wind at

var(VisualFX) ParticleFX fxWindParticleEffect;				// Wind particle actor
var(VisualFX) Class<ParticleFX> fxWindParticleEffectClass;	// Wind particle class to spawn

var bool bTouch;						// Are we being touched
var FlyingFordDirector Director;		// Ref to director
var FlyingFordWindTrigger windTrigger;	// Ref to wind trigger


//=========
// Events
//=========

// Called after gameplay starts
event PostBeginPlay()
{
	// Call parent behavior
	Super.PostBeginPlay();

	// Get director ref
	foreach AllActors(Class'FlyingFordDirector',Director)
	{
		break;
	}

	// Spawn wind trigger
	windTrigger = Spawn(Class'FlyingFordWindTrigger',self,,Location + Vec(0.0,0.0,10.0),Rotation);

	// Set wind trigger collision size
	windTrigger.SetCollisionSize(triggerRadius,triggerHeight);
}

// On tick
event Tick (float DeltaTime)
{
	// Call parent behavior
	Super.Tick(DeltaTime);

	// If we have a particle actor, set its location to our location
	if ( fxWindParticleEffect != None )
	{
		fxWindParticleEffect.SetLocation(Location);
	}
}

// When touched by actor
event Touch (Actor Other)
{
	// Call parent behavior
	Super.Touch(Other);

	// If other is Harry
	if ( Other.IsA('harry') )
	{
		// If not being touched
		if ( !bTouch )
		{
			// Set that we're being touched
			bTouch = True;

			// Call touch event on director
			Director.OnTouchEvent(self,Other);

			// Start wind turbulence
			Director.StartTurbulence(violence,Vector(Rotation));
		}
	}
}

// When untouched by actor
event UnTouch (Actor Other)
{
	// Call parent behavior
	Super.UnTouch(Other);

	// If other is Harry
	if ( Other.IsA('harry') )
	{
		// Call untouch event on director
		Director.OnUnTouchEvent(self,Other);
	}
}

// When bumped by actor
event Bump (Actor Other)
{
	// If in debug mode, log that we've been bumped
	if ( BOOL_DEBUG_AI )
	{
		PlayerHarry.ClientMessage("I have been bumped ");
	}

	// Redirect to Touch
	Touch(Other);
}


//==============
// Particle FX
//==============

// Spawns wind particles
function StartWind()
{
	fxWindParticleEffect = Spawn(fxWindParticleEffectClass,,,Location);
}

// Stops wind particles
function StopWind()
{
	if ( fxWindParticleEffect != None )
	{
		fxWindParticleEffect.Shutdown();
		fxWindParticleEffect.Destroy();
		fxWindParticleEffect = None;
	}
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	violence=100.00

	triggerRadius=800.00

	triggerHeight=300.00

	fxWindParticleEffectClass=Class'HPParticle.CloudWind'

	Tag="FlyingFordWind"

	CollisionRadius=200.00

	CollisionWidth=55.00

	CollisionHeight=150.00

	bCollideActors=True

	bCollideWorld=True
}