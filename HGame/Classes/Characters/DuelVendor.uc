//==========================================================================//
// DuelVendor.
//
// Character actor used for the interactable duel vendors outside of the great hall.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class DuelVendor extends Characters;

defaultproperties
{
	CharacterSells=Sells_Duel

	VendorDialogSet=VDialog_DuelVendor

	bHidden=True

	Mesh=SkeletalMesh'HPModels.skhp2_genmale1Mesh'

	AmbientGlow=75

	CollisionRadius=15.00

	CollisionHeight=42.00

	bCollideActors=False

	bBlockActors=False

	bBlockPlayers=False
}
