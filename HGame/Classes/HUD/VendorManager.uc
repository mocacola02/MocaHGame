//==========================================================================//
// VendorManager.
//
// HUD item class for managing and displaying vendor item info.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class VendorManager extends HudItemManager;

//= Texture Constants =//
const strVENDORBAR_LEFT= "HP2_Menu.Icons.HP2VendorBarLeft";
const strVENDORBAR_RIGHT= "HP2_Menu.Icons.HP2VendorBarRight";
const strVENDORBAR_BUTTON_NORMAL= "HP2_Menu.Icons.HP2ConfirmYes";
const strVENDORBAR_BUTTON_OVER= "HP2_Menu.Icons.HP2ConfirmYes_Highlight";
const strVENDORITEM_NIMBUS= "HP2_Menu.Icons.HP2Nimbus2001";
const strVENDORITEM_QARMOR= "HP2_Menu.Icons.HP2QuidditchArmor";
const strVENDORITEM_FMUCUS= "HP2_Menu.Icons.HP2VendorFMucus";
const strVENDORITEM_WBARK= "HP2_Menu.Icons.HP2VendorWBark";
const strVENDORITEM_SILVERCARD= "HP2_Menu.Icons.HP2VendorSilverCard";
const strVENDORITEM_BRONZECARD= "HP2_Menu.Icons.HP2VendorBronzeCard";
const strVENDORITEM_WIZDUEL= "HP2_Menu.Icons.HP2VendorWizDuel";

//= String ID Constants =//
const strID_YES= "Shared_Menu_0003";
const strID_NO= "Shared_Menu_0004";

//= HUD Sizing Constants =//
const fVENDORBAR_W= 366.0;
const fVENDORBAR_Y= 20.0;
const fVENDORBAR_PRICE_X= 76.0;
const fVENDORBAR_PRICE_Y= 74.0;
const fVENDORBAR_BUTTON_W= 92.0;
const fVENDORBAR_BUTTON_H= 25.0;
const fVENDORBAR_YESBUTTON_X= 246.0;
const fVENDORBAR_YESBUTTON_Y= 20.0;
const fVENDORBAR_NOBUTTON_X= 246.0;
const fVENDORBAR_NOBUTTON_Y= 54.0;
const fVENDORBAR_PURCHASE_ITEM_X= 155.0;
const fVENDORBAR_PURCHASE_ITEM_Y= 14.0;
const fVENDORBAR_BUTTON_TEXT_X= 46.0;
const fVENDORBAR_BUTTON_TEXT_Y= 12.0;

//= Cutscene Constants =//
const strQUESTION_ANIM_PARAM= " startanim=talk_question";
const strBOTHHANDS_ANIM_PARAM= " startanim=talk_bothhands";
const strLEFTHAND_ANIM_PARAM= " startanim=talk_lhand";
const strRIGHTHAND_ANIM_PARAM= " startanim=talk_rhand";
const strVENDOR_WAIT_ANIM_PARAM= " loopanim=vendor_idle2";
const strINDEFINITE_TEXT_PARAM= " IndefiniteText";
const strTALK_COMMAND= "TALK ";
const strSAY_COMMAND= "SAY ";
const strFACE_HARRY_COMMAND= "TURNTO harry";
const strCAPTURE_COMMAND= "CAPTURE";
const strRELEASE_COMMAND= "RELEASE";
const strFLYTO_COMMAND= "FLYTO ";
const strTARGET_FLYTO_COMMAND= "TARGET FLYTO ";
const strCUE_VENDOR_TURN_DONE= "_VendorTurnDone";
const strCUE_CAMERA_IN_POSITION= "_CameraInPosition";
const strCUE_ITEM_SOLD= "_ItemSold";
const strCUE_HARRY_INQUIRY= "_HarryInquiry";
const strCUE_IHAVE_X= "_IHaveX";
const strCUE_INSTRUCTIONS= "_Instructions";
const strCUE_TRANSACTION_DONE= "_TransactionDone";
const strCUE_DECLINE_SALE= "_DeclineSale";
const strCUE_NOT_ENOUGH_BEANS= "_NotEnoughBeans";
const strCUE_RAN_OUT_OF_BEANS= "_RanOutOfBeans";
const strCUE_OUT_OF_STOCK= "_OutOfStock";
const strTEMP_VENDOR_CUT_NAME= "TempVendorCutName";

//= Texture References =//
var Texture textureVendorBarLeft;
var Texture textureVendorBarRight;
var Texture textureVendorButtonNormal;
var Texture textureVendorButtonOver;
var Texture textureItemToSell;

//= Actor References
var Characters Vendor;

// Metallicafan212: Prevent a stutter by caching the Weasley twin (to be compatible with the new engine)
var Characters WeasTwin;
var Characters WeasleyTwin;

var StatusManager managerStatus;

