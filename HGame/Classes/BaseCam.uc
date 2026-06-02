//==========================================================================//
// BaseCam.
//
// This class acts as *the* camera for the entire game.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class BaseCam extends HPawn;  

//== Consts ==//
// A lot of the consts just get copied to variables on begin play, IDK why they did it this way

const USE_DEBUG_MODE = true;				// Should we be in debug mode? Enables additional debug logging

const DISTANCE_SCALAR_MIN = 0.15;			// Minimum allowed value for fDistanceScalarMin to set on begin play

const PITCH_MOVING_IN_SPREAD = 10000.0;		// Value needed to reach a scalar of zero. AKA if pitch == spread, then fDistanceScalar = 0.0
const PITCH_MOVING_IN_THRESHOLD = 0.0;		// When pitch reaches this threshold, start to move the camera in towards Harry

const MAX_MOUSE_DELTA_X =  20000.0;			// Maximum value to clamp fMouseDeltaX to
const MIN_MOUSE_DELTA_X = -20000.0; 		// Minimum value to clamp fMouseDeltaX to
const MAX_MOUSE_DELTA_Y =  10000.0;			// Maximum value to clamp fMouseDeltaY to
const MIN_MOUSE_DELTA_Y = -10000.0;			// Minimum value to clamp fMouseDeltaY to

const NUM_USER_SETTINGS= 4;					// Number of user camera settings

//== Camera Mode ==//
enum ECamMode
{
	CM_Startup,
	CM_Idle,
	CM_Transition,
	CM_Standard,
	CM_Quidditch,
	CM_FlyingCar,
	CM_Dueling,
	CM_CutScene,
	CM_Boss,
	CM_Free
};

var ECamMode CameraMode;			// Current camera mode
var ECamMode LastCamMode;			// Previous camera mode
var ECamMode CameraModeTransition;	// Camera mode to be transitioned to

//== Camera Settings ==//
struct CamSettings
{
	var Vector vLookAtOffset;		// Offset applied when looking at a camera target.
	var float fLookAtDistance;		// Distance from look at target.
	var float fRotTightness;		// Tightness when rotating (similar to an acceleration value).
	var float fRotSpeed;			// Rotation speed.
	var float fMoveTightness;		// Tightness when moving (similar to an acceleration value).
	var float fMoveSpeed;			// Movement speed.
};

var CamSettings CurrentSet;			// Current camera settings
var CamSettings CamSetStandard;		// Standard camera settings
var CamSettings CamSetQuidditch;	// Quidditch camera settings
var CamSettings CamSetFlyingCar;	// Flying Car camera settings
var CamSettings CamSetCutScene;		// Cutscene camera settings
var CamSettings CamSetDueling;		// Dueling camera settings
var CamSettings CamSetFree;			// Free Cam camera settings
var CamSettings CamSetBoss;			// Boss camera settings
var CamSettings UserSettings[4];	// User defined camera settings

//== Targeting ==//
var bool bIgnoreTarget;				// Should we ignore the target when doing FlyTo
var BaseCamTarget CamTarget;		// Current camera target

var bool bSyncRotationWithTarget;	// Should we sync our rotation to always face the CamTarget
var bool bSyncPositionWithTarget;	// Should we sync our position with CamTarget using a fixed distance

var float fCurrLookAtDistance;		// Current LookAt distance
var float fDestLookAtDistance;		// Destination LookAt distance

//== Camera Positioning ==//
var float fMouseDeltaX;				// Stored mouse delta X value from Harry
var float fMouseDeltaY;				// Stored mouse delta Y value from Harry

var float fDistanceScalar;			// Distance scalar calculated based on current pitch and spread
var float fDistanceScalarMin;		// Minimum allowed distance scalar
var float fMoveBackTightness;		// Camera's move back tightness when hitting a wall or blocking actor
var float fPitchMovingInThreshold;	// Set from PITCH_MOVING_IN_THRESHOLD
var float fPitchMovingInSpread;		// Set from PITCH_MOVING_IN_SPREAD

var Vector vForward;				// Camera's forward vector

var Vector vCurrPosition;			// Current camera position
var Rotator rCurrRotation;			// Current camera rotation
var Vector vDestPosition;			// Destination camera position
var Rotator rDestRotation;			// Destination camera rotation

var float fCurrentMinPitch;			// Current minimum pitch the camera can have
var float fCurrentMaxPitch;			// Current maximum pitch the camera can have
var Rotator rExtraRotation;			// Additional rotation to be added to final rotation, used for things like camera shake
var Rotator rRotationStep;			// Rotation step applied over time

//== Camera Mode Specific ==//
// Standard Mode
var Vector vSavedPosition;			// Saved standard camera mode position
var Rotator rSavedRotation;			// Saved standard camera mode rotation

// Boss Mode
var() int MaxBossAimRot;			// Max aim rotation when targeting a boss
var Rotator rBossRotationOffset;	// Offset applied when targeting a boss, allows the player to aim while in boss camera mode

// Cutscene Mode
var string cue;						// Cut notify cue to send when done



//============
// BeginPlay
//============

// Called right before gameplay starts
event PreBeginPlay()
{
	// Disable all collision
	SetCollision(False,False,False);
	bCollideWorld = False;

	// Init variables from constants
	fPitchMovingInThreshold = PITCH_MOVING_IN_THRESHOLD;
	fPitchMovingInSpread = PITCH_MOVING_IN_SPREAD;
	fDistanceScalarMin = DISTANCE_SCALAR_MIN;
}

// Called right after gameplay starts
event PostBeginPlay()
{
	// Call parent PostBeginPlay behavior
	Super.PostBeginPlay();

	// Set player reference
	PlayerHarry = harry(Level.PlayerHarryActor);

	// If we don't have a ref to Harry, log warning
	if ( PlayerHarry == None )
	{
		Log("CAMERA CAN NOT FIND HARRY!!!!!!!! in baseCam::PostBeginPlay()");
	}
	
	// If we don't have a cam target already, spawn one
	if ( CamTarget == None )
	{
		CamTarget = Spawn(Class'BaseCamTarget');
	}

	// Set the cam target as our owner
	SetOwner(CamTarget);

	// Set the cam target's camera ref to ourself
	CamTarget.Cam = self;

	// If we don't have a cam target, log warnings
	if ( CamTarget == None )
	{
		PlayerHarry.ClientMessage("baseCam could not create the hiddenPawn CamTarget!");
		Log("CutSceneCam could not create the hiddenPawn CamTarget!");
	}
}

// Initiates position values
function InitPosition(Vector Pos)
{
	// Set destination position
	vDestPosition = Pos;

	// Check if the position collides with the world
	CheckCollisionWithWorld();

	// Make destination position current
	vCurrPosition = vDestPosition;
	SetLocation(vDestPosition);
}

// Initiates rotation values
function InitRotation(Rotator Rot)
{
	// Set destination rotation, ensuring values fit into valid rotation range
	rDestRotation.Yaw = Rot.Yaw & 65535;
	rDestRotation.Pitch = Rot.Pitch & 65535;
	rDestRotation.Roll = Rot.Roll & 65535;

	// Get forward vector from rotation
	vForward = Normal(Vector(DesiredRotation));

	// Make destination rotation current
	rCurrRotation = rDestRotation;
	DesiredRotation = rDestRotation;
	SetRotation(DesiredRotation);
}

// Initiates position and rotation
function InitPositionAndRotation(bool bSnapToNewPosAndRot)
{
	// If the camera should snap to the new position and rotation
	if ( bSnapToNewPosAndRot )
	{
		// Init our rotation
		InitRotation(CamTarget.Rotation);

		// Init our position, accounting for dolly zoom
		InitPosition(CamTarget.Location + ((Vec(-DollyZoomDistance(CurrentSet.fLookAtDistance),0.0,0.0)) >> rDestRotation));
	}
	// Otherwise
	else
	{
		// Set our destination rotation
		SetDestRotation(CamTarget.Rotation);

		// Set our destination position, accounting for dolly zoom
		vDestPosition = CamTarget.Location + ((Vec(-DollyZoomDistance(CurrentSet.fLookAtDistance),0.0,0.0)) >> rDestRotation);

		// Check if the position collides with the world
		CheckCollisionWithWorld();
	}

	// Zero out rotation roll values
	rDestRotation.Roll = 0;
	rCurrRotation.Roll = 0;
}

// Initiates camera settings
function InitSettings(CamSettings CamSet, bool bSyncWithTargetPos, bool bSyncWithTargetRot)
{
	// Set current camera settings
	CurrentSet = CamSet;

	// "Reset" distance scalar and rotation step
	fDistanceScalar = 1.0;
	rRotationStep = rot(0,0,0);

	// Store our current rotation
	rSavedRotation = Rotation;

	// Set if we should sync position and rotation with target
	bSyncPositionWithTarget = bSyncWithTargetPos;
	bSyncRotationWithTarget = bSyncWithTargetRot;
	
	// Set minimum distance scalar from constant
	fDistanceScalarMin = DISTANCE_SCALAR_MIN;

	// Set look at distance, accounting for FOV-related dolly zoom distance
	fCurrLookAtDistance = DollyZoomDistance(CurrentSet.fLookAtDistance);
}

// Initiates camera target
function InitTarget(Actor A)
{
	// Attach camara target to given actor
	CamTarget.SetAttachedTo(A);
	
	// Apply look at offset
	CamTarget.SetOffset(CurrentSet.vLookAtOffset);
}


//==============
// Camera Mode
//==============

// Take string of the mode name and return the matching camera mode
function ECamMode GetModeFromString(string str)
{
	switch( str )
	{
		case "Startup":		return CM_Startup;
		case "Idle":		return CM_Idle;
		case "Transition":	return CM_Transition;
		
		case "Standard":	return CM_Standard;
		case "FlyingCar":	return CM_FlyingCar;
		case "Quidditch":	return CM_Quidditch;
		case "Dueling":		return CM_Dueling;
		case "CutScene":	return CM_CutScene;
		case "Boss":		return CM_Boss;
		
		case "Free":		return CM_Free;

		default:			return CM_Standard;
	}
}

