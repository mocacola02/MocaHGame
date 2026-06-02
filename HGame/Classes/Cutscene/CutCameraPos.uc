//==========================================================================//
// CutCameraPos.
//
// Keypoint actor intended for positioning the camera during cutscenes.
//
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class CutCameraPos extends Keypoint;

//= Imports ==/
#exec Texture Import File=Textures\Icons\CutCamIcon.PNG		GROUP=Icons	Name=CutCamIcon COMPRESSION=P8 UPSCALE=1 Mips=0 Flags=2


//=====================
// Default Properties
//=====================

defaultproperties
{
	Texture=Texture'HGame.Icons.CutCamIcon'

	DrawScale=0.50
	bDisplayFOVCone=true
}
