//==========================================================================//
// QuidditchBar.
//
// HUD item class for the Quidditch progress bar.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//

class QuidditchBar extends HudItemManager;

//= Constants =//
const strBAR_EMPTY = "HP2_Menu.Hud.HP2_QuidBarEmpty";		// Empty bar texture name
const strBAR_FULL = "HP2_Menu.Hud.HP2_QuidBarFull";			// Full bar texture name
const strBAR_GOLD = "HP2_Menu.Hud.HP2QuidditchBarGold";		// Gold bar texture name
const strBAR_WHITE = "HP2_Menu.Hud.HP2QuidditchBarWhite";	// White bar texture name

const fBAR_W = 117.0;		// Bar width
const fBAR_H = 20.0;		// Bar height
const fBAR_START_X = 4.0;	// Bar starting X pos
const fBAR_START_Y = 52.0;	// Bar starting Y pos

const fSCREEN_OVER_FROM_RIGHT_X = 132.0;	// How far from right of screen to be placed
const fSCREEN_UP_FROM_BOTTOM_Y = 80.0;		// How far from bottom of screen to be placed

//= General Variables =//
var bool bRegisteredWithHud;	// Are we registered with the HUD
var int nPercentFull;			// What percentage of full are we

//= Flashing =//
var bool bFlashing;				// Is bar flashing
var float fFadeRedTotalSecs;	// How long to fade to red
var float fFadeRedCurrSecs;		// Current fade to red time
var float fFlashTotalSeconds;	// How long to flash
var float fFlashCurrSeconds;	// Current flash time

//= Texture References =//
var Texture textureBarEmpty;	// Ref to empty texture
var Texture textureBarFull;		// Ref to full texture
var Texture textureBarGold;		// Ref to gold texture
var Texture textureBarWhite;	// Ref to white texture


//=========
// Events
//=========

// Called after gameplay begin
event PostBeginPlay()
{
	// Call parent behavior
    Super.PostBeginPlay();

	// Load textures from constant names
    textureBarEmpty = Texture(DynamicLoadObject(strBAR_EMPTY, class'Texture'));
    textureBarFull = Texture(DynamicLoadObject(strBAR_FULL, class'Texture'));
    textureBarGold = Texture(DynamicLoadObject(strBAR_GOLD, class'Texture'));
    textureBarWhite = Texture(DynamicLoadObject(strBAR_WHITE, class'Texture'));
	
	// Get references to Harry and his HUD
	CheckHUDReferences();
}

// Called when being destroyed
event Destroyed()
{
	// Clear HUD's registered quidditch bar
    HPHud(harry(Level.PlayerHarryActor).myHUD).RegisterQuidditchBar(None);
	HPHud(HUD).RegisterQuidditchBar(None);
	
	// Call parent behavior
    Super.Destroyed();
}


//===============
// Bar Handling
//===============

// Shows or hides the bar based on the value of bShow
function Show(bool bShow)
{
	// If we should show, go to display state
    if(bShow)
    {
        GotoState('DisplayQBar');
    }
	// Otherwise, go to idle state
    else
    {
        GotoState('Idle');
    }
}

// Set whether or not bar should be flashing
function SetFlashing(bool flashing)
{
    bFlashing = flashing;
}

// Set current progress
function SetProgress(int nPercentFullIn, optional bool bShowWhite, optional float fFadeRedOutSeconds)
{
	// Clamp percent full between 0 and 100 and set it as the current percentage
    Clamp(nPercentFullIn, 0, 100);
    nPercentFull = nPercentFullIn;

	// If we should show white
    if(bShowWhite) 
    {
		// Set fade red total time
        fFadeRedTotalSecs = fFadeRedOutSeconds;

		// Reset fade red current time to 0.0
        fFadeRedCurrSecs = 0.0;
    }
}

// Get bar color
function Color GetBarDrawColor()
{
    local Color colorRet;
    local float ratio;

	// If fade red total time is 0, set color to bronze color
    if(fFadeRedTotalSecs == 0)
    {
        colorRet.R = 210;
        colorRet.G = 145;
        colorRet.B = 0;
    }
	// Otherwise, scale towards bronze color based on calculated ratio
    else
    {
        ratio = fFadeRedCurrSecs / fFadeRedTotalSecs;
        colorRet.R = 255 - (45 * ratio);
        colorRet.G = 255 - (110 * ratio);
        colorRet.B = 255 - (255 * ratio);
    }

	// Return final color
    return colorRet;
}


//=========
// States
//=========

// Default idle state
auto state Idle
{    
}

