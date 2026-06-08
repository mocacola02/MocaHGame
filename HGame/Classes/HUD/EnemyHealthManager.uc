//==========================================================================//
// EnemyHealthManager.
//
// Class for enemy health bars, used primarily by Duellists and bosses.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class EnemyHealthManager extends HudItemManager;

//= Constants =//
const fSCREEN_UP_FROM_BOTTOM_Y=   110.0;	// How far up from bottom of screen to display
const fSCREEN_X= 4;							// Target X position

const fBAR_START_Y= 83;						// Bar's starting Y pos
const fBAR_START_X= 5;						// Bar's starting X pos
const fBAR_H= 20.0;							// Bar height
const fBAR_W= 116.0;						// Bar width

const strBAR_EMPTY= "HP2_Menu.Icon.HP2EnemyHealthEmpty";		// Empty bar texture name
const strBAR_SEEKER_HUF= "HP2_Menu.Icon.HP2_QuidBarHuff";		// Hufflepuff seeker texture name
const strBAR_SEEKER_SLY= "HP2_Menu.Icon.HP2_QuidBarSlyth";		// Slytherin seeker texture name
const strBAR_SEEKER_RAV= "HP2_Menu.Icon.HP2_QuidBarRave";		// Ravenclaw seeker texture name
const strBAR_SEEKER_GRY= "HP2_Menu.Icon.HP2_QuidBarGryf";		// Gryffindor seeker texture name
const strBAR_PEEVES= "HP2_Menu.Icon.HP2EnemyHealthPeeves";		// Peeves texture name
const strBAR_DUELLIST= "HP2_Menu.Icon.HP2EnemyHealthWizard";	// Duellist texture name
const strBAR_BASILISK= "HP2_Menu.Icon.HP2EnemyHealthBasilisk";	// Basilisk texture name
const strBAR_ARAGOG= "HP2_Menu.Icon.HP2EnemyHealthAragog";		// Aragog texture name

//= General Variables =//
var bool bRegisteredWithHud;// Are we registered with the HUD
var Texture textureBarFull;	// Reference to full bar texture
var Texture textureBarEmpty;// Reference to empty bar texture
var HChar Enemy;			// Reference to relevant enemy HChar


//=========
// Events
//=========

// Called after gameplay begins
event PostBeginPlay()
{
	// Call parent behavior
	Super.PostBeginPlay();

	// Load empty bar texture from constant
	textureBarEmpty = Texture(DynamicLoadObject(strBAR_EMPTY,Class'Texture'));
}


//===============
// Bar Handling
//===============

// Start displaying the bar
function Start (HChar EnemyIn)
{
	local string MatchOpponent;

	// Set enemy to given enemy actor
	Enemy = EnemyIn;

	// Determine type of health bar from enemy
	switch (EnemyIn.EnemyHealthBar)
	{
		case EnemyIn.EEnemyBar.EnemyBar_Aragog:
			textureBarFull = Texture(DynamicLoadObject(strBAR_ARAGOG,Class'Texture'));
			break;

		case EnemyIn.EEnemyBar.EnemyBar_Basilisk:
			textureBarFull = Texture(DynamicLoadObject(strBAR_BASILISK,Class'Texture'));
			break;

		case EnemyIn.EEnemyBar.EnemyBar_Duellist:
			textureBarFull = Texture(DynamicLoadObject(strBAR_DUELLIST,Class'Texture'));
			break;
			
		case EnemyIn.EEnemyBar.EnemyBar_Peeves:
			textureBarFull = Texture(DynamicLoadObject(strBAR_PEEVES,Class'Texture'));
			break;
   
		// If a seeker, determine what house they belong to
		case EnemyIn.EEnemyBar.EnemyBar_Seeker:
			switch (Seeker(EnemyIn).eHouse)
			{
		  
				case Seeker(EnemyIn).HouseAffiliation.HA_Gryffindor:
					textureBarFull = Texture(DynamicLoadObject(strBAR_SEEKER_GRY,Class'Texture'));
					break;
		  
				case Seeker(EnemyIn).HouseAffiliation.HA_Ravenclaw:
					textureBarFull = Texture(DynamicLoadObject(strBAR_SEEKER_RAV,Class'Texture'));
					break;
		
				case Seeker(EnemyIn).HouseAffiliation.HA_Hufflepuff:
					textureBarFull = Texture(DynamicLoadObject(strBAR_SEEKER_HUF,Class'Texture'));
					break;
		  
				case Seeker(EnemyIn).HouseAffiliation.HA_Slytherin:
					textureBarFull = Texture(DynamicLoadObject(strBAR_SEEKER_SLY,Class'Texture'));
					break;
			}
		break;
		
		// If nothing matches, log an error and default to duellist bar texture
		default:
			Log("ERROR: Missing enemy health enum");
			textureBarFull = Texture(DynamicLoadObject(strBAR_DUELLIST,Class'Texture'));
			break;
	}
	
	// Go to display state
	GotoState('DisplayEnemyHealth');
}

