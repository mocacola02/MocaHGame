//==========================================================================//
// HudItemManager.
//
// Base class to manage drawn HUD items.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class HudItemManager extends Actor;

const BASE_RESOLUTION_X = 640.0;	// Base resolution X size
const BASE_RESOLUTION_Y = 480.0;	// base resolution Y size

// Omega: Alignment type
// Holdover from StatusGroup's new code but can be used for new HUD items anyway, so I'll leave it coded in
// And maintain it. However, the existing implementations with the hardcoded offsets won't be using this new
// system. This is for future coders of a HudItemManager subclass
// This also means that this class now holds a lot of math functions for scaling your rendered items on the 
// Canvas without having it move about when it's in other ratios than 4:3
var enum EAlignmentType
{
	AT_None,
	AT_Left,
	AT_Right,
	AT_Center,
	AT_Arbitrary
} AlignmentType;

var float ScreenPctToAlignTo;	// Omega: Used for AT_Arbitrary, intended 0-1 percentage to multiply against Canvas.SizeX
var Harry PlayerHarry;			// Reference to Harry
var BaseHud HUD;				// Reference to HUD


//==========
// Display
//==========

// Handles HUD item rendering, by default just checks if we have references to Harry and his HUD
function RenderHudItemManager (Canvas Canvas, bool bMenuMode, bool bFullCutMode, bool bHalfCutMode)
{
	CheckHUDReferences();
}


//==========
// Scaling
//==========

// Gets the X axis scale factor from canvas size / base resolution size
// AKA: The larger SizeX is than base resolution, the larger the scale factor
function float GetScaleFactor (Canvas Canvas)
{
	return Canvas.SizeX / BASE_RESOLUTION_X;
}

// Gets the Y axis scale factor from canvas size / base resolution size
// AKA: The larger SizeY is than base resolution, the larger the scale factor
function float GetScaleFactorY (int nCanvasSizeY)
{
	return nCanvasSizeY / BASE_RESOLUTION_Y;
}

// Calculate horizontal scale based on aspect ratio, using a given Canvas' size
function float GetHScale(Canvas Canvas)
{
	return (4.0 / 3.0) / (float(Canvas.SizeX) / float(Canvas.SizeY));
}

// Calculate horizontal scale based on aspect ratio, using given X and Y values
function float floatGetHScale(float x, float y)
{
	return (4.0 / 3.0) / (x / y);
}

// Omega: Adjusted scale depending on your HUD4By3ScalePercent value, to help provide correct locations on scaled element groups
function float GetHAdjustedScale(Canvas Canvas)
{
	local float hScale;

	// Get canvas' horizontal scale
	hScale = GetHScale(Canvas);

	// Omega: Return a corrected ratio for the hScale depending on our 4:3-ness
	return lerp(HUD.HUD4By3ScalePercent, hScale, 1.0);
}

// Omega: Canvas-less versions. I don't think much use can come of these since the functions intentionally get lied to...
function float NoCanvasGetHAdjustedScale(int nCanvasSizeX, int nCanvasSizeY)
{
	local float hScale;
	hScale = floatGetHScale(nCanvasSizeX, nCanvasSizeY);
	// Omega: Return a corrected ratio for the hScale depending on our 4:3-ness
	return lerp(HUD.HUD4By3ScalePercent, hScale, 1.0);
}

// Omega: Adjust Canvas X coordinates for the 4:3-ness
function float GetHAdjustedX(Canvas Canvas)
{
	return lerp(HUD.HUD4By3ScalePercent, Canvas.SizeX, Canvas.SizeX * GetHScale(Canvas));
}

// Omega: Apply the HUD scale
function int ApplyHUDScale(Canvas Canvas, int nOutX)
{
	local float fScaledScreen;
	local float fCanvasX;
	local float tempX;

	// Get adjusted X position
	fScaledScreen 	= GetHAdjustedX(Canvas);

	// Get canvas X size
	fCanvasX 		= Canvas.SizeX;

	// Get target X position
	tempX 			= nOutX;

	// Get the 4:3 ratio, scale it, add half of what was lost in width back on to recenter it
	tempX = (tempX * fScaledScreen / fCanvasX) + (0.5 * (fCanvasX - fScaledScreen));
	
	// Return final X pos
	return tempX;
}

