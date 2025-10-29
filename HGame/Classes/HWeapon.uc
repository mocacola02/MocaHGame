//================================================================================
// HWeapon.
//================================================================================

class HWeapon extends Weapon;

var harry PlayerHarry;
var cHarryAnimChannel HarryAnimChannel;

function SecondaryFireAction();
function PrimaryFireAction();

event PostBeginPlay()
{
	super.PostBeginPlay();

	PlayerHarry = harry(Owner);

	if (PlayerHarry == None)
	{
		print("Not connected to Harry yet!");
		return;
	}

	
}

// Moca: I'm adding this since 1) I'm used to print() in Godot lmfao and 2) I can have it clearly mark the "speaker" of the message
function Print(string msg, optional bool BothLogs)
{
	if (msg == "")
	{
		return;
	}

	if (BothLogs)
	{
		CMAndLog(string(self) $ " says: " $ msg);
	}
	else
	{
		Log(string(self) $ " says: " $ msg);
	}
}

function ChangePlayer(harry NewPlayer)
{
	if (PlayerHarry != harry(Level.PlayerHarryActor))
	{
		PlayerHarry = harry(Level.PlayerHarryActor);
		CMAndLog(string(self) $ " says: ")
	}
}

function Fire(float Value)
{
	SecondaryFireAction();
}

function AltFire(float Value)
{
	PrimaryFireAction();
}