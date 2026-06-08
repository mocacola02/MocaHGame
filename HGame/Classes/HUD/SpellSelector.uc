//==========================================================================//
// SpellSelector.
//
// HUD item class for the dueling mini-game's spell selector.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class SpellSelector extends HudItemManager;

//= Constants =//
const nSPACE_BETWEEN_ICONS= 4;	// How much space between icons

const nTEXT_OFFSET_X= 20;	// Text X offset
const nTEXT_OFFSET_Y= 50;	// Text Y offset

const nSTART_X= 2;			// Start X pos
const nSTART_Y= 175;		// Start Y pos

const strRICTUSEMPRA_HOTKEY= "1";	// Hotkey for Rictusempra
const strMIMBLEWIMBLE_HOTKEY= "2";	// Hotkey for Mimblewimble
const strEXPELLIARMUS_HOTKEY= "3";	// Hotkey for Expelliarmus

const strSPELL_RICTUSEMPRA= "HP2_Menu.Icons.HP2SpellRictusempra";				// Rictusempra icon texture name
const strSPELL_RICTUSEMPRA_SEL= "HP2_Menu.Icons.HP2SpellRictusempraSelect";		// Rictusempra selected icon texture name

const strSPELL_EXPELLIARMUS= "HP2_Menu.Icons.HP2SpellExpelliarmus";				// Expelliarmus icon texture name
const strSPELL_EXPELLIARMUS_SEL= "HP2_Menu.Icons.HP2SpellExpelliarmusSelect";	// Expelliarmus selected icon texture name

const strSPELL_MIMBLEWIMBLE= "HP2_Menu.Icons.HP2SpellMimblewimble";				// Mimblewimble icon texture name
const strSPELL_MIMBLEWIMBLE_SEL= "HP2_Menu.Icons.HP2SpellMimblewimbleSelect";	// Mimblewimble selected icon texture name

//= General Variables =//
enum ESpellSelection		// Enum for the current selected spell
{
	SSelection_Rictusempra,
	SSelection_Mimblewimble,
	SSelection_Expelliarmus
};

var ESpellSelection CurrSelection;		// What spell is selected

var Texture textureSpellRictusempra;	// Rictusempra texture ref
var Texture textureSpellRictusempraSel;	// Rictusempra selected texture ref
var Texture textureSpellMimblewimble;	// Mimblewimble texture ref
var Texture textureSpellMimblewimbleSel;// Mimblewimble selected texture ref
var Texture textureSpellExpelliarmus;	// Expelliarmus texture ref
var Texture textureSpellExpelliarmusSel;// Expelliarmus selected texture ref


//=========
// Events
//=========

// Called after gameplay starts
event PostBeginPlay()
{
	// Call parent behavior
	Super.PostBeginPlay();
	
	// Get textures from constant names
	textureSpellRictusempra 		= Texture(DynamicLoadObject(strSPELL_RICTUSEMPRA, Class'Texture'));
	textureSpellRictusempraSel 		= Texture(DynamicLoadObject(strSPELL_RICTUSEMPRA_SEL, Class'Texture'));
	textureSpellMimblewimble 		= Texture(DynamicLoadObject(strSPELL_MIMBLEWIMBLE, Class'Texture'));
	textureSpellMimblewimbleSel 	= Texture(DynamicLoadObject(strSPELL_MIMBLEWIMBLE_SEL, Class'Texture'));
	textureSpellExpelliarmus 		= Texture(DynamicLoadObject(strSPELL_EXPELLIARMUS, Class'Texture'));
	textureSpellExpelliarmusSel 	= Texture(DynamicLoadObject(strSPELL_EXPELLIARMUS_SEL, Class'Texture'));
	
	// Set looping timer for 0.2 seconds
	SetTimer(0.2,True);
}

// Called when destroyed
event Destroyed()
{
	// Log that we're being destroyed
	harry(Level.PlayerHarryActor).ClientMessage("spellselector destroyed");

	// Clear HUD's registered spell selector
	HPHud(harry(Level.PlayerHarryActor).myHUD).RegisterSpellSelector(None);
	
	// Call parent behavior
	Super.Destroyed();
}

// Called when timer times out
event Timer()
{
	// If Harry has a HUD
	if ( Level.PlayerHarryActor.myHUD != None )
	{
		// Register self as spell selector
		HPHud(harry(Level.PlayerHarryActor).myHUD).RegisterSpellSelector(self);

		// Set non-looping timer for 0.0 seconds
		SetTimer(0.0,False);
	}
}


//============
// Rendering
//============

