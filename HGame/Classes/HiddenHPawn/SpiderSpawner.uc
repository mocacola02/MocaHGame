//==========================================================================//
// SpiderSpawner.
//
// Invisible spider spawner.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class SpiderSpawner extends HiddenHPawn;

//= Constants =//
const BOOL_DEBUG_AI= true;

//= Spider Params =//
struct SpiderSpawnerParams
{
	var() float NormalSpeed;				// Normal movement speed
	var() float attackSpeed;				// Attack movement speed
	var() bool canWander;					// Can spider wander
	var() bool waitForTrigger;				// Should spider wait to be triggered
	var() float forwardDistance;			// Forward distance
	var() string GroupName;					// Name of spider group to be part of
	var() int iRotation;					// Spider rotation
	var() float nextSpiderDelay;			// Delay before spawning next spider
	var() float drawingScale;				// Draw scale of spider
	var() float jumpingDistanceFromHarry;	// Allowed distance to jump towards Harry
	var() int numSpellsLargeSpider;			// Number of spells spider can take
	var() float leaveSmallDeadSpider;		// Should dead small spider be left
};

var() SpiderSpawnerParams theSpiders[5];	// Params to use when spawning spiders

//= General Variables =//
var() bool bSmallSpiders;	// Should we spawn small spiders
var() int numSpiders;		// How many spiders to spawn

var int Counter;			// How many spiders have we spawned
var float spiderYaw;		// Yaw rotation of spider
var Rotator spiderRotation;	// Rotation of spider
var SpiderSmall smallSpider;// Ref to spawned small spider
var SpiderLarge largeSpider;// Ref to spawned large spider


//=========
// Events
//=========

// Called after gameplay starts, enables world collision
event PostBeginPlay()
{
	bCollideWorld = True;
}

// Called when triggered, goes to spawning state
event Trigger (Actor Other, Pawn EventInstigator)
{
	GotoState('SpawnSomeSpiders');
}

// Called when touched, calls parent behavior, this can be deleted
event Touch (Actor Other)
{
	Super.Touch(Other);
}

// Called when bumped, redirects to Touch
event Bump (Actor Other)
{
	Touch(Other);
}


//===========
// Spawning
//===========

