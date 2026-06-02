//==========================================================================//
// BenchTrestle.
//
// Trestle bench furniture actor.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class BenchTrestle extends HFurniture;

defaultproperties
{
	Mesh=SkeletalMesh'HProps.skBenchTrestleMesh'

	CollisionRadius=50.00

	CollisionWidth=20.00

	CollisionHeight=18.00

	CollideType=CT_Box
}
