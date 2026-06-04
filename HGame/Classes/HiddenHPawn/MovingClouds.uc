//==========================================================================//
// MovingClouds.
//
// Clouds placed in front of the Ford during the scrapped flying mini-game.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class MovingClouds extends HiddenHPawn;

//= Constants =//
const BOOL_DEBUG_AI= false;

//= General Variables =//
var() bool bFollowCar;	// Should clouds move with car
var() bool bFollowPath;	// Should clouds follow a path

var bool bTouch;		// Are we being touched
var Director Director;	// Ref to director

//= Positioning =//
var() float fFrontOffset;	// How far in front of car to be placed
var() float fSideOffset;	// How far to the side of car to be placed

var Vector vCloudLocation;	// Location of the clouds offset from car
var Vector vDir;			// Rotation direction of moving cloud


//=========
// Events
//=========

// Called after gameplay starts
event PostBeginPlay()
{
	// Get ref to director
	foreach AllActors(Class'Director',Director)
	{
		break;
	}

	// Determine and set cloud location
	vCloudLocation = FindLocation();

	// Set location to the calculated location
	SetLocation(vCloudLocation);
}

// On tick
event Tick (float DeltaTime)
{
	local Vector vDirection;
	local Rotator vRot;

	// If we should follow the path, determine location from path
	if ( bFollowPath )
	{
		vCloudLocation = FindLocationFromPath();
	}

	// If we should follow the path, determine location
	if ( bFollowCar )
	{
		vCloudLocation = FindLocation();
	}

	// Set location to the calculated location
	SetLocation(vCloudLocation);
}

// When touched by actor, call touch event on director
event Touch (Actor Other)
{
	Director.OnTouchEvent(self,Other);
}

// When untouched by actor, call untouch event on director
event UnTouch (Actor Other)
{
	Director.OnUnTouchEvent(self,Other);
}

// When bumped by actor
event Bump (Actor Other)
{
	// If in debug mode, log that we've been bumped
	if ( BOOL_DEBUG_AI )
	{
		PlayerHarry.ClientMessage("I have been bumped ");
	}

	// Redirect to Touch
	Touch(Other);
}


//===========
// Movement
//===========

// Returns if car has passed clouds, never called
function bool PassedClouds()
{
	local Vector vCarLocation;
	local Vector vStraightDir;
	local Vector vCarDir;

	// Calculate straight direction from negated rotation
	vStraightDir 	=  -(Vector(Rotation));

	// Calculate car direction from Harry's (car's) rotation
	vCarDir 		= Vector(PlayerHarry.Rotation);

	// If directions point in opposite directions
	if ( vStraightDir Dot vCarDir < 0 )
	{
		// Log that we've passed the clouds
		ClientMessage("We have passed the clouds");

		// Return true
		return True;
	}

	// Return false, we have no passed clouds
	return False;
}

// Returns intended location
function Vector FindLocation()
{
	local Vector vOffset;
	local Vector vLocation;
	local Rotator Direction;

	// Set direction to Harry's (car's) rotation
	Direction 		= PlayerHarry.Rotation;

	// Add side offset to direction yaw
	Direction.Yaw  += fSideOffset;

	// Set offset to our direction multiplied by front offset
	vOffset 		= Vector(Direction) * fFrontOffset;

	// Set final location to Harry's (car's) location plus the offset
	vLocation 		= PlayerHarry.Location + vOffset;

	// Return final location
	return vLocation;
}

// Returns intended location based on path
function Vector FindLocationFromPath()
{
	local float fDistanceFromPoint;
	local Vector fLine;
	local Vector vOffset, vLocation;
	local Rotator lineRotation, destRotation;
	local Rotator Direction;
	local PatrolPoint PPClosestToCar, PPClosestToCarNext;
	local PatrolPoint PPClosestToLine, PPClosestToLineNext;

	// Set closest to car PatrolPoint to the nearest PatrolPoint to Harry (car)
	PPClosestToCar 		= FindNearestPatrolPoint(PlayerHarry.Location);
	
	// Get next PatrolPoint from closest PatrolPoint
	PPClosestToCarNext 	= PPClosestToCar.NextPatrolPoint;

	// Set rotation towards next PatrolPoint as line rotation
	lineRotation 		= rotator(PPClosestToCarNext.Location - PPClosestToCar.Location);

	// Set line as Harry's (car's) location plus the line rotation multiplied by the front offset
	fLine 				= PlayerHarry.Location + Vector(lineRotation) * fFrontOffset;

	// Find PatrolPoint closest to line position
	PPClosestToLine 	= FindNearestPatrolPoint(fLine);

	// Set distance as the size between the line position and PatrolPoint closest to line position
	fDistanceFromPoint 	= VSize2D(PPClosestToLine.Location - fLine);

	// If there's another PP after the closest to line PP
	if ( PPClosestToLine.NextPatrolPoint != None )
	{
		// Set next closest to line PP to next PP
		PPClosestToLineNext = PPClosestToLine.NextPatrolPoint;

		// Set destination rotation as the rotation facing the next closest to line PP
		destRotation 		= rotator(PPClosestToLineNext.Location - PPClosestToLine.Location);
	}
	// Otherwise, set destination rotation to the rotation of the closest to line PP
	else 
	{
		destRotation = PPClosestToLine.Rotation;
	}

	// Add side offset to destination rotation yaw
	destRotation.Yaw   += fSideOffset;

	// Set offset as the destination rotation times the distance from point
	vOffset 			= Vector(destRotation) * fDistanceFromPoint;

	// Set the final location as the location of the closest to line PP plus the offset
	vLocation 			= PPClosestToLine.Location + vOffset;

	// Return the final location
	return vLocation;
}

// Returns the nearest PatrolPoint at a given location
function PatrolPoint FindNearestPatrolPoint (Vector Loc)
{
	local float fDist;
	local float fClosestDist, vLocation;
	local PatrolPoint tempPatrolPoint, ClosestPoint;

	// Set location value to the given loc vector
	vLocation = Loc;

	// Set closest dist to a very high value so anything we find will become the new closest
	fClosestDist = 1000000.0;

	// For all actors of class PatrolPoint
	foreach AllActors(Class'PatrolPoint', tempPatrolPoint)
	{
		// Set distance to the size between the current PP and the location value
		fDist = VSize(vLocation - tempPatrolPoint.Location);

		// If current dist is less than closest dist
		if ( fDist < fClosestDist )
		{
			// Set current dist as the new closest dest
			fClosestDist = fDist;

			// Set closest PP as the current PP
			ClosestPoint = tempPatrolPoint;
		}
	}

	// Return the closest PP
	return ClosestPoint;
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	fFrontOffset=100.00

	fSideOffset=8191.00

	bFollowCar=True

	attachedParticleClass(0)=Class'HPParticle.FlyingClouds'

	bHidden=False

	Tag="MovingClouds"

	DrawScale=5.00

	CollisionRadius=35.00

	CollisionHeight=32.00
}