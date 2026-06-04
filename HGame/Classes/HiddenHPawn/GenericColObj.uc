//==========================================================================//
// GenericColObj.
//
// Generic collision actor to be owned by an HPawn.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class GenericColObj extends HiddenHPawn;

var bool bIsHead;	// Are we a head


//=========
// Events
//=========

// When touched by actor
event Touch (Actor Other)
{
	// If we have an owner that's an HPawn
	if ( HPawn(Owner) != None )
	{
		// Handle collision object touch on HPawn
		HPawn(Owner).ColObjTouch(Other,self);
	}
}


//=================
// Spell Handling
//=================

// Handle Flipendo spell based on HPawn's behavior
function bool HandleSpellFlipendo (optional baseSpell spell, optional Vector vHitLocation)
{
	return HPawn(Owner).HandleSpellFlipendo(spell,vHitLocation);
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bIgnoreZonePainDamage=True

	DrawType=DT_None

	CollisionRadius=20.00

	CollisionHeight=30.00

	bCollideActors=True
}