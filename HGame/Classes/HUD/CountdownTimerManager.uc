//==========================================================================//
// CountdownTimerManager.
//
// Base class for countdown timers such as BeanRoomTimerManager
// and GoldCardTimerManager.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class CountdownTimerManager extends HudItemManager;

//= Constants =//
const fFULL_BAR_W= 118.0;	// Fully filled bar width
const fTIMER_EMPTY_W= 205.0;// Empty bar width
const fTIMER_EMPTY_H= 58.0;	// Empty bar height

//= Visuals =//
var(TimerVisual) float fFULL_OFFSET_X;			// Full bar offset on X axis
var(TimerVisual) float fFULL_OFFSET_Y;			// Full bar offset on Y axis
var(TimerVisual) string strTextureTimerEmpty;	// Name of empty bar texture
var(TimerVisual) string strTextureFullBar;		// Name of full bar texture

var Texture textureTimerEmpty;	// Reference to empty bar texture
var Texture textureFullBar;		// Reference to full bar texture

//= General Variables =//
var() bool bStartOnLevelLoad;	// Should timer appear on level load
var() float fDuration;			// Duration of the timer

var bool bShowNumericTime;		// Should timer show the numeric timer
var float fCountdownTime;		// Current countdown time
var float fLastTickTime;		// Countdown time when clock tick sound last played


//=========
// Events
//=========

// Called after gameplay begins
event PostBeginPlay()
{
	// If we should start on level load, start countdown after 0.2 seconds
	if ( bStartOnLevelLoad )
	{
		SetTimer(0.2,False);
	}

	// Load timer bar textures
	LoadTimerBarGraphics();
}

// Called on timer time out
event Timer()
{
	// If we should start on level load
	if ( bStartOnLevelLoad )
	{
		// If we don't have ref to Harry, wait longer
		if ( Level.PlayerHarryActor == None )
		{
			SetTimer(0.2,False);
		}
		// Otherwise
		else
		{
			// If we should start on level load (why are we checking again)
			if ( bStartOnLevelLoad )
			{
				// Start countdown
				StartCountDown();
			}
		}
	}
}


//==========
// Display
//==========

// Load timer bar textures from strTextureTimerEmpty and strTextureFullBar properties
function LoadTimerBarGraphics()
{
	textureTimerEmpty 		= Texture(DynamicLoadObject(strTextureTimerEmpty, Class'Texture'));
	textureFullBar 			= Texture(DynamicLoadObject(strTextureFullBar, Class'Texture'));
}

// Draws the countdown bar
function DrawCountdown(Canvas Canvas)
{
	local int Ox, Oy;
	local float fScaleFactor, fScaleFactorNoH;
	local float fFullRatio, fSegmentWidth;
	
	// Get references to Harry and his HUD if we don't have them
	CheckHUDReferences();
	
	// Apply texture filtering
	Canvas.bNoSmooth = False;

	// Get scale factor from canvas factor adjusted for height scale
	fScaleFactor = Canvas.GetHudScaleFactor() * Class'M212HScale'.Static.CanvasGetHeightScale(Canvas);
	
	// Get scale factor from canvas factor without adjusting for height scale
	fScaleFactorNoH = Canvas.GetHudScaleFactor();
	
	// Determine canvas positioning based on timer bar size and scale factor
	Ox = Canvas.SizeX - (8 * fScaleFactorNoH) - (fTIMER_EMPTY_W * fScaleFactorNoH);
	Oy = Canvas.SizeY - 8 * fScaleFactor - fTIMER_EMPTY_H * fScaleFactor;
	
	// Aligns canvas to the right side of screen
	AlignXToRight(Canvas, Ox);

	// Applies HUD scale to the target canvas X position
	Ox = ApplyHUDScale(Canvas, Ox);
	
	// Set canvas position
	Canvas.SetPos(Ox,Oy);

	// Draw the empty texture bar to the scale factor
	Canvas.DrawIcon(textureTimerEmpty,fScaleFactor);

	// Determine texture fill ratio
	fFullRatio = fCountdownTime / GetTimerDuration();

	// Determine fill bar width
	fSegmentWidth = fFullRatio * fFULL_BAR_W;

	// Place canvas inside the empty bar area
	Canvas.SetPos(Ox + fFULL_OFFSET_X * fScaleFactor,Oy + fFULL_OFFSET_Y * fScaleFactor);
	
	// Draw full bar tile, scaled based on the target segment (fill) width
	Canvas.DrawTile(textureFullBar,fSegmentWidth * fScaleFactor,textureFullBar.VSize * fScaleFactor,0.0,0.0,fSegmentWidth,textureFullBar.VSize);

	// Draw numeric timer, if needed
	DrawTuningModeData(Canvas);
}

// Draw numeric timer if bShowNumbericTime
function DrawTuningModeData(Canvas Canvas)
{
	local string strCurrTime;

	if ( bShowNumericTime )
	{
		Canvas.SetPos(Canvas.SizeX - 75,Canvas.SizeY - 60);
		strCurrTime = string(int(GetTimerDuration() - fCountdownTime));
		Canvas.DrawText(strCurrTime,False);
	}
}


//========
// Audio
//========

