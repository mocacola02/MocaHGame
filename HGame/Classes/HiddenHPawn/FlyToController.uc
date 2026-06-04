//==========================================================================//
// FlyToController.
//
// Manages fly to behavior on actors.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class FlyToController extends HiddenHPawn;

var bool bEnabled;	// Are we enabled
var HPawn H;		// Ref to HPawn that is flying to


//=========
// Events
//=========

event PostBeginPlay()
{
	// Call parent behavior
	Super.PostBeginPlay();

	// If we have an owner, set its tick parent as self
	if ( Owner != None )
	{
		Owner.TickParent = self;
	}
}


//=============
// Activation
//=============

// Enable controller
function EnableController()
{
	// Set that we're enabled
	bEnabled = True;

	// Set HPawn ref to our owner cast as HPawn
	H = HPawn(Owner);

	// Go to flying to state
	GotoState('DoingTheFlyTo');
}

// Disable controller
function DisableController()
{
	// Set that we're not enabled
	bEnabled = False;

	// Go to idle state
	GotoState('stateIdle');
}


//===========
// Movement
//===========

// Get destination position
function Vector GetVDest()
{
	local Vector vDest;

	// If HPawn has a flyto actor
	if ( H.aFlyToActor != None )
	{
		// Set destination to the flyto actor's position
		vDest = H.aFlyToActor.Location;

		// If HPawn is set to be fixed to destination actor
		if ( H.bFlyToFixedToDestActor )
		{
			// Add HPawn's destination offset to the destination
			vDest += H.vFlyToDestOffset;
		}
		// Otherwise
		else 
		{
			// Add the rotated destination offset to the destination
			vDest += H.vFlyToDestOffset >> H.aFlyToActor.Rotation;
		}
	}
	// Otherwise
	else 
	{
		// Set destination to HPawn's flyto dest
		vDest = H.vFlyToDest;
	}

	// Return calculated destination
	return vDest;
}


//=========
// States
//=========

// Default flying to state
auto state DoingTheFlyTo
{
	// On tick
	event Tick (float DeltaTime)
	{
		local float f;
		local Vector vDest;
		local bool bGotToEnd;
  
		// If we're not enabled, do nothing and return
		if ( !bEnabled )
		{
			return;
		}

		// If we don't have an HPawn ref, do nothing and return
		if ( H == None )
		{
			return;
		}

		// If pawn's current fly to time is less than the fly to timespan
		if ( H.fFlyToTime < H.fFlyToTimeSpan )
		{
			// Increment fly to time
			H.fFlyToTime += DeltaTime;

			// If fly to time is greater than fly to timespan
			if ( H.fFlyToTime > H.fFlyToTimeSpan )
			{
				// Set that we go to the end
				bGotToEnd = True;

				// Make sure our fly to time is equal to the timespan
				H.fFlyToTime = H.fFlyToTimeSpan;
			}
		}

		// Get our destination position
		vDest = GetVDest();

		// If fly to timespan is 0.0, move HPawn to the destination
		if ( H.fFlyToTimeSpan == 0 )
		{
			H.SetLocation(vDest);
		}
		// Otherwise, ease the HPawn towards the destination
		else 
		{
			H.SetLocation(H.vFlyToStart + (vDest - H.vFlyToStart) * EaseFunction(H.fFlyToTime / H.fFlyToTimeSpan,H.eFlyMoveType));
		}

		// If flyto time is equal to flyto timespan
		if ( H.fFlyToTime == H.fFlyToTimeSpan )
		{
			// IF we got to the end, call flyto done behavior on Pawn
			if ( bGotToEnd )
			{
				H.OnFlyToDone();
			}

			// If the HPawn shouldn't stay locked to actor, set ourselves as disabled
			if ( !H.bFlyToStayLockedToActor )
			{
				bEnabled = False;
			}
		}
	}
  
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bHidden=False

	DrawType=DT_None
}