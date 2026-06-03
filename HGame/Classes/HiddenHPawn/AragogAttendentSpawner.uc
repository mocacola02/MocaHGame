//==========================================================================//
// AragogAttendentSpawner.
//
// Spawns SpiderAttendents with configurable parameters.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class AragogAttendentSpawner extends HiddenHPawn;

//= Constants =//
const BOOL_DEBUG_AI= true;	// Debug status. Never referenced.

//= Parameter Structs =//
struct AragogAttendentParams
{
	var() float attackSpeed;					// Attack speed of attendent
	var() int iRotation;						// Rotation of attendent
	var() float drawingScale;					// Draw scale of attendent
	var() float DamageAmount;					// Damage amount dealt by attendent
	var() Vector offsetFromSpawner;				// Position offset from spawner (self)
	var() float jumpingDistanceFromHarry;		// Allowed distance for jumping towards Harry
	var() int numSpells;						// Number of spells attendent can take
};

struct SpiderSpawnerParams
{
	var() AragogAttendentParams theSpiders[4];	// Attendent params to spawn with
	var() int numberOfSpiders;					// Number of spiders we can spawn
	var() float nextSpiderDelay;				// Delay between spawning spiders
};

var() SpiderSpawnerParams theAnchors[8];		// Array of spider spawner parameter sets

//= Positioning =//
var float spiderYaw;			// Yaw of spider
var Rotator spiderRotation;		// Rotation of spider

var Vector vRight;				// Right vector of spawner
var Vector vOffset;				// Position offset
var Vector vOffsetSide;			// Position side offset
var Vector vOffsetFront;		// Position front offset
var Vector vOffsetUp;			// Position up offset
var Vector vTempOffset;			// Temporary position offset


//= Counters =//
var int Counter;			// Counter value, never used
var int Spidercounter;		// Current spawner count
var int numberOfSpiders;	// Total number of spiders to spawn
var int numberOfAnchors;	// Number of anchors (webs holding up center web) to spawn at

//= Actor References =//
var SpiderAttendent atSpider;			// Current spider being spawned
var AragogCenterWeb _AragogCenterWeb;	// Reference to Aragog's center web


//=========
// Events
//=========

// Called after gameplay begins
event PostBeginPlay()
{
	// Make spawner collide with world
	bCollideWorld = True;

	// Get reference to Aragog's center web
	foreach AllActors(Class'AragogCenterWeb', _AragogCenterWeb)
	{
		break;
	}
}

// Called on trigger, go to spawning state
event Trigger (Actor Other, Pawn EventInstigator)
{
	GotoState('SpawnSomeSpiders');
}


//===========
// Spawning
//===========

// Spawn spawners at a given anchor
function SpawnSpiders (int A)
{
	// Set number of anchors to the given int
	numberOfAnchors = A;

	// Get number of spiders to spawn
	numberOfSpiders = theAnchors[numberOfAnchors].numberOfSpiders;

	// Calculate right vector
	vRight = Vector(Rotation) Cross vect(0.00,0.00,1.00);

	// Go to spawning state
	GotoState('SpawnSomeSpiders');
}

// Set up a given spider's properties
function SetupSpider (SpiderAttendent atSpider)
{
	// Set spider's attack speed, draw scale, damage amount, jumping distance, and allowed spell hits to the intended parameters
	atSpider.attackSpeed 				= theAnchors[numberOfAnchors].theSpiders[Spidercounter].attackSpeed;
	atSpider.DrawScale 					= theAnchors[numberOfAnchors].theSpiders[Spidercounter].drawingScale;
	atSpider.fDamageAmount 				= theAnchors[numberOfAnchors].theSpiders[Spidercounter].DamageAmount;
	atSpider.jumpingDistanceFromHarry 	= theAnchors[numberOfAnchors].theSpiders[Spidercounter].jumpingDistanceFromHarry;
	atSpider.numSpellsDefault 			= theAnchors[numberOfAnchors].theSpiders[Spidercounter].numSpells;

	// Allow spider to be despawnable
	atSpider.bDespawnable 				= True;

	// Randomly pick an integer between 0 and 1, and use to randomize pre attack anim
	switch (Rand(2))
	{
		// In the case of rolling a 0
		case 0:
			// Set pre attack anim to jump
			atSpider.ePreAttackAnim = ATTACK_JUMP;
			// Exit switch statement
			break;
		// In the case of rolling a 1
		case 1:
			// Set pre attack anim to rear
			atSpider.ePreAttackAnim = ATTACK_REAR;
			// Exit switch statement
			break;
	}
}

