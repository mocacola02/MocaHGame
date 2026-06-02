//==========================================================================//
// CutMark.
//
// Keypoint actor intended for positioning various cutscene elements.
//
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class CutMark extends Keypoint;

//= Imports ==/
#exec Texture Import File=Textures\Icons\CutMarkIcon.PNG	GROUP=Icons	Name=CutMarkIcon COMPRESSION=P8 UPSCALE=1 Mips=0 Flags=2


//=====================
// Default Properties
//=====================

defaultproperties
{
	Texture=Texture'HGame.Icons.CutMarkIcon'

	DrawScale=0.50
}
