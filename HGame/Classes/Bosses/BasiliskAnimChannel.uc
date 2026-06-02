//==========================================================================//
// BasiliskAnimChannel.
//
// Animation channel to combine animations on the Basilisk boss.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class BasiliskAnimChannel extends AnimChannel;

var bool bAnimDone; // Is the animation done?
var Basilisk Basil;	// Reference to Basilisk



//=====================
// Main Functions
//=====================

// Sets owner to a given actor, intended to be a Basilisk
function _SetOwner (Actor o)
{
	SetOwner(o);
	Basil = Basilisk(o);
}


// Called on animation end, set anim to be done and calls RealAnimEnd on basilisk
function AnimEnd()
{
	bAnimDone = True;
	Basil.RealAnimEnd();
}

// Tells Basilisk to play its hiss sound
function PlayHissSound()
{
	Basil.PlayHissSound();
}