// Spawns a given number of random spiders, never called for some reason?
function SpawnRandomSpiders (int ns)
{
	local int randNum;
	local int numberOfSpiders;
	local int Spidercounter;
	local SpiderSmall smSpider;
	local SpiderLarge lgSpider;

	// Set number of spiders to spawn
	numberOfSpiders 	= ns;

	// For the number of spiders to spawn
	for( SpiderCounter = 0; SpiderCounter < numberOfSpiders; SpiderCounter++ )
	{
		// Get random value between 0 and number of spiders
		randNum = Rand(numSpiders);

		// If spawning small spiders
		if ( bSmallSpiders )
		{
			// Set spider rotation to our rotation
			spiderRotation 		= Rotation;

			// Convert the spider's yaw from degrees to Unreal units
			spiderYaw 			= theSpiders[randNum].iRotation * (16384 / 90.0);

			// Add spider yaw to spider's rotation
			spiderRotation.Yaw += spiderYaw;

			// Make sure yaw fits within Unreal's 16-bit rotator value
			spiderRotation.Yaw  = spiderRotation.Yaw & 65535;
			
			// Spawn small spider and set its params
			smSpider 							= Spawn(Class'SpiderSmall',self,,Location,spiderRotation);
			smSpider.NormalSpeed 				= theSpiders[randNum].NormalSpeed;
			smSpider.attackSpeed 				= theSpiders[randNum].attackSpeed;
			smSpider.GroundSpeed 				= theSpiders[randNum].NormalSpeed;
			smSpider.canWander 					= theSpiders[randNum].canWander;
			smSpider.waitForTrigger 			= theSpiders[randNum].waitForTrigger;
			smSpider.forwardDistance 			= theSpiders[randNum].forwardDistance;
			smSpider.DrawScale 					= theSpiders[randNum].drawingScale;
			smSpider.jumpingDistanceFromHarry 	= theSpiders[randNum].jumpingDistanceFromHarry;
			smSpider.GroupName 					= theSpiders[randNum].GroupName;
			smSpider.numSpellsDefault		 	= theSpiders[randNum].numSpellsLargeSpider;
			smSpider.leaveDeadSpider 			= theSpiders[randNum].leaveSmallDeadSpider;

			// Allow spider to despawn
			smSpider.bDespawnable 				= True;
		} 
		// Otherwise
		else 
		{
			// Set spider rotation to our rotation
			spiderRotation 		= Rotation;

			// Convert the spider's yaw from degrees to Unreal units
			spiderYaw 			= theSpiders[randNum].iRotation * (16384 / 90.0);

			// Add spider yaw to spider's rotation
			spiderRotation.Yaw += spiderYaw;

			// Make sure yaw fits within Unreal's 16-bit rotator value
			spiderRotation.Yaw  = spiderRotation.Yaw & 65535;
			
			// Spawn large spider and set its params
			lgSpider 							= Spawn(Class'SpiderLarge',self,,Location,spiderRotation);
			lgSpider.NormalSpeed 				= theSpiders[randNum].NormalSpeed;
			lgSpider.attackSpeed 				= theSpiders[randNum].attackSpeed;
			lgSpider.GroundSpeed 				= theSpiders[randNum].NormalSpeed;
			lgSpider.canWander 					= theSpiders[randNum].canWander;
			lgSpider.waitForTrigger 			= theSpiders[randNum].waitForTrigger;
			lgSpider.forwardDistance 			= theSpiders[randNum].forwardDistance;
			lgSpider.DrawScale 					= theSpiders[randNum].drawingScale;
			lgSpider.jumpingDistanceFromHarry 	= theSpiders[randNum].jumpingDistanceFromHarry;
			lgSpider.GroupName 					= theSpiders[randNum].GroupName;
			lgSpider.numSpellsDefault 			= theSpiders[randNum].numSpellsLargeSpider;
			lgSpider.leaveDeadSpider 			= theSpiders[randNum].leaveSmallDeadSpider;

			// Allow spider to despawn
			lgSpider.bDespawnable 				= True;
      
			// Randomly pick between jump and rear attack anim
			switch (Rand(2))
			{
				case 0:
					lgSpider.ePreAttackAnim = ATTACK_Jump;
					break;
				case 1:
					lgSpider.ePreAttackAnim = ATTACK_Rear;
					break;
        
			}
		}
	}

	// Go to waiting state
	GotoState('spiderSpawnerWait');
}


//=========
// States
//=========

// Default waiting state
auto state spiderSpawnerWait
{
}

