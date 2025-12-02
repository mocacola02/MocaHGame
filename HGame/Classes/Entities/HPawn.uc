//==========================================
//
//	HPawn. Initially rewritten 11/21/2025 - 11/24/2025
//
//==========================================
class HPawn extends Pawn;

//-------------------------------------
// Constants
//-------------------------------------
var const int NINETY_DEG;

//-------------------------------------
// Key References
//-------------------------------------
var BaseCam PlayerCam;										// Moca: Reference to Player's BaseCam
var harry PlayerHarry;										// Moca: Reference to Harry

//-------------------------------------
// Health
//-------------------------------------
var(Combat) int DamageToDeal;

var() bool bDespawnable;									// Moca: Can this Pawn be despawned by a Despawner?
var bool bPendingDespawn;									// Moca: Is this Pawn pending a despawn

//-------------------------------------
// Display
//-------------------------------------
// Shadows
var(Display) class<ActorShadow> ShadowClass;				// Moca: Shadow class to spawn as the Pawn's shadow
var(Display) float ShadowScale;								// Moca: Size of the shadow

// Animation
var(Display) array<name> IdleAnimations;					// Moca: List of Idle animations
var(Display) array<name> FidgetAnimations;					// Moca: List of Fidget animations
var(Display) bool bPlayIdleOnPlay;							// Moca: Should this Pawn play an Idle animation on BeginPlay?

var(Display) bool bFidget;									// Moca: Should this Pawn fidget periodically?
var(Display) float FidgetDelayMin;							// Moca: Minimum fidget delay
var(Display) float FidgetDelayMax;							// Moca: Maximum fidget delay

// Attached Particles
struct AttachedParticle
{
	var() array<class<ParticleFX>> ParticleClass;			// Moca: Class of the attached particle
	var() array<Vector> ParticleOffset;						// Location offset of the attached particle
};

var(Display) array<AttachedParticle> AttachedParticleFX;	// Moca: List of particles to spawn and attach
var array<ParticleFX> AttachedParticleActors;				// Moca: List of the spawned attached particle actors

var(Display) class<ParticleFX> DiedFX;
var(Display) class<ParticleFX> HitFX;

// Enemy Bar
var Texture EnemyBarBaseTexture;							// Moca: Base texture for enemy health bar
var Texture EnemyBarFullTexture;							// Moca: Full texture for enemy health bar
var Texture EnemyBarEmptyTexture;							// Moca: Empty texture for enemy health bar

//-------------------------------------
// Audio
//-------------------------------------
var(Sounds) class<FootstepSet> FootstepSoundSet;			// Moca: FootstepSet to use for this Pawn
var(Sounds) float FootstepFrequency;						// Moca: How frequently to play footstep sounds. 2.0 = twice as often, 0.5 = half as often,  etc.
var float StepAccumulator;									// Moca: How far into a step are we
var float StepDistance;										// Moca: Required distance for a step
var float StepThreshold;									// Moca: Required speed to gain step distance

var array<Sound> LastFootstepSounds;						// Moca: Previous played footstep(s)

var Sound FallingSound;										// Moca: Falling sounds this Pawn can play when falling
var Sound SelectedFallingSound;								// Moca: What falling sound have we played

//-------------------------------------
// Magic
//-------------------------------------
enum eInteraction
{
	INT_Push,												// Moca: Get pushed by spell
	INT_Pull,												// Moca: Get pulled by spell
	INT_Lift,												// Moca: Get lifted by spell
	INT_Lower,												// Moca: Get lowered by spell
	INT_Damage,												// Moca: Take damage from spell
	INT_Stun,												// Moca: Be stunned from spell (eg. Mimblewimble)
	INT_Custom,												// Moca: INT_Custom will use a custom behavior function defined in a child class of HPawn.
};

struct MagicInteraction
{
	var() class<baseSpell> SpellClass;						// Moca: What spell class should this apply to
	var() eInteraction SpellInteraction;					// Moca: What interaction to apply to spell
};

var(Spells) array<MagicInteraction> SpellInteractions;		// Moca: List of spell interaction mappings. Empty by default, which makes all spells use INT_Custom (aka a custom spell response function)
var(Spells) int RequiredSpellHits;							// Moca: Number of spell hits required to trigger spell reaction
var int CurrentSpellHitCount;								// Moca: How many times the Pawn has been hit with a spell it's vulnerable to
var int TotalSpellHitCount;

var(Spells) float PushForce;								// Moca: How much does this Pawn get pushed if INT_Push
var(Spells) float PushMomentumInfluence;					// Moca: How much of the momentum from the actor that pushed us is applied to our push movement? 1.0 = Full momentum, 0.5 = half, etc.
var(Spells) Sound PushedSound;								// Moca: Sound to play when pushed
var(Spells) name PushedAnim;								// Moca: Animation to play when pushed
var vector CurrentPushDirection;

//-------------------------------------
// Stealth
//-------------------------------------
var(Stealth) bool bIsHuntingHarry;							// Moca: Is this Pawn currently hunting Harry? Aka should we be checking if we see Harry and going to chase if so
var(Stealth) bool bFollowUpSearch;							// Moca: Should we follow up our search after losing sight of Harry?

var(Stealth) float MinStealthChaseDelay;					// Moca: Minimum delay before we start actually chasing Harry after spotting him.
var(Stealth) float MaxStealthChaseDelay;					// Moca: Maximum delay before we start actually chasing Harry after spotting him.

var(Stealth) float CurrentSuspicion;						// Moca: Current suspicion level if hunting Harry
var(Stealth) float RequiredSuspicion;						// Moca: Required suspicion level to begin chasing Harry
var(Stealth) float MaxSuspicion;							// Moca: Maximum suspicion level possible, can be set higher than the required amount to make it take longer to stop chasing Harry
var(Stealth) float SuspicionGrowRate;						// Moca: How much suspicion is gained over the span of one second of looking at Harry
var(Stealth) float SuspicionLossRate;						// Moca: How much suspicion is lost over the span of one second after losing sight of Harry

var(Stealth) name EventStealthSearch;						// Moca: What event to broadcast when entering a search? Useful for controlling music, etc.
var(Stealth) name EventStealthChase;						// Moca: What event to broadcast when entering a chase? Useful for controlling music, etc.
var(Stealth) name EventStealthCaught;						// Moca: What event to broadcast on catching Harry? Useful for controlling music, etc.

var(Stealth) array<name> AnimStealthSpot;					// Moca: List of possible animations to play upon spotting Harry (occurs after meeting RequiredSuspicion)
var(Stealth) array<name> AnimStealthCaught;					// Moca: List of possible animations to play upon catching Harry

var(Stealth) name PostChaseState;							// Moca: What state to go to after stealth? If blank, uses previous state.

var(Stealth) Sound FirstSpotSound;							// Moca: Possible sounds to play the first time Harry is spotted
var(Stealth) Sound FollowUpSpotSound;						// Moca: Possible sounds to play on additional spots
var(Stealth) Sound LostHarrySound;							// Moca: Possible sounds to play after losing Harry

var bool bSeesHarry;										// Moca: Do we see Harry right now?
var int StealthChaseCount;									// Moca: How many times have we engaged in a chase?

var Vector PlayerLastLocation;								// Moca: Last location this Pawn saw Harry at

//-------------------------------------
// BumpLine
//-------------------------------------
var(BumpLine) bool bCanBumpLine;							// Moca: Can this Pawn use BumpLines?
var(BumpLine) bool bBumpLineIs2D;							// Moca: Should the BumpLine play as a 2D sound?
var(BumpLine) bool bRandomBumpLine;							// Moca: Use random BumpLine?
var(BumpLine) bool bBumpCapturesHarry;						// Moca: Should this Pawn capture Harry on bump?
var(BumpLine) name BumpLineAnim;							// Moca: What animation to play for BumpLines?
var(BumpLine) string BumpSetFile;							// Moca: BumpSetFile to use
var(BumpLine) string BumpSetPrefix;							// Moca: BumpSetPrefix to use
var(BumpLine) string BumpSetLocalizationFile;				// Moca: BumpSetLocalizationFile to use
var(BumpLine) string BumpSetPackage;						// Moca: BumpSetPackage to use
var(BumpLine) string BumpSetSection;						// Moca: BumpSetSection to use
var(BumpLine) float BumpLineHoldTime;						// Moca: How long to keep showing subtitle after done speaking
var(BumpLine) float BumpLineCooldown;						// Moca: How long does this Pawn have to wait before being able to BumpLine again?

var int CurrentBumpline;									// Moca: Current BumpLine being played
var int LastBumpline;										// Moca: Previous BumpLine played

var float LastBumpTime;										// Moca: Last Level time in seconds we were bumped by Harry

var name PreBumpState;										// Moca: State this Pawn was in before BumpLine
var rotator PreBumpRot;										// Moca: This Pawn's rotation before BumpLine

//-------------------------------------
// Carry
//-------------------------------------
var(Carry) bool bCanPickupObjects;							// Moca: Can this Pawn pick up objects?
var(Carry) bool bAffectedByCarriedActors;					// Moca: Is this Pawn affected by carried actors that have been thrown at it?
var(Carry) array<class> AllowedPickupClasses;				// Moca: What classes can this Pawn pick up?
var Actor HeldActor;

