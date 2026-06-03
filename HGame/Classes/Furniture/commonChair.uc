//==========================================================================//
// commonChair.
//
// Common room chair furniture actor.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class commonChair extends HFurniture;

defaultproperties
{
	Mesh=SkeletalMesh'HProps.skcommonChairMesh'

	CollisionRadius=35.00

	CollisionHeight=45.00

	CollideType=CT_Box
}
