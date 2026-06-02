//==========================================================================//
// SpellCursor.
//
// This class handles the visible cursor, line trace to detect and target
// a compatible actor, and positioning the spell gesture.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class SpellCursor extends ParticleFX;

//== Imports ==//
#exec OBJ LOAD FILE=..\Textures\SpellShapes.utx PACKAGE=SpellShapes.SpellFX	// Import the SpellShapes texture package.

//== Consts ==//
const MAX_GESTURE_SIZE = 100.0f;			// Maximum spell gesture size.
const MIN_GESTURE_SIZE = 50.0f;				// Minimum spell gesture size.

//== General ==//
var bool bDebugMode;						// Are we in debug mode? Enables additional logging.
var globalconfig bool bSpellCursorAlwaysOn;	// Should the spell cursor always be on?

//== Line of Sight ==//
var bool bInvisibleCursor;					// Should the cursor be invisible? AKA no cursor particles.
var float fLOS_Distance;					// Distance of the cursor's line of sight. Affects targeting range.
var Vector vLOS_Dir;						// Direction of the cursor's line of sight.
var Vector vLOS_Start;						// Start position of the cursor's line of sight.
var Vector vLOS_End;						// End position of the cursor's line of sight.

//== Cursor Trace ==//
var bool bHitSomething;						// Did the cursor hit anything during the cursor trace?
var Vector vHitLocation;					// Hit position of the cursor trace.
var Vector vHitNormal;						// Hit normal of the cursor trace.
var Vector vLastValidHitPos;				// Position of the last valid hit position.

//== Spell Gesture ==//
var float fFinalGestureDistance;			// Distance value used to determine vGestureOffset when locked on.
var Vector vTargetOffset;					// Position offset when initially positioning the spell gesture.
var Vector vGestureOffset;					// Position offset to apply to spell gesture when locked on.
var GestureSprite SpellGesture;				// Reference to the GestureSprite actor.

//== Wet Textures ==//
var WetTexture FlipendoWetTexture;			// WetTexture to be used when targeting a Flipendo target.
var WetTexture LumosWetTexture;				// WetTexture to be used when targeting a Lumos target.
var WetTexture AlohomoraWetTexture;			// WetTexture to be used when targeting a Alohamora target.
var WetTexture SkurgeWetTexture;			// WetTexture to be used when targeting a Skurge target.
var WetTexture RictusempraWetTexture;		// WetTexture to be used when targeting a Rictusempra target.
var WetTexture DiffindoWetTexture;			// WetTexture to be used when targeting a Diffindo target.
var WetTexture SpongifyWetTexture;			// WetTexture to be used when targeting a Spongify target.

//== Actor References ==//
var harry PlayerHarry;						// Reference to Harry actor.
var Actor aPossibleTarget;					// Reference to possible spell target.
var Actor aCurrentTarget;					// Reference to current spell target.



//=========
// Events
//=========

// Called right before gameplay starts
event PreBeginPlay()
{
	// Set our PlayerHarry reference.
	PlayerHarry = harry(Level.PlayerHarryActor);

	// If bSpellCursorAlwaysOn is false OR bInvisibleCursor is true
	if ( !bSpellCursorAlwaysOn || bInvisibleCursor )
	{
		// Disable particle emission (despite the function name lol)
		EnableEmission(False);
	}

	// Spawn the SpellGesture actor.
	SpellGesture = Spawn(Class'GestureSprite');

	// If we still have no SpellGesture, print a warning.
	if ( SpellGesture == None )
	{
		PlayerHarry.ClientMessage(" Could not create Sprite SpellGesture!!! ");
	}
}

// Called when destroyed.
event Destroyed()
{
	// If we have a SpellGesture, destroy it.
	if ( SpellGesture != None )
	{
		SpellGesture.Destroy();
	}

	// Call parent behavior.
	Super.Destroyed();
}


//================
// LOS & Tracing
//================

