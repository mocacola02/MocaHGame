//==========================================================================//
// CabinetSupplyCase.
//
// Supply case cabinet furniture actor.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class CabinetSupplyCase extends HFurniture;

defaultproperties
{
	Mesh=SkeletalMesh'HProps.skCabinetSupplyCaseMesh'

	DrawScale=1.20

	CollisionRadius=41.00

	CollisionWidth=18.00

	CollisionHeight=72.00

	CollideType=CT_Box
}