//-------------------------------------
// Movement
//-------------------------------------
var float RunThreshold;										// Moca: Threshold based off of GroundRunSpeed in which Pawn will determine if it's running
var float HighestZ;											// Moca: Highest Location Z value this Pawn has reached
var float FallDistance;										// Moca: How much did we fall?

var(Movement) float MaxDistanceFromHome;					// Moca: Maximum distance allowed from home. If <=0.0, no limit
var Vector HomeLocation;									// Moca: This Pawn's "home" location, aka where it spawned (if not manually set otherwise)

var ePhysics LastTickPhys;									// Moca: This Pawn's Physics state from the previous tick

//-------------------------------------
// Navigation
//-------------------------------------
var NavigationPoint FirstNavP;								// Moca: First NavP we went to (aka home NavP)
var NavigationPoint DestNavP;								// Moca: Destination NavP (aka where we're trying to go to)
var NavigationPoint NextNavP;								// Moca: The next NavP to go to that leads to our DestNavP
var NavigationPoint PrevNavP;								// Moca: The previous NavP we went to
var NavigationPoint LeadNavP;								// Moca: Pending deletion, DELETEME

var(Patrol) name FirstPointName;							// Moca: Name of the first navigation point
var(Patrol) name DestinationPointName;						// Moca: Name of the destination navigation point

var(Patrol) float PatrolAnimRate;							// Moca: AnimRate to use for Patrol animations

// Lead
var bool bLeadingHarry;										// Moca: Are we leading Harry somewhere?
var float RequiredLeadDistance;								// Moca: Required distance from Harry before we start moving to the next point during a lead

// FlyTo
var FlyToController FTController;							// Moca: Reference to our FlyTo Controler
var Actor FlyToActor;										// Moca: Actor we're flying to

var enumMoveType FlyMoveType;								// Moca: Type of flight movement (easing movement)

var bool bFlyToFixedToDestActor;							// Moca: Should Pawn stay fixed to the destination actor
var bool bFlyToStopAtEnd;									// Moca: Should Pawn stay at the end of the FlyTo destination

var name FlyToEvent;										// Moca: Event to broadcast when done Flying To

var Vector FlyToStart;										// Moca: FlyTo start location
var Vector FlyToDest;										// Moca: FlyTo destination location
var Vector FlyToDestOffset;									// Moca: FlyTo destination offset

var float FlyToTimespan;									// Moca: Time it takes to FlyTo destination
var float FlyToTime;										// Moca: Current time in our FlyTo duration
var float EaseBetweenLinearness;							// Moca: Pending deletion, DELETEME

// Misc.
var name PreCaptureState;									// Moca: What state was this Pawn in before Capture?



//-------------------------------------
// Init Events
//-------------------------------------
event PreBeginPlay()
{
	Super.PreBeginPlay();

	PlayerHarry = harry(Level.PlayerHarryActor);

	DesiredRotation.Yaw = Rotation.Yaw;

	if ( ShadowClass != None )
	{
		Shadow = Spawn(ShadowClass, self);
		ActorShadow(Shadow).ShadowSizeFactor *= ShadowScale;
	}

	CreateAttachedParticleFX();

	if ( CutName == "" )
	{
		CutName = string(Name);
	}
}

event PostBeginPlay()
{
	Super.PostBeginPlay();

	PlayerCam = PlayerHarry.Cam;

	SetTimer(1.0,True);

	HomeLocation = Location;
	HighestZ = Location.Z;

	if ( IdleAnimations.Length > 0 && IdleAnimName != '' )
	{
		IdleAnimations.Append(IdleAnimName);
	}

	if ( bPlayIdleOnPlay )
	{
		if ( IdleAnimations.Length > 0 )
		{
			LoopAnim(IdleAnimations[Rand(IdleAnimations.Length)]);
		}
	}
}

//-------------------------------------
// Misc. Events
//-------------------------------------
event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if ( bIsHuntingHarry )
	{
		HandleHunt(DeltaTime);
	}

	if ( Physics = PHYS_Walking && FootstepSoundSet != None )
	{
		DoFootstep();
	}

	if ( Physics == PHYS_Falling )
	{
		if ( LastTickPhys != PHYS_Falling )
		{
			HighestZ = Location.Z;
		}
		else if ( HighestZ < Location.Z )
		{
			HighestZ = Location.Z;
		}
	}

	if ( LastTickPhys != Physics )
	{
		LastTickPhys = Physics;
	}
}

event Falling()
{
	Super.Falling();
	
	HandleFallSound();
}

event Landed()
{
	FallDistance = HighestZ - Location.Z;

	if ( SelectedFallingSound != None )
	{
		StopSound(SelectedFallingSound, SLOT_Talk);
		SelectedFallingSound = None;
	}
}

event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	if  (DamageType == GetSpellName() )
	{
		TotalSpellHitCount++;
		CurrentSpellHitCount++;

		if ( CurrentSpellHitCount >= RequiredSpellHits )
		{
			CurrentSpellHitCount = 0;
			DetermineSpellOutcome(Damage,EventInstigator,HitLocation,Momentum,GetSpellName());
		}
		else
		{
			Print("Hit by spell " $ DamageType $ ", we have " $ string(RequiredSpellHits - CurrentSpellHitCount) $ " hits left until we react to the spell");
		}
	}
	else if ( (DamageType == 'ZonePain') &&  !bIgnoreZonePainDamage )
	{
		GotoState(stateDestroy);
	}
	else
	{
		Health -= Damage;

		if ( Health <= 0 )
		{
			GotoState('stateDie');
		}
	}
}

event OnResolveGameState()
{
	if ( !bInCurrentGameState )
	{
		bHidden = True;
		DisableCollision();
	}
}

event Destroyed()
{
	ShutdownAttachedParticleFX();

	if ( FTController != None )
	{
		FTController.Destroy();
	}

	Super.Destroyed();
}

//-------------------------------------
// Magic
//-------------------------------------
function name GetSpellName()
{
	return baseSpell(SpellVulnerableTo).Default.Name;
}

function DetermineSpellOutcome(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	local int i;
	local eInteraction SelectedInteraction;
	local class<baseSpell> HitSpellClass;

	Print("Determining spell outcome for spell " $ DamageType);

	SelectedInteraction = INT_Custom;
	HitSpellClass = GetSpellClassByName(DamageType);

	if ( SpellInteractions.Length > 0 )
	{
		for ( i = 0; i < SpellInteractions.Length; i++ )
		{
			if ( SpellInteractions[i].SpellClass == HitSpellClass )
			{
				print("Spell class " $ HitSpellClass $ " ");
				SelectedInteraction = SpellInteractions[i].SpellInteraction;
				break;
			}
		}

		if ( SelectedInteraction != INT_Custom )
		{
			switch(SelectedInteraction)
			{
				case INT_Push:	InteractionPushed(HitLocation,Momentum); break;
				case INT_Pull:	InteractionPulled(HitLocation,Momentum); break;
				case INT_Lift:	InteractionLifted(); break;
				case INT_Lower:	InteractionLowered(); break;
				case INT_Damage:InteractionDamaged(Damage); break;
				case INT_Stun:	InteractionStunned(); break;
				default: break;
			}
		}
	}

	ProcessSpell();
}

function class<baseSpell> GetSpellClassByName(name SpellName)
{
	if ( SpellName != '' )
	{
		return class<baseSpell>(DynamicLoadObject(SpellName,class'baseSpell'));
	}

	return class'baseSpell';
}

function SetVulnerableSpell(class<baseSpell> NewSpell)
{
	Print("Setting vulnerable spell to " $ string(NewSpell));
	SpellVulnerableTo = NewSpell;
}

function class<baseSpell> GetInteractionSpell(eInteraction InteractionType)
{
	local int i;

	if ( SpellInteractions.Length <= 0 )
	{
		return MapDefault.SpellVulnerableTo;
	}

	for ( i = 0; i < SpellInteractions.Length; i++ )
	{
		if ( SpellInteractions[i].SpellInteraction == InteractionType )
		{
			return SpellInteractions[i].SpellClass;
		}
	}

	return MapDefault.SpellVulnerableTo;
}

function ProcessSpell(class<baseSpell> HitSpell); // Define in child classes

//-------------------------------------
// Interactions
//-------------------------------------
function InteractionPushed(vector HitLocation, optional vector Momentum)
{
	CurrentPushDirection = GetPushDirection(HitLocation,Momentum);
	GotoState('statePushed');
}

function InteractionPulled(vector HitLocation, optional vector Momentum);
function InteractionLifted();
function InteractionLowered();

function InteractionDamaged(int Damage)
{
	TakeDamage(Damage,self,Location,Velocity,'InteractDamage');
}

function InteractionStunned()
{
	GotoState('stateStunned');
}

function Vector GetPushDirection(Vector HitLocation, optional vector Momentum)
{
	local Vector PushMomentum;

	PushMomentum = Momentum * PushMomentumInfluence;

	return Normal( Location - HitLocation ) * PushForce + PushMomentum;
}

