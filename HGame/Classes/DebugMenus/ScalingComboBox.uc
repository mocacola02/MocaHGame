
//==========================================================================//
// ScalingComboBox.
//
// Metallicafan212:	A combo box that scales correctly
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class ScalingComboBox based on UWindowComboControl;

// Call when resized
function Resized()
{
	// Call parent behavior
	Super.Resized();
	
	// Metallicafan212:	Now set everything up
	// Set edit box width to the window width minus 12 units, and the height to the window height
	EditBox.SetSize(WinWidth - 12, WinHeight);
	
	// Set button width to the window width minus 12 units, and the height to 12 units
	Button.SetSize(WinWidth - 12, 12);
	
	// If we have a left button, set its width to the window width minus 12 units, and the height to 12 units
	if(LeftButton != None)
	{
		LeftButton.SetSize(WinWidth - 12, 12);
	}
	
	// If we have a right button, set its width to the window width minus 12 units, and the height to 12 units
	if(RightButton != None)
	{
		RightButton.SetSize(WinWidth - 12, 12);
	}
	
	// Set edit box width to window width
	EditBoxWidth = WinWidth;

	// Set edit area draw X and Y to 0.0
	EditAreaDrawX = 0.0;
	EditAreaDrawY = 0.0;
}