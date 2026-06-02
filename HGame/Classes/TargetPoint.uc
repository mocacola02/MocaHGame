//==========================================================================//
// TargetPoint.
//
// Generic HPawn to be used as a targeting point.
//
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class TargetPoint extends HPawn;


//=====================
// Default Properties
//=====================

defaultproperties
{
	bHidden=True

	DrawType=DT_Sprite

	Texture=Texture'Engine.S_Patrol'

	CollisionRadius=2.00

	CollisionHeight=2.00

	bCollideActors=False

	bCollideWorld=False

	bBlockActors=False

	bBlockPlayers=False
}
