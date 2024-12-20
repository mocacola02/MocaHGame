//================================================================================
// FadeViewTrigger.
//================================================================================

class FadeViewTrigger extends Triggers;

var() bool bTriggerOnceOnly;
var() bool bFlash;
var() float fadetime;
var() float A;
var() float R;
var() float G;
var() float B;
var FadeViewController FadeController;
var bool bTriggered;
var harry PlayerHarry;

event BeginPlay ()
{
	Super.BeginPlay();
	PlayerHarry = harry(Level.PlayerHarryActor);
	bTriggered = False;
	//Disable('Tick');
}

event Trigger (Actor Other, Pawn EventInstigator)
{
	local float tempFadeTime;
	// Omega: Don't screenflash if we're cutscene skipping
	if ( bTriggerOnceOnly && bTriggered || (HPHud(PlayerHarry.MyHud).managerCutScene.bShowFF && bFlash))
	{
		// Omega: Also treat it as if it did go off
		if(HPHud(PlayerHarry.MyHud).managerCutScene.bShowFF)
		{
			bTriggered = True;
		}

		return;
	}

	// Omega: We fell through, we may need to modify fadetime
	if(HPHud(PlayerHarry.MyHud).managerCutScene.bShowFF)
	{
		tempFadeTime = 0.0;
	}
	else
	{
		tempFadeTime = fadetime;
	}

	bTriggered = True;
	FadeController = Spawn(Class'FadeViewController');
	A = FClamp(A / 255.0, 0.0, 1.0);
	R = FClamp(R / 255.0, 0.0, 1.0);
	G = FClamp(G / 255.0, 0.0, 1.0);
	B = FClamp(B / 255.0, 0.0, 1.0);
	FadeController.Init(A, R, G, B, /*fadetime*/ tempFadeTime, bFlash);
	PlayerHarry.ClientMessage(" FadeStart = " $ string(FadeController.FadeStart.X) $ " " $ string(FadeController.FadeStart.Y) $ " " $ string(FadeController.FadeStart.Z) $ " " $ string(FadeController.FadeStart.W));
	PlayerHarry.ClientMessage(" FadeEnd = " $ string(FadeController.FadeEnd.X) $ " " $ string(FadeController.FadeEnd.Y) $ " " $ string(FadeController.FadeEnd.Z) $ " " $ string(FadeController.FadeEnd.W));
}

defaultproperties
{
    bFlash=True

    fadetime=0.25

    A=0.00

    R=255.00

    G=255.00

    B=255.00

    bStatic=True

}
