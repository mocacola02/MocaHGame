//==========================================================================//
// DeskTeacher.
//
// Teacher's desk furniture actor.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class DeskTeacher extends HFurniture;

defaultproperties
{
	Mesh=SkeletalMesh'HProps.skDeskTeacherMesh'

	CollisionRadius=25.00

	CollisionWidth=50.00

	CollisionHeight=27.00

	CollideType=CT_Box
}
