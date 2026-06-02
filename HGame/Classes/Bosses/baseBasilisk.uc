//==========================================================================//
// baseBasilisk.
//
// Base class for Basilisk boss.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class baseBasilisk extends baseBoss;

var() float HeadDamage;	// Damage done by head.
var() float TailDamage;	// Damage done by tail.



//=================
// Main Functions
//=================

// On collision object touch. Does nothing without extending.
function ColObjTouch (Actor Other, GenericColObj ColObj);


//=====================
// Default Properties
//=====================

defaultproperties
{
	HeadDamage=80.00

	TailDamage=3.00

	EnemyHealthBar=EnemyBar_Basilisk

	Physics=PHYS_None
}
