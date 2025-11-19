//================================================================================
// AragogSpellAttack.
//================================================================================

class AragogSpellAttack extends baseSpell;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.25,False);
	Velocity = ComputeTrajectoryByTime(Location,TargetActor.Location,0.75);
	LoopAnim('Idle');
}

function Timer()
{
  	SetCollisionSize(20.0,20.0);
}

function PlayerCutCapture()
{
	Destroy();
}
	
function ProcessTouch (Actor Other, Vector HitLocation)
{
	if (  !Other.IsA('SpiderMarker') &&  !Other.IsA('largeSpider') &&  !Other.IsA('spellWeb') )
	{
		Aragog(Owner).createWeb(OldLocation);

		if ( Other.IsA('harry') )
		{
			PlayerHarry.TakeDamage(Damage,Pawn(Owner),Location,Velocity * 1,'AragogSpellAttack');
		}

		Destroy();
	}
}

event Landed (Vector HitNormal)
{
	Aragog(Owner).createWeb(OldLocation);
	Destroy();
}

defaultproperties
{

    FlyingParticleFX=Class'HPParticle.AragogAttackFx'

    HitParticleFX=Class'HPParticle.SmokeExplo_01'

	Physics=PHYS_Falling

    Mesh=SkeletalMesh'HPModels.skAragogAttackMesh'

	SpellName=AragogWeb
}
