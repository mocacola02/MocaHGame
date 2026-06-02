//==========================================================================//
// DragonSkeleton.
//
// Dragon skeleton decoration actor.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class DragonSkeleton extends HDecoration;

defaultproperties
{
	Mesh=SkeletalMesh'HProps.skDragonSkeletonMesh'

	DrawScale=1.50

	CollisionRadius=80.00

	CollisionWidth=20.00

	CollisionHeight=105.00

	CollideType=CT_Box
}
