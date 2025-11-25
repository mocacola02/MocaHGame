//==========================================
//
//	HEnemy. Initial written 11/24/2025
//
//==========================================

class HEnemy extends HPawn;

var(EnemyAI) array<name> HatedTargetTags;	// Moca: This Enemy will attempt to attack any actors of Tag in this list, if the Enemy class supports it
var(EnemyAttack) int DamageToDeal;

var Actor HatedTarget;


//-------------------------------------
// Events
//-------------------------------------
event Tick(float DeltaTime)
{
	ProcessAttack();

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

//-------------------------------------
// Attack
//-------------------------------------
function ProcessAttack()
{
	if ( bIsHuntingHarry && CanAttack() && CanSeeHarry(0.25) )
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
	return AttitudeToPlayer == ATTITUDE_Hate;
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
	AttitudeToPlayer=ATTITUDE_Hate

	bUseAllowedAttackPhys=True
	AllowedAttackPhys(0)=PHYS_Walking
	AllowedAttackPhys(1)=PHYS_Flying
}