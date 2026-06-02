//==========================================================================//
// Ron.
//
// Character actor used for Ron Weasley.
//
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class Ron extends Characters;


//=================
// Main Functions
//=================

function float GetFootStepVol()
{
  return 1.0;
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	BumpLineSetPrefix="Ron"

	GroundRunSpeed=220.00

	Mesh=SkeletalMesh'HPModels.skronMesh'

	AmbientGlow=65

	CollisionRadius=15.00

	CollisionHeight=40.00
}