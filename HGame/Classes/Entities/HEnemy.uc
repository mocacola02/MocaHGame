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

var(Combat) bool bBumpHurtsHarry;
var(Combat) int BumpDamage;

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

event Bump(Actor Other)
{
	if ( Other == PlayerHarry )
	{
		if ( bHuntingHarry && bBumpHurtsHarry )
		{
			PlayerHarry.TakeDamage(BumpDamage,self,Location,Velocity,'BumpDamage');
		}

		if ( CanBumpLine() )
		{
			DoBumpLine();
			return;
		}
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
// Audio
//-------------------------------------
// spooky scary sound function
// essentially just PlaySound but you can make the volume, radius, and pitch randomized, may move this to HPawn if needed
function PlayEnemySound(Sound SoundToPlay, optional ESoundSlot SoundSlot,
						optional float MinVolume, optional float MaxVolume,
						optional float MinRadius, optional float MaxRadius,
						optional float MinPitch, optional float MaxPitch,
						optional bool bDisable3D, optional bool bLoop)
{
	local float FinalVolume;
	local float FinalRadius;
	local float FinalPitch;

	if ( SoundToPlay != None )
	{
		if ( MinVolume <= 0.0 && MaxVolume <= 0.0 )
		{
			MinVolume = TransientSoundVolume;
			MaxVolume = TransientSoundVolume;
		}
		if ( MinRadius <= 0.0 && MaxRadius <= 0.0 )
		{
			MinRadius = TransientSoundRadius;
			MaxRadius = TransientSoundRadius;
		}
		if ( MinPitch <= 0.0 && MaxPitch <= 0.0 )
		{
			MinPitch = TransientSoundPitch;
			MaxPitch = TransientSoundPitch;
		}

		FinalVolume = RandRange(MinVolume,MaxVolume);
		FinalRadius = RandRange(MinRadius,MaxRadius);
		FinalPitch = RandRange(MinPitch,MaxPitch);

		PlaySound(SoundToPlay,SoundSlot,FinalVolume,,FinalRadius,FinalPitch,bDisable3D,bLoop);
	}
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