var name nameVendorSavedState;
var string strVendorSavedCutName;
var int nLastButtonYes;
var int nLastButtonNo;
var int nItemsBoughtInCurrTransaction;
var int nCurrPrice;

// Metallicafan212:	2025, HOLY SHIT guys, what is wrong with you?
//					This was ANOTHER transient save issue. Canvas is not suppost to be set to actor properties, let alone persistent actors!
var Transient Canvas VendorCanvas;	// Canvas to render to

//= General Variables =//
var int I;					// Loop increment value
var int nSubtractBeans;		// How many beans to subtract from player's bean count
var float fTicksPerSec;		// Number of ticks per second
var float fTickDelta;		// Tick delta time
var float HScale;	// UI height scale
var int nMinusBeansPerTick;	// How many beans to remove per tick after buying something
var string strYes;			// Yes text string
var string strNo;			// No text string



//=========
// Events
//=========

event PlayerInput (float DeltaTime);

// Sets the Vendor reference
function SetVendor (Characters V)
{
	// Set vendor reference to given character
	Vendor 		= V;

	// Metallicafan212:	Added to prevent against stutter with Fred and George (to be compatible with the new engine)
	WeasTwin 	= Vendor.GetWeasleyTwin();
}

// Handles vendor engagement
function DoEngageVendor (name nameSaveState)
{
	local StatusGroup sgJellyBeans;
	local string strItemTexture;

	// Set saved state as the given state
	nameVendorSavedState = nameSaveState;

	// If the vendor has a blank cutname, set the saved cutname as the vendor's cutname
	if ( Vendor.CutName == "" )
	{
		strVendorSavedCutName = Vendor.CutName;
	}

	// Set cutname to the temporary cutname
	Vendor.CutName = strTEMP_VENDOR_CUT_NAME;

	// If no left bar texture is defined
	if ( textureVendorBarLeft == None )
	{
		// Load default constant texture for each bar portion
		textureVendorBarLeft 		= Texture(DynamicLoadObject(strVENDORBAR_LEFT,Class'Texture'));
		textureVendorBarRight 		= Texture(DynamicLoadObject(strVENDORBAR_RIGHT,Class'Texture'));
		textureVendorButtonNormal 	= Texture(DynamicLoadObject(strVENDORBAR_BUTTON_NORMAL,Class'Texture'));
		textureVendorButtonOver 	= Texture(DynamicLoadObject(strVENDORBAR_BUTTON_OVER,Class'Texture'));

		// Set the proper item texture based on what the vendor is selling
		switch (Vendor.CharacterSells)
		{
			case Vendor.ESells.Sells_Nimbus2001:
				strItemTexture = strVENDORITEM_NIMBUS;
				break;
			case Vendor.ESells.Sells_QArmor:
				strItemTexture = strVENDORITEM_QARMOR;
				break;
			case Vendor.ESells.Sells_WBark:
				strItemTexture = strVENDORITEM_WBARK;
				break;
			case Vendor.ESells.Sells_FMucus:
				strItemTexture = strVENDORITEM_FMUCUS;
				break;
			case Vendor.ESells.Sells_BronzeCards:
				strItemTexture = strVENDORITEM_BRONZECARD;
				break;
			case Vendor.ESells.Sells_SilverCards:
				strItemTexture = strVENDORITEM_SILVERCARD;
				break;
			case Vendor.ESells.Sells_Duel:
				strItemTexture = strVENDORITEM_WIZDUEL;
				break;
			default:
				break;
		}

		// Load the determined item texture
		textureItemToSell = Texture(DynamicLoadObject(strItemTexture,Class'Texture'));
	}

	// Localize the Yes and No strings
	strYes = Localize("All",strID_YES,"HPMenu");
	strNo = Localize("All",strID_NO,"HPMenu");
	
	// Register self as the vendor manager in the HUD
	HPHud(harry(Level.PlayerHarryActor).myHUD).RegisterVendorManager(self);
	
	// Tell Harry to start vendor engagement
	harry(Level.PlayerHarryActor).StartVendorEngagement(self);
	
	// Get the jellybeans StatusGroup
	sgJellyBeans = harry(Level.PlayerHarryActor).managerStatus.GetStatusGroup(Class'StatusGroupJellybeans');

	// Set the bean counter effect type to permanent so it doesn't go away
	sgJellyBeans.SetEffectTypeToPermanent();

	// Set the StatusGroup to cutscene render mode
	sgJellyBeans.SetCutSceneRenderMode(True);
	
	// Set the cut notify actor references to self
	Level.PlayerHarryActor.CutNotifyActor = self;
	harry(Level.PlayerHarryActor).Cam.CutNotifyActor = self;
	Vendor.CutNotifyActor = self;
	
	// Run the capture command on each relevant actor
	Level.PlayerHarryActor.CutCommand(strCAPTURE_COMMAND);
	harry(Level.PlayerHarryActor).Cam.CutCommand(strCAPTURE_COMMAND);
	Vendor.CutCommand(strCAPTURE_COMMAND);
	
	// Reset items bought in current transaction to 0
	nItemsBoughtInCurrTransaction = 0;

	// Get the selling price from the vendor
	nCurrPrice = Vendor.GetSellingPrice();

	// Go to EngageVendor state
	GotoState('EngageVendor');
}

