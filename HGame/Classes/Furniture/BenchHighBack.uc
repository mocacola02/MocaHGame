//==========================================================================//
// BenchHighBack.
//
// High-back bench furniture actor.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class BenchHighBack extends HFurniture;

defaultproperties
{
	Mesh=SkeletalMesh'HProps.skBenchHighBackMesh'

	CollisionRadius=50.00

	CollisionWidth=20.00

	CollisionHeight=50.00

	CollideType=CT_Box
}