// Set the active camera mode to a given mode
function SetCameraMode(ECamMode eMode)
{
	// Match the camera mode and update the last cam mode, current cam mode, and go to the proper state
	switch( eMode )
	{
		case CM_Startup:	LastCamMode = CameraMode; CameraMode = eMode; GotoState('StateStartup');		break;
		case CM_Idle:		LastCamMode = CameraMode; CameraMode = eMode; GotoState('StateIdle');			break;
		
		// If the user SetCameraMode to Transition, assume the user wants to transition to standard mode
		case CM_Transition:	LastCamMode = CameraMode; TransitionToCameraMode( CM_Standard ); break;
		
		case CM_Standard:	LastCamMode = CameraMode; CameraMode = eMode; GotoState('StateStandardCam');	break;
		case CM_FlyingCar:	LastCamMode = CameraMode; CameraMode = eMode; GotoState('StateFlyingCarCam');	break;
		case CM_Quidditch:	LastCamMode = CameraMode; CameraMode = eMode; GotoState('StateQuidditchCam');	break;
		case CM_Dueling:	LastCamMode = CameraMode; CameraMode = eMode; GotoState('StateDuelingCam');		break;
		case CM_CutScene:	LastCamMode = CameraMode; CameraMode = eMode; GotoState('StateCutSceneCam');	break;
		case CM_Boss:		LastCamMode = CameraMode; CameraMode = eMode; GotoState('StateBossCam');		break;

		case CM_Free:		LastCamMode = CameraMode; CameraMode = eMode; GotoState('StateFreeCam');		break;
		
		
		default: Log("Camera: Trying to set a camera mode that is not supported!!!");
	}
	
	// If in debug mode, log the new camera mode
	if( USE_DEBUG_MODE )
	{
		PlayerHarry.ClientMessage("CameraMode is: " $CameraMode $" with Target:" $CamTarget );
	}
}

// Transition to a given camera mode
function TransitionToCameraMode(ECamMode eMode)
{
	CameraModeTransition = eMode;
	GotoState('StateTransition');
}

//==================
// Camera Settings
//==================

// Print all camera settings
function ShowSettings()
{
    PlayerHarry.ClientMessage("The current camera settings are:");
    PlayerHarry.ClientMessage("-------------------------------------------");
    PlayerHarry.ClientMessage("LookAtOffset:        " 	$ string(CurrentSet.vLookAtOffset));
    PlayerHarry.ClientMessage("LookAtDistance:    " 	$ string(CurrentSet.fLookAtDistance));
    PlayerHarry.ClientMessage("RotTightness:        " 	$ string(CurrentSet.fRotTightness));
    PlayerHarry.ClientMessage("RotSpeed:             "	$ string(CurrentSet.fRotSpeed));
    PlayerHarry.ClientMessage("MoveTightness:     " 	$ string(CurrentSet.fMoveTightness));
    PlayerHarry.ClientMessage("MoveSpeed:          " 	$ string(CurrentSet.fMoveSpeed));
    PlayerHarry.ClientMessage("-------------------------------------------");
    PlayerHarry.ClientMessage("Current mode:       " 	$ string(CameraMode));
    PlayerHarry.ClientMessage("Current pos:          " 	$ string(vCurrPosition));
    PlayerHarry.ClientMessage("Destination pos:      " 	$ string(vDestPosition));
    PlayerHarry.ClientMessage("Current rot:           " $ string(rCurrRotation.Yaw) $ " , " $ string(rCurrRotation.Pitch) $ " , " $ string(rCurrRotation.Roll) $ " ");
    PlayerHarry.ClientMessage("Destination rot:      " 	$ string(rDestRotation.Yaw) $ " , " $ string(rDestRotation.Pitch) $ " , " $ string(rDestRotation.Roll) $ " ");
    PlayerHarry.ClientMessage("fCurrLookAtDistance: " 	$ string(fCurrLookAtDistance));
    PlayerHarry.ClientMessage("fDestLookAtDistance: " 	$ string(fDestLookAtDistance));
    PlayerHarry.ClientMessage("SyncRotationWithTarget: "$ string(bSyncRotationWithTarget));
    PlayerHarry.ClientMessage("SyncPositionWithTarget: "$ string(bSyncPositionWithTarget));
    PlayerHarry.ClientMessage("-------------------------------------------");
    PlayerHarry.ClientMessage("CamTarget loc:                   " 	$ string(CamTarget.Location));
    PlayerHarry.ClientMessage("CamTarget rot:                   " 	$ string(CamTarget.Rotation));
    PlayerHarry.ClientMessage("CamTarget AttachedTo:       " 		$ string(CamTarget.aAttachedTo));
    PlayerHarry.ClientMessage("CamTarget Attached loc:     " 		$ string(CamTarget.aAttachedTo.Location));
    PlayerHarry.ClientMessage("CamTarget attached offset:  " 		$ string(CamTarget.vOffset));
    PlayerHarry.ClientMessage("CamTarget relative:            " 	$ string(CamTarget.bRelative));
}

// Loads user camera settings from a given index
function LoadUserSettings(int i)
{
	// If invalid settings index, print notice if in debug mode, and then do nothing
	if( i > NUM_USER_SETTINGS-1 )
	{
		if( USE_DEBUG_MODE )
		{
			PlayerHarry.ClientMessage("the max user settings index you can have is:" $(NUM_USER_SETTINGS-1) );
		}

		return;
	}
	
	// Set current camera settings to the settings at the given index
	CurrentSet = UserSettings[i];

	// If in debug mode, log the change
	if(USE_DEBUG_MODE)
	{
		PlayerHarry.ClientMessage("Loaded user settings from slot " $i);
	}
}

// Saves user camera settings to a given index
function SaveUserSettings(int i)
{
	// If invalid settings index, print notice if in debug mode, and then do nothing
	if( i > NUM_USER_SETTINGS-1 )
	{
		if( USE_DEBUG_MODE )
		{
			PlayerHarry.ClientMessage("the max user settings index you can have is:" $(NUM_USER_SETTINGS-1));
		}

		return;
	}

	// Set the user settings at a given index to our current camera settings
	UserSettings[i] = CurrentSet;

	// If in debug mode, log the change
	if( USE_DEBUG_MODE )
	{
		PlayerHarry.ClientMessage("Saved user settings into slot " $i);
	}
}


//=====================
// Camera Positioning
//=====================

// Set camera position to Pos
function SetPosition(Vector Pos)
{
	// If camera should sync position with cam target
	if ( bSyncPositionWithTarget )
	{
		// Set look at distance to the distance between the cam position and target position
		CurrentSet.fLookAtDistance = VSize(CamTarget.Location - Location);

		// Update current and destination rotations and positions
		rDestRotation = Rotation;
		rCurrRotation = Rotation;
		vDestPosition = Location;
		vCurrPosition = Location;

		// Set look at distance to the distance between Pos and target position
		CurrentSet.fLookAtDistance = VSize(CamTarget.Location - Pos);

		// Set destination rotation to look towards the camera target
		rDestRotation = rotator(Normal(CamTarget.Location - Pos));
	} 
	// Otherwise, set destination position to Pos
	else 
	{
		vDestPosition = Pos;
	}
}

// Update camera position
function UpdatePosition(float DeltaTime, optional bool bSkipWorldCheck)
{
	local float fTravelScalar;

	// If camera should sync position with cam target
	if ( bSyncPositionWithTarget )
	{
		// Set destination position behind the cam target at the current look distance
		vDestPosition = CamTarget.Location + ((Vec( -fCurrLookAtDistance,0.0,0.0)) >> rCurrRotation);
	}

	// If we should check for world collision, check for it
	if ( !bSkipWorldCheck )
	{
		CheckCollisionWithWorld();
	}

	// If our move tightness is greater than 0.0, calculate the travel scalar to adjust position update speed
	if ( CurrentSet.fMoveTightness > 0.0 )
	{
		fTravelScalar = FMin(1.0,CurrentSet.fMoveTightness * DeltaTime);
	}
	// Otherwise, default to a scalar of 1.0
	else 
	{
		fTravelScalar = 1.0;
	}

	// Move camera towards the destination position at a speed of fTravelScalar
	vCurrPosition += (vDestPosition - vCurrPosition) * fTravelScalar;
	SetLocation(vCurrPosition);
}

// Set destination rotation
function SetDestRotation(Rotator NewRot)
{
	rDestRotation = NewRot;
}

// Set final rotation
function SetFinalRotation(Rotator R)
{
	// Add any extra rotation to the given rotation
	R += rExtraRotation;

	// Reset extra rotation now that it's applied
	rExtraRotation = rot(0,0,0);

	// Set desired rotation and rotation to final rotation
	DesiredRotation = R;
	SetRotation(R);
}

// Update camera rotation
function UpdateRotation(float DeltaTime)
{
	local float fTravelScalar;

	// Adjust our destination by rotation step
	rDestRotation += rRotationStep * DeltaTime;
	
	// If camera should sync rotation with cam target, set current rotation to look at target
	if ( bSyncRotationWithTarget )
	{
		rCurrRotation = rotator(CamTarget.Location - Location);
	}
	// Otherwise
	else 
	{
		// If rotation tightness is greater than 0.0, calculate the travel scalar to adjust rotation update speed
		if ( CurrentSet.fRotTightness > 0.0 )
		{
			fTravelScalar = FMin(1.0,CurrentSet.fRotTightness * DeltaTime);
		}
		// Otherwise, default scalar to 1.0
		else
		{
			fTravelScalar = 1.0;
		}

		// Make current rotation rotate towards the destination rotation at a speed of fTravelScalar
		rCurrRotation += (rDestRotation - rCurrRotation) * fTravelScalar;
	}
	// Update our forward vector
	vForward = Normal(vector(rCurrRotation));

	// Set final rotation value
	SetFinalRotation(rCurrRotation);
}

