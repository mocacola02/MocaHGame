//==========================================================================//
// CoatRack1.
//
// Coat rack furniture actor.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class CoatRack1 extends HFurniture;

defaultproperties
{
	Mesh=SkeletalMesh'HProps.skCoatRack1Mesh'

	DrawScale=1.10

	CollisionRadius=50.00

	CollisionWidth=9.00

	CollisionHeight=8.00

	CollideType=CT_Box
}
