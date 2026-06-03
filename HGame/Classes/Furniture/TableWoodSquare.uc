//==========================================================================//
// TableWoodSquare.
//
// Square wooden table furniture actor.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class TableWoodSquare extends HFurniture;

defaultproperties
{
	Mesh=SkeletalMesh'HProps.skTableWoodSquareMesh'

	CollisionRadius=40.00

	CollisionHeight=28.00

	CollideType=CT_Box
}
