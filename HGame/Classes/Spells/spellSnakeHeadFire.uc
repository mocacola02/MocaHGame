//================================================================================
// spellSnakeHeadFire.
//================================================================================

class spellSnakeHeadFire extends baseSpell;

// TODO: Change this into a flamethrower class under HProjectile

defaultproperties
{
    SpellIcon=None

    SeekSpeed=50.00

    FlyingParticleFX=Class'HPParticle.TorchFire04'

	HitParticleFX=Class'HPParticle.Flip_hit'

    SpellIncantation="spells1"

    QuietSpellIncantation="spells10"

    Damage=10.00

	DrawType=DT_None

    CollisionRadius=30.00

    CollisionHeight=30.00

	SpellName=SnakeFire
}