// Randomly returns one of three constant animation names
function string GetAnimParam()
{
	switch (Rand(3))
	{
		case 0:
			return strRIGHTHAND_ANIM_PARAM;
		case 1:
			return strLEFTHAND_ANIM_PARAM;
		case 2:
			return strBOTHHANDS_ANIM_PARAM;
		default:
	}
}

// Set vendor bar flags in the console to the given value, used to toggle vendor HUD
function SetConsoleVendorBarFlags (bool bSet)
{
	HPConsole(Level.PlayerHarryActor.Player.Console).bVendorBar = bSet;
	HPConsole(Level.PlayerHarryActor.Player.Console).bUWindowActive = bSet;
	HPConsole(Level.PlayerHarryActor.Player.Console).Viewport.bShowWindowsMouse = bSet;
}

// Handles cutscene talking
function DoCutTalk (Actor actorTalk, string strDialogID, string strTalkAnimName, string strLoopAnimName, string strIndefiniteParam, string strCue)
{
	local string strDialog;
	local TimedCue tcue;
	local float fSoundLen;

	// If dialog ID is blank, call the cut cue
	if ( strDialogID == "" )
	{
		CutCue(strCue);
	}
	// Otherwise
	else 
    {
		// If vendor is not a duelling vendor, run the talk cut command
		if ( !Vendor.IsDuelVendor() )
		{
			actorTalk.CutCommand(strTALK_COMMAND $strDialogID $strTalkAnimName $strLoopAnimName $strIndefiniteParam,strCue);
		}
		// Otherwise
		else 
		{
			// Localize dialog string
			strDialog = (Localize("All",strDialogID,"HPMenu"));

			// Calculate dialog sound length
			fSoundLen = (Len(strDialog) * 0.01) + 3.0;

			// If indefinite param string is blank
			if ( strIndefiniteParam == "" )
			{
				// Spawn a timed cue
				tcue = Spawn(Class'TimedCue');

				// Set cut notify actor to self
				tcue.CutNotifyActor = self;

				// Setup timed cue timer for fSoundLen plus 0.5 seconds, calling the cut cue when done
				tcue.SetupTimer(fSoundLen + 0.5,strCue);

				// Print "Indefinite"
				harry(Level.PlayerHarryActor).ClientMessage("Indefinite");

				// Set the subtitle text to the localized dialog for sound length
				harry(Level.PlayerHarryActor).myHUD.SetSubtitleText(strDialog,fSoundLen);
			}
			// Otherwise
			else 
			{
				// Set subtitle text to the localize dialog for 0.0 seconds
				harry(Level.PlayerHarryActor).myHUD.SetSubtitleText(strDialog,0.0);

				// Call the cut cue
				CutCue(strCue);
			}
		}
	}
}

// Plays the narrator instructions
function DoNarratorInstructions()
{
	// If vendor instruction ID is blank, call cut cue
	if ( Vendor.GetVendorInstructionId() == "" )
	{
		CutCue(strCUE_INSTRUCTIONS);
	}
	// Otherwise
	else 
    {
		// If vendor is a dueling vendor, do cutscene talk
		if ( Vendor.IsDuelVendor() )
		{
			DoCutTalk(Level.PlayerHarryActor,Vendor.GetVendorInstructionId(),"","",strINDEFINITE_TEXT_PARAM,strCUE_INSTRUCTIONS);
		}
		// Otherwise, do say cut command
		else 
		{
			CutCommand(strSAY_COMMAND $Vendor.GetVendorInstructionId() $strINDEFINITE_TEXT_PARAM,strCUE_INSTRUCTIONS);
		}
	}
}

// Returns whether or not instructions need to be read out
function bool WantInstructions()
{
	return !harry(Level.PlayerHarryActor).bSaidVendorInstructions || Vendor.IsDuelVendor();
}

// Automatic state idle, does nothing on its own
auto state Idle
{
}