// Render HUD items
function RenderHudItemManager (Canvas Canvas, bool bMenuMode, bool bFullCutMode, bool bHalfCutMode)
{
	local float fScaleFactor, HScale;
	local int nIconX, nIconY;
	local Texture textureSpellIcon;

	// Get reference to Harry and his HUD
	CheckHUDReferences();
	
	// Get HScale
	HScale = Class'M212HScale'.Static.CanvasGetHeightScale(Canvas);

	// Get scale factor
	fScaleFactor = GetScaleFactor(Canvas);

	// Adjust icon's X and Y position based on scale factor and height scale
	nIconX = nSTART_X * fScaleFactor;
	nIconY = nSTART_Y * fScaleFactor * HScale;

	// Align icon X pos to the left
	AlignXToLeft(Canvas, nIconX);

	// Apply scale to icon X pos
	nIconX = ApplyHUDScale(Canvas, nIconX);
  
	// If rictu is selected, draw rictu selection icon
	if ( CurrSelection == SSelection_Rictusempra )
	{
		textureSpellIcon = textureSpellRictusempraSel;
	}
	// Otherwise, draw normal rictu icon
	else 
	{
		textureSpellIcon = textureSpellRictusempra;
	}
	
	// Draw rictu icon
	DrawSpellIcon(Canvas, fScaleFactor * HScale, textureSpellIcon, nIconX, nIconY, "1");

	// Adjust icon Y for the next spell icon
	nIconY += (textureSpellRictusempra.VSize + nSPACE_BETWEEN_ICONS) * fScaleFactor * HScale;
  
	// If mimble is selected, draw mimble selection icon
	if ( CurrSelection == SSelection_Mimblewimble )
	{
		textureSpellIcon = textureSpellMimblewimbleSel;
	}
	// Otherwise, draw normal mimble icon
	else 
	{
		textureSpellIcon = textureSpellMimblewimble;
	}
  
	// Draw mimble icon
	DrawSpellIcon(Canvas, fScaleFactor * HScale, textureSpellIcon, nIconX, nIconY, "2");

	// Adjust icon Y for the next spell icon
	nIconY += (textureSpellMimblewimble.VSize + nSPACE_BETWEEN_ICONS) * fScaleFactor * HScale;
  
	// If expell is selected, draw expell selection icon
	if ( CurrSelection == SSelection_Expelliarmus )
	{
		textureSpellIcon = textureSpellExpelliarmusSel;
	}
	// Otherwise, draw normal expell icon
	else 
	{
		textureSpellIcon = textureSpellExpelliarmus;
	}
	
	// Draw expell icon
	DrawSpellIcon(Canvas, fScaleFactor * HScale, textureSpellIcon, nIconX, nIconY, "3");
}

// Draw spell icon
function DrawSpellIcon (Canvas Canvas, float fScaleFactor, Texture textureSpellIcon, int nIconX, int nIconY, string strHotKey)
{
	// Set canvas position to the target icon position
	Canvas.SetPos(nIconX,nIconY);

	// Draw the given icon texture
	Canvas.DrawIcon(textureSpellIcon,fScaleFactor);

	// Draw hotkey text
	DrawHotKeyText(Canvas, nIconX, nIconY, strHotKey);
}

// Draw hotkey text
function DrawHotKeyText (Canvas Canvas, int nIconX, int nIconY, string strHotKey)
{
	local int nXOffset, nYOffset;
	local float fScaleFactor, HScale;
	local float fXTextLen, fYTextLen;
	local Color colorSave;
	local Font fontSave;
	
	// Get HScale
	HScale = Class'M212HScale'.Static.CanvasGetHeightScale(Canvas);

	// Get scale factor
	fScaleFactor = GetScaleFactor(Canvas);

	// Store current draw color
	colorSave = Canvas.DrawColor;

	// Store current font
	fontSave = Canvas.Font;

	// Set draw color to pale brown
	Canvas.DrawColor.R = 206;
	Canvas.DrawColor.G = 200;
	Canvas.DrawColor.B = 190;
	
	// If canvas x size is or is less than 512, use tiny font
	if ( Canvas.SizeX <= 512 )
	{
		Canvas.Font = baseConsole(Level.PlayerHarryActor.Player.Console).LocalTinyFont;
	}
	// Otherwise, if x size is or is less than 640, use small font 
	else if ( Canvas.SizeX <= 640 )
    {
		Canvas.Font = baseConsole(Level.PlayerHarryActor.Player.Console).LocalSmallFont;
    }
	// Otherwise, use medium font
	else 
	{
		Canvas.Font = baseConsole(Level.PlayerHarryActor.Player.Console).LocalMedFont;
	}
	
	// Calculate text size
	Canvas.TextSize(strHotKey,fXTextLen,fYTextLen);

	// Get text X and Y offset
	nXOffset = ((nTEXT_OFFSET_X * fScaleFactor) - fXTextLen / 2) * HScale; 
	nYOffset = ((nTEXT_OFFSET_Y * fScaleFactor) - fXTextLen / 2) * HScale;

	// Set canvas position
	Canvas.SetPos(nIconX + nXOffset, nIconY + nYOffset);

	// Draw text
	Canvas.DrawText(strHotKey, false);

	// Restore saved color and font
	Canvas.DrawColor = colorSave;
	Canvas.Font = fontSave;
}


//================
// Misc. Helpers
//================

// Sets the current selected spell
function SetSelection (ESpellSelection SSelection)
{
  	CurrSelection = SSelection;
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bHidden=True

	DrawType=DT_Sprite
}
