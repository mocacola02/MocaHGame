//================================================================================
// BaseCamTarget.
//
// This class acts as the target for BaseCam.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//

class BaseCamTarget extends HiddenHPawn; 

var bool bRelative;			// Whether or not to make target offset relative
var Vector vOffset;			// Target position offset

var Actor aAttachedTo;	// Reference to actor we're attached to
var BaseCam Cam;				// Reference to BaseCam



//=========
// Events
//=========

// On tick
event Tick (float DeltaTime)
{
	// Call parent tick behavior
	Super.Tick(DeltaTime);

	// Update our orientation
	UpdateOrientation();
}


//=================
// Main Functions
//=================

// Update target orientation
function UpdateOrientation()
{
	local Vector Delta;

	// If we're attached to an actor
	if ( aAttachedTo != None )
	{
		// Set delta to the attached actor's saved pre pivot Z value
		Delta = Vec(0.0,0.0,aAttachedTo.SavedPrePivotZ);

		// Set desired rotation to attached actor rotation
		SetNewRotation(aAttachedTo.Rotation);

		// If relative, set location relative to attached actor's rotation
		if ( bRelative )
		{
			SetLocation(aAttachedTo.Location + Delta + (vOffset >> Rotation));
		}
		// Otherwise, set location normally
		else
		{
			SetLocation(aAttachedTo.Location + Delta + vOffset);
		}
	}
}

// Set what actor we are attached to, update our orientation, and make the new actor our tick parent
function SetAttachedTo (Actor A)
{
	aAttachedTo = A;
	UpdateOrientation();
	TickParent = aAttachedTo;
}

// Set what actor we are attached to based on the actor's name
function bool SetAttachedToByName (name nName)
{
	local Actor A;

	// If we have an actual name
	if ( nName != 'None' )
	{
		// Loop through all actors
		foreach AllActors(Class'Actor',A)
		{
			// If the actors name or cutname matches the given name
			if ( (A.Name == nName) || (A.CutName ~= string(nName)) )
			{
				// Set the attached actor to the current looped actor
				aAttachedTo = A;

				// If relative, attach relative to actor's rotation
				if ( bRelative )
				{
					SetLocation(aAttachedTo.Location + (vOffset >> aAttachedTo.Rotation));
				}
				// Otherwise, attach normally
				else
				{
					SetLocation(aAttachedTo.Location + vOffset);
				}

				// Set tick parent to newly attached actor
				TickParent = aAttachedTo;

				// Log our new attached actor
				PlayerHarry.ClientMessage("CamTarget is AttachedTo: " $ string(aAttachedTo));

				// Return that we successfully attached
				return True;
			}
		}
	}

	// Log that we could not find the actor of that name
	PlayerHarry.ClientMessage("Could not find targetActor with the name -> " $ string(nName));

	// Log every single actor name
	PlayerHarry.ClientMessage("Valid names you can use are as follows:");
	foreach AllActors(Class'Actor',A)
	{
		PlayerHarry.ClientMessage(string(A));
	}

	// Return that we could not attach
	return False;
}

// Set what actor we are attached to based on the actor's cutname
function bool SetAttachedToByCutName (string sCutName)
{
	local Actor A;

	// If cutname is none, detach and return successful
	if ( sCutName ~= "none" )
	{
		aAttachedTo = None;
		return True;
	}

	// Loop through all actors
	foreach AllActors(Class'Actor',A)
	{
		// If the looped actor's cutname or name is the target cutname
		if ( (A.CutName ~= sCutName) || (string(A.Name) ~= sCutName) )
		{
			// Attach to the looped actor
			aAttachedTo = A;

			// If relative, attach relative to actor's rotation
			if ( bRelative )
			{
				SetLocation(aAttachedTo.Location + (vOffset >> aAttachedTo.Rotation));
			}
			// Otherwise, attach normally
			else
			{
				SetLocation(aAttachedTo.Location + vOffset);
			}

			// Set tick parent to attached actor
			TickParent = aAttachedTo;

			// Return that we successfully attached
			return True;
		}
	}

	// Set our error string that we could not find the actor
	Cam.CutErrorString = "baseCam target could not find the actor with the CutName: " $ sCutName;

	// Return as unsuccessful
	return False;
}

// Set desired rotation to a given rotation value, ensuring rotation value is valid
function SetNewRotation (Rotator Rot)
{
	DesiredRotation = Rot;
	DesiredRotation.Yaw = DesiredRotation.Yaw & 65535;
	DesiredRotation.Pitch = DesiredRotation.Pitch & 65535;
	DesiredRotation.Roll = DesiredRotation.Roll & 65535;
	SetRotation(DesiredRotation);
}


//================
// Misc. Helpers
//================

// Return whether or not we're attached to an actor
function bool IsAttached()
{ 
	return aAttachedTo != None;
}

// Set our offset to a given vector and update our orientation
function SetOffset (Vector V)
{
	vOffset = V;
	UpdateOrientation();
}

// Set our offset X value to a given offset and update our orientation
function SetXOffset (float X)
{
	vOffset.X = X;
	UpdateOrientation();
}

// Set our offset Y value to a given offset and update our orientation
function SetYOffset (float Y)
{
	vOffset.Y = Y;
	UpdateOrientation();
}

// Set our offset Z value to a given offset and update our orientation
function SetZOffset (float Z)
{
	vOffset.Z = Z;
	UpdateOrientation();
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bIgnoreZonePainDamage=True
}

//=====================================================================================================
// KW didn't specify when this class was written :(
// But I formatted it on 5/21/2026.
// May 21st is International Tea Day!
// - Moca, 5/21/2026
//=====================================================================================================