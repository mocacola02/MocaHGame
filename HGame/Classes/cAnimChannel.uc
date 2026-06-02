//==========================================================================//
// cAnimChannel.
//
// Allows playing animations on top of other animations.
// Used for dueling animations.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class cAnimChannel extends AnimChannel;

var bool bCasting;						// Are we casting?
var int LastAnimFrame;				// Last animation frame.
var float fTimeInRictusempra;	// How long have we been reacting to rictu?
var float fTimeInMimbleWimble;// How long have we been reacting to mimble?


//=================
// Main Functions
//=================

// Makes the Duellist owner cast
function Cast()
{
	Duellist(Owner).Cast();
}

// If not casting, goes to casting state
function DoCast()
{
	if ( !IsInState('stateCast') )
	{
		GotoState('stateCast');
	}
}

// If not charging, go to charging state
function DoCharging()
{
	if ( !IsInState('stateCharging') )
	{
		GotoState('stateCharging');
	}
}

// If not in defence, go to defence state
function DoDefence()
{
	if ( !IsInState('stateDefence') )
	{
		GotoState('stateDefence');
	}
}

// If not in knockback, go to knockback state
function DoKnockBack()
{
	if ( !IsInState('stateKnockBack') )
	{
		GotoState('stateKnockBack');
	}
}

// If not reacting to rictu, go to rictu react state
function DoReactRictusempra()
{
	if ( !IsInState('stateReactRictusempra') )
	{
		GotoState('stateReactRictusempra');
	}
}

// Quits to stateIdle, making the duellist patrol or charge rictu
// Very unclear function name lol
function QuitThisState (bool rictusempra)
{
	Duellist(Owner).GotoState('statePatrol');

	if ( rictusempra )
	{
		Duellist(Owner).StartCharging();
	}

	GotoState('stateIdle');
}

// If not reacting to mimble, go to mimble react state
function DoReactMimbleWimble()
{
	if ( !IsInState('stateReactMimbleWimble') )
	{
		GotoState('stateReactMimbleWimble');
	}
}


//=====================
// States
//=====================

// Default idle state
auto state stateIdle
{
	// On enter state, play idle anim on duellist owner
	event BeginState()
	{
		Duellist(Owner).PlayIdle();
	}
}

// Casting state
state stateCast
{
	// On event start, set that we're casting and set to combine anims
	event BeginState()
	{
		bCasting = True;
		Duellist(Owner).DuellistAnimType =  AT_Combine;
	}
  
	// On tick
	event Tick (float DeltaTime)
	{
		local int Frame;
	
		// Call parent tick behavior
		Super.Tick(DeltaTime);

		// Set our frame to AnimFrame * 33
		Frame = AnimFrame * 33;

		// If frame is greater than or equal to 20 AND our last anim frame was less than 20, cast
		if ( (Frame >= 20) && (LastAnimFrame < 20) )
		{
			Duellist(Owner).Cast();
		}

		// Update our last anim frame
		LastAnimFrame = Frame;
	}
  
	// Begin label
	begin:
		// Play cast animation
		PlayAnim('Cast',,[TweenTime]0.3);

		// Wait until animation is finished
		FinishAnim();

		// Set to replace anims
		Duellist(Owner).DuellistAnimType =  AT_Replace;
		
		// Set that we aren't casting
		bCasting = False;

		// Go to idle
		GotoState('stateIdle');
}

// Charging state
state stateCharging
{
	// Begin label
	begin:
		// Set to combine anims
		Duellist(Owner).DuellistAnimType =  AT_Combine;
		
		// Loop the charge anim with a tween time of 0.3
		LoopAnim('duel_charge', [TweenTime]0.3);

		// Go to idle state
		GotoState('stateIdle');
}

// Defence state
state stateDefence
{
	// On enter state
	event BeginState()
	{
		// Set that we're casting
		bCasting = True;

		// Allow rebounding spells
		Duellist(Owner).bReboundingSpells = True;

		// Set to combine anims
		Duellist(Owner).DuellistAnimType =  AT_Combine;
	}
	
	// Begin label
	begin:
		// Tell duellist to defend
		Duellist(Owner).Defence();

		// Play expelliarmus anim with a tween time of 0.3
		PlayAnim('cast_Expelliarmus', [TweenTime]0.3);
		
		// Wait until anim is finished
		FinishAnim();

		// Set to replace anims
		Duellist(Owner).DuellistAnimType =  AT_Replace;

		// Disallow rebounding spells
		Duellist(Owner).bReboundingSpells = False;

		// Set that we're not casting
		bCasting = False;

		// Go to idle state
		GotoState('stateIdle');
}

// Knockback state
state stateKnockBack
{
	// Begin label
	begin:
		// Set to combine anims
		Duellist(Owner).DuellistAnimType =  AT_Combine;

		// Play backfire anim with a tween time of 0.3
		PlayAnim('react_backfire', [TweenTime]0.3);

		// Wait until anim is finished
		FinishAnim();
		
		// Set to replace anims
		Duellist(Owner).DuellistAnimType =  AT_Replace;

		// Go to idle state
		GotoState('stateIdle');
}

// Rictusempra reaction state
state stateReactRictusempra
{
	// On enter state, set to combine anims and set rictu time to 0.0
	event BeginState()
	{
		Duellist(Owner).DuellistAnimType =  AT_Combine;
		fTimeInRictusempra = 0.0;
	}

	// On tick
	event Tick (float DeltaTime)
	{
		// Increment rictu time
		fTimeInRictusempra += DeltaTime;

		// If rictu time is over 2, quit state
		if ( fTimeInRictusempra > 2 )
		{
			QuitThisState(True);
		}
	}
	
	// Begin label
	begin:
		// Tell duellist to stop charging spell
		Duellist(Owner).StopCharging();

		// Play rictu react anim with a tween time of 0.3
		PlayAnim('react_rictusempra', [TweenTime]0.3);

		// Wait for 0.1
		Sleep(0.1);

		// Wait for anim to finish (why call sleep before this?)
		FinishAnim();

		// Set to replace anims
		Duellist(Owner).DuellistAnimType =  AT_Replace;

		// Quit this state, resuming rictu charge
		QuitThisState(True);
}

state stateReactMimbleWimble
{
	// On enter state, set to combine anims and set mimble time to 0.0
	event BeginState()
	{
		Duellist(Owner).DuellistAnimType =  AT_Combine;
		fTimeInMimbleWimble = 0.0;
	}

	// On tick
	event Tick (float DeltaTime)
	{
		// Increment mimble time
		fTimeInMimbleWimble += DeltaTime;

		// If mimble time is over 2, quit this state without charging rictu
		if ( fTimeInMimbleWimble > 2 )
		{
			QuitThisState(False);
		}
	}
	
	// Begin label
	begin:
		// Tell duellist to stop charging
		Duellist(Owner).StopCharging();

		// Play mimble anim with a tween time of 0.3
		PlayAnim('mimblewimble', [TweenTime]0.3);
		
		// Wait for 0.1
		Sleep(0.1);

		// Wait for anim to finish (why call sleep before this?)
		FinishAnim();

		// Set to replace anims
		Duellist(Owner).DuellistAnimType =  AT_Replace;

		// Quit this state without charging rictu
		QuitThisState(False);
}

