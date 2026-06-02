//==========================================================================//
// baseWarning.
//
// Base class for warning pop ups. Unused in HP2.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class baseWarning extends basePopup;

//== Imports ==//
#exec Texture Import File=Textures\Icons\leftPanel.PNG	GROUP=Icons	Name=leftPanel COMPRESSION=3 UPSCALE=1 Mips=0 Flags=0

//== Pop Up ==//
var bool bShow;
var float fFlashTime;
var string DisplayText;



//=================
// Main Functions
//=================

// Called on tick, increments fFlashTime
event Tick (float DeltaTime)
{
	Super.Tick(DeltaTime);
	fFlashTime += DeltaTime;
}

// Called in baseHUD's DrawPopup function
function Draw (Canvas Canvas)
{
	local Font saveFont;
	local float fTextHeight;
	local float fTextWidth;
	local int t;
	local Texture Background;

	// Store the current canvas font
	saveFont = Canvas.Font;

	// If we should be shown
	if ( bShow )
	{
		// If flash time is greater than 1, make sure we show up and reset flash time
		if ( fFlashTime > 1 )
		{
			bShow = True;
			fFlashTime = 0.0;
		}

		// Set background to leftPanel texture
		Background = Texture'leftPanel';

		// Set our alpha to 0.5, being partially transparent
		Background.Alpha = 0.5;

		// Make sure we render transparent
		Background.bTransparent = True;

		// Set the canvas font to the console's big font
		Canvas.Font = baseConsole(PlayerHarry.Player.Console).LocalBigFont;
		
		// Set fTextWidth and fTextHeight based on our display text
		Canvas.TextSize(DisplayText,fTextWidth,fTextHeight);

		// If our text width exceeds the size of our canvas width with 32 units of margin
		if ( fTextWidth > Canvas.SizeX - 32 )
		{
			// Set the canvas font to the console's medium font
			Canvas.Font = baseConsole(PlayerHarry.Player.Console).LocalMedFont;

			// Recalculate text size
			Canvas.TextSize(DisplayText,fTextWidth,fTextHeight);

			// If our text still exceeds the desired size
			if ( fTextWidth > Canvas.SizeX - 32 )
			{
				// Set the canvas font to the console's small font
				Canvas.Font = baseConsole(PlayerHarry.Player.Console).LocalSmallFont;

				// Recalculate text size
				Canvas.TextSize(DisplayText,fTextWidth,fTextHeight);
			}
		}

		// Move the canvas slightly off center
		Canvas.SetPos(Canvas.SizeX / 2 - (fTextWidth / 2) - 8,8.0);
		
		// Draw the texture tile
		Canvas.DrawTile(Background,fTextWidth + 16,fTextHeight + 16,0.0,0.0,1.0,1.0);

		// Center the canvas
		Canvas.SetPos(Canvas.SizeX / 2 - (fTextWidth / 2),16.0);

		// Draw the text
		Canvas.DrawText(DisplayText,False);
	}
	// Otherwise
	else
	{
		// If flash time exceeds 0.5, show us and reset flash time
		if ( fFlashTime > 0.5 )
		{
			bShow = True;
			fFlashTime = 0.0;
		}
	}

	// Reset canvas font to the original font
	Canvas.Font = saveFont;
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	DisplayText="WARNING"

	bShow=True

	LifeSpan=0.00
}

//=====================================================================================================
// I wish KW warned me about their bad code
// - Moca, 6/2/2026
//=====================================================================================================