// Update the cursor position and trace for a target.
function UpdateCursor (optional bool bJustStopAtClosestPawnOrWall)
{
	local bool bHitActor;
	local float fDotProduct;
	local Vector vFirstHitPos;
	local Actor aHitActor;
	
	// If we're not emitting and we're not intended to be always invisible, do nothing and return.
	if ( bEmit == False &&  !bInvisibleCursor )
	{
		return;
	}

	// Reset the aPossibleTarget and bHitSomething
	aPossibleTarget = None;
	bHitSomething = False;

	// Note: LOS is more or less our line trace. vLOS_Start is where the line trace starts, vLOS_End is where the line trace ends.

	// Set trace start position at the cam target position.
	vLOS_Start = PlayerHarry.Cam.CamTarget.Location;

	// If Harry is dueling
	if ( PlayerHarry.bInDuelingMode )
	{
		// Set the end position so we trace directly in front of Harry with a length of fLOS_Distance
		vLOS_End = PlayerHarry.Location + (vector (PlayerHarry.Rotation) * fLOS_Distance);
	}
	// Otherwise, if Harry is using sword
	else if ( PlayerHarry.bHarryUsingSword )
	{
		// Set the end position so we trace in the direction the camera is looking plus Harry's AimRotOffset with a length of the camera set's fLookAtDistance plus fLOS_Distance
		vLOS_End = PlayerHarry.Cam.Location + (vector (PlayerHarry.Cam.Rotation + PlayerHarry.AimRotOffset) * (PlayerHarry.Cam.CurrentSet.fLookAtDistance + fLOS_Distance));
	}
	// Otherwise
	else
	{
		// Set the end position so we trace in the direction the camera is looking with a length of the camera set's fLookAtDistance plus fLOS_Distance
		vLOS_End = PlayerHarry.Cam.Location + (PlayerHarry.Cam.vForward * (PlayerHarry.Cam.CurrentSet.fLookAtDistance + fLOS_Distance));
	}

	// Determine the trace direction vector by normalizing the direction from the trace start to the trace end
	vLOS_Dir = Normal(vLOS_End - vLOS_Start);

	// Trace for any actor between the camera position and trace end position, and store the actor, hit location, and hit normal
	aHitActor = Trace(vHitLocation,vHitNormal,vLOS_End,PlayerHarry.Cam.Location);

	// If we hit an actor AND the hit actor is not a BaseHarry (that's an HP1 class, so this always clears)
	if ( (aHitActor != None) && !aHitActor.IsA('BaseHarry') )
	{
		// Set that we hit something
		bHitSomething = True;
		// Determine the new trace end position from the hit location plus our trace direction multiplied by 5
		vLOS_End = vHitLocation + (vLOS_Dir * 5.0);
	}

	// Trace for any actors in our line of sight and do the following for each traced actor
	foreach TraceActors(Class'Actor',aHitActor,vHitLocation,vHitNormal,vLOS_End,vLOS_Start)
	{
		// If the hit actor is our owner OR is Harry OR is not a Pawn, GridMover, or spellTrigger
		if ( aHitActor == Owner || aHitActor.IsA('harry') ||  (!aHitActor.IsA('Pawn') &&  !aHitActor.IsA('GridMover') &&  !aHitActor.IsA('spellTrigger')) )
		{
			// Continue to the next traced actor, if any
			continue;
		}

		// If we're emitting and we're in debug mode, print what actor we hit
		if ( bEmit && bDebugMode )
		{
			PlayerHarry.ClientMessage(" TraceActors Hit actor -> " $ string(aHitActor));
		}

		// If we have not hit an actor yet, and the actor isn't hidden
		if (  !bHitActor &&  !aHitActor.bHidden )
		{
			// Set that we hit something and hit an actor
			bHitSomething = True;
			bHitActor = True;
			// Set the first hit position to the current hit position
			vFirstHitPos = vHitLocation;
		}

		// If the hit actor is not vulnerable to any spell
		if ( aHitActor.eVulnerableToSpell == SPELL_None )
		{
			// Continue to the next traced actor, if any
			continue;
		}

		// If Harry has the vulnerable spell OR bJustStopAtClosestPawnOrWall is true
		if ( PlayerHarry.IsInSpellBook(aHitActor.eVulnerableToSpell) || (bJustStopAtClosestPawnOrWall) )
		{
			// If the hit actor is a spellTrigger
			if ( aHitActor.IsA('spellTrigger') )
			{
				// If trigger is not initially active
				if( !spellTrigger(aHitActor).bInitiallyActive )
				{
					// Continue to the next traced actor, if any
					continue;
				}

				// If spellTrigger can only be hit from front AND Harry is not facing the spellTrigger
				if ( spellTrigger(aHitActor).bHitJustFromFront &&  !IsHarryFacingTarget(aHitActor) )
				{
					// Continue to the next traced actor, if any
					continue;
				}
			}

			// If bJustStopAtClosestPawnOrWall is false
			if ( !bJustStopAtClosestPawnOrWall )
			{
				// Set our possible target to the hit actor
				aPossibleTarget = aHitActor;
				// Set our target offset to the hit location minus the possible target's location
				vTargetOffset = vHitLocation - aPossibleTarget.Location;
			}

			// Set the last valid hit position to our current hit position
			vLastValidHitPos = vHitLocation;
		}

		// Set the end position of our LOS/trace to our current hit position
		vLOS_End = vHitLocation;

		// Exit the foreach loop
		break;
	}

	// If we don't have a possible target, but we hit an actor
	if ( aPossibleTarget == None && bHitActor )
	{
		// Set the end of our LOS to the first hit position
		vLOS_End = vFirstHitPos;
	}

	// If we don't have a current target
	if ( aCurrentTarget == None )
	{
		// Move the cursor to the end of our LOS minus the direction of our LOS multiplied by 8 minus the cursor's current position
		MoveSmooth((vLOS_End - (vLOS_Dir * 8.0)) - Location);
		
		// If we have a possible target
		if ( aPossibleTarget != None )
		{
			// Set the spell gesture's location to the end of our LOS
			SpellGesture.SetLocation(vLOS_End);
		}
	}
}

