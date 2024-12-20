//================================================================================
// baseConsole.
//================================================================================

class baseConsole extends WindowConsole; 

//texture imports -AdamJD
/*
#exec Texture Import File=Textures\Icons\FELoadingBackground1.PNG	GROUP=Icons	Name=FELoadingBackground1 COMPRESSION=3 UPSCALE=1 Mips=1 Flags=0
#exec Texture Import File=Textures\Icons\FELoadingBackground2.PNG	GROUP=Icons	Name=FELoadingBackground2 COMPRESSION=3 UPSCALE=1 Mips=1 Flags=0
#exec Texture Import File=Textures\Icons\FELoadingBackground3.PNG	GROUP=Icons	Name=FELoadingBackground3 COMPRESSION=3 UPSCALE=1 Mips=1 Flags=0
#exec Texture Import File=Textures\Icons\FELoadingBackground4.PNG	GROUP=Icons	Name=FELoadingBackground4 COMPRESSION=3 UPSCALE=1 Mips=1 Flags=0
#exec Texture Import File=Textures\Icons\FELoadingBackground5.PNG	GROUP=Icons	Name=FELoadingBackground5 COMPRESSION=3 UPSCALE=1 Mips=1 Flags=0
#exec Texture Import File=Textures\Icons\FELoadingBackground6.PNG	GROUP=Icons	Name=FELoadingBackground6 COMPRESSION=3 UPSCALE=1 Mips=1 Flags=0
*/

// Metallicafan212:	One texture
#exec Texture Import File=Textures\LoadingScreen\LoadingScreen.png	GROUP=LoadingScreen NAME=FELoadingScreen COMPRESSION=3 UPSCALE=1 MIPS=0 FLAGS=0

/*
struct BackgroundBitmap
{
  var Texture p1;
  var Texture p2;
  var Texture p3;
  var Texture p4;
  var Texture p5;
  var Texture p6;
  var float durration;
};

var BackgroundBitmap LoadingBackground;
*/

var Texture LoadingBackground;
// Omega: Black background:
var Texture BlackBG;

var bool bLeftKeyDown;
var bool bRightKeyDown;
var bool bForwardKeyDown;
var bool bBackKeyDown;
var bool bUpKeyDown;
var bool bDownKeyDown;
var bool bRotateLeftKeyDown;
var bool bRotateRightKeyDown;
var bool bRotateUpKeyDown;
var bool bRotateDownKeyDown;
var bool bSpaceReleased;
var bool bSpacePressed;
var globalconfig bool bDebugMode;
var globalconfig bool bUseSystemFonts;
var bool bUseAsianFont;
var bool bUseThaiFont;
var string LanguageCode;
var Font LocalHugeFont;
var Font LocalBigFont;
var Font LocalMedFont;
var Font LocalSmallFont;
var Font LocalIconMessageFont;
var Font LocalTinyFont;
var Font IntMedFont;

var(Debugging) bool bForceLoadScreen;	// Omega: Force display of the loading screen

// Metallicafan212:	HP2 shouldn't call this
event bool ShouldDrawLevelInfo(canvas C, string URL)
{
	return false;
}

function ExitFromGame()
{
}

function SaveSelectedSlot()
{
}

function LoadSelectedSlot()
{
}

function ChangeLevel (string lev, bool flag)
{
}

function ScaleAndDraw (Canvas C, float X, float Y, Texture Tex)
{ 
    local float FX;
    local float fy;
    local float Ratio;
    local float CRTScale;
    local float XOffset;
    local float YOffset;
    local float ResX;
    local float ResY;	
	local float HScale;
	
	HScale = GetHScale(C);
	

    if ( Tex == None )
    {
		return;
    }
	
	// Metallicafan212:	This is centered in the previous call, just draw scaled
	FX = 1.0;
 	FY = HScale;
	Root.DrawStretchedTexture(C, (X * FX), (Y * FY), Tex.USize * FX * HScale, Tex.VSize * FY, Tex);
}