// Update camera rotation using vectorized rotation values
function UpdateRotationUsingVectors(float DeltaTime)
{
	local float fTravelScalar;
	local Vector vDestRotation;
	local Vector vCurrRotation;

	// Convert destination rotation to a normalized vector
	vDestRotation = Normal(vector(rDestRotation));

	// Set curent rotation to our forward vector
	vCurrRotation = vForward;

	// If camera should sync rotation with cam target, set destination rot to look at the cam target and make it current
	if ( bSyncRotationWithTarget )
	{
		vDestRotation = CamTarget.Location - Location;
		vCurrRotation = vDestRotation;
	}
	// Otherwise
	else 
	{
		// If rotation tightness is greater than 0.0, calculate the travel scalar to adjust rotation update speed
		if ( CurrentSet.fRotTightness > 0.0 )
		{
			fTravelScalar = FMin(1.0,CurrentSet.fRotTightness * DeltaTime);
		}
		// Otherwise, default scalar to 1.0
		else 
		{
			fTravelScalar = 1.0;
		}

		// Make current rotation rotate towards the destination rotation at a speed of fTravelScalar
		vCurrRotation += (vDestRotation - vCurrRotation) * fTravelScalar;
	}

	// Normalize current rotation
	vCurrRotation = Normal(vCurrRotation);

	// Convert vector rotation value to rotator and set it as current rotation
	rCurrRotation = rotator(vCurrRotation);

	// Update our forward vector
	vForward = vCurrRotation;

	// Set final rotation value
	SetFinalRotation(rotator(vCurrRotation));
}

// Apply mouse X delta to the destination yaw
function ApplyMouseXToDestYaw (float DeltaTime, optional bool bApplyToBossOffset)
{
	// Get current mouse delta X from Harry
	fMouseDeltaX = PlayerHarry.SmoothMouseX * DeltaTime;

	// If delta is greater than the max, clamp it
	if ( fMouseDeltaX > MAX_MOUSE_DELTA_X )
	{
		fMouseDeltaX = MAX_MOUSE_DELTA_X;
	} 
	
	// If we shouldn't apply to boss offset, adjust our destination yaw by the delta accounting for rot speed
	if ( !bApplyToBossOffset )
	{
		rDestRotation.Yaw  += fMouseDeltaX * CurrentSet.fRotSpeed;
	}
	// Otherwise
	else
	{
		// Add delta value to boss rotation offset yaw adjusted for rotation speed
		rBossRotationOffset.Yaw += fMouseDeltaX * CurrentSet.fRotSpeed;

		// If offset yaw is greater than the max allowed, clamp it
		if( rBossRotationOffset.Yaw >  MaxBossAimRot )
		{
			rBossRotationOffset.Yaw = MaxBossAimRot;
		}
		// Otherwise, if it is less than the minimum (negated max), clamp it
		else if ( rBossRotationOffset.Yaw < -MaxBossAimRot )
		{
			rBossRotationOffset.Yaw = -MaxBossAimRot;
		}
	}
}

// Apply mouse Y delta to the destination pitch
function ApplyMouseYToDestPitch (float DeltaTime, optional bool bApplyToBossOffset)
{
	// Get current mouse delta Y from Harry
	fMouseDeltaY = PlayerHarry.SmoothMouseY * DeltaTime;

	// If inverted mouse is on, negate delta
	if ( PlayerHarry.bInvertMouse )
	{
		fMouseDeltaY = -fMouseDeltaY;
	}

	// If delta is over the max, clamp it
	if ( fMouseDeltaY > MAX_MOUSE_DELTA_Y )
	{
		fMouseDeltaY = MAX_MOUSE_DELTA_Y;
	}
	// Otherwise, if the delta is under the min, clamp it
	else if ( fMouseDeltaY < MIN_MOUSE_DELTA_Y )
    {
		fMouseDeltaY = MIN_MOUSE_DELTA_Y;
    }
  
	// If we shouldn't apply to boss offset
	if (  !bApplyToBossOffset )
	{
		// Adjust our destination pitch by the delta accounting for rotation speed
		rDestRotation.Pitch += fMouseDeltaY * CurrentSet.fRotSpeed;
	
		// If destination pitch is over the max, clamp it
		if( rDestRotation.Pitch > fCurrentMaxPitch )	
		{	
			rDestRotation.Pitch  = fCurrentMaxPitch;
		}
		// Otherwise, if destination pitch is under the min, clamp it
		else if( rDestRotation.Pitch < fCurrentMinPitch )
		{	
			rDestRotation.Pitch  = fCurrentMinPitch;
		}
	}
	// Otherwise
	else
	{
		// Add delta value to boss rotation offset pitch adjusted for rotation speed
		rBossRotationOffset.Pitch += fMouseDeltaY * CurrentSet.fRotSpeed;
	
		// If offset pitch is over the max, clamp it
		if( rBossRotationOffset.Pitch > MaxBossAimRot )
		{
			rBossRotationOffset.Pitch = MaxBossAimRot;
		}
		// Otherwise, if offset pitch is under the min (negated max), clamp it
		else if ( rBossRotationOffset.Pitch < -MaxBossAimRot )
		{
			rBossRotationOffset.Pitch = -MaxBossAimRot;
		}
	}
}

// Returns whether or not our target positions collide with the world
function bool CheckCollisionWithWorld()
{
	local Vector HitLocation, HitNormal;
	local Vector LookAtPoint, LookFromPoint;
	local Vector vCusionFromWorld;
	local Actor  aHitActor;

	// Set look at point to the cam target's position
	LookAtPoint = CamTarget.Location;

	// If cam target is attached to something AND any of the target offset's values are not zero
	if( CamTarget.aAttachedTo != None && (CamTarget.vOffset.x != 0.0 || CamTarget.vOffset.y != 0.0 || CamTarget.vOffset.z != 0.0) )
	{
		// Trace for an actor and set it as our hit actor, setting HitLocation and HitNormal in the process
		aHitActor = Trace(HitLocation,HitNormal,CamTarget.Location,CamTarget.aAttachedTo.Location,False);

		// If we have a hit actor AND it is a LevelInfo (AKA level geometry)
		if ( (aHitActor != None) && aHitActor.IsA('LevelInfo') )
		{
			// Set look at point near the hit location with some padding
			LookAtPoint = HitLocation + (Normal(CamTarget.aAttachedTo.Location - HitLocation) * 5.0) + HitNormal;

			// Log hit location and normal
			PlayerHarry.ClientMessage("CamTarget HitLoc:" $ string(HitLocation) $ " HitNorm: " $ string(HitNormal));
		}
	}

	// Calculate a "cusion" offset toward the look at point
	vCusionFromWorld = Normal(LookAtPoint - vDestPosition) * 10.0;

	// Set our look from point as the camera's destination position minus the cusion
	LookFromPoint = vDestPosition - vCusionFromWorld;

	// Trace for any actors between the look points and do the following for each traced actor
	foreach TraceActors(Class'Actor',aHitActor,HitLocation,HitNormal,LookFromPoint,LookAtPoint)
	{
		// If the hit actor is the camera owner
		if ( aHitActor == Owner )
		{
			// Continue to the next traced actor, if any
			continue;
		}

		// If the hit actor is a LevelInfo OR the hit actor blocks the camera
		if ( aHitActor.IsA('LevelInfo') || aHitActor.bBlockCamera )
		{
			// Set the destination camera position to the hit location plus cusion
			vDestPosition = HitLocation + vCusionFromWorld;

			// Set the look at distance to the distance between the look at point and destination position
			fDestLookAtDistance = VSize(vDestPosition - LookAtPoint);

			// Make the destination look at distance current
			fCurrLookAtDistance = fDestLookAtDistance;
			
			// Return that we collided
			return true;
		}
	}
	// Return that we have not collided
	return false;
}


//==================
// Distance & FOV
//==================

// Update camera distance
function UpdateDistance(float DeltaTime)
{
	// If current rotation pitch is greater than the move in threshold
	if( rCurrRotation.Pitch > fPitchMovingInThreshold )
	{
		// Set distance scalar, reducing distance as camera pitch increases
		fDistanceScalar = 1.0 - ( rCurrRotation.Pitch / fPitchMovingInSpread );

		// If scalar is less than the minimum allowed, clamp it
		if ( fDistanceScalar < fDistanceScalarMin )
		{
			fDistanceScalar = fDistanceScalarMin;
		}

		// Set destination look to the distance setting multiplied by the scalar
		fDestLookAtDistance = CurrentSet.fLookAtDistance * fDistanceScalar;
	}
	// Otherwise
	else 
	{
		// Set destination look at distance to the distance setting
		fDestLookAtDistance = CurrentSet.fLookAtDistance;
	}
	
	// Adjust the destination distance for any necessary FOV dolly zoom distance
	fDestLookAtDistance = DollyZoomDistance(fDestLookAtDistance);

	// If needed, clamp the current look at distance
	fCurrLookAtDistance = fClamp(fCurrLookAtDistance, 0.0, fDestLookAtDistance);
	
	// If move back tightness is greater than 0.0 AND we are not at the destination distance
	if ( (fMoveBackTightness > 0.0) && (fCurrLookAtDistance != fDestLookAtDistance) )
	{
		// Adjust the distance towards the destination at a rate based on the tightness
		fCurrLookAtDistance += (fDestLookAtDistance - fCurrLookAtDistance) * FMin(1.0,fMoveBackTightness * DeltaTime);
	}
}

