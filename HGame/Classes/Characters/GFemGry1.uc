//==========================================================================//
// GFemGry1.
//
// Character actor used for generic female Gryffindor student 1.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class GFemGry1 extends Characters;

defaultproperties
{
	BumpLineSetPrefix="Gfg"

	GroundRunSpeed=220.00

	Mesh=SkeletalMesh'HPModels.skhp2_genfemale1Mesh'

	AmbientGlow=75

	MultiSkins(0)=Texture'HPModels.Skins.skhp2_genfemale1_0Tex0'

	MultiSkins(1)=Texture'HPModels.Skins.skhp2_genfemale1_0Tex1'

	CollisionRadius=15.00

	CollisionHeight=42.00
}