// Sets fLOS_Distance to the value of fNewDistance.
function SetLOSDistance (float fNewDistance)
{
	// If fNewDistance is 0, use the default value.
	if ( fNewDistance == 0 )
	{
		fNewDistance = Default.fLOS_Distance;
	}

	// Set our new distance.
	fLOS_Distance = fNewDistance;

	// Print message with new distance.
	PlayerHarry.ClientMessage("SpellCursor: Set spell distance to " $ string(fNewDistance));
}


//===================
// Targeting
//===================

// Unlocks off of the current target, if valid
function UnLock()
{
	// If we don't have a current target, return false as we don't need to unlock
	if ( aCurrentTarget == None )
	{
		return;
	}

	// Stop the locked on sound
	StopLockedOnSoundLoop();

	// Reset the possible and current targets
	aPossibleTarget = None;
	aCurrentTarget = None;

	// Hide the spell gesture
	SpellGesture.bHidden = True;
}

// Locks onto a given target, if valid
function LockOn (Actor TargetActor)
{
	local float fTargetDepth, fTargetWidth, fTargetHeight;
	local Vector dwh;

	// If the target's collision type is an aligned OR oriented cylinder OR if collision width is 0
	if ( TargetActor.CollideType == CT_AlignedCylinder  || TargetActor.CollideType == CT_OrientedCylinder || TargetActor.CollisionWidth == 0 )
	{
		// Set depth and width from the target's radius, and set the height from the target's height
		dwh = Vec(TargetActor.CollisionRadius,TargetActor.CollisionRadius,TargetActor.CollisionHeight);
	}
	// Otherwise
	else
	{
		// Set the depth from target's radius, width from target's width, and height from target's height
		dwh = Vec(TargetActor.CollisionRadius,TargetActor.CollisionWidth,TargetActor.CollisionHeight);
	}

	// Scale up depth by 2.2 and the target's size modifier
	fTargetDepth = dwh.X * 2.2 * TargetActor.SizeModifier;
	// Scale up width by 2.2 and the target's size modifier
	fTargetWidth = dwh.Y * 2.2 * TargetActor.SizeModifier;
	// Scale up height by 2.2 and the target's size modifier
	fTargetHeight = dwh.Z * 2.2 * TargetActor.SizeModifier;

	// If target actor is none, or Harry is none, or Harry has no weapon, log an error and return
	if ( (TargetActor == None) || (PlayerHarry == None) || (PlayerHarry.Weapon == None) )
	{
		Log("SpellCursor::LockOn() -> ERROR TargetActor or playerHarry or playerHarry.Weapon is invalid!!!");
		return;
	}

	// If the target depth is less than the target width
	if ( fTargetDepth < fTargetWidth )
	{
		// Set the final gesture distance to half the target depth plus 2.0 plus the target's gesture distance
		fFinalGestureDistance = (fTargetDepth * 0.5) + 2.0 + TargetActor.GestureDistance;
	}
	// Otherwise
	else
	{
		// Set the final gesture distance to half the target width plus 2.0 plus the target's gesture distance
		fFinalGestureDistance = (fTargetWidth * 0.5) + 2.0 + TargetActor.GestureDistance;
	}

	// Set the wand's spell to the target's vulnerable spell
	baseWand(PlayerHarry.Weapon).ChooseSpell(TargetActor.eVulnerableToSpell);

	// Set the current target to the target actor
	aCurrentTarget = TargetActor;

	// If the target's gesture should face horizontal only
	if ( aCurrentTarget.bGestureFaceHorizOnly )
	{
		// Set the gesture offset to X = the negated fFinalGestureDistance
		vGestureOffset =  -(Vec(fFinalGestureDistance,0.0,0.0));

		// Turn on the spell gesture's FX
		TurnOnSpellGestureFX(TargetActor.eVulnerableToSpell,TargetActor.Location + TargetActor.CentreOffset + (vGestureOffset >> PlayerHarry.Rotation),fFinalGestureDistance * TargetActor.SizeModifier);
	}
	// Otherwise
	else
	{
		// Set the gesture offset to the normalized direction between the target and Harry multiplied by fFinalGestureDistance
		vGestureOffset = Normal(PlayerHarry.Location - aCurrentTarget.Location) * fFinalGestureDistance;

		// Turn on the spell gesture's FX
		TurnOnSpellGestureFX(TargetActor.eVulnerableToSpell,vLOS_End,fFinalGestureDistance * TargetActor.SizeModifier);
	}

	// If we're in debug mode, log the depth, width, and height of the locked onto target
	if ( bDebugMode )
	{
		PlayerHarry.ClientMessage("LockedOnto Target using Depth:" $ string(fTargetDepth) $ " Width:" $ string(fTargetWidth) $ " Height:" $ string(fTargetHeight));
	}

	// Set the spawn bounds of the cursor particles
	SetSparklesLockedOn(fTargetWidth,fTargetHeight,fTargetDepth);

	// Set the cursor's rotation to the target actor's rotation
	SetRotation(TargetActor.Rotation);

	// Start playing the locked on looping sound
	StartLockedOnSoundLoop();
}

