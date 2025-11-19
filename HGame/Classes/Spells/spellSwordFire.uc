//================================================================================
// spellSwordFire.
//================================================================================

class spellSwordFire extends baseSpell;

// TODO: Rework this to use whatever I end up making for dueling spell charges/damage

/* var() float fNormalDamage;
var() float fFullDamage;
var() float fNormalScale;
var() float fFullScale;
var float fCurrentScale;
var() float fHalfLife;
 *//* 
function bool OnHitWall (Actor Wall)
{
  if ( harry(Level.PlayerHarryActor).bMSword )
  {
		harry(Level.PlayerHarryActor).PlaySound(Sound'Big_whomp2',SLOT_None,RandRange(1.0,1.5),False,500.0,RandRange(0.5,1.0));
		Spawn(Class'DustCloud05_lrg',self,,Location);
		harry(Level.PlayerHarryActor).ShakeView(1.0,150.0,150.0);
		harry(Level.PlayerHarryActor).AutoHitAreaEffect(300.0);
  }
  return Super.OnSpellHitWall(Wall);
} */

defaultproperties
{
    SpellIcon=None

    SeekSpeed=50.00

    FlyingParticleFX=Class'HPParticle.SwordFireball'

    HitParticleFX=Class'HPParticle.Flip_hit'

    SpellIncantation="spells1"

    QuietSpellIncantation="spells10"

	DrawType=DT_None

    CollisionRadius=35.00

    CollisionHeight=35.00

	SpellName=SwordFire
}