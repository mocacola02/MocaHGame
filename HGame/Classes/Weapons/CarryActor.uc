class CarryActor extends HWeapon;

var name CarryBone;
var Actor CarryingActor;

function InitWeapon()
{
	SetCarryingActor(CarryBone);
}

function PrimaryFireAction()
{
	ThrowCarryingActor();
}

function SetCarryingActor (optional name nameBone)
{
	if ( CarryingActor != None )
	{
		PlayerHarry.HarryAnimType = AT_Combine;

		CarryingActor.SetCollision(False,False,False);
		CarryingActor.SetOwner(PlayerHarry);
		CarryingActor.AttachToOwner(nameBone);
		CarryingActor.bRotateToDesired = False;
	}
	else
	{
		print("CarryingActor was None!! Aborting carry!",true);
		PlayerHarry.ChangeWeapon(PlayerHarry.PreviousWeapon.Class);
	}
}

function PickupActor (Actor Other)
{
	// Potentially unsafe local declaration. We'll see how this works
	if (Other.IsA('HPawn'))
	{
		local HPawn ActorToPickup;
		ActorToPickup = HPawn(Other);
	}
	else if (Other.IsA('HActor'))
	{
		local HActor ActorToPickup;
		ActorToPickup = HActor(Other);
	}
	else
	{
		Log("Not a compatible pickup actor!");
		return;
	}

	// If we're eligible to carry, "do it". - Emperor Palpatine, 19 BBY
	if ( PlayerHarry.Physics == PHYS_Walking && PlayerHarry.IsInState('PlayerWalking') && CarryingActor == None && ActorToPickup.bObjectCanBePickedUp)
	{
		CarryingActor = ActorToPickup;
		PlayerHarry.GotoState('statePickupItem');
	}
}

function DropCarryingActor (optional bool bLatentDrop)
{
	ClientMessage("** DropCarryingActor");

	// If we're carrying an actor
	if ( CarryingActor != None )
	{
		// Set the carried actor to be dropped
		CarryingActor.SetPhysics(PHYS_Falling);
		CarryingActor.SetOwner(None);
		CarryingActor.Velocity = vect(0.00,0.00,125.00);
		CarryingActor.Instigator = self;
		CarryingActor.bRotateToDesired = True;
		CarryingActor.SetCollision(True,True,True);
		CarryingActor = None;
	}

	// If we were in pickup, go back to walk
	if ( PlayerHarry.IsInState('statePickupItem') )
	{
		PlayerHarry.GotoState('PlayerWalking');
	}

	// Tbh i'm not entirely sure what latent drop is, so i'm leaving it as is. I think it determines if harry can move during the drop? dunno
	if ( !bLatentDrop )
	{
		HarryAnimChannel.GotoState('stateIdle');
		HarryAnimType = AT_Replace;
	}

	PlayerHarry.ChangeWeapon(PlayerHarry.PreviousWeapon);
}

function ThrowCarryingActor()
{
	local Vector V;
	local Actor Target;
	local float ThrowVelocity;

	if ( (CarryingActor != None) )
	{
		// Again this feels a bit risky, but we'll see
		if (CarryingActor.IsA('HActor'))
		{
			local HActor A;
		}
		else if (CarryingActor.IsA('HPawn'))
		{
			local HPawn A;
		}
		else
		{
			Log("CarryingActor is not valid!");
			return;
		}

		// Set our actor and drop
		A = CarryingActor;
		DropCarryingActor(True);

		// If we're throwing accurately
		if (A.bAccurateThrowing)
		{
			// Find our target
			Target = GetAccurateThrowTarget(A);
		}

		// If we have a target and are throwing accurately
		if ( Target != None && A.bAccurateThrowing)
		{
			// "Do it" -Emperor Palpatine, 19 BBY
			HarryAccurateThrowObject(A,Target,True,True);
		}
		// Otherwise, just throw normally
		else
		{
			// Set forward velocity
			V = Normal(Cam.vForward + vect(0.00,0.00,0.50));

			if ( A != None )
			{
				ThrowVelocity = A.ThrowVelocity;
				A.GotoState('stateBeingThrown');
			}
			else
			{
				ThrowVelocity = 400.0;
			}

			// Multiply our velocity by the intended throw velocity
			V *= ThrowVelocity;

			// Set actor's velocity
			A.Velocity = V;
		}
	}

	PlayerHarry.ChangeWeapon(PlayerHarry.PreviousWeapon.Class);
}

function Actor GetAccurateThrowTarget (Actor A)
{
	local TargetPoint ClosestTP;
	local TargetPoint CurrTP;
	local float Dist;

	// Went with 65536 since no level goes larger than that. did i need to change it? nah
	ClosestDist = 65536.0;
	
	// For each TargetPoint
	foreach AllActors(Class'TargetPoint',CurrTP)
	{
		// If the target is in front of Harry
		if ( PlayerHarry.InFrontOfHarry(CurrTP) )
		{
			// Get the distance between Harry and the target
			Dist = VSize(CurrTP.Location - Location);

			// If its not too far away
			if ( Dist < ClosestDist )
			{
				// Set the closest TP to the current TP
				ClosestTP = CurrTP;

				// Set the closest dist to current dist
				ClosestDist = Dist;
			}
		}
	}

	return ClosestTP;
}

function HarryAccurateThrowObject (HPawn A, Actor Target, bool bCollideActors, bool bCollideWorld)
{
	local Vector Vel;

	// Set thrown actor properties
	A.SetPhysics(PHYS_Falling);
	A.SetCollision(bCollideActors);
	A.bCollideWorld = bCollideWorld;

	// Calculate velocity
	Vel = ComputeTrajectoryByTime(A.Location,Target.Location,0.5);

	// Set thrown actor velocity
	A.Velocity = Vel;

	// Set thrown actor state
	A.GotoState('stateBeingThrown');
}

defaultproperties
{
	CarryBone=WeaponRight
	bAllowPickup=False
}