// Omega: Used to determine horizontal offsets so they match their relative 4:3 offset
function float GetCanvasHHudScale(Canvas Canvas)
{
	local float fScaledWidth;

	// Omega: Safety first!
	// If we don't have a ref to HUD, get it
	if(HUD == None)
	{
		HUD = BaseHud(PlayerHarry.MyHud);
	}

	// Scale width based on aspect ratio and HScale
	fScaledWidth = lerp(HUD.HUD4By3ScalePercent, Canvas.SizeX, Canvas.SizeX * GetHScale(Canvas));
	return (4.0 / 3.0) / (fScaledWidth / float(Canvas.SizeY));
}

// Determine horizontal offsets based on X and Y values instead of the Canvas directly
function float floatGetHHUDScale(float x, float y)
{
	local float fScaledWidth;

	// Omega: Safety first!
	// If we don't have a ref to HUD, get it
	if(HUD == None)
	{
		HUD = BaseHud(PlayerHarry.MyHud);
	}

	// Scale width based on aspect ratio and HScale
	fScaledWidth = lerp(HUD.HUD4By3ScalePercent, x, x * floatGetHScale(x,y));
	return (4.0 / 3.0) / (fScaledWidth / y);
}


//============
// Alignment
//============

// Omega: Main alignment functionality, passes off to other functions
function AlignElement(Canvas Canvas, out int nOutX)
{
	// Call matching alignment function based on our alignment type
	Switch(AlignmentType)
	{
		Case AT_None:
			return;
		Case AT_Left:
			AlignXToLeft(Canvas, nOutX);
			return;
		Case AT_Right:
			AlignXToRight(Canvas, nOutX);
			return;
		Case AT_Center:
			AlignXToCenter(Canvas, nOutX);
			return;
		Case AT_Arbitrary:
			AlignXArbitrary(Canvas, nOutX);
			return;
		default:
			return;
	}
}

// Omega: Align ourselves to the right side of the screen
function AlignXToRight(Canvas Canvas, out int nOutX)
{
	nOutX = Canvas.SizeX - ((Canvas.SizeX - nOutX) * GetHAdjustedScale(Canvas));
}

// Align ourselves to the left side of the screen
function AlignXToLeft(Canvas Canvas, out int nOutX)
{
	nOutX = nOutX * GetHAdjustedScale(Canvas);
}

// Align ourselves to the center of screen
function AlignXToCenter(Canvas Canvas, out int nOutX)
{
	nOutX = (Canvas.SizeX * 0.5) - (((Canvas.SizeX * 0.5) - nOutX) * GetHScale(Canvas));
}

// Align ourselves arbitrarily, based on ScreenPctToAlignTo
function AlignXArbitrary(Canvas Canvas, out int nOutX)
{
	nOutX = (Canvas.SizeX * ScreenPctToAlignTo) - (((Canvas.SizeX * ScreenPctToAlignTo) - nOutX) * GetHAdjustedScale(Canvas));
}

// Align coordinates to the right, returning the aligned X value
function NoCanvasAlignXToRight(int nCanvasSizeX, int nCanvasSizeY, out int nOutX)
{
	nOutX = nCanvasSizeX - ((nCanvasSizeX - nOutX) * NoCanvasGetHAdjustedScale(nCanvasSizeX, nCanvasSizeY));
}

// Align coordinates to the left, returning the aligned X value
function NoCanvasAlignXToLeft(int nCanvasSizeX, int nCanvasSizeY, out int nOutX)
{
	nOutX = nOutX * NoCanvasGetHAdjustedScale(nCanvasSizeX, nCanvasSizeY);
}


//================
// Misc. Helpers
//================

// If we don't have a ref to Harry or his HUD, get them both
function CheckHUDReferences()
{
	if(PlayerHarry == None || HUD == None)
	{
		PlayerHarry = Harry(Level.playerHarryActor);
		HUD = BaseHud(PlayerHarry.MyHud);
	}
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	DrawType=DT_None
}
