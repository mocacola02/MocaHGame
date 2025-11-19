//================================================================================
// harry.
//================================================================================ 

// MocaHGame rewrite started 9/28/2025 22:00.

class harry extends PlayerPawn
  Config(User);    

//-------------------------------------
// GlobalConfig
//-------------------------------------
var globalconfig bool bAutoCenterCamera;
var globalconfig bool bDollyZoomCamera;
var globalconfig bool bMoveWhileCasting;
var globalconfig bool bAutoQuaff;
var globalconfig bool bWithOlly;
var globalconfig bool bInvertBroomPitch;
var globalconfig bool bAllowBroomMouse;
var globalconfig bool bDisableDialog;

var globalconfig int AnnouncerVolume;

var globalconfig float fDamageMultiplier_Easy;
var globalconfig float fDamageMultiplier_Medium;
var globalconfig float fDamageMultiplier_Hard;
var globalconfig float fDamageMultiplier_Custom;

//-------------------------------------
// Input / Movement
//-------------------------------------
var input byte bBroomYawLeft;
var input byte bBroomYawRight;
var input byte bBroomPitchUp;
var input byte bBroomPitchDown;
var input byte bBroomBoost;
var input byte bBroomBrake;
var input byte bBroomAction;
var input byte bDrinkWiggenwell;
var input byte bSpellBallAction;
var input byte bVendorReply;
var input byte bDuelCycleSpell;
var input byte bSpellLessonLeft;
var input byte bSpellLessonRight;
var input byte bSpellLessonUp;
var input byte bSpellLessonDown;
var input byte bOpenMap;
var input byte bSkipCutScene;

var input float aBroomYaw;
var input float aBroomPitch;
var input float aJoyBroomYaw;
var input float aJoyBroomPitch;
var input float aSpellLessonX;
var input float aSpellLessonY;

var(Movement) float GroundEctoSpeed;
var(Movement) float GroundJumpSpeed;

var float HighestZ;

var(Movement) bool bUseFixedFaceDirection;
var(Movement) Vector FixedFaceDirection;

var(Movement) bool bConstrainYaw;
var(Movement) bool bKeepStationary;
var(Movement) bool bLockedOnTarget;

var(Input) bool bReverseInput;
var(Input) bool bCanUseWeapon;
var(Input) float SpellCursorRange;

var int WebAmount;
var float AirTime;

//-------------------------------------
// Visual
//-------------------------------------
enum enumHarryAnimSet
{
  HARRY_ANIM_SET_MAIN,
  HARRY_ANIM_SET_ECTO,
  HARRY_ANIM_SET_SLEEPY,
  HARRY_ANIM_SET_SWORD,
  HARRY_ANIM_SET_WEB,
  HARRY_ANIM_SET_DUEL
};

struct cHarryAnims
{
  var name Idle;
  var name Walk;
  var name run;
  var name WalkBack;
  var name StrafeRight;
  var name StrafeLeft;
  var name Jump;
  var name Jump2;
  var name Fall;
  var name Land;
};

var(Animations) name FaintAnim;

var name CurrIdleAnimName;

var array<cHarryAnims> HarryAnims;
var enumHarryAnimSet HarryAnimSet;
var cHarryAnimChannel HarryAnimChannel;
var EAnimType HarryAnimType;

var float LastAnimFrame;

var int WaitingCount;

var(Ecto) bool bPlayedEctoKnockBack;

//-------------------------------------
// Health
//-------------------------------------
enum eDeathTypes
{
	DEATH_Instant,
	DEATH_Slow,
	DEATH_Fast,
	DEATH_Hidden
};

var eDeathTypes DeathType;
var name LastDamageType;

var(Health) int ReviveHealth; // Moca: How much health to set if revived? Applies if Harry enters a level change while dead.
var(Health) bool bNoFallingDamage;

var float TimeSinceLastAcidHit;

var bool bHarryKilled;
var int PreviousHealth;

//-------------------------------------
// Sound
//-------------------------------------
var(Sounds) Sound drown;
var(Sounds) Sound breathagain;
var(Sounds) Sound HitSound3;
var(Sounds) Sound HitSound4;
var(Sounds) Sound Die2;
var(Sounds) Sound Die3;
var(Sounds) Sound Die4;
var(Sounds) Sound GaspSound;
var(Sounds) Sound LandGrunt;

var(Sounds) array<Sound> HurtSounds;
var(Sounds) array<Sound> GoyleHurtSounds;

var(Sounds) array<Sound> DieSounds;
var(Sounds) array<Sound> GoyleDieSounds;

var(Sounds) array<Sound> LandedSounds;
var(Sounds) array<Sound> GoyleLandedSounds;

var(Sounds) array<Sound> FallingPullupSounds;
var(Sounds) array<Sound> GoyleFallingPullupSounds;

var(Sounds) array<Sound> EasyPullupSounds;
var(Sounds) array<Sound> GoyleEasyPullupSounds;

var(Sounds) array<Sound> HardPullupSounds;
var(Sounds) array<Sound> GoyleHardPullupSounds;

var(Sounds) array<Sound> FallDeepSounds;
var(Sounds) array<Sound> GoyleFallDeepSounds;

var(Sounds) array<Sound> JumpEmoteSounds;
var(Sounds) array<Sound> GoyleJumpEmoteSounds;

var(Sounds) Sound EctoDamage;
var(Sounds) int EctoHurtSoundCount;

var(Sounds) Sound StirPotion;
var(Sounds) array<Sound> PotionMixingSounds;
var Sound SelectedMixingSound;
var float MixingSoundDuration;

var(Sounds) class<FootstepSet> FootstepSoundSet;

var(Sounds) float LandingNoiseMult;

//-------------------------------------
// HousePoints
//-------------------------------------
var(HousePoints) const int maxPointsPerHouse;
var(HousePoints) const int HarryMultipleForGryffindor;

var travel int numHousePointsHarry;

var int numHousePointsGryffindor;
var int numHousePointsSlytherin;
var int numHousePointsHufflepuff;
var int numHousePointsRavenclaw;
var int numLastHousePointsHarry;

//-------------------------------------
// Inventory
//-------------------------------------
struct WCardSaveData
{
  var int nCardId;
  var int nCardOwner;
};

struct StatusSaveData
{
  var Class<StatusGroup> classGroup;
  var Class<StatusItem> classItem;
  var int nPotential;
  var int nCount;
  var int nMaxCount;
};

var StatusManager managerStatus;

var travel array<StatusSaveData> StatusSave;
var travel array<WCardSaveData> BronzeCardSave;
var travel array<WCardSaveData> SilverCardSave;
var travel array<WCardSaveData> GoldCardSave;

var travel bool IgnoreSpellbook;
var travel array<Class<baseSpell>> SpellBook;

var travel bool bHaveNimbus2001;
var travel bool bHaveQArmor;

var travel int nLastCardTypeSave;

var(Weapon) Weapon DefaultWeapon;

//-------------------------------------
// Dueling
//-------------------------------------
struct DuelSpellIcon
{
	var class<baseSpell> MatchingSpell;
	var Texture DuelSpellIcon;
	var Texture DuelSpellSelectedIcon;
};

var travel int DuelRankHarry;
var travel int DuelRankOppon;
var travel int DuelRankBeans;
var travel int curWizardDuel;
var travel int curWizardDuelRank;
var travel int lastUnlockedDuelist;

var bool bInDuelingMode;

var int CurrentDuelSpell;

var SpellSelector DuelSpellSelector;
var Duellist DuelOpponent;

var array<baseSpell> DuelSpellList;
var array<Sound> DuelSpellSounds;
var array<DuelSpellIcon> DuelingSpellIcons;

//-------------------------------------
// Challenges
//-------------------------------------
struct ChallengeScoreType  
{  
  var int nHighScore;
  var int nMaxScore; 
};

var travel array<ChallengeScoreType> ChallengeScores;

//-------------------------------------
// Objective
//-------------------------------------
var travel string strObjectiveId;
var travel string strObjectiveIntFile;
var travel string strObjectiveSection;

//-------------------------------------
// Quidditch
//-------------------------------------
struct QuidGameResult 
{
  var string Opponent;
  var int myScore;
  var int OpponentScore;
  var int HousePoints;
  var bool bLocked;
  var bool bWon;
};

var travel array<QuidGameResult> quidGameResults;

var travel int curQuidMatchNum;

//-------------------------------------
// Object References
//-------------------------------------
var baseWand Wand;
var BaseCam Cam;
var FEBook menuBook;
var Actor CarryingActor;
var CauldronMixing ActiveCauldron;
var(Boss) baseBoss BossTarget;
var HPawn HearHarryRecipient;
var SpellCursor Cursor;

//-------------------------------------
// Misc. Travel
//-------------------------------------
var travel string PreviousLevelName;

//-------------------------------------
// Miscellaneous
//-------------------------------------
var int iGameState;
var int EctoAmount;
var bool bFlashCooldown;
var() class<HUD> HUDToUse;
var float SleepyTimer;
var Texture LastHitTexture;
var array<Sound> LastFootstepSounds;
var float DifficultyMultiplier;
var(Magic) bool bLumosOnSpawn;

//-------------------------------------
// Pending Deletion
//-------------------------------------
//var travel bool bHub9CeremonyFlag;
//var travel bool bSaidVendorInstructions;
//var travel bool bHarryKilled;


//-------------------------------------
// BeginPlay Event & Helpers
//-------------------------------------
event PreBeginPlay()
{
	Super.PreBeginPlay();

	FOVAngle = DesiredFOV;
	
	GetDirector();
	GetStatusManager();

	HUDType = HUDToUse;
	menuBook = HPConsole(Player.Console).menuBook;

	if (DifficultyMultiplier == 0)
	{
		switch(Difficulty)
		{
			case DifficultyEasy:
				SetDifficultyMultiplier(fDamageMultiplier_Easy); break;
			case DifficultyMedium:
				SetDifficultyMultiplier(fDamageMultiplier_Medium); break;
			case DifficultyHard:
				SetDifficultyMultiplier(fDamageMultiplier_Hard); break;
			default:
				SetDifficultyMultiplier(fDamageMultiplier_Easy); break;
		}
	}
}

event PostBeginPlay()
{
	Super.PostBeginPlay();

	InitDependencies();

    CopyAllStatusFromHarryToManager();

	if (bLumosOnSpawn && Weapon.IsA('baseWand'))
	{
		baseWand(Weapon).LumosTurnOn();
	}
}

function GetDirector()
{
	foreach AllActors(Class'Director',Director)
	{
		Director.PlayerHarry = self;
		break;
	}

	if (Director == None)
	{
		ErrorMsg("MocaHGame Error: Harry could not find his Director.");
	}
}

function GetStatusManager()
{
	if ( managerStatus == None )
	{
		managerStatus = Spawn(Class'StatusManager');
		managerStatus.PlayerHarry = self;
		managerStatus.CreateStartupItems();
	}
}

function GetBaseCam()
{
	ForEach AllActors( class'BaseCam', cam )
		break;
	
	if( cam == none )
	{
		cam = spawn( class'BaseCam' );
		SpellCursor.TickParent = cam;
	}

	if (cam == none)
	{
		ErrorMsg("MocaHGame Error: BaseCam could not be spawned.");
	}

	viewClass(class'BaseCam', true);
}

function InitDependencies()
{
	HUDType=class'HPHud';

	Shadow = Spawn(ShadowClass,self);

	HarryAnimChannel = cHarryAnimChannel( CreateAnimChannel(class'cHarryAnimChannel', AT_Replace, 'bip01 spine1') );
	HarryAnimChannel.SetOwner( self );

	Cursor = Spawn(Class'SpellCursor');
}

//-------------------------------------
// Misc. Events
//-------------------------------------

event UpdateEyeHeight(float DeltaTime);

event Possess()
{
	Super.Possess();
	if ( Director != None )
	{
		Director.OnPlayerPossessed();
	}
}

function OnEvent (name EventName)
{
	if ( EventName == 'LumosOff' )
	{
		baseWand(Weapon).TheLumosLight.TurnOff();
	}
	
	Super.OnEvent(EventName);
}

//-------------------------------------
// Cutscene
//-------------------------------------

function DisablePlayerInput()
{
	SendPlayerCaptureMessages(True);
	bIsCaptured = True;
	myHUD.StartCutScene();
	bKeepStationary = True;
}

function EnablePlayerInput()
{
	bIsCaptured = False;
	myHUD.EndCutScene();
	bKeepStationary = False;
	SendPlayerCaptureMessages(False);
}

//-------------------------------------
// Spellbook
//-------------------------------------

function AddToSpellBook (Class<baseSpell> spellClass)
{
	if (!IsSpellInBook(spellClass))
	{
		SpellBook.AddItem(spellClass);
	}
}

function bool IsSpellInBook(Class<baseSpell> spellClass)
{
	local int i;

	for (i = 0; i < Spellbook.Length; i++)
	{
		if (Spellbook[i] == spellClass)
		{
			return true;
		}
	}

	return false;
}

function ToggleSpellbookEnforcement()
{
	IgnoreSpellbook = !IgnoreSpellbook();
	ClientMessage("Spellbook Ignore set to " $ string(IgnoreSpellbook));
}

function AddToSpellBookByString (string SpellName)
{
	local class<baseSpell> SpellToAdd;

    SpellToAdd = class<baseSpell>(DynamicLoadObject(SpellName, class'baseSpell'));

    if (SpellToAdd != None)
    {
        StoredClasses.AddItem(SpellToAdd);
    }
    else
    {
		ClientMessage("Failed to find class " $ SpellName);
    }
}

function ClearSpellBook()
{
	Spellbook.Empty();
}

//-------------------------------------
// Dueling
//-------------------------------------

function TurnOnDuelingMode (Duellist PawnOpponent)
{
	local Rotator R;
	local int nMaxHealth;

	bInDuelingMode = True;

	// Set duel opponent
	DuelOpponent = PawnOpponent;

	// Prepare cam
	Cam.SetCameraMode(Cam.ECamMode.CM_Dueling);
	Cam.SetYaw(0.0);
	Cam.SetPitch(-3500.0);
	Cam.SetFOV(50.0);

	// Prepare rotation
	R = Rotation;
	R.Yaw = 0;
	SetRotation(R);
	DesiredRotation = R;

	// Prepare health
	PreviousHealth = managerStatus.GetHealthCount();
	nMaxHealth = managerStatus.GetHealthPotentialCount();
	managerStatus.SetHealthCount(nMaxHealth);

	// Prepare duellist health
	DuelOpponent.nMaxHealth = nMaxHealth;
	DuelOpponent.Health = nMaxHealth;
	DuelOpponent.SetHealthBar();

	// Set anim set
	HarryAnimSet = HARRY_ANIM_SET_DUEL;

	// Prepare wand
	SpellCursor.bInvisibleCursor = True;
	Wand.StartGlowingWand(Wand.CurrentSpell);

	// Get spell selector if we don't have one
	if ( DuelSpellSelector == None )
	{
		DuelSpellSelector = SpellSelector(FancySpawn(Class'SpellSelector'));
	}
}

function TurnOffDuelingMode()
{
	bInDuelingMode = False;

	// Stop opponent
	DuelOpponent.TurnOffSpellCursor();
	DuelOpponent.GotoState('stateIdle');
	DuelOpponent.Health = 0;

	// Set cam
	Cam.SetCameraMode(Cam.ECamMode.CM_Standard);
	Cam.SetFOV(90.0);

	// Restore health
	managerStatus.SetHealthCount(PreviousHealth);

	// Set anim set
	HarryAnimSet = HARRY_ANIM_SET_MAIN;

	// Restore wand
	SpellCursor.bInvisibleCursor = False;
	Wand.StopGlowingWand();

	// Remove spell selector
	DuelSpellSelector.Destroy();
	DuelSpellSelector = None;
}

function HandleDuelPlayerInput()
{
	local bool bSpellCyclePressed;

	bSpellCyclePressed = bDuelCycleSpell;

	if ( bSpellCyclePressed )
	{
		bSpellCyclePressed = False;
		CurrentDuelSpell++;

		if ( CurrentDuelSpell > DuelSpellList.Length)
		{
			CurrentDuelSpell = 0;
		}

		SetDuelSpell(CurrentDuelSpell);
	}
}

function int GetDuelSpellIdx(baseSpell SpellClass)
{
	local int i;

	for (i = 0; i < DuelSpellList.Length; i++)
	{
		if (DuelSpellList[i] == spellClass)
		{
			return i;
		}
	}

	return 0;
}

exec function SetDuelSpell(int SpellIdx)
{
	CurrentDuelSpell = Clamp(SpellIdx,0,DuelSpellList.Length);

	DuelSpellSelector.SetSelection(DuelSpellList[CurrentDuelSpell]);

	Wand.CurrentSpell = DuelSpellList[CurrentDuelSpell];
	Wand.StartGlowingWand(CurrentSpell);

	PlaySound(DuelSpellSounds[CurrentDuelSpell]);
}

function bool IsDueling()
{
	return bInDuelingMode;
}

//-------------------------------------
// Ecto
//-------------------------------------

function EctoRefAdd()
{
	EctoAmount++;
	EctoAmount = Clamp(EctoAmount,0,MAXINT);

	if ( EctoAmount == 1 )
	{
		GroundSpeed = GroundEctoSpeed;
		HarryAnimSet = HARRY_ANIM_SET_ECTO;
		PlaySound(EctoDamage,SLOT_Interact,,,,,,True);
	}
}

function EctoRefSub()
{
	EctoAmount--;
	EctoAmount = Clamp(EctoAmount,0,MAXINT);

	if ( EctoAmount <= 0)
	{
		GroundSpeed = GroundRunSpeed;
		HarryAnimSet = HARRY_ANIM_SET_MAIN;
		bFlashCooldown = False;
		StopSound(EctoDamage,SLOT_Interact);
	}
}

//-------------------------------------
// Web
//-------------------------------------

function WebAnimRefCountAdd()
{
	WebAmount++;
	WebAmount = Clamp(WebAmount,0,MAXINT);

	if ( WebAmount == 1 )
	{
		GroundSpeed = fWebSpeed;
	}
}

function WebAnimRefCountSub()
{
	WebAmount--;
	WebAmount = Clamp(WebAmount,0,MAXINT);

	if (WebAmount <= 0)
	{
		GroundSpeed = GroundRunSpeed;
	}
}

//-------------------------------------
// Misc. Functions
//-------------------------------------

function ResetFired()
{
	bJustFired = False;
	bJustAltFired = False;
}

function DestroyClass (string ClassToDestroy)
{
	local name ClassN;
	local Actor A;

	ClassN = name(ClassToDestroy);
	foreach AllActors(Class'Actor',A)
	{
		if ( A.IsA(ClassN) )
		{
			ClientMessage("Destroying:" $ string(A));
			A.Destroy();
		}
	}
}

function ListGroups()
{
	local Actor A;

	foreach AllActors(Class'Actor',A)
	{
		ClientMessage(string(A) $ " " $ string(A.Group));
	}
}

function GotoLocation (Vector newLoc)
{
	// Add collision height to target Z
	newLoc.Z = newLoc.Z + CollisionHeight;

	// Set location
	SetLocation(newLoc);

	// Set our highest Z to the new location's Z
	HighestZ = Location.Z;
}

function SetDifficultyMultiplier(float Multiplier)
{
	DifficultyMultiplier = Multiplier;
}

//-------------------------------------
// Saving, Loading, & Travel
//-------------------------------------

event PreSaveGame()
{
	PreviousLevelName = "";
	SloMo(1.0);
	CopyAllStatusFromManagerToHarry();
}

event PostSaveGame()
{
	bShowLoadingScreen = False;
}

function LoadLevel (string LevelName)
{
	local Characters A;

	foreach AllActors(Class'Characters',A)
	{
		if ( A.bPersistent )
		{
			A.PersistentState = A.GetStateName();
			
			if(A.LeadingActor != None)
				A.PersistentLeadingActor = A.LeadingActor.Name;
			
			if(A.navP != None)
				A.PersistentNavPName = A.navP.Name;
				
			Log("*!* " $ string(A) $ " P_SAVING: PersistentState: " $ string(A.PersistentState) $ " for " $ string(A));
			Log("*!* " $ string(A) $ " P_SAVING: LeadingActor: " $ string(A.PersistentLeadingActor) $ " AnimSequence: " $ string(A.AnimSequence) $ " navP:" $ string(A.navP));
		}
	}

	StopAllMusic(1.0);
	ConsoleCommand("SavePActors");
	HPConsole(Player.Console).ChangeLevel(LevelName,True);
}

