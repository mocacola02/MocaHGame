//==========================================================================//
// BenchTable.
//
// Bench & Table furniture actor.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class BenchTable extends HFurniture;

defaultproperties
{
	Mesh=SkeletalMesh'HProps.skBenchTableMesh'

	CollisionRadius=80.00

	CollisionHeight=30.00

	CollideType=CT_Box
}