// Play clock tick sound if enough time has passed
function PlayCountdownSound()
{
	local BaseCam Cam;

	// If more than a second has passed
	if ( Abs(fLastTickTime - fCountdownTime) > 1.0 )
	{
		// Get reference to BaseCam to play sound from
		Cam = harry(Level.PlayerHarryActor).Cam;

		// Play higher pitch timer sound based on current countdown time
		// If we're above 30 seconds, play timer_1
		if ( fCountdownTime > 30.0 )
		{
			Cam.PlaySound(Sound'timer_1',SLOT_None,0.5,,,,True);
		}
		// Otherwise if we're above 20 seconds, play timer_2
		else if ( fCountdownTime > 20.0 )
		{
			Cam.PlaySound(Sound'timer_2',SLOT_None,0.5,,,,True);
		}
		// Otherwise if we're above 15 seconds, play timer_3
		else if ( fCountdownTime > 15.0 )
        {
			Cam.PlaySound(Sound'timer_3',SLOT_None,0.5,,,,True);
        }
		// Otherwise if we're above 10 seconds, play timer_4
		else if ( fCountdownTime > 10.0 )
		{
			Cam.PlaySound(Sound'timer_4',SLOT_None,0.5,,,,True);
		}
		// Otherwise if we're above 5 seconds, play timer_5
		else if ( fCountdownTime > 5.0 )
		{
			Cam.PlaySound(Sound'timer_5',SLOT_None,0.5,,,,True);
		}
		// Otherwise, play timer_6
		else 
		{
			Cam.PlaySound(Sound'timer_6',SLOT_None,0.5,,,,True);
		}

		// Set last tick time to current countdown time
		fLastTickTime = fCountdownTime;
	}
}


//=================
// Timer Handling
//=================

// Start the countdown
function StartCountDown()
{
	HPHud(Level.PlayerHarryActor.myHUD).RegisterCountdownTimerManager(self);
	GotoState('CountingDown');
}

// Stop the countdown
function StopCountDown()
{
	HPHud(Level.PlayerHarryActor.myHUD).RegisterCountdownTimerManager(None);
	GotoState('Idle');
}

// Get current timer duration
function float GetTimerDuration()
{
	return fDuration;
}


//====================
// Cutscene Handling
//====================

// Handle cut command
function bool CutCommand(string Command, optional string cue, optional bool bFastFlag)
{
	local string sActualCommand;
	local string sCutName;
	local Actor A;

	// Get command from full command string
	sActualCommand = ParseDelimitedString(Command," ",1,False);

	// If command is Capture, return that it succeeded (despite doing nothing)
	if ( sActualCommand ~= "Capture" )
	{
		return True;
	}
	// Otherwise, if command is Release, return that it succeeded (despite doing nothing)
	else if ( sActualCommand ~= "Release" )
    {
		return True;
    }
	// Otherwise, if command is StartCountdown, start the countdown and notify cue actor, return successful
	else if ( sActualCommand ~= "StartCountdown" )
	{
		StartCountDown();
		CutNotifyActor.CutCue(cue);
		return True;
	}
	// Otherwise, if command is StopCountdown, stop the countdown and notify cue actor, return successful
	else if ( sActualCommand ~= "StopCountdown" )
	{
		StopCountDown();
		CutNotifyActor.CutCue(cue);
		return True;
	}
	// Otherwise, return unsuccessful for all other commands
	else 
	{
		return False;
	}
}


//=========
// States
//=========

// Default idle state
auto state Idle
{
	// Called when triggered by an actor
	event Trigger(Actor Other, Pawn EventInstigator)
	{
		// Log that we're now counting down
		Level.PlayerHarryActor.ClientMessage("countdown ON");

		// Start countdown
		StartCountDown();
	}
}

// Counting down state
state CountingDown
{
	// On enter state
	event BeginState ()
	{
		// Get timer duration
		fCountdownTime = GetTimerDuration();

		// Reset last tick time to 0.0
		fLastTickTime = 0.0;
	}

	// On tick
	event Tick(float DeltaTime)
	{
		// If we're not in a cutscene or showing pop up, decrease countdown time
		if ( !HPHud(Level.PlayerHarryActor.myHUD).IsCutSceneOrPopupInProgress() )
		{
			fCountdownTime -= DeltaTime;
		}

		// If countdown is or less than 0.0, stop countdown and emit our event
		if ( fCountdownTime <= 0.0 )
		{
			StopCountDown();
			TriggerEvent(Event,None,None);
		}
	}
  
	// Called when triggered by an actor
	event Trigger(Actor Other, Pawn EventInstigator)
	{
		// Log that countdown is off
		Level.PlayerHarryActor.ClientMessage("countdown off");

		// Stop countdown
		StopCountDown();
	}
  
	// Render timer HUD elements
	function RenderHudItemManager(Canvas Canvas, bool bMenuMode, bool bFullCutMode, bool bHalfCutMode)
	{
		// If we're in menu mode, don't draw
		if ( bMenuMode )
		{
			return;
		}

		// Draw the countdown
		DrawCountdown(Canvas);

		// Play countdown sound if needed
		PlayCountdownSound();
	}
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bHidden=True

	DrawType=DT_Sprite

	CutName="CountdownTimerManager"

	strTextureTimerEmpty="HP2_Menu.Icons.HP2Timer"
	strTextureFullBar="HP2_Menu.Icons.HP2EmptyBar"

	fFULL_OFFSET_X=51.0
	fFULL_OFFSET_Y=26.0
}