// Turns targeting on. Only has behavior in stateIdle.
function TurnTargetingOn();

// Turns targeting off by unlocking and going to stateIdle.
function TurnTargetingOff()
{
	UnLock();
	GotoState('stateIdle');
}


//===========
// Sound FX
//===========

// Play the locked on sound and looping target sound
function StartLockedOnSoundLoop()
{
	PlaySound(Sound'spell_target_nl3',SLOT_Misc);
	PlaySound(Sound'spell_targetloop',SLOT_Interact);
}

// Stop playing the looping target sound
function StopLockedOnSoundLoop()
{
	StopSound(Sound'spell_targetloop',SLOT_Interact);
}


//============
// Visual FX
//============

// Turn the cursor sparkles off. Does nothing and is never called.
function TurnSparklesOff();


// Set the cursor particles to the idle red particles
function SetSparklesIdle()
{
	ParticlesPerSec.Base = 20.0;
	SourceWidth.Base = 3.0;
	SourceHeight.Base = 3.0;
	SourceDepth.Base = 3.0;
	Speed.Base = 0.0;
	Lifetime.Base = 0.30;
	SizeWidth.Base = 4.0;
	SizeLength.Base = 4.0;
	SizeEndScale.Base = 0.75;
	SpinRate.Base = 4.0;
	SpinRate.Rand = -8.0;
	ParticlesAlive = 10;
	ColorStart.Base.R = 255;
	ColorStart.Base.G = 0;
	ColorStart.Base.B = 0;
	ColorEnd.Base.R = 255;
	ColorEnd.Base.G = 255;
	ColorEnd.Base.B = 255;
}

