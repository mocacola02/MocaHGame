//==========================================================================//
// BenchWithArms.
//
// Armed bench furniture actor.
// This bench is packing heat
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class BenchWithArms extends HFurniture;

defaultproperties
{
	Mesh=SkeletalMesh'HProps.skBenchWithArmsMesh'

	CollisionRadius=80.00

	CollisionWidth=24.00

	CollisionHeight=37.00

	CollideType=CT_Box
}
