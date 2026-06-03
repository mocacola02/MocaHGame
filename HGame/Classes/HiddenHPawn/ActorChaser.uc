//==========================================================================//
// ActorChaser.
//
// Actor that chases after its owner. Unused in stock (?).
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class ActorChaser extends HiddenHPawn;

var() bool bActive;	// Are we active?


//=========
// States
//=========

// Default chase state
auto state stateChase
{
	event Tick (float DeltaTime)
	{
		local float f;

		// Call parent behavior
		Super.Tick(DeltaTime);

		// Set acceleration towards the owner
		Acceleration = Normal(Owner.Location - Location) * AccelRate;

		// Add half of our negated velocity to our acceleration
		Acceleration +=  -Velocity * 0.5;

		// Add acceleration to our velocity, adjusting for frame rate
		Velocity += Acceleration * DeltaTime;

		// Get velocity size
		f = VSize(Velocity);

		// If velocity size is greater than our air speed, adjust it to fit
		if ( f > AirSpeed )
		{
			Velocity *= AirSpeed / f;
		}

		// Set our location using velocity, adjusting for frame rate
		SetLocation(Location + Velocity * DeltaTime);
	}

}

// Idle state
state stateIdle
{
	// Begin label
	begin:
		// Stop all acceleration and velocity
		Acceleration 	= vect(0.00,0.00,0.00);
		Velocity 		= vect(0.00,0.00,0.00);
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bActive=True

	AirSpeed=90.00

	AccelRate=150.00
}