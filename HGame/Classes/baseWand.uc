//================================================================================
// baseWand.
//================================================================================

class baseWand extends HWeapon; 

var class<baseSpell> CurrentSpell;


var LumosLight LumosGlow;

var ParticleFX ChargeParticles;
var class<ParticleFX> ChargeParticleFXClass;

//-------------------------------------
// Events
//-------------------------------------

event PostBeginPlay()
{
	Super.PostBeginPlay();

	LumosGlow = Spawn(Class'LumosLight',self,,Location);
	Cursor = PlayerHarry.Cursor;
}

event Destroyed()
{
	if ( LumosGlow != None )
	{
		LumosGlow.Destroy();
	}

	if ( ChargeParticles != None)
	{
		ChargeParticles.Shutdown();
	}
	
	Super.Destroyed();
}

//-------------------------------------
// Main Actions
//-------------------------------------

function PrimaryFireAction()
{
	bPointing = True;
	
	PlayerHarry.ResetFired();
	HPConsole(Player.Console).ResetSpace();

	PlayerHarry.HarryAnimChannel.GotoStateCasting();
	PlayerHarry.HarryAnimType = AT_Combine;
}

function SecondaryFireAction()
{
	if ( Cursor.CurrentTarget != None && Cursor.CurrentTarget.SpellVulnerableTo != None)
	{
		FireSpell(Cursor.CurrentTarget.SpellVulnerableTo);
	}
}

function FireSpell(class<baseSpell> SpellToFire)
{
	local baseSpell FiredSpell;
	FiredSpell = Spawn(SpellToFire,,,Location);
	FiredSpell.TargetActor = CurrentTarget;
}

function Vector GetTraceOffset()
{
	local Vector FinalOffset;

	if ( PlayerHarry.bInDuelingMode )
	{
		return vector(PlayerHarry.Rotation) * CursorRange;
	}

	return PlayerHarry.Cam.vForward * (PlayerHarry.Cam.CurrentSet.fLookAtDistance + CursorRange);
}

function BecomeItem()
{
	Super.BecomeItem();
	bHidden = False;
}

defaultproperties
{
    ChargeParticleFXClass=Class'HPParticle.Skurge_fly'

    PickupAmmoCount=1

    FireOffset=(X=0.00,Y=-6.00,Z=-7.00)

    DeathMessage="%k inflicted magic damage upon %o with the %w."

    AutoSwitchPriority=0

    InventoryGroup=0

    PickupMessage="You got Harry's wand"

    ItemName="Wand"

    ThirdPersonMesh=SkeletalMesh'HPModels.WandMesh'

    Mesh=SkeletalMesh'HPModels.WandMesh'

    CollisionRadius=28.00

    CollisionHeight=8.00

    Mass=50.00
	
	bRespectHidden=true
}