// Set FOV to a target angle over a given time and with or without easing
function SetFOV (float fFOV, optional float fTime, optional bool bEaseTo)
{
	local FOVController FOVControl;

	FOVControl = Spawn(Class'FOVController');
	FOVControl.Init(fFOV, fTime, bEaseTo);
}

// Set settings look at distance and current look at distance to given distance
function SetDistance (float fDist)
{
	CurrentSet.fLookAtDistance = fDist;
	fCurrLookAtDistance = fDist;
}

// Determine our distance accounting for FOV dolly zoom
function float DollyZoomDistance(float Distance, optional float CustomFOV)
{
	local float OurFOV;

	// If we are not zoomable, return the base distance
	if(!DollyZoomable())
	{
		return Distance;
	}

	// If FOV is 0.0, use Harry's current FOV angle instead
	if(CustomFOV == 0)
	{
		CustomFOV = PlayerHarry.FOVAngle;
	}

	// Omega: Calc our FOV to radians
	OurFOV = (CustomFOV * Pi)/180.0;

	// Calculate dolly zoom at the given distance and FOV
	return Distance / (Tan(0.5 * OurFOV));
}

// Omega: Necessary to notify camera of FOV settings change
// Overridden in states.
function FOVChanged();

// Omega: Return if we want FOVControllers or other fov altering classes to return Harry to his desired FOV, or 90 (default)
// Overridden in states.
function bool SupportFOV()
{
	return false;
}

// Omega: Should respond to PlayerHarry.bDollyZoomCamera
// Overridden in states.
function bool DollyZoomable()
{
	return false;
}


//=========
// States
//=========

// Startup state, actor's default state
auto state StateStartup
{
	// On state enter. Do nothing
	event BeginState();
  
	begin:
		// Init the camera and default to standard mode
		InitSettings(CamSetStandard,True,False);
		InitTarget(PlayerHarry);
		InitPositionAndRotation(True);
		SetCameraMode( CM_Standard );
}

// Idle state, overridden to do nothing
state stateIdle
{
}

// Transition state
state StateTransition
{
	// On enter state
	event BeginState()
	{
		// Detach camera target from its attach actor
		CamTarget.SetAttachedTo(None);

		// Fly the camera to Harry's position plus the standard offset, easing into place, over the span of 1.0 second
		CamTarget.DoFlyTo( PlayerHarry.location + CamSetStandard.vLookAtOffset, MOVE_TYPE_EASE_TO, 1.0);

		// Re-init settings and rotation
		InitSettings(CamSetStandard,False,True);
		InitRotation(PlayerHarry.Rotation);

		// Set our move tightness to 0.1
		CurrentSet.fMoveTightness = 0.1;
		
		// Set our destination position to Harry's position plus the look at offset, adjusted for the dolly zoom distance
		vDestPosition = PlayerHarry.Location + CamSetStandard.vLookAtOffset + ((Vec( -DollyZoomDistance(CurrentSet.fLookAtDistance, PlayerHarry.DesiredFOV),0.0,0.0)) >> rDestRotation);
		
		// Log the destination rot and current rot
		PlayerHarry.ClientMessage(" 1 DestRot = " $ string(rDestRotation) $ " CurRot = " $ string(rCurrRotation));
		
		// Ease the camera FOV to Harry's desired FOV over the span of 1.0 second
		SetFOV(PlayerHarry.DesiredFOV, 1.0, True);
	}

	// On tick
	event Tick (float DeltaTime)
	{
		// Increase camera tightness
		CurrentSet.fMoveTightness += DeltaTime * 4.0;

		// Update rotation and position
		UpdateRotation(DeltaTime);
		UpdatePosition(DeltaTime);

		// If our current position is mostly at the destination, bypass cutscene
		if ( VSize(vCurrPosition - vDestPosition) <= 0.01 )
		{
			CutBypass();
		}
	}
  
	// Bypass the cutscene
	function CutBypass()
	{
		// Log the transition destination rot, current rot, and target location
		PlayerHarry.ClientMessage(" Transition DestRot = " $ string(rDestRotation) $ " CurRot = " $ string(rCurrRotation) $ "TargetLoc = " $ string(CamTarget.Location));
		
		// Attach the cam target to Harry
		CamTarget.SetAttachedTo(PlayerHarry);

		// Set target offset to standard camera offset
		CamTarget.SetOffset(CamSetStandard.vLookAtOffset);

		// Emit the cut cue notification
		DoCutCueNotify();

		// Set our camera mode to transition mode
		SetCameraMode(CameraModeTransition);

		// Call parent CutBypass behavior
		Super.CutBypass();
	}
	
	// Return that we support FOV
	function bool SupportFOV()
	{
		return true;
	}
	
	// Return whether or not dolly should zoom based on FOV
	function bool DollyZoomable()
	{
		return PlayerHarry.bDollyZoomCamera;
	}
}

// Standard camera state
state StateStandardCam
{
	// Ignore the following events
	ignores TakeDamage, SeePlayer, EnemyNotVisible,
			HearNoise, KilledBy, Trigger, Bump, HitWall,
			HeadZoneChange, FootZoneChange, ZoneChange,
			Falling, WarnTarget, Died, LongFall, PainTimer;
	
	// On enter state
	event BeginState()
	{
		// If in debug mode, log that we entered StateStandardCam
		if ( USE_DEBUG_MODE )
		{
			PlayerHarry.ClientMessage("Camera: BeginState -> StandardCam");
		}

		// Re-init camera
		InitSettings(CamSetStandard,True,False);
		InitTarget(PlayerHarry);
		InitPositionAndRotation(True);
		
		// Omega: Restore FOV angle
		PlayerHarry.FOVAngle = PlayerHarry.DesiredFOV;
	}
  
	// On state exit, store our current rotation
	event EndState()
	{
		rSavedRotation = rCurrRotation;
	}

	// On tick, apply mouse deltas and update our distance, rotation, and position
	event Tick (float DeltaTime)
	{
		ApplyMouseXToDestYaw(DeltaTime);
		ApplyMouseYToDestPitch(DeltaTime);
		UpdateDistance(DeltaTime);
		UpdateRotation(DeltaTime);
		UpdatePosition(DeltaTime);
	}
	
	// Update the FOV angle
	function FOVChanged()
	{
		PlayerHarry.FOVAngle = PlayerHarry.DesiredFOV;
	}
	
	// Return that we support FOV
	function bool SupportFOV()
	{
		return true;
	}
	
	// Return whether or not dolly should zoom based on FOV
	function bool DollyZoomable()
	{
		return PlayerHarry.bDollyZoomCamera;
	}
}

// Quidditch camera state
state StateQuidditchCam
{
	// On enter state
	event BeginState()
	{
		// If we're in debug mode, log that we've entered StateQuidditchCam
		if ( USE_DEBUG_MODE )
		{
			PlayerHarry.ClientMessage("Camera: BeginState -> QuidditchCam");
		}
		
		// Log that we've entered StateQuidditchCam (yes we're doing this twice apparently)
		Log(string(Name) $ " Entered " $ string(GetStateName()) $ " State");

		// Re-init camera
		InitSettings(CamSetQuidditch,True,False);
		InitTarget(PlayerHarry);
		InitPositionAndRotation(True);
		
		// Zoom the camera FOV to 90.0 over the span of 0.5 seconds
		SetFOV(90.0, 0.5, True);
	}
  
	// On tick
	event Tick (float DeltaTime)
	{
		local Vector lookDir;
		local Rotator rSavedCurrRotation;
  
		// Save our current rotation
		rSavedCurrRotation = rCurrRotation;
		
		// Calculate rotation towards the camera target
		rCurrRotation = rotator(CamTarget.Location - vCurrPosition);
		
		// Update the camera position, regardless of any world collisions
		UpdatePosition(DeltaTime,True);

		// Restore the saved current rotation
		rCurrRotation = rSavedCurrRotation;

		// Blend the look direction between the player and target
		lookDir = 0.5 * (PlayerHarry.Location - vCurrPosition) + 0.5 * (CamTarget.Location - vCurrPosition);

		// Set our destination rotation to the look direction
		rDestRotation = rotator(lookDir);

		// Update rotation using vector values
		UpdateRotationUsingVectors(DeltaTime);
	}
}

// Flying Car camera state
state StateFlyingCarCam
{
	// On enter state
	event BeginState()
	{
		// If we're in debug mode, log that we've entered StateFlyingCarCam
		if ( USE_DEBUG_MODE )
		{
			PlayerHarry.ClientMessage("Camera: BeginState -> FlyingCarCam");
		}

		// Re-init camera
		InitSettings(CamSetFlyingCar,True,False);
		InitTarget(PlayerHarry);
		InitPositionAndRotation(True);
	}
  
	// On tick
	event Tick (float DeltaTime)
	{
		local Rotator Rot;
  
		// Set target rotation yaw & pitch to Harry's rotation yaw & pitch, ensuring values fit into valid rotation range
		Rot.Yaw = PlayerHarry.Rotation.Yaw & 65535;
		Rot.Pitch = PlayerHarry.Rotation.Pitch & 65535;

		// Set destination rotation to the calculated rotation
		SetDestRotation(Rot);

		// Update rotation using vector values and update position
		UpdateRotationUsingVectors(DeltaTime);
		UpdatePosition(DeltaTime);
	}
}

// Dueling camera state
state StateDuelingCam
{
	// Ignore the following events
	ignores TakeDamage, SeePlayer, EnemyNotVisible, HearNoise,
			KilledBy, Trigger, Bump, HitWall, HeadZoneChange,
			FootZoneChange, ZoneChange, Falling, WarnTarget,
			Died, LongFall, PainTimer;
  
	// On enter state
	event BeginState()
	{
		local Rotator Rot;
  
		// If we're in debug mode, log that we've entered StateDuelingCam
		if ( USE_DEBUG_MODE )
		{
			PlayerHarry.ClientMessage("Camera: BeginState -> StandardCam");
		}

		// Re-init camera
		InitSettings(CamSetDueling,True,False);
		InitTarget(PlayerHarry);
		InitPositionAndRotation(True);
	}

	// On tick
	event Tick (float DeltaTime)
	{
		UpdateDistance(DeltaTime);
		UpdateRotation(DeltaTime);
		UpdatePosition(DeltaTime);
	}
}