// Display bar state
state DisplayQBar
{
	// On exit state
	event EndState()
    {
		// Set that we're not registered
        bRegisteredWithHud = false;

		// Clear HUD's registered quidditch bar
        HPHud(harry(Level.PlayerHarryActor).myHUD).RegisterQuidditchBar(None);
    }

	// On tick
    event Tick(float DeltaTime)
    {
		// If we're not registered with HUD
        if( !bRegisteredWithHud )
        {
			// If Harry has a HUD
            if( Level.PlayerHarryActor.myHUD != None )
            {
                // Get reference to Harry and his HUD
				CheckHUDReferences();

				// Register ourselves
				HPHud(HUD).RegisterQuidditchBar(self);
				
				// Set that we've been registered
                bRegisteredWithHud = true;
            }
        }

		// If current flash seconds is greater than 0, decrease it
		if( fFlashCurrSeconds > 0 )
        {
            fFlashCurrSeconds -= DeltaTime;
        }
		// Otherwise, set flash current seconds to flash total seconds
        else
        {
            fFlashCurrSeconds = fFlashTotalSeconds;
        }

		// If fade red total seconds is greater than 0
        if( fFadeRedTotalSecs > 0 )
        {
			// If current fade red seconds is greater or equal to total fade red seconds
            if(fFadeRedCurrSecs >= fFadeRedTotalSecs)
            {
				// Reset current and total settings to 0.0
                fFadeRedCurrSecs = 0.0;
                fFadeRedTotalSecs = 0.0;
            }
			// Otherwise
            else
            {
				// Increment current seconds
                fFadeRedCurrSecs += DeltaTime;

				// Clamp current seconds between 0.0 and total seconds
                fFadeRedCurrSecs = FClamp(fFadeRedCurrSecs, 0.0, fFadeRedTotalSecs);
            }
        }
    }
	
	// Render HUD items
    function RenderHudItemManager(Canvas Canvas, bool bMenuMode, bool bFullCutMode, bool bHalfCutMode)
    {
		local bool empty;
		local float fScaleFactor, fFullRatio, fSegmentWidth, fScaleWithoutH;
        local int fIconX, fIconY;
        local Color colorSave;
        
		// Get reference to Harry and his HUD
		CheckHUDReferences();

		// Store current draw color
        colorSave = Canvas.DrawColor;
		
		// Get scale factor without height scaling
		fScaleWithoutH = GetScaleFactor(Canvas);
		
		// Get scale factor with height scaling
        fScaleFactor = GetScaleFactor(Canvas) * Class'M212HScale'.Static.CanvasGetHeightScale(Canvas);
		
        // Calculate icon X pos
        fIconX = Canvas.SizeX - (fScaleWithoutH * fSCREEN_OVER_FROM_RIGHT_X);
		
		// Calculate icon Y pos
        fIconY = Canvas.SizeY - (fScaleFactor * fSCREEN_UP_FROM_BOTTOM_Y);
		
		// Align icon X pos to the right
		AlignXToRight(Canvas, fIconX);

		// Apply scale to icon X pos
		fIconX = ApplyHUDScale(Canvas, fIconX);
		
		// Set canvas position for icon
        Canvas.SetPos(fIconX, fIconY);
		
		// Set empty to if we're not flashing OR if current flash seconds is greater than half of the flash total seconds
		empty = !bFlashing || (fFlashCurrSeconds > fFlashTotalSeconds / 2);

		// If empty, draw empty icon
        if(empty)
        {
            Canvas.DrawIcon(textureBarEmpty, fScaleFactor);
        }
		// Otherwise, draw full icon
        else
        {
            Canvas.DrawIcon(textureBarFull, fScaleFactor);
        }
		
		// Calculate full ratio from nPercentFull, normalized & clamped to be between 0.0 and 1.0
        fFullRatio = float(nPercentFull) / 100.0;
        fFullRatio = FClamp(fFullRatio, 0.0, 1.0);
		
		// Set canvas draw color to the result of GetBarDrawColor
        Canvas.DrawColor = GetBarDrawColor();

		// Determine segment width from ratio
        fSegmentWidth = fFullRatio * fBAR_W;

		// Draw empty bar based on segment width
        Canvas.SetPos(fIconX + (fBAR_START_X * fScaleFactor), fIconY + (fBAR_START_Y * fScaleFactor));
		
		// If empty, draw white bar texture
        if(empty)
        {
            Canvas.DrawTile(textureBarWhite, fSegmentWidth * fScaleFactor, textureBarWhite.VSize * fScaleFactor, 0.0, 0.0, fSegmentWidth, textureBarWhite.VSize);
        }

		// Restore canvas draw color to the saved color
        Canvas.DrawColor = colorSave;
    }
}


//=====================
// Default Properties
//=====================
defaultproperties
{
	fFlashTotalSeconds=0.20

	bHidden=True

	DrawType=DT_Sprite
}