state statePushed
{
	event BeginState()
	{
		if ( PushedAnim != '' )
		{
			PlayAnim(PushedAnim);
		}

		if ( PushedSound != None )
		{
			PlaySound(PushedSound);
		}
	}

	begin:
		Acceleration = CurrentPushDirection;
		Velocity = CurrentPushDirection;

		Sleep(1.0);

		GotoState(LastValidState);
}

state stateStunned
{
	//Placeholder behavior. Should be defined in child classes.
	begin:
		Sleep(5.0);
		GotoState(LastValidState);
}

//-------------------------------------
// Bump
//-------------------------------------
event Bump(Actor Other)
{
	if ( Other == PlayerHarry )
	{
		if ( bHuntingHarry && !PlayerHarry.bIsStealthed )
		{
			CatchHarry();
			return;
		}

		if ( CanBumpLine() )
		{
			DoBumpLine();
			return;
		}
	}

	Super.Bump(Other);
}

function bool CanBumpLine()
{
	return bCanBumpLine && !PlayerHarry.bInBumpLine && (Level.TimeSeconds - LastBumpTime > BumpLineCooldown);
}

function DoBumpLine (optional string AlternateBumpSet)
{
	local string ActiveBumpSet;
	local string SetID;
	local string SayTextID;
	local string SayText;

	local Sound DialogSound;
	local float SoundLen;

	if ( BumpSetFile == "" && AlternateBumpSet == "" )
	{
		Print("ERROR, I DO NOT HAVE ANY BUMPLINES!!!",true);
	}

	ActiveBumpSet = BumpSetFile;

	if ( AlternateBumpSet != "" )
	{
		ActiveBumpSet = AlternateBumpSet;
	}

	if ( BumpSetPrefix != "" )
	{
		SetID = BumpsetPrefix $ "_" $ ActiveBumpSet;
	}

	Print("LOOKING FOR BUMPSET: " $ string(sSetID));

	LastBumpline = CurrentBumpline;

	if ( bRandomBumpLine )
	{
		local int NumOfBS;
		local int i;

		NumOfBS = int(Localize(SetID, "Count", BumpSetFile));
		i = Rand(NumOfBS);

		if ( i == LastBumpline )
		{
			i = (i + 1) % NumOfBS;
		}

		CurrentBumpline = i;
	}
	else
	{
		CurrentBumpline++;
		
		if ( InStr(SayTextID, "<") > -1 )
		{
			CurrentBumpline = 0;
		}
	}

	SayTextID = Localize(SetID, "line" $ CurrentBumpline, ActiveBumpSet);

	if ( InStr(SayTextID, "<") > -1 )
	{
		Print("ERROR: COULDN'T FIND BUMPSET: " $ ActiveBumpSet);
		return;
	}

	Print("LOOKING FOR BUMPLINE ID: " $ SayTextID);

	SayText = Localize(BumpSetSection, SayTextID, BumpSetLocalizationFile);

	if ( InStr(SayText, "<?") > -1 )
	{
		Print("ERROR: COULDN'T FIND BUMPLINE ID: " $ SayTextID $ " FROM BUMPSET: " $ ActiveBumpSet);
		return;
	}

	PreBumpState = GetStateName();
	PreBumpRot = Rotation;

	if ( bBumpCapturesHarry && PlayerHarry.CutNotifyActor != None )
	{
		PlayerHarry.CutNotifyActor = self;
		PlayerHarry.CutCommand("capture");
	}
	
	CutNotifyActor = self;

	DialogSound = Sound(DynamicLoadObject(BumpSetPackage $ "." $ SayTextID, Class'Sound'));

	if ( DialogSound != None )
	{
		SoundLen = GetSoundDuration(DialogSound);
		PlaySound(DialogSound, SLOT_Talk, [Disable3D] bBumpLineIs2D);
	}
	else
	{
		SoundLen = Len(SayText) * 0.01 + 3.0;
	}

	SayText = HandleFacialExpression(SayText, SoundLen);

	local TimedCue TCue;
	TCue = Spawn(class'TimedCue');
	TCue.CutNotifyActor = self;
	TCue.SetupTimer(SoundLen + 0.5, "_BumpLineCue");

	PlayerHarry.myHUD.SetSubtitleText(SayText, SoundLen + BumpLineHoldTime);

	GotoState('stateBumpline');
}

state stateBumpline
{
	function CutCue(string Cue)
	{
		if (  bBumpCapturesHarry )
		{
			PlayerHarry.CutCommand("release");
			PlayerHarry.CutNotifyActor = None;
		}

		CutNotifyActor = None;
		GotoState(PreBumpState);
		DesiredRotation = PreBumpRot;
		LastBumpTime = Level.TimeSeconds;
	}

	begin:
		Acceleration = vect(0,0,0);
		Velocity = vect(0,0,0);
		PlayAnim(BumpLineAnim,,0.5);

		TurnTo(GetActorXYLocation(PlayerHarry));
		SleepForTick();
		Goto('begin');
}

//-------------------------------------
// Audio
//-------------------------------------
function float PlayDialog (string DialogID, optional string SectionName, optional string DialogFileName, optional string PackageName, optional ESoundSlot Slot, optional float Volume, optional bool bNoOverride, optional float Radius, optional float Pitch, optional bool Disable3D, optional bool Loop)
{
	local Sound DialogSound;
	local string DialogString;
	local float SoundLength;

	if ( Slot == SLOT_None )
	{
		Slot = SLOT_Talk;
	}

	if ( SectionName == "" )
	{
		SectionName = "all";
	}

	if ( DialogFileName = "" )
	{
		DialogFileName = "HPdialog";
	}

	if ( PackageName = "" )
	{
		PackageName = "AllDialog";
	}

	PackageName = PackageName $ ".";

	DialogString = Localize(SectionName,DialogID,DialogFileName);
	DialogSound = Sound(DynamicLoadObject(PackageName $ DialogId, Class'Sound'));

	if ( DialogSound != None )
	{
		SoundLength = GetSoundDuration(DialogSound);

		if ( Volume <= 0 )
		{
			Volume = TransientSoundVolume;
		}

		if ( Radius <= 0 )
		{
			Radius = TransientSoundRadius;
		}

		if ( Pitch <= 0 )
		{
			Pitch = TransientSoundPitch;
		}

		PlaySound(DialogSound,Slot,Volume,bNoOverride,Radius,Pitch,Disable3D,Loop);
	}
	else
	{
		SoundLength = (Len(DialogString) * 0.01) + 3.0;
	}

	return SoundLength;
}

function DoFootstep(float DeltaTime)
{
	local Vector Velocity2D;
	local float CurrentSpeed;

	Velocity2D = vect(Velocity.X, Velocity.Y, 0.0);
	CurrentSpeed = VSize(Velocity2D);

	if ( CurrentSpeed > StepThreshold )
	{
		StepAccumulator += CurrentSpeed * DeltaTime;

		if ( StepAccumulator >= StepDistance )
		{
			PlayFootStep();
			StepAccumulator -= StepDistance;
		}
	}
	else
	{
		if ( StepAccumulator > 0.0 )
		{
			StepAccumulator = 0.0;
		}
	}
}

