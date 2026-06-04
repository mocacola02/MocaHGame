//==========================================================================//
// HiddenHPawn.
//
// Category class for invisible HPawn actors.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class HiddenHPawn extends HPawn;

//= Imports =//
#exec Texture Import File=Textures\HiddenPawn.PNG Name=HiddenPawn COMPRESSION=P8 UPSCALE=1 Mips=0 Flags=2

//= General Variables =//
var bool bShowHiddenPawns;	// Should this HiddenHPawn be visible


//=========
// Events
//=========

// Called before gameplay starts
event PreBeginPlay()
{
	// Call parent behavior
	Super.PreBeginPlay();

	// Disable all collision
	SetCollision();
	bCollideWorld = False;

	// If we should be shown
	if ( bShowHiddenPawns )
	{
		// Do not be hidden
		bHidden = False;

		// Draw as a sprite
		DrawType= DT_Sprite;

		// Use normal style
		Style 	= STY_Normal;
	}
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bHidden=True

	DrawType=DT_Sprite

	Texture=Texture'HGame.HiddenPawn'

	Mesh=None

	CollisionRadius=2.00

	CollisionHeight=2.00

	bCollideActors=False

	bCollideWorld=False

	bBlockActors=False

	bBlockPlayers=False
}