// Stop displaying the bar
function End()
{
	// Set registered enemy health bar to none
	HPHud(harry(Level.PlayerHarryActor).myHUD).RegisterEnemyHealth(None);

	// Set that we're no longer registered
	bRegisteredWithHud = False;
	
	// Go to idle state
	GotoState('Idle');
}


//=========
// States
//=========

// Default idle state
auto state Idle
{
}

// Display health state
state DisplayEnemyHealth
{
	// On tick
	event Tick (float DeltaTime)
	{
		// If not registered with HUD
		if (  !bRegisteredWithHud )
		{
			// If Harry has a HUD
			if ( Level.PlayerHarryActor.myHUD != None )
			{
				// Register self as current enemy health bar
				HPHud(harry(Level.PlayerHarryActor).myHUD).RegisterEnemyHealth(self);

				// Set that we are registered
				bRegisteredWithHud = True;
			}
		}
	}
  
	// Render health bar onto HUD
	function RenderHudItemManager (Canvas Canvas, bool bMenuMode, bool bFullCutMode, bool bHalfCutMode)
	{
		local int fIconX, fIconY;
		local float fScaleFactor;
		local float fEnemyHealth, fEmptyHealth;
		local float fEmptyW, fBarEmptyOffset;
		local float fSegmentWidth, fSegmentStartAt;
		
		// Get references to Harry and his HUD if we don't have them
		CheckHUDReferences();

		// Get scale factor from canvas factor adjusted for height scale
		fScaleFactor = GetScaleFactor(Canvas) * Class'M212HScale'.Static.CanvasGetHeightScale(Canvas);

		// Get icon's X position adjusted for scale factor
		fIconX = fSCREEN_X * fScaleFactor;

		// Get icon's Y position adjusted for scale factor, accounting for how far up from screen bottom we should be
		fIconY = Canvas.SizeY - fScaleFactor * fSCREEN_UP_FROM_BOTTOM_Y;
		
		// Align icon to left of screen
		AlignXToLeft(Canvas, fIconX);

		// Apply HUD scale to icon X position
		fIconX = ApplyHUDScale(Canvas, fIconX);
		
		// Set canvas position
		Canvas.SetPos(fIconX,fIconY);

		// Draw full bar icon
		Canvas.DrawIcon(textureBarFull,fScaleFactor);

		// Get enemy health
		fEnemyHealth = Enemy.GetHealth();

		// Ensure health value is between 0.0 and 1.0
		fEnemyHealth = FClamp(fEnemyHealth,0.0,1.0);

		// Determine how much health is missing
		fEmptyHealth = 1.0 - fEnemyHealth;

		// Determine segment (fill) width based on enemy health
		fSegmentWidth = fEnemyHealth * fBAR_W;

		// Place canvas inside the empty bar area
		Canvas.SetPos(fIconX + (fBAR_START_X * fScaleFactor), fIconY + (fBAR_START_Y * fScaleFactor));

		// Draw empty bar based on segment width
		Canvas.DrawTile(textureBarEmpty,fSegmentWidth * fScaleFactor,textureBarEmpty.VSize * fScaleFactor,0.0,0.0,fSegmentWidth,textureBarEmpty.VSize);

		// If health is under 0.0, stop showing bar
		if ( fEnemyHealth <= 0.0 )
		{
			End();
		}
	}
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bHidden=True

	DrawType=DT_Sprite
}
