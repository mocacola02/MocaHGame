//==========================================================================//
// SmartStart.
//
// Custom PlayerStart that allows placing Harry at a starting point
// Based on the previous level name. Also allows saving when placed
// at that point. 
//
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class SmartStart extends PlayerStart;

var(PlayerStart) bool bDoLevelSave;			// Whether or not to save at this point
var(PlayerStart) string PreviousLevelName;	// Name of previous level to check for