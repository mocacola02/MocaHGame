//================================================================================
// HCollectible.
//================================================================================

class HCollectible extends HProp;

enum EPickupFlyTo
{
  FT_None,			// Moca: Fly nowhere
  FT_Camera,		// Moca: Fly to camera, HP1 star style
  FT_HudPosition,	// Moca: Fly to HUD counter
  FT_DropOffInWorld	// Moca: Fly to somewhere in the world
};

var() int PickupIncrement;					// Moca: How many of the collectible does this count for? Def: 1

var() bool bGnomeable;					// Moca: Can Gnomes pick up this bean? Def: False

var() name EventToSendOnPickup;				// Moca: What event should be sent on pickup? Def: None

var() Class<StatusGroup> TargetStatusGroup;	// Moca: What StatusGroup does this collectible apply to?
var() Class<StatusItem> TargetStatusItem;	// Moca: What StatusItem does this collectible apply to?

var() array<Sound> PickupSounds;			// Moca: What sound(s) play on pickup?
var() array<Sound> DropOffSound;			// Moca: What sound(s) play on drop off?

var() Vector DropOffLoc;					// Moca: Where should the collectible drop off to?

var() float StartCamZoomDist;				// Moca: How far from the camera does the collectible start if FT_Camera? Def: 160.0
var() EPickupFlyTo PickupFlyTo;				// Moca: What fly to mode to use? Def: FT_HudPosition

var bool bReadyForFlyEffect;
var float TotalFlyTime;
var float CurrFlyTime;
var float CurrCameraZoomDist;

var float MinFlyToHudScale;
var float MaxFlyToHudScale;
var Vector HudLocation;

//-------------------------------------
// Event
//-------------------------------------

event Touch (Actor Other)
{
	if ( CanPickupNow(Other) )
	{
		DoPickupProp();
	}
}

event HitWall (Vector HitNormal, Actor Wall)
{
	PlayerHarry.ClientMessage("hitwall " $ string(Wall.Name));
	
	if ( IsInState('PickupProp') || IsInState('DropOffProp') )
	{
		bHidden = True;
		bCollideWorld = False;
		SetCollision(False,False,False);
		HPHud(PlayerHarry.myHUD).RegisterPickupProp(self);
	}
}

//-------------------------------------
// Misc. Functions
//-------------------------------------

function bool CanPickupNow (Actor Other)
{
	return (Other == PlayerHarry) && (GetStateName() != 'PickupProp') &&  !PlayerHarry.IsEngagedWithVendor() &&  !PlayerHarry.IsMixingPotion();
}

function RenderHud (Canvas Canvas)
{
	Canvas.DrawActor(self,False,True);
}

function DoPickupProp(optional bool bDropOff)
{
	if (bDropOff)
	{
		PickupFlyTo = FT_DropOffInWorld;
		GotoState('DropOffProp');
	}
	else
	{
		GotoState('PickupProp');
	}
}

//-------------------------------------
// FlyTo
//-------------------------------------

function FaceCamera()
{
	local Rotator R;

	R = PlayerHarry.Cam.Rotation;
	R.Yaw += 16384;
	R.Roll = R.Pitch;
	R.Pitch = 0;
	DesiredRotation = R;
	SetRotation(R);
}

function ZoomToCamera()
{
	local Vector V;

	V.X = CurrCameraZoomDist;
	SetLocation(PlayerHarry.Cam.Location + (V >> PlayerHarry.Cam.Rotation));
}

function FlyToNewPosition (float MovePercent)
{
	local Vector vectMove;
	local bool bMovedSmooth;

	if ( MovePercent < 1 )
	{
		MovePercent = 1.0;
	}

	MovePercent = FClamp(MovePercent,1.0)

	switch(PickupFlyTo)
	{
		case FT_HudPosition:
			vectMove = (HudLocation - Location) / MovePercent;
			break;

		case FT_DropOffInWorld:
			vectMove = (DropOffLoc - Location) / MovePercent;
			break;

		default:
			PlayerHarry.ClientMessage("ERROR:  Unrecognized PickupFlyTo value");
			break;
	}

	MoveSmooth(vectMove);
	DrawScale = Clamp(DrawScale * 0.95, MinFlyToHudScale, MaxFlyToHudScale);
}