simulated function PlayFootStep(optional float Volume)
{
	local Sound Step;
	local int Decision;
	local Texture HitTexture;
	local int Flags;
	local Sound Footsteps;
	local float NoiseLevel;

	if (Volume <= 0)
	{
		Volume = 1000.0;
	}

	if ( FootRegion.Zone.bWaterZone )
	{
		PlaySound(WaterStep,SLOT_Interact,1.0,False,Volume,1.0);
		return;
	}
	else if ( Fatness > 200 )
	{
		PlaySound(Sound'Big_whomp2',SLOT_None,RandRange(0.4,0.7),False,500.0,RandRange(0.5,1.0));
		ShakeView(0.22,50.0,50.0);
		return;
	}

	if ( EctoAmount > 0 || WebAmount > 0)
	{
		Footsteps[0] = Sound'HAR_foot_ecto1';
		Footsteps[1] = Sound'HAR_foot_ecto2';
		Footsteps[2] = Sound'HAR_foot_ecto3';
	}
	else if ( FootstepSoundSet.bUseGlobalSteps )
	{
		Footsteps = FootstepSoundSet.GlobalSteps;
	}
	else
	{
		HitTexture = TraceTexture(Location + vect(0.00,0.00,-128.00),Location,Flags);

		if ( HitTexture != None  && HitTexture != LastHitTexture)
		{
			LastHitTexture = HitTexture;

			switch (HitTexture.FootstepSound)
			{
				case FOOTSTEP_Stone:
					FootSteps = FootstepSoundSet.Default.StoneSteps;
					NoiseLevel = 10.0;
					break;
				case FOOTSTEP_Rug:
					FootSteps = FootstepSoundSet.Default.RugSteps;
					NoiseLevel = 2.0;
					break;
				case FOOTSTEP_Wood:
					FootSteps = FootstepSoundSet.Default.WoodSteps;
					NoiseLevel = 8.0;
					break;
				case FOOTSTEP_Cave:
					FootSteps = FootstepSoundSet.Default.CaveSteps;
					NoiseLevel = 10.0;
				case FOOTSTEP_Cloud:
					FootSteps = FootstepSoundSet.Default.CloudSteps;
					NoiseLevel = 1.0;
					break;
				case FOOTSTEP_Wet:
					FootSteps = FootstepSoundSet.Default.WetSteps;
					NoiseLevel = 8.0;
					break;
				case FOOTSTEP_Grass:
					FootSteps = FootstepSoundSet.Default.WetSteps;
					NoiseLevel = 2.0;
					break;
				case FOOTSTEP_Metal:
					FootSteps = FootstepSoundSet.Default.MetalSteps;
					NoiseLevel = 10.0;
					break;
				case FOOTSTEP_Snow:
					FootSteps = FootstepSoundSet.Default.SnowSteps;
					NoiseLevel = 3.0;
					break;
				case FOOTSTEP_Sand:
					FootSteps = FootstepSoundSet.Default.SandSteps;
					NoiseLevel = 4.0;
					break;
				case FOOTSTEP_Gravel:
					FootSteps = FootstepSoundSet.Default.GravelSteps;
					NoiseLevel = 5.0;
					break;
				case FOOTSTEP_lava:
					FootSteps = FootstepSoundSet.Default.LavaSteps;
					NoiseLevel = 1.0;
					break;
				case FOOTSTEP_drylava:
					FootSteps = FootstepSoundSet.Default.DryLavaSteps;
					NoiseLevel = 10.0;
					break;
				case FOOTSTEP_Rubble:
					FootSteps = FootstepSoundSet.Default.RubbleSteps;
					NoiseLevel = 10.0;
					break;
				case FOOTSTEP_MetalHollow:
					FootSteps = FootstepSoundSet.Default.MetalHollowSteps;
					NoiseLevel = 10.0;
					break;
				case FOOTSTEP_MetalPipe:
					FootSteps = FootstepSoundSet.Default.MetalPipeSteps;
					NoiseLevel = 10.0;
					break;
				case FOOTSTEP_Grate:
					FootSteps = FootstepSoundSet.Default.GrateSteps;
					NoiseLevel = 10.0;
					break;
				case FOOTSTEP_Dirt:
					FootSteps = FootstepSoundSet.Default.DirtSteps;
					NoiseLevel = 3.0;
					break;
				case FOOTSTEP_Glass:
					FootSteps = FootstepSoundSet.Default.GlassSteps;
					NoiseLevel = 7.0;
					break;
				case FOOTSTEP_BrokenGlass:
					FootSteps = FootstepSoundSet.Default.BrokenGlassSteps;
					NoiseLevel = 10.0;
					break;
				case FOOTSTEP_Ice:
					FootSteps = FootstepSoundSet.Default.IceSteps;
					NoiseLevel = 7.0;
					break;
				case FOOTSTEP_Forcefield:
					FootSteps = FootstepSoundSet.Default.ForcefieldSteps;
					NoiseLevel = 10.0;
					break;
				case FOOTSTEP_CreakyWood:
					FootSteps = FootstepSoundSet.Default.CreakyWoodSteps;
					NoiseLevel = 12.0;
					break;
				case FOOTSTEP_Marble:
					FootSteps = FootstepSoundSet.Default.MarbleSteps;
					NoiseLevel = 8.0;
					break;
				case FOOTSTEP_SqueakyFloor:
					FootSteps = FootstepSoundSet.Default.SqueakyFloorSteps;
					NoiseLevel = 10.0;
					break;
				case FOORSTEP_HollowWood:
					FootSteps = FootstepSoundSet.Default.HollowWoodSteps;
					NoiseLevel = 6.0;
					break;
				case FOOTSTEP_WetStone:
					FootSteps = FootstepSoundSet.Default.WetStoneSteps;
					NoiseLevel = 8.0;
					break;

				default:
					Footsteps = FootstepSoundSet.Default.StoneSteps;
					NoiseLevel = 10.0;
					break;
			}

			LastFootstepSounds = Footsteps;
		}
		else
		{
			Footsteps = LastFootstepSounds;
		}
	}
	
	Decision = Rand(Footsteps.Length);
	
	Step = Footsteps[Decision];

	PlaySound(Step,SLOT_None,0.5,False,Volume,0.9);

	if (NoiseLevel > 0.0)
	{
		MakeNoise(NoiseLevel);
	}
}

function HandleFallSound()
{
	if ( FallingSounds.Length <= 0 )
	{
		Print("Not playing falling sounds as the FallingSounds array is empty.");
		return;
	}

	if ( SelectedFallingSound != None )
	{
		return;
	}

	PlaySound(GetRandomFallSound(),SLOT_Talk);
}

function Sound GetRandomFallSound()
{
	local int i;

	for ( i = 0; i < FallingSounds.Length; i++ )
	{
		if ( FallingSounds[i] != None )
		{
			SelectedFallingSound = FallingSounds[i];
			break;
		}
	}

	if ( SelectedFallingSound != None )
	{
		return SelectedFallingSound;
	}
	else
	{
		Print("Could not get a random fall sound.");
		return None;
	}
}

//-------------------------------------
// Attached Particles
//-------------------------------------
function CreateAttachedParticleFX()
{
	local int i;

	for ( i = 0; i < AttachedParticleClass.Length; i++ )
	{
		local class<ParticleFX> CurrentClass;
		local class<Vector> CurrentOffset;

		CurrentClass = AttachedParticlesFX[i].ParticleClass;
		CurrentOffset = AttachedParticleFX[i].ParticleOffset;

		if ( CurrentClass != None )
		{
			AttachedParticleActors[i] = Spawn(CurrentClass,self,,Location + CurrentOffset);
			AttachedParticleActors[i].SetPhysics(PHYS_Trailer);

			if ( CurrentOffset != vect(0,0,0) )
			{
				AttachedParticleActors[i].bTrailerPrePivot = True;
				AttachedParticleActors[i].PrePivot = CurrentOffset;
			}
		}
	}
}

function ShutdownAttachedParticleFX()
{
	local int i;

	for ( i = 0; i < AttachedParticleActors.Length; i++ )
	{
		if ( AttachedParticleActors[i] != None )
		{
			AttachedParticleActors[i].Shutdown();
		}
	}
}

//-------------------------------------
// Sight
//-------------------------------------
function bool IsFacing(Actor Other, float MinDot)  //Courtesy of Omega
{
    local float DotProduct;
    DotProduct = Vector(Rotation) Dot Normal(Other.Location - Location);

    if (DotProduct > MinDot)
    {
        return true;
    }

    return false;
}

function bool CanSeeHarry(optional float MinDot, optional float ViewRange)
{
	if ( MinDot == 0.0 )
	{
		MinDot = 0.25;
	}

	if ( ViewRange <= 0 && SightRadius > 0 )
	{
		ViewRange = SightRadius;
	}
	else
	{
		return false;
	}

	if ( GetDistanceFromActor(PlayerHarry) <= ViewRange && IsFacing(PlayerHarry, MinDot) && FastTrace(Playerharry.Location, Location) ) //Recommended default MinDot = 0.25
	{	
		return true;
	}

    return false;
}

//-------------------------------------
// Animation
//-------------------------------------
function name GetCurrentIdleAnim()
{
	if ( IdleAnimations.Length <= 0 )
	{
		return IdleAnimName;
	}

	local int i;
	i = Rand(IdleAnimations.Length);

	return IdleAnimations[i];
}

function name GetCurrentFidgetAnim()
{
	if ( FidgetAnimations.Length <= 0 )
	{
		return IdleAnimName;
	}

	local int i;
	i = Rand(FidgetAnimations.Length);

	return FidgetAnimations[i];
}

function float GetFidgetDelay()
{
	return RandRange(FidgetDelayMin,FidgetDelayMax);
}

//-------------------------------------
// Thrown
//-------------------------------------
function DoPickupObject(Actor Obj);		 //Define in child class
function ThrowObject (Vector ThrowVelocity, bool bCollideActors, bool bCollideWorld);	// Define in child class

function SelfGotPickedUp();				 //Define in child class
function SelfGotThrown();				 //Define in child class

function HitByThrownObject(int Damage, Pawn Instigator, vector HitLocation, vector Momentum, name ObjectType);

function ThrownLanded(Vector HitNormal, optional name NextState)
{
	EnableCollision();

	if ( NextState == '' )
	{
		NextState = LastValidState;
	}

	GotoState(NextState);
}

function bool CheckPickupObject(Actor Obj, name HoldingBone)
{
	local bool bIsCompatible;

	if ( !Obj.IsA('HActor') && !Obj.Is('HPawn') )
	{
		Print("ERROR! HPawn cannot pickup an actor this is not a child of HActor or HPawn!",true);
		return false;
	}

	if ( AllowedPickupClasses.Length <= 0 )
	{
		Print("Notice: Not picking up bumped actor " $ Obj $ " as we do not have any allowed pickup classes.");
	}

	for ( i = 0; i < AllowedPickupClasses.Length; i++ )
	{
		if ( Obj.IsA(AllowedPickupClasses[i].Default.Name) )
		{
			Print("We are allowed to pick up " $ Obj $ " of class " $ AllowedPickupClasses[i].Default.Name);
			bIsCompatible = True;
			break;
		}
	}

	if ( !bIsCompatible )
	{
		Print("Notice: Bumped actor " $ Obj $ " of class " $ Obj.Class " is not in our allowed class list.");
		return false;
	}

	DoPickupObject(Obj);
	return true;
}

