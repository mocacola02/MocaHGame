//==========================================
//
//	HChar. Initially rewritten 11/24/2025
//
//==========================================

class HChar extends HPawn;

auto state stateIdle
{
	begin:
		if ( bFidget )
		{
			PlayAnim(GetCurrentFidgetAnim(),,0.2);
			FinishAnim();
		}

		Sleep(GetFidgetDelay());
		SleepForTick();
		Goto('begin');
}

defaultproperties
{
	bCanBumpLine=True
	bRandomBumpLine=True
	bBumpLineIs2D=True
	BumpLineAnim=Idle
	BumpSetFile="BumpSet"
	BumpSetLocalizationFile="BumpDialog"	
	BumpSetPackage="AllDialog"
	BumpSetSection="All"
	BumpLineCooldown=0.75
	LastBumpline=99
	
	bFidget=True

	IdleAnimations(0)=Idle
	FidgetAnimations(0)=fidget_1
	FidgetAnimations(1)=fidget_2
	FidgetAnimations(2)=fidget_3
	FidgetAnimations(3)=fidget_4

	FootstepSoundSet=Class'FootstepSet'
}