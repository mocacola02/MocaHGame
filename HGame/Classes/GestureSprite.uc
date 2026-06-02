//==========================================================================//
// GestureSprite.
//
// Sprite actor used for spell gesture during targeting.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class GestureSprite extends Sprite;


//=========
// Events
//=========

// Called before gameplay starts
event PreBeginPlay()
{
	// Call parent behavior
	Super.PreBeginPlay();

	// Set all collision to false
	SetCollision(,,);
	bCollideWorld = False;
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bHidden=True

	Texture=None

	CollisionRadius=2.00

	CollisionHeight=2.00

	bCollideActors=False

	bCollideWorld=False

	bBlockActors=False

	bBlockPlayers=False
}
