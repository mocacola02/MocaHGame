//==========================================================================//
// HermioneInfimary.
//
// Character actor used for Hermione petrified in the infirmary.
//
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class HermioneInfimary extends Characters;

defaultproperties
{
	Mesh=SkeletalMesh'HPModels.skHermioneInfimaryMesh'

	AmbientGlow=65

	CollisionRadius=70.00

	CollisionHeight=40.00

	CollideType=CT_Box
}