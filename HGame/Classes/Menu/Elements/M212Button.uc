// Omega: A new button type to more easily handle typical HGame-ish features
class M212Button based on HGameButton;

var color SIOffWhiteColor, SIShadowColor;
var string StatusText;
var vector vStatusTextOffset;
var Texture RolloverTexture;
var sound soundRO;

var bool bHightlightMode, bHighLighted;
var bool bDebugMode;

function MouseLeave()
{
	Super.MouseLeave();

	if ( soundRO != None )
	{
		GetPlayerOwner().StopSound(soundRO, SLOT_Interact, 0.0);
	}
}

function MouseEnter()
{
	Super.MouseEnter();

	if ( soundRO != None )
	{
		GetPlayerOwner().PlaySound(soundRO,SLOT_Interact,,,100000.0,,True,True);
	}
}

function HideWindow()
{
	Super.HideWindow();
	
	if ( soundRO != None )
	{
		GetPlayerOwner().StopSound(soundRO, SLOT_Interact, 0.0);
	}
}

// Omega: Except disabled texture
function SetAllTextures(Texture Tex, Optional Texture RO)
{
	UpTexture = Tex;
	DownTexture = Tex;
	OverTexture = Tex;
	RolloverTexture = RO;
}

// Omega: Do original button shit, and then hgame style stuff on top
function Paint(Canvas C, float X, float Y)
{
	local int nStyleSave;
	Super.Paint(C, X, Y);

	nStyleSave 		= C.Style;

	// Omega: Hightlight mode as well
	if((!bHightlightMode && MouseIsOver() && RolloverTexture != None) 
	|| (bHightlightMode && bHighLighted && RolloverTexture != None))
	{
		if(RolloverTexture != None)
		{
			C.Style 	= 3;
			if(bUseRegion) 
			{
				DrawStretchedTextureSegment( C, ImageX, ImageY, OverRegion.W*RegionScale, OverRegion.H*RegionScale, 
				OverRegion.X, OverRegion.Y, OverRegion.W, OverRegion.H, RolloverTexture );
			}
			else if(bStretched)
			{
				DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, RolloverTexture );
			} 
			else 
			{
				DrawClippedTexture( C, ImageX, ImageY, RolloverTexture);
			}

			C.Style = nStyleSave;
		}
	}

	if(StatusText != "")
	{
		//DrawCount(C, (float(C.SizeX) / WinWidth), WinLeft, WinTop, StatusText);
		DrawCount(C, (Root.RealWidth / Root.WinWidth), WinLeft, WinTop, StatusText);
	}
}

function DrawCount (Canvas Canvas, float fScaleFactor, int nButtonLeft, int nButtonTop, string strCount)
{
	local Font fontSave;
	local float fXTextLen;
	local float fYTextLen;
	local float X, Y;
	
	local float hScale;
	local float ClipX, ClipY, OrgX, OrgY;

	OrgX = Canvas.OrgX;
	OrgY = Canvas.OrgY;
	ClipX = Canvas.ClipX;
	ClipY = Canvas.ClipY;

	Canvas.SetOrigin(0, 0);
	Canvas.SetClip(Root.RealWidth, Root.RealHeight);
	
	// Metallicafan212:	Calc once
	hScale = Class'M212HScale'.Static.UWindowGetHeightScale(Root);

	fontSave = Canvas.Font;
	Canvas.Font = GetCountFont(Canvas);
	Canvas.DrawColor = SIOffWhiteColor;
	Canvas.TextSize(strCount,fXTextLen,fYTextLen);
	Canvas.SetPos((((nButtonLeft) + (vStatusTextOffset.X * HScale)) * fScaleFactor - fXTextLen / 2), ((nButtonTop) + (vStatusTextOffset.Y * HScale)) * (fScaleFactor) - fYTextLen / 2);
	Canvas.DrawShadowText(strCount, SIOffWhiteColor, SIShadowColor);

	if(bDebugMode)
	{
		X = (((nButtonLeft) + (vStatusTextOffset.X * HScale)) * fScaleFactor - fXTextLen / 2);
		Y = ((nButtonTop) + (vStatusTextOffset.Y * HScale)) * (fScaleFactor) - fYTextLen / 2;
		Log(Self$ " DrawCount: " $strCount$ ", Font" $Canvas.Font$ " X: " $X$ ", Y: " $Y);
	}

	Canvas.Font = fontSave;
	Canvas.SetClip(ClipX, ClipY);
	Canvas.SetOrigin(OrgX, OrgY);
}

function Font GetCountFont (Canvas Canvas)
{
	local Font fontRet;

	if ( Canvas.SizeX <= 512 )
	{
		fontRet = baseConsole(GetPlayerOwner().Player.Console).LocalSmallFont;
	} 
	else 
	{
		if ( Canvas.SizeX <= 640 )
		{
			fontRet = baseConsole(GetPlayerOwner().Player.Console).LocalMedFont;
		} 
		else 
		{
			fontRet = baseConsole(GetPlayerOwner().Player.Console).LocalBigFont;
		}
	}
	return fontRet;
}

defaultproperties
{
	// Colors
	SIOffWhiteColor=(R=206,G=200,B=190)
	SIShadowColor=(R=0,G=0,B=0)

	vStatusTextOffset=(X=50,Y=58,Z=0)
}