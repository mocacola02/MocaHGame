//==========================================================================//
// BlockCamera.
//
// Keypoint actor that is intended to block the camera.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class BlockCamera extends Keypoint;


//=====================
// Default Properties
//=====================

defaultproperties
{
	CollisionRadius=128.00

	CollisionWidth=128.00

	CollisionHeight=128.00

	CollideType=CT_Box

	bCollideActors=True
}
