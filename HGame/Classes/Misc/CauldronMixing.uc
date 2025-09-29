//================================================================================
// CauldronMixing.
//================================================================================

class CauldronMixing extends HCauldron;

const strCUE_CAULDRON_NOT_AVAIL_LINE= "_MixingCauldronsNotAvailableYet";	// Moca: Const localization string for the disabled cauldron text.

// Moca: Enum for the start modes.
enum eStartMixOn
{
	SMO_Trigger,
	SMO_Bump
};

var() bool bIgnoreGamestate;		// Moca: Should gamestate be ignored entirely? Aka we rely entirely on bMixingEnabled. Def: False
var() int iGamestateEnabledOn; 		// Metallicafan212:	Gamestate the pot is enabled on. Def: 40

var() float fMixingCooldown;		// Moca: How long to wait in seconds before re-enabling the cauldron after a mix. Def: 4.5

var() float CauldronFXOffset;		// Moca: Offset for cauldron particle FX. Def: 25.0
var() class<ParticleFX> NeutralFX;	// Moca: Particle class for the neutral FX. Def: ParticleFX'Cauldron_Neutral'
var() class<ParticleFX> MixedFX;	// Moca: Particle class for the mixed FX. Def: ParticleFX'Cauldron_Mixed'

var() eStartMixOn StartMixOn;		// Moca: What causes the start to mix, a trigger or a bump? Def: SMO_Bump

var() bool bMixingEnabled;			// Moca: Is mixing enabled by default? This will be overridden by gamestate if bIgnoreGamestate is false. Def: True

var int iPotionCount;				// Moca: How many potions to make when mixing. Determined in code.

var Vector vTopOfCauldron;			// Moca: Location of the top of the cauldron.

var HCollectible propTemp;					// Moca: HProp reference for the HUD fly effect.

// Moca: StatusGroup/Item refs.
var StatusGroup sgPotionIngr;
var StatusGroup sgPotions;
var StatusItem siWiggenBark;
var StatusItem siFlobberMucus;

//-------------------------------------
// BeginPlay
//-------------------------------------

event PostBeginPlay()
{
	Super.PostBeginPlay();
	InitStatusItems();
}

// Metallicafan212:	Move it here so we can call upon it to fix it up.
function InitStatusItems()
{
	sgPotionIngr 	= PlayerHarry.managerStatus.GetStatusGroup(Class'StatusGroupPotionIngr');
	sgPotions 		= PlayerHarry.managerStatus.GetStatusGroup(Class'StatusGroupPotions');
	siWiggenBark 	= sgPotionIngr.GetStatusItem(Class'StatusItemWiggenBark');
	siFlobberMucus 	= sgPotionIngr.GetStatusItem(Class'StatusItemFlobberMucus');
}

//-------------------------------------
// Events
//-------------------------------------

event Trigger (Actor Other, Pawn EventInstigator)
{
	if (StartMixOn != SMO_Trigger || !HaveWiggenPotionIngredients())
	{
		return;
	}

	GotoState('Mixing');
}

event Bump (Actor Other)
{
	if (StartMixOn != SMO_Bump || !HaveWiggenPotionIngredients())
	{
		return;
	}

	if(!bIgnoreGamestate)
	{
		if(PlayerHarry.iGameState >= iGamestateEnabledOn)
		{
			bMixingEnabled = true;
		}
		else
		{
			bMixingEnable = false;
		}
	}

	if (!bMixingEnabled)
	{
		GotoState('CauldronsNotAvailableYet');
	}
	else
    {
		TriggerEvent(Event, None, None);
		GotoState('Mixing');
    }
}

//-------------------------------------
// Misc. Functions
//-------------------------------------

function bool CutCommand (string Command, optional string cue, optional bool bFastFlag)
{
	local string sActualCommand;
	local string sCutName;
	local Actor A;
	
	sActualCommand = ParseDelimitedString(Command," ",1,False);
	if ( sActualCommand ~= "Capture" )
	{
		return Super.CutCommand(Command,cue,bFastFlag);
	} 
	else if ( sActualCommand ~= "Release" )
    {
		return Super.CutCommand(Command,cue,bFastFlag);
    } 
	else if ( sActualCommand ~= "Enable" )
	{
		bMixingEnabled = True;
		CutNotifyActor.CutCue(cue);
		return True;
	} 
	else if ( sActualCommand ~= "Disable" )
	{
		bMixingEnabled = False;
		CutNotifyActor.CutCue(cue);
		return True;
	}
	else 
	{
		return Super.CutCommand(Command,cue,bFastFlag);
	}
}

function SetCauldronFX (class<ParticleFX> FX)
{
	local Vector vOffset;
	
	killAttachedParticleFX(0.0);

	vOffset.X = 0.0;
	vOffset.Y = 0.0;
	vOffset.Z = CauldronFXOffset;
	attachedParticleOffset[0] = vOffset;
	attachedParticleClass[0] = FX;

	CreateAttachedParticleFX();
}

function int GetNumPotionsToMake()
{
	if(siWiggenBark == none || siFlobberMucus == none)
	{
		InitStatusItems();
	}
	
	return Min(siWiggenBark.nCount,siFlobberMucus.nCount);
}

