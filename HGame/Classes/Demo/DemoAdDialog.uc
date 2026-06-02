//==========================================================================//
// DemoAdDialog.
//
// Leftover advertisement window from the demo build.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class DemoAdDialog extends UWindowDialogClientWindow;

//= Main Vars =//

// Background struct, stores textures (forming one larger screen) and duration
struct Background
{
	var Texture p1;
	var Texture p2;
	var Texture p3;
	var Texture p4;
	var Texture p5;
	var Texture p6;
	var float durration;
};

var bool bShift;					// Is shift key held?

//= Backgrounds =//
var Background DemoAd1Background;	// Demo ad background
var Background curBackground;		// Current background

//= Timing =//
var bool bClosing;					// Is window closing?
var bool bClosedFromTick;			// Is closed from tick?
var int FrameCount;					// Current frame count
var float TimeOutTime;				// Current time out duration
var float TimeOut;					// Max time out duration
var float AcceptKeyInputTime;		// Current time to accept key input
var float TimeTillAcceptInput;		// Max time to accept key input


//==========
// Display
//==========

// Sets up window
function Setup (float setTimeOut)
{
	// Set time out to provided setTimeOut
	TimeOut = setTimeOut;

	// Set current time out time to 0.0
	TimeOutTime = 0.0;

	// Set frame count to 0
	FrameCount = 0;

	// Set background to ad background
	curBackground = DemoAd1Background;

	// Load tiled image textures
	curBackground.p1 = Texture(DynamicLoadObject("HPDemoAd.FEDemoAdBack1Texture1",Class'Texture'));
	curBackground.p2 = Texture(DynamicLoadObject("HPDemoAd.FEDemoAdBack1Texture2",Class'Texture'));
	curBackground.p3 = Texture(DynamicLoadObject("HPDemoAd.FEDemoAdBack1Texture3",Class'Texture'));
	curBackground.p4 = Texture(DynamicLoadObject("HPDemoAd.FEDemoAdBack1Texture4",Class'Texture'));
	curBackground.p5 = Texture(DynamicLoadObject("HPDemoAd.FEDemoAdBack1Texture5",Class'Texture'));
	curBackground.p6 = Texture(DynamicLoadObject("HPDemoAd.FEDemoAdBack1Texture6",Class'Texture'));
}

// Scale window and draw it
function ScaleAndDraw (Canvas Canvas, float X, float Y, Texture Tex)
{
	local float FX;
	local float fy;

	// If texture is none, do nothing and return
	if ( Tex == None )
	{
		return;
	}

	// Scale window to support widescreen
	FX = 1.0;
	FY = (4.0 / 3.0) / (Root.RealWidth / Root.RealHeight);
	
	// Draw the stretched texture
	DrawStretchedTexture(Canvas,X * FX,Y * fy, Tex.USize* FX, Tex.VSize * fy,Tex);
}

// Paint element onto canvas
function Paint (Canvas Canvas, float X, float Y)
{
	// Draw all tiled image textures
	ScaleAndDraw(Canvas,0.0,0.0,curBackground.p1);
	ScaleAndDraw(Canvas,256.0,0.0,curBackground.p2);
	ScaleAndDraw(Canvas,512.0,0.0,curBackground.p3);
	ScaleAndDraw(Canvas,0.0,256.0,curBackground.p4);
	ScaleAndDraw(Canvas,256.0,256.0,curBackground.p5);
	ScaleAndDraw(Canvas,512.0,256.0,curBackground.p6);
}

// Called after painting
function AfterPaint (Canvas C, float X, float Y)
{
	// Call parent behavior
	Super.AfterPaint(C,X,Y);

	// If time out is not 0
	if ( TimeOut != 0 )
	{
		// Increment frame count
		FrameCount++;

		// If frame count is equal or greater than 5
		if ( FrameCount >= 5 )
		{
			// Set accept key input time to level's time plus time to accept input
			AcceptKeyInputTime = GetEntryLevel().TimeSeconds + TimeTillAcceptInput;

			// Set time out time to level's time plus time out
			TimeOutTime = GetEntryLevel().TimeSeconds + TimeOut;
			
			// Set time out to 0.0
			TimeOut = 0.0;
		}
	}

	// If time out time is not 0.0 AND level time exceeds the time out time
	if ( TimeOutTime != 0.0 && GetEntryLevel().TimeSeconds > TimeOutTime )
	{
		// Set time out time to 0.0
		TimeOutTime = 0.0;

		// Set that we closed from tick
		bClosedFromTick = True;

		// Close window
		Close();
	}
}

// Close the window
function Close (optional bool bByParent)
{
	// If not already closing
	if ( !bClosing )
	{
		// Set that we're closing
		bClosing = True;

		// Call parent behavior
		Super.Close(bByParent);

		// Call that the window is done
		OwnerWindow.WindowDone(self);
	}
}


//========
// Input
//========

// Called when closing with escape, does nothing here
function EscClose ();

// Handles key event OR shift is held
function bool KeyEvent (byte Key, byte Action, float Delta)
{
	// If level time exceeds accept key input time OR shift is held
	if ( (GetEntryLevel().TimeSeconds > AcceptKeyInputTime) || bShift )
	{
		// If action is released AND pressed key is space or escape
		if ( Action == 3 && (Key == 32 || Key == 27) )
		{
			// Close window
			Close();
		}
	}
	// Otherwise
	else
	{
		// If action is pressed AND key is shift
		if ( Action == 1 && Key == 16 )
		{
			// Set shift to true
			bShift = True;
		}
		// Otherwise, if action is axis movement AND key is shift
		else if ( Action == 4 && Key == 16 )
		{
			// Set shift to false
			bShift = False;
		}
	}

	// Return false
	return False;
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	TimeTillAcceptInput=10.00
}