event PreClientTravel()
{
	local string TS;
	local int TI;

	// Get level name
	TI = InStr(Level.LevelEnterText,".");

	if ( TI == -1 )
	{
		TS = Level.LevelEnterText;
	}
	else
	{
		TS = Left(Level.LevelEnterText,TI);
	}

	Log("PreClientTravel: Cur Level Name:" $ Level.LevelEnterText);

	if ( !bQueuedToSaveGame )
	{
		Log("PreClientTravel: Setting Previous Level Name:" $ PreviousLevelName);
		cm("PreClientTravel: Setting Previous Level Name:" $ PreviousLevelName);
		PreviousLevelName = TS;
	}

	ClearNonTravelStatus();
	CopyAllStatusFromManagerToHarry();

	if ( bHarryKilled )
	{
		cm("***Setting health to iMinHealthAfterDeath(" $ string(iMinHealthAfterDeath) $ ") because harry died before we loaded this level.");
		SetHealth(ReviveHealth);
		bHarryKilled = False;
	}
}

event TravelPostAccept()
{
    local SmartStart StartPoint;
    local Characters Ch;
    local Weapon weap;
    local bool bFoundSmartStart;

	Super.TravelPostAccept();
	
	iGamestate = ConvertGameStateToNumber();
	
	Log("weapon is" $ string(Weapon));

	if ( Inventory == None )
	{
		weap = Spawn(DefaultWeapon,self);
		weap.BecomeItem();
		AddInventory(weap);
		weap.WeaponSet(self);
		weap.GiveAmmo(self);
		Log(string(self) $ " spawning weap " $ string(weap));
	} 
	else 
	{
		Log("not spawning weap");
	}

	CopyAllStatusFromHarryToManager();
	StatusGroupWizardCards(managerStatus.GetStatusGroup(Class'StatusGroupWizardCards')).RemoveHarryOwnedCardsFromLevel(None);
	
	if ( Director != None )
	{
		Director.OnPlayerTravelPostAccept();
	}

	foreach AllActors(Class'Characters',Ch)
	{
		Ch.SetEverythingForTheDuel();
	}

	if ( PreviousLevelName != "" )
	{
		bFoundSmartStart = False;
		foreach AllActors(Class'SmartStart',StartPoint)
		{
			if ( (StartPoint.PreviousLevelName != "") && (StartPoint.PreviousLevelName ~= PreviousLevelName) )
			{
				SetLocation(StartPoint.Location);
				SetRotation(StartPoint.Rotation);

				if ( StartPoint.bDoLevelSave )
				{
					harry(Level.PlayerHarryActor).SaveGame();
				}

				cm("***Found SmartStart from:" $ PreviousLevelName);
				Log("***Found SmartStart from:" $ PreviousLevelName);

				bFoundSmartStart = True;
				break;
			} 
		}
	}
	if (  !bFoundSmartStart )
	{
		cm("***Failed to find SmartStart from:" $ PreviousLevelName);
		Log("***Failed to find SmartStart from:" $ PreviousLevelName);
	}

	if ( bQueuedToSaveGame )
	{
		cm(" *-*-* Keep the loading screen ON because we *ARE* QueuedToSaveGame. At least until we are done saving.");
		Log(" *-*-* Keep the loading screen ON because we *ARE* QueuedToSaveGame. At least until we are done saving.");
		bShowLoadingScreen = True;
	} 
	else 
	{
		cm(" *-*-* Turn OFF the loading screen because we are *NOT* QueuedToSaveGame.");
		Log(" *-*-* Turn OFF the loading screen because we are *NOT* QueuedToSaveGame.");

		bShowLoadingScreen = False;
		
		Log("Loading into save with cutscene skip state: " $HPHud(MyHud).managerCutScene.bShowFF);
		if(HPHud(MyHud).managerCutScene.bShowFF)
		{
			HPConsole(Player.Console).StartFastForward();
		}
	}

	Cam.FOVChanged();
}

function CopyAllStatusFromHarryToManager()
{
  CopyGenericStatusFromHarryToManager();
  CopyCardCardStatusFromHarryToManager();
}

function CopyGenericStatusFromHarryToManager()
{
	local StatusItem  siCurr;
	local int         nStatusIdx;

	// Repopulate status manager items from info we saved off before traveling or saving.
	for (nStatusIdx=0; nStatusIdx<ArrayCount(StatusSave); nStatusIdx++)
	{
		// Nothing more in our list.  Stop looping.
		if (StatusSave[nStatusIdx].classGroup == None)
		{
			break;
		}

		siCurr = managerStatus.GetStatusItem(StatusSave[nStatusIdx].classGroup, StatusSave[nStatusIdx].classItem); 
		siCurr.nCount = StatusSave[nStatusIdx].nCount;
		siCurr.nCurrCountPotential = StatusSave[nStatusIdx].nPotential;
        siCurr.nMaxCount = StatusSave[nStatusIdx].nMaxCount;
	}
}

function CopyCardCardStatusFromHarryToManager()
{
	local StatusGroupWizardCards sgCards;
	local StatusItemWizardCards  siCards;
	local int                    i;

	sgCards = StatusGroupWizardCards(managerStatus.GetStatusGroup(class'StatusGroupWizardCards'));

	// Restore bronze card data.
	siCards = StatusItemWizardCards(sgCards.GetStatusItem(class'StatusItemBronzeCards'));
	for (i=0; i<ArrayCount(BronzeCardSave); i++)
	{
		siCards.SetCardData(i, BronzeCardSave[i].nCardId, BronzeCardSave[i].nCardOwner);
	}

	// Restore silver card data.
	siCards = StatusItemWizardCards(sgCards.GetStatusItem(class'StatusItemSilverCards'));
	for (i=0; i<ArrayCount(SilverCardSave); i++)
	{
		siCards.SetCardData(i, SilverCardSave[i].nCardId, SilverCardSave[i].nCardOwner);
	}

	// Restore gold card data.
	siCards = StatusItemWizardCards(sgCards.GetStatusItem(class'StatusItemGoldCards'));
	for (i=0; i<ArrayCount(GoldCardSave); i++)
	{
		siCards.SetCardData(i, GoldCardSave[i].nCardId, GoldCardSave[i].nCardOwner);
	}

	// Restore last card group picked up
	sgCards.SetLastObtainedCardTypeAsInt(nLastCardTypeSave);
}

//-------------------------------------
// Carrying & Throwing
//-------------------------------------

function SetCarryingActor (optional name nameBone)
{
	// If no nameBone was provided, default to weapon bone
	if ( nameBone == 'None' )
	{
		nameBone = 'WeaponRight';
	}

	// If we have a carried actor:
	if ( CarryingActor != None )
	{
		// Hide our weapon if attached to weapon bone
		if ( nameBone == 'WeaponRight' )
		{
			Weapon.bHidden = True;
		}

		// Prep animation combine
		HarryAnimType = AT_Combine;
		// Prep carried actor
		CarryingActor.SetCollision(False,False,False);
		CarryingActor.SetOwner(self);
		CarryingActor.AttachToOwner(nameBone);
		CarryingActor.bRotateToDesired = False;
	}
	// Otherwise, don't carry
	else
	{
		ClientMessage("******* Dont allow this case   SetCarryingActor *******");
		Weapon.bHidden = False;
	}

	bThrow = False;
}

function AttachCarryActor (optional name nameBone)
{
	// If we have a carried actor
	if ( CarryingActor != None )
	{
		// Go to carry it
		SetCarryingActor(nameBone);
	} 
	else
	{
		// Drop our carry
		DropCarryingActor();
	}
}

function PickupActor (Actor Other)
{
	// This might not be optimal, but I'll see where it goes

	// If pickup is an HPawn
	if (Other.IsA('HPawn'))
	{
		local HPawn ActorToPickup;
		ActorToPickup = HPawn(Other);
	}
	// If pickup is an HProp (since those aren't pawns now)
	else if (Other.IsA('HProp'))
	{
		local HProp ActorToPickup;
		ActorToPickup = HProp(Other);
	}
	// If we're not either, abort!
	else
	{
		Log("Not a compatible pickup actor!");
		return;
	}

	// If we're eligible to carry, "do it". - Emperor Palpatine, 19 BBY
	if ( Physics == PHYS_Walking && IsInState('PlayerWalking') && CarryingActor == None && ActorToPickup.bObjectCanBePickedUp)
	{
		ClientMessage("Do Pickup");
		CarryingActor = ActorToPickup;
		GotoState('statePickupItem');
	}
}

function DropCarryingActor (optional bool bLatentDrop)
{
	ClientMessage("** DropCarryingActor");

	// If we're carrying an actor
	if ( CarryingActor != None )
	{
		// Set the carried actor to be dropped
		CarryingActor.SetPhysics(PHYS_Falling);
		CarryingActor.SetOwner(None);
		CarryingActor.Velocity = vect(0.00,0.00,125.00);
		CarryingActor.Instigator = self;
		CarryingActor.bRotateToDesired = True;
		CarryingActor.SetCollision(True,True,True);
		CarryingActor = None;
	}

	// If we were in pickup, go back to walk
	if ( IsInState('statePickupItem') )
	{
		GotoState('PlayerWalking');
	}

	// Tbh i'm not entirely sure what latent drop is, so i'm leaving it as is. I think it determines if harry can move during the drop? dunno
	if ( !bLatentDrop )
	{
		HarryAnimChannel.GotoState('stateIdle');
		HarryAnimType = AT_Replace;
	}
	
	// Unhide our wand
	Weapon.bHidden = False;
}

function ThrowCarryingActor()
{
	local Vector V;
	local Actor Target;
	local float ThrowVelocity;

	if ( bThrow && (CarryingActor != None) )
	{
		// Again this feels a bit risky, but we'll see
		if (CarryingActor.IsA('HProp'))
		{
			local HProp A;
		}
		else if (CarryingActor.IsA('HPawn'))
		{
			local HPawn A;
		}
		else
		{
			Log("CarryingActor is not valid!");
			return;
		}

		// Reset throw var
		bThrow = False;

		// Set our actor and drop
		A = CarryingActor;
		DropCarryingActor(True);

		// If we're throwing accurately
		if (A.bAccurateThrowing)
		{
			// Find our target
			aTarget = GetAccurateThrowTarget(A);
		}

		// If we have a target and are throwing accurately
		if ( aTarget != None && A.bAccurateThrowing)
		{
			// "Do it" -Emperor Palpatine, 19 BBY
			HarryAccurateThrowObject(A,aTarget,True,True);
		}
		// Otherwise, just throw normally
		else
		{
			// Set forward velocity
			V = Normal(Cam.vForward + vect(0.00,0.00,0.50));

			if ( A != None )
			{
				ThrowVelocity = A.ThrowVelocity;
				A.GotoState('stateBeingThrown');
			}
			else
			{
				ThrowVelocity = 400.0;
			}

			// Multiply our velocity by the intended throw velocity
			V *= ThrowVelocity;

			// Set actor's velocity
			A.Velocity = V;
		}
	}
}

function Actor GetAccurateThrowTarget (Actor A)
{
	local TargetPoint ClosestTP;
	local TargetPoint CurrTP;
	local float Dist;

	// Went with 65536 since no level goes larger than that. did i need to change it? nah
	ClosestDist = 65536.0;
	
	// For each TargetPoint
	foreach AllActors(Class'TargetPoint',CurrTP)
	{
		// If the target is in front of Harry
		if ( InFrontOfHarry(CurrTP) )
		{
			// Get the distance between Harry and the target
			Dist = VSize(CurrTP.Location - Location);

			// If its not too far away
			if ( Dist < ClosestDist )
			{
				// Set the closest TP to the current TP
				ClosestTP = CurrTP;

				// Set the closest dist to current dist
				ClosestDist = Dist;
			}
		}
	}

	return ClosestTP;
}

function HarryAccurateThrowObject (HPawn A, Actor Target, bool bCollideActors, bool bCollideWorld)
{
	local Vector Vel;

	// Set thrown actor properties
	A.SetPhysics(PHYS_Falling);
	A.SetCollision(bCollideActors);
	A.bCollideWorld = bCollideWorld;

	// Calculate velocity
	Vel = ComputeTrajectoryByTime(A.Location,Target.Location,0.5);

	// Set thrown actor velocity
	A.Velocity = Vel;

	// Set thrown actor state
	A.GotoState('stateBeingThrown');
}

state statePickupItem
{
	function BeginState()
	{
		CurrIdleAnimName = GetCurrIdleAnimName();
		PlayAnim(CurrIdleAnimName,,[TweenTime]0.4,[Type]HarryAnimType);
	}
	
	begin:
		// Halt horizontal velocity
		Velocity *= vect(0.00,0.00,1.00);
		Acceleration *= vect(0.00,0.00,1.00);
	
		// If we have a carried actor, turn to it
		if ( CarryingActor != None )
		{
			TurnTo(CarryingActor.Location * vect(1.00,1.00,0.00) + Location * vect(0.00,0.00,1.00));
		}

		// Prep Harry's animations
		HarryAnimType = AT_Combine;
		HarryAnimChannel.GotoState('statePickupItem');
		PlayAnim('Pickup',1.0,0.15,[Type]HarryAnimType);
		FinishAnim();
		
		// I wanna see how this feels without any delay
		//Sleep(0.5);

		// After picking up, return to walking state
		GotoState('PlayerWalking');
}

//-------------------------------------
// Potion Mixing
//-------------------------------------

function DoPotionMixingEnd()
{
	// Send done cutcue
	CutCue("MixingCauldronDone");

	// Disable stationary
	bKeepStationary = False;

	// Reset cauldron
	ActiveCauldron = None;

	// If we aren't captured, go to walking
	if ( !bIsCaptured )
	{
		GotoState('PlayerWalking');
	}
}

function bool IsMixingPotion()
{
	return IsInState('statePotionMixingBegin') || IsInState('statePotionMixingStir') || IsInState('statePotionMixingIdle');
}

state statePotionMixingBegin
{
	function BeginState()
	{
		// Make Harry stationary
		bKeepStationary = True;

		// Get and play anims
		CurrIdleAnimName = GetCurrIdleAnimName();
		LoopAnim(CurrIdleAnimName,,[TweenTime]0.4,,[Type]HarryAnimType);
	}
	
	begin:
		// Halt horizontal velocity
		Velocity *= vect(0.00,0.00,1.00);
		Acceleration *= vect(0.00,0.00,1.00);
}

state statePotionMixingStir
{
	function EndState()
	{
		// Stop mixing sound
		StopSound(StirPotion,SLOT_Interact);
	}
	
	begin:
		// Turn to the cauldron
		TurnToward(ActiveCauldron);

		// Loop mix anim
		LoopAnim('MixPotion',,,,[Type]HarryAnimType);

		// Not sure if I understand the separate var for this. I'm gonna try just using StirPotion.
		//SelectedMixingSound = PotionMixingSounds[Rand(PotionMixingSounds.Length)];
		StirPotion = PotionMixingSounds[Rand(PotionMixingSounds.Length)];

		// Get sound duration
		MixingSoundDuration = GetSoundDuration(StirPotion);

	loop:
		// Play sound
		PlaySound(StirPotion,SLOT_Interact);

		// Delay sound loop
		Sleep(MixingSoundDuration);
	
		// Loop
		goto ('Loop');
}

state statePotionMixingIdle
{
	begin:
		// Get and loop anim
		CurrIdleAnimName = GetCurrIdleAnimName();
		LoopAnim(CurrIdleAnimName,,[TweenTime]0.4,, [Type]HarryAnimType);
}

function int PotionsCount()
{
	local StatusGroup sg;
	local int Count;

	sg = managerStatus.GetStatusGroup(Class'StatusGroupPotions');
	Count = sg.GetStatusItem(Class'StatusItemWiggenwell').nCount;
	return Count;
}

function AddPotionsPoints (int iPoints)
{
  if ( iPoints == 0 )
  {
    return;
  }
  if ( (iPoints < 0) && (PotionsCount() == 0) )
  {
    return;
  }
  managerStatus.IncrementCount(Class'StatusGroupPotions',Class'StatusItemWiggenwell',iPoints);
}

//-------------------------------------
// Death
//-------------------------------------
function vector FindFaintLocation(); // We don't need this outside of the state, so let's keep a global dummy state to prevent any issues.

function KillHarry (bool bImmediateDeath)
{
	ClientMessage("argghhh I'm Dead!!!!   in KillHarry");

	// If there's a boss, end the encounter
	if ( BossTarget != None )
	{
		StopBossEncounter();
	}

	// If there's a boss and it has a victory event, do that event
	if ( (BossTarget != None) && (BossTarget.TrigEventWhenVictor != '') )
	{
		BossTarget.SendVictoriousTrigger();
	}
	else
	{
		// If we should instantly die, do that
		if(bImmediateDeath)
		{
			DeathType = DEATH_Instant;
		}

		// Go to death state
		GotoState('stateDead');
	}
}

function Died (Pawn Killer, name DamageType, Vector HitLocation)
{
	cm("Harry 'Died' function called by '" $ string(Killer) $ "' routing to TakeDamage...");

	// Kill harry
	TakeDamage(10000,None,Location,vect(0.00,0.00,0.00),'Crushed');
}

state stateDead
{
	ignores TakeDamage, AltFire, Tick, Fire;

	function BeginState()
	{
		// Default AnimRate to 1.0
		AnimRate = 1.0;

		// Halt horizontal velocity and all acceleration
		Velocity *= vect(0.0,0.0,1.0);
		Acceleration = vect(0.0,0.0,0.0);

		// If we should die fast, increase anim rate
		if ( LastDamageType == DEATH_Fast )
		{
			AnimRate = 1.5;
		}

		// Play faint anim
		PlayAnim(FaintAnim,AnimRate,0.2);

		// If fast death, skip ahead in the faint anim
		if ( DeathType == DEATH_Fast )
		{
			AnimFrame = 36.0 / 151.0;
		}
	}

	function vector FindFaintLocation()
	{ 
		// Might see if there's a better way to do this eventually
		local float  Distance;
		local vector ReverseDir;
		local vector CurrentLocation, LastLocation, SavedLocation, FaintDestination;
		local float  CheckDist;

		CheckDist = 70;  //70 seems to keep his head snug against the wall...
		
		// Set d to CheckDist
		Distance = CheckDist;

		// Save current location
		SavedLocation = Location;

		// Set n to the opposite of our rotation
		ReverseDir = -vector(rotation);

		// Set our destination to our location plus the inverted rotation times our CheckDist
		FaintDestination = Location + ReverseDir * CheckDist;

		// Set v to our location
		CurrentLocation = Location;

		do
		{
			LastLocation = CurrentLocation;
			CurrentLocation += ReverseDir * 10;
			MoveSmooth( ReverseDir * 10 );

			if( Location != CurrentLocation )
			{
				CurrentLocation = LastLocation;
				break;
			}

			Distance -= 10;
		} until( Distance <= 0 );

		if( Distance <= 0 )
		{
			Distance = 0;
			CurrentLocation = FaintDestination;
		}

		SetLocation( SavedLocation );

		//If d is 0, then there's full room to fall down, return where we're at
		//Actually, lets make it at least 20, so he falls more in place.
		Distance = Clamp(Distance, 20, MAXINT);

		//No see if there's room to move away from the obstruction.  We need to move away only as far as we have to.
		// d is already set to the amount we need to move.
		ReverseDir = -ReverseDir;
		CurrentLocation = Location;

		do
		{
			LastLocation = CurrentLocation;
			CurrentLocation += ReverseDir * 10;
			MoveSmooth( Reverse * 10 );

			if( Location != CurrentLocation )
			{
				CurrentLocation = LastLocation;
				break;
			}

			//See if we can go down.  We dont want to fall off a ledge.
			MoveSmooth( vect(0,0,-20) );

			if( CurrnetLocation.z - Location.z > 19 )
			{
				CurrentLocation = LastLocation;
				break;
			}

			SetLocation( CurrentLocation );


			Distance -= 10;
		} until( Distance <= 0 );

		SetLocation( vSave );

		return CurrentLocation;
	}

	begin:
		RotationRate.Yaw = 0;
		AccelRate = 70.0;

		// If not instant death
		if ( !DeathType == DEATH_Instant )
		{
			// Play death sound
			PlayDeathEmoteSound();

			// Two thirds of a second
			Sleep(0.67);

			// Move to faint location
			MoveTo(FindFaintLocation());
		}

		// Zero out velocity and acceleration
		Velocity = vect(0.00,0.00,0.00);
		Acceleration = vect(0.00,0.00,0.00);

		// If instant death, wait half a second
		if ( DeathType == DEATH_Instant )
		{
			Sleep(0.5);
		}
		else
		{
			// Otherwise, finish anim and then wait
			FinishAnim();
			Sleep(0.5);
		}

		// If slow death, wait an extra second and a half
		if ( DeathType == DEATH_Slow )
		{
			Sleep(1.5);
		}

		// Load game
		ConsoleCommand("LoadGame 0");
}

state stateInactive
{
	ignores DoJump, AltFire, Fire, TakeDamage;
}

//-------------------------------------
// Health
//-------------------------------------

function StatusItem GetHealthStatusItem()
{
	return (managerStatus.GetStatusItem(Class'StatusGroupHealth',Class'StatusItemHealth'));
}