// Tosses a spider up from Aragog hole
function TosssSpiderUpFromHole (bool bPlayShriek)
{
	local int YawOffset;
	local Vector V;
	local Vector vStart;
	local Vector vDest;
	local Rotator rToDest;
	local Rotator R;

	// Calculate direction from the center web to Harry
	V 			= PlayerHarry.Location - _AragogCenterWeb.Location;

	// Set destination yaw to the calculated direction yaw
	rToDest.Yaw = rotator(V).Yaw;

	// Calculate yaw offset based on where Harry is going
	YawOffset 	= 5000 + 4000 * VSize2D(PlayerHarry.Velocity) / 200;
	
	// If Harry is on the right side of the web relative to the direction he's facing, add yaw offset to destination yaw
	if ( (V * vect(1.00,1.00,0.00) Cross Vector(PlayerHarry.Rotation)).Z > 0 )
	{
		rToDest.Yaw += YawOffset;
	}
	// Otherwise, subtract yaw offset from destination yaw since Harry is on the left side
	else 
	{
		rToDest.Yaw -= YawOffset;
	}

	// Set destination vector based on center web location plus 650 units in the direction of the destination
	vDest 		= _AragogCenterWeb.Location + Vector(rToDest) * 650;

	// Set destination Z to Harry's Z
	vDest.Z 	= PlayerHarry.Location.Z;

	// Add a random X and Y value between -125 and 125 to the destination
	vDest 	   += Vec(RandRange(-125.0,125.0),RandRange(-125.0,125.0),0.0);

	// Set start position to center web position
	vStart 		= _AragogCenterWeb.Location;

	// Set start Z to 500 units below Harry
	vStart.Z 	= PlayerHarry.Location.Z - 500;

	// Set rotation from the destination towards the start
	R 			= rotator(vStart - vDest);

	// Zero out the pitch
	R.Pitch 	= 0;

	// Spawn the spider with self as its owner, spawn at the start position, and rotated to R
	atSpider 	= Spawn(Class'SpiderAttendent',self,,vStart,R);
	
	// Set up spider properties
	SetupSpider(atSpider);

	// Set spider physics to falling
	atSpider.SetPhysics(PHYS_Falling);

	// Set spider velocity to the trajected vector between the start and destination over two seconds
	atSpider.Velocity 				= ComputeTrajectoryByTime(vStart,vDest,2.0);

	// Ignore all zone pain damage on spider
	atSpider.bIgnoreZonePainDamage 	= True;

	// Do not allow spider to despawn
	atSpider.bDespawnable 			= False;

	// Set whether or not to scream when in view to the given bool value
	atSpider.bPlayScreamWhenInView 	= bPlayShriek;

	// Set spider to go to the fly in state
	atSpider.GotoState('stateFlyIn');
}

// Tosses a spider up from Aragog hole, alternative rendition that sets the spider to patrol
function TosssSpiderUpFromHole2 (bool bPlayShriek)
{
	local int YawOffset;
	local Vector V;
	local Vector vStart;
	local Vector vDest;
	local Rotator rToDest;
	local Rotator R;
	local PatrolPoint ppStart;

	// Calculate direction from the center web to Harry
	V 			= PlayerHarry.Location - _AragogCenterWeb.Location;

	// Set destination yaw to the calculated direction yaw
	rToDest.Yaw = rotator(V).Yaw;

	// Calculate yaw offset based on where Harry is going
	YawOffset 	= 5000 + 4000 * VSize2D(PlayerHarry.Velocity) / 200;

	// If Harry is on the right side of the web relative to the direction he's facing, add yaw offset to destination yaw
	if ( (V * vect(1.00,1.00,0.00) Cross Vector(PlayerHarry.Rotation)).Z > 0 )
	{
		rToDest.Yaw += YawOffset;
	}
	// Otherwise, subtract yaw offset from destination yaw since Harry is on the left side
	else 
	{
		rToDest.Yaw -= YawOffset;
	}

	// Set destination vector based on center web location plus 400 units in the direction of the destination
	vStart 		= _AragogCenterWeb.Location + Vector(rToDest) * 400;

	// Set start PatrolPoint to the closest start PatrolPoint from the start position
	ppStart 	= FindClosestStartPoint(vStart);

	// Set start position to the start PatrolPoint position
	vStart 		= ppStart.Location;

	// Set rotation yaw from the center web towards the start PatrolPoint
	R.Yaw 		= rotator(ppStart.Location - _AragogCenterWeb.Location).Yaw;

	// Set pitch to -32000 units
	R.Pitch 	= -32000;

	// Fancy spawn a spider with self as owner, at the start position, rotated to R
	atSpider 	= SpiderAttendent(FancySpawn(Class'SpiderAttendent',self,,vStart,R));

	// Set up spider parameters
	SetupSpider(atSpider);

	// Set spider physics to flying
	atSpider.SetPhysics(PHYS_Flying);

	// Ignore all zone pain damage on spider
	atSpider.bIgnoreZonePainDamage 	= True;

	// Do not allow spider to despawn
	atSpider.bDespawnable 			= False;

	// Set whether or not to scream when in view to the given bool value
	atSpider.bPlayScreamWhenInView 	= bPlayShriek;

	// Set spider to follow PatrolPoints start with start PatrolPoint
	atSpider.FollowPatrolPoints(ppStart.Name);

	// Set spider to go to the crawl in state
	atSpider.GotoState('stateCrawlIn');
}

