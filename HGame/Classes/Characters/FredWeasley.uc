//==========================================================================//
// FredWeasley.
//
// Character actor used for Fred Weasley.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class FredWeasley extends Characters;

defaultproperties
{
	VendorDialogSet=VDialog_FredWeasley

	BumpLineSetPrefix="Frd"

	GroundRunSpeed=220.00

	Mesh=SkeletalMesh'HPModels.skFredWeasleyMesh'

	AmbientGlow=65

	CollisionRadius=15.00

	CollisionHeight=45.00
}
