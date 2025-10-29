// HActor. I decided to add this so I can easily add widespread features to all non-Pawn HGame actors.
// This may not be the most efficient method, so this is subject to change.
class HActor extends Actor;

var(Spells) class<baseSpell> WeakToSpell; // Moca: This replaces eVulnerableToSpell. Please do not use eVulnerableToSpell.

var harry PlayerHarry;


event PostBeginPlay()
{
	Super.PostBeginPlay();

	PlayerHarry = harry(Level.PlayerHarryActor);

	ResolveEVulnerableToSpell();
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

function ResolveEVulnerableToSpell()
{
	if (eVulnerableToSpell != SPELL_None)
	{
		print("WARNING!!!! eVulnerableToSpell is obsolete! Please use WeakToSpell! Spells will still work, but this is not recommended.",true);

		switch(eVulnerableToSpell)
		{
			case SPELL_Alohomora: WeakToSpell = class'spellAlohomora'; break;
			case SPELL_Lumos: WeakToSpell = class'spellLumos'; break;
			case SPELL_Flipendo: WeakToSpell = class'spellFlipendo'; break;
			case SPELL_Diffindo: WeakToSpell = class'spellDiffindo'; break;
			case SPELL_Skurge: WeakToSpell = class'spellSkurge'; break;
			case SPELL_Spongify: WeakToSpell = class'spellSpongify'; break;
			case SPELL_Rictusempra: WeakToSpell = class'spellRictusempra'; break;
			case SPELL_DuelRictusempra: WeakToSpell = class'spellDuelRictusempra'; break;
			case SPELL_DuelMimblewimble: WeakToSpell = class'spellDuelMimblewimble'; break;
			case SPELL_DuelExpelliarmus: WeakToSpell = class'spellDuelExpelliarmus'; break;
			default:
				CMAndLog(string(self) $ " says: Couldn't match eVulnerableToSpell to WeakToSpell, defaulting to Flipendo",true);
				WeakToSpell = class'spellFlipendo';
				break;
		}
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