//================================================================================
// baseFEPage.
//================================================================================

class baseFEPage extends UWindowDialogClientWindow; 

struct CurrRolloverInfo
{
	var HGameButton Button;
	var Texture textureRO;
	var bool bROIsWet;
	var Sound soundRO;
};

var baseFEBook book;
var HGameButton BackPageButton;
var HGameLabelControl TitleButton;
var Texture textureReturnNorm;
var Texture textureReturnRO;
var CurrRolloverInfo CurrRollover;

// Metallicafan212:	Custom object for additional layering
var Class<M212CustBack> ExBackLayering;

var String PageName;

function string GetLocalFEString (string strId)
{
	return Localize("All",strId,"HPMenu");
}

function Paint (Canvas Canvas, float X, float Y)
{
}

// Metallicafan212:	Blank function to call on all children when the height changes
function RepositionChildControls()
{
}

// Omega: This sucks but in order to do this, we need a specific execution timing that basically involves directly copying this. Man
function UWindowDialogControl CreateAlignedControl(class<UWindowDialogControl> ControlClass, float X, float Y, float W, float H, optional UWindowWindow OwnerWindow, 
optional EAlignmentType Alignment, optional float ScreenPCT)
{
	local UWindowDialogControl C;

	C = UWindowDialogControl(CreateWindow(ControlClass, X, Y, W, H, OwnerWindow));
	C.Register(Self);
	C.Notify(C.DE_Created);
	C.AlignmentType = Alignment;
	C.ScreenPctToAlignTo = ScreenPCT;

	if(TabLast == None)
	{
		TabLast = C;
		C.TabNext = C;
		C.TabPrev = C;
	}
	else
	{
		C.TabNext = TabLast.TabNext;
		C.TabPrev = TabLast;
		TabLast.TabNext.TabPrev = C;
		TabLast.TabNext = C;

		TabLast = C;
	}

	//Log("Created Aligned Control: " $C$ " Aligned on: " $C.AlignmentType.EnumName(C.AlignmentType));
	return C;
}

// Metallicafan212:	Override version of the UWindow function, so we can auto scale on Y
function UWindowDialogControl CreateControl(class<UWindowDialogControl> ControlClass, float X, float Y, float W, float H, optional UWindowWindow OwnerWindow)
{
	local UWindowDialogControl C;
	
	// Metallicafan212:	These are in 4/3 units
	//					We need to scale it to our corrected units
	
	// Metallicafan212:	Scale
	//Y *= GetHeightScale();
	//W *= GetHeightScale();
	//H *= GetHeightScale();
	//X *= GetHeightScale();
	//X *= GetWidthScale();
	//Y *= GetHeightScale();
	//W *= GetHeightScale();
	//H *= GetHeightScale();

	C = UWindowDialogControl(CreateWindow(ControlClass, X, Y, W, H, OwnerWindow));
	C.Register(Self);
	C.Notify(C.DE_Created);

	if(TabLast == None)
	{
		TabLast = C;
		C.TabNext = C;
		C.TabPrev = C;
	}
	else
	{
		C.TabNext = TabLast.TabNext;
		C.TabPrev = TabLast;
		TabLast.TabNext.TabPrev = C;
		TabLast.TabNext = C;

		TabLast = C;
	}

	return C;
}

// Omega: Called when switching pages
function PreSwitchPage()
{
	local bool bBackPage;

	bBackPage = True;
	if ( (FEBook(book).prevPage == None) || (FEBook(book).curPage == FEBook(book).InGamePage) )
	{
		bBackPage = False;
	}
	harry(Root.Console.Viewport.Actor).ClientMessage("Preswitch Page " $ string(FEBook(book).prevPage) $ " " $ string(FEBook(book).curPage));
	SetBackPageToolTip(bBackPage);
	ClearRollover();
}

// Omega: Called at the end of opening a new page on CurPage
function PostSwitchPage()
{

}

function PreOpenBook()
{
}

// Omega: Alignment added
function CreateBackPageButton (optional int nX, optional int nY, optional EAlignmentType Alignment)
{
	// Omega: If blank, use this alignment
	if(Alignment == AT_None)
	{
		Alignment = AT_Right;
	}

	if ( nX == 0 )
	{
		nX = 582;
	}
	if ( nY == 0 )
	{
		nY = 422;
	}
	if ( textureReturnNorm == None )
	{
		textureReturnNorm = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuBackToGame",Class'Texture'));
		textureReturnRO = Texture(DynamicLoadObject("HP2_Menu.Icons.HP2MenuBackToGameWet",Class'WetTexture'));
	}
	//BackPageButton = HGameButton(CreateControl(Class'HGameButton', nX, nY,48.0,48.0));
	BackPageButton = HGameButton(CreateAlignedControl(Class'HGameButton', nX, nY,48.0,48.0,,Alignment));
	BackPageButton.UpTexture = textureReturnNorm;
	BackPageButton.DownTexture = textureReturnNorm;
	BackPageButton.OverTexture = textureReturnNorm;
	BackPageButton.ToolTipString = GetLocalFEString("Shared_Menu_0002");
	BackPageButton.DownSound = Sound'GUI_Esc_Click5';
	BackPageButton.Register(self);
}