// Spawning state
state SpawnSomeSpiders
{
	// Begin label
	begin:
		// Reset counter
		Counter = 0;

		// While we still have more spiders to spawn
		while( Counter < numSpiders )
		{
			// If we should spawn small spider
			if ( bSmallSpiders )
			{
				// Set spider rotation to our rotation
				spiderRotation 		= Rotation;

				// Convert the spider's yaw from degrees to Unreal units
				spiderYaw 			= theSpiders[randNum].iRotation * (16384 / 90.0);

				// Add spider yaw to spider's rotation
				spiderRotation.Yaw += spiderYaw;

				// Make sure yaw fits within Unreal's 16-bit rotator value
				spiderRotation.Yaw  = spiderRotation.Yaw & 65535;
				
				// Spawn small spider and set its params
				smallSpider 							= Spawn(Class'SpiderSmall',self,,Location,spiderRotation);
				smallSpider.NormalSpeed 				= theSpiders[Counter].NormalSpeed;
				smallSpider.attackSpeed 				= theSpiders[Counter].attackSpeed;
				smallSpider.GroundSpeed 				= theSpiders[Counter].NormalSpeed;
				smallSpider.canWander 					= theSpiders[Counter].canWander;
				smallSpider.waitForTrigger 				= theSpiders[Counter].waitForTrigger;
				smallSpider.forwardDistance 			= theSpiders[Counter].forwardDistance;
				smallSpider.DrawScale 					= theSpiders[Counter].drawingScale;
				smallSpider.jumpingDistanceFromHarry 	= theSpiders[Counter].jumpingDistanceFromHarry;
				smallSpider.GroupName 					= theSpiders[Counter].GroupName;
				smallSpider.numSpellsDefault			= theSpiders[Counter].numSpellsLargeSpider;
				smallSpider.leaveDeadSpider 			= theSpiders[Counter].leaveSmallDeadSpider;
			}
			// Otherwise
			else 
			{
				// Set spider rotation to our rotation
				spiderRotation 		= Rotation;

				// Convert the spider's yaw from degrees to Unreal units
				spiderYaw 			= theSpiders[randNum].iRotation * (16384 / 90.0);

				// Add spider yaw to spider's rotation
				spiderRotation.Yaw += spiderYaw;

				// Make sure yaw fits within Unreal's 16-bit rotator value
				spiderRotation.Yaw  = spiderRotation.Yaw & 65535;
				
				// Spawn large spider and set its params
				largeSpider 							= Spawn(Class'SpiderLarge',self,,Location,spiderRotation);
				largeSpider.NormalSpeed 				= theSpiders[Counter].NormalSpeed;
				largeSpider.attackSpeed 				= theSpiders[Counter].attackSpeed;
				largeSpider.GroundSpeed 				= theSpiders[Counter].NormalSpeed;
				largeSpider.canWander 					= theSpiders[Counter].canWander;
				largeSpider.waitForTrigger 				= theSpiders[Counter].waitForTrigger;
				largeSpider.forwardDistance 			= theSpiders[Counter].forwardDistance;
				largeSpider.DrawScale 					= theSpiders[Counter].drawingScale;
				largeSpider.jumpingDistanceFromHarry 	= theSpiders[Counter].jumpingDistanceFromHarry;
				largeSpider.GroupName 					= theSpiders[Counter].GroupName;
				largeSpider.numSpellsDefault 			= theSpiders[Counter].numSpellsLargeSpider;
				largeSpider.leaveDeadSpider 			= theSpiders[Counter].leaveSmallDeadSpider;
			}

			// Increment spawn counter
			Counter++;

			// Wait for the intended delay
			Sleep(theSpiders[Counter].nextSpiderDelay);
		}

		// Go to waiting state
		GotoState('spiderSpawnerWait');
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	numSpiders=5

	bSmallSpiders=True

	theSpiders(0)=(NormalSpeed=75,attackSpeed=100,canWander=True,waitForTrigger=False,forwardDistance=0,GroupName="",iRotation=0,nextSpiderDelay=0.5,drawingScale=1,jumpingDistanceFromHarry=250,numSpellsLargeSpider=1,leaveSmallDeadSpider=0.2)
	theSpiders(1)=(NormalSpeed=75,attackSpeed=100,canWander=True,waitForTrigger=False,forwardDistance=0,GroupName="",iRotation=0,nextSpiderDelay=0.5,drawingScale=1,jumpingDistanceFromHarry=250,numSpellsLargeSpider=1,leaveSmallDeadSpider=0.2)
	theSpiders(2)=(NormalSpeed=75,attackSpeed=100,canWander=True,waitForTrigger=False,forwardDistance=0,GroupName="",iRotation=0,nextSpiderDelay=0.5,drawingScale=1,jumpingDistanceFromHarry=250,numSpellsLargeSpider=1,leaveSmallDeadSpider=0.2)
	theSpiders(3)=(NormalSpeed=75,attackSpeed=100,canWander=True,waitForTrigger=False,forwardDistance=0,GroupName="",iRotation=0,nextSpiderDelay=0.5,drawingScale=1,jumpingDistanceFromHarry=250,numSpellsLargeSpider=1,leaveSmallDeadSpider=0.2)
	theSpiders(4)=(NormalSpeed=75,attackSpeed=100,canWander=True,waitForTrigger=False,forwardDistance=0,GroupName="",iRotation=0,nextSpiderDelay=0.5,drawingScale=1,jumpingDistanceFromHarry=250,numSpellsLargeSpider=1,leaveSmallDeadSpider=0.2)

	CollisionRadius=10.00

	CollisionHeight=10.00

	bCollideActors=True

	bCollideWorld=True

	Mass=10.00
}