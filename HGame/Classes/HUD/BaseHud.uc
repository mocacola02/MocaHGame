//==========================================================================//
// baseHUD.
//
// Base HUD class. Almost entirely unused HP1 leftovers.
//
// Note: 	Effectively unused means that the variable is used in code
// 			somewhere, but said code is never actually called by anything.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class baseHUD extends HUD
  Config(User);

//= Imports ==/
#exec new TrueTypeFontFactory Name=HugeInkFont 	FontName="Times New Roman" Height=24 AntiAlias=1 CharactersPerPage=32 RenderNative=1
#exec new TrueTypeFontFactory Name=BigInkFont 	FontName="Times New Roman" Height=18 AntiAlias=1 CharactersPerPage=32 RenderNative=1
#exec new TrueTypeFontFactory Name=MedInkFont 	FontName="Times New Roman" Height=14 AntiAlias=1 CharactersPerPage=32 RenderNative=1
#exec new TrueTypeFontFactory Name=SmallInkFont FontName="Times New Roman" Height=12 AntiAlias=1 CharactersPerPage=32 RenderNative=1
#exec new TrueTypeFontFactory Name=TinyInkFont 	FontName="Times New Roman" Height=10 AntiAlias=1 CharactersPerPage=32 RenderNative=1

#exec new TrueTypeFontFactory Name=AsianFontHuge FontName="Gulim" Height=24 AntiAlias=0 RenderNative=1 
#exec new TrueTypeFontFactory Name=AsianFontBig FontName="Gulim" Height=18 AntiAlias=0 RenderNative=1  
#exec new TrueTypeFontFactory Name=AsianFontMed FontName="Gulim" Height=14 AntiAlias=0 RenderNative=1  
#exec new TrueTypeFontFactory Name=AsianFontSmall FontName="Gulim" Height=12 AntiAlias=0 RenderNative=1 

#exec new TrueTypeFontFactory Name=JapFontHuge FontName="PMingLiU" Height=24 AntiAlias=0 RenderNative=1 
#exec new TrueTypeFontFactory Name=JapFontBig FontName="PMingLiU" Height=18 AntiAlias=0 RenderNative=1  
#exec new TrueTypeFontFactory Name=JapFontMed FontName="PMingLiU" Height=14 AntiAlias=0 RenderNative=1  
#exec new TrueTypeFontFactory Name=JapFontSmall FontName="PMingLiU" Height=12 AntiAlias=0 RenderNative=1 

#exec new TrueTypeFontFactory Name=SystemFontHuge FontName="system" Height=24 AntiAlias=0 RenderNative=1 CharactersPerPage=64 
#exec new TrueTypeFontFactory Name=SystemFontBig FontName="system" Height=18 AntiAlias=0 RenderNative=1 CharactersPerPage=64 
#exec new TrueTypeFontFactory Name=SystemFontMed FontName="system" Height=14 AntiAlias=0 RenderNative=1 CharactersPerPage=64 
#exec new TrueTypeFontFactory Name=SystemFontSmall FontName="system" Height=12 AntiAlias=0 RenderNative=1 CharactersPerPage=64 

#exec new TrueTypeFontFactory Name=ThaiFontHuge FontName="Tahoma" Height=24 AntiAlias=0 RenderNative=1 CharactersPerPage=64 
#exec new TrueTypeFontFactory Name=ThaiFontBig FontName="Tahoma" Height=20 AntiAlias=0 RenderNative=1 CharactersPerPage=64 
#exec new TrueTypeFontFactory Name=ThaiFontMed FontName="Tahoma" Height=18 AntiAlias=0 RenderNative=1 CharactersPerPage=64 
#exec new TrueTypeFontFactory Name=ThaiFontSmall FontName="Tahoma" Height=14 AntiAlias=0 RenderNative=1 CharactersPerPage=64 

//= General HUD =//
enum _HUDGameType 	// Type of game HUD to use. HP1 leftover/unused
{
	HUDG_QUIDDITCH,	// Quidditch game type
	HUDG_FLYINGKEYS	// Flying keys game type (HP1 leftover)
};

struct IconMessage		// Icon message struct. HP1 leftover/unused
{
	var bool valid;		// Is this a valid icon
	var Texture Icon;	// Icon texture
	var string Message;	// Message to go with icon
	var float duration;	// Message duration
};

var bool bCutSceneMode;			// Are we in cutscene mode?
var bool bCutPopupMode;			// Are we in cutscene pop up mode? aka only the bottom cutscene border is up
var bool bDrawDialogText;		// Are we drawing dialog text? Effectively unused

var basePopup curPopup;			// Current pop up, only used by the HP1 leftover WarnTrigger
var IconMessage curIconMessage;	// Current icon message, effectively unused
var _HUDGameType HUDGameType;	// Current HUD game type, effectively unused

//= Debug Text =//
var int DebugValA, DebugValX, DebugValY, DebugValZ;		// Debug values to display, effectively unused
var string DebugString;									// Final debug string formed from values, effectively unused

