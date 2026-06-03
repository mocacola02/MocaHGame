//==========================================================================//
// CouchSlytherin.
//
// Slytherin common room couch furniture actor.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class CouchSlytherin extends HFurniture;

defaultproperties
{
	Mesh=SkeletalMesh'HProps.skCouchSlytherinMesh'

	CollisionRadius=80.00

	CollisionWidth=35.00

	CollisionHeight=30.00

	CollideType=CT_Box
}
