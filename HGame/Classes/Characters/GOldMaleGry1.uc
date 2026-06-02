//==========================================================================//
// GOldMaleGry1.
//
// Character actor used for generic old male Gryffindor student 1.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class GOldMaleGry1 extends Characters;

defaultproperties
{
	BumpLineSetPrefix="Omg"

	GroundSpeed=150.00

	GroundRunSpeed=220.00

	Mesh=SkeletalMesh'HPModels.skhp2_genmale1Mesh'

	DrawScale=1.10

	AmbientGlow=75

	MultiSkins(0)=Texture'HPModels.Skins.skhp2_genmale1_0Tex0'

	MultiSkins(1)=Texture'HPModels.Skins.skhp2_genmale1_0Tex1'

	CollisionRadius=15.00

	CollisionHeight=42.00
}
