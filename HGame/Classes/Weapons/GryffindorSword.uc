class GryffindorSword extends baseWand;

function Vector GetTraceOffset()
{
	return vector(PlayerHarry.Cam.Rotation) * (PlayerHarry.Cam.CurrentSet.fLookAtDistance + CursorRange);
}