state stateBeingThrown
{
	event Landed (Vector HitNormal)
	{
		ThrownLanded(HitNormal);
	}
}

//-------------------------------------
// Stealth
//-------------------------------------
function HandleHunt(float DeltaTime)
{
	bSeesHarry = CanSeeHarry();

	if ( !IsInState('stateChaseHarry') )
	{
		if ( bSeesHarry )
		{
			CurrentSuspicion += SuspicionGrowRate * DeltaTime;
			CurrentSuspicion = FClamp(CurrentSuspicion, 0.0, MaxSuspicion);

			if ( CurrentSuspicion >= RequiredSuspicion && !IsInState('stateChaseHarry') )
			{
				GotoState('stateChaseHarry');
			}
		}
		else if ( CurrentSuspicion > 0.0 )
		{
			CurrentSuspicion -= SuspicionLossRate * DeltaTime;
			CurrentSuspicion = FClamp(CurrentSuspicion, 0.0, MaxSuspicion);
		}
	}
}

function CatchHarry()
{
	PlayerHarry.GotoState('stateCaught');
	GotoState('stateCaughtHarry');
}

state stateChaseHarry
{
	event BeginState()
	{
		local int i;

		if ( PostChaseState == '' )
		{
			PostChaseState = LastValidState;
		}

		if ( StealthChaseCount > 0 )
		{
			i = Rand(FollowUpSpotSound.Length);
			if ( FollowUpSpotSound[i] != None )
			{
				PlaySound(FollowUpSpotSound[i],SLOT_Talk);
			}
		}
		else
		{
			i = Rand(FirstSpotSound.Length);
			if ( FirstSpotSound[i] != None )
			{
				PlaySound(FirstSpotSound[i],SLOT_Talk);
			}
		}

		StealthChaseCount++;
	}

	begin:
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);

		LoopAnim(AnimStealthSpot[Rand(AnimStealthSpot.Length)],, 0.2);
		Sleep(RandRange(MinStealthChaseDelay,MaxStealthChaseDelay));

		if ( !bSeesHarry )
		{
			Goto('navchase');
		}
	
	freechase:
		while ( bSeesHarry )
		{
			MoveToward(PlayerHarry);
			SleepForTick();
		}

		if ( !bFollowUpSearch )
		{
			Goto(PostChaseState);
		}
	
	navchase:
		while ( CurrentSuspicion > 0.0 )
		{
			DestNavP = NavigationPoint(FindPathToward(PlayerHarry));
			MoveToward(DestNavP);

			SleepForTick();

			if ( bSeesHarry )
			{
				Goto('freechase');
			}
		}
}

state stateCaughtHarry
{
	begin:
		Acceleration = vect(0,0,0);
		Velocity = vect(0,0,0);

		TriggerEvent(EventStealthCaught,self,self);

		PlayAnim(AnimStealthCaught[Rand(AnimStealthCaught.Length)],,0.2);
		FinishAnim();
		
		GotoState(PostChaseState);
}

//-------------------------------------
// General Navigation
//-------------------------------------
function NavigationPoint GetNavP(name TargetPointName)
{
	local NavigationPoint TempNavP;

	foreach AllActors(Class'NavigationPoint',TempNavP)
	{
		if ( TempNavP.Name == TargetPointName )
		{
			break;
		}
	}

	return TempNavP;
}

function NavigationPoint GetTaggedNavP(name TargetTag)
{
	local NavigationPoint TempNavP;

	foreach AllActors(Class'NavigationPoint',TempNavP,TargetTag)
	{
		break;
	}

	return TempNavP;
}

function NavigationPoint GetNavPClosestToOther(Actor Other)
{
    local NavigationPoint TempNavP;
    local NavigationPoint CandidateNavP;
    local float CandidateDist;
	local float TempDist;

    foreach AllActors(Class'NavigationPoint', TempNavP)
    {
        TempDist = VSize(Other.Location - TempNavP.Location);

        if (CandidateNavP == None || TempDist < CandidateDist)
        {
            CandidateNavP = TempNavP;
            CandidateDist = TempDist;
        }
    }

    return CandidateNavP;
}

//-------------------------------------
// Patrol Navigation
//-------------------------------------

function bool StartPatrol (name StartPointName, optional name EndPointName, optional bool bTeleportToStart, optional bool bRun, optional float Speed)
{
	local PatrolPoint DestinationPoint;

	DestinationPoint = GetPP(StartPointName);

	if ( DestinationPoint == None )
	{
		print("Couldn't find start patrol point of name " $ string(StartPointName));
		return False;
	}

	if ( bTeleportToStart )
	{
		SetLocation(DestinationPoint.Location);
	}

	if ( Speed > 0 )
	{
		GroundSpeed = Speed;
	}
	else if ( bRun )
	{
		GroundSpeed = GroundRunSpeed;
	}
	else
	{
		GroundSpeed = GroundWalkSpeed;
	}

	FirstPointName = StartPointName;
	DestinationPointName = EndPointName;

	ClearNavP();

	GotoState('statePatrol');
	return True;
}

function bool StartLead (name StartPointName, optional name EndPointName, optional bool bTeleportToStart)
{
	FirstNavP = GetPP(StartPointName);

	if ( FirstNavP == None )
	{
		print("Couldn't find start lead point of name " $ string(StartPointName));
		return False;
	}

	if ( bTeleportToStart )
	{
		SetLocation(FirstNavP.Location);
	}

	GroundSpeed = GroundRunSpeed;

	FirstPointName = StartPointName;
	DestinationPointName = EndPointName;

	ClearNavP();

	bLeadingHarry = True;

	GotoState('statePatrol');
	return True;
}

function RestartPatrol()
{
	SetLocation2(FirstNavP.Location);

	if (bLeadingHarry)
	{
		StartLead(FirstNavP.Name,'None',True);
	}
	else
	{
		StartPatrol(FirstNavP.Name,'None',True);
	}

	Print("Restarting Patrol");
}

function PatrolPoint GetPP(name TargetPointName)
{
	local PatrolPoint TempPP;

	foreach AllActors(Class'PatrolPoint',TempPP)
	{
		if ( TempPP.Name == TargetPointName )
		{
			break;
		}
	}

	return TempPP;
}

function PatrolPoint GetTaggedPP(name TargetTag)
{
	local PatrolPoint TempPP;

	foreach AllActors(Class'PatrolPoint',TempPP,TargetTag)
	{
		break;
	}

	return TempPP;
}

function PatrolPoint GetCutPP(name TargetCutName)
{
	local PatrolPoint TempPP;

	foreach AllActors(Class'PatrolPoint',TempPP)
	{
		if ( TempPP.CutName ~= TargetCutName )
		{
			break;
		}
	}

	return TempPP;
}

function ClearNavP()
{
	FirstNavP = None;
	DestNavP = None;
	NextNavP = None;
	PrevNavP = None;
	LeadNavP = None;
}

state statePatrol
{
	event BeginState()
	{
		FirstNavP = GetPP(FirstPointName);
		DestNavP = FirstNavP;
	}

	event EndState()
	{
		ClearNavP();
		bLeadingHarry = False;
	}

	PatrolLoop:
		NextNavP = None;

		if ( PatrolPoint(DestNavP).PatrolAnim != '')
		{
			LoopAnim(PatrolPoint(DestNavP).PatrolAnim,,0.75);
		}
		else if ( IsRunning() )
		{
			PlayRunAnim();
		}
		else
		{
			PlayWalkAnim();
		}

		if ( PatrolPoint(DestNavP).PatrolSound != None )
		{
			PlaySound(PatrolPoint(DestNavP).PatrolSound, SLOT_Misc, [Loop] True);
		}

		while (NextNavP != DestNavP)
		{
			NextNavP = NavigationPoint(FindPathToward(DestNavP));

			if ( NextNavP != None )
			{
				MoveToward(NextNavP);
			}
			else
			{
				Print("Couldn't find NextNavP, going to idle!");
				GotoState('stateIdle');
			}

			PrevNavP = NextNavP;
			SleepForTick();
		}

		MoveToward(DestNavP);
	
	AtDest:
		PrevNavP = DestNavP;
		DestNavP = None;

		while ( bLeadingHarry && (GetDistanceFromActor < RequiredLeadDistance ) )
		{
			if( !bTurnTo_FollowActor )
			{
				EnableTurnTo(PlayerHarry);
			}

			SleepForTick();
		}

		if ( PatrolPoint(PrevNavP).pausetime > 0.0 )
		{
			Velocity = Vect(0,0,0);
			Acceleration = Vect(0,0,0);

			if ( PatrolPoint(PrevNavP).PauseAnim != '' )
			{
				LoopAnim(PatrolPoint(PrevNavP).PauseAnim,,0.5);
			}
			else
			{
				LoopAnim(IdleAnimName,,0.5);
			}

			if ( PatrolPoint(PrevNavP).EventToSend != '' )
			{
				TriggerEvent(PatrolPoint(PrevNavP).EventToSend,self,self);
			}

			if ( PatrolPoint(PrevNavP).bUseLookDir )
			{
				TurnTo(Location + PatrolPoint(PrevNavP).lookDir);
			}

			Sleep(PatrolPoint(PrevNavP).pausetime);
		}

		if ( PrevNavP.Nextpatrol != '' )
		{
			DestinationObjectName = PatrolPoint(PrevNavP).Nextpatrol;
			DestNavP = GetTaggedNavP(DestinationObjectName);
		}
		else if ( PrevNavP.NextPatrol_ObjectName != '' )
		{
			DestinationObjectName = PatrolPoint(PrevNavP).NextPatrol_ObjectName;
			DestNavP = GetNavP(DestinationObjectName);
		}

		if ( DestNavP == None )
		{
			Print("Couldn't find next DestNavP, going to idle!");
			GotoState('stateIdle');
		}

		SleepForTick();
		Goto('PatrolLoop');
}

