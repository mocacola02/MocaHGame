//================================================================================
// SpellSelector.
//================================================================================

class SpellSelector extends HudItemManager;

const nSPACE_BETWEEN_ICONS= 4;
const nTEXT_OFFSET_Y= 50;
const nTEXT_OFFSET_X= 20;
const nSTART_Y= 175;
const nSTART_X= 2;
const strEXPELLIARMUS_HOTKEY= "3";
const strMIMBLEWIMBLE_HOTKEY= "2";
const strRICTUSEMPRA_HOTKEY= "1";

var class<baseSpell> CurrSelection;


event PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.2,True);
}

event Destroyed()
{
	harry(Level.PlayerHarryActor).ClientMessage("spellselector destroyed");
	HPHud(harry(Level.PlayerHarryActor).myHUD).RegisterSpellSelector(None);
	Super.Destroyed();
}

event Timer()
{
	if ( Level.PlayerHarryActor.myHUD != None )
	{
		HPHud(harry(Level.PlayerHarryActor).myHUD).RegisterSpellSelector(self);
		SetTimer(0.0,False);
	}
}

function SetSelection (class<baseSpell> SSelection)
{
  	CurrSelection = SSelection;
}

function array<Texture> GetSpellIcons (class<baseSpell> SpellClass)
{
	local int i;
	local array<Texture> TextureResults;

	for (i = 0; i < PlayerHarry.DuelingSpellIcons.Length; i++)
	{
		if (PlayerHarry.DuelingSpellIcons[i].MatchingSpell = SpellClass)
		{
			TextureResults[0] = PlayerHarry.DuelingSpellIcons[i].DuelSpellIcon;
			TextureResults[1] = PlayerHarry.DuelingSpellIcons[i].DuelSpellSelectedIcon;

			break;
		}
	}

	return TextureResults;
}

function RenderHudItemManager (Canvas Canvas, bool bMenuMode, bool bFullCutMode, bool bHalfCutMode)
{
	local float fScaleFactor;
	local int nIconX;
	local int nIconY;
	local Texture textureSpellIcon;
	local array<Texture> TextureList;
	
	// Metallicafan212:	Scaling by height
	local float HScale;

	CheckHUDReferences();
	
	HScale = Class'M212HScale'.Static.CanvasGetHeightScale(Canvas);

	fScaleFactor = GetScaleFactor(Canvas);
	nIconX = nSTART_X * fScaleFactor;
	nIconY = nSTART_Y * fScaleFactor * HScale;

	// Omega: Align and scale
	AlignXToLeft(Canvas, nIconX);
	nIconX = ApplyHUDScale(Canvas, nIconX);

	for (i = 0; i < PlayerHarry.DuelSpellList.Length; i++)
	{
		TextureList = GetSpellIcons(PlayerHarry.DuelSpellList[i]);

		textureSpellIcon = TextureList[PlayerHarry.DuelSpellList[i] == CurrSelection];

		DrawSpellIcon(Canvas, fScaleFactor * HScale, textureSpellIcon, nIconX, nIconY, string(i + 1));
		
		nIconY += (textureSpellIcon.VSize + nSPACE_BETWEEN_ICONS) * fScaleFactor * HScale;
	}
}

function DrawSpellIcon (Canvas Canvas, float fScaleFactor, Texture textureSpellIcon, int nIconX, int nIconY, string strHotKey)
{
	Canvas.SetPos(nIconX,nIconY);
	Canvas.DrawIcon(textureSpellIcon,fScaleFactor);
	DrawHotKeyText(Canvas, nIconX, nIconY, strHotKey);
}

function DrawHotKeyText (Canvas Canvas, int nIconX, int nIconY, string strHotKey)
{
	local float fScaleFactor;
	local Font fontSave;
	local Color colorSave;
	local float fXTextLen;
	local float fYTextLen;
	local int nXOffset;
	local int nYOffset;
	
	local float HScale;
	
	HScale = Class'M212HScale'.Static.CanvasGetHeightScale(Canvas);

	fScaleFactor = GetScaleFactor(Canvas);
	colorSave = Canvas.DrawColor;
	fontSave = Canvas.Font;
	Canvas.DrawColor.R = 206;
	Canvas.DrawColor.G = 200;
	Canvas.DrawColor.B = 190;
	
	if ( Canvas.SizeX <= 512 )
	{
		Canvas.Font = baseConsole(Level.PlayerHarryActor.Player.Console).LocalTinyFont;
	} 
	else if ( Canvas.SizeX <= 640 )
    {
		Canvas.Font = baseConsole(Level.PlayerHarryActor.Player.Console).LocalSmallFont;
    } 
	else 
	{
		Canvas.Font = baseConsole(Level.PlayerHarryActor.Player.Console).LocalMedFont;
	}
	
	Canvas.TextSize(strHotKey,fXTextLen,fYTextLen);
	nXOffset = ((nTEXT_OFFSET_X * fScaleFactor) - fXTextLen / 2) * HScale; 
	nYOffset = ((nTEXT_OFFSET_Y * fScaleFactor) - fXTextLen / 2) * HScale;
	Canvas.SetPos(nIconX + nXOffset, nIconY + nYOffset);
	Canvas.DrawText(strHotKey, false);
	Canvas.DrawColor = colorSave;
	Canvas.Font = fontSave;
}

defaultproperties
{
    bHidden=True

	DrawType=DT_Sprite
}