function bool HaveWiggenPotionIngredients()
{
	if(siWiggenBark == none || siFlobberMucus == none)
	{
		InitStatusItems();
	}
	
	return (siWiggenBark.nCount > 0) && (siFlobberMucus.nCount > 0);
}

auto state Idle
{
	event BeginState()
	{
		Super.BeginState();
		SetCauldronFX(NeutralFX);
	}
}

state CauldronsNotAvailableYet
{
	ignores Bump;
	
	event BeginState()
	{
		local string strDialog;
		local string strDialogID;
		local float fSoundLen;
		local TimedCue tcue;
		
		if ( Rand(2) == 0 )
		{
			strDialogID = "Shared_Menu_0009";
		} 
		else 
		{
			strDialogID = "Shared_Menu_0010";
		}
    
		strDialog = Localize("All",strDialogID,"HPMenu");
		fSoundLen = (Len(strDialog) * 0.01) + 3.0;
		tcue = Spawn(Class'TimedCue');
		tcue.CutNotifyActor = self;
		tcue.SetupTimer(fSoundLen + 0.5,strCUE_CAULDRON_NOT_AVAIL_LINE);
		harry(Level.PlayerHarryActor).myHUD.SetSubtitleText(strDialog,fSoundLen);
	}

	function CutCue (string cue)
	{
		if ( cue ~= strCUE_CAULDRON_NOT_AVAIL_LINE )
		{
			GotoState('Idle');
		}
	}
}

state Mixing
{
	ignores Bump;

	event BeginState()
	{
		harry(Level.PlayerHarryActor).ActiveCauldron = self;
		sgPotionIngr.SetEffectTypeToPermanent();
		sgPotions.SetEffectTypeToPermanent();
		sgPotionIngr.SetCutSceneRenderMode(True);
		sgPotions.SetCutSceneRenderMode(True);
	}

	event EndState()
	{
		sgPotionIngr.SetCutSceneRenderModeToNormal();
		sgPotions.SetCutSceneRenderModeToNormal();
		sgPotionIngr.SetEffectTypeToNormal();
		sgPotions.SetEffectTypeToNormal();
	}

	function GetFlobberLoc()
	{
		local Vector vFlobberHudLoc;

		vFlobberHudLoc = sgPotionIngr.GetItemLocation(Class'StatusItemFlobberMucus',False);
		propTemp = HCollectible(FancySpawn(Class'FlobberwormMucus',,,vFlobberHudLoc));
		propTemp.fMinFlyToHudScale = 0.1;
		propTemp.fMaxFlyToHudScale = 0.4;
		propTemp.DropOffLoc = vTopOfCauldron;
		propTemp.DoPickupProp(True);
	}

	function HandlePropFly(Vector HudLoc, class<PotionIngredients> IngredClass)
	{
		propTemp = HCollectible(FancySpawn(IngredClass,,,HudLoc));
		propTemp.fMinFlyToHudScale = 0.1;
		propTemp.fMaxFlyToHudScale = 0.4;
		propTemp.DropOffLoc = vTopOfCauldron;
		propTemp.DoPickupProp(True);
	}
	
	begin:
		PlayerHarry.GotoState('statePotionMixingBegin');

		Sleep(0.5);

		vTopOfCauldron = Location;
		vTopOfCauldron.Z += 40;

		iPotionCount = GetNumPotionsToMake();
		
		for(I = 0; I < iPotionCount; I++)
		{
			HandlePropFly(sgPotionIngr.GetItemLocation(Class'StatusItemFlobberMucus',False), Class'FlobberwormMucus');
			Sleep(0.1);
			HandlePropFly(sgPotionIngr.GetItemLocation(Class'StatusItemWiggenBark',False), Class'WiggentreeBark');
			Sleep(0.1);
		}		
		
		PlayerHarry.GotoState('statePotionMixingStir');
		Sleep(1.0);
		
		for(I = 0; I < iPotionCount; I++)
		{
			propTemp = HCollectible(FancySpawn(Class'WWellCauldronBottle',,,vTopOfCauldron));
			Sleep(0.25);
			propTemp.fTotalFlyTime = 0.5;
			propTemp.fMinFlyToHudScale = 0.8;
			propTemp.DoPickupProp();
			Sleep(0.25);
		}

		SetCauldronFX(MixedFX);

		Sleep(0.3);

		PlayerHarry.GotoState('statePotionMixingIdle');

		PlaySound(Sound'Potion_complete');

		PlayerHarry.DoPotionMixingEnd();

		Sleep(fMixingCooldown);
		GotoState('Idle');
}

defaultproperties
{
    bMixingEnabled=True

    Mesh=SkeletalMesh'HProps.skCauldronTeacherMesh'

    CollisionRadius=15.00

    CollisionHeight=100.00

	bMixingEnabled=True
	
	iGamestateEnabledOn=40

	fMixingCooldown=4.5

	CauldronFXOffset=25.0

	NeutralFX=ParticleFX'Cauldron_Neutral'

	NeutralFX=ParticleFX'Cauldron_Mixed'

	StartMixOn=SMO_Bump
}