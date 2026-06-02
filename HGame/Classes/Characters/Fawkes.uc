//==========================================================================//
// Fawkes.
//
// Character actor used for Fawkes.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class Fawkes extends Characters;


//=================
// Main Functions
//=================

// Plays a wing flap sound
function PlayWingFlap()
{
	PlaySound(Sound'Fawkes_wing_flap',,,,,RandRange(0.8,1.0));
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bDoEyeBlinks=False

	Mesh=SkeletalMesh'HPModels.skFawkesMesh'

	AmbientGlow=65

	CollisionRadius=15.00

	CollisionHeight=49.00
}
