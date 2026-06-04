//==========================================================================//
// SecretAreaMarker.
//
// Marks a secret area, and marks it as discoveredwhen touched by a
// player or triggered.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class SecretAreaMarker extends HiddenHPawn;

//= Imports =//
#exec Texture Import File=Textures\SecretTexture.PNG Name=SecretTexture COMPRESSION=P8 UPSCALE=1 Mips=0 Flags=2


//= General Variables =//
var() bool bUseCollision;	// Should we use collision (touch event) to be activated

var bool bFound;			// Have we been found
var Sound FoundSound;		// Sound to play when found


//=========
// Events
//=========

// Called before gameplay starts
event PreBeginPlay()
{
	// If we shouldn't use collision, disable collision
	if ( !bUseCollision )
	{
		SetCollision(False,False,False);
	}
}

// Called when touched by actor
event Touch (Actor Other)
{
	// If we should use collision and other is a player, get found
	if ( bUseCollision && Other.IsA('PlayerPawn') )
	{
		OnFound();
	}
}

// Called when triggered, get found
event Trigger (Actor Other, Pawn EventInstigator)
{
	OnFound();
}


//=============
// Activation
//=============

// Set self as found
function OnFound()
{
	// If we haven't been found yet
	if ( !bFound )
	{
		// Log that we were found
		cm("Secret Area Found!  Oh most glorious delight and joy!!!");

		// If we have a found sound, play it
		if ( FoundSound != None )
		{
			PlaySound(FoundSound);
		}
	}

	// Set that we've been found
	bFound = True;
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bUseCollision=True

	FoundSound=Sound'HPSounds.Music_Events.Found_Secret_Music'

	bPersistent=True

	Texture=Texture'HGame.SecretTexture'

	bCollideActors=True
}