// Engage vendor state
state EngageVendor
{	
	// Handle cut cue
	function CutCue (string cue)
	{
		local string strStayUpText;
		local float fSoundLenDummy;
  
		// If cue is vendor turn done
		if ( cue ~= strCUE_VENDOR_TURN_DONE )
		{
			// Move camera to vendor with offset
			harry(Level.PlayerHarryActor).Cam.CutCommand(strFLYTO_COMMAND $Vendor.CutName $" x=80 y=80");

			// Turn camera to vendor with offset
			harry(Level.PlayerHarryActor).Cam.CutCommand(strTARGET_FLYTO_COMMAND $Vendor.CutName $" x=10 z=10",strCUE_CAMERA_IN_POSITION);
			
			WeasleyTwin = WeasTwin; // Metallicafan212: To be compatible with the new engine

			// If we have a Weasley twin, put them in stateIdle
			if ( WeasleyTwin != None )
			{
				WeasleyTwin.GotoState('stateIdle');
			}
		}
		// Otherwise, if cue is camera in position, do inquiry cut talk
		else if ( cue ~= strCUE_CAMERA_IN_POSITION )
		{
			DoCutTalk(Level.PlayerHarryActor,Vendor.GetVendorHarryInquiryId(),strQUESTION_ANIM_PARAM,"","",strCUE_HARRY_INQUIRY);
		}
		// Otherwise, if cue is Harry inquiry
		else if ( cue ~= strCUE_HARRY_INQUIRY )
		{
			// If vendor has something to sell
			if ( Vendor.HaveSomethingToSell() )
			{
				// If we want instructions, do cut talk without indefinite text
				if ( WantInstructions() )
				{
					DoCutTalk(Vendor,Vendor.GetSellDialogId(),GetAnimParam(),strVENDOR_WAIT_ANIM_PARAM,"",strCUE_IHAVE_X);
				}
				// Otherwise, do cut talk with indefinite text
				else 
				{
					DoCutTalk(Vendor,Vendor.GetSellDialogId(),GetAnimParam(),strVENDOR_WAIT_ANIM_PARAM,strINDEFINITE_TEXT_PARAM,strCUE_IHAVE_X);
				}
			}
			// Otherwise, do out of stock cut talk
			else
			{
				DoCutTalk(Vendor,Vendor.GetVendorOutOfStockId(),GetAnimParam(),"","",strCUE_OUT_OF_STOCK);
			}
        }
		// Otherwise, if cue is out of stock, disengage vendor
		else if ( cue ~= strCUE_OUT_OF_STOCK )
		{
			DoDisengageVendor();
		}
		// Otherwise, if cue is I have X (item)
		else if ( cue ~= strCUE_IHAVE_X )
		{
			// If we want instructions, do instructions and set that we have done them
			if ( WantInstructions() )
			{
				DoNarratorInstructions();
                harry(Level.PlayerHarryActor).bSaidVendorInstructions = True;
			}
			// Otherwise, go to the VendorTransaction state
			else 
			{
				GotoState('VendorTransaction');
			}
		}
		// Otherwise, if cue is instructions, go to the VendorTransaction state
		else if ( cue ~= strCUE_INSTRUCTIONS )
		{
			GotoState('VendorTransaction');
		}
	}
  
	// Begin label
	begin:
		// Stop all horizontal movement on Harry
		Level.PlayerHarryActor.Acceleration = vect(0.00,0.00,0.00);
		Level.PlayerHarryActor.Velocity *= vect(0.00,0.00,1.00);

		// Turn Harry towards vendor
		harry(Level.PlayerHarryActor).TurnTo(Level.PlayerHarryActor.Location + (Vendor.Location - Level.PlayerHarryActor.Location) * vect(1.00,1.00,0.00));
		
		// Turn vendor towards Harry
		Vendor.CutCommand(strFACE_HARRY_COMMAND,strCUE_VENDOR_TURN_DONE);

		// Get cached Weasley twin
		WeasleyTwin = WeasTwin;

		// If we have a Weasley twin, set them to stateIdle and make them face Harry
		if ( WeasleyTwin != None )
		{
			WeasleyTwin.GotoState('stateIdle');
			WeasleyTwin.CutCommand(strFACE_HARRY_COMMAND);
		}
}

