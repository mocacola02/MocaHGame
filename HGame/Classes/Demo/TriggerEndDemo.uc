//==========================================================================//
// TriggerEndDemo.
//
// Leftover trigger from demo build that ends the demo.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class TriggerEndDemo extends Trigger;


//=================
// Main Functions
//=================

// Called when processing trigger
function ProcessTrigger()
{
	local harry PlayerHarry;

	// Get reference to Harry
	PlayerHarry = harry(Level.PlayerHarryActor);

	// If Harry is none, log that we couldn't find him and return
	if ( PlayerHarry == None )
	{
		Log("TriggerEndDemo: Couldn't find Harry, and that ain't right!");
		return;
	}
	
	// Show end of demo advertisement
	HPConsole(PlayerHarry.Player.Console).menuBook.ShowDemoAds(20.0);
}

//=========
// States
//=========

// Default waiting state
auto state Waiting
{
	// Called on trigger
	event Trigger (Actor Other, Pawn EventInstigator)
	{
		// Process trigger
		ProcessTrigger();
		// Log that we were triggered
		Level.PlayerHarryActor.ClientMessage(string(self) $ " Here");
	}
	
	// Called on touch
	event Touch (Actor Other)
	{
		// Call parent behavior
		Super.Touch(Other);

		// If touched actor is Harry, process trigger
		if ( Other == Level.PlayerHarryActor )
		{
			ProcessTrigger();
		}
	}
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	InitialState=None
}