function PrintActionMessageInUpperLeft (Canvas C, string BigMessage)
{
	local float XL;
	local float YL;

	C.bCenter = False;
	C.StrLen(BigMessage,XL,YL);
	C.SetPos(FrameX / 4 - XL / 2, FrameY / 4.5 - YL / 2);
	C.DrawText(BigMessage,False);
}

function PrintActionMessageInLowerLeft (Canvas C, string BigMessage)
{
	local float XL;
	local float YL;

	C.bCenter = False;
	C.StrLen(BigMessage,XL,YL);
	C.SetPos(FrameX / 10,FrameY - FrameY / 4 - YL / 2);
	C.DrawText(BigMessage,False);
}

function float GetHScale(Canvas C)
{
	return (4.0 / 3.0) / (FrameX / FrameY);//(Canvas.SizeX / float(Canvas.SizeY));
}

function DrawStretchedTextureSegment( Canvas C, float X, float Y, float W, float H, 
									  float tX, float tY, float tW, float tH, texture Tex ) 
{
	local float OrgX, OrgY, ClipX, ClipY, HScale;
	
	local bool bOldNoSmooth;
	
	// Metallicafan212:	Disable no smooth
	bOldNoSmooth = C.bNoSmooth;
	C.bNoSmooth = false;
	
	HScale = GetHScale(C);//Class'M212HScale'.Static.CanvasGetHeightScale(C);

	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;

	C.SetOrigin(OrgX + Root.ClippingRegion.X * Root.GUIScale, OrgY + Root.ClippingRegion.Y * Root.GUIScale);
	C.SetClip(Root.RealWidth, Root.RealHeight);//ClippingRegion.W * Root.GUIScale, ClippingRegion.H * Root.GUIScale);

	C.SetPos((X - Root.ClippingRegion.X) * Root.GUIScale, (Y - Root.ClippingRegion.Y) * Root.GUIScale);
	
	C.DrawTileClipped( Tex, W * Root.GUIScale * HScale, H * Root.GUIScale * HScale, tX, tY, tW, tH);
	
	C.SetClip(ClipX, ClipY);
	C.SetOrigin(OrgX, OrgY);
	
	C.bNoSmooth = bOldNoSmooth;
}