var int DebugValA2, DebugValX2, DebugValY2, DebugValZ2; // Secondary debug values to display, effectively unused
var string DebugString2;								// Final secondary debug string formed from values, effectively unused

//= Quidditch =//
var bool bPlayQHUDGame;			// Are we playing quidditch game, effectively unused
var bool bScoreCountup;			// Should we count down the score time, while technically used it doesn't really do anything
var float fScoreCountTime;		// Current score count time, while technically used it doesn't really do anything
var float fMaxScoreCountTime;	// Max allowed score count time, effectively unused


//=========
// Events
//=========

// On tick
event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	// If we have a valid icon message
	if ( curIconMessage.valid )
	{
		// Decrease its duration
		curIconMessage.duration -= DeltaTime;

		// If duration is less than 0, make it invalid
		if ( curIconMessage.duration < 0 )
		{
			curIconMessage.valid = False;
		}
	}
}

// Setup the HUD
simulated function HUDSetup(Canvas Canvas)
{
	// Reset the canvas
	Canvas.Reset();

	// Set X spacing to 0.0
	Canvas.SpaceX 		= 0.0;

	// Do not disable texture filtering on canvas elements (this is set to true in stock)
	Canvas.bNoSmooth 	= False;

	// Set draw color to be white
	Canvas.DrawColor.R 	= 255;
	Canvas.DrawColor.G 	= 255;
	Canvas.DrawColor.B 	= 255;

	// Set font to be the medium font
	Canvas.Font		 	= baseConsole(PlayerPawn(Owner).Player.Console).LocalMedFont;
}

// Draw debugs info. Unused
function DrawDebug(Canvas Canvas)
{
	Canvas.SetPos(8.0, Canvas.SizeY - 240);
	Canvas.DrawText("Text " $ DebugString, False);
	Canvas.SetPos(8.0, Canvas.SizeY - 224);
	Canvas.DrawText("ValA " $ string(DebugValA),False);
	Canvas.SetPos(8.0, Canvas.SizeY - 208);
	Canvas.DrawText("ValX " $ string(DebugValX),False);
	Canvas.SetPos(8.0, Canvas.SizeY - 192);
	Canvas.DrawText("ValY " $ string(DebugValY),False);
	Canvas.SetPos(8.0, Canvas.SizeY - 176);
	Canvas.DrawText("ValZ " $ string(DebugValZ),False);
	Canvas.SetPos(8.0, Canvas.SizeY - 144);
	Canvas.DrawText("Text " $ DebugString2,False);
	Canvas.SetPos(8.0, Canvas.SizeY - 128);
	Canvas.DrawText("ValA " $ string(DebugValA2),False);
	Canvas.SetPos(8.0, Canvas.SizeY - 112);
	Canvas.DrawText("ValX " $ string(DebugValX2),False);
	Canvas.SetPos(8.0, Canvas.SizeY - 96);
	Canvas.DrawText("ValY " $ string(DebugValY2),False);
	Canvas.SetPos(8.0, Canvas.SizeY - 80);
	Canvas.DrawText("ValZ " $ string(DebugValZ2),False);
}

//=========
// Pop Up
//=========
// This section is all unused HP1 leftovers

// Draws the current pop up. Only used by baseWarning
function DrawPopup (Canvas Canvas)
{
	// If we don't have a current pop up, do nothing and return
	if ( curPopup == None )
	{
		return;
	}

	// Draw the pop up
	curPopup.Draw(Canvas);

	// If the current pop up is set to be deleted, clear the reference
	if ( curPopup.bDeleteMe )
	{
		curPopup = None;
	}
}

// Spawns a pop up of a given basePopup class
function ShowPopup (Class<basePopup> popup)
{
	curPopup = Spawn(popup);
}

// Destroy the current pop up, if there is one
function DestroyPopup()
{
	if ( curPopup != None )
	{
		curPopup.Destroy();
		curPopup = None;
	}
}


//================
// Mini-Game HUD
//================
// This section is all unused HP1 leftovers

// Sets the score count time to a given time
function SetScoreCountTime (float t)
{
	fScoreCountTime = t;
	fMaxScoreCountTime = t;
}

// Sets whether or not we're playing a quidditch game
function PlayHUDGame (bool bEnable)
{
	bPlayQHUDGame = bEnable;
}

// Set the game type of the HUD
function SetHUDGameType (_HUDGameType GameType)
{
	HUDGameType = GameType;
}


//=====================
// Misc. HUD Elements
//=====================

// Set the current icon message's icon, message, and duration, and make it valid
// This function is called in Harry, but by an unused function
function ReceiveIconMessage (Texture Icon, string Message, float duration)
{
	curIconMessage.Icon 	= Icon;
	curIconMessage.Message 	= Message;
	curIconMessage.duration = duration;
	curIconMessage.valid 	= True;
}

// Toggles the dialog text border
// Never used, but can be typed into the command console
exec function ToggleDialog()
{
	bDrawDialogText =  !bDrawDialogText;
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bDrawDialogText=True
}