// Cutscene camera state
state StateCutSceneCam
{
	// On enter state
	event BeginState()
	{
		// Omega: Restore 90.0 Degree angle for cutscenes
		PlayerHarry.FOVAngle = 90.0;
		
		// If we're in debug mode, log that we've entered StateCutSceneCam
		if ( USE_DEBUG_MODE )
		{
			PlayerHarry.ClientMessage("Camera: BeginState -> StateCutSceneCam");
		}

		// "Reset" distance scalar and rotation step
		fDistanceScalar = 1.0;
		rRotationStep = rot(0,0,0);

		// Set cam target location to the attached actor location plus the target offset
		CamTarget.SetLocation(CamTarget.aAttachedTo.Location + CamTarget.vOffset);

		// Detach target from attached actor
		CamTarget.aAttachedTo = None;

		// Set current settings to the cutscene camera settings
		CurrentSet = CamSetCutScene;

		// Set target offset to the current offset setting
		CamTarget.SetOffset(CurrentSet.vLookAtOffset);

		// Zero out destination and current rotation roll
		rDestRotation.Roll = 0;
		rCurrRotation.Roll = 0;

		// Set camera to not sync with target position
		bSyncPositionWithTarget = False;

		// Set camera to sync with target rotation
		bSyncRotationWithTarget = True;
	}

	// On tick
	event Tick (float DeltaTime)
	{
		// Call parent tick behavior
		Super.Tick(DeltaTime);

		// Update camera rotation
		UpdateRotation(DeltaTime);

		// If we should sync our position with cam target, update position
		if ( bSyncPositionWithTarget )
		{
			UpdatePosition(DeltaTime);
		}
	}
}

// Boss camera state
state StateBossCam
{
	// On event enter
	event BeginState()
	{
		// If we're in debug mode, log that we've entered StateBossCam
		if ( USE_DEBUG_MODE )
		{
			PlayerHarry.ClientMessage("Camera: BeginState -> BossCam");
		}

		// Re-init camera
		InitSettings(CamSetBoss,True,False);
		InitTarget(PlayerHarry);
		InitPositionAndRotation(False);
		
		// Omega: Restore FOV angle
		PlayerHarry.FOVAngle = PlayerHarry.DesiredFOV;
	}

	// On tick
	event Tick (float DeltaTime)
	{
		local Vector V;
  
		// Apply mouse deltas
		ApplyMouseXToDestYaw(DeltaTime,True);
		ApplyMouseYToDestPitch(DeltaTime,True);

		// If Harry has a boss target, set V to boss' cam target location
		if ( baseBoss(PlayerHarry.BossTarget) != None )
		{
			V = baseBoss(PlayerHarry.BossTarget).GetCamTargetLoc();
		}
		// Otherwise, set V to the boss location
		else 
		{
			V = PlayerHarry.BossTarget.Location;
		}

		// Set destination rotation towards the location of V and add rotation offset
		rDestRotation = rotator(Normal(V - Location));
		rDestRotation += rBossRotationOffset;

		// Update rotation using vector values
		UpdateRotationUsingVectors(DeltaTime);
		
		// Omega: DOLLY CHANGES
		// Boss cam doesn't actually update the distances, and we now need to
		// So I am leaving the file in a nicer state than I started editing it in
		// Essentially ripped from UpdateDistance, but without the pitch scaling

		// Set destination look at distance to adjusted dolly zoom distance
		fDestLookAtDistance = DollyZoomDistance(CurrentSet.fLookAtDistance);
		
		// Omega: And clamp if need be
		fCurrLookAtDistance = fClamp(fCurrLookAtDistance, 0.0, fDestLookAtDistance);

		// If move back tightness is greater than 0.0 AND we are not at our destination distance
		if ( (fMoveBackTightness > 0.0) && (fCurrLookAtDistance != fDestLookAtDistance) )
		{
			// Adjust distance towards the destination at a speed based on tightness
			fCurrLookAtDistance += (fDestLookAtDistance - fCurrLookAtDistance) * FMin(1.0,fMoveBackTightness * DeltaTime);
		}
	
		// Update camera position
		UpdatePosition(DeltaTime);
	}
	
	// Update the FOV angle
	function FOVChanged()
	{
		PlayerHarry.FOVAngle = PlayerHarry.DesiredFOV;
	}
	
	// Return that we support FOV
	function bool SupportFOV()
	{
		return true;
	}
	
	// Return whether or not dolly should zoom based on FOV
	function bool DollyZoomable()
	{
		return PlayerHarry.bDollyZoomCamera;
	}
}

// FreeCam state
state StateFreeCam
{
	// Ignore the following events
	ignores TakeDamage, SeePlayer, EnemyNotVisible, HearNoise,
			KilledBy, Trigger, Bump, HitWall, HeadZoneChange,
			FootZoneChange, ZoneChange, Falling, WarnTarget,
			Died, LongFall, PainTimer;
	
	// On enter state
	event BeginState()
	{
		// If we're in debug mode, log that we've entered StateFreeCam
		if ( USE_DEBUG_MODE )
		{
			PlayerHarry.ClientMessage("Camera: BeginState -> FreeCam");
		}

		// Set camera settings to free cam settings
		CurrentSet = CamSetFree;

		// "Reset" distance scalar and rotation step
		fDistanceScalar = 1.0;
		rRotationStep = rot(0,0,0);

		// Save current rotation
		rSavedRotation = Rotation;
		
		// Set camera to not sync with target position and rotation
		bSyncPositionWithTarget = False;
		bSyncRotationWithTarget = False;
	}

	// On tick
	event Tick (float DeltaTime)
	{
		// Get mouse deltas from Harry
		fMouseDeltaX = PlayerHarry.SmoothMouseX * DeltaTime;
		fMouseDeltaY = PlayerHarry.SmoothMouseY * DeltaTime;

		// Clamp mouse delta X between the min and max
		if ( fMouseDeltaX > MAX_MOUSE_DELTA_X )
		{
			fMouseDeltaX = MAX_MOUSE_DELTA_X;
		}
		else if ( fMouseDeltaX < MIN_MOUSE_DELTA_X )
		{
			fMouseDeltaX = MIN_MOUSE_DELTA_X;
		}

		// Clamp mouse delta Y between the min and max
		if ( fMouseDeltaY > MAX_MOUSE_DELTA_Y )
		{
			fMouseDeltaY = MAX_MOUSE_DELTA_Y;
		} 
		else if ( fMouseDeltaY < MIN_MOUSE_DELTA_Y )
		{
			fMouseDeltaY = MIN_MOUSE_DELTA_Y;
		}

		// If player is pressing forward, move camera forward, otherwise if pressing backward, move camera backward
		if ( baseConsole(PlayerHarry.Player.Console).bForwardKeyDown )
		{
			vDestPosition += (vect(1.00,0.00,0.00) >> Rotation) * CurrentSet.fMoveSpeed * DeltaTime;
		} 
		else if ( baseConsole(PlayerHarry.Player.Console).bBackKeyDown )
		{
			vDestPosition += (vect(-1.00,0.00,0.00) >> Rotation) * CurrentSet.fMoveSpeed * DeltaTime;
		}

		// If player is pressing right, strafe camera right, otherwise if pressing left, strafe camera left
		if ( baseConsole(PlayerHarry.Player.Console).bRightKeyDown )
		{
			vDestPosition += (vect(0.00,1.00,0.00) >> Rotation) * CurrentSet.fMoveSpeed * DeltaTime;
		} 
		else if ( baseConsole(PlayerHarry.Player.Console).bLeftKeyDown )
		{
			vDestPosition += (vect(0.00,-1.00,0.00) >> Rotation) * CurrentSet.fMoveSpeed * DeltaTime;
		}

		// If player is pressing up, shift camera up, otherwise if pressing down, shift camera down
		if ( baseConsole(PlayerHarry.Player.Console).bUpKeyDown )
		{
			vDestPosition += (vect(0.00,0.00,1.00) >> Rotation) * CurrentSet.fMoveSpeed * DeltaTime;
		} 
		else if ( baseConsole(PlayerHarry.Player.Console).bDownKeyDown )
		{
			vDestPosition += (vect(0.00,0.00,-1.00) >> Rotation) * CurrentSet.fMoveSpeed * DeltaTime;
		}

		// Move current position towards the destination position at a speed based on tightness
		vCurrPosition += (vDestPosition - vCurrPosition) * FMin(1.0,CurrentSet.fMoveTightness * DeltaTime);

		// Set camera location to the current calculated position
		SetLocation(vCurrPosition);

		// If player is pressing rotate right, rotate to the right, otherwise if pressing rotate left, rotate to the left
		if ( baseConsole(PlayerHarry.Player.Console).bRotateRightKeyDown )
		{
			rDestRotation.Yaw += CurrentSet.fRotSpeed * DeltaTime;
		}
		else if ( baseConsole(PlayerHarry.Player.Console).bRotateLeftKeyDown )
		{
			rDestRotation.Yaw -= CurrentSet.fRotSpeed * DeltaTime;
		}

		// If player is pressing rotate up, rotate upward, otherwise if pressing rotate down, rotate downward
		if( baseconsole(PlayerHarry.player.console).bRotateUpKeyDown)
		{
			rDestRotation.Pitch += CurrentSet.fRotSpeed * DeltaTime;
		}
		else if ( baseConsole(PlayerHarry.Player.Console).bRotateDownKeyDown )
		{
			rDestRotation.Pitch -= CurrentSet.fRotSpeed * DeltaTime;
		}

		// Adjust destination rotation by the mouse deltas adjsuted by rotation speed
		rDestRotation.Yaw   += fMouseDeltaX * CurrentSet.fRotSpeed;
		rDestRotation.Pitch += fMouseDeltaY * CurrentSet.fRotSpeed;
	
		// Rotate current rotation towards the destination rotation at a speed based on tightness
		rCurrRotation += (rDestRotation - rCurrRotation ) * FMin( 1.0, CurrentSet.fRotTightness * DeltaTime );

		// Set desired rotation to the calculated current rotation, and then rotate
		DesiredRotation = rCurrRotation;
		SetRotation(DesiredRotation);
	}
}

