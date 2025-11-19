//================================================================================
// GestureSprite.
//================================================================================

class GestureSprite extends HActor;

state stateIdle
{
	event BeginState()
	{
		bHidden = True;
	}

	event Tick(float DeltaTime);
}

state stateVisible
{
	event BeginState()
	{
		if ( Cursor == None )
		{
			Cursor = baseWand(PlayerHarry.Weapon).Cursor;
		}
	}
}

defaultproperties
{
    bHidden=True

    Texture=None

    CollisionRadius=2.00
    CollisionHeight=2.00

    bCollideActors=False
    bCollideWorld=False
    bBlockActors=False
    bBlockPlayers=False

	Physics=PHYS_None
	DrawType=DT_Sprite
}
