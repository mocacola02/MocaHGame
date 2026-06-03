//==========================================================================//
// BooksFlourishStand.
//
// Flourish and Blotts book stand furniture actor.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class BooksFlourishStand extends HFurniture;

defaultproperties
{
	Mesh=SkeletalMesh'HProps.skBooksFlourishStandMesh'

	DrawScale=1.40

	CollisionWidth=60.00

	CollisionHeight=32.00

	CollideType=CT_Box
}