// Set the cursor particles to the yellow seeking particles
function SetSparklesSeeking()
{
	ParticlesPerSec.Base = 20.0;
	SourceWidth.Base = 10.0;
	SourceHeight.Base = 10.0;
	SourceDepth.Base = 10.0;
	AngularSpreadWidth.Base = 2.0;
	AngularSpreadHeight.Base = 2.0;
	Speed.Base = 5.0;
	Lifetime.Base = 2.0;
	SizeWidth.Base = 8.0;
	SizeWidth.Rand = 10.0;
	SizeLength.Base = 8.0;
	SizeLength.Rand = 10.0;
	SizeEndScale.Base = -0.5;
	SpinRate.Base = 1.0;
	SpinRate.Rand = 20.0;
	Attraction.X = 10.0;
	Attraction.Y = 10.0;
	ParticlesAlive = 10;
	ColorStart.Base.R = 255;
	ColorStart.Base.G = 255;
	ColorStart.Base.B = 255;
	ColorEnd.Base.R = 255;
	ColorEnd.Base.G = 255;
	ColorEnd.Base.B = 0;
}

// Set the cursor particles to the 
function SetSparklesLockedOn (float fTargetWidth, float fTargetHeight, float fTargetDepth)
{
	PlayerHarry.cm("SetSparklesLockedOn -> fTargetWidth=" $ string(fTargetWidth) $ " fTargetHeight=" $ string(fTargetHeight) $ " fTargetDepth=" $ string(fTargetDepth));
	ParticlesPerSec.Base = 60.0;
	SourceWidth.Base = fTargetWidth;
	SourceHeight.Base = fTargetHeight;
	SourceDepth.Base = fTargetDepth;
	AngularSpreadWidth.Base = 2.0;
	AngularSpreadHeight.Base = 2.0;
	Speed.Base = 5.0;
	Lifetime.Base = 2.0;
	SizeWidth.Base = 2.0;
	SizeWidth.Rand = 10.0;
	SizeLength.Base = 2.0;
	SizeLength.Rand = 10.0;
	SizeEndScale.Base = -0.5;
	SpinRate.Base = 1.0;
	SpinRate.Rand = 20.0;
	Attraction.X = 10.0;
	Attraction.Y = 10.0;
	ParticlesAlive = 30;
	bRotateToDesired = True;
	ColorStart.Base.R = 255;
	ColorStart.Base.G = 0;
	ColorStart.Base.B = 255;
	ColorEnd.Base.R = 255;
	ColorEnd.Base.G = 0;
	ColorEnd.Base.B = 255;
}

