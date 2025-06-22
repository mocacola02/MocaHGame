//================================================================================
// TriggerShakeCamera.
//================================================================================

class TriggerShakeCamera extends Triggers;

var() float fShakeTime;
var() float fRollMagnitude;
var() float fVertMagnitude;

// Metallicafan212:	Force this trigger to always work
function GlobalTriggerHandler( actor Other, pawn EventInstigator )
{
	// Metallicafan212:	We use global, as KW are shitty coders so the trigger states are causing issues
	Global.Trigger(Other, EventInstigator);
}

event Trigger (Actor Other, Pawn EventInstigator)
{
  ProcessTrigger();
}

function ProcessTrigger()
{
  harry(Level.PlayerHarryActor).ShakeView(fShakeTime,fRollMagnitude,fVertMagnitude);
}

defaultproperties
{
    fShakeTime=2.00

    fRollMagnitude=100.00

    fVertMagnitude=100.00

}
