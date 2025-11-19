//================================================================================
// spellExpelliarmus.
//================================================================================

class spellExpelliarmus extends baseSpell;
/* 
function Color Col (float R, float G, float B)
{
	local Color C;
	
	//UTPT didn't add this... -AdamJD
	C.R = R;
	C.G = G;
	C.B = B;
	
	//or this... -AdamJD
	return C;
} */

defaultproperties
{
    SpellIcon=None

    SpellLifeTime=1.00

    SeekSpeed=0.00

    HitParticleFX=Class'HPParticle.Lumos_hit'

    SpellIncantation="spells3"

    QuietSpellIncantation="spells4"

    Speed=0.00

	DrawType=DT_None

	SpellName=Expelliarmus
}
