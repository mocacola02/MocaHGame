//==========================================================================//
// TableTrestle.
//
// Trestle table furniture actor.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class TableTrestle extends HFurniture;

defaultproperties
{
	Mesh=SkeletalMesh'HProps.skTableTrestleMesh'

	CollisionRadius=20.00

	CollisionWidth=48.00

	CollisionHeight=25.00

	CollideType=CT_Box
}