function DrawLevelAction (Canvas C)
{
	local string BigMessage;
	local float fTextWidth;
	local float fTextHeight;
	local float Offset;
	local float HScale;
	local Color OldColor;
	
	local float XL;
	local float YL;
	
	// Omega: Used by new scaling stuff
	local float fScaleFactor;
	local int xOffset;
	
	HScale = GetHScale(C);//Class'M212HScale'.Static.UWindowGetHeightScale(Root);//GetHScale(C);
	// Omega: Get the scale factor:
	fScaleFactor = (C.SizeX / 640.0) * HScale;
	
	OldColor = C.DrawColor;

	if ( (Viewport.Actor.Level.Pauser != "") && Viewport.Actor.Level.LevelAction == LEVACT_None && !bForceLoadScreen)
	{
		C.Font = C.MedFont;
		BigMessage = PausedMessage;
		PrintActionMessage(C,BigMessage);
		return;
	}
	if ( Viewport.Actor.Level.LevelAction == LEVACT_None && !bForceLoadScreen)
	{
		BigMessage = "";
		return;
	} 
	else if(Viewport.Actor.Level.LevelAction == LEVACT_Loading || Viewport.Actor.bShowLoadingScreen || bForceLoadScreen)
	{
		// Omega: Reworked the function to draw a lot cleaner than before
		BigMessage = Localize("all","Options_0058","HPMenu");
		Viewport.Actor.bShowLoadingScreen = True;
		C.Style = 1;
		C.TextSize(BigMessage,fTextWidth,fTextHeight);
		if ( fTextWidth > C.SizeX - 32 )
		{
			C.Font = LocalMedFont;
		} 
		else 
		{
			C.Font = LocalBigFont;
		}
		
		C.SetPos(0, 0);
		
		// Metallicafan212:	Clear the screen to black by drawing a black tile across the entire screen
		//					It's not 100% black, so we need to use RGB(8, 8, 8)...
		C.DrawColor.R = 128;
		C.DrawColor.G = 128;
		C.DrawColor.B = 128;
		
		// Omega: Black tiled BG:
		C.SetPos(0,0);
		C.DrawTileClipped(BlackBG, C.SizeX, C.SizeY, 0.0, 0.0, C.SizeX * 2.5, C.SizeY * 2.5);

		// Omega: Test:
		C.SetPos(0,0);

		// Omega: Now the loading screen texture
		C.DrawColor = OldColor;
		
		// Metallicafan212:	Center the tiles
		Offset = (128.0 / HScale) - (128.0 * HScale);//256 - (256 * HScale);
		
		xOffset = 0;

		AlignXToCenter(C, xOffset);

		C.SetPos(xOffset, 0);
		C.DrawIcon(LoadingBackground, fScaleFactor);
		
		Offset *= Root.GUIScale * 0.7;

		// Omega: Text scaling backup
		local float OldTextScale;
		OldTextScale = C.FontScale;
		
		// Metallicafan212:	Customly draw the text offset
		C.bCenter = False;

		C.FontScale *= fScaleFactor;
		C.StrLen(BigMessage, XL, YL);
		
		xOffset = ((C.SizeX) / 4.0)/* + Offset*/;

		AlignXToCenter(C, xOffset);

		xOffset -= (XL / 2.0);

		C.SetPos(xOffset, FrameY / 4.5 - YL / 2.0);
		C.DrawText(BigMessage, False);
		
		C.FontScale = OldTextScale;
		C.Reset();

		// Omega: Ensure this is actually reset...
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
		C.DrawColor.A = 0;
		return;
	} 
	else if ( Viewport.Actor.Level.LevelAction == LEVACT_Saving && !bForceLoadScreen)
	{
		BigMessage = Localize("all","Options_0057","HPMenu");
	} 
	else if ( Viewport.Actor.Level.LevelAction == LEVACT_Connecting && !bForceLoadScreen)
	{
		BigMessage = ConnectingMessage;
	}
	else if ( Viewport.Actor.Level.LevelAction == LEVACT_Precaching && !bForceLoadScreen)
	{
		BigMessage = PrecachingMessage;
	}
	if ( BigMessage != "" && !bForceLoadScreen)
	{
		C.Style = 1;
		C.TextSize(BigMessage,fTextWidth,fTextHeight);
		if ( fTextWidth > C.SizeX - 32 )
		{
			C.Font = LocalMedFont;
		} 
		else 
		{
			C.Font = LocalBigFont;
		}
		PrintActionMessage(C,BigMessage);
	}
}

function AlignXToCenter(Canvas Canvas, out int nOutX)
{
	//nOutX = (Canvas.SizeX * 0.5) - (((Canvas.SizeX * 0.5) - nOutX) * GetHAdjustedScale(Canvas));
	nOutX = (Canvas.SizeX * 0.5) - (((Canvas.SizeX * 0.5) - nOutX) * GetHScale(Canvas));
}

defaultproperties
{
	//UTPT didn't decompile the texture paths correctly -AdamJD
	//
    //LoadingBackground=(p1=Texture'Icons.FELoadingBackground1',p2=Texture'Icons.FELoadingBackground2',p3=Texture'Icons.FELoadingBackground3',p4=Texture'Icons.FELoadingBackground4',p5=Texture'Icons.FELoadingBackground5',p6=Texture'Icons.FELoadingBackground6',durration=999999.00)
	//LoadingBackground=(p1=Texture'HGame.Icons.FELoadingBackground1',p2=Texture'HGame.Icons.FELoadingBackground2',p3=Texture'HGame.Icons.FELoadingBackground3',p4=Texture'HGame.Icons.FELoadingBackground4',p5=Texture'HGame.Icons.FELoadingBackground5',p6=Texture'HGame.Icons.FELoadingBackground6',durration=999999.00)
	
	LoadingBackground=Texture'HGame.LoadingScreen.FELoadingScreen'
	
	BlackBG=Texture'HGame.FEBook.FEMapBack'
	
	// Metallicafan212:	Load the white tex for doing the black background

    bUseSystemFonts=True
}