//-------------------------------------
// FlyTo
//-------------------------------------
function bool SetupFlyTo()
{
	if ( FTController == None )
	{
		FTController = Spawn(Class'FlyToController',self);

		if ( FTController == None )
		{
			Print("ERROR! Couldn't make FlyController.",true);
			return false;
		}
	}

	TickParent = FTController;
	FTController.EnableController();
	Print("FlyController created.");
	return true;
}

function DoFlyTo(Vector DestLocation, enumMoveType MoveType, float Timespan, optional bool bStopAtEnd, optional name EventOnDone)
{
	SetupFlyTo();
	FlyToActor = None;
	FlyMoveType = MoveType;
	FlyToStart = Location;
	FlyToDest = DestLocation;
	FlyToTimespan = Timespan;
	FlyToTime = 0.0;
	FlyToEvent = EventOnDone;
	bFlyToStopAtEnd = bStopAtEnd;
}

function DoFlyToActor(Actor DestActor, Vector Offset, enumMoveType MoveType, float Timespan, bool bFixedToChar, optional bool bStopAtEnd, optional name EventOnDone)
{
	SetupFlyTo();
	FlyToActor = DestActor;
	bFlyToFixedToDestActor = bFixedToChar;
	FlyMoveType = MoveType;
	FlyToStart = Location;
	FlyToDest = DestActor.Location;
	FlyToDestOffset = Offset;
	FlyToTimespan = Timespan;
	FlyToTime = 0.0;
	FTController.TickParent = DestActor;
	FlyToEvent = EventOnDone;
	bFlyToStopAtEnd = bStopAtEnd;
}

function FlyToDone()
{
	Print("Flew to " $ string(FlyToDest),true);
	OnEvent(FlyToEvent);
	DoCutCueNotify();
}

//-------------------------------------
// Easing
//-------------------------------------
function float EaseMovement (float t, enumMoveType EaseType)
{
	t = FClamp(t,0.0,1.0);

	switch (EaseType)
	{
		case MOVE_TYPE_EASE_FROM:
			return EaseFrom(t);
		case MOVE_TYPE_EASE_TO:
			return EaseTo(t);
		case MOVE_TYPE_EASE_FROM_AND_TO:
			return EaseBetween(t);
		default:
	}

	return t;
}

function float EaseBetween (float t)
{
	if ( t <= 0 )
	{
		return 0.0;
	}
	else if ( t < 0.5 )
	{
		return 2.0 * t * t;
	}
	else if ( t < 1.0 )
	{
		return 1.0 - 2.0 * (1.0 - t) * (1.0 - t);
	}
	else
	{
		return 1.0;
	}
}

function float EaseFrom (float t)
{
	if ( t <= 0 )
	{
		return 0.0;
	}
	else if ( t < EaseFromX )
	{
		return 2.0 * t * t;
	}
	else if ( t < 1.0 )
	{
		return EaseFromM * t + EaseFromB;
	}
	else
	{
		return 1.0;
	}
}

function float EaseTo (float t)
{
	if ( t <= 0 )
	{
		return 0.0;
	}
	else if ( t < 1 - EaseFromX )
	{
		return EaseFromM * t + 0;
	}
	else if ( t < 1.0 )
	{
		return 1.0 - 2.0 * (1.0 - t) * (1.0 - t);
	}
	else
	{
		return 1.0;
	}
}

//-------------------------------------
// CutCommands
//-------------------------------------
function PlayerCutCapture();

function PlayerCutRelease();

function bool CutCommand(string Command, optional string Cue, optional bool bFastFlag)
{
	local string ActualCommand;
	local string TargetName;
	local Actor TempActor;

	ActualCommand = ParseDelimitedString(Command," ",1,False);
	ActualCommand = ToLower(ActualCommand);

	switch(ActualCommand)
	{
		case "capture": 				CutCommand_Capture(); break;
		case "release":					CutCommand_Release(); break;
		case "say": 					return Command_M212Say(Command,Cue,bFastFlag);
		case "flyto": 					return CutCommand_FlyTo(Command,Cue,bFastFlag);
		case "flytounlocked": 
		case "frayunlocked":
		case "funckled":
		case "fuct":					FTController.DisableController(); break;
		case "matchrot":				return CutCommand_MatchRot(Command,Cue,bFastFlag);
		case "leadactor":				return CutCommand_LeadActor(Command,Cue,bFastFlag);
		case "easebetweenlinearness":	CutCommand_EaseBetweenLinearness(Command); return true;
		case "setonpatrolpointpath":	CutCommand_SetOnPatrolPointPath(Command,Cue,bFastFlag);
		case "gotostate":				CutCommand_GotoState(Command,Cue); return true;
		case "visibleinsoftware":		CutCommand_RelevantInSoftware(True,Cue); return true;
		case "invisibleinsoftware":		CutCommand_RelevantInSoftware(False,Cue); return true;
		case "fadeto":					return CutCommand_FadeTo(Command,Cue,bFastFlag);
		case "castspell":				return CutCommand_CastSpell(Command,Cue,bFastFlag);
		case "set":						return CutCommand_HandleSet(Command,Cue,bFastFlag);
		default: break;
	}

	return Super.CutCommand(Command,Cue,bFastFlag);
}

function CutCommand_Capture()
{
	PreCaptureState = GetStateName();

	Acceleration = vect(0,0,0);
	Velocity = vect(0,0,0);

	if ( HasAnim(IdleAnimName) )
	{
		LoopAnim(IdleAnimName, RandRange(0.8, 1.2), 0.75);
		AnimFrame = RandRange(0, 0.7);
	}

	GotoState('stateCutCapture');
}

function CutCommand_Release()
{
	if ( ShouldPlayIdleOnRelease() )
	{
		LoopAnim(IdleAnimName, 1.0, 0.75);
	}

	DestroyControllers();

	if ( IsInState('stateCutCapture') )
	{
		GotoState(PreCaptureState);
	}
}

function bool CutCommand_HandleSet(string Command, optional string Cue, optional bool bFastFlag)
{
	local string VariableName;
	local string VariableValue;

	VariableName = ToLower(ParseDelimitedString(Command, " ", 2, False));
	VariableValue = ParseDelimitedString(Command,  " ", 3, False);

	switch(VariableName)
	{
		case "bumpset":
			Print("Setting BumpSet to: " $ VariableValue);
			BumpSetFile = VariableValue;
			break;
		case "bumpprefix":
			Print("Setting BumpLineSetPrefix to: " $ VariableValue);
			BumpLineSetPrefix = VariableValue;
			break;
		default:
	}

	CutCue(Cue);
	return true;
}

