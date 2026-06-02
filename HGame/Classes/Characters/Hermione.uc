//==========================================================================//
// Hermione.
//
// Character actor used for Hermione.
//
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class Hermione extends Characters;


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
	BumpLineSetPrefix="Her"

	GroundRunSpeed=220.00

	Mesh=SkeletalMesh'HPModels.skhermioneMesh'

	AmbientGlow=65

	CollisionRadius=15.00

	CollisionHeight=38.00
}