//==========================================================================//
// fatfriar.
//
// Character actor used for the Fat Friar.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class fatfriar extends Characters;

defaultproperties
{
	ShadowClass=None

	Mesh=SkeletalMesh'HPModels.skfatfriarMesh'

	DrawScale=1.20

	AmbientGlow=65

	Opacity=0.75

	CollisionHeight=47.00

	bCollideWorld=False

	bBlockActors=False

	bBlockPlayers=False
}