function SetHealth (int Health)
{
	local StatusItem siHealth;

	siHealth = GetHealthStatusItem();

	if ( siHealth != None )
	{
		siHealth.SetCount(Health);
	}
	else
	{
		Log("Error getting health status item");
	}
}

function AddHealth (int Health)
{
	local StatusItem siHealth;

	siHealth = GetHealthStatusItem();

	if ( siHealth != None )
	{
		siHealth.IncrementCount(Health);
	}
	else
	{
		Log("Error getting health status item");
	}
}

function int GetHealthCount()
{
	local StatusItem siHealth;

	siHealth = GetHealthStatusItem();
	if ( siHealth != None )
	{
		return siHealth.nCount;
	}
	else
	{
		Log("Error getting health status item");
		return 0;
	}
}

function float GetHealth()
{
	return (GetHealthStatusItem().GetCountToCurrPotentialRatio());
}

//-------------------------------------
// StatusItems
//-------------------------------------

function AddGryffindorPoints (int iPoints)
{
	managerStatus.IncrementCount(Class'StatusGroupHousePoints',Class'StatusItemGryffindorPts',iPoints);
}

function int CollectibleCount(optional class<HCollectible> CollectibleClass)
{
	local class<StatusGroup> sgClass;
	local class<StatusItem> siClass;
	local StatusGroup sg;
	local int Count;

	// If no collectible class was given, default to Jellybeans
	if(CollectibleClass == None)
	{
		CollectibleClass = Class'Jellybean';
		sgClass = Class'StatusGroupJellybeans';
		siClass = Class'StatusItemJellybeans';
	}
	else
	{
		sgClass = CollectibleClass.Default.classStatusGroup;
		siClass = CollectibleClass.Default.classStatusItem;
	}

	sg = managerStatus.GetStatusGroup(sgClass);
	Count = sg.GetStatusItem(siClass).nCount;
	return Count;
}

function managerStatus_PickupItem (HProp Item)
{
	managerStatus.PickupItem(Item);
}

function AddJellyBeansPoints (int iPoints)
{
	ClientMessage("Adding Jellybeans:" $ string(iPoints));

	if ( iPoints == 0 || ((iPoints < 0) && (CollectibleCount() == 0)))
	{
		return;
	}

	managerStatus.IncrementCount(Class'StatusGroupJellybeans',Class'StatusItemJellybeans',iPoints);
}

/* I think this is unused.
state LookAtActor
{
  ignores  AltFire, Fire;
  
Begin:
  Enable('Tick');
  CurrIdleAnimName = GetCurrIdleAnimName();
  LoopAnim(CurrIdleAnimName);
Loop:
  Sleep(0.1);
  goto ('Loop');
}*/

/* Might remove this, DELETEME
function KeyDownEvent (int Key)
{
	local Characters Chars;

	if ( !HPConsole(Player.Console).bDebugMode )
	{
		return;
	}
	 
	if ( (Level.TimeSeconds - _LastKeyPressTime > 1.0) || (_iCurrentStringChar > 20) )
	{
		_iCurrentStringChar = 0;
		_CurrentString = "";
	}

	_LastKeyPressTime = Level.TimeSeconds;
	_CurrentString = _CurrentString $ Chr(Key);
	_iCurrentStringChar++;

	if ( _CurrentString ~= "ChadModeOn" )
	{
		TurnDebugModeOn();
	}

	if ( _CurrentString ~= "EricGetsFullHealth" )
	{
		GetHealthStatusItem().SetCountToMaxPotential();
	}
	else if ( _CurrentString ~= "EliJump" )
	{
		DoJump(0.0);
		Velocity = (vector(Rotation) + vect(0.00,0.00,1.00)) * 800;
	}
	else if ( _CurrentString ~= "PhillipsJump" )
	{
		DoJump(0.0);
		Velocity = (vector(Rotation) + vect(0.00,0.00,1.00)) * 500;
	}
	else if ( _CurrentString ~= "MelanieSword" )
	{
		ToggleUseSword();
		if ( bHarryUsingSword )
		{
			bMSword = True;
			makeTarget();
			SpellCursor.bSpellCursorAlwaysOn = True;
		}
		else {
			bMSword = False;
			SpellCursor.bSpellCursorAlwaysOn = False;
			SpellCursor.EnableEmission(False);
			TurnOffSpellCursor();
		}
	}
	else if ( _CurrentString ~= "GoyleMode" )
	{
		ConsoleCommand("GoyleMode");

		if ( bIsGoyle )
		{
			PlaySound(Sound'Pig_snort02',SLOT_None);
			Fatness = 210;
		}
		else
		{
			Fatness = 128;
		}
	}
	else if ( _CurrentString ~= "ChrisMode" )
	{
		if ( Opacity == 1.0 )
		{
			Opacity = 0.5;
		}
		else if ( Opacity == 0.5 )
		{
			Opacity = 0.0;
		}
		else
		{
			Opacity = 1.0;
		}
	} 
	else if ( _CurrentString ~= "FraserIsGod" )
	{
		bFraserMode =  !bFraserMode;
		if ( bFraserMode )
		{
			ClientMessage("Indeed, Fraser IS God...");
		} else {
			ClientMessage("Sad, Fraser is now NOT God.");
		}
	}
	else if ( _CurrentString ~= "BeatBoss" )
	{
		baseBoss(BossTarget).BeatBoss();
	}
	else if ( _CurrentString ~= "Quit" )
	{
		ConsoleCommand("exit");
	}
}*/

function StartBossEncounter (baseBoss Boss, bool in_bHarryShouldLockOntoBoss, bool in_bReverseInput, bool in_bKeepHarryFixed, bool in_bCanUseWeapon, Vector in_FixedFaceDirection, class<Spell> ForceSpellType, float in_SpellTargetRange, bool in_bDontShowBossMeter)
{
	local EnemyHealthManager EHealth;

	BossTarget = Boss;
	bLockedOnTarget = in_bHarryShouldLockOntoBoss;

	/*in_FixedFaceDirection.X != 0 || in_FixedFaceDirection.Y != 0 || in_FixedFaceDirection.Z != 0*/
	if (VSize(in_FixedFaceDirection) != 0)
	{
		bUseFixedFaceDirection = True;
		FixedFaceDirection = Normal(in_FixedFaceDirection);
	}

	if ( in_bHarryShouldLockOntoBoss )
	{
		bStrafe = 1;
	}
	else
	{
		bStrafe = 0;
	}

	if ( in_bReverseInput )
	{
		bReverseInput = True;
		bConstrainYaw = True;
	}

	if ( in_bKeepHarryFixed )
	{
		bKeepStationary = True;
	}

	bCanUseWeapon = in_bCanUseWeapon;

	if ( ForceSpellType != None && Weapon.IsA('baseWand') )
	{
		baseWand(Weapon).SetCurrentSpell(ForceSpellType,True);
		baseWand(Weapon).bAutoSelectSpell = False;
	}

	SpellCursor.SetLOSDistance(in_SpellTargetRange);

	if ( in_bHarryShouldLockOntoBoss && Boss != None )
	{
		if (  !Boss.SetCamMode() )
		{
			Cam.SetCameraMode(Cam.ECamMode.CM_Boss);
		}
	}

	if ( Boss != None )
	{
		Boss.StartBossEncounter();

		if ( !in_bDontShowBossMeter )
		{
			EHealth = EnemyHealthManager(FancySpawn(Class'EnemyHealthManager'));
			EHealth.Start(Boss);
		}
		else
		{
			Cam.SetDistance(100.0);
			Cam.SetZOffset(250.0);
			Cam.SetXOffset(-50.0);
		}
	}
}

function StopBossEncounter()
{
	BossTarget = None;
	bLockedOnTarget = False;
	bUseFixedFaceDirection = False;
	bStrafe = 0;
	bKeepStationary = False;
	bReverseInput = False;
	bConstrainYaw = False;

	ClientMessage("baseHarry.StopBossEncounter()");

	if( Weapon.IsA('baseWand'))
	{
		baseWand(Weapon).SetCurrentSpell(SPELL_None);
		baseWand(Weapon).bAutoSelectSpell = True;
	}
	
	bCanUseWeapon = True;
	bCastFastSpells = False;
	SpellCursor.SetLOSDistance(MapDefault.SpellCursorRange);
	GroundRunSpeed = MapDefault.GroundRunSpeed;
	GroundSpeed = GroundRunSpeed;
	Cam.SetCameraMode(Cam.ECamMode.CM_Standard);
}

function name HarryAtMapMarker()
{
	local MenuMapLocationMarker A;
	local name ClosestAtag;
	local float ClosestD;
	local float Distance;

	ClosestD = 1000000.0;

	foreach AllActors(Class'MenuMapLocationMarker',A)
	{
		Distance = VSize2D(A.Location - Location);
		if ( Distance < CollisionRadius + A.CollisionRadius && Location.Z > A.Location.Z - A.CollisionHeight - 80 && Location.Z < A.Location.Z + A.CollisionHeight + 80 )
		{
			if ( Distance < ClosestD )
			{
				ClosestD = Distance;
				ClosestAtag = A.Tag;
			}
		}
	}
	return ClosestAtag;
}

function InvertBroomPitch (bool Value)
{
	bInvertBroomPitch = Value;
	SaveConfig();
}

simulated function ClientPlaySound (Sound ASound, optional bool bInterrupt, optional bool bVolumeControl)
{
	local Actor SoundPlayer;
	local int Volume;

	if ( b3DSound )
	{
		if ( bVolumeControl && (AnnouncerVolume == 0) )
		{
			Volume = 0;
		}
		else
		{
			Volume = 1;
		}
	}
	else if ( bVolumeControl )
	{
		Volume = AnnouncerVolume;
	}
	else
	{
		Volume = 4;
	}

	LastPlaySound = Level.TimeSeconds;

	if ( ViewTarget != None )
	{
		SoundPlayer = ViewTarget;
	}
	else
	{
		SoundPlayer = self;
	}

	switch(Volume):
	{
		case 0: return;
		case 1: SoundPlayer.PlaySound(ASound,SLOT_None,16.0,bInterrupt); return;
		case 2: SoundPlayer.PlaySound(ASound,SLOT_Interface,16.0,bInterrupt); return;
		case 3: SoundPlayer.PlaySound(ASound,SLOT_Misc,16.0,bInterrupt); return;
		default: SoundPlayer.PlaySound(ASound,SLOT_Talk,16.0,bInterrupt);
	}
}

/* Unused I think.
function DebugState()
{
}
*/

function TurnDebugModeOn()
{
	HPConsole(Player.Console).bDebugMode = True;
}

function PreSetMovement()
{
	bCanJump = True;
	bCanWalk = True;
	bCanSwim = True;
	bCanFly = False;
	bCanOpenDoors = True;
	bCanDoSpecial = True;
}

function HarryKnockBack()
{
	PlayHurtEmoteSound();

	if ( CarryingActor != None )
	{
		DropCarryingActor();
	}

	HarryAnimChannel.DoKnockBack();
	Acceleration *= vect(0.00,0.00,1.00);
}

function TakeDamage (int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
	local Sound snd;
	local bool bPlayKnockBack;
	local bool bPlayHurtSound;
	local float fFlashScale;
	local StatusItem siWiggenPotion;
	local bool bFallDamage;
	local int FinalDamage;
	
	if ( (CarryingActor != None) && (CarryingActor == InstigatedBy) )
	{
		return;
	}

	LastDamageType = DamageType;
	
	bPlayHurtSound = True;
	FinalDamage = Damage * DifficultyMultiplier;

	fFlashScale = FClamp(FinalDamage,20.0,60.0);

	switch (DamageType)
	{
		case 'Falling':
			ClientFlash(-0.02 * fFlashScale,fFlashScale * vect(20.00,20.00,20.00));
			break;
		case 'Ectoplasma':
			if (  !bEctoFlashed )
			{
				bEctoFlashed = True;
				ClientFlash(-0.03 * fFlashScale,fFlashScale * vect(9.38,14.06,4.69));
			}
			break;
		case 'PoisonCloud':
			ClientFlash(-0.01171875 * fFlashScale,fFlashScale * vect(7.80,11.72,11.72));
			break;
		default:
	}

	// If Harry is not dead
	if ( !HarryIsDead() )
	{
		// If carrying an actor, drop it
		if ( CarryingActor != None )
		{
			DropCarryingActor();
		}

		// No throw
		bThrow = False;

		// If crushed or rolled over, and health > 0, play hurt sound
		bPlayHurtSound = ((DamageType == 'Crushed') || (DamageType == 'RolledOver')) && (GetHealthCount() > 0);

		// If zone pain or pit, instant die
		bInstantDeath = (DamageType == 'ZonePain') || (DamageType == 'pit');

		// If crushed or roll over, club die
		bClubDeath = (DamageType == 'Crushed') || (DamageType == 'RolledOver');

		// If rolled over, slow die
		bSlowDeath = DamageType == 'RolledOver';

		// If zone pain or pit, hide Harry
		bHidden = (DamageType == 'ZonePain') || (DamageType == 'pit');

		// Set final damage to 1000
		FinalDamage = 1000;
	}
	else
	{
		// If falling and final damage > 20, fall damage
		bFallDamage = (DamageType == 'Falling') && (FinalDamage > 20);

		// If we have ecto
		if ( EctoAmount > 0 || WebAmount > 0 )
		{
			// If we haven't played ecto knockback or the next up value of Ecto sound count >= 6
			if ( !bPlayedEctoKnockBack || ( ++EctoHurtSoundCount >= 6) )
			{
				// Set sound count to 0
				EctoHurtSoundCount = 0;
			}
			else
			{
				// Don't play hurt sound
				bPlayHurtSound = False;
			}
		}

		// If acid hit
		if ( DamageType == 'AcidHit' )
		{
			// If its been less than a third of a second since hit
			if ( TimeSinceLastAcidHit < 0.333 )
			{
				// Don't take damage
				FinalDamage = 0;
			}
			else
			{
				// Reset acid hit
				TimeSinceLastAcidHit = 0.0;
			}
		}

		// Play knockback
		bPlayKnockBack = True;

		// If we have ecto
		if ( EctoAmount > 0 )
		{
			// If played knockback
			if ( bPlayedEctoKnockBack )
			{
				// Don't play knockback
				bPlayKnockBack = False;
			}

			// If we didn't play knockback before, now we have
			bPlayedEctoKnockBack = True;
		}

		// If play knockback
		if ( bPlayKnockBack )
		{
			// Play knockback
			HarryAnimChannel.DoKnockBack();
		}

		// Halt horizontal acceleration
		Acceleration *= vect(0.00,0.00,1.00);
	}

	if ( bPlayHurtSound )
	{
		PlayHurtEmoteSound();
	}
	
	// If we have health and we're not in fraser mode
	if ( (GetHealthCount() > 0) &&  !bFraserMode )
	{
		ClientMessage("baseHarry: argghhh I'm HIT!!!!  " $ string(FinalDamage) $ " Difficulty:" $ string(Difficulty) $ " Type:" $ string(DamageType) $ " State:" $ string(GetStateName()));
		
		AddHealth(-FinalDamage);

		// If we now have no health
		if ( GetHealthCount() <= 0.0 )
		{
			// Get potion items
			siWiggenPotion = managerStatus.GetStatusItem(Class'StatusGroupPotions',Class'StatusItemWiggenwell');
			
			// If auto drink potions is on, and we don't have fall damage, instant death, club death, and we have potions
			if ( bAutoQuaff &&  !bFallDamage &&  !bInstantDeath &&  !bClubDeath && siWiggenPotion.nCount >= 1 )
			{
				// Give us a little health to drink
				AddHealth(1);

				// Drink potion
				DoDrinkWiggenwell();
			}
			else
			{
				// Time to die
				bHarryKilled = True;
			}
		}

		// If we're in a boss fight
		if ( BossTarget != None )
		{
			// If we died
			if ( bHarryKilled )
			{
				// Trigger player death event on boss
				BossTarget.OnEvent('HarryWasKilled');
			}
			else
			{
				// Trigger player hurt event on boss
				BossTarget.OnEvent('HarryWasHurt');
			}
		}
		
		// If we died
		if ( bHarryKilled )
		{
			// Actually die
			KillHarry(True);
		}
	}
	else
	{
		ClientMessage("baseHarry: argghhh I'm HIT!!!! (no damage) " $ string(FinalDamage) $ " Type:" $ string(DamageType) $ " State:" $ string(GetStateName()));
	}
}

exec function Summon (string ClassName)
{
	Summon(ClassName);
}

event Landed (Vector HitNormal)
{
	// When we land, go back to run speed
  	GroundSpeed = GroundRunSpeed;
}

function Falling()
{
	// Prevent us from falling faster than our ground jump speed
	local float FallSpeed;

	FallSpeed = VSize2D(Velocity);

	if ( FallSpeed > GroundJumpSpeed )
	{
		Velocity *= GroundJumpSpeed / FallSpeed;
	}

	GroundSpeed = GroundJumpSpeed;
}

simulated function PlayFootStep(optional float Volume)
{
	local Sound Step;
	local int Decision;
	local Texture HitTexture;
	local int Flags;
	local array<Sound> Footsteps;
	local float NoiseLevel;

	if (Volume <= 0)
	{
		Volume = 1000.0;
	}

	if ( FootRegion.Zone.bWaterZone )
	{
		PlaySound(WaterStep,SLOT_Interact,1.0,False,Volume,1.0);
		return;
	}
	else if ( Fatness > 200 )
	{
		PlaySound(Sound'Big_whomp2',SLOT_None,RandRange(0.4,0.7),False,500.0,RandRange(0.5,1.0));
		ShakeView(0.22,50.0,50.0);
		return;
	}

	if ( EctoAmount > 0 || WebAmount > 0)
	{
		Footsteps[0] = Sound'HAR_foot_ecto1';
		Footsteps[1] = Sound'HAR_foot_ecto2';
		Footsteps[2] = Sound'HAR_foot_ecto3';
	}
	else
	{
		HitTexture = TraceTexture(Location + vect(0.00,0.00,-128.00),Location,Flags);

		if ( HitTexture != None  && HitTexture != LastHitTexture)
		{
			LastHitTexture = HitTexture;

			switch (HitTexture.FootstepSound)
			{
				case FOOTSTEP_Stone:
					FootSteps = FootstepSoundSet.Default.StoneSteps;
					NoiseLevel = 10.0;
					break;
				case FOOTSTEP_Rug:
					FootSteps = FootstepSoundSet.Default.RugSteps;
					NoiseLevel = 2.0;
					break;
				case FOOTSTEP_Wood:
					FootSteps = FootstepSoundSet.Default.WoodSteps;
					NoiseLevel = 8.0;
					break;
				case FOOTSTEP_Cave:
					FootSteps = FootstepSoundSet.Default.CaveSteps;
					NoiseLevel = 10.0;
				case FOOTSTEP_Cloud:
					FootSteps = FootstepSoundSet.Default.CloudSteps;
					NoiseLevel = 1.0;
					break;
				case FOOTSTEP_Wet:
					FootSteps = FootstepSoundSet.Default.WetSteps;
					NoiseLevel = 8.0;
					break;
				case FOOTSTEP_Grass:
					FootSteps = FootstepSoundSet.Default.WetSteps;
					NoiseLevel = 2.0;
					break;
				case FOOTSTEP_Metal:
					FootSteps = FootstepSoundSet.Default.MetalSteps;
					NoiseLevel = 10.0;
					break;
				case FOOTSTEP_Snow:
					FootSteps = FootstepSoundSet.Default.SnowSteps;
					NoiseLevel = 3.0;
					break;
				case FOOTSTEP_Sand:
					FootSteps = FootstepSoundSet.Default.SandSteps;
					NoiseLevel = 4.0;
					break;
				case FOOTSTEP_Gravel:
					FootSteps = FootstepSoundSet.Default.GravelSteps;
					NoiseLevel = 5.0;
					break;
				case FOOTSTEP_lava:
					FootSteps = FootstepSoundSet.Default.LavaSteps;
					NoiseLevel = 1.0;
					break;
				case FOOTSTEP_drylava:
					FootSteps = FootstepSoundSet.Default.DryLavaSteps;
					NoiseLevel = 10.0;
					break;
				case FOOTSTEP_Rubble:
					FootSteps = FootstepSoundSet.Default.RubbleSteps;
					NoiseLevel = 10.0;
					break;
				case FOOTSTEP_MetalHollow:
					FootSteps = FootstepSoundSet.Default.MetalHollowSteps;
					NoiseLevel = 10.0;
					break;
				case FOOTSTEP_MetalPipe:
					FootSteps = FootstepSoundSet.Default.MetalPipeSteps;
					NoiseLevel = 10.0;
					break;
				case FOOTSTEP_Grate:
					FootSteps = FootstepSoundSet.Default.GrateSteps;
					NoiseLevel = 10.0;
					break;
				case FOOTSTEP_Dirt:
					FootSteps = FootstepSoundSet.Default.DirtSteps;
					NoiseLevel = 3.0;
					break;
				case FOOTSTEP_Glass:
					FootSteps = FootstepSoundSet.Default.GlassSteps;
					NoiseLevel = 7.0;
					break;
				case FOOTSTEP_BrokenGlass:
					FootSteps = FootstepSoundSet.Default.BrokenGlassSteps;
					NoiseLevel = 10.0;
					break;
				case FOOTSTEP_Ice:
					FootSteps = FootstepSoundSet.Default.IceSteps;
					NoiseLevel = 7.0;
					break;
				case FOOTSTEP_Forcefield:
					FootSteps = FootstepSoundSet.Default.ForcefieldSteps;
					NoiseLevel = 10.0;
					break;
				case FOOTSTEP_CreakyWood:
					FootSteps = FootstepSoundSet.Default.CreakyWoodSteps;
					NoiseLevel = 12.0;
					break;
				case FOOTSTEP_Marble:
					FootSteps = FootstepSoundSet.Default.MarbleSteps;
					NoiseLevel = 8.0;
					break;
				case FOOTSTEP_SqueakyFloor:
					FootSteps = FootstepSoundSet.Default.SqueakyFloorSteps;
					NoiseLevel = 10.0;
					break;
				case FOORSTEP_HollowWood:
					FootSteps = FootstepSoundSet.Default.HollowWoodSteps;
					NoiseLevel = 6.0;
					break;
				case FOOTSTEP_WetStone:
					FootSteps = FootstepSoundSet.Default.WetStoneSteps;
					NoiseLevel = 8.0;
					break;

				default:
					Footsteps = FootstepSoundSet.Default.StoneSteps;
					NoiseLevel = 10.0;
					break;
			}

			LastFootstepSounds = Footsteps;
		}
		else
		{
			Footsteps = LastFootstepSounds;
		}
	}
	
	Decision = Rand(Footsteps.Length);
	
	Step = Footsteps[Decision];

	PlaySound(Step,SLOT_None,1.0,False,Volume,0.9);

	if (NoiseLevel > 0.0)
	{
		HearHarryRecipient.PawnHearHarryNoise();
		MakeNoise(NoiseLevel);
	}
}