// Handles a given Cut Command and returns if successful
function bool CutCommand (string Command, optional string cue, optional bool bFastFlag)
{
	local bool B;
	local int I;
	local string sActualCommand, sString;
	
	// Set the "actual command" to the first word of the command string
	sActualCommand = ParseDelimitedString(Command," ",1,False);

	// If command is Capture
	if ( sActualCommand ~= "Capture" )
	{
		// Log that we've captured the camera
		PlayerHarry.ClientMessage("Camera Captured");
		
		// Set our mode to Cutscene
		SetCameraMode( CM_CutScene );

		// Return that we handled the command
		return True;
	}
	// Otherwise, if command is Release
	else if ( sActualCommand ~= "Release" )
    {
		// Log that we've released the camera
		PlayerHarry.ClientMessage("Camera Released");

		// Direct the command to the camera target
		CamTarget.CutCommand("Release","",False);
		
		// Set our mode to Standard
		SetCameraMode( CM_Standard );
	}
	// Otherwise, if command is GoHome
	else if ( sActualCommand ~= "GoHome" )
	{
		//Log that we're going home
		Log("*** GoHome CALLED!!!!  loc = " $ string(Location) $ " rot = " $ string(Rotation));

		// Set us to sync our position with the target
        bSyncPositionWithTarget = True;

		// Set our position
        SetPosition(Location);

        // Set our camera mode to Transition
		SetCameraMode( CM_Transition );

		// Set the cut notify cue to the provided cue
        sCutNotifyCue = cue;

		// If going fast
        if ( bFastFlag )
        {
			// Re-init camera
			InitSettings(CamSetStandard,False,True);
			InitRotation(PlayerHarry.Rotation);
			InitPosition(PlayerHarry.Location + CamSetStandard.vLookAtOffset + (Vec( -CurrentSet.fLookAtDistance,0.0,0.0) >> rDestRotation));
			
			// Attach the target to Harry and set the look at offset
			CamTarget.SetAttachedTo(PlayerHarry);
			CamTarget.SetOffset(CamSetStandard.vLookAtOffset);

			// Set camera mode to the intended transition mode
			SetCameraMode(CameraModeTransition);

			// Emit cut cue notification
			DoCutCueNotify();
        }

		// Return that we handled the command
        return True;
	}
	// Otherwise, if command is FlyTo
	else if ( sActualCommand ~= "FlyTo" )
	{
		// Set us to not sync position with target
		bSyncPositionWithTarget = False;

		// If we're not ignoring the target, sync our rotation with it
        if ( !bIgnoreTarget )
		{
			bSyncRotationWithTarget = True;
        }
	}
	// Otherwise, if command is Target
	else if ( sActualCommand ~= "Target" )
	{
		// Handle the target command and return the result
		return CutCommand_ProcessTarget(Command,cue,bFastFlag);
	}
	// Otherwise, if command is IgnoreTargetOn
	else if ( sActualCommand ~= "IgnoreTargetOn" )
	{
		// Set us to ignore the target
		bIgnoreTarget = True;

		// Set us to not sync with the target position and rotation
        bSyncPositionWithTarget = False;
		bSyncRotationWithTarget = False;

		// Set the cut notify cue to the provided cue
		sCutNotifyCue = cue;

		// Emit cut cue notification
		DoCutCueNotify();

		// Return that we handled the command
		return True;
	}
	// Otherwise, if command is IgnoreTargetOff
	else if ( sActualCommand ~= "IgnoreTargetOff" )
	{
		// Set us to not ignore the target
		bIgnoreTarget = False;

		// Set the cut notify cue to the provided cue
		sCutNotifyCue = cue;

		// Emit cut cue notification
		DoCutCueNotify();

		// Return that we handled the command
		return True;
	}
	// Otherwise, if command is Locked
	else if ( sActualCommand ~= "Locked" )
	{
		// Sync our position and rotation with the target
		bSyncPositionWithTarget = True;
		bSyncRotationWithTarget = True;

		// Handle the locked command and return the result
        return CutCommand_ProcessLocked(Command,cue,bFastFlag);
	}
	// Otherwise, if command is Unlock
	else if ( sActualCommand ~= "UnLock" )
	{
		// Do not sync our position with the target
		bSyncPositionWithTarget = False;

		// Sync our rotation with the target
		bSyncRotationWithTarget = True;

		// Set the cut notify cue to the provided cue
		sCutNotifyCue = cue;

		// Emit cut cue notification
		DoCutCueNotify();

		// Return that we handled the command
		return True;
	}
	// Otherwise, if command is FOV
	else if ( sActualCommand ~= "FOV" )
	{
		// Handle the FOV command and return the result
		return CutCommand_ProcessFOV(Command,cue,bFastFlag);
	}
	// Otherwise, if command is Shake
	else if ( sActualCommand ~= "Shake" )
	{
		// Handle the shake command and return the result
		return CutCommand_ProcessShake(Command,cue,bFastFlag);
	}
	// Otherwise, if command is Flash
	else if ( sActualCommand ~= "Flash" )
	{
		// Handle the flash command and return the result
		return CutCommand_ProcessFlash(Command,cue,bFastFlag);
	}
	// Otherwise, if command is FadeOut
	else if ( sActualCommand ~= "FadeOut" )
	{
		// Handle the fade command and return the result
		return CutCommand_ProcessFade(True,Command,cue,bFastFlag);
	}
	// Otherwise, if command is FadeIn
	else if ( sActualCommand ~= "FadeIn" )
	{
		// Handle the fade command and return the result
		return CutCommand_ProcessFade(False,Command,cue,bFastFlag);
	}

	// Call the parent CutCommand behavior and return the result
	return Super.CutCommand(Command,cue,bFastFlag);
}

// Handle FOV command
function bool CutCommand_ProcessFOV (string Command, optional string cue, optional bool bFastFlag)
{
	local bool bEaseTo;
	local int I;
	local float fAngle, fTime;
	local string sString;
	local FOVController FOVControl;
	local TimedCue tcue;

	// Set default FOV angle
	fAngle = 90.0;

	// Set change time to 0.0
	fTime = 0.0;

	// Loop through command words
	for( I = 2; I < 8; I++ )
	{
		// Parse word from command string
		sString = ParseDelimitedString(Command," ",I,False);

		// If command is EaseTo, set to ease to
		if ( sString ~= "EaseTo" )
		{
			bEaseTo = True;
		}
		// Otherwise, if command is Angle=, convert it to a float and set it as our FOV angle
		else if ( Left(sString,6) ~= "Angle=" )
		{
			fAngle = float(Mid(sString,6));
		}
		// Otherwise, if command is Time=, convert it to a float and set it as our time
		else if ( Left(sString,5) ~= "Time=" )
        {
			fTime = float(Mid(sString,5));
        }

		// If command is empty, exit loop
		if ( sString == "" )
		{
			break;
		}
	}

	// If going fast, set change time to 0.0
	if ( bFastFlag )
	{
		fTime = 0.0;
	}

	// Spawn an FOVController
	FOVControl = Spawn(Class'FOVController');

	// Initiate controller with our target angle, change time, and if we should ease to
	FOVControl.Init(fAngle,fTime,bEaseTo);

	// Spawn a TimedCue
	tcue = Spawn(Class'TimedCue');

	// Set the tcue's notify actor to ourself
	tcue.CutNotifyActor = self;

	// Setup the time with our change time and cue
	tcue.SetupTimer(fTime,cue);

	// Return that we handled the command
	return True;
}


// Handle flash command
function bool CutCommand_ProcessFlash (string Command, optional string cue, optional bool bFastFlag)
{
	local bool bUseDefault;
	local int I;
	local float A, R, G, B;
	local float fTime;
	local string sString;
	local FadeViewController FadeController;
	local TimedCue tcue;
	
	// If going fast, immediately end command
	if(bFastFlag)
	{
		CutCue(Cue);
		return true;
	}

	// Set alpha to 0.0
	A = 0.0;

	// Set default bUseDefault to true
	bUseDefault = True;

	// Set default flash time to 0.25 seconds
	fTime = 0.25;

	// Loop through command words
	for( I = 2; I < 8; I++ )
	{
		// Parse word from command string
		sString = ParseDelimitedString(Command," ",I,False);

		// If command is A=, convert string to float to set alpha, and set bUseDefault to false
		if ( Left(sString,2) ~= "A=" )
		{
			A = float(Mid(sString,2));
			bUseDefault = False;
		}
		// Otherwise, if command is R=, convert string to float to set red, and set bUseDefault to false
		else if ( Left(sString,2) ~= "R=" )
		{
			R = float(Mid(sString,2));
			bUseDefault = False;
		}
		// Otherwise, if command is G=, convert string to float to set green, and set bUseDefault to false
		else if ( Left(sString,2) ~= "G=" )
        {
			G = float(Mid(sString,2));
			bUseDefault = False;
        }
		// Otherwise, if command is B=, convert string to float to set blue, and set bUseDefault to false
		else if ( Left(sString,2) ~= "B=" )
		{
			B = float(Mid(sString,2));
			bUseDefault = False;
		}
		// Otherwise, if command is Time=, convert string to float to set change time
		else if ( Left(sString,5) ~= "Time=" )
		{
			fTime = float(Mid(sString,5));
		}
		// Otherwise, if command is blank, exit loop
		else if ( sString == "" )
		{
			break;
		}
	}

	// Normalize color values against max byte value, and clamp between 0.0 and 1.0
	A = FClamp(A / 255,0.0,1.0);
	R = FClamp(R / 255,0.0,1.0);
	G = FClamp(G / 255,0.0,1.0);
	B = FClamp(B / 255,0.0,1.0);

	// Spawn fade controller
	FadeController = Spawn(Class'FadeViewController');

	// If using default, default colors to 1.0
	if ( bUseDefault )
	{
		R = 1.0;
		G = 1.0;
		B = 1.0;
	}

	// If going fast, fade with time 0.0 and end command
	if ( bFastFlag )
	{
		FadeController.Init(A,R,G,B,0.0,True);
		CutCue(cue);
		return True;
	}

	// Fade colors over the span of fTime
	FadeController.Init(A,R,G,B,fTime,True);

	// Spawn TimedCue
	tcue = Spawn(Class'TimedCue');

	// Set tcue's notify actor to self
	tcue.CutNotifyActor = self;

	// Setup cue timer
	tcue.SetupTimer(fTime,cue);

	// Return that we handled the command
	return True;
}

