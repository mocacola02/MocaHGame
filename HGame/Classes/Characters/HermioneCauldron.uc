//==========================================================================//
// HermioneCauldron.
//
// Character actor used for Hermione sitting at the polyjuice potion cauldron.
//
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class HermioneCauldron extends Characters;

defaultproperties
{
	BumpLineSetPrefix="Her"

	Mesh=SkeletalMesh'HPModels.skhermioneCauldronMesh'

	AmbientGlow=65

	CollisionRadius=20.00
}