function PlayLandedSound()
{
	local float vol;

	if( AirTime < 1.0 )
	{
		vol = 0.3 * AirTime;
	}
	else
	{
		vol = 0.3 + (AirTime - 1.0) * 0.7/0.5;
	}
	
	if( Location.z < (fFallingZ - 40) )
	{
		vol *= 2;
	}

	PlayFootStep(vol);
}

function PlayHit (float Damage, Vector HitLocation, name DamageType, Vector Momentum)
{
}

function DoJump (optional float f)
{
	local float TmpJumpZ;
	local float VelocitySize;

	if ( bKeepStationary || bInDuelingMode || bCorraledByMover )
	{
		return;
	}

	if ( EctoAmount > 0 )
	{
		PlayAnim(HarryAnims[HarryAnimSet].Jump,,[TweenTime]0.1,[Type]HarryAnimType);
		HarryAnimChannel.DoEctoJump();
		return;
	}
	else if ( SleepyTimer > 0 )
	{
		PlayAnim(HarryAnims[HarryAnimSet].Jump,,[TweenTime]0.1,[Type]HarryAnimType);
		HarryAnimChannel.DoSleepyJump();
		return;
	}
	
	if ( Physics == PHYS_Walking )
	{
		PlayJumpEmoteSound();

		MakeNoise(0.1 * DifficultyMultiplier);

		MountDelta = Location;

		VelocitySize = VSize2D(Velocity);

		if ( VelocitySize > 0 )
		{
			PlayAnim(HarryAnims[HarryAnimSet].Jump2,,[TweenTime]0.1,[Type]HarryAnimType);
		}
		else 
		{
			PlayAnim(HarryAnims[HarryAnimSet].Jump,,[TweenTime]0.1,[Type]HarryAnimType);
		}		

		if ( VelocitySize > GroundJumpSpeed )
		{
			Velocity *= GroundJumpSpeed / VelocitySize;
		}

		GroundSpeed = GroundJumpSpeed;

		TmpJumpZ = JumpZ;

		Velocity.Z = Velocity.Z * 0.2 + TmpJumpZ;

		if ( (Base != Level) && (Base != None) )
		{
			Velocity += Base.Velocity;
		}

		SetPhysics(PHYS_Falling);
	}
}

function PlayHurtEmoteSound()
{
	local int RandIndex;

	if ( bIsGoyle )
	{
		RandIndex = Rand(GoyleHurtSounds.Length);
		PlaySound(GoyleHurtSounds[RandIndex],SLOT_Talk);
	}
	else
	{
		RandIndex = Rand(HurtSounds.Length);
		PlaySound(HurtSounds[RandIndex],SLOT_Talk);
	}
}

function PlayDeathEmoteSound()
{
	local int RandIndex;

	if ( bIsGoyle )
	{
		RandIndex = Rand(GoyleDieSounds.Length);
		PlaySound(GoyleDieSounds[RandIndex],SLOT_Talk,0.75);
	} 
	else
	{
		RandIndex = Rand(DieSounds.Length);
		PlaySound(DieSounds[RandIndex],SLOT_Talk,0.75);
	}
}

function PlayLandedEmoteSound()
{
	local int RandIndex;

	if ( bIsGoyle )
	{
		RandIndex = Rand(GoyleLandedSounds.Length);
		PlaySound(GoyleLandedSounds[RandIndex],SLOT_Talk);
	}
	else
	{
		RandIndex = Rand(GoyleLandedSounds.Length);
		PlaySound(GoyleLandedSounds[RandIndex],SLOT_Talk);
	}
}

function PlayFallingPullupEmoteSound()
{
	local int RandIndex;

	if ( bIsGoyle )
	{
		RandIndex = Rand(GoyleFallingPullupSounds.Length);
		PlaySound(GoyleFallingPullupSounds[RandIndex],SLOT_Talk);
	}
	else
	{
		RandIndex = Rand(FallingPullupSounds.Length);
		PlaySound(FallingPullupSounds[RandIndex],SLOT_Talk);
	}
}

function PlayEasyPullupEmoteSound()
{
	local int RandIndex;

	if ( bIsGoyle )
	{
		RandIndex = Rand(GoyleEasyPullupSounds.Length);
		PlaySound(GoyleEasyPullupSounds[RandIndex],SLOT_Talk);
	}
	else
	{
		RandIndex = Rand(EasyPullupSounds.Length);
		PlaySound(EasyPullupSounds,SLOT_Talk);
	}
}

function PlayHardPullupEmoteSound()
{
	local int RandIndex;

	if ( bIsGoyle )
	{
		RandIndex = Rand(GoyleHardPullupSounds.Length);
		PlaySound(GoyleHardPullupSounds[RandIndex],SLOT_Talk);
	}
	else
	{
		RandIndex = Rand(HardPullupSounds.Length);
		PlaySound(HardPullupSounds[RandIndex],SLOT_Talk);
	}
}

function PlayFallDeepEmoteSound()
{
	local int RandIndex;

	if ( bIsGoyle )
	{
		RandIndex = Rand(GoyleFallDeepSounds.Length);
		PlaySound(GoyleFallDeepSounds[RandIndex],SLOT_Talk);
	}
	else
	{
		RandIndex = Rand(FallDeepSounds.Length);
		PlaySound(FallDeepSounds[RandIndex],SLOT_Talk);
	}
}

function PlayJumpEmoteSound()
{
	local int RandIndex;

	if ( bIsGoyle )
	{
		RandIndex = Rand(GoyleJumpEmoteSounds.Length);
		PlaySound(GoyleJumpEmoteSounds[RandIndex],SLOT_Talk);
	} 
	else 
	{
		// why lol
		//PlayOwnedSound(JumpSound,SLOT_Talk,1.5,False,1200.0,1.0);

		RandIndex = Rand(JumpEmoteSounds.Length);
		PlaySound(JumpEmoteSounds[RandIndex],SLOT_Talk);
	}
}

function PlayIncantationEmoteSound (class<baseSpell> SpellType)
{
	local string IncantationString;
	local array<string> IncantationArray;
	local int RandIndex;

	if ( bIsGoyle )
	{
		IncantationArray = SpellType.Default.GoyleIncants;
	}
	else
	{
		IncantationArray = SpellType.Default.HarryIncants;
	}

	if(IncantationArray != None)
	{
		RandIndex = Rand(IncantationArray.Length);
		IncantationString = IncantationArray[RandIndex];

		if ( IncantationString != "" )
		{
			PlaySound(Sound(DynamicLoadObject("AllDialog." $ SpellIncantation,Class'Sound')),SLOT_Talk,0.75,True);
		}
	}
}

/* TODO: Move to baseWand
function PlaySpellCastSound (ESpellType SpellType)
{
  local Sound SpellSound;

  switch (SpellType)
  {
    case SPELL_Alohomora:
    SpellSound = Sound'cast_Alohomora';
    break;
    case SPELL_Flipendo:
    SpellSound = Sound'cast_Flipendo';
    break;
    case SPELL_Lumos:
    SpellSound = Sound'cast_Lumos';
    break;
    case SPELL_Skurge:
    SpellSound = Sound'cast_Skurge';
    break;
    case SPELL_Diffindo:
    SpellSound = Sound'cast_Diffindo';
    break;
    case SPELL_Spongify:
    SpellSound = Sound'cast_Spongify';
    break;
    case SPELL_Rictusempra:
    case SPELL_DuelRictusempra:
    SpellSound = Sound'cast_Rictusempra';
    break;
    case SPELL_DuelMimblewimble:
    SpellSound = Sound'cast_Mimblewimble';
    break;
    case SPELL_DuelExpelliarmus:
    SpellSound = None;
    break;
    default:
  }
  if ( SpellSound != None )
  {
    PlaySound(SpellSound,SLOT_None);
  }
}
*/

function PlayTurning()
{
  PlayAnim(HarryAnims[HarryAnimSet].StrafeLeft,,,[Type]HarryAnimType);
}

function TweenToRunning (float TweenTime)
{
	local Vector X;
	local Vector Y;
	local Vector Z;
	local Vector Dir;

	GetAxes(Rotation,X,Y,Z);
	Dir = Normal(Acceleration);

	if ( (Dir Dot X < 0.75) && (Dir != vect(0,0,0)) )
	{
		if ( Dir Dot X < -0.75 )
		{
			LoopAnim(HarryAnims[HarryAnimSet].WalkBack,0.9,[TweenTime]TweenTime,,[Type]HarryAnimType);
		}
		else if ( Dir Dot Y > 0 )
		{
			LoopAnim(HarryAnims[HarryAnimSet].StrafeRight,0.9,[TweenTime]TweenTime,,[Type]HarryAnimType);
		}
		else
		{
			LoopAnim(HarryAnims[HarryAnimSet].StrafeLeft,0.9,[TweenTime]TweenTime,,[Type]HarryAnimType);
		}
	}
	else
	{
		LoopAnim(HarryAnims[HarryAnimSet].run,0.9,[TweenTime]TweenTime,,[Type]HarryAnimType);
	}
}

function PlayRunning()
{
	TweenToRunning(0.0);
}

function PlayInAir()
{
	LoopAnim(AnimFalling,,[TweenTime]0.4,,[Type]HarryAnimType);
	ClientMessage(" animFalling = " $ string(AnimFalling));
}

function PlayIdle()
{
	if ( Mesh == None )
	{
		return;
	}
	CurrIdleAnimName = GetCurrIdleAnimName();
	LoopAnim(CurrIdleAnimName,0.8,0.25,,HarryAnimType);
}

function PlayWaiting()
{
	if ( Mesh == None )
	{
		return;
	}

	WaitingCount++;

	if ( WaitingCount < 3 )
	{
		CurrIdleAnimName = GetCurrIdleAnimName();
		LoopAnim(CurrIdleAnimName,0.40 + 0.40 * FRand(),0.25,,HarryAnimType);
		return;
	}

	if ( FRand() < 0.5 )
	{
		CurrIdleAnimName = GetCurrIdleAnimName();
		LoopAnim(CurrIdleAnimName,0.40 + 0.40 * FRand(),0.25,,HarryAnimType);
	}
	else
	{
		WaitingCount = 0;
		CurrFidgetAnimName = GetCurrFidgetAnimName();

		if ( BossTarget != None )
		{
			PlayAnim('look_frantic',1.0,0.2,HarryAnimType);
		}
		else
		{
			PlayAnim(CurrFidgetAnimName,0.5 + 0.5 * FRand(),0.3,HarryAnimType);
		}
	}
}

function TweenToWaiting (float TweenTime)
{
	if (!PlayingFidgetAnimation(AnimSequence) && AnimSequence != 'look_frantic')
	{
		CurrIdleAnimName = GetCurrIdleAnimName();
		LoopAnim(CurrIdleAnimName,,[TweenTime]TweenTime,,[Type]HarryAnimType);CurrIdleAnimName = GetCurrIdleAnimName();
		LoopAnim(CurrIdleAnimName,,[TweenTime]TweenTime,,[Type]HarryAnimType);
	}
}

// TODO: Move to basewand
function Cast()
{
  local Actor BestTarget;
  //local Actor HitActor;
  local Rotator defaultAngle;
  local Rotator checkAngle;
  local Pawn hitPawn;
  local Vector objectDir;
  local int bestYaw;
  local int tempYaw;
  local int defaultYaw;
  local float bestDist;
  local float TempDist;
  local string SpellIncantation;

  //log("Cast!");
  
  if ( fTimeAfterHit > 0 )
  {
    if ( (fTimeAfterHit > 1.0) && bInDuelingMode )
    {
      if ( CurrentDuelSpell == 0 )
      {
        switch (Rand(6))
        {
          case 0:
          SpellIncantation = "PC_Hry_HryDuelMW_04";
          break;
          case 1:
          SpellIncantation = "PC_Hry_HryDuelMW_05";
          break;
          case 2:
          SpellIncantation = "PC_Hry_HryDuelMW_12";
          break;
          case 3:
          SpellIncantation = "PC_Hry_HryDuelMW_13";
          break;
          case 4:
          SpellIncantation = "PC_Hry_HryDuelMW_14";
          break;
          case 5:
          SpellIncantation = "PC_Hry_HryDuelMW_15";
          break;
          default:
        }
      } else //{
        if ( CurrentDuelSpell == 1 )
        {
          switch (Rand(6))
          {
            case 0:
            SpellIncantation = "PC_Hry_HryDuelMW_06";
            break;
            case 1:
            SpellIncantation = "PC_Hry_HryDuelMW_07";
            break;
            case 2:
            SpellIncantation = "PC_Hry_HryDuelMW_08";
            break;
            case 3:
            SpellIncantation = "PC_Hry_HryDuelMW_09";
            break;
            case 4:
            SpellIncantation = "PC_Hry_HryDuelMW_10";
            break;
            case 5:
            SpellIncantation = "PC_Hry_HryDuelMW_11";
            break;
            default:
          }
        } 
		  else //{
          if ( CurrentDuelSpell == 2 )
          {
            switch (Rand(3))
            {
              case 0:
              SpellIncantation = "PC_Hry_HryDuelMW_01";
              break;
              case 1:
              SpellIncantation = "PC_Hry_HryDuelMW_02";
              break;
              case 2:
              SpellIncantation = "PC_Hry_HryDuelMW_03";
              break;
              default:
            }
          }
        //}
      //}
      if ( SpellIncantation != "" )
      {
        PlaySound(Sound(DynamicLoadObject("AllDialog." $ SpellIncantation,Class'Sound')),SLOT_Talk,0.75,True);
      }
    }
    return;
  }
  defaultAngle = Rotation;
  defaultAngle.Pitch = 0;
  defaultYaw = defaultAngle.Yaw;
  defaultYaw = defaultYaw & 65535;
  if ( defaultYaw > 32767 )
  {
    defaultYaw = defaultYaw - 65536;
  }
  BestTarget = None;
  if ( BossTarget != None )
  {
    Target = BossTarget;
  }
  if (  !baseWand(Weapon).bAutoSelectSpell )
  {
    baseWand(Weapon).CastSpell(BossTarget,vect(0.00,0.00,0.00));
    baseWand(Weapon).LastCastedSpell.SeekSpeed *= 0.25;
  } else //{
    if ( bInDuelingMode )
    {
      baseWand(Weapon).CastSpell(DuelOpponent,,DuelSpells[CurrentDuelSpell]);
      baseWand(Weapon).LastCastedSpell.SetSpellDirection(SpellCursor.Location - baseWand(Weapon).LastCastedSpell.Location);
    } else //{
      if ( bHarryUsingSword )
      {
        baseWand(Weapon).CastSpell(None,,Class'spellSwordFire');
      } else //{
        if ( SpellCursor.IsLockedOn() )
        {
          baseWand(Weapon).CastSpell(SpellCursor.aCurrentTarget,SpellCursor.vTargetOffset);
        } else {
          ClientMessage("Harry Can't cast a spell... SpellCursor.IsLockedOn = " $ string(SpellCursor.IsLockedOn()) $ " CurrentSpell = " $ string(baseWand(Weapon).CurrentSpell));
        //}
      //}
    //}
	}
  TurnOffSpellCursor();
}

/* function Fire (optional float f)
{
  if ( Weapon != None && bJustFired == False )
  {
    Weapon.bPointing = True;
  }
  bJustFired = True;
}

exec function AltFire (optional float f)
{
  local Vector V;
  local Rotator R;

  if ( HarryAnimChannel.IsCarryingActor() )
  {
    if ( bThrow == False && IsInState('PlayerWalking') )
    {
      ClientMessage("Throw!");
      HarryAnimChannel.GotoStateThrow();
      bThrow = True;
    }
  } 
  else 
  {
    if ( (Weapon != None) && (CarryingActor == None) &&  !bIsAiming )
    {
      Weapon.bPointing = True;
      StartAiming(bHarryUsingSword);
    }
  }
} */

exec function AltFire (optional float f)
{
	if ( HarryAnimChannel.IsCarryingActor() )
	{
		if ( bThrow == False && IsInState('PlayerWalking'))
		{
			HarryAnimChannel.GotoStateThrow();
			bThrow = True;
		}
	}
	else
	{
		if ( Weapon.IsA('HWeapon') && !HarryAnimChannel.IsInState('stateCasting') )
		{
			HWeapon(Weapon).PrimaryFireAction();
		}
	}
}

event Mount (Vector Delta)
{
  DropCarryingActor();
  Destination = Location + Delta;
  MountBase = Base;
  GotoState('Mounting');
}

state Mounting
{
  ignores AltFire, Mount;
  
  function BeginState()
  {
    //DebugState();
    bFallingMount = Physics == PHYS_Falling;
    Velocity = vect(0.00,0.00,0.00);
    Acceleration = vect(0.00,0.00,0.00);
    SetPhysics(PHYS_Projectile);
    SetBase(MountBase);
  }
  
  //UTPT didn't add this for some reason -AdamJD
  function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
  {
	Global.ProcessMove(DeltaTime, vect(0,0,0), DodgeMove, DeltaRot);
  }
  
  begin:
  Velocity = vect(0.00,0.00,0.00);
  Acceleration = vect(0.00,0.00,0.00);
  DesiredRotation.Yaw = rotator(Vec(Destination.X,Destination.Y,Location.Z) - Location).Yaw;
  DesiredRotation.Pitch = 0;
  MountDelta = Destination - Location;
  MountDelta -= Normal(MountDelta * vect(1.00,1.00,0.00)) * 30;
  if ( bFallingMount && (MountDelta.Z >= 80 * DrawScale) )
  {
    MountDelta.Z -= 82 * DrawScale;
    PlayAnim('climb96end',,0.2,,[RootBone] 'Move');
    PlayFallingPullupEmoteSound();
  } 
  else if ( MountDelta.Z < 48 * DrawScale )
  {
    MountDelta.Z -= 32 * DrawScale;
    PlayAnim('climb32',1.0,,,[RootBone] 'Move');
    PlayEasyPullupEmoteSound();
  } 
  else if ( MountDelta.Z < 80 * DrawScale )
  {
    MountDelta.Z -= 64 * DrawScale;
    PlayAnim('climb64',,,,[RootBone] 'Move');
    PlayHardPullupEmoteSound();
  } 
  else 
  {
    MountDelta.Z -= 96 * DrawScale;
    PlayAnim('climb96start',,,,[RootBone] 'Move');
  }
  GotoState('MountFinish');
}