// Metallicafan212:	Don't think this is used, so I'm not going to fix the jump shit
// This is used lol -AdamJD
function CreateTitleButton (string strTitle, optional int nXPos, optional int nYPos)
{
	local bool bCenter;
	
	if ( nXPos == 0 )
	{
		/*
		//align title to the centre of the page -AdamJD
		
		// Metallicafan212:	Correctly align to the center
		nXPos = (WinWidth / 2) - (200 * GetHeightScale());
		*/
		
		nXPos = 0;
		
		nYPos = 40;
		
		bCenter = true;
	}
	
	if(!bCenter)
		TitleButton = HGameLabelControl(CreateControl(Class'HGameLabelControl', nXPos, nYPos, 400.0, 30.0));
	else
	{
		TitleButton = HGameLabelControl(CreateControl(Class'HGameLabelControl', nXPos, nYPos, 640.0, 30.0));
	}
		
	TitleButton.SetFont(F_HPMenuLarge);
	TitleButton.TextColor.R = 215;
	TitleButton.TextColor.G = 0;
	TitleButton.TextColor.B = 215;
	TitleButton.Align = TA_Center;
	TitleButton.bShadowText = True;
	TitleButton.SetText(strTitle);
}

function SetBackPageToolTip (bool bBackPage)
{
	if ( BackPageButton != None )
	{
		if ( bBackPage )
		{
			BackPageButton.ToolTipString = GetLocalFEString("Shared_Menu_0002");
		} 
		else 
		{
			BackPageButton.ToolTipString = GetLocalFEString("Main_Menu_0010");
		}
	}
}

// Omega: Correct this:
function int GetStatusY()
{
	local float HScale;
	// Omega: Scale the GetStatusY function
	HScale = Class'M212HScale'.Static.UWindowGetHeightScale(Root);

	//return (WinHeight * HScale) - 26;
	return (WinHeight - 26) * HScale;
	//return WinHeight - 26;
}

function Notify (UWindowDialogControl C, byte E)
{
	if ( E == DE_MouseEnter )
	{
		if ( C == BackPageButton )
		{
			SetRollover(BackPageButton,textureReturnRO,Sound'GUI_Esc_Rollover4',True);
		}
	} 
	else if ( E == DE_MouseLeave )
	{
		if ( C == BackPageButton )
		{
			ClearRollover();
		}
	}
	Super.Notify(C,E);
}

function AfterPaint (Canvas Canvas, float X, float Y)
{
	local float fScaleFactor;
	local float fHalfROScale;
	local float fOffsetX;
	local float fOffsetY;
	local int nSaveStyle;
	
	local float HScale;
	
	// Metallicafan212:	Scale rollover
	HScale = Class'M212HScale'.Static.UWindowGetHeightScale(Root);

	if ( BackPageButton != None )
	{
		if ( CurrRollover.textureRO != None )
		{
			fScaleFactor 	= Canvas.SizeX / WinWidth;
			nSaveStyle 		= Canvas.Style;
			Canvas.Style 	= 3;
			Canvas.SetPos(CurrRollover.Button.WinLeft * fScaleFactor,CurrRollover.Button.WinTop * fScaleFactor);
			Canvas.DrawIcon(CurrRollover.textureRO, fScaleFactor * HScale);
			Canvas.Style = nSaveStyle;
		}
	}
	Super.AfterPaint(Canvas,X,Y);
}

function SetRollover (HGameButton Button, Texture textureRO, Sound soundRO, bool bROIsWet)
{
	CurrRollover.Button = Button;
	CurrRollover.textureRO = textureRO;
	CurrRollover.bROIsWet = bROIsWet;
	CurrRollover.soundRO = soundRO;
	if ( soundRO != None )
	{
		GetPlayerOwner().PlaySound(CurrRollover.soundRO,SLOT_Interact,,,100000.0,,True,True);
	}
}

function ClearRollover()
{
	CurrRollover.Button = None;
	CurrRollover.textureRO = None;
	if ( CurrRollover.soundRO != None )
	{
		GetPlayerOwner().StopSound(CurrRollover.soundRO, SLOT_Interact, 0.0);
		CurrRollover.soundRO = None;
	}
}

function HPMessageBox doHPMessageBox (string Msg, string textButton1, optional string textButton2, optional float TimeOut)
{
	local HPMessageBox W;

	local float HScale;
	
	// Metallicafan212:	Cache it
	HScale = Class'M212HScale'.Static.UWindowGetHeightScale(Root);

	// Omega: Scale the X reduction by the HScale:
	W = HPMessageBox(Root.CreateWindow(Class'HPMessageBox',(640.0 - (246) * HScale) / 2,(480.0 - 102) / 2,246.0,150.0,self));
	W.Setup(Msg,textButton1,textButton2,TimeOut);
	Root.ShowModal(W);
	return W;
}

function WindowEvent (WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	if ( (Msg == WM_Paint) ||  !Root.WaitModal() )
	{
		Super.WindowEvent(Msg,C,X,Y,Key);
	}
}

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta)//(byte Key, byte Action, float Delta)
{
	return False;
}

// Omega: If we're handling the escape manually, return true. Default FEBook handles it
function bool HandleEscFromPage()
{
	return false;
}

function bool CanChangePageFromHotkey()
{
	return false;
}

// Omega: Subscribe to the bug
function bool CanEffFour()
{
	return true;
}

function bool ShouldPlayMusic()
{
	return true;
}

defaultproperties
{
	//PageName=""
}