// Vendor Transaction state
state VendorTransaction
{
	// Render HUD elements
	function RenderHud (Canvas canvas, bool bMenuMode, bool bFullCutMode, bool bHalfCutMode)
	{
		local StatusGroup sgJellyBeans;

		// Get jellybeans StatusGroup
		sgJellyBeans = harry(Level.PlayerHarryActor).managerStatus.GetStatusGroup(Class'StatusGroupJellybeans');

		// Render jellybean counter
		sgJellyBeans.RenderHudItemManager(canvas,bMenuMode,bFullCutMode,bHalfCutMode);

		// Draw vendor bar
		DrawVendorBar(canvas);
	}

	// Handle cut cue
	function CutCue (string cue)
	{
		// If cue is transaction done, decline sale, or out of stock, disengage vendor
		if ( cue ~= strCUE_TRANSACTION_DONE || cue ~= strCUE_DECLINE_SALE || cue ~= strCUE_OUT_OF_STOCK )
		{
			DoDisengageVendor();
		}
	}

	// On player input
	event PlayerInput (float fDeltaTime)
	{
		// If not showing mouse cursor, do nothing and return
		if ( !HPConsole(Level.PlayerHarryActor.Player.Console).Viewport.bShowWindowsMouse )
		{
			return;
		}

		// If pressing bVendorReply and mouse is over yes
		if ( (harry(Level.PlayerHarryActor).bVendorReply == 1) && IsMouseOverVendorYes() )
		{
			// Play GUI sound
			Level.PlayerHarryActor.PlaySound(Sound'ss_gui_rotatebut_0003');

			// Set console bar flags to false
			SetConsoleVendorBarFlags(False);

			// If vendor has nothing to sell, do out of stock cut talk
			if ( !Vendor.HaveSomethingToSell() )
			{
				DoCutTalk(Vendor,Vendor.GetVendorOutOfStockId(),GetAnimParam(),"","",strCUE_OUT_OF_STOCK);
			}
			// Otherwise, if Harry doesn't have enough beans, go to NotEnoughBeans state
			else if ( !HarryHasEnoughBeans(nCurrPrice) )
			{
				GotoState('NotEnoughBeans');
			}
			// Otherwise, increase number of items bought in current transaction and go to MakePurchase state
			else 
			{
				nItemsBoughtInCurrTransaction++;
				GotoState('MakePurchase');
			}
		}
		// Otherwise, if pressing bVendorReply and mouse is over no
		else if ( (harry(Level.PlayerHarryActor).bVendorReply == 1) && IsMouseOverVendorNo() )
		{
			// Play GUI sound
			Level.PlayerHarryActor.PlaySound(Sound'ss_gui_rotatebut_0002');

			// Set console bar flags to false
			SetConsoleVendorBarFlags(False);

			// If Harry bought any items, do transaction done cut talk
			if ( nItemsBoughtInCurrTransaction > 0 )
			{
				DoCutTalk(Vendor,Vendor.GetVendorTransactionDoneId(),GetAnimParam(),"","",strCUE_TRANSACTION_DONE);
			}
			// Otherwise, do decline cut talk
			else 
			{
				DoCutTalk(Vendor,Vendor.GetVendorDeclineId(),GetAnimParam(),"","",strCUE_DECLINE_SALE);
			}
		}
	}

	// On state begin, set console flags to true
	event BeginState()
	{
		SetConsoleVendorBarFlags(True);
	}

	// On state end, set console flags to false
	event EndState()
	{
		SetConsoleVendorBarFlags(False);
	}

	// Begin label
	begin:
		// Loop idle animation on vendor
		Vendor.LoopAnim('vendor_idle2',RandRange(0.80,1.20),0.2);
}

