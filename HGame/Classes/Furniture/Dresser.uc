//==========================================================================//
// Dresser.
//
// Dresser furniture actor.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class Dresser extends HFurniture;

defaultproperties
{
	Mesh=SkeletalMesh'HProps.skDresserMesh'

	CollisionRadius=45.00

	CollisionWidth=15.00

	CollisionHeight=30.00

	CollideType=CT_Box
}
