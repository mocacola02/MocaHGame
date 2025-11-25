class FootstepSet extends Info;

var(Sounds) bool bUseGlobalSteps;

var(Sounds) Array<Sound> GlobalSteps;
var(Sounds) Array<Sound> StoneSteps;
var(Sounds) Array<Sound> RugSteps;
var(Sounds) Array<Sound> WoodSteps;
var(Sounds) Array<Sound> CaveSteps;
var(Sounds) Array<Sound> CloudSteps;
var(Sounds) Array<Sound> WetSteps;
var(Sounds) Array<Sound> GrassSteps;
var(Sounds) Array<Sound> MetalSteps;
var(Sounds) Array<Sound> SnowSteps;
var(Sounds) Array<Sound> SandSteps;
var(Sounds) Array<Sound> GravelSteps;
var(Sounds) Array<Sound> LavaSteps;
var(Sounds) Array<Sound> DryLavaSteps;
var(Sounds) Array<Sound> RubbleSteps;
var(Sounds) Array<Sound> MetalHollowSteps;
var(Sounds) Array<Sound> MetalPipeSteps;
var(Sounds) Array<Sound> GrateSteps;
var(Sounds) Array<Sound> DirtSteps;
var(Sounds) Array<Sound> GlassSteps;
var(Sounds) Array<Sound> BrokenGlassSteps;
var(Sounds) Array<Sound> IceSteps;
var(Sounds) Array<Sound> ForcefieldSteps;
var(Sounds) Array<Sound> CreakyWoodSteps;
var(Sounds) Array<Sound> MarbleSteps;
var(Sounds) Array<Sound> SqueakyFloorSteps;
var(Sounds) Array<Sound> HollowWoodSteps;
var(Sounds) Array<Sound> WetStoneSteps;

defaultproperties
{
	RugSteps(0)=Sound'HAR_foot_rug1'
	RugSteps(1)=Sound'HAR_foot_rug2'
	RugSteps(2)=Sound'HAR_foot_rug3'

	WoodSteps(0)=Sound'HAR_foot_wood1'
	WoodSteps(1)=Sound'HAR_foot_wood2'
	WoodSteps(2)=Sound'HAR_foot_wood3'

	StoneSteps(0)=Sound'HAR_foot_stone1'
	StoneSteps(1)=Sound'HAR_foot_stone2'
	StoneSteps(2)=Sound'HAR_foot_stone3'

	CaveSteps(0)=Sound'HAR_foot_cave1'
	CaveSteps(1)=Sound'HAR_foot_cave2'
	CaveSteps(2)=Sound'HAR_foot_cave3'

	CloudSteps(0)=Sound'HAR_foot_cloud1'
	CloudSteps(1)=Sound'HAR_foot_cloud2'
	CloudSteps(2)=Sound'HAR_foot_cloud3'

	WetSteps(0)=Sound'HAR_foot_wet1'
	WetSteps(1)=Sound'HAR_foot_wet2'
	WetSteps(2)=Sound'HAR_foot_wet3'

	GrassSteps(0)=Sound'HAR_foot_grass1'
	GrassSteps(1)=Sound'HAR_foot_grass2'
	GrassSteps(2)=Sound'HAR_foot_grass3'

	MetalSteps(0)=Sound'HAR_foot_metal1'
	MetalSteps(1)=Sound'HAR_foot_metal2'
	MetalSteps(2)=Sound'HAR_foot_metal3'

	SnowSteps(0)=Sound'HAR_foot_cloud1'
	SnowSteps(1)=Sound'HAR_foot_cloud2'
	SnowSteps(2)=Sound'HAR_foot_cloud3'

	SandSteps(0)=Sound'HAR_foot_grass1'
	SandSteps(1)=Sound'HAR_foot_grass2'
	SandSteps(2)=Sound'HAR_foot_grass3'

	GravelSteps(0)=Sound'HAR_foot_stone1'
	GravelSteps(1)=Sound'HAR_foot_stone2'
	GravelSteps(2)=Sound'HAR_foot_stone3'

	LavaSteps(0)=Sound'HAR_foot_wet1'
	LavaSteps(1)=Sound'HAR_foot_wet2'
	LavaSteps(2)=Sound'HAR_foot_wet3'

	DryLavaSteps(0)=Sound'HAR_foot_stone1'
	DryLavaSteps(1)=Sound'HAR_foot_stone2'
	DryLavaSteps(2)=Sound'HAR_foot_stone3'

	RubbleSteps(0)=Sound'HAR_foot_stone1'
	RubbleSteps(1)=Sound'HAR_foot_stone2'
	RubbleSteps(2)=Sound'HAR_foot_stone3'

	MetalHollowSteps(0)=Sound'HAR_foot_metal1'
	MetalHollowSteps(1)=Sound'HAR_foot_metal2'
	MetalHollowSteps(2)=Sound'HAR_foot_metal3'

	MetalPipeSteps(0)=Sound'HAR_foot_metal1'
	MetalPipeSteps(1)=Sound'HAR_foot_metal2'
	MetalPipeSteps(2)=Sound'HAR_foot_metal3'

	GrateSteps(0)=Sound'HAR_foot_metal1'
	GrateSteps(1)=Sound'HAR_foot_metal2'
	GrateSteps(2)=Sound'HAR_foot_metal3'

	DirtSteps(0)=Sound'HAR_foot_grass1'
	DirtSteps(1)=Sound'HAR_foot_grass2'
	DirtSteps(2)=Sound'HAR_foot_grass3'

	GlassSteps(0)=Sound'HAR_foot_stone1'
	GlassSteps(1)=Sound'HAR_foot_stone2'
	GlassSteps(2)=Sound'HAR_foot_stone3'

	BrokenGlassSteps(0)=Sound'HAR_foot_stone1'
	BrokenGlassSteps(1)=Sound'HAR_foot_stone2'
	BrokenGlassSteps(2)=Sound'HAR_foot_stone3'

	IceSteps(0)=Sound'HAR_foot_stone1'
	IceSteps(1)=Sound'HAR_foot_wet1'
	IceSteps(2)=Sound'HAR_foot_stone2'

	ForcefieldSteps(0)=Sound'HAR_foot_cloud1'
	ForcefieldSteps(1)=Sound'HAR_foot_cloud2'
	ForcefieldSteps(2)=Sound'HAR_foot_cloud3'

	CreakyWoodSteps(0)=Sound'HAR_foot_wood1'
	CreakyWoodSteps(1)=Sound'HAR_foot_wood2'
	CreakyWoodSteps(2)=Sound'HAR_foot_wood3'

	MarbleSteps(0)=Sound'HAR_foot_stone1'
	MarbleSteps(1)=Sound'HAR_foot_stone2'
	MarbleSteps(2)=Sound'HAR_foot_stone3'

	SqueakyFloorSteps(0)=Sound'HAR_foot_wood1'
	SqueakyFloorSteps(1)=Sound'HAR_foot_wood2'
	SqueakyFloorSteps(2)=Sound'HAR_foot_wood3'

	HollowWoodSteps(0)=Sound'HAR_foot_wood1'
	HollowWoodSteps(1)=Sound'HAR_foot_wood2'
	HollowWoodSteps(2)=Sound'HAR_foot_wood3'

	WetStoneSteps(0)=Sound'HAR_foot_stone1'
	WetStoneSteps(1)=Sound'HAR_foot_wet1'
	WetStoneSteps(2)=Sound'HAR_foot_stone2'
}