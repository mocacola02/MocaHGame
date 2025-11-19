// HActor. I decided to add this so I can easily add widespread features to all non-Pawn HGame actors.
// This may not be the most efficient method, so this is subject to change.
class HActor extends Actor;

var harry PlayerHarry;


event PostBeginPlay()
{
	Super.PostBeginPlay();

	PlayerHarry = harry(Level.PlayerHarryActor);

	ResolveEVulnerableToSpell();
}

function bool HandleSpell(class<baseSpell> HitSpell)
{
	if (HitSpell == SpellVulnerableTo)
	{
		ProcessSpell();
		return true;
	}
	else
	{
		return false;
	}
}

function ProcessSpell(class<baseSpell> HitSpell); // Define in child classes

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
		print("WARNING!!!! eVulnerableToSpell is obsolete! Please use SpellVulnerableTo! Spells will still work, but this is not recommended.",true);

		switch(eVulnerableToSpell)
		{
			case SPELL_Alohomora: SpellVulnerableTo = class'spellAlohomora'; break;
			case SPELL_Lumos: SpellVulnerableTo = class'spellLumos'; break;
			case SPELL_Flipendo: SpellVulnerableTo = class'spellFlipendo'; break;
			case SPELL_Diffindo: SpellVulnerableTo = class'spellDiffindo'; break;
			case SPELL_Skurge: SpellVulnerableTo = class'spellSkurge'; break;
			case SPELL_Spongify: SpellVulnerableTo = class'spellSpongify'; break;
			case SPELL_Rictusempra: SpellVulnerableTo = class'spellRictusempra'; break;
			case SPELL_DuelRictusempra: SpellVulnerableTo = class'spellRictusempra'; break;
			case SPELL_DuelMimblewimble: SpellVulnerableTo = class'spellMimblewimble'; break;
			case SPELL_DuelExpelliarmus: SpellVulnerableTo = class'spellExpelliarmus'; break;
			default:
				CMAndLog(string(self) $ " says: Couldn't match eVulnerableToSpell to SpellVulnerableTo, defaulting to Flipendo",true);
				SpellVulnerableTo = class'spellFlipendo';
				break;
		}
	}
}

function bool IsOtherLookingAt(Actor Other, float minDot)
{
    return ( IsOtherFacing(Other, minDot) && PlayerCanSeeMe() );
}