state MountFinish
{
  ignores AltFire, Mount;
  
  event PlayerTick (float DeltaTime)
  {
    local Vector V;
  
    Velocity = vect(0.00,0.00,0.00);
    Acceleration = vect(0.00,0.00,0.00);
    V = MountDelta * DeltaTime * AnimRate;
    V *= vect(0.00,0.00,1.00);
    Move(V);
    ViewRotation = Rotation;
  }
  
  function BeginState()
  {
    //DebugState();
    SetCollisionSize(CollisionRadius * 0.5,CollisionHeight * 0.5,CollisionHeight * 0.5);
    PrePivot.Z -= CollisionHeight;
  }
  
  //UTPT didn't add this for some reason -AdamJD
  function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
  {
	Global.ProcessMove(DeltaTime, vect(0,0,0), DodgeMove, DeltaRot);
  }
 
  function EndState()
  {
    PrePivot.Z += CollisionHeight;
    SetCollisionSize(CollisionRadius * 2,CollisionHeight * 2,0.0);
  }
  
  begin:
  if ( AnimSequence == 'climb96start' )
  {
    MountDelta *= 0.5;
    FinishAnim();
    PlayAnim('climb96end',,,,[RootBone] 'Move');
    PlayHardPullupEmoteSound();
  }
  FinishAnim();
  SetPhysics(PHYS_Walking);
  CurrIdleAnimName = GetCurrIdleAnimName();
  PlayAnim(CurrIdleAnimName,1.0,0.2);
  GotoState('PlayerWalking');
}

state statePickBitOfGoyle
{
	begin:
		Velocity = vect(0.00,0.00,0.00);
		Acceleration = vect(0.00,0.00,0.00);
		StopAllMusic(0.0);
		PlayMusic("sm_Ingredient_Success_Music",0.0);
		PlayAnim('PickBitOfGoyle',1.0,0.2);
		FinishAnim();
		bFinishPickBitOfGoyle = True;
		GotoState('PlayerWalking');
}

state ChessDeath
{
	begin:
		//DebugState();
		KillHarry(True);
}

function DoCelebrateCardSet (bool bCelebrateBronzeIn)
{
  bCelebrateBronze = bCelebrateBronzeIn;
  GotoState('CelebrateCardSet');
}

state CelebrateCardSet
{
  event BeginState()
  {
    nCelebrateProgress = 0;
  }
  
  event EndState()
  {
    if ( nCelebrateProgress < 1 )
    {
      if ( bCelebrateBronze )
      {
        PlaySound(Sound'health_boost1');
        GetHealthStatusItem().IncrementCountPotential(StatusItemHealth(GetHealthStatusItem()).nUnitsPerIcon);
      }
    }
    if ( nCelebrateProgress < 2 )
    {
      Cam.SetCameraMode(Cam.ECamMode.CM_Transition);
    }
  }
  begin:
	  Cam.SetCameraMode(Cam.ECamMode.CM_CutScene);
	  Cam.CamTarget.SetAttachedTo(self);
	  Cam.SetSyncPosWithTarget(True);
	  Cam.SetSyncRotWithTarget(False);
	  Cam.SetZOffset(25.0);
	  Cam.SetPitch(-6000.0);
	  Cam.SetDistance(100.0);
	  Cam.SetRotStepYaw(-12288.0);
	  PlayAnim('celebrate',1.0,0.2);
	  if ( bCelebrateBronze )
	  {
		Sleep(1.5);
		PlaySound(Sound'health_boost1');
		GetHealthStatusItem().IncrementCountPotential(StatusItemHealth(GetHealthStatusItem()).nUnitsPerIcon);
	  }
	  nCelebrateProgress = 1;
	  FinishAnim();
	  Cam.SetCameraMode(Cam.ECamMode.CM_Transition);
	  nCelebrateProgress = 2;
	  while ( Cam.CameraMode == Cam.ECamMode.CM_CutScene )
	  {
		Sleep(0.1);
	  }
	  GotoState('PlayerWalking');
}

function Bump (Actor Other)
{
  Super.Bump(Other);
  PickupActor(Other);
}

function StartAimSoundFX()
{
  if ( bInDuelingMode && (CurrentDuelSpell == 2) )
  {
    return;
  }
  PlaySound(Sound'Spell_aim',SLOT_Misc);
  if ( bInDuelingMode && (CurrentDuelSpell == 1) )
  {
    PlaySound(Sound'Dueling_MIM_buildup',SLOT_Interact);
  } else {
    PlaySound(Sound'spell_loop_nl',SLOT_Interact);
  }
}

function StopAimSoundFX()
{
  StopSound(Sound'spell_dud',SLOT_Misc);
  if ( bInDuelingMode && (CurrentDuelSpell == 1) )
  {
    StopSound(Sound'Dueling_MIM_buildup',SLOT_Interact);
  } else {
    StopSound(Sound'spell_loop_nl',SLOT_Interact);
  }
}

function StartAiming (bool in_bHarryUsingSword)
{
}

/*
function StopAiming()
{
  if ( CarryingActor == None )
  {
    HarryAnimChannel.GotoState('stateIdle');
    HarryAnimType = 0;
    TurnOffCastingVars();
    TurnOffSpellCursor();
    if ( bHarryUsingSword )
    {
      StopSound(Sound'sword_buildup',3);
    }
  }
}
*/

function StopAiming()
{
	//ClientMessage("StopAiming()");

	//Dont even bother trying to do this if you're carrying something.  You wont be aiming FOR SURE.
	if( CarryingActor == none )
	{
		HarryAnimChannel.GotoState( 'stateIdle' );
		HarryAnimType = AT_Replace;
		TurnOffCastingVars();
		TurnOffSpellCursor();
		
		if ( bHarryUsingSword )
		{
		  StopSound(Sound'sword_buildup',SLOT_Interact);
		}
	}
}

function TurnOffCastingVars()
{
  bIsAiming = False;
  bIsAimingWithCharge = False;
}

function TurnOffSpellCursor()
{
  bIsAimingWithCharge = False;
  baseWand(Weapon).StopChargingSpell();
  SpellCursor.TurnTargetingOff();
  GroundSpeed = GroundRunSpeed;
}

/* function TurnOnCastingVars (bool in_bHarryUsingSword)
{
  bIsAiming = True;
  bIsAimingWithCharge = True;
  if ( bInDuelingMode )
  {
    if ( CurrentDuelSpell != 2 )
    {
      baseWand(Weapon).StartChargingSpell(True,in_bHarryUsingSword,DuelSpells[CurrentDuelSpell]);
    } else {
      baseWand(Weapon).StartChargingSpell(False,in_bHarryUsingSword,DuelSpells[CurrentDuelSpell]);
    }
  } else {
    baseWand(Weapon).StartChargingSpell(False,in_bHarryUsingSword);
  }
} */

function bool PlayerIsAiming()
{
  return bIsAiming;
}

function bool PlayerIsAimingWithCharge()
{
  return bIsAimingWithCharge;
}

function PlayerTick (float dtime)
{
  //cm("Current state is " $ GetStateName());

  if ( fTimeAfterShield > 0 )
  {
    fTimeAfterShield -= dtime;
  }
  if ( bInDuelingMode && (fTimeAfterShield <= 0) && baseWand(Weapon).fxChargeParticles.IsA('Exep_Shield') )
  {
    baseWand(Weapon).StartGlowingWand(DuelSpells[CurrentDuelSpell]);
  }
  if ( fTimeAfterHit > 0 )
  {
    fTimeAfterHit -= dtime;
  }
  TimeSinceLastAcidHit += dtime;
  if ( CurrentAnimHasFootStepSounds() )
  {
    if ( AnimSequence != 'run' )
    {
      if ( (AnimFrame >= 0.5) && (LastAnimFrame < 0.5) || AnimFrame < LastAnimFrame )
      {
        PlayFootStep();
      }
    } else {
      if ( (AnimFrame < LastAnimFrame) || (AnimFrame >= 0.25) && (LastAnimFrame < 0.25) || (AnimFrame >= 0.5) && (LastAnimFrame < 0.5) || (AnimFrame >= 0.75) && (LastAnimFrame < 0.75) )
      {
        PlayFootStep();
      }
    }
  }
  LastAnimFrame = AnimFrame;
  ViewRotation = BaseCam(ViewTarget).rCurrRotation;
  ViewShake(dtime);
  if ( ViewTarget != None )
  {
    BaseCam(ViewTarget).rExtraRotation = ViewRotation - BaseCam(ViewTarget).rCurrRotation;
  }
  if (  !bDisplayedFirstErrorMessages )
  {
    bDisplayedFirstErrorMessages = True;
    DisplayFirstErrorMessages();
  }
}

function DisplayFirstErrorMessages()
{
  local Actor A;
  local Actor a2;

  if ( HPConsole(Player.Console).bDebugMode )
  {
    foreach AllActors(Class'Actor',A)
    {
      if ( (A.CutName != "") && (A.IsA('CutScene') || A.IsA('CutCameraPos') || A.IsA('CutMark')) )
      {
        foreach AllActors(Class'Actor',a2)
        {
          if ( (a2.IsA('CutScene') || a2.IsA('CutCameraPos') || a2.IsA('CutMark')) && (a2 != A) && (a2.CutName ~= A.CutName) )
          {
            ClientMessage("**** ERROR: Actor:" $ string(a2.Name) $ " has same CutName as " $ string(A.Name) $ ".  CutName:" $ A.CutName);
          }
        }
      }
    }
  }
}

function bool CurrentAnimHasFootStepSounds()
{
  switch (AnimSequence)
  {
    case 'run':
    case 'runback':
    case 'StrafeLeft':
    case 'StrafeRight':
    case 'Walk':
    case 'ectowalk':
    case 'EctoWalkback':
    case 'ectostraferight':
    case 'ectostrafeleft':
    case 'SwordRun':
    case 'SwordRunback':
    case 'SwordStrafeRight':
    case 'SwordStrafeLeft':
    case 'duel_run':
    case 'duel_runback':
    case 'duel_strafe_right':
    case 'duel_strafe_left':
    return True;
    default:
  }
  return False;
}

/*
function bool PlayingIdleAnimation (name animseqname)
{
  local string AnimName;
  local int I;
  local name nm;

  I = 1;
  if ( I <= 16 )
  {
    AnimName = "idle_" $ string(I);
    nm = StringToAnimName(AnimName);
    if ( nm == animseqname )
    {
      return True;
    }
    I++;
    goto JL0007;
  }
  return False;
}
*/

function bool PlayingIdleAnimation(name animseqname)
{
	local string animName;
	local int	i;
	local name	nm;

	for ( i = 1; i <= 16; i++)
	{
		animName = "idle_" $i;
		nm = StringToAnimName(animName);
		if(nm == animseqname)
			return true;
	}

	return false;
}

/*
function bool PlayingFidgetAnimation (name animseqname)
{
  local string AnimName;
  local int I;
  local name nm;

  I = 1;
  if ( I <= 16 )
  {
    AnimName = "fidget_" $ string(I);
    nm = StringToAnimName(AnimName);
    if ( nm == animseqname )
    {
      return True;
    }
    I++;
    goto JL0007;
  }
  return False;
}
*/

function bool PlayingFidgetAnimation(name animseqname)
{
	local string animName;
	local int	i;
	local name	nm;

	for ( i = 1; i <= 16; i++)
	{
		animName = "fidget_" $i;
		nm = StringToAnimName(animName);
		if(nm == animseqname)
			return true;
	}

	return false;
}

function name MyGetAnimGroup (name animseqname)
{
  if ( PlayingIdleAnimation(animseqname) )
  {
    return 'Waiting';
  }
  if ( PlayingFidgetAnimation(animseqname) )
  {
    return 'Waiting';
  }
  if ( AnimSequence == 'look_frantic' )
  {
    return 'Waiting';
  }
  return 'None';
}

function SetNewMesh()
{
  if ( bIsGoyle && (Mesh == SkeletalMesh'skharryMesh') )
  {
    Mesh = SkeletalMesh'skGoyleMesh';
    DrawScale = 1.14999998;
  }
  if (  !bIsGoyle && (Mesh == SkeletalMesh'skGoyleMesh') )
  {
    Mesh = SkeletalMesh'skharryMesh';
    DrawScale = 1.0;
  }
}

function SpawnParticles (Class<ParticleFX> Particles)
{
  Spawn(Particles,,,Location,rot(0,0,0));
}

function AutoHitAreaEffect (float fRadius)
{
	local HPawn Pawn;
	//local spellTrigger Trigger;
	local spellTrigger spTrigger;

	foreach AllActors(Class'HPawn',Pawn)
	{
		if ( VSize(Pawn.Location - Location) < fRadius )
		{
			if ( Pawn.eVulnerableToSpell != ESpellType.SPELL_None )
			{
				Pawn.CallHandleSpellBySpellType(Pawn.eVulnerableToSpell,Pawn.Location);
			}
			if ( (Pawn.Owner == None) && (Pawn.IsA('Jellybean') || Pawn.IsA('WizardCardIcon')) )
			{
				Pawn.SetPhysics(PHYS_Falling);
				Pawn.Velocity = Vec(0.0,0.0,300.0) + Normal(Pawn.Location - Location) * 100 * FRand();
			}
		}	
	}
	foreach AllActors(Class'spellTrigger',spTrigger)
	{
		if ( spTrigger.eVulnerableToSpell != SPELL_None && (VSize(spTrigger.Location - Location) < fRadius) )
		{
			spTrigger.Activate(self,self);
		}
	}
}

/*
function CreateSpongifyEffects()
{
  local int I;

  return;
  if ( SpongifyFX[0] == None )
  {
    SpongifyFX[0] = Spawn(Class'SpellVoldTrackingFX',self);
    SpongifyFX[0].AttachToOwner('bip01 R Foot');
    if ( SpongifyFX[1] == None )
    {
      SpongifyFX[1] = Spawn(Class'SpellVoldTrackingFX',self);
      SpongifyFX[1].AttachToOwner('bip01 L Foot');
    }
  }
  I = 0;
  if ( I < 2 )
  {
    SpongifyFX[I].bEmit = True;
    I++;
    goto JL0071;
  }
}
*/

function CreateSpongifyEffects()
{
	local int   i;

	return;

	if( SpongifyFX[0] == none )
		{ SpongifyFX[0] = spawn( class'SpellVoldTrackingFX', self );       SpongifyFX[0].AttachToOwner( 'Bip01 R Foot' );
	if( SpongifyFX[1] == none )
		{ SpongifyFX[1] = spawn( class'SpellVoldTrackingFX', self );       SpongifyFX[1].AttachToOwner( 'Bip01 L Foot' ); }}

	for( i = 0; i < NUM_SPONGIFY_FX; i++ )
		SpongifyFX[i].bEmit = true;
}

/*
function StopSpongifyEffects()
{
  local int I;

  I = 0;
  if ( I < 2 )
  {
    SpongifyFX[I].bEmit = False;
    I++;
    goto JL0007;
  }
}
*/

function StopSpongifyEffects()
{
	local int   i;

	for( i = 0; i < NUM_SPONGIFY_FX; i++ )
		SpongifyFX[i].bEmit = false;
}

