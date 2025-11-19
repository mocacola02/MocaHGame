//================================================================================
// spellAcidSpit.
//================================================================================

class spellAcidSpit extends baseSpell;

var float FloorZ;
var float PoolShrinkTimeMult;

event HitWall (Vector HitNormal, Actor Wall)
{
	local AcidSpitPool A;
	local Rotator R;

	if ( Location.Z - CollisionHeight / 2 - FloorZ > 10 )
	{
		Velocity = MirrorVectorByNormal(Velocity,HitNormal);
		Velocity *= 0.25;

		if ( VSize(Velocity) < 100 )
		{
			Velocity *= 100 / VSize(Velocity);
		}
	}
	else
	{
		A = Spawn(Class'AcidSpitPool');
		R.Yaw = Rand(65536);
		A.SetRotation(R);

		if ( PoolShrinkTimeMult > 0 )
		{
			A.fShrinkTime *= PoolShrinkTimeMult;
		}

		Destroy();
	}
}

defaultproperties
{
    Damage=25

    FlyingParticleFX=Class'HPParticle.SnakeVenomFX'

    HitParticleFX=Class'HPParticle.Flip_hit'

    Speed=1000.00

    ImpactSound=Sound'HPSounds.Adv11_COS.ss_COS_venom_hit_Harry'

	Physics=PHYS_Falling

	DrawType=DT_None

    CollisionRadius=10.00

    CollisionHeight=10.00

    bBounce=True

	SpellName=AcidSpit
}
