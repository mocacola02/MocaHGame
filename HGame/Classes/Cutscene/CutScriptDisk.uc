//==========================================================================//
// CutScriptDisk.
//
// Loads CutScript from a given file name.
//
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class CutScriptDisk extends CutScript;

// Omega: Make CutscriptDisk operate more like the original script by using the script lines
function load (string threadName, string FileName)
{
	local int I;
	local string Line;
	
	// While true (aka keep looping this)
	while(true)
	{
		// Localize line from a thread in a given script file
		Line = Localize(threadName,"line_"$I,FileName);

		// If line is blank or contains an XML declaration tag (TODO: confirm this is the case)
		if(Line == "" || InStr(Line,"<?") > -1)
		{
			return;
		}

		// Add line to script with a newline character
		Script $= Line $ Chr(10);

		// Increment line number
		I++;
	}
}