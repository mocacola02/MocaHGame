//==========================================
//
//	HPawn. Initially rewritten 11/21/2025
//
//==========================================
class HPawn extends Pawn;

// Enemy Bar
var Texture EnemyBarBaseTexture;
var Texture EnemyBarFullTexture;
var Texture EnemyBarEmptyTexture;

// Magic
var(SpellEffects) bool bFlipendable;

// Shadows
var(Display) class<ActorShadow> ShadowClass;
var(Display) float ShadowScale;

// Attached Particles
struct AttachedParticle
{
	var() array<class<ParticleFX>> ParticleClass;
	var() array<Vector> ParticleOffset;
};

var(Display) array<AttachedParticle> AttachedParticleFX;
var array<ParticleFX> AttachedParticleActors;

// Despawn
var() bool bDespawnable;
var bool bPendingDespawn;

// Movement
var float RunThreshold;

// Patrol
var NavigationPoint FirstNavP;
var NavigationPoint DestNavP;
var NavigationPoint NextNavP;
var NavigationPoint PrevNavP;
var NavigationPoint LeadNavP;

var float PatrolAnimRate;

var name FirstPointName;
var name DestinationPointName;

// Lead
var bool bLeadingHarry;
var float RequiredLeadDistance;

// FlyTo
var FlyToController FTController;
var Actor FlyToActor;

var enumMoveType FlyMoveType;

var bool bFlyToFixedToDestActor;
var bool bFlyToStopAtEnd;

var name FlyToEvent;

var Vector FlyToStart;
var Vector FlyToDest;
var Vector FlyToDestOffset;

var float FlyToTimespan;
var float FlyToTime;
var float EaseBetweenLinearness;

// Misc
var BaseCam PlayerCam;

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
}

//-------------------------------------
// Misc. Events
//-------------------------------------
event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	if  (DamageType == GetSpellName() )
	{
		ProcessSpell();
	}
	else if ( (DamageType == 'ZonePain') &&  !bIgnoreZonePainDamage )
	{
		Destroy();
	}
	else
	{
		Super.TakeDamage();
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
// Helper Functions
//-------------------------------------
function EnableCollision()
{
	SetCollision(True,True,True);
}

function DisableCollision()
{
	SetCollision(False,False,False);
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
// Magic
//-------------------------------------
function name GetSpellName()
{
	if (SpellVulnerableTo.IsA('baseSpell'))
	{
		return baseSpell(SpellVulnerableTo).Default.SpellName;
	}
	else
	{
		return SpellVulnerableTo.Default.Name;
	}
}

function ProcessSpell(class<baseSpell> HitSpell); // Define in child classes

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
// Misc Functions
//-------------------------------------
function Timer()
{
	if ( bDespawnable && bPendingDespawn && !PlayerCam.CameraCanSeeYou(Location) )
	{
		Destroy();
	}
}

function PawnHearHarryNoise();

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

function bool ShouldPlayIdleOnRelease()
{
  	return True;
}

function bool IsRunning()
{
	return GroundSpeed >= (GroundRunSpeed - RunThreshold);
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

function float GetDistanceFromActor(Actor Other)
{
    return VSize(Location - Other.Location);
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

//-------------------------------------
// Main States
//-------------------------------------
auto state stateIdle {}

state stateInfoPrint {}

//-------------------------------------
// Thrown
//-------------------------------------
function ThrownLanded ( Vector HitNormal ); //Define in child class

state stateBeingThrown
{
	event Landed ( Vector HitNormal )
	{
		ThrownLanded(HitNormal);
	}
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
// Dialog
//-------------------------------------
function float PlayDialog (string DialogID, optional string SectionName, optional string DialogFileName, optional string PackageName, optional ESoundSlot Slot, optional float Volume, optional bool bNoOverride, optional float Radius, optional float Pitch, optional bool Disable3D, optional bool Loop)
{
	local Sound DialogSound;
	local string DialogString;
	local float SoundLength;
	local int i;

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
	}

	return Super.CutCommand(Command,Cue,bFastFlag);
}

function CutCommand_Capture()
{
	Acceleration = vect(0,0,0);
	Velocity = vect(0,0,0);

	if ( HasAnim(IdleAnimName) )
	{
		LoopAnim(IdleAnimName, RandRange(0.8, 1.2), 0.75);
		AnimFrame = RandRange(0, 0.7);
	}
}

function CutCommand_Release()
{
	if ( ShouldPlayIdleOnRelease() )
	{
		LoopAnim(IdleAnimName, 1.0, 0.75);
	}

	DestroyControllers();
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

function CutCommand_MatchRot(string Command, optional string Cue, optional bool bFastFlag)
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

function CutCommand_LeadActor(string Command, optional string Cue, optional bool bFastFlag)
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

function CutCommand_FadeTo(string Command, optional string Cue, optional bool bFastFlag)
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

defaultproperties
{
	ShadowClass=Class'ActorShadow'
	ShadowScale=1.0

	bDespawnable=True

	RunThreshold=50.0
	
	PatrolAnimRate=1.0

	RequiredLeadDistance=300

	EaseBetweenLinearness=2.0

	DrawType=DT_Mesh
	Mesh=SkeletalMesh'HProps.skSundialMesh'
}