// Make Purchase state
state MakePurchase
{
	// On tick
	event Tick (float DeltaTime)
	{
		// If saved delta time is above 0
		if ( fTickDelta > 0.0 )
		{
			// If bean subtract count is above 0
			if ( nSubtractBeans > 0 )
			{
				// If bean subtract count is above or equal to the amount to remove per tick
				if ( nSubtractBeans >= nMinusBeansPerTick )
				{
					// Remove beans from StatusGroup using the negated value of nMinusBeansPerTick
					managerStatus.IncrementCount(Class'StatusGroupJellybeans',Class'StatusItemJellybeans', -nMinusBeansPerTick);

					// Subtract the amount we removed from the total subtraction amount
					nSubtractBeans -= nMinusBeansPerTick;
				}
				// Otherwise
				else 
				{
					// Remove beans from StatusGroup using the negated value of nSubtractBeans
					managerStatus.IncrementCount(Class'StatusGroupJellybeans',Class'StatusItemJellybeans', -nSubtractBeans);

					// Set bean subtract count to 0
					nSubtractBeans = 0;
				}
			}
		}
		// Otherwise, store the current delta time
		else 
		{
			fTickDelta = DeltaTime;
		}
	}

	// Render HUD elements
	function RenderHud (Canvas canvas, bool bMenuMode, bool bFullCutMode, bool bHalfCutMode)
	{
		local StatusGroup sgJellyBeans;
		
		// Get jellybeans StatusGroup
		sgJellyBeans = harry(Level.PlayerHarryActor).managerStatus.GetStatusGroup(Class'StatusGroupJellybeans');

		// Render jellybean counter
		sgJellyBeans.RenderHudItemManager(canvas,bMenuMode,bFullCutMode,bHalfCutMode);
	}

	// Handle cut cue
	function CutCue (string cue)
	{
		// If cue is item sold
		if ( cue ~= strCUE_ITEM_SOLD )
		{
			// If vendor is dueling vendor, set rank to 0
			if ( Vendor.IsDuelVendor() )
			{
				Vendor.DuelRank = 0;
			}

			// If vendor has nothing to sell, do transaction done cut talk
			if (  !Vendor.HaveSomethingToSell() )
			{
				DoCutTalk(Vendor,Vendor.GetVendorTransactionDoneId(),GetAnimParam(),"","",strCUE_TRANSACTION_DONE);
			}
			// Otherwise, go to VendorTransaction state
			else 
			{
				GotoState('VendorTransaction');
			}
		}
		// Otherwise, if cue is transaction done, do out of stock cut talk
		else if ( cue ~= strCUE_TRANSACTION_DONE )
		{
			DoCutTalk(Vendor,Vendor.GetVendorOutOfStockId(),GetAnimParam(),"","",strCUE_OUT_OF_STOCK);
		}
		// Otherwise, if cue is out of stock, disengage
		else if ( cue ~= strCUE_OUT_OF_STOCK )
        {
			DoDisengageVendor();
        }
	}

	// On state begin, get StatusManager from Harry
	event BeginState()
	{
		managerStatus = harry(Level.PlayerHarryActor).managerStatus;
	}

	// Begin label
	begin:
		// While stored delta time is less than or equal to 0.0, sleep for 0.1 seconds
		while (fTickDelta <= 0.0 )
		{
			Sleep(0.1);
		}
	
		// Set subtract bean count to current price
		nSubtractBeans = nCurrPrice;

		// Calculate the ticks per second
		fTicksPerSec = 1.0 / fTickDelta;
		
		// Calculate the amount of beans to remove per tick
		nMinusBeansPerTick = nCurrPrice / (1.5 * fTicksPerSec);
	
		// If calculate remove rate is less than 1.0, set it to 1.0
		if ( nMinusBeansPerTick < 1 )
		{
			nMinusBeansPerTick = 1;
		}
	
		// While we still have beans to remove, sleep for 0.1 seconds
		while ( nSubtractBeans > 0 )
		{
			Sleep(0.1);
		}

		// If vendor is a dueling vendor
		if ( Vendor.IsDuelVendor() )
		{
			// If duel level trigger is not none
			if ( Vendor.DuelLevelTrigger != None )
			{
				// Set Harry's rank opponent and beans to the vendor's rank and beans
				harry(Level.PlayerHarryActor).DuelRankOppon = Vendor.DuelRank;
				harry(Level.PlayerHarryActor).DuelRankBeans = Vendor.DuelBeans;

				// Process level trigger
				Vendor.DuelLevelTrigger.ProcessTrigger();
			}
		}

		// Execute sell vendor item cut command on vendor
		Vendor.CutCommand("SellVendorItem" $GetAnimParam(),strCUE_ITEM_SOLD);
}

// Not Enough Beans state
state NotEnoughBeans
{
	// Render HUD elements
	function RenderHud (Canvas canvas, bool bMenuMode, bool bFullCutMode, bool bHalfCutMode)
	{
		local StatusGroup sgJellyBeans;
  
		sgJellyBeans = harry(Level.PlayerHarryActor).managerStatus.GetStatusGroup(Class'StatusGroupJellybeans');
		sgJellyBeans.RenderHudItemManager(canvas,bMenuMode,bFullCutMode,bHalfCutMode);
	}
  
	function CutCue (string cue)
	{
		if ( cue ~= strCUE_RAN_OUT_OF_BEANS || cue ~= strCUE_NOT_ENOUGH_BEANS )
		{
			DoDisengageVendor();
		}
	}
  
	begin:
		if ( nItemsBoughtInCurrTransaction == 0 )
		{
			DoCutTalk(Vendor,Vendor.GetVendorNotEnoughBeansId(),GetAnimParam(),"","",strCUE_NOT_ENOUGH_BEANS);
		} 
		else 
		{
			DoCutTalk(Vendor,Vendor.GetVendorRanOutOfBeansId(),GetAnimParam(),"","",strCUE_RAN_OUT_OF_BEANS);
		}
}

function DoDisengageVendor()
{
	local StatusGroup sgJellyBeans;
	//local Characters WeasleyTwin;
	local Characters WeasleyTwinFredOrGeorge;

	harry(Level.PlayerHarryActor).Cam.CutCommand(strRELEASE_COMMAND);
	harry(Level.PlayerHarryActor).Cam.CutNotifyActor = None;
	Level.PlayerHarryActor.CutCommand(strRELEASE_COMMAND);
	Level.PlayerHarryActor.CutNotifyActor = None;
	Vendor.CutCommand(strRELEASE_COMMAND);
	Vendor.CutNotifyActor = None;
	harry(Level.PlayerHarryActor).EndVendorEngagement();
	sgJellyBeans = harry(Level.PlayerHarryActor).managerStatus.GetStatusGroup(Class'StatusGroupJellybeans');
	sgJellyBeans.SetEffectTypeToNormal();
	sgJellyBeans.SetCutSceneRenderMode(True);
	Vendor.DesiredRotation = Vendor.rSave;
	Vendor.GotoState('VendorIdle');
	Vendor.CutName = strVendorSavedCutName;
	//Vendor.GetWeasleyTwin();
	// Metallicafan212: Cached previously
	WeasleyTwinFredOrGeorge = WeasTwin;
	if ( WeasleyTwinFredOrGeorge != None )
	{
		WeasleyTwinFredOrGeorge.DesiredRotation = WeasleyTwinFredOrGeorge.rSave;
		WeasleyTwinFredOrGeorge.GotoState('VendorIdle');
	}
	GotoState('Idle');
}

