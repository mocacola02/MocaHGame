//==========================================================================//
// ArmorWholeSuit.
//
// Armor suit decoration actor.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class ArmorWholeSuit extends HDecoration;

defaultproperties
{
	Mesh=SkeletalMesh'HProps.skArmorWholeSuitMesh'

	DrawScale=1.50

	CollisionRadius=24.00

	CollisionWidth=11.00

	CollisionHeight=60.00

	CollideType=CT_Box
}