function SetFlyProps()
{
	SetPhysics(PHYS_Flying);
	bBounce = False;
	bCollideWorld = True;
	SetCollision(False,False,False);
}

function TickPickupOrDropOff (float Delta)
{
	local Vector Dest;

	if ( !bReadyForFlyEffect )
	{
		return;
	}

	switch (PickupFlyTo)
	{
		case FT_HudPosition:

		case FT_DropOffInWorld:
			CurrFlyTime -= Delta;

			if ( CurrFlyTime > 0 )
			{
				FlyToNewPosition(CurrFlyTime / Delta);
			}
			break;

		case FT_Camera:
			CurrCameraZoomDist -= Delta * 400;

			if ( CurrCameraZoomDist > 0 )
			{
				ZoomToCamera();
				FaceCamera();
			}
			break;

		default:
			PlayerHarry.ClientMessage("ERROR:  Pickup type not recognized");
			break;
	}
}

state DropOffProp
{	
	ignores Touch;

	event Tick (float Delta)
	{
		TickPickupOrDropOff(Delta);
	}
	
	event BeginState()
	{
		PickupFlyTo = FT_DropOffInWorld;
		bReadyForFlyEffect = False;

		DrawScale = MaxFlyToHudScale;

		if ( DropOffSounds.Length > 0 )
		{
			PlaySound(DropOffSounds[Rand(DropOffSounds.Length)]);
		}

		SetFlyProps();
		CurrFlyTime = TotalFlyTime;
		PlayerHarry.managerStatus.DropOffItem(self);
		bReadyForFlyEffect = True;
	}
	
	begin:
		while ( CurrFlyTime > 0 )
		{
			Sleep(0.1);
		}

		HPHud(PlayerHarry.myHUD).UnregisterPickupProp(self);

		bHidden = True;
		Destroy();
}

state PickupProp
{  
	ignores Touch;

	event Tick (float Delta)
	{
		TickPickupOrDropOff(Delta);
	}
	
	event BeginState()
	{
		bReadyForFlyEffect = False;

		DrawScale = MaxFlyToHudScale;

		if(PickupSounds.Length > 0)
		{
			PlaySound(PickupSounds[Rand(PickupSounds.Length)]);
		}

		SetFlyProps();
	}
  
	begin:
		if ( PickupFlyTo == FT_HudPosition )
		{
			CurrFlyTime = TotalFlyTime;
			HudLocation = PlayerHarry.managerStatus.GetHudLocation(self);
			bReadyForFlyEffect = True;

			while ( CurrFlyTime > 0 )
			{
				Sleep(0.1);
			}
		}
		else if ( PickupFlyTo == FT_Camera )
		{
			FaceCamera();
			CurrCameraZoomDist = StartCamZoomDist;
			bReadyForFlyEffect = True;

			while ( CurrCameraZoomDist > 0 )
			{
				Sleep(0.2);
			}
		}

		PlayerHarry.managerStatus_PickupItem(self);

		if ( EventToSendOnPickup != 'None' )
		{
			TriggerEvent(EventToSendOnPickup,self,self);
		}

		bHidden = True;
		HPHud(PlayerHarry.myHUD).UnregisterPickupProp(self);
		Destroy();
}

defaultproperties
{
	PickupIncrement=1

	PickupSounds(0)=Sound'HPSounds.Magic_sfx.pickup11'

	StartCamZoomDist=160.0

	PickupFlyTo=FT_HudPosition


	bBlockActors=False

    bBlockPlayers=False

    bProjTarget=False

    bBlockCamera=False

	bPersistent=True

	Physics=PHYS_None

	AmbientGlow=200

	CollisionRadius=32.00

    CollisionHeight=10.00
}