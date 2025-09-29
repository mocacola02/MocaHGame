//================================================================================
// Jellybean.
//================================================================================

class Jellybean extends HCollectible;

var() array<Texture> JellybeanSkins;	// Moca: Array of possible bean textures. Randomly selected on spawn.

event PreBeginPlay()
{
  Super.PreBeginPlay();

  Skin = JellybeanSkins[Rand(JellybeanSkins.Length)];
}

defaultproperties
{
	bBounceIntoPlace=True

	bGnomeable=True

	EventToSendOnPickup=JellyBeanPickupEvent

	TargetStatusGroup=Class'StatusGroupJellybeans'

	TargetStatusItem=Class'StatusItemJellybeans'

	BounceSounds(0)=Sound'HPSounds.Magic_sfx.bean_bounce'

	Physics=PHYS_Walking

	Mesh=SkeletalMesh'HProps.skJellybeanMesh'

	JellybeanSkins(0)=Texture'skBeanBlueSpotTex0'
	JellybeanSkins(1)=Texture'skJellybeanTex0'
	JellybeanSkins(2)=Texture'skBeanBlackTex0'
	JellybeanSkins(3)=Texture'skBeanPurpleTex0'
	JellybeanSkins(4)=Texture'skBeanRedTex0'
	JellybeanSkins(5)=Texture'skBeanDarkGreenTex0'
	JellybeanSkins(6)=Texture'skBeanBogieTex0'
	JellybeanSkins(7)=Texture'skBlueJellyBeanTex0'
	JellybeanSkins(8)=Texture'skGreenJellyBeanTex0'
	JellybeanSkins(9)=Texture'skGreenPurpleCheckerBeanTex0'
	JellybeanSkins(10)=Texture'skSpottedJellyBeanTex0'
	JellybeanSkins(11)=Texture'skRedBlackStripeBeanTex0'
	JellybeanSkins(12)=Texture'skBeanBrownTex0'
	JellybeanSkins(13)=Texture'skBeanDkBlueTex0'
	JellybeanSkins(14)=Texture'skBeanMauveTex0'
	JellybeanSkins(15)=Texture'skBeanOrngeTex0'
	JellybeanSkins(16)=Texture'skBeanYellowyTex0'
}