function bool CutCommand_FlyTo(string Command, optional string Cue, optional bool bFastFlag)
{
	local string TargetCutName;
	local string ParamString;
	local bool bFixedToChar;
	local bool bCalcTimeFromSpeed;
	local bool bStopAtEnd;
	local bool bRelativeJustForInit;
	local int i;
	local float Speed;
	local float FlyTime;
	local Vector FlyOffset;
	local Actor A;
	local enumMoveType MoveType;

	bFixedToChar = True;
	bRelativeJustForInit = True;
	MoveType = MOVE_TYPE_EASE_FROM_AND_TO;
	CutName = ParseDelimitedString(Command," ",2,False);
	DestroyControllers();

	foreach AllActors(Class'Actor',A)
	{
		if ( A.CutName ~= TargetCutName)
		{
			break;
		}
	}

	if ( A == None )
	{
		CutErrorString = "FlyTo: No Actor with CutName '" $ TargetCutName $ "'";
		CutNotifyActor.CutCue(cue);
		return false;
	}

	if ( bFastFlag )
	{
		SetLocation(A.Location);
		CutNotifyActor.CutCue(cue);
		return True;
	}

	for (i = 3; i < 15; i++)
	{
		ParamString = ParseDelimitedString(Command," ",i,False);

		if ( ParamString == "" )
		{
			break;
		}

		if ( ParamString ~= "Snap" )
		{
			MoveType = MOVE_SNAP;
		}
		else if ( ParamString ~= "Linear" || ParamString ~= "l" )
		{
			MoveType = MOVE_TYPE_LINEAR;
		}
		else if ( ParamString ~= "EaseFrom" || ParamString ~= "ef" )
		{
			MoveType = MOVE_TYPE_EASE_FROM;
		}
		else if ( ParamString ~= "EaseTo" || ParamString ~= "et" )
		{
			MoveType = MOVE_TYPE_EASE_TO;
		}
		else if ( ParamString ~= "EaseBetween" )
		{
			MoveType = MOVE_TYPE_EASE_FROM_AND_TO;
		}
		else if ( ParamString ~= "Relative" || ParamString ~= "Rel" )
		{
			bFixedToChar = False;
		}
		else if ( ParamString ~= "Fixed" )
		{
			bRelativeJustForInit = False;
		}
		else if ( Left(ParamString,2) ~= "x=" )
		{
			FlyOffset.X = float(Mid(ParamString,2));
		}
		else if ( Left(ParamString,2) ~= "y=" )
		{
			FlyOffset.Y = float(Mid(ParamString,2));
		}
		else if ( Left(ParamString,2) ~= "z=" )
		{
			FlyOffset.Z = float(Mid(ParamString,2));
		}
		else if ( Left(ParamString,5) ~= "time=" )
		{
			FlyTime = float(Mid(ParamString,5));
		}
		else if ( Left(ParamString,6) ~= "speed=" )
		{
			Speed = float(Mid(ParamString,6));
			bCalcTimeFromSpeed = True;
		}
		else if ( ParamString ~= "StayLocked" || ParamString ~= "sl" )
		{
			bStayLockedToActor = True;
		}
		else
		{
			Print("ERROR!! FlyTo option '" $ ParamString $ "' not recognized, ignoring.");
		}
	}

	if ( FlyTime <= 0 )
	{
		MoveType = MOVE_SNAP;
	}

	if ( bRelativeJustForInit && FlyOffset != vect(0,0,0) )
	{
		FlyOffset = FlyOffset >> A.Rotation;
	}

	if ( MoveType == MOVE_SNAP )
	{
		if ( !SetLocation2(A.Location + FlyOffset) )
		{
			Print("ERROR!! FlyTo/Snap wasn't able to move me to destination. Cutname: " $ CutName);
		}

		CutNotifyActor.CutCue(Cue);
	}
	else
	{
		sCutNotifyCue = Cue;
	}

	if ( bCalcTimeFromSpeed )
	{
		FlyTime = VSize(A.Location - Location) / Speed;
	}

	DoFlyToActor(A, FlyOffset, MoveType, FlyTime, bFixedToChar, bStopAtEnd);
	return true;
}

function bool CutCommand_SetOnPatrolPointPath(string Command, optional string Cue, optional bool bFastFlag)
{
	local PatrolPoint PP;
	local string ParsedString;
	local int i;

	ParsedString = ParseDelimitedString(Command," ",2,False);

	PP = GetCutPP(ParsedString);

	if ( PP == None )
	{
		CutErrorString = " SetOnPatrolPath: No Actor with CutName '" $ ParsedString $ "'";
		CutNotifyActor.CutCue(Cue);
		return false;
	}

	for ( i = 3; i < 15; i++ )
	{
		ParsedString = ParseDelimitedString(Command," ",i,False);

		if ( ParsedString == "" )
		{
			break;
		}
	}

	FirstPointName = PP.Name;

	ClearNavP();

	GotoState('statePatrol');
	return true;
}

function bool CutCommand_MatchRot(string Command, optional string Cue, optional bool bFastFlag)
{
	local Actor A;
	local string ParsedString;
	local int i;
	local Rotator R;

	i = 2;
	ParsedString = ParseDelimitedString(Command," ",2,False);

	foreach AllActors(Class'Actor',A)
	{
		if ( A.CutName ~= ParsedString )
		{
			break;
		}
	}

	if ( A == None )
	{
		CutErrorString = "No Actor with CutName '" $ ParsedString $ "'";
		CutNotifyActor.CutCue(Cue);
		return false;
	}

	i++;

	for ( i = i; i < 20; i++)
	{
		ParsedString = ParseDelimitedString(Command," ",i,false);

		if ( ParsedString == "" )
		{
			break;
		}
	}

	if ( A.IsA('InterpolationPoint') )
	{
		R = rotator(InterpolationPoint(A).StartControlPoint);
	}
	else
	{
		R = A.Rotation;
	}

	DesiredRotation = R;

	if ( Physics == PHYS_None )
	{
		SetPhysics(PHYS_Rotating);
	}

	bRotateToDesired = True;
	bFixedRotationDir = False;

	if ( bFastFlag )
	{
		SetRotation(R);
	}

	CutNotifyActor.CutCue(Cue);
	return true;
}

function bool CutCommand_LeadActor(string Command, optional string Cue, optional bool bFastFlag)
{
	local Actor A;
	local Actor ActorToLead;
	local name StartPP;
	local name DestPP;
	local string ParsedString;
	local int i;
	local name Anim;
	local string Speech;

	i = 2;
	ParsedString = ParseDelimitedString(Command," ",i,false);

	foreach AllActors(Class'Actor',ActorToLead)
	{
		if ( ActorToLead.CutName ~= ParsedString )
		{
			break;
		}
	}

	if ( ActorToLead == None )
	{
		CutErrorString = "No Actor with CutName '" $ ParsedString $ "'";
		CutNotifyActor.CutCue(Cue);
		return false;
	}

	i++;
	ParsedString = ParseDelimitedString(Command," ",i,false);

	foreach AllActors(Class'Actor',A)
	{
		if ( A.CutName ~= ParsedString )
		{
			break;
		}
	}

	if ( A == None )
	{
		CutErrorString = "No Actor with CutName '" $ ParsedString $ "'";
		CutNotifyActor.CutCue(Cue);
		return false;
	}

	StartPP = A.Name;
	i++;
	ParsedString = ParseDelimitedString(Command," ",i,false);

	foreach AllActors(Class'Actor',A)
	{
		if ( A.CutName ~= ParsedString )
		{
			break;
		}
	}

	if ( A == None )
	{
		CutErrorString = "No Actor with CutName '" $ ParsedString $ "'";
		CutNotifyActor.CutCue(Cue);
		return false;
	}

	DestPP = A.Name;

	i++;

	for ( i = i; i < 20; i++ )
	{
		ParsedString = ParseDelimitedString(Command," ",i,false);

		if ( ParsedString == "" )
		{
			break;
		}
		else if ( Left(ParsedString,5) ~= "anim=" )
		{
			Anim = name(Mid(ParsedString,5));
		}
		else if ( Left(ParsedString,8) ~= "BumpSet=" )
		{
			Speech = Mid(ParsedString,8);
		}
	}

	StartLead(StartPP,DestPP,Anim,Speech);
	sCutNotifyCue = Cue;
	return true;
}

function bool CutCommand_FadeTo(string Command, optional string Cue, optional bool bFastFlag)
{
	local FadeActorController FAController;
	local string ParsedString;
	local float FadeTime;
	local float FadeOpacity;
	local int i;

	FadeTime = 1.0;
	FadeOpacity = 0.5;

	for( i = 1; i < 4; i++ )
	{
		ParsedString = ParseDelimitedString(Command," ",i,false);

		if ( Left(ParsedString,8) ~= "Opacity=" )
		{
			FadeOpacity = float(Mid(ParsedString,8));
		}
		else if ( Left(ParsedString,5) ~= "Time=" )
		{
			FadeTime  = float(Mid(ParsedString,5));
		}
		else if ( ParsedString == "" )
		{
			break;
		}
	}

	if ( bFastFlag )
	{
		FadeTime = 0.0;
	}

	FAController = Spawn(Class'FadeActorController');
	FAController.Init(self,FadeOpacity,FadeTime,Cue);
	return true;
}

function nool CutCommand_CastSpell(string Command, optional string Cue, optional bool bFastFlag)
{
	local string ParsedString;
	local string SpellName;
	local string SpellTarget;
	local Actor TargetActor;
	local bool bFoundTarget;
	local int i;

	if ( !Weapon.IsA('baseWand') )
	{
		CutErrorString = "Could not cast spell as we do not have baseWand equipped!";
		CutNotifyActor.CutCue(Cue);
		return false;
	}

	for ( i = 1; i < 4; i++ )
	{
		ParsedString = ParseDelimitedString(Command," ",i,false);

		if ( Left(ParsedString,12) ~= "SpellTarget=" )
		{
			SpellTarget = Mid(ParsedString,12);
		}
		else if ( Left(ParsedString,10) ~= "SpellName=" )
		{
			SpellName = Mid(ParsedString,10);
		}
		else if ( ParsedString == "" )
		{
			break;
		}
	}

	if ( SpellTarget == "" )
	{
		CutErrorString = "CastSpell command is missing SpellTarget parameter!";
		CutNotifyActor.CutCue(Cue);
		return false;
	}

	foreach AllActors(Class'Actor',TargetActor)
	{
		if ( (TargetActor.Name == name(SpellTarget)) || (TargetActor.CutName == SpellTarget) )
		{
			bFoundTarget = True;
			break;
		}
	}

	if ( !bFoundTarget )
	{
		CutErrorString = "Could not find Actor in level with name: " $ SpellTarget;
		CutNotifyActor.CutCue(Cue);
		return false;
	}

	baseWand(Weapon).PrimaryFireAction();

	CutNotifyActor.CutCue(Cue);
	return true;
}

