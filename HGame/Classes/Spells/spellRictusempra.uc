//================================================================================
// spellRictusempra.
//================================================================================

class spellRictusempra extends baseSpell;

function OnSpellInit()
{
	Super.OnSpellInit();

	local float fDistMod;

	CurrentDir = vector(Rotation);
	fDistMod = VSize(TargetActor.Location - Location) / 800;
	if ( fDistMod > 1.0 )
	{
		fDistMod = 1.0;
	}
	SeekSpeed += 1.0 - fDistMod;
	CurrentDir.X += (FRand() - 0.4) * fDistMod;
	CurrentDir.Y += (FRand() - 0.4) * fDistMod;
	CurrentDir.Z += (FRand() * 0.5) * fDistMod;
	PlayerHarry.ClientMessage(" fDistMod = " $ string(fDistMod) $ " curDir = " $ string(CurrentDir));
	SetRotation(rotator(CurrentDir));

	if (PlayerHarry.bInDuelingMode)
	{
		SeekSpeed = 0.0;
	}
}

defaultproperties
{
    SpellIcon=None

    SeekSpeed=5.00

    fxFlyParticleEffectClass=Class'HPParticle.Rictusempra_fly'

    fxHitParticleEffectClass=Class'HPParticle.Rictusempra_hit'

    SpellIncantation="spells1"

    QuietSpellIncantation="spells10"

	DrawType=DT_None

	SpellName=Rictusempra
}