// Returns the closest PatrolPoint to a given position
function PatrolPoint FindClosestStartPoint (Vector V)
{
	local float cd, D;
	local PatrolPoint cpp, pP;

	// Init closest distance to a very large number so anything we find will be the new closest
	cd = 999999.0;

	// For each PatrolPoint actor with tag PP_StartPoint
	foreach AllActors(Class'PatrolPoint',pP,'PP_StartPoint')
	{
		// Calculate distance between given position and PatrolPoint position
		D = VSize2D(V - pP.Location);

		// If distance is less than the closest distance
		if ( D < cd )
		{
			// Set distance as the new closest distance
			cd = D;

			// Set closest PatrolPoint to the current PatrolPoint
			cpp = pP;
		}
	}
	
	// Return the closest PatrolPoint
	return cpp;
}

//=========
// States
//=========

// Spawning state
state SpawnSomeSpiders
{
	// Begin label
	begin:
		// Log number of spiders being spawned
		cm("Number of spiders: " $ string(numberOfSpiders));

		// For the number of spiders to be spawned
		for(SpiderCounter = 0; SpiderCounter < numberOfSpiders; SpiderCounter++)
		{
			// If we have a center web, toss spider up from hole, shrieking if we're the first spider
			if ( _AragogCenterWeb != None )
			{
				TosssSpiderUpFromHole2(Spidercounter == 0);
			}
			// Otherwise
			else 
			{
				// Set spider rotation to our current rotation
				spiderRotation 		= Rotation;

				// Set spider yaw, converting from degrees to unreal units
				spiderYaw 			= theAnchors[numberOfAnchors].theSpiders[Spidercounter].iRotation * (16384 / 90.0);

				// Rotate spider
				spiderRotation.Yaw += spiderYaw;

				// Make sure yaw fits within allowed 16-bit rotator value
				spiderRotation.Yaw  = spiderRotation.Yaw & 65535;

				// Get offset
				vTempOffset 		= theAnchors[numberOfAnchors].theSpiders[Spidercounter].offsetFromSpawner;

				// Calculate the offset side from right vector
				vOffsetSide 		= vRight * vTempOffset.X;
				
				// Calculate the offset front using our current rotation
				vOffsetFront 		= Vector(Rotation) * vTempOffset.Y;

				// Determine the offset up
				vOffsetUp 			= Vec(0.0,0.0,vTempOffset.Z);

				// Calculate final offset
				vOffset 			= vOffsetSide + vOffsetFront + vOffsetUp;

				// Spawn new spider with self as owner, at our location plus the offset, and at the calculate spider rotation
				atSpider 			= Spawn(Class'SpiderAttendent',self,,Location + vOffset,spiderRotation);

				// Log that we've spawned the spider
				cm("Spawning a spiders at offset : " $ string(vTempOffset));

				// Set up the new spider
				SetupSpider(atSpider);
			}

			// Wait for the intended spawn delay
			Sleep(theAnchors[numberOfAnchors].nextSpiderDelay);
		}
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	CollisionRadius=10.00

	CollisionHeight=10.00

	Mass=10.00
}