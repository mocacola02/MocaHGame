//==========================================================================//
// NHNick.
//
// Character actor used for Nearly Headless Nick.
//
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class NHNick extends Characters;

defaultproperties
{
	ShadowClass=None

	Mesh=SkeletalMesh'HPModels.skNHNickMesh'

	AmbientGlow=65

	Opacity=0.75

	CollisionHeight=45.00

	bCollideWorld=False

	bBlockActors=False

	bBlockPlayers=False
}
