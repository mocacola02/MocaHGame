class HProjectile extends Projectile;

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