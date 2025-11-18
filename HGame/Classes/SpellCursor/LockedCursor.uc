class LockedCursor extends ParticleFX;

defaultproperties
{
	ParticlesPerSec=(Base=60.0)
	AngularSpreadWidth=(Base=2.0)
	AngularSpreadHeight=(Base=2.0)
	Speed=(Base=5.0)
	Lifetime=(Base=2.0)
	SizeWidth=(Base=2.0,Rand=10.0)
	SizeLength=(Base=2.0,Rand=10.0)
	SizeEndScale=(Base=-0.5)
	SpinRate=(Base=1.0,Rand=20.0)
	Attraction=(X=10.0,Y=10.0)
	ParticlesAlive=30
	bRotateToDesired=True
	ColorStart=(Base=(R=255,G=0,B=255))
	ColorEnd=(Base=(R=255,G=0,B=255))
}