// Handle shake command
function bool CutCommand_ProcessShake (string Command, optional string cue, optional bool bFastFlag)
{
	local int I;
	local float fTime, fMagnitude;
	local string sString;
	local TimedCue tcue;
	
	// Default magnitude to 100.0
	fMagnitude = 100.0;

	// Default shake time to 0.5
	fTime = 0.5;

	// Loop through command words
	for( I = 2; I < 8; I++ )
	{
		// Parse word from command string
		sString = ParseDelimitedString(Command," ",I,False);

		// If command is Magnitude=, convert to float and set as magnitude
		if ( Left(sString,10) ~= "Magnitude=" )
		{
			fMagnitude = float(Mid(sString,10));
		}
		// Otherwise, if command is Time=, convert to float and set as shake time
		else if ( Left(sString,5) ~= "Time=" )
		{
			fTime = float(Mid(sString,5));
		}
		// Otherwise, if command is blank, exit loop
		else if ( sString == "" )
        {
			break;
        }
	}

	// If going fast, call cut cue
	if ( bFastFlag )
	{
		CutCue(cue);
	}
	// Otherwise
	else 
	{
		// Spawn TimedCue
		tcue = Spawn(Class'TimedCue');

		// Set tcue's notify actor to self
		tcue.CutNotifyActor = self;

		// Set up cue timer
		tcue.SetupTimer(fTime,cue);
	}
	
	// Shake view
	PlayerHarry.ShakeView(fTime,fMagnitude,fMagnitude);

	// Return that we handled the command
	return True;
}

// Handle fade command
function bool CutCommand_ProcessFade (bool bFadeOut, string Command, optional string cue, optional bool bFastFlag)
{
	local FadeViewController FadeController;
	local TimedCue tcue;
	local string sString;
	local float A;
	local float R;
	local float G;
	local float B;
	local float fTime;
	local int I;

	// If fading out, set alpha to 255.0
	if ( bFadeOut )
	{
		A = 255.0;
	}

	// Default fade time to 1.0
	fTime = 1.0;

	// Loop through command words
	for( I = 2; I < 8; I++ )
	{
		// Parse word from command string
		sString = ParseDelimitedString(Command," ",I,False);

		// If command is A= and we're fading out, set alpha to converted float
		if ( (Left(sString,2) ~= "A=") && bFadeOut )
		{
			A = float(Mid(sString,2));
		}
		// Otherwise, if command is R= and we're fading out, set red to converted float
		else if ( (Left(sString,2) ~= "R=") && bFadeOut )
		{
			R = float(Mid(sString,2));
		}
		// Otherwise, if command is G= and we're fading out, set green to converted float
		else if ( (Left(sString,2) ~= "G=") && bFadeOut )
        {
			G = float(Mid(sString,2));
        }
		// Otherwise, if command is B= and we're fading out, set blue to converted float
		else if ( (Left(sString,2) ~= "B=") && bFadeOut )
		{
			B = float(Mid(sString,2));
		}
		// Otherwise, if command is Time=, set fade time to converted float
		else if ( Left(sString,5) ~= "Time=" )
		{
			fTime = float(Mid(sString,5));
		}
		// Otherwise, if command is blank, exit loop
		else if ( sString == "" )
		{
			break;
		}
	}

	// Normalize color values against max byte value, and clamp between 0.0 and 1.0
	A = FClamp(A / 255,0.0,1.0);
	R = FClamp(R / 255,0.0,1.0);
	G = FClamp(G / 255,0.0,1.0);
	B = FClamp(B / 255,0.0,1.0);

	// Spawn fade controller
	FadeController = Spawn(Class'FadeViewController');

	// If going fast, fade with time 0.0 and call cue
	if ( bFastFlag )
	{
		FadeController.Init(A,R,G,B,0.0,False);
		CutCue(cue);
		return True;
	}

	// Start fading
	FadeController.Init(A,R,G,B,fTime,False);

	// Spawn TimedCue
	tcue = Spawn(Class'TimedCue');

	// Set tcue's notify actor to self
	tcue.CutNotifyActor = self;

	// Setup cue timer
	tcue.SetupTimer(fTime,cue);

	// Return that we handled the command
	return True;
}

// Handle locked command
function bool CutCommand_ProcessLocked (string Command, optional string cue, optional bool bFastFlag)
{
	//local bool B;	unused
	local int I;
	local string sString;

	// Set look at distance setting to the distance between the camera and the cam target
	CurrentSet.fLookAtDistance = VSize(CamTarget.Location - Location);

	// Set destination and current rotations and positions to current rotation and position
	rDestRotation = Rotation;
	rCurrRotation = Rotation;
	vDestPosition = Location;
	vCurrPosition = Location;

	// Loop through command words
	for( I = 2; I < 15; I++ )
	{
		// Parse word from command
		sString = ParseDelimitedString(Command," ",I,False);

		// If command is distance=, set distance to converted float
		if ( Left(sString,9) ~= "distance=" )
		{
			SetDistance(float(Mid(sString,9)));
		}
		// Otherwise, if command is yaw=, set yaw to converted rotation float
		else if ( Left(sString,4) ~= "yaw=" )
		{
			SetYaw(ConvertDegToRot(float(Mid(sString,4))));
		}
		// Otherwise, if command is pitch=, set pitch to converted rotation pitch
		else if ( Left(sString,6) ~= "pitch=" )
        {
			SetPitch(ConvertDegToRot(float(Mid(sString,6))));
        }
		// Otherwise, if command is roll=, set roll to converted rotation pitch
		else if ( Left(sString,5) ~= "roll=" )
		{
			SetRoll(ConvertDegToRot(float(Mid(sString,5))));
		}
		// Otherwise, if command is yawStep=, set rot step's yaw to converted rotation yaw and don't sync with target
		else if ( Left(sString,8) ~= "yawStep=" )
		{
			rRotationStep.Yaw = ConvertDegToRot( float(Mid(sString,8))); 
			bSyncRotationWithTarget = false;
		}
		// Otherwise, if command is pitchStep=, set rot step's pitch to converted rotation pitch and don't sync with target
		else if ( Left(sString,10) ~= "pitchStep=" )
		{
			rRotationStep.Pitch = ConvertDegToRot( float(Mid(sString,10))); 
			bSyncRotationWithTarget = false;
		}
		// Otherwise, if command is rollStep=, set rot step's roll to converted rotation roll and don't sync with target
		else if ( Left(sString,9) ~= "rollStep=" )
		{
			// rRotationStep.Roll = ConvertDegToRot(float(Mid(sString,9))) = bSyncRotationWithTarget = False;
			rRotationStep.Roll = ConvertDegToRot( float(Mid(sString,9))); 
			bSyncRotationWithTarget = false;
		}
		// Otherwise, if command is rotTightness=, set rot tightness to converted float
		else if ( Left(sString,13) ~= "rotTightness=" )
		{
			SetRotTightness(float(Mid(sString,13)));
		}
		// Otherwise, if command is moveTightness=, set move tightness to converted float
		else if ( Left(sString,14) ~= "moveTightness=" )
		{
			SetMoveTightness(float(Mid(sString,14)));
		}
		// Otherwise, if command is blank, exit loop
		else if ( sString == "" )
		{
			break;
		}
	}

	// Set notify cue to given cue
	sCutNotifyCue = cue;

	// Emit cut cue notification
	DoCutCueNotify();

	// Return that we handled the command
	return True;
}

