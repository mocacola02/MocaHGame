//==========================================================================//
// basePopup.
//
// Leftover pop up class from HP1. It and its children are not used in stock HP2.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class basePopup extends Actor;

var harry PlayerHarry;	// Reference to Harry



//=========
// Events
//=========

// Called right after gameplay starts
event PostBeginPlay()
{
	// Call parent post begin play behavior
	Super.PostBeginPlay();

	// Find and set harry reference by looping through all actors
	foreach AllActors(Class'harry',PlayerHarry)
	{
		break;
	}
}


//=================
// Main Functions
//=================

// Canvas draw function. Does nothing by default.
function Draw (Canvas Canvas);


//=========
// States
//=========

// Pop up state, default state
auto state popstate
{
	// On begin, wait 0.5 seconds and set clear messages to false
	begin:
		Sleep(0.5);
		PlayerHarry.ClearMessages = False;
	
	// Loop label
	poploop:
		// If clear messages, set it to false and destroy
		if ( PlayerHarry.ClearMessages )
		{
			PlayerHarry.ClearMessages = False;
			Destroy();
		}

		// Sleep for 0.03 seconds
		Sleep(0.03);

		// Loop by going back to poploop
		goto ('poploop');
}


//=====================
// Default Properties
//=====================

defaultproperties
{
		bHidden=True

		LifeSpan=1.00
}

//=====================================================================================================
// Why doesn't HP1 pop up some better code
// - Moca, 5/21/2026
//=====================================================================================================