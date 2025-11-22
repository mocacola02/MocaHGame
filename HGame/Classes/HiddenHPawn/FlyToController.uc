//================================================================================
// FlyToController.
//================================================================================

class FlyToController extends HActor;

var bool bEnabled;
var HPawn FlyActor;

function EnableController()
{
	bEnabled = True;
	FlyActor = HPawn(Owner);
	GotoState('FlyingTo');
}

function DisableController()
{
	bEnabled = False;
	GotoState('stateIdle');
}

state FlyingTo
{
	event Tick (float DeltaTime)
	{
		local bool bGotToEnd;
		local float f;
		local Vector DestLocation;

		if ( FlyActor == None )
		{
			Print("ERROR! I don't have a FlyActor, destroying!",true);
			Destroy();
			return;
		}

		if ( FlyActor.FlyToTime < FlyActor.FlyToTimespan )
		{
			FlyActor.FlyToTime += DeltaTime;
		}

		DestLocation = GetDestLocation();

		if ( FlyActor.FlyToTimespan == 0 )
		{
			FlyActor.SetLocation(DestLocation);
		} 
		else 
		{
			FlyActor.SetLocation(FlyActor.vFlyToStart + (DestLocation - FlyActor.vFlyToStart) * EaseMovement(FlyActor.fFlyToTime / FlyActor.fFlyToTimeSpan,FlyActor.eFlyMoveType));
		}

		if ( FlyActor.FlyToTime > FlyActor.FlyToTimespan )
		{
			FlyActor.OnFlyToDone();

			if ( !FlyActor.bFlyToStopAtEnd )
			{
				bEnabled = False;
			}
		}
	}
  
}

function Vector GetDestLocation()
{
	local Vector DestLocation;

	if ( FlyActor.FlyToActor != None )
	{
		DestLocation = FlyActor.FlyToActor.Location;

		if ( FlyActor.bFlyToFixedToDestActor )
		{
			DestLocation += FlyActor.FlyToDestOffset;
		} 
		else 
		{
			DestLocation += FlyActor.FlyToDestOffset >> FlyActor.FlyToActor.Rotation;
		}
	}
	else 
	{
		DestLocation = FlyActor.FlyToDest;
	}

	return DestLocation;
}

defaultproperties
{
    bHidden=False
    DrawType=DT_None
}