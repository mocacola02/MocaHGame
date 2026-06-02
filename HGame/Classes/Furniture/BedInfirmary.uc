//==========================================================================//
// BedInfirmary.
//
// Infirmary bed furniture actor.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class BedInfirmary extends HFurniture;

defaultproperties
{
	Mesh=SkeletalMesh'HProps.skBedInfirmaryMesh'

	CollisionRadius=30.00

	CollisionWidth=65.00

	CollisionHeight=33.00

	CollideType=CT_Box
}
