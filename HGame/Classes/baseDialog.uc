//================================================================================
// baseDialog.
//
// Leftover dialog class from HP1. Not used in HP2.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class baseDialog extends Info;

//== Consts ==//
const MAX_LINES = 2100;						// Max number of dialog lines

//== GlobalConfig ==//
var globalconfig string LanguageExtension;	// Language extension

//== Dialog Lines ==//
var int NumLines;							// Number of dialog lines
var string LanguageName;					// Name of dialog language
var string lineIDs[2100];					// Array of dialog line IDs
var string lineText[2100];					// Array of dialog text
var Sound lineSounds[2100];					// Array of dialog sounds

//== Actor References ==//
var harry PlayerHarry;						// Reference to Harry



//=========
// Events
//=========

// On spawn
event Spawned()
{
	// If we don't have Harry
	if ( PlayerHarry == None )
	{
		// Try to find Harry by looping through all actors for actor of class harry
		foreach AllActors(Class'harry', PlayerHarry)
		{
			break;
		}
	}
}


//=================
// Main Functions
//=================

// Find a dialog string and sound
function bool FindDialog (string dialogID, out Sound dlgSound, out string DlgText)
{
	local int I;

	// Get localized dialog text
	DlgText = Localize("all",dialogID,"HPdialog");

	// Get matching dialog sound
	dlgSound = Sound(DynamicLoadObject("AllDialog." $ dialogID,Class'Sound'));

	// If we have no sound, add "*" to start of DlgText
	if ( dlgSound == None )
	{
		DlgText = "*" $ DlgText;
	}

	// Return as successful
	return True;
}

// Translate string. Always returns the input string.
function string TranslateString (string S)
{
	return S;
}

// Deliver dialog. Always returns 3.0.
function float DeliverDialog (string dialogID)
{
	local float duration;
	local Sound dlgSound;
	local string DlgText;

	duration = 3.0;
	return duration;
}

// Deliver emote
function float DeliverEmote (string dialogID)
{
	local float duration;
	local Sound dlgSound;
	local string DlgText;

	// Default duration to 1.0
	duration = 1.0;

	// If we have the target dialog, setting dlgSound and DlgText in the process
	if ( FindDialog(dialogID,dlgSound,DlgText) )
	{
		// If we have a dialog sound
		if ( dlgSound != None )
		{
			// Set duration to sound duration
			duration = GetSoundDuration(dlgSound);

			// Add half a second of ending time
			duration += 0.5;

			// Play the sound on Harry
			PlayerHarry.PlaySound(dlgSound,SLOT_Interact,3.2,False,20000.0,1.0);
		}
	}
	// Otherwise, log that we couldn't find the emote
	else
	{
		PlayerHarry.ClientMessage("*****DeliverEmote cant find emote:" $ dialogID);
	}

	// Return the duration
	return duration;
}


//=====================
// Default Properties
//=====================

defaultproperties
{
    NumLines=1

    lineIDs(0)="TUT1_DUMINTRO_1"

    lineText(0)="Welcome to Hogwarts, the school for Witches and Wizards. I am Albus Dumbledore, your Headmaster."

    LanguageName="base"
}

//=====================================================================================================
// KW didn't specify when this class was written :(
// But HP1 released 11/16/2001!
// November 16th is Have a Party With Your Bear Day!
// - Moca, 5/21/2026
//=====================================================================================================