//================================================================================
// WarnTrigger.
//================================================================================

class WarnTrigger extends Trigger;

var() string WarningMessage;
var() float durration;
var harry PlayerHarry;

// Metallicafan212:	Force this trigger to always work
function GlobalTriggerHandler( actor Other, pawn EventInstigator )
{
	// Metallicafan212:	We use global, as KW are shitty coders so the trigger states are causing issues
	Global.Trigger(Other, EventInstigator);
}

function PostBeginPlay()
{
  Super.PostBeginPlay();
  foreach AllActors(Class'harry',PlayerHarry)
  {
    // goto JL001A;
	break;
  }
}

event Trigger (Actor Other, Pawn EventInstigator)
{
  Touch(Other);
}

function Touch (Actor Other)
{
  local Actor A;
  local harry H;

  baseHUD(PlayerHarry.myHUD).ShowPopup(Class'baseWarning');
  baseWarning(baseHUD(PlayerHarry.myHUD).curPopup).DisplayText = Localize("all",WarningMessage,"Pickup");
  baseWarning(baseHUD(PlayerHarry.myHUD).curPopup).LifeSpan = durration;
  if ( bTriggerOnceOnly )
  {
    Disable('Touch');
  }
}

defaultproperties
{
    durration=3.00

}
