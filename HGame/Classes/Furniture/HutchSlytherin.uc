//==========================================================================//
// HutchSlytherin.
//
// Slytherin common room hutch furniture actor.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class HutchSlytherin extends HFurniture;

defaultproperties
{
	Mesh=SkeletalMesh'HProps.skHutchSlytherinMesh'

	DrawScale=1.20

	CollisionRadius=45.00

	CollisionWidth=22.00

	CollisionHeight=76.00

	CollideType=CT_Box
}