// Handle target command
function bool CutCommand_ProcessTarget (string Command, optional string cue, optional bool bFastFlag)
{
	local bool B, bPassToTarget;
	local int I;
	local string sActualCommand, sString;

	// Default bPassToTarget to true
	bPassToTarget = True;

	// Parse second word from string
	sString = ParseDelimitedString(Command," ",2,False);

	// If command is flyto, detach target from attached actor
	if ( sString ~= "flyto" )
	{
		CamTarget.aAttachedTo = None;
	}
	// Otherwise, if command is teleport, detach target from attached actor
	else if ( sString ~= "teleport" )
    {
		CamTarget.aAttachedTo = None;
    }
	// Otherwise
	else 
	{
		// Loop through command words
		for( I = 2; I < 20; I++ )
		{
			// Parse word from command
			sString = ParseDelimitedString(Command," ",I,False);

			// If command is attachedto=
			if ( Left(sString,11) ~= "attachedto=" )
			{
				// Do not pass to target
				bPassToTarget = False;

				// Attach target to cut named actor, if this fails, log a warning and return that this command failed
				if ( !CamTarget.SetAttachedToByCutName(Mid(sString,11)) )
				{
					PlayerHarry.ClientMessage("!*!*!* COULD NOT ATTACH TARGET TO: " $ Mid(sString,11));
					return False;
				}
			}
			// Otherwise, if command is x=
			else if ( Left(sString,2) ~= "x=" )
			{
				// Set target offset's X to the converted float
				CamTarget.vOffset.X = float(Mid(sString,2));

				// Set our Z offset to the new offset
				SetZOffset(CamTarget.vOffset.X);

				// Do not pass to target
				bPassToTarget = False;
			}
			// Otherwise, if command is y=
			else if ( Left(sString,2) ~= "y=" )
            {
				// Set target's offset Y to converted float
				CamTarget.vOffset.Y = float(Mid(sString,2));
				
				// Set our Z offset to new offset
				SetZOffset(CamTarget.vOffset.Y);

				// Do not pass to target
				bPassToTarget = False;
            }
			// Otherwise, if command is z=
			else if ( Left(sString,2) ~= "z=" )
			{
				// Set target's offset Z to converted float
				CamTarget.vOffset.Z = float(Mid(sString,2));

				// Set our Z offset to new offset
				SetZOffset(CamTarget.vOffset.Z);
				
				// Do not pass to target
				bPassToTarget = False;
			}
			// Otherwise, if command is relative
			else if ( sString ~= "relative" )
			{
				// Set target to be relative
				CamTarget.bRelative = True;

				// Do not pass to target
				bPassToTarget = False;
			}
			// Otherwise, if command is fixed
			else if ( sString ~= "fixed" )
			{
				// Set target to not be relative
				CamTarget.bRelative = False;

				// Do not pass to target
				bPassToTarget = False;
			}
			// Otherwise, if command is blank, exit loop
			else if ( sString == "" )
			{
				break;
			}
		}
	}

	// If pass to target
	if ( bPassToTarget )
	{
		// Set target notify actor to our notify actor
		CamTarget.CutNotifyActor = CutNotifyActor;

		// Set B to the success result of target's command
		B = CamTarget.CutCommand(ParseDelimitedString(Command," ",2,True),cue,bFastFlag);

		// If failed, set error string to the error of our target
		if ( !B )
		{
			CutErrorString = CamTarget.CutErrorString;
		}

		// Return the result
		return B;
	}

	// Set our notify cue to the given cue
	sCutNotifyCue = cue;

	// Emit cut cue notification
	DoCutCueNotify();

	// Return that we handled the command
	return True;
}

// Bypass the cutscene on ourselves and our target (see definition in Actor)
function CutBypass()
{
	cm("******** baseCam CutBypass.");
	Super.CutBypass();
	CamTarget.CutBypass();
}

// Globally bypass the cutscene on ourselves and our target (see definition in Actor)
function GlobalCutBypass()
{
	cm("******** baseCam GlobalCutBypass.");
	Super.GlobalCutBypass();
	CamTarget.GlobalCutBypass();
}

// Return whether or not the camera can see a given position
function bool CameraCanSeeYou(Vector Pos)
{
	local float dotpr;
	local vector vNormal;
	
	// Get the camera's rotation vector
	vNormal = Vector(Rotation);

	// Calculate the dot product between the camera normal and given position
	dotpr = vNormal.X * (Pos.X - Location.X) + vNormal.Y * (Pos.Y - Location.Y) + vNormal.Z * (Pos.Z - Location.Z);
	
	// If the dot product is greater than 0, return that we can see Pos
	if(dotpr > 0)
	{
		return True;
	}

	// Otherwise, return that we cannot see Pos
	return False;
}

//===============
// Math Helpers
//===============

// Convert rotation value to degrees
function float ConvertRotToDeg	( int iRot )		
{
	return ((float(iRot & 0xFFFF)) / 65536) * 360; 
}

// Convert degrees to rotation value
function float ConvertDegToRot	( float fDeg )		
{ 
	return (fDeg / 360) * 65536; 
}


//=================
// Setter Helpers
//=================

// Set destination yaw to given yaw
function SetYaw (float fYaw)
{
	rDestRotation.Yaw = fYaw;
}

// Set destination pitch to given pitch
function SetPitch (float fPitch)
{
	rDestRotation.Pitch = fPitch;
}

// Set destination roll to given roll
function SetRoll (float fRoll)
{
	rDestRotation.Roll = fRoll;
}

// Set current minimum pitch to given pitch
function SetMinPitch (float fPitch)
{
	fCurrentMinPitch = fPitch;
}

// Set current maximum pitch to given pitch
function SetMaxPitch (float fPitch)
{
	fCurrentMaxPitch = fPitch;
}


// Set rotation step to given rotator
function SetRotStep (Rotator Step)
{
	rRotationStep = Step;
}

// Set rotation step yaw to given yaw
function SetRotStepYaw (float fYaw)
{
	rRotationStep.Yaw = fYaw;
}

// Set rotation step pitch to given pitch
function SetRotStepPitch (float fPitch)
{
	rRotationStep.Pitch = fPitch;
}

// Set rotation step roll to given roll
function SetRotStepRoll (float fRoll)
{
	rRotationStep.Roll = fRoll;
}

// Set move back tightness to given tightness
function SetMoveBackTightness (float fTight)
{
	fMoveBackTightness = fTight;
}

// Set rotation tightness to given tightness
function SetRotTightness (float fTight)
{
	CurrentSet.fRotTightness = fTight;
}

// Set rotation speed to given speed
function SetRotSpeed (float fSpeed)
{
	CurrentSet.fRotSpeed = fSpeed;
}

// Set movement tightness to given tightness
function SetMoveTightness (float fTight)
{
	CurrentSet.fMoveTightness = fTight;
}

// Set movement speed to given speed
function SetMoveSpeed (float fSpeed)
{
	CurrentSet.fMoveSpeed = fSpeed;
}

// Set target actor to given actor of name
function SetTargetActor (name Target)
{
	CamTarget.SetAttachedToByName(Target);
}

// Set cam target offset to given vector
function SetOffset (Vector V)
{
	CamTarget.SetOffset(V);
}

// Set target offset X to given offset
function SetXOffset (float X)
{
	CamTarget.SetXOffset(X);
}

// Set target offset Y to given offset
function SetYOffset (float Y)
{
	CamTarget.SetYOffset(Y);
}

// Set target offset Z to given offset
function SetZOffset (float Z)
{
	CamTarget.SetZOffset(Z);
}

// Set camera mode by string
function SetModeByString (string Str)
{
	SetCameraMode(GetModeFromString(Str));
}

// Set whether we should sync position with target
function SetSyncPosWithTarget (bool bSyncPos)
{
	bSyncPositionWithTarget = bSyncPos;
}

// Set whether we should sync rotation with target
function SetSyncRotWithTarget (bool bSyncRot)
{
	bSyncRotationWithTarget = bSyncRot;
}


//========
// Junk
//========

// Do a simple camera fade. Doesn't actually do anything as return is called immediately.
function DoSimpleFade (bool bFadeIn)
{
	local FadeViewController FadeController;
	
	// Stop function
	return;

	// Spawn fade controller
	FadeController = Spawn(Class'FadeViewController');

	// If fading in, fade in
	if ( bFadeIn )
	{
		FadeController.Init(0.0,0.0,0.0,0.0,1.0,False);
	}
	// Otherwise, fade out
	else 
	{
		FadeController.Init(1.0,0.0,0.0,0.0,1.0,False);
	}
}


//=====================
// Default Properties
//=====================

defaultproperties
{
    bSyncPositionWithTarget=True

    fMoveBackTightness=4.00

    fCurrentMinPitch=-14000.00

    fCurrentMaxPitch=14000.00

    CamSetStandard=(vLookAtOffset=(X=0.00,Y=0.00,Z=55.00),fLookAtDistance=128.00,fRotTightness=8.00,fRotSpeed=4.00,fMoveTightness=0.00,fMoveSpeed=0.00)

    CamSetQuidditch=(vLookAtOffset=(X=0.00,Y=0.00,Z=65.00),fLookAtDistance=175.00,fRotTightness=2.00,fRotSpeed=0.00,fMoveTightness=7.00,fMoveSpeed=0.00)

    CamSetFlyingCar=(vLookAtOffset=(X=0.00,Y=0.00,Z=175.00),fLookAtDistance=400.00,fRotTightness=4.00,fRotSpeed=0.00,fMoveTightness=4.00,fMoveSpeed=0.00)

    CamSetCutScene=(vLookAtOffset=(X=0.00,Y=0.00,Z=0.00),fLookAtDistance=128.00,fRotTightness=2.00,fRotSpeed=5.00,fMoveTightness=0.00,fMoveSpeed=0.00)

    CamSetDueling=(vLookAtOffset=(X=0.00,Y=0.00,Z=45.00),fLookAtDistance=200.00,fRotTightness=8.00,fRotSpeed=4.00,fMoveTightness=3.50,fMoveSpeed=0.00)

    CamSetFree=(vLookAtOffset=(X=0.00,Y=0.00,Z=0.00),fLookAtDistance=0.00,fRotTightness=10.00,fRotSpeed=5.00,fMoveTightness=7.00,fMoveSpeed=600.00)

    CamSetBoss=(vLookAtOffset=(X=0.00,Y=0.00,Z=100.00),fLookAtDistance=170.00,fRotTightness=8.00,fRotSpeed=4.00,fMoveTightness=0.00,fMoveSpeed=0.00)

    fDistanceScalar=1.00

    MaxBossAimRot=4000

    bIgnoreZonePainDamage=True

    bHidden=True

    bCanMoveInSpecialPause=True

    bBlockActors=False

    bBlockPlayers=False

    bRotateToDesired=False

    CutName="baseCam"
}

//=====================================================================================================
// This class was originally written 03/28/2002.
// March 28th is National Hot Tub Day!
// - Moca, 5/21/2026
//=====================================================================================================