function CutCommand_EaseBetweenLinearness(string Command)
{
	EaseBetweenLinearness = float(ParseDelimitedString(Command," ",2,False));
}

function CutCommand_GotoState(string Command, string Cue)
{
	GotoState(name(ParseDelimitedString(Command," ",2,False)));
	CutCue(Cue);
}

function CutCommand_RelevantInSoftware(bool bIsRelevant, string Cue)
{
	bRelevantInSoftwareRenderer = bIsRelevant;
	CutCue(Cue);
}

function GlobalCutBypass()
{
	Super.GlobalCutBypass();

	if ( (FTController != None) && FTController.bEnabled )
	{
		SetLocation2(FTController.GetVDest());
		DoCutCueNotify();
		FTController.DisableController();
	}
}

state stateCutCapture {}

//-------------------------------------
// Helper / Misc. Functions
//-------------------------------------
function PawnHearHarryNoise();

function EnableCollision()
{
	SetCollision(True,True,True);
}

function DisableCollision()
{
	SetCollision(False,False,False);
}

function Vector GetActorXYLocation(Actor Other)
{
	return vect(Other.Location.X, Other.Location.Y, Location.Z);
}

function Vector GetForwardVector()
{
	return Normal(Vector(Rotation));
}

function Vector GetRandomNearbyLocation(Vector BaseLocation, optional float NearbyRange, optional bool bTraceForGround)
{
	local float XPos;
	local float YPos;
	local Vector RandLocation;

	if ( NearbyRange <= 0.0 )
	{
		NearbyRange = SightRadius;
	}

	XPos = RandRange(-NearbyRange, NearbyRange);
	YPos = RandRange(-NearbyRange, NearbyRange);

	RandLocation = vect(XPos,YPos,BaseLocation.Z);

	if ( bTraceForGround )
	{
		if ( !IsOnGround(RandLocation) || IsOutOfBounds(RandLocation) )
		{
			return BaseLocation;
		}
	}

	return RandLocation;
}

function Vector GetNearbyLocationWithSpread(Vector BaseLocation, float Accuracy, optional float MaxSpread)
{
	local float Spread;
	local Vector Dir;
	local Vector Offset2D;
	local Rotator AimRot;

	if ( MaxSpread <= 0.0 )
	{
		MaxSpread = 8192.0;
	}

	Offset2D = BaseLocation;
	Offset2D.Z = 0.0;

	AimRot = rotator(Offset2D);

	Spread = (1.0 - Accuracy) * MaxSpread;

	AimRot.Yaw += RandRange(-Spread,Spread);

	Dir = vector(AimRot);

	Dir *= VSize(Offset2D);

	Dir.Z = BaseLocation.Z;

	return Dir;
}

function bool IsOutOfBounds(Vector CheckLocation)
{
	return !FastTrace(CheckLocation,CheckLocation);
}

function bool IsOnGround(Vector CheckLocation, optional float TraceRange)
{
	local Vector EndTrace;

	if ( TraceRange <= 0.0 )
	{
		TraceRange = CollisionHeight + 1.0;
	}
	
	EndTrace = vect(0,0,1) * TraceRange;
	EndTrace = CheckLocation - EndTrace;

	return !FastTrace(EndTrace, CheckLocation);
}

function bool IsSuspicious()
{
	return CurrentSuspicion > 0.0;
}

function bool IsValidNavP(NavigationPoint TestNavP)
{
	return TestNavP != None && TestNavP != PrevNavP;
}

function bool ShouldPlayIdleOnRelease()
{
  	return True;
}

function bool IsRunning()
{
	return GroundSpeed >= (GroundRunSpeed - RunThreshold);
}

function bool OnALedge(Vector Loc, optional float TraceLength)
{
	local Vector CurrentLocation;
	local Vector UnderLocation;

	if ( TraceLength == 0 )
	{
		TraceLength = -35.0;
	}

	CurrentLocation = Loc;
	UnderLocation = CurrentLocation + Vec(0.0,0.0,-35.0);

	return FastTrace(UnderLocation,CurrentLocation);
}

function float GetDistanceFromActor(Actor Other)
{
    return Abs(VSize(Location - Other.Location));
}

function float GetDistanceFromVector(Vector OtherLoc)
{
    return Abs(VSize(Location - OtherLoc));
}

function Actor GetNearestActorOfClass(class<Actor> ClassToMatch)
{
	local Actor A;
	local Actor CurrentWinner;
	local float CurrentDistance;

	foreach AllActors(ClassToMatch, A)
	{
		if ( CurrentWinner != None )
		{
			CurrentWinner = A;
			CurrentDistance = GetDistanceFromActor(A);
		}

		if ( GetDistanceFromActor(A) < CurrentDistance)
		{
			CurrentWinner = A;
			CurrentDistance = GetDistanceFromActor(A);
		}
	}

	return CurrentWinner;
}

function PlayRunAnim()
{
	PatrolAnimRate = GroundSpeed / GroundRunSpeed;
	LoopAnim(RunAnimName,PatrolAnimRate,0.75);
}

function PlayWalkAnim()
{
	PatrolAnimRate = GroundSpeed / GroundWalkSpeed;
	LoopAnim(WalkAnimName,PatrolAnimRate,0.75);
}

function EnableTurnTo(actor TurnTarget)
{
    bTurnTo_FollowActor = true;
    TurnTo_TargetActor = TurnTarget;
    MakeTurnToPermanentController();
}

function DisableTurnTo()
{
	bTurnTo_FollowActor = false;
	TurnTo_TargetActor = None;
	DestroyTurnToPermanentController();
}

function vector GetDirectionToActor(Actor Other)
{
	if ( Other == None )
	{
		return vect(0,0,0);
	}

	return Normal( Other.Location - Location );
}

function vector GetDirectionAwayFromActor(Actor Other)
{
	if ( Other == None )
	{
		return vect(0,0,0);
	}

	return Normal( Location - Other.Location );
}

function Timer()
{
	Super.Timer();

	if ( bDespawnable && bPendingDespawn && !PlayerCam.CameraCanSeeYou(Location) )
	{
		GotoState(stateDestroy);
	}
}

//-------------------------------------
// Debug
//-------------------------------------
function Print(string msg, optional bool BothLogs)
{
	if (msg == "")
	{
		return;
	}

	if (BothLogs)
	{
		CMAndLog(string(self) $ " says: " $ msg);
	}
	else
	{
		Log(string(self) $ " says: " $ msg);
	}
}

//-------------------------------------
// Misc. States
//-------------------------------------
auto state stateIdle
{
	begin:
		LoopAnim('Idle');
}

state stateInfoPrint {}

state stateDestroy
{
	event BeginState()
	{
		SpellVulnerableTo = None;

		if ( DiedFX != None )
		{
			Spawn(DiedFX,,,Location);
		}
	}

	begin:
		SleepForTick();
		Destroy();
}

state stateGoHome
{
	begin:
		while( GetDistanceFromVector(HomeLocation) > SightRadius )
		{
			NextNavP = NavigationPoint(FindPathToward(DestNavP));

			if ( NextNavP == None || NextNavP == PrevNavP )
			{
				break;
			}

			MoveToward(NextNavP);
			SleepForTick();
		}

		GotoState(NextState);
}

state stateDie
{
	begin:
		Print("AHHHHHHHHHH I'M DEAD!!!!!!!!!!");
		GotoState('stateDestroy');
}




//-------------------------------------
// Default Properties
//-------------------------------------

defaultproperties
{
	NINETY_DEG=16384

	PushForce=260.0
	RequiredSpellHits=1

	bFollowUpSearch=True

	MinStealthChaseDelay=1.0
	MaxStealthChaseDelay=2.5

	RequiredSuspicion=10.0
	MaxSuspicion=20.0
	SuspicionGrowRate=5.0
	SuspicionLossRate=2.0

	AnimStealthSpot(0)=Idle
	AnimStealthCaught(0)=Idle

	PostChaseState=statePatrol

	FidgetDelayMin=2.0
	FidgetDelayMax=5.0

	ShadowClass=Class'ActorShadow'
	ShadowScale=1.0

	bDespawnable=True

	RunThreshold=50.0
	
	PatrolAnimRate=1.0

	RequiredLeadDistance=300.0

	FlyMoveType=MOVE_TYPE_EASE_FROM_AND_TO
	EaseBetweenLinearness=2.0

	FootstepFrequency=1.0

	IdleAnimations(0)=Idle
	bPlayIdleOnPlay=True

	StepDistance=50.0
	StepThreshold=16.0

	DrawType=DT_Mesh

	Mesh=SkeletalMesh'HProps.skSundialMesh'

	bCantStandOnMe=True

    bCanWalk=True

    GroundSpeed=200.00

    AirSpeed=100.00

    AccelRate=1024.00

    SightRadius=512.00

    PeripheralVision=0.85

    BaseEyeHeight=40.75

    EyeHeight=40.75

    Physics=PHYS_Walking

    bGestureFaceHorizOnly=False

    Buoyancy=118.80

	AttitudeToPlayer=ATTITUDE_Friendly

	Health=1

	AmbientGlow=32

	NextState=stateIdle
}