// Turns on SpellGesture FX.
function TurnOnSpellGestureFX (ESpellType SpellType, Vector vLocation, float fFXSize)
{
	// If we have no target, return so we don't turn on.
	if ( aCurrentTarget == None )
	{
		return;
	}

	// If fFXSize is smaller than the minimum allowed size, clamp it.
	if ( fFXSize < MIN_GESTURE_SIZE )
	{
		fFXSize = MIN_GESTURE_SIZE;
	}
	// Otherwise, if fFXSize is larger than the maximum allowed size, clamp it.
	else if ( fFXSize > MAX_GESTURE_SIZE )
	{
		fFXSize = MAX_GESTURE_SIZE;
	}

	// Set SpellGesture position & rotation.
	SpellGesture.SetLocation(vLocation);
	SpellGesture.SetRotation(PlayerHarry.Rotation);

	// Get the matching WetTexture and set it as the gesture texture.
	SpellGesture.Texture = GetGestureTexture(SpellType);

	// Set the gesture scale to 1.0 so we can see it.
	SpellGesture.DrawScale = 1.0;
}

// Return the proper WetTexture based on the provided ESpellType.
function WetTexture GetGestureTexture (ESpellType SpellType)
{
	// Match based on SpellType
	switch (SpellType)
	{
		// Return the correct imported wet texture -AdamJD
		case SPELL_None:			return None;
		case SPELL_Flipendo:		return FlipendoWetTexture;
		case SPELL_Lumos:			return LumosWetTexture;
		case SPELL_Alohomora:		return AlohomoraWetTexture;
		case SPELL_Skurge:			return SkurgeWetTexture;
		case SPELL_Rictusempra:		return RictusempraWetTexture;
		case SPELL_Diffindo:		return DiffindoWetTexture;
		case SPELL_Spongify:		return SpongifyWetTexture;
	}
}


//================
// Misc. Helpers
//================

// Sets bDebugMode to the value of bOn.
function SetDebugMode (bool bOn)
{
  	bDebugMode = bOn;
}

// Returns whether or not the camera can see a given point in a given FOV.
function bool CanCameraSeeYouInFOV (int rOutsideFOV, Vector Pos)
{
	local Vector vNormal;
	local Vector Dir;
	local Rotator OutsideFOV;

	// Calculates the direction to the given position.
	Dir = Pos - PlayerHarry.Cam.Location;

	// If our target is a spellTrigger AND spellTrigger's bHitJustFromFront is true AND Harry is not facing the target, return false.
	if ( aCurrentTarget.IsA('spellTrigger') && spellTrigger(aCurrentTarget).bHitJustFromFront &&  !IsHarryFacingTarget(aCurrentTarget) )
	{
		return False;
	}

	// If the direction length is longer than our fLOS_Distance value * 1.25, return false.
	if ( VSize(Dir) > fLOS_Distance * 1.25 )
	{
		return False;
	}

	// Prepare the OutsideFOV rotator for the FOV check by subtracting the provided FOV from the current camera yaw.
	OutsideFOV.Yaw = PlayerHarry.Cam.Rotation.Yaw - rOutsideFOV;

	// Determine the normal of the target rotation value.
	vNormal = vector(OutsideFOV);

	// If vNormal and Dir are roughly facing the same direction
	if ( vNormal Dot Dir > 0.0 )
	{
		// Prepare the OutsideFOV rotator for the FOV check in the other direction by adding the provided FOV from the current camera yaw.
		OutsideFOV.Yaw = PlayerHarry.Cam.Rotation.Yaw + rOutsideFOV;

		// Determine the normal of the target rotation value.
		vNormal = vector(OutsideFOV);

		// If vNormal and Dir are roughly facing the same direction, return true
		if ( vNormal Dot Dir > 0.0 )
		{
			return True;
		}
	}

	// If all else fails, return false
	return False;
}

// Returns whether or not Harry is facing a given actor.
function bool IsHarryFacingTarget (Actor aTarget)
{
	local float fDotProduct;
	local Vector X, Y, Z;

	// Get axes from target actor's rotation
	GetAxes(aTarget.Rotation,X,Y,Z);

	// Determine the dot product between the camera's forward direction and X.
	fDotProduct = PlayerHarry.Cam.vForward Dot X;

	// Print our direction and dot.
	PlayerHarry.cm("vLOS_Dir = " $ string(vLOS_Dir) $ " dot =" $ string(fDotProduct));

	// If the dot product is greater or equal to 0.0, return false
	if ( fDotProduct >= 0.0 )
	{
		return False;
	}

	// Otherwise, return true
	return True;
}

