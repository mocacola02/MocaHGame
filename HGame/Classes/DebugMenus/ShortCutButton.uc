//==========================================================================//
// ScalingComboBox.
//
// Button class used for ShortCutBrowser.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class ShortCutButton extends UWindowButton;

//= Imports =//
#exec Texture Import File=Textures\Icons\ButtonUpTexture.PNG	GROUP=Icons	Name=ButtonUpTexture COMPRESSION=3 UPSCALE=1 Mips=0 Flags=536870914
#exec Texture Import File=Textures\Icons\ButtonDownTexture.PNG	GROUP=Icons	Name=ButtonDownTexture COMPRESSION=3 UPSCALE=1 Mips=0 Flags=536870914

//= Main Vars =//
var string strText;	// Text string

var Texture UpButtonTexture;	// Up button texture
var Texture DownButtonTexture;	// Down button texture



//=================
// Main Functions
//=================

// Called when resized
function Resized()
{
	// Call parent behavior
	Super.Resized();
	
	// Metallicafan212:	Scale the region to window size
	UpRegion.W			= WinWidth;
	UpRegion.H			= WinHeight;
	
	DownRegion.W		= WinWidth;
	DownRegion.H		= WinHeight;
	
	DisabledRegion.W	= WinWidth;
	DisabledRegion.H	= WinHeight;
	
	OverRegion.W		= WinWidth;
	OverRegion.H		= WinHeight;
}

// Called when created
function Created ()
{
	// Call parent behavior
	Super.Created();

	// Set textures
	UpTexture = UpButtonTexture;
	DownTexture = DownButtonTexture;
	OverTexture = UpButtonTexture;

	// Set text string to "NOSTR"
	strText = "NOSTR";
}

// Set strText to a given string
function SetText (string NewText)
{
	strText = NewText;
}

// Paint onto canvas
function Paint (Canvas Canvas, float X, float Y)
{
	// Call parent behavior
	Super.Paint(Canvas,X,Y);

	// Zero out draw color to get black
	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G = 0;
	Canvas.DrawColor.B = 0;

	// Clip the text string
	ClipText(Canvas,4.0,4.0,strText);
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	UpButtonTexture=ButtonUpTexture
	DownButtonTexture=ButtonDownTexture
}