state PlayerWalking
{
  //ignores  PlayerTick, Landed, TakeDamage, HitWall, Bump, UnTouch, Touch;
  ignores SeePlayer, HearNoise;
  
  event Touch( Actor Other )
  {
	// Let the director (if any) know when Harry touches things
	if ( Director != None )
		Director.OnTouchEvent( Self, Other );

	Global.Touch( Other );
  }

  event UnTouch( Actor Other )
  {
	// Let the director (if any) know when Harry stops touching things
	if ( Director != None )
		Director.OnUnTouchEvent( Self, Other );

	Global.UnTouch( Other );
  }

  event Bump( Actor Other )
  {
	// Let the director (if any) know when Harry bumps things
	if ( Director != None )
		Director.OnBumpEvent( Self, Other );

	Global.Bump( Other );
  }
  
  event HitWall( vector HitNormal, Actor Wall )
  {
	// Let the director (if any) know when Harry hits things
	if ( Director != None )
		Director.OnHitEvent( Self );

	Global.HitWall( HitNormal, Wall );
  }
  
  //update the director about damage types (UTPT didn't add this) -AdamJD
  event TakeDamage (int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
  {
	if ( Director != None )
	{
		Director.OnTakeDamage( Self, Damage, InstigatedBy, DamageType );
	}
	
	Global.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
  }
  
  function ZoneChange (ZoneInfo NewZone)
  {
    if ( NewZone.bWaterZone )
    {
      SetPhysics(PHYS_Swimming);
      GotoState('PlayerSwimming');
    }
  }

  function AnimEnd()
  {
    local name MyAnimGroup;
  
    bAnimTransition = False;
    bJustFired = False;
    bJustAltFired = False;
    if (Physics == PHYS_Walking )
    {
      MyAnimGroup = MyGetAnimGroup(AnimSequence);
      if ( (Velocity.X * Velocity.X + Velocity.Y * Velocity.Y) < 1000 )
      {
        if ( MyAnimGroup == 'Waiting' )
        {
          PlayWaiting();
        } 
		else 
		{
          bAnimTransition = True;
          TweenToWaiting(0.40);
        }
      } 
	  else if (bIsWalking)
      {
        if ( (MyAnimGroup == 'Waiting') || (MyAnimGroup == 'Landing') )
        {
          TweenToWalking(0.40);
          bAnimTransition = True;
        } 
		else 
		{
          PlayWalking();
        }
      } 
      else 
	  {
        if ( (MyAnimGroup == 'Waiting') || (MyAnimGroup == 'Landing') )
        {
          bAnimTransition = True;
          TweenToRunning(0.40);
        } 
		else 
		{
          PlayRunning();
        }
      }
    } 
	else 
	{
      PlayInAir();
    }
  }
  
/*   function StartAiming (bool in_bHarryUsingSword)
  {
		if ( !bIsAiming && (CarryingActor == None) )
		{
			//TurnOnCastingVars(in_bHarryUsingSword);
			bJustFired = False;
			bJustAltFired = False;
			HPConsole(Player.Console).bSpaceReleased = False;
			HPConsole(Player.Console).bSpacePressed = False;

			HarryAnimChannel.GotoStateCasting(in_bHarryUsingSword);
			HarryAnimType = AT_Combine;
		}
  } */
  
  function Landed(vector HitNormal)
  {
	local float fFallDistanceZ;
	local int   i;
	local SpongifyPad sp; //added by me for compatibility code -AdamJD

	clientMessage("landed: jump dist = " $VSize(Location-MountDelta) $ "   tia="$AirTime);
		
	Global.Landed(HitNormal);

	PlayLandedSound();
	
	//only do this if not hidden (UTPT didn't add this) -AdamJD
	if(!bHidden)
	{
		PlayLandedEmoteSound();
	}
	
	playanim(HarryAnims[HarryAnimSet].land, [TweenTime]0.1, [Type] HarryAnimType);

	//log("PLOG PWalking landed");

	// Set our spell distance to the default if we landed from a spongify jump
	if( !bExtendedTargetting && AnimFalling == SpongifyFallAnim )
		SpellCursor.SetLOSDistance( 0 );
		
	// See if we laneded on spongify!
	//
	//updated to make this compatible with the new engine -AdamJD
	//
	//for(i=0; i<ArrayCount(Touching); i++)
	foreach TouchingActors(class'SpongifyPad', sp)
	{
		//if( Touching[i].IsA('SpongifyPad') &&
		//	SpongifyPad(Touching[i]).IsEnabled() )
		if(sp.IsEnabled())
		{
			// We landed on a spongifyPad an
			HitSpongifyPad = sp; //SpongifyPad(Touching[i]);
				
			// Set our spell distance longer so we can easily target the next spongify pad
			// The spell distance will revert back to normal once we land from a spongify pad
			if( !bExtendedTargetting )
				SpellCursor.SetLOSDistance( 1024 );
		}
	}
		
	//if( AnimFalling == SpongifyFallAnim  &&  HitSpongifyPad == none )
		StopSpongifyEffects();

	// We didn't land on a spongify pad and we are not falling from a spongify pad bounce
	if( AnimFalling != SpongifyFallAnim && HitSpongifyPad == None 
		&& (!bNoFallingDamage && NoFallingDamageTimer == 0) ) //only take damage if no falling damage stuff is off (UTPT didn't add this) -AdamJD
	{
		// we are doing a regular fall animation
		ClientMessage("Z Fall Distance = " $(HighestZ-location.z) $" TimeInAir = " $AirTime
						$"ZHighest = " $HighestZ $"ZLoc = " $location.z );
									
		fFallDistanceZ = (HighestZ-location.z);
			
		// if we fell for a long distance then hurt harry
		if( fFallDistanceZ > FALL_DAMAGE_DISTANCE )
		{
			// The farther you fall the more damage you get
			if( fFallDistanceZ < FALL_DAMAGE_DISTANCE + 32 )	// 512 - 544
				TakeDamage(20, self, location,vec(0,0,0), 'Falling' );
			else
			if( fFallDistanceZ < FALL_DAMAGE_DISTANCE + 64 )	// 
				TakeDamage(30, self, location,vec(0,0,0), 'Falling' );
			else
			if( fFallDistanceZ < FALL_DAMAGE_DISTANCE + 256 )	// 
				TakeDamage(50, self, location,vec(0,0,0), 'Falling' );
			else
			if( fFallDistanceZ < FALL_DAMAGE_DISTANCE + 512 )	// 
				TakeDamage(100, self, location,vec(0,0,0), 'Falling' );
			else
			if( fFallDistanceZ < FALL_DAMAGE_DISTANCE + 1024 )	// 
				TakeDamage(200, self, location,vec(0,0,0), 'Falling' );
			else
			{													// 768 - 
				TakeDamage(99999, self, location,vec(0,0,0), 'Falling' );
			}
		}
	}
		
	// Reset our falling animation
	AnimFalling = HarryAnims[HarryAnimSet].fall;

	// Reset our highestZ position
	HighestZ = default.HighestZ;
	
	//landed code for fatness (UTPT didn't add this) -AdamJD
	if ( Fatness > 200 )
	{
	  PlaySound(Sound'Big_whomp2',SLOT_None,RandRange(1.0,1.5),False,500.0,RandRange(0.5,1.0));
	  Spawn(Class'DustCloud04_med',self,,Location - Vec(0.0,0.0,32.0),rotator(Vec(0.0,0.0,1.0)));
	  ShakeView(1.0,150.0,150.0);
	  AutoHitAreaEffect(275.0);
	}
  }
  
  event PlayerTick( float DeltaTime )
  {
	local actor a;
	local float d;
	local actor ca;

	Global.PlayerTick( DeltaTime );

	//if(	GetHealthCount() < 5 )
	//	DoDrinkWiggenwell();

	//		d = 1000000;
	//		ForEach AllActors(class'actor', a)
	//		{
	//			if( a == self )
	//				continue;
	//			//if( a.IsA('basewand') )
	//			//	continue;
	//			if( VSize( a.location - Location ) < 500 )
	//			{
	//				Log("*****:"$a$" a.h:"$a.bHidden$" dt:"$a.DrawType);
	//				d = VSize( a.location - Location );
	//				ca = a;
	//			}
	//		}
	//		ClientMessage("ca:"$ca);
	
	//stop Harry tilting (UTPT didn't add this) -AdamJD
	if (  !IsA('BroomHarry') && Physics == PHYS_Walking )
	{
		DesiredRotation.Pitch = 0;
	}
	
	/*
	if( bTempKillHarry )// ||  lifePotions <= 0 )
	{
		bTempKillHarry = false;
		KillHarry(true);
	}
	*/

	//Weird problem, not sure what's causing it, but sometimes when you touch a painzone, but start your climb
	// you'll end up with no health, but not in the dying state.  This "safely" takes care of that.
	if( GetHealthCount() <= 0 
		&& !IsInState('stateDead')) //don't do this if already dead/dying (UTPT didn't add this) -AdamJD
	{
		KillHarry(true);
		return;
	}
	
	//start counting down the NoFallingDamageTimer if it was turned on (UTPT didn't add this) -AdamJD
	if ( NoFallingDamageTimer > 0 )
    {
       NoFallingDamageTimer -= DeltaTime;
	   
	   //make sure the NoFallingDamageTimer doesn't go under 0 (UTPT didn't add this) -AdamJD
	   if ( NoFallingDamageTimer < 0 )
	   {
		  NoFallingDamageTimer = 0.0;
	   }
	}
	
	//if ( bUpdatePosition )   Might not be able to just remove this.
	//	ClientUpdatePosition();

	if( bIsAiming && HarryAnimChannel.IsInState('stateCasting') && bAltFire == 0 )
	{
		//HarryAnimChannel.

		//if( HarryAnimChannel.AnimSequence == 'castaim' )
		//{
			ClientMessage("LoopAim done");
			//PlaySound(sound'HPSounds.Magic_sfx.spell_loop_nl', [Volume]0);
			StopAimSoundFX();
				
			if( bInDuelingMode )
			{
				if(DuelSpells[CurrentDuelSpell] == class'spellExpelliarmus')
				{
				 	PlaySound( Sound'HPSounds.Magic_sfx.Dueling_EXP_swoosh' );
					HarryAnimChannel.GotoState( 'stateDefenceCast' );
				}
				else
					HarryAnimChannel.GotoState( 'stateDuelingCast' );
			}
			else
			if(   SpellCursor.IsLockedOn() //If harry's locked on, he's in normal aim mode, so cast
			   || bHarryUsingSword && baseWand(weapon).SwordChargedUpEnough() //if using sword, and sword is charged up enough
			   || !baseWand(weapon).bAutoSelectSpell // if you're not in autoselect spell mode
			  )
			{
				HarryAnimChannel.GotoState( 'stateCast' );//PlayAnim('cast', 2.0, 0.1);
				if( bCastFastSpells )  //Old, may not be needed in HP2
				{
					AnimFrame = 0.09;
					AnimRate = 3;
				}
			}
			else
			{
				// We don't have a lock so lets stop casting
				HarryAnimChannel.GotoState( 'stateCancelCasting' );

				// Stop Aiming
				StopAiming();					
			}
		//}
	}

	//Try and save how long you've been falling, and what you're original height was when you started falling
	ProcessFalling( DeltaTime );

	PlayerMove(DeltaTime);

	if( CarryingActor != none )
	{
		//r = weaponRot;
		//v = vect(0,0,1);
		//v = v >> r;
		CarryingActor.setLocation( weaponLoc );//- vect(0,0,1 );
		CarryingActor.SetRotation( weaponRot );

		//Also, look for a spacebar throw
		if( hpconsole(player.console).bSpacePressed )
		{
			hpconsole(player.console).bSpacePressed = false;
			AltFire(0);
		}
	}
		
	// If we landed on a spongify pad then bounce harry
	if( HitSpongifyPad != None && HitSpongifyPad.IsEnabled() )
	{
		DoJump(0);
		HitSpongifyPad.OnBounce( self );
		AnimFalling = SpongifyFallAnim;
		PlayinAir();
		cam.SetPitch(-8000);
		HitSpongifyPad = None;
		CreateSpongifyEffects();
	}
		
	// HP2 cam
	if( cam.IsInState('StateStandardCam') )//|| cam.IsInState('StateBossCam') )
	{
		// Force our desired Yaw to what the camera's yaw is, in this way harry will
		// always "lookAt" what the camera is looking at.
			DesiredRotation.Yaw = cam.rotation.Yaw & 0xFFFF;
	}
  }
	
  //Try and save how long you've been falling, and what you're original height was when you started falling
  //When you land, it uses this info to set the sound volume.
  function ProcessFalling( float DeltaTime )
  {
	local float fLastTimeInAir;
		
	if( Physics == PHYS_Falling )
	{
		if( eLastPhysState != PHYS_Falling )
		{
			fFallingZ = Location.z;
			HighestZ = location.z;
		}
		else // Save the highest z location for falling damage
		if( HighestZ < location.z )
		{
			HighestZ = location.z;
		}
			
		fLastTimeInAir = AirTime;
		AirTime += DeltaTime;

		if( !bPlayedFallSound  &&  AirTime > 1.5 )
		{
			bPlayedFallSound = true;

			if( AnimFalling != SpongifyFallAnim )
				//PlaySound( sound'HPSounds.HAR_emotes.falldeep2' );
				PlayFallDeepEmoteSound(); //decide which fall deep sound to play (UTPT didn't add this) -AdamJD
		}

		if( fLastTimeInAir <= 0.35   &&   AirTime > 0.35 )
			PlayInAir();
	}
	else
	{
		bPlayedFallSound = false;
		AirTime = 0;
	}

	eLastPhysState = Physics;
  }
  
  function JumpOffPawn()
  {
    AirTime = 0.0;
    Super.JumpOffPawn();
  }
  
  function PlayerMove (float DeltaTime)
  {
    local Vector X;
    local Vector Y;
    local Vector Z;
    local Vector NewAccel;
    local EDodgeDir OldDodge;
    local EDodgeDir DodgeMove;
    local Rotator OldRotation;
    local Rotator CamRot;
    local float Speed2D;
    local bool bSaveJump;
    local name AnimGroupName;
  
	//log("Player move!");
  
    if ( bReverseInput )
    {
      aForward = Abs(aForward * 2);
      aTurn =  -aTurn;
      aStrafe =  -aStrafe;
    }
    aForward *= 0.08;
    if ( Physics == PHYS_Falling || bLockedOnTarget || bUseFixedFaceDirection ) 
    {
      aStrafe *= 0.08;
      aTurn = 0.0;
    } 
	else 
	{
      aStrafe *= 0.08;
      aTurn *= 0.24;
    }
    aLookUp *= 0;
    aSideMove *= 0.1;
    if ( Adv1TutManager != None )
    {
      if ( aForward > 0 )
      {
        Adv1TutManager.ForwardPushed();
      }
      if ( aForward < 0 )
      {
        Adv1TutManager.BackwardPushed();
      }
      if ( aStrafe < 0 )
      {
        Adv1TutManager.StrafeLeftPushed();
      }
      if ( aStrafe > 0 )
      {
        Adv1TutManager.StrafeRightPushed();
      }
    }
    if ( bKeepStationary )
    {
      aForward = 0.0;
      aStrafe = 0.0;
    }
    if ( bLockOutForward && (aForward > 0) || bLockOutBackward && (aForward < 0) )
    {
      aForward = 0.0;
    }
    if ( bLockOutStrafeLeft && (aStrafe < 0) || bLockOutStrafeRight && (aStrafe > 0) )
    {
      aStrafe = 0.0;
    }
    if ( bLockedOnTarget || bUseFixedFaceDirection )
    {
      NewAccel = ProcessAccel();
    } 
	else 
	{
      GetAxes(Rotation,X,Y,Z);
      if ( bScreenRelativeMovement )
      {
        GetAxes(Cam.Rotation,X,Y,Z);
        NewAccel = aForward * X + aSideMove * Y;
        if ( NewAccel != vect(0.00,0.00,0.00) )
        {
          CamRot = Cam.Rotation;
          CamRot.Pitch = 0;
          ScreenRelativeMovementYaw = (rotator(NewAccel)).Yaw;
        }
      } 
	  else 
	  {
        NewAccel = aForward * X + aStrafe * Y;
        if ( bInDuelingMode )
        {
          NewAccel *= 1000000;
        }
      }
    }
    if ( bHarryUsingSword )
    {
      GroundSpeed = GroundRunSpeed * (1.0 - 0.9 * baseWand(Weapon).ChargingLevel());
    }
    if ( (aForward != 0) &&  !bIsAiming )
    {
      bHarryMovingNotAiming = True;
    } 
	else 
	{
      bHarryMovingNotAiming = False;
    }
    NewAccel.Z = 0.0;
    AnimGroupName = GetAnimGroup(AnimSequence);
    OldRotation = Rotation;
    ProcessMove(DeltaTime,NewAccel,DodgeMove,OldRotation - Rotation);
    if ( Cam.IsInState('StateStandardCam') )
    {
      DesiredRotation.Yaw = Cam.Rotation.Yaw & 0xFFFF;
      if ( bHarryMovingNotAiming && bAutoCenterCamera &&  !bInDuelingMode )
      {
        if ( AnimFalling != SpongifyFallAnim )
        {
          Cam.SetPitch(-1500.0);
        }
      }
    }
  }
  
  function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
  {
		local vector OldAccel;
		local float  Speed;
		
		//log("ProcessMove!");

		OldAccel = Acceleration;
		Acceleration = NewAccel;
		bIsTurning = ( Abs(DeltaRot.Yaw/DeltaTime) > 5000 );

		if(bJustAltFired || bJustFired)
		{
			Velocity = vect(0,0,0);
			return;
		}

		if ( bPressedJump )
		{
//			ClientMessage("Jump pressed");
			DoJump();			// jumping
			bPressedJump = false;
		}

		if ( (Physics == PHYS_Walking)  )
		{
			Speed = VSize2d( Velocity );

			if(   (!bAnimTransition || (AnimFrame > 0))
			   && !( AnimSequence == HarryAnims[HarryAnimSet].Land && (Speed < 5 || VSize2D(acceleration)==0) )  //You need to NOT be (landing and not-moving)    //(GetAnimGroup(AnimSequence) != 'Landing') )
			  )
			{
				//ClientMessage("AnimSequence:"$AnimSequence$" AnimGroup:"$GetAnimGroup(AnimSequence)$" Speed:"$Speed);

				if( Speed > 5 )
					fTimeWalking += DeltaTime;
				else
					fTimeWalking = 0;

				if(   Acceleration != vect(0,0,0)
				   && Speed > 1 //you need a little bit of motion 
				   //&& (    bMovingBackwards   && Speed > 30
				   //    || !bMovingBackwards   && Speed > 65
				   //    ||  fTimeWalking > 0.5 && Speed > 15
				   //   )
				  )
				{
						bAnimTransition = true;
						TweenToRunning(0.4);
				}
			 	else
			 	{
						bAnimTransition = true;
						TweenToWaiting(0.4);
				}
			}
		}
  }
  
  function BeginState()
  {
    //DebugState();
    if ( Mesh == None )
    {
      SetMesh();
    }
    WalkBob = vect(0.00,0.00,0.00);
    DodgeDir = DODGE_None;
    bIsCrouching = False;
    bIsTurning = False;
    bPressedJump = False;
    if ( Physics != PHYS_Falling )
    {
      SetPhysics(PHYS_WALKING);
    }
    if (  !IsAnimating() )
    {
      PlayWaiting();
    }
    foreach AllActors(Class'BaseCam',Cam)
    {
	  break;
    }
  }
  
  function EndState()
  {
    WalkBob = vect(0.00,0.00,0.00);
    bIsCrouching = False;
    StopAiming();
    Acceleration = vect(0.00,0.00,0.00);
    Velocity = vect(0.00,0.00,0.00);
    CurrIdleAnimName = GetCurrIdleAnimName();
    LoopAnim(CurrIdleAnimName,,[TweenTime]0.40,,[Type]HarryAnimType);
  }
}

function UpdateRotationToTarget()
{
  local Rotator R;
  local Vector V;
  local Vector TargetLoc;

  if ( bUseFixedFaceDirection )
  {
    R = rotator(FixedFaceDirection);
    R.Pitch = 0;
    R.Roll = 0;
    SetRotation(R);
    ViewRotation = R;
  } else //{
    if ( BossTarget != None )
    {
      if ( baseBoss(BossTarget) != None )
      {
        TargetLoc = baseBoss(BossTarget).GetHarryFaceLocation();
      } else {
        TargetLoc = BossTarget.Location;
      }
      R = rotator(TargetLoc - Location);
      R.Pitch = Rotation.Pitch;
      ViewRotation = R;
      DesiredRotation = R;
    }
  //}
}

function Vector ProcessAccel()
{
  local float D;
  local Vector V;
  local Vector X;
  local Vector Y;
  local Vector Z;
  local Vector x2;
  local Vector y2;
  local float xMag;
  local float yMag;
  local BossRailMove B;
  local Vector N;

  if ( aForward > fLargestAForward )
  {
    fLargestAForward = aForward;
  }
  UpdateRotationToTarget();
  if ( baseBoss(BossTarget) != None )
  {
    GetAxes(rotator(baseBoss(BossTarget).GetHarryMovementCenter() - Location),X,Y,Z);
  } else {
    GetAxes(Rotation,X,Y,Z);
  }
  if ( bLockedOnTarget && BossRailMove(BossTarget) != None )
  {
	//log("AdamJD: Locked onto Peeves");
    B = BossRailMove(BossTarget);
    xMag = aForward;
    yMag = aStrafe;
    xMag -= Abs(aStrafe) * 0.25;
    V = xMag * X + yMag * Y;
    V = KeepPawnInsidePlane(V,B.v1, -B.n2);
    V = KeepPawnInsidePlane(V,B.v1,B.n1);
    V = KeepPawnInsidePlane(V,B.v2,B.n2);
    V = KeepPawnInsidePlane(V,B.v4, -B.n1);
    // if ( (V.X != 0) || (V.Y != 0) && fLargestAForward != 0 )
	if ( (V.X != 0 || V.Y != 0) && fLargestAForward != 0 ) //removed wrong decomped brackets so Harry can move in the Peeves fight -AdamJD
    {
      V = Normal(V) * fLargestAForward;
    }
  } else {
    V = aForward * X + aStrafe * Y;
  }
  V += vAdditionalAccel;
  vAdditionalAccel = vect(0.00,0.00,0.00);
  return V;
}

function Vector KeepPawnInsidePlane (Vector vAccel, Vector vPlanePoint, Vector vPlaneNormal)
{
  local float D;
  local Vector x2;
  local Vector y2;
  local float xMag;
  local float yMag;

  D = (Location - vPlanePoint) Dot vPlaneNormal;
  if ( D > 0 )
  {
    x2 =  -vPlaneNormal;
    y2 = vect(0.00,0.00,1.00) Cross x2;
    // xMag = vAccel Dot x2;
    // yMag = vAccel Dot y2;
	xMag = (vAccel Dot x2); //UTPT forgot to add brackets -AdamJD
    yMag = (vAccel Dot y2); //UTPT forgot to add brackets -AdamJD
    if ( xMag < 0 )
    {
      xMag = D * 10;
    }
    vAccel = x2 * xMag + y2 * yMag;
  }
  return vAccel;
}

state GameEnded
{
  // ignores  Died, TakeDamage, KilledBy;
  ignores SeePlayer, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, TakeDamage, PainTimer, Died; //UTPT forgot to add these... -AdamJD
}

function Rotator AdjustAim (float ProjSpeed, Vector projStart, int AimError, bool bLeadTarget, bool bWarnTarget)
{
  local Vector FireDir;
  local Actor BestTarget;
  //local Actor HitActor;
  local Actor aHitActor;
  local Rotator defaultAngle;
  local Rotator checkAngle;
  local Pawn hitPawn;
  local Vector objectDir;
  local int bestYaw;
  local int tempYaw;
  local int defaultYaw;
  local float bestZ;

  defaultAngle = Rotation;
  defaultAngle.Pitch = 0;
  defaultYaw = defaultAngle.Yaw;
  defaultYaw = defaultYaw & 0xffff;
  FireDir = vector(defaultAngle);
  FireDir = Normal(FireDir);
  BestTarget = None;
  foreach VisibleActors(Class'Actor',aHitActor)
  {
    if ( aHitActor.bProjTarget && PlayerPawn(aHitActor) != self &&  !aHitActor.IsA('BaseCam') )
    {
      objectDir = Normal(aHitActor.Location - projStart);
      checkAngle = rotator(objectDir);
      if ( BestTarget == None )
      {
        bestYaw = checkAngle.Yaw;
        bestYaw = bestYaw & 0xFFFF;
        BestTarget = aHitActor;
        bestZ = objectDir.Z;
      } else {
        tempYaw = checkAngle.Yaw;
        tempYaw = tempYaw & 0xFFFF;
        if ( Abs(tempYaw - defaultYaw) < Abs(bestYaw - defaultYaw) )
        {
          bestYaw = tempYaw;
          BestTarget = aHitActor;
          bestZ = objectDir.Z;
        }
      }
    }
  }
  if ( BestTarget != None )
  {
    if ( Abs(bestYaw - defaultYaw) < 8000 )
    {
      FireDir.Z = bestZ;
    }
  }
  defaultAngle = rotator(FireDir);
  return defaultAngle;
}

function float TurnWhileStrafingMult()
{
  if ( Basilisk(BossTarget) != None )
  {
	//return 0.01 + 0.14 * 1 - baseWand(Weapon).ChargingLevel();
    return 0.01 + 0.14 * (1 - baseWand(Weapon).ChargingLevel()); //UTPT forgot to add brackets which made Harry walk around in a small 360 circle when fighting the basilisk instead of strafing... -AdamJD
  }
  return 0.0;
}

function Vector GetSwordFireTargetLoc()
{
  return baseBoss(BossTarget).GetTargetLocation();
}

function Timer()
{
  SleepyAnimTimerSub();
}

function nailed (Actor caller, out int status)
{
  if ( bustedBy == None )
  {
    bustedBy = caller;
    status = 1;
    GotoState('waitForDeath');
  } else {
    status = 0;
  }
}

function displaydemoMessage()
{
}

state waitForDeath
{
	begin:
		//DebugState();
		
	loop:
		if ( Abs(VSize(Location - bustedBy.Location)) < 150 )
		{
			MoveTo(Location);
			CurrFidgetAnimName = GetCurrFidgetAnimName();
			PlayAnim(CurrFidgetAnimName,1.0,0.2);
		} 
		else 
		{
			MoveToward(bustedBy);
			LoopAnim(HarryAnims[HarryAnimSet].run);
		}
		goto ('Loop');
}

function name GetCurrIdleAnimName()
{
  local string AnimName;
  //local int Index;
  local int iIndex;
  local name nm;

  if ( bInDuelingMode )
  {
    IdleNums = 0;
  }
  if ( IdleNums == 0 )
  {
    return HarryAnims[HarryAnimSet].Idle;
  }
  if ( (HarryAnimSet == HARRY_ANIM_SET_SLEEPY) || (HarryAnimSet == HARRY_ANIM_SET_SWORD) )
  {
    return HarryAnims[HarryAnimSet].Idle;
  }
  iIndex = 1 + Rand(IdleNums);
  AnimName = "idle_" $iIndex;
  nm = StringToAnimName(AnimName);
  return nm;
}

function name GetCurrFidgetAnimName()
{
  local string AnimName;
  //local int Index;
  local int iIndex;
  local name nm;

  if ( bInDuelingMode )
  {
    FidgetNums = 0;
  }
  if ( FidgetNums == 0 )
  {
    return GetCurrIdleAnimName();
  }
  iIndex = 1 + Rand(FidgetNums);
  AnimName = "fidget_" $iIndex;
  nm = StringToAnimName(AnimName);
  return nm;
}

function ReceiveIconMessage (Texture Icon, string Message, float duration)
{
  baseHUD(myHUD).ReceiveIconMessage(Icon,Message,duration);
}

function bool HarryIsDead()
{
  return GetHealthCount() <= 0;
}

function startmenu()
{
  HPConsole(Player.Console).bQuickKeyEnable = False;
  HPConsole(Player.Console).LaunchUWindow();
}

state exittoMenu
{
	begin:
		Level.Game.RestartGame();
		GotoState('harryfrozen');
}

state harryfrozen
{
  // ignores  AltFire, Fire;
  ignores Fire, AltFire, ZoneChange, AnimEnd, Landed, PlayerTick, SeePlayer, HearNoise, Bump; //UTPT forgot to add these... -AdamJD
  
  function BeginState()
  {
  }
  
  function EndState()
  {
  }
  
}

event PlayerCalcView (out Actor ViewActor, out Vector CameraLocation, out Rotator CameraRotation)
{
  local Pawn PTarget;

  if ( ViewTarget != None )
  {
    ViewActor = ViewTarget;
    CameraLocation = ViewTarget.Location;
    CameraRotation = ViewTarget.Rotation;
  }
}

function makeTarget()
{
  local Vector tloc;
  //local Vector TargetOffset;
  local Vector vTargetOffsetMT; 

  vTargetOffsetMT.Y = 0.0;
  vTargetOffsetMT.X = 50.0;
  vTargetOffsetMT.Z = 0.0;
  tloc = vTargetOffsetMT >> ViewRotation;
  tloc = tloc + Location;
  if ( SpellCursor == None )
  {
    GotoState('PlayerWalking');
    ClientMessage("failed targetspawn");
    HPConsole(Player.Console).bSpaceReleased = True;
    HPConsole(Player.Console).bSpacePressed = False;
  } else {
    SpellCursor.TurnTargetingOn();
  }
}

function StartSpellLearning (SpellLessonTrigger SpellLesson)
{
  CurrSpellLesson = SpellLesson;
  GotoState('SpellLearning');
}

function EndSpellLearning()
{
  CurrSpellLesson = None;
  GotoState('PlayerWalking');
}

state SpellLearning
{
  ignores  AltFire, ProcessMove;
  
  event PlayerInput (float DeltaTime)
  {
    Super.PlayerInput(DeltaTime);
    CurrSpellLesson.PlayerInput(DeltaTime);
  }
  
}

function StartVendorEngagement (VendorManager VManager)
{
  CurrVendorManager = VManager;
  bKeepStationary = True;
}

function EndVendorEngagement()
{
  CurrVendorManager = None;
  bKeepStationary = False;
}

function bool IsEngagedWithVendor()
{
  return (CurrVendorManager != None);
}

function Add60HousePointsToGryffindor()
{
  numHousePointsHarry += 60;
  numHousePointsGryffindor += 60;
  numLastHousePointsHarry = 60;
  if ( numHousePointsSlytherin >= numHousePointsGryffindor )
  {
    numHousePointsSlytherin = numHousePointsGryffindor - 1;
  }
}

function AddHousePoints (int Num)
{
	local int temp;
	local float ftemp;

	numLastHousePointsHarry = Num;
	numHousePointsHarry += Num;
	numHousePointsGryffindor = numHousePointsHarry;
	
	if ( numHousePointsGryffindor < 58 )
	{
		temp = numHousePointsGryffindor + Rand(numHousePointsGryffindor) + 1;
	} 
	else 
	{
		temp = numHousePointsGryffindor + Rand(58) + 1;
	}
	
	if ( numHousePointsSlytherin < temp )
	{
		numHousePointsSlytherin = temp;
	}
	  
	ftemp = numHousePointsGryffindor * (0.5 + FRand() * 0.2);
	if ( numHousePointsHufflepuff < ftemp )
	{
		numHousePointsHufflepuff = ftemp;
	}
	
	ftemp = numHousePointsGryffindor * (0.7 + FRand() * 0.2);
	if ( numHousePointsRavenclaw < ftemp )
	{
		numHousePointsRavenclaw = ftemp;
	}
	
	Log("###### House Points");
	Log("added" @ string(numLastHousePointsHarry));
	Log("Harry total" @ string(numHousePointsHarry));
	Log("Gryffindor" @ string(numHousePointsGryffindor));
	Log("Slytherin" @ string(numHousePointsSlytherin));
	Log("Hufflepuff" @ string(numHousePointsHufflepuff));
	Log("Ravenclaw" @ string(numHousePointsRavenclaw));
}

state stateCutIdle
{
  function BeginState()
  {
    Acceleration = vect(0.00,0.00,0.00);
    Velocity = vect(0.00,0.00,0.00);
    CurrIdleAnimName = GetCurrIdleAnimName();
    LoopAnim(CurrIdleAnimName,1.0,0.2);
  }
}

function bool CutQuestion(string question)
{
	local ChallengeScoreManager managerChallenge;
	local bool		bAnswer;

	CutErrorString="";	//clear error string.

	// If there is a mini-game director, give it first chance at answering the
	// question; if it reports that it didn't answer it, then let Harry give it
	// a try.
	if ( Director != None )
	{
		bAnswer = Director.CutQuestion( question );
		if ( !(CutErrorString ~= "Unanswered") )
			return bAnswer;
	
		CutErrorString="";	// clear error string and let Harry try
	}

		//see if it is a question about the game state.
	question=caps(question);
	if(instr(question,"GSTATE")>-1)
	{
		cm("CutQuestion about game state:"$question $" CurrentGameState is:" $currentGameState);
		if(CurrentGameState~=question)
			return(true);
		else
			return(false);
	}


//sample question
	if(question~="EnoughBeans")
	{
//		if(beans greater than whatever)
			return true;
//		else
//			return false;
	}
	else if (question ~= "IsGryffindorAhead" ||
		     question ~= "IsSlytherinAhead"  ||
			 question ~= "IsHufflepuffAhead" ||
			 question ~= "IsRavenclawAhead")
	{
		return (managerStatus.GetStatusGroup(class'StatusGroupHousePoints').CutQuestion(question));
	}

	else if (question ~= "ChallengeIsFirstTime" ||
			 question ~= "ChallengePreviouslyBeaten" ||
			 question ~= "ChallengePreviouslyMastered" ||
			 question ~= "ChallengeWorseThanBefore"    ||
			 question ~= "ChallengeJustWonFirstTime"   ||
			 question ~= "ChallengeJustMastered"       ||
			 question ~= "ChallengeMissedStars"       ||
			 question ~= "ChallengeNewBestScore")
	{
		// Get level's challenge score manager.  A level should either have
		// 0 or 1 ChallengeScoreManagers.
		foreach AllActors(class'ChallengeScoreManager', managerChallenge )
			break;

		if (managerChallenge != None)
			return (managerChallenge.CutQuestion(question));		
		else
			return Super.CutQuestion(question);
	}
    else if (question ~= "ReadyForTransitionE")
    {        
        return (bHub9CeremonyFlag == true &&
                (managerStatus.GetStatusItem(class'StatusGroupPolyIngr',class'StatusItemBoomslang').nCount > 0) &&
                (managerStatus.GetStatusItem(class'StatusGroupPolyIngr',class'StatusItemBicorn').nCount > 0));
    }
    else if (question ~= "HaveAllSilverCards")
    {
        return (managerStatus.GetStatusItem(class'StatusGroupWizardCards',class'StatusItemSilverCards').nCount >= 40);
    }
	else
		return Super.CutQuestion(question);
}

function bool CutCommand (string Command, optional string cue, optional bool bFastFlag)
{
	local string sActualCommand;
	local string sCutName;
	local Actor A;
	local string sSayText;
	local string sSayTextID;
	local Characters CurrCharacter;
  
	//ClientMessage(self$" CutCommand:" $command $" Cue:" $cue);

	sActualCommand = ParseDelimitedString(Command," ",1,False);
  
	if ( sActualCommand ~= "Capture" )
	{
		if ( HarryIsDead() )
		{
			return False;
		}
		foreach AllActors(Class'Characters',CurrCharacter)
		{
			CurrCharacter.OnHarryCaptured();
		}	
		
		bIsCaptured = True;
		myHUD.StartCutScene();
		SendPlayerCaptureMessages(True);
		GotoState('stateCutIdle');
		return True;
	} 
	else if ( sActualCommand ~= "Release" )
	{
		myHUD.EndCutScene();
		DestroyControllers();
		// DivingDeep39: Destroy TurnToController
		DestroyTurnToPermanentController();
		SendPlayerCaptureMessages(False);
		bIsCaptured = False;
		GotoState('PlayerWalking');
		RotationRate = Default.RotationRate;
		
		return True;
	} 
	
	// Metallicafan212:	Lumos control
	else if (sActualCommand ~= "ToggleLumos")
	{
		// Metallicafan212:	Toggle it on or off
		if(baseWand(Weapon).TheLumosLight.bLumosOn)
		{
			baseWand(Weapon).TheLumosLight.TurnOff();
		}
		else
		{
			baseWand(Weapon).TheLumosLight.TurnOn();
		}
		
		// Metallicafan212:	Check if we want infinite lumos
		sActualCommand = ParseDelimitedString(Command," ",2,False);
		
		if (sActualCommand ~= "Infinite")
		{
			baseWand(Weapon).TheLumosLight.bInfiniteLumos = true;
		}
		
		CutCue(cue);
		
		return true;
	}
	else if (sActualCommand ~= "LumosOn")
	{
		// Metallicafan212:	On
		baseWand(Weapon).TheLumosLight.TurnOn();
		
		// Metallicafan212:	Check if we want infinite lumos
		sActualCommand = ParseDelimitedString(Command," ",2,False);
		
		if (sActualCommand ~= "Infinite")
		{
			baseWand(Weapon).TheLumosLight.bInfiniteLumos = true;
		}
		
		CutCue(cue);
		
		return true;
	}
	else if (sActualCommand ~= "LumosOff")
	{
		// Metallicafan212:	Off
		baseWand(Weapon).TheLumosLight.TurnOff();
		
		CutCue(cue);
		
		return true;
	}
	
	else if ( sActualCommand ~= "ToggleUseSword" )
	{
		ToggleUseSword();
		CutCue(cue);
		return True;
	} 
	else if ( sActualCommand ~= "ChangeGameState" )
	{
		sActualCommand = ParseDelimitedString(Command," ",2,False);
		if (  !SetGameState(sActualCommand) )
		{
			CutErrorString = "!E!R!R!O!R! GameState " $ sActualCommand $ " is not a valid GameState in the *GameStateMasterList*!!!";
			CutCue(cue);
			return False;
		}
		
		CutCue(cue);
		return True;
	} 
	else if ( sActualCommand ~= "HideWeapon" )
	{
		Weapon.bHidden = True;
		CutCue(cue);
		return True;
	} 
	else if ( sActualCommand ~= "ShowWeapon" )
	{
		Weapon.bHidden = False;
		CutCue(cue);
		return True;
	} 
	else if ( sActualCommand ~= "SetHub9CeremonyFlag" )
	{
		bHub9CeremonyFlag = True;
		CutCue(cue);
		return True;
	} 
	else if ( sActualCommand ~= "GiveHermioneBicorn" )
	{
		managerStatus.AddBicorn(-1);
		CutCue(cue);
		return True;
	} 
	else if ( sActualCommand ~= "GiveHermioneBoomslang" )
	{
		managerStatus.AddBoomslang(-1);
		CutCue(cue);
		return True;
	} 
	else if ( sActualCommand ~= "RunCredits" )
	{
		HPConsole(Player.Console).menuBook.RunTheCredits();
        CutCue(cue);
        return True;

        // Omega: menuBook deprecated because of its game busting potential:
        /*menuBook = HPConsole(Player.Console).menuBook;
        if ( menuBook != None )
        {
            menuBook.RunTheCredits();
            CutCue(cue);
            return True;
        }*/
	} 
	else if ( sActualCommand ~= "ResetLevel" )
	{
		return CutCommand_ResetLevel(Command,cue);
	} 
	else if ( sActualCommand ~= "PutGryffInLead" )
	{
		StatusGroupHousePoints(managerStatus.GetStatusGroup(Class'StatusGroupHousePoints')).PutGryffInLead();
		CutCue(cue);
		return True;
	} 
	else if ( sActualCommand ~= "AddHPointsG" )
	{
		sActualCommand = ParseDelimitedString(Command," ",2,False);
		managerStatus.AddHPointsG(int(sActualCommand));
		CutCue(cue);
		return True;
	}
	return Super.CutCommand(Command,cue,bFastFlag);
}

function bool SetGameState (string strNewGameState)
{
	local bool bRet;
	local int nNewGameState;
	
	bRet = Super.SetGameState(strNewGameState);
	if ( bRet )
	{
		nNewGameState = ConvertGameStateToNumber();
		iGameState = nNewGameState;
		if ( nNewGameState >= 180 )
		{
			StatusGroupWizardCards(managerStatus.GetStatusGroup(Class'StatusGroupWizardCards')).AssignAllSilverToVendors();
		}
	}
	return bRet;
}

function SendPlayerCaptureMessages (bool bCapture)
{
  if ( bCapture )
  {
    ++nPlayerCaptureCount;
    if ( nPlayerCaptureCount == 1 )
    {
      foreach AllActors(Class'HPawn',foreachActor)
      {
        foreachActor.PlayerCutCapture();
      }
    }
  } else {
    --nPlayerCaptureCount;
    if ( nPlayerCaptureCount <= 0 )
    {
      nPlayerCaptureCount = 0;
      foreach AllActors(Class'HPawn',foreachActor)
      {
        foreachActor.PlayerCutRelease();
      }
    }
  }
}

function bool CutCommand_ResetLevel (string Command, optional string cue)
{
  local Characters A;

  foreach AllActors(Class'Characters',A)
  {
    if ( A.SavedFirstNavP != None )
    {
      A.RestartPatrol();
    }
  }
  CutCue(cue);
  return True;
}

function ToggleUseSword()
{
  bHarryUsingSword =  !bHarryUsingSword;
  if ( bHarryUsingSword )
		HarryAnimSet = HARRY_ANIM_SET_SWORD;
	else
		HarryAnimSet = HARRY_ANIM_SET_MAIN;
		
  baseWand(Weapon).ToggleUseSword();
}

function bool MoveWhileCasting()
{
  if ( bAltFire == 0 )
  {
    return True;
  } else {
    return bMoveWhileCasting;
  }
}

event PlayerInput (float DeltaTime)
{
  if ( bE3DemoLockout )
  {
    if ( myHUD.MainMenu != None )
    {
      myHUD.MainMenu.MenuTick(DeltaTime);
    }
    bEdgeForward = False;
    bEdgeBack = False;
    bEdgeLeft = False;
    bEdgeRight = False;
    bWasForward = False;
    bWasBack = False;
    bWasLeft = False;
    bWasRight = False;
    aStrafe = 0.0;
    aTurn = 0.0;
    aForward = 0.0;
    aLookUp = 0.0;
    return;
  }
  if ( bInDuelingMode )
  {
	bStrafe = 1;
  }
  Super.PlayerInput(DeltaTime);
  if ( HPHud(myHUD).bCutSceneMode )
  {
	if (bSkipCutScene == 1)
	{
		HPConsole(Player.Console).StartFastForward();
	}
  } 
  else if ( bInDuelingMode )
  {
	if ( !(baseWand(Weapon).ChargingLevel() > 0 ) )
	{
		HandleDuelPlayerInput();
	}
  } 
  else
  {
	if ( bAltFire > 0 )
	{
	  if ( GetCurrentKeyState(IK_LeftMouse) || GetCurrentKeyState(IK_RightMouse) || GetCurrentKeyState(IK_MiddleMouse) )
	  {
	      bMoveWhileCasting = True;
		  //log("Move while casting!");
	  } 
	  else 
	  {
		  bMoveWhileCasting = False;
		  //log("No move while casting!");
	  }
	}
	/*
	if ( bOpenMap == 1 &&  !bMapQuickLook )
    {
	  bMapQuickLook = True;
    } 
    else if ( bOpenMap == 0 && bMapQuickLook )
    {
      cm("FEBook ToggleMap");
      HPConsole(Player.Console).menuBook.ToggleMap();
      bMapQuickLook = False;
    }
	*/
    if ( (bDrinkWiggenwell == 1 && IsInState('PlayerWalking') && Physics == PHYS_Walking &&  !IsA('BroomHarry')) || (bDrinkWiggenwell == 1 && IsInState('PlayerWalking') && IsA('BroomHarry')) )
    {
	  DoDrinkWiggenwell();
    }
  }  
  if ( CurrVendorManager != None )
  {
	CurrVendorManager.PlayerInput(DeltaTime);
  }
}

function DoDrinkWiggenwell()
{
  local StatusItem siWiggenPotion;
  local StatusGroup sgPotions;

  if ( HPHud(myHUD).bCutSceneMode )
  {
    return;
  }
  if ( managerStatus.GetHealthCount() == managerStatus.GetHealthPotentialCount() )
  {
    return;
  }
  if ( HarryAnimChannel.IsInState('stateDrinkWiggenwell') )
  {
    return;
  }
  siWiggenPotion = managerStatus.GetStatusItem(Class'StatusGroupPotions',Class'StatusItemWiggenwell');
  if ( siWiggenPotion.nCount >= 1 )
  {
    StopAiming();
    DropCarryingActor(False);
    HarryAnimChannel.DoDrinkWiggenwell();
  }
}

function CopyAllStatusFromManagerToHarry()
{
  CopyGenericStatusFromManagerToHarry();
  CopyCardStatusFromManagerToHarry();
}

/*
function CopyGenericStatusFromManagerToHarry()
{
  local StatusGroup sgLoop;
  local StatusItem siLoop;
  local int nStatusIdx;

  nStatusIdx = 0;
JL001B:
  sgLoop = managerStatus.sgList;
  if ( sgLoop != None )
  {
    siLoop = sgLoop.siList;
    if ( siLoop != None )
    {
      if ( nStatusIdx >= 30 )
      {
        ClientMessage("ERROR:  Need to increase StatusSaveSize");
        goto JL013F;
      } else {
        StatusSave[nStatusIdx].classGroup = sgLoop.Class;
        StatusSave[nStatusIdx].classItem = siLoop.Class;
        StatusSave[nStatusIdx].nPotential = siLoop.nCurrCountPotential;
        StatusSave[nStatusIdx].nCount = siLoop.nCount;
        StatusSave[nStatusIdx].nMaxCount = siLoop.nMaxCount;
        nStatusIdx++;
      }
      siLoop = siLoop.siNext;
      goto JL003A;
    }
    sgLoop = sgLoop.sgNext;
    goto JL001B;
  }
  nStatusIdx = nStatusIdx;
  if ( nStatusIdx < 30 )
  {
    StatusSave[nStatusIdx].classGroup = None;
    StatusSave[nStatusIdx].classItem = None;
    StatusSave[nStatusIdx].nPotential = 0;
    StatusSave[nStatusIdx].nCount = 0;
    StatusSave[nStatusIdx].nMaxCount = 0;
    nStatusIdx++;
    goto JL0161;
  }
}
*/

// Save off StatusManager data into an array that travels/goes with save games.
function CopyGenericStatusFromManagerToHarry()
{
	local StatusGroup            sgLoop;
	local StatusItem             siLoop;
	local int                    nStatusIdx;

	// Setup StatusSave array with status item information to carry
	// onto next level or into restored game
	nStatusIdx = 0;
	for (sgLoop=managerStatus.sgList; sgLoop!=None; sgLoop=sgLoop.sgNext)
	{
		for (siLoop=sgLoop.siList; siLoop!=None; siLoop=siLoop.siNext)
		{
			// If list isn't big enough to hold everything, throw out a message.
			if (nStatusIdx >= ArrayCount(StatusSave))
			{
				ClientMessage("ERROR:  Need to increase StatusSaveSize");
				break;
			}

			// Save off necessary status information into our array that will travel/save.
			else
			{
				StatusSave[nStatusIdx].classGroup   = sgLoop.class;
				StatusSave[nStatusIdx].classItem    = siLoop.class;
				StatusSave[nStatusIdx].nPotential   = siLoop.nCurrCountPotential;
				StatusSave[nStatusIdx].nCount       = siLoop.nCount;
                StatusSave[nStatusIdx].nMaxCount    = siLoop.nMaxCount;

				nStatusIdx++;
			}
		}
	}

	// Clear out unused portion of StatusSave array.
	for (nStatusIdx=nStatusIdx; nStatusIdx < ArrayCount(StatusSave); nStatusIdx++)
	{
		StatusSave[nStatusIdx].classGroup = None;
		StatusSave[nStatusIdx].classItem  = None;
		StatusSave[nStatusIdx].nPotential = 0;
		StatusSave[nStatusIdx].nCount     = 0;
        StatusSave[nStatusIdx].nMaxCount  = 0;
	}

}

/*
function CopyCardStatusFromManagerToHarry()
{
  local StatusGroupWizardCards sgCards;
  local StatusItemWizardCards siCards;
  local int I;
  local int nId;
  local int nOwner;

  sgCards = StatusGroupWizardCards(managerStatus.GetStatusGroup(Class'StatusGroupWizardCards'));
  sgCards.AssignVendorCards();
  siCards = StatusItemWizardCards(sgCards.GetStatusItem(Class'StatusItemBronzeCards'));
  I = 0;
  if ( I < 50 )
  {
JL0054:
    siCards.GetCardData(I,nId,nOwner);
    BronzeCardSave[I].nCardId = nId;
    BronzeCardSave[I].nCardOwner = nOwner;
    I++;
    goto JL0054;
  }
  siCards = StatusItemWizardCards(sgCards.GetStatusItem(Class'StatusItemSilverCards'));
  I = 0;
  if ( I < 40 )
  {
    siCards.GetCardData(I,nId,nOwner);
    SilverCardSave[I].nCardId = nId;
    SilverCardSave[I].nCardOwner = nOwner;
    I++;
    goto JL00DA;
  }
  siCards = StatusItemWizardCards(sgCards.GetStatusItem(Class'StatusItemGoldCards'));
  I = 0;
  if ( I < 11 )
  {
    siCards.GetCardData(I,nId,nOwner);
    GoldCardSave[I].nCardId = nId;
    GoldCardSave[I].nCardOwner = nOwner;
    I++;
    goto JL0160;
  }
  nLastCardTypeSave = sgCards.GetLastObtainedCardTypeAsInt();
}
*/

// Save off wizard card data in arrays that travel/save to save game.
function CopyCardStatusFromManagerToHarry()
{
	local StatusGroupWizardCards sgCards;
	local StatusItemWizardCards  siCards;
	local int                    i;
	local int                    nId;
	local int                    nOwner;

	// If there are any wizard cards left in the current level that can be sold by vendors,
	// flag them as being owned by vndors.
	sgCards = StatusGroupWizardCards(managerStatus.GetStatusGroup(class'StatusGroupWizardCards'));
	sgCards.AssignVendorCards();
	//sgCards.ShowCardData();   // for debugging

	// Save bronze card data in array that travels/goes to save game.
	siCards = StatusItemWizardCards(sgCards.GetStatusItem(class'StatusItemBronzeCards'));
	for (i=0; i<ArrayCount(BronzeCardSave); i++)
	{
		siCards.GetCardData(i, nId, nOwner);
		BronzeCardSave[i].nCardId    = nId;
		BronzeCardSave[i].nCardOwner = nOwner;
	}

	// Save silver card data in array that travels/goes to save game.
	siCards = StatusItemWizardCards(sgCards.GetStatusItem(class'StatusItemSilverCards'));
	for (i=0; i<ArrayCount(SilverCardSave); i++)
	{
		siCards.GetCardData(i, nId, nOwner);
		SilverCardSave[i].nCardId    = nId;
		SilverCardSave[i].nCardOwner = nOwner;
	}

	// Save gold card data in array that travels/goes to save gaem.
	siCards = StatusItemWizardCards(sgCards.GetStatusItem(class'StatusItemGoldCards'));
	for (i=0; i<ArrayCount(GoldCardSave); i++)
	{
		siCards.GetCardData(i, nId, nOwner);
		GoldCardSave[i].nCardId    = nId;
		GoldCardSave[i].nCardOwner = nOwner;
	}

	// Save off last card type picked up
	nLastCardTypeSave = sgCards.GetLastObtainedCardTypeAsInt();
}


/*
function ClearNonTravelStatus()
{
  local StatusGroup sgLoop;
  local StatusItem siLoop;
  local int nStatusIdx;

  nStatusIdx = 0;
JL001B:
  sgLoop = managerStatus.sgList;
  if ( sgLoop != None )
  {
    siLoop = sgLoop.siList;
    if ( siLoop != None )
    {
      if (  !siLoop.bTravelStatus )
      {
        siLoop.nCount = 0;
        siLoop.nMaxCount = 0;
        siLoop.nCurrCountPotential = 0;
      }
      siLoop = siLoop.siNext;
      goto JL003A;
    }
    sgLoop = sgLoop.sgNext;
    goto JL001B;
  }
}
*/

function ClearNonTravelStatus()
{
	local StatusGroup            sgLoop;
	local StatusItem             siLoop;
	local int                    nStatusIdx;

	// Setup StatusSave array with status item information to carry
	// onto next level or into restored game
	nStatusIdx = 0;
	for (sgLoop=managerStatus.sgList; sgLoop!=None; sgLoop=sgLoop.sgNext)
	{
		for (siLoop=sgLoop.siList; siLoop!=None; siLoop=siLoop.siNext)
		{
            if (!siLoop.bTravelStatus)
            {
                siLoop.nCount = 0;
                siLoop.nMaxCount = 0;
                siLoop.nCurrCountPotential = 0;
            }
        }
    }
}

function HandleSpellIncantationSound (ESpellType SpellType)
{
  if ( bInDuelingMode )
  {
    if ( Duellist(DuelOpponent).TimeLeftUntilSafeToSayAComment(True) > 0 )
    {
      return;
    }
  }
  PlayIncantationEmoteSound(SpellType);
  PlaySpellCastSound(SpellType);
}

function CheckIfHarryLostDuel()
{
  if ( (managerStatus.GetHealthCount() <= 0) &&  !bDuelIsOver )
  {
    bDuelIsOver = True;
    UpdateDuelingRanks(False);
    Duellist(DuelOpponent).SayComment(DC_DuelLose,Duellist(DuelOpponent).eHouse,True);
    Duellist(DuelOpponent).SentEvent(Duellist(DuelOpponent).LostEventName);
   } else {
    // Duellist(DuelOpponent).SayComment(DC_DuelWin,Duellist(DuelOpponent).eHouse,True);
	Duellist(DuelOpponent).SayComment(DC_DuelOpp,Duellist(DuelOpponent).eHouse,True); //the old code by UTPT made Snape say Harry had won when Harry got hit... -AdamJD
 }
}

function bool HandlespellRictusempra (optional baseSpell spell, optional Vector vHitLocation)
{
  local float fTimeAfterHitNew;
  local string SpellIncantation;
  local int iDamage;

  if ( bDuelIsOver )
  {
    return False;
  }
  if ( bReboundingSpells )
  {
    switch (Rand(3))
    {
      case 0:
      SpellIncantation = "PC_Hry_SpellCast_09a";
      break;
      case 1:
      SpellIncantation = "PC_Hry_SpellCast_09b";
      break;
      case 2:
      SpellIncantation = "PC_Hry_SpellCast_09c";
      break;
      default:
    }
    PlaySound(Sound(DynamicLoadObject("AllDialog." $ SpellIncantation,Class'Sound')),SLOT_Talk);
    PlaySound(Sound'Dueling_EXP_smack',SLOT_Misc);
    spell.Reflect(self,FMin(5.0,spell.SpellCharge + (5 - spell.SpellCharge) * 0.1),FMin(1000.0,spell.Speed + (1000 - spell.Speed) * 0.25));
    baseWand(Weapon).FlashChargeParticles(Class'Exep_Shield');
    fTimeAfterShield = 1.0;
    return False;
  }
  iDamage = Duellist(DuelOpponent).DeltaHealth(True,0,spell.SpellCharge);
  if ( Difficulty > 0 )
  {
    iDamage *= Difficulty + 1;
  }
  AddHealth( -iDamage);
  CheckIfHarryLostDuel();
  PlayHurtEmoteSound();
  HarryAnimChannel.DoReactRictusempra();
  fTimeAfterHitNew = 1.0 * (1 + Duellist(DuelOpponent).Intellect); //UTPT didn't add the bit after 1.0... -AdamJD
  if ( fTimeAfterHitNew > fTimeAfterHit )
  {
    fTimeAfterHit = fTimeAfterHitNew;
  }
  return True;
}

function bool HandlespellMimblewimble (optional baseSpell spell, optional Vector vHitLocation)
{
  local string SpellIncantation;
  local int iDamage;

  if ( bDuelIsOver )
  {
    return False;
  }
  if ( bReboundingSpells )
  {
    switch (Rand(3))
    {
      case 0:
      SpellIncantation = "PC_Hry_SpellCast_09a";
      break;
      case 1:
      SpellIncantation = "PC_Hry_SpellCast_09b";
      break;
      case 2:
      SpellIncantation = "PC_Hry_SpellCast_09c";
      break;
      default:
    }
    PlaySound(Sound(DynamicLoadObject("AllDialog." $ SpellIncantation,Class'Sound')),SLOT_Talk);
    PlaySound(Sound'Dueling_EXP_smack',SLOT_Misc);
    spell.Reflect(self,FMin(5.0,spell.SpellCharge + (5 - spell.SpellCharge) * 0.1),FMin(1000.0,spell.Speed + (1000 - spell.Speed) * 0.25));
    baseWand(Weapon).FlashChargeParticles(Class'Exep_Shield');
    fTimeAfterShield = 1.0;
    return False;
  }
  PlaySound(Sound'Dueling_MIM_hit');
  if ( Rand(2) == 0 )
  {
    iDamage = Duellist(DuelOpponent).DeltaHealth(True,1,spell.SpellCharge);
    if(Difficulty > 1)
    {
      iDamage *= Difficulty + 1;
    }
    AddHealth( -iDamage);
    PlaySound(Sound'Dueling_MIM_self_damage',SLOT_Misc);
  } else {
    PlaySound(Sound'Dueling_MIM_self_lucky',SLOT_Misc);
  }
  CheckIfHarryLostDuel();
  HarryAnimChannel.DoReactMimbleWimble();
  fTimeAfterHit = 2.0 + 2 * Duellist(DuelOpponent).Intellect;
  return True;
}

function bool HandleSpellDuelExpelliarmus (optional baseSpell spell, optional Vector vHitLocation)
{
  return False;
}

function SetObjectiveTextId (string strId)
{
  strObjectiveId = strId;
}

function bool HaveObjectiveText()
{
  return strObjectiveId != "";
}

function int ConvertGameStateToNumber()
{
  local string Num;

  Num = Right(CurrentGameState,3);
  ClientMessage("*********Converting gameState: " $ CurrentGameState $ " - " $ Num);
  return int(Num);
}

function UpdateDuelingRanks (bool bWon)
{
  if ( bWon )
  {
    if ( DuelRankHarry == DuelRankOppon )
    {
      DuelRankHarry++;
      curWizardDuelRank--;
      if ( curWizardDuelRank < 0 )
      {
        curWizardDuelRank = 0;
      }
    }
  }
}

function UpdateChallengeScores (string strLevelURL, int nHighScore, int nMaxScore)
{
  local int nIdx;

  strLevelURL = Caps(strLevelURL);
  if ( InStr(strLevelURL,"CH1RICTUSEMPRA") != -1 )
  {
    nIdx = nRICTUSEMPRA_CHALLENGE_IDX;
  } else //{
    if ( InStr(strLevelURL,"CH2SKURGE") != -1 )
    {
      nIdx = nSKURGE_CHALLENGE_IDX;
    } else //{
      if ( InStr(strLevelURL,"CH3DIFFINDO") != -1 )
      {
        nIdx = nDIFFINDO_CHALLENGE_IDX;
      } else //{
        if ( InStr(strLevelURL,"CH4SPONGIFY") != -1 )
        {
          nIdx = nSPONGIFY_CHALLENGE_IDX;
        } else {
          ClientMessage("ERROR: Invalid Challenge Level URL passed in" $ strLevelURL);
          return;
        }
      // }
    // }
  // }
  if ( (nIdx < nRICTUSEMPRA_CHALLENGE_IDX) || (nIdx >= 4) )
  {
    ClientMessage("ERROR: Unrecognized challenge level");
  } else {
    if ( nHighScore > ChallengeScores[nIdx].nHighScore )
    {
      ChallengeScores[nIdx].nHighScore = nHighScore;
    }
    ChallengeScores[nIdx].nMaxScore = nMaxScore;
  }
}

function GetRictusempraChallengeScore (out int nHighScore, out int nMaxScore)
{
  nHighScore = ChallengeScores[0].nHighScore;
  nMaxScore = ChallengeScores[0].nMaxScore;
}

function GetSkurgeChallengeScore (out int nHighScore, out int nMaxScore)
{
  nHighScore = ChallengeScores[1].nHighScore;
  nMaxScore = ChallengeScores[1].nMaxScore;
}

function GetDiffindoChallengeScore (out int nHighScore, out int nMaxScore)
{
  nHighScore = ChallengeScores[2].nHighScore;
  nMaxScore = ChallengeScores[2].nMaxScore;
}

function GetSpongifyChallengeScore (out int nHighScore, out int nMaxScore)
{
  nHighScore = ChallengeScores[3].nHighScore;
  nMaxScore = ChallengeScores[3].nMaxScore;
}

event ViewFlash (float DeltaTime)
{
  if ( bForceBlackScreen )
  {
    FlashFog.W = 0.0;
    FlashFog.X = 0.0;
    FlashFog.Y = 0.0;
    FlashFog.Z = 0.0;
    return;
  }
  Super.ViewFlash(DeltaTime);
}

// Omega: Notification for having a controller get plugged in
// ported from Cruciatus Child, but nothing here uses it yet
function ControllerPluggedIn(bool bUsingController)
{
	
}

defaultproperties
{
    bAutoCenterCamera=True

    bMoveWhileCasting=True

    bAutoQuaff=True

    ShadowClass=Class'HarryShadow'

    eaid="xa37dd45ffe10EU-0000029655-SD-00807cb3fa231144fe2e33ae4783feead2b8a73ff021fac326df0ef9753ab9cdf6573ddff0312fab0b0ff39779eaff312x"

    HurtSound(0)=Sound'HPSounds.Har_Emotes.ouch1'

    HurtSound(1)=Sound'HPSounds.Har_Emotes.ouch2'

    HurtSound(2)=Sound'HPSounds.Har_Emotes.ouch3'

    HurtSound(3)=Sound'HPSounds.Har_Emotes.ouch4'

    HurtSound(4)=Sound'HPSounds.Har_Emotes.ouch5'

    HurtSound(5)=Sound'HPSounds.Har_Emotes.ouch6'

    HurtSound(6)=Sound'HPSounds.Har_Emotes.ouch7'

    HurtSound(7)=Sound'HPSounds.Har_Emotes.ouch8'

    HurtSound(8)=Sound'HPSounds.Har_Emotes.ouch9'

    HurtSound(9)=Sound'HPSounds.Har_Emotes.ouch10'

    HurtSound(10)=Sound'HPSounds.Har_Emotes.ouch11'

    HurtSound(11)=Sound'HPSounds.Har_Emotes.ouch12'

    HurtSound(12)=Sound'HPSounds.Har_Emotes.ouch13'

    HurtSound(13)=Sound'HPSounds.Har_Emotes.oof1'

    HurtSound(14)=Sound'HPSounds.Har_Emotes.oof2'

    turnRate=1000.00

    maxPointsPerHouse=150

    HarryMultipleForGryffindor=3

    DuelSpells(0)=Class'spellRictusempra'

    DuelSpells(1)=Class'spellMimblewimble'

    DuelSpells(2)=Class'spellExpelliarmus'

    DuelSpellSwitchSounds(0)=Sound'HPSounds.Magic_sfx.Dueling_switch2RIC'

    DuelSpellSwitchSounds(1)=Sound'HPSounds.Magic_sfx.Dueling_switch2MIM'

    DuelSpellSwitchSounds(2)=Sound'HPSounds.Magic_sfx.Dueling_switch2EXP'

    DuelRankHarry=1

    fDamageMultiplier_Easy=1.20

    fDamageMultiplier_Medium=2.00

    fDamageMultiplier_Hard=3.00

	fDamageMultiplier_Custom=5.00

    fMinDamageScalar=1.00

    bCanUseWeapon=True

    SpongifyFallAnim=spongify

	//AnimFalling=''
	//fix for KW using '' instead of "" and added the name (to be compatible with the new engine) -AdamJD
    AnimFalling="fall"

    HarryAnims(0)=(Idle=Idle,Walk=Walk,run=run,WalkBack=runback,StrafeRight=StrafeRight,StrafeLeft=StrafeLeft,Jump=Jump,Jump2=Jump2,Fall=Fall,Land=Land)

    HarryAnims(1)=(Idle=Idle,Walk=ectowalk,run=ectowalk,WalkBack=EctoWalkback,StrafeRight=ectostraferight,StrafeLeft=ectostrafeleft,Jump=ectojump,Jump2=Jump2,Fall=Fall,Land=Land)

    HarryAnims(2)=(Idle=idlesleepy,Walk=SleepyWalk,run=SleepyWalk,WalkBack=SleepyWalkBack,StrafeRight=sleepyStrafeRight,StrafeLeft=sleepyStrafeLeft,Jump=sleepyjump,Jump2=Jump2,Fall=Fall,Land=Land)

    HarryAnims(3)=(Idle=SwordIdle,Walk=Walk,run=SwordRun,WalkBack=SwordRunback,StrafeRight=SwordStrafeRight,StrafeLeft=SwordStrafeLeft,Jump=SwordJump,Jump2=SwordJump2,Fall=SwordFall,Land=SwordLand)

    HarryAnims(4)=(Idle=Idle,Walk=webmove,run=webmove,WalkBack=webmove,StrafeRight=webmove,StrafeLeft=webmove,Jump=ectojump,Jump2=ectojump,Fall=Fall,Land=Land)

    HarryAnims(5)=(Idle=duel_idle,Walk=duel_run,run=duel_run,WalkBack=duel_runback,StrafeRight=duel_strafe_right,StrafeLeft=duel_strafe_left,Jump=None,Jump2=None,Fall=None,Land=None)

    bAllowHarryToDie=True

    ConstrainYawVariance=5500

    GroundJumpSpeed=200.00

    GroundEctoSpeed=50.00

    iMaxSleepyAnim=6

    fSleepySpeed=50.00

    fWebSpeed=145.00

    FootOffsetZ=-34.00

    HighestZ=-999999.00

    quidGameResults(0)=(Opponent="Hufflepuff",myScore=0,OpponentScore=0,HousePoints=0,bLocked=True,bWon=False)

    quidGameResults(1)=(Opponent="Ravenclaw",myScore=0,OpponentScore=0,HousePoints=0,bLocked=True,bWon=False)

    quidGameResults(2)=(Opponent="Slytherin",myScore=0,OpponentScore=0,HousePoints=0,bLocked=True,bWon=False)

    quidGameResults(3)=(Opponent="Hufflepuff",myScore=0,OpponentScore=0,HousePoints=0,bLocked=True,bWon=False)

    quidGameResults(4)=(Opponent="Ravenclaw",myScore=0,OpponentScore=0,HousePoints=0,bLocked=True,bWon=False)

    quidGameResults(5)=(Opponent="Slytherin",myScore=0,OpponentScore=0,HousePoints=0,bLocked=True,bWon=False)

    curWizardDuelRank=10

    lastUnlockedDuelist=8

    iMinHealthAfterDeath=41

    DesiredSpeed=1.00

    GroundSpeed=210.00

    AirSpeed=400.00

    AccelRate=1024.00

    JumpZ=245.00

    MaxMountHeight=96.50

    AirControl=0.25

    BaseEyeHeight=40.75

    EyeHeight=40.75

    MenuName="Harry"

    bDoEyeBlinks=True

    DrawType=DT_Mesh

    Mesh=SkeletalMesh'HPModels.skharryMesh'

    AmbientGlow=65

    CollisionRadius=15.00

    CollisionHeight=42.00

    Buoyancy=118.80

    RotationRate=(Pitch=20000,Yaw=70000,Roll=3072)
	
	// Metallicafan212:	Tune moveto/movetoward closer to what stock HP2 was
	MinMoveDestDist=75.0
}