// Returns if we have a target, based on if aCurrentTarget is not None.
function bool IsLockedOn()
{
	return aCurrentTarget != None;
}

// Locks onto the possible target, if valid
function bool LookForTarget()
{
	// If we don't have a possible target, return false
	if ( aPossibleTarget == None )
	{
		return False;
	}

	// If we the possible target is the current target, return true
	if ( aPossibleTarget == aCurrentTarget )
	{
		return True;
	}

	// Lock onto the possible target and return true
	LockOn(aPossibleTarget);
	return True;
}


//=========
// States
//=========

// Idle state
auto state stateIdle
{
	// On state enter
	event BeginState()
	{
		// Set sparkles to idle FX
		SetSparklesIdle();

		// If bSpellCursorAlwaysOn is false OR bInvisibleCursor is true
		if ( !bSpellCursorAlwaysOn || bInvisibleCursor )
		{
			// Disable particle emission (despite the function name lol)
			EnableEmission(False);
		}
	}
	
	// On tick
	event Tick (float DeltaTime)
	{
		// Update our cursor
		UpdateCursor(PlayerHarry.bHarryUsingSword);

		// If we hit something, turn cursor particles yellow
		if ( bHitSomething )
		{
			ColorStart.Base.R = 255;
			ColorStart.Base.G = 255;
			ColorStart.Base.B = 0;
		}
		// Otherwise, turn cursor particles red
		else
		{
			ColorStart.Base.R = 255;
			ColorStart.Base.G = 0;
			ColorStart.Base.B = 0;
		}
	}
	
	// Goes to state stateSeeking. Gets called from Harry
	function TurnTargetingOn()
	{
		GotoState('stateSeeking');
	}
	
	begin:
		// If we're in debug mode, print that we're in StateIdle's begin label
		if ( bDebugMode )
		{
			PlayerHarry.ClientMessage("BeginState -> StateIdle");
		}
}

// Seeking state
state stateSeeking
{
	// On state enter
	event BeginState()
	{
		// If bInvisibleCursor is false, enable emission (for real this time)
		if ( !bInvisibleCursor )
		{
			EnableEmission(True);
		}

		// Set sparkles to seeking
		SetSparklesSeeking();
	}
	
	// On state exit. Do nothing
	event EndState();
	
	// On tick
	event Tick (float DeltaTime)
	{
		// Update cursor
		UpdateCursor(PlayerHarry.bHarryUsingSword);

		// If we hit something, turn cursor particles yellow
		if ( bHitSomething )
		{
			ColorStart.Base.R = 255;
			ColorStart.Base.G = 255;
			ColorStart.Base.B = 0;
		}
		// Otherwise, turn cursor particles red
		else
		{
			ColorStart.Base.R = 255;
			ColorStart.Base.G = 0;
			ColorStart.Base.B = 0;
		}

		// If we just locked on or are already locked on, go to stateLockedOn
		if ( LookForTarget() )
		{
			GotoState('stateLockedOn');
		}
	}
	
	begin:
		// If we're in debug mode, print that we're in StateSeeking's begin label
		if ( bDebugMode )
		{
			PlayerHarry.ClientMessage("BeginState -> StateSeeking");
		}
}