function bool HarryHasEnoughBeans (int nPrice)
{
	local StatusItem siBeans;

	siBeans = harry(Level.PlayerHarryActor).managerStatus.GetStatusItem(Class'StatusGroupJellybeans',Class'StatusItemJellybeans');
	return (siBeans.nCount >= nPrice);
}

function RenderHud (Canvas canvas, bool bMenuMode, bool bFullCutMode, bool bHalfCutMode)
{
}

function DrawVendorBar (Canvas canvas)
{
	local Texture textureYesButton;
	local Texture textureNoButton;
	local float fBarX;
	local float fBarY;
	local string strCurrPrice;
	local Color colorSave;
	local Font fontSave;
	local float fXTextLen;
	local float fYTextLen;
	local float fScaleFactor;
	local StatusItem siJellybeans;
	local Color colorText;
	local Color colorTextShadow;
	
	local float Offset;
	
	HScale = Class'M212HScale'.Static.CanvasGetHeightScale(Canvas);
	
	// Metallicafan212:	This needs to be offset to be in the center again
	//Offset = (256 - (256 * HScale)) * 2.0;

	VendorCanvas = Canvas;
	fontSave = Canvas.Font;
	fScaleFactor = Canvas.GetHudScaleFactor();
	if ( IsMouseOverVendorYes() )
	{
		textureYesButton = textureVendorButtonOver;
		textureNoButton = textureVendorButtonNormal;
	} 
	else if ( IsMouseOverVendorNo() )
    {
		textureYesButton = textureVendorButtonNormal;
		textureNoButton = textureVendorButtonOver;
    } 
	else 
	{
		textureYesButton = textureVendorButtonNormal;
		textureNoButton = textureVendorButtonNormal;
    }
	
	fBarX = GetVendorBarX(Canvas); //+ Offset;
	fBarY = GetVendorBarY(Canvas) * HScale;
	
	// Metallicafan212:	Left side
	canvas.SetPos(fBarX, fBarY);	
	canvas.DrawIcon(textureVendorBarLeft, fScaleFactor * HScale);
	
	// Metallicafan212: Right side, but we need to shift over
	canvas.SetPos(fBarX + (256 * fScaleFactor * HScale), fBarY);
	canvas.DrawIcon(textureVendorBarRight, fScaleFactor * HScale); 
	
	// Metallicafan212:	What they're selling
	canvas.SetPos(fBarX + (fVENDORBAR_PURCHASE_ITEM_X * fScaleFactor * HScale), fBarY + (fVENDORBAR_PURCHASE_ITEM_Y * fScaleFactor * HScale));
	canvas.DrawIcon(textureItemToSell, fScaleFactor * HScale);
	
	// Metallicafan212:	Yes button
	canvas.SetPos(fBarX + (fVENDORBAR_YESBUTTON_X * fScaleFactor * HScale), fBarY + (fVENDORBAR_YESBUTTON_Y * fScaleFactor * HScale));
	canvas.DrawIcon(textureYesButton, fScaleFactor * HScale); 
	
	// Metallicafan212:	No button
	canvas.SetPos(fBarX + (fVENDORBAR_NOBUTTON_X * fScaleFactor * HScale), fBarY + (fVENDORBAR_NOBUTTON_Y * fScaleFactor * HScale));
	canvas.DrawIcon(textureNoButton, fScaleFactor * HScale);
	
	// Metallicafan212:	Bean count
	siJellybeans 	= harry(Level.PlayerHarryActor).managerStatus.GetStatusItem(Class'StatusGroupStars',Class'StatusItemStars');
	Canvas.Font 	= siJellybeans.GetCountFont(Canvas);
	colorText 		= siJellybeans.GetCountColor();
	colorTextShadow = siJellybeans.GetCountColor(True);
	
	// Metallicafan212:	Yes line
	Canvas.TextSize(strYes, fXTextLen, fYTextLen);
	Canvas.SetPos(fBarX + (fVENDORBAR_YESBUTTON_X * fScaleFactor * HScale) + (fVENDORBAR_BUTTON_TEXT_X * fScaleFactor * HScale) - (fXTextLen / 2), fBarY + (fVENDORBAR_YESBUTTON_Y * fScaleFactor * HScale) + (fVENDORBAR_BUTTON_TEXT_Y * fScaleFactor * HScale) - (fYTextLen / 2));
	Canvas.DrawShadowText(strYes,colorText,colorTextShadow);
	
	// Metallicafan212:	No text
	Canvas.TextSize(strNo,fXTextLen,fYTextLen);
	Canvas.SetPos(fBarX + (fVENDORBAR_NOBUTTON_X * fScaleFactor * HScale) + (fVENDORBAR_BUTTON_TEXT_X * fScaleFactor * HScale) - (fXTextLen / 2), fBarY + (fVENDORBAR_NOBUTTON_Y * fScaleFactor * HScale) + (fVENDORBAR_BUTTON_TEXT_Y * fScaleFactor * HScale) - (fYTextLen / 2));
	Canvas.DrawShadowText(strNo,colorText,colorTextShadow);
	
	// Metallicafan212:	Price text
	strCurrPrice = string(nCurrPrice);
	Canvas.TextSize(strCurrPrice, fXTextLen, fYTextLen);
	Canvas.SetPos(fBarX + (fVENDORBAR_PRICE_X * fScaleFactor * HScale) - fXTextLen / 2, fBarY + (fVENDORBAR_PRICE_Y * fScaleFactor * HScale) - fYTextLen / 2);
	Canvas.DrawShadowText(strCurrPrice, colorText, colorTextShadow);
	
	Canvas.Font = fontSave;
}

