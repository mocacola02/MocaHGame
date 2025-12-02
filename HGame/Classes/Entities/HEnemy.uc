//==========================================
//
//	HEnemy. Initial written 11/24/2025
//
//==========================================

class HEnemy extends HPawn;

//-------------------------------------
// AI
//-------------------------------------
var(AI) array<name> HatedTargetTags;	// Moca: This Enemy will attempt to attack any actors of Tag in this list, if the Enemy class supports it
var Actor HatedTarget;


//-------------------------------------
// Events
//-------------------------------------
event Tick(float DeltaTime)
{
	ProcessAttack();

	HandleHunt(DeltaTime);

	if ( Physics = PHYS_Walking && FootstepSoundSet != None )
	{
		DoFootstep();
	}

	if ( Physics == PHYS_Falling )
	{
		if ( LastTickPhys != PHYS_Falling )
		{
			HighestZ = Location.Z;
		}
		else if ( HighestZ < Location.Z )
		{
			HighestZ = Location.Z;
		}
	}

	if ( LastTickPhys != Physics )
	{
		LastTickPhys = Physics;
	}

	if( bDoBreath )
	{
		DoBreath(DeltaTime);
	}
}

function HandleHunt(float DeltaTime)
{
	bSeesHarry = CanSeeHarry();

	if ( bSeesHarry )
	{
		CurrentSuspicion += SuspicionGrowRate * DeltaTime;
		CurrentSuspicion = FClamp(CurrentSuspicion, 0.0, MaxSuspicion);
	}
	else if ( CurrentSuspicion > 0.0 )
	{
		CurrentSuspicion -= SuspicionLossRate * DeltaTime;
		CurrentSuspicion = FClamp(CurrentSuspicion, 0.0, MaxSuspicion);
	}
}

//-------------------------------------
// Attack
//-------------------------------------
function ProcessAttack()
{
	if ( CanAttack() )
	{
		if ( HatedTarget == None )
		{
			HatedTarget = PlayerHarry;
		}

		DoAttack();
	}
}

function DoAttack();

function EnableAttack()
{
	AttitudeToPlayer = ATTITUDE_Hate;
}

function DisableAttack()
{
	AttitudeToPlayer = ATTITUDE_Ignore;
}

function bool CanAttack()
{
	return AttitudeToPlayer == ATTITUDE_Hate && bIsHuntingHarry && bSeesHarry && ( CurrentSuspicion >= RequiredSuspicion );
}

//-------------------------------------
// CutCommands
//-------------------------------------
function CutCommand_Capture()
{
	Super.CutCommand_Capture();
	HandleCapture();
}

function PlayerCutCapture()
{
	Super.PlayerCutCapture();
	HandleCapture();
}


function CutCommand_Release()
{
	Super.CutCommand_Release();
	HandleRelease();
}

function PlayerCutRelease()
{
	Super.PlayerCutRelease();
	HandleRelease();
}

function HandleCapture()
{
	SpellVulnerableTo = None;
	AttitudeToPlayer = ATTITUDE_Ignore;
}

function HandleRelease()
{
	AttitudeToPlayer = MapDefault.AttitudeToPlayer;
	SpellVulnerableTo = MapDefault.SpellVulnerableTo;
}




//-------------------------------------
// Default Properties
//-------------------------------------
defaultproperties
{
	bIsHuntingHarry=True

	RequiredSuspicion=5.0
	MaxSuspicion=5.0

	AttitudeToPlayer=ATTITUDE_Hate
}