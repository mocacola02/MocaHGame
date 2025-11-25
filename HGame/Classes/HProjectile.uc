class HProjectile extends Projectile;

var int MinAccuracy;
var int MaxAccuracy;

var harry PlayerHarry;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	PlayerHarry = harry(Level.PlayerHarryActor);
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

defaultproperties
{
	TransientSoundVolume=1.0
}