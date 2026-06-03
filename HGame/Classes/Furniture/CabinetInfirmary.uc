//==========================================================================//
// CabinetInfirmary.
//
// Infirmary cabinet furniture actor.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class CabinetInfirmary extends HFurniture;

defaultproperties
{
	Mesh=SkeletalMesh'HProps.skCabinetInfirmaryMesh'

	CollisionRadius=25.00

	CollisionWidth=65.00

	CollisionHeight=58.00

	CollideType=CT_Box
}