function float GetVendorBarX (Canvas canvas)
{
	// Omega: The below commented out math is obsolete (And wasn't correct either)
	// Kept only for posterity and an example of how we can do some better math with the new functions
	// Metallicafan212:	Add the offset
	//local float offset;
	local int PreTransform;
	
	//HScale = Class'M212HScale'.Static.CanvasGetHeightScale(Canvas);
	
	// Metallicafan212:	This needs to be offset to be in the center again
	//Offset = (256.0 / HScale) - (256.0 * HScale);//(256 - (256 * HScale)) * 2.0;
	
	//return ((canvas.SizeX / 2.0) - (canvas.GetHudScaleFactor() * (fVENDORBAR_W / 2.0))) + Offset;
	
	// Omega: No offset, use the alignment math instead: Same equation as stock, we just use our function to
	// align and correct it based on our current ratio. Center elements do not require the alignment function
	PreTransform = ((canvas.SizeX / 2.0) - (canvas.GetHudScaleFactor() * (fVENDORBAR_W / 2.0)));
	AlignXToCenter(Canvas, PreTransform);
	return PreTransform;
}

function float GetVendorBarY (Canvas canvas)
{
	return (canvas.GetHudScaleFactor() * fVENDORBAR_Y);
}

function bool IsMouseOverVendorYes()
{
	return (IsMouseOverVendorButton(fVENDORBAR_YESBUTTON_X * HScale, fVENDORBAR_YESBUTTON_Y * HScale, fVENDORBAR_BUTTON_W, fVENDORBAR_BUTTON_H));
}

function bool IsMouseOverVendorNo ()
{	
	return (IsMouseOverVendorButton(fVENDORBAR_NOBUTTON_X * HScale, fVENDORBAR_NOBUTTON_Y * HScale, fVENDORBAR_BUTTON_W, fVENDORBAR_BUTTON_H));
}

function bool IsMouseOverVendorButton (int nLeft, int nTop, int nWidth, int nHeight)
{
	local HPConsole hpCon;
	local int nVendorMouseX;
	local int nVendorMouseY;
	local float fScaleFactor;
	//local float Offset;
	
	//Offset = 256 - (256 * HScale);
	
	hpCon 			= HPConsole(Level.PlayerHarryActor.Player.Console);
	fScaleFactor 	= VendorCanvas.GetHudScaleFactor();
	nVendorMouseX 	= hpCon.MouseX * hpCon.Root.GUIScale;
	nVendorMouseY 	= hpCon.MouseY * hpCon.Root.HGUIScale;//hpCon.Root.GUIScale;
	nLeft 	*= fScaleFactor;
	nTop 	*= fScaleFactor;
	nWidth 	*= fScaleFactor * HScale;
	nHeight *= fScaleFactor * HScale;
	nLeft 	+= GetVendorBarX(VendorCanvas);
	nTop 	+= GetVendorBarY(VendorCanvas) * HScale;
	if( (nVendorMouseX >= nLeft) && (nVendorMouseX <= (nLeft + nWidth)) )
	{
		return ((nVendorMouseY >= nTop) && (nVendorMouseY <= (nTop + nHeight)));
	} 
	else
	{
		return False;
	}
}

event Tick (float fDeltaTime)
{
	Super.Tick(fDeltaTime);
	if ( HPConsole(Level.PlayerHarryActor.Player.Console).bVendorBar )
	{
		SetConsoleVendorBarFlags(True);
	}
}

defaultproperties
{
    bHidden=True

	DrawType=DT_None
}