// Locked on state
state stateLockedOn
{
	// On tick
	event Tick (float DeltaTime)
	{
		// Update the cursor
		UpdateCursor();

		// If we're not locked on AND we cannot see the current target's position in our outside FOV
		if ( !LookForTarget() &&  !CanCameraSeeYouInFOV(10923,aCurrentTarget.Location) )
		{
			// Unlock from target
			UnLock();

			// Go to seeking state
			GotoState('stateSeeking');
		}

		// Set the cursor location to the current target's location
		SetLocation(aCurrentTarget.Location);

		// If we have a current target AND current target's bGestureFaceHorizOnly is true
		if ( (aCurrentTarget != None) && aCurrentTarget.bGestureFaceHorizOnly )
		{
			// Set spell gesture's location to the target location plus the target's centre offset plus the gesture offset rotated by Harry's rotation
			SpellGesture.SetLocation(aCurrentTarget.Location + aCurrentTarget.CentreOffset + (vGestureOffset >> PlayerHarry.Rotation));

			// Make gesture visible
			SpellGesture.bHidden = False;
		}
		// Otherwise, if we have a possible target
		else if ( aPossibleTarget != None )
		{
			// If the spell gesture is hidden AND possible target is our current target
			if ( SpellGesture.bHidden && aPossibleTarget == aCurrentTarget )
			{
				// Set the gesture's location to the end of our LOS
				SpellGesture.SetLocation(vLOS_End);

				// Make gesture visible
				SpellGesture.bHidden = False;
			}
			// Otherwise
			else
			{
				// Move gesture smoothly towards vLOS_End
				SpellGesture.MoveSmooth((vLOS_End - SpellGesture.Location) * 10.0 * DeltaTime);
			}

			// Set the target offset to the spell gesture's location minus the cursor's location
			vTargetOffset = SpellGesture.Location - Location;
		}
		// Otherwise, if we have a current target
		else if ( aCurrentTarget != None )
		{
			// Set the gesture offset to be in the direction of the current target from Harry multiplied by fFinalGestureDistance
			vGestureOffset = Normal(PlayerHarry.Location - aCurrentTarget.Location) * fFinalGestureDistance;

			// Move gesture smoothly towards the target's location plus the target's centre offset plus the gesture offset
			SpellGesture.MoveSmooth(((aCurrentTarget.Location + aCurrentTarget.CentreOffset + vGestureOffset) - SpellGesture.Location) * 8.0 * DeltaTime);

			// Set the target offset to the spell gesture's location minus the cursor's location
			vTargetOffset = SpellGesture.Location - Location;
		}

		// If we hit something OR we have a current target, turn cursor particles yellow
		if ( bHitSomething || aCurrentTarget != None )
		{
			ColorStart.Base.R = 255;
			ColorStart.Base.G = 255;
			ColorStart.Base.B = 0;
		}
		// Otherwise, turn cursor particles red
		else
		{
			ColorStart.Base.R = 255;
			ColorStart.Base.G = 0;
			ColorStart.Base.B = 0;
		}
	}
	
	begin:
		// If we're in debug mode, print that we're in StateLockedOn's begin label and targeting aCurrentTarget
		if ( bDebugMode )
		{
			PlayerHarry.ClientMessage("BeginState -> StateLockedOn ( " $ string(aCurrentTarget) $ " )");
		}
}


//=====================
// Default Properties
//=====================

defaultproperties
{
    fLOS_Distance=512.00
	
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
	
	//wet texture paths, only way I can get these imported is to set them up here in the default properties -AdamJD

	FlipendoWetTexture=WetTexture'SpellShapes.SpellFX.FlipendoWet1'
	
	LumosWetTexture=WetTexture'SpellShapes.SpellFX.LumosWet1'
	
	AlohomoraWetTexture=WetTexture'SpellShapes.SpellFX.AlohomoraWet1'
	
	SkurgeWetTexture=WetTexture'SpellShapes.SpellFX.SkurgeWet1'
	
	RictusempraWetTexture=WetTexture'SpellShapes.SpellFX.RictusWet1'
	
	DiffindoWetTexture=WetTexture'SpellShapes.SpellFX.DiffindoWet1'
	
	SpongifyWetTexture=WetTexture'SpellShapes.SpellFX.SpongifyWet1'
}

//=====================================================================================================
// This class was originally written 03/21/2002.
// March 21st is Slytherin Pride Day!
// - Moca, 5/20/2026
//=====================================================================================================