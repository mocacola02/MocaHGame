//================================================================================
// CutScene.
//================================================================================
// Omega: Cleaned up tabbing

class CutScene extends Actor;

const MAX_THREADS=20;
// Omega: If only we could update this to be dynamic
var() string aThreadScripts[20];
var CutScript aThreads[20];
var bool bHasBeenDisabled;
var bool Saved_bBumpStarts;
var bool Saved_bTriggerStarts;
var bool Saved_bDoImmediateStart;
var() bool bBumpStarts;
var() bool bTriggerStarts;
var() bool bLevelLoadStarts;
// Omega: Add support for uncompiled files
var() string FileName, UncompiledFileName, UncompiledFileExtension;
var() bool bPlayOnce;
var() bool bDelayLevelFadeIn;
var() bool bTriggerTogglesBumpStart;
var() bool bSkipAllowed;
var bool bDoImmediateStart;
var bool bPlaying;
var int numScriptsPlaying;
var int nPlayedCount;
var bool bFastForwarding;
var int safetyLoopCount;

// Omega: Support for loading specific cutscenes by the command line for testing
var NoPersistent bool bPlayByCmd, bDisabledByCmd, bCheckedCmd;

// Omega: New cutscript class vars. Cutscript now has a forward def for load, unimplemented for base
// cutscript class
var() class<CutScript> CutscriptClass, CutscriptDiskClass;

function CutSceneLog (string Str)
{
	Level.PlayerHarryActor.ClientMessage("CutSceneLog:<" $ FileName $ ">" $ Str);
	Log("CutSceneLog:<" $ FileName $ ">" $ Str);
}

function OpenCutConsole ()
{
  	HPConsole(Level.PlayerHarryActor.Player.Console).ShowCutConsole(True);
}

function CutCue (string cue)
{
	local int I;

	for(I = 0; I < MAX_THREADS; I++)
	{
		if ( aThreads[I] != None )
		{
			aThreads[I].CutCue(cue);
		}
	}
}

function bool CheckLaunchArgs()
{
	local array<String> LaunchArgs;
	local int i;

	bCheckedCmd = True;

	// Omega: Check our launch arguments:
	LaunchArgs = GetLaunchArgumentsArray();
	for(i = 0; i < LaunchArgs.Length; i++)
	{
		//Log(Name$ " Launch argument: " $LaunchArgs[i]);
		
		//Log("Launch arguments: " $LaunchArgs[i]);
		if(Left(LaunchArgs[i], len("TestCutscene=")) ~= "TestCutscene=")
		{
			if(Mid(LaunchArgs[i], len("TestCutscene=")) ~= String(Name))
			{
				if(bInCurrentGameState)
				{
					Log(Self$ "Found testing cutscene in our Gamestate, setting to bLevelLoadStarts = True!!");
					bPlayByCmd = True;
					return false;
				}
				else
				{
					bDisabledByCmd = True;

					Log(Self$ " Found testing cutscene NOT in our Gamestate. Will not start!!");
					GoToState('disabled');
					return true;
				}
			}
			else
			{
				bDisabledByCmd = True;

				Log(Name$ " Disabled from command line specifying test cutscene!");
				GotoState('disabled');
				return true;
			}
		}
	}

	return false;
}

event OnResolveGameState ()
{
	// Metallicafan212:	Cache the reference
	local Harry pHarry;
	
	pHarry = Harry(Level.PlayerHarryActor);

	if(CheckLaunchArgs())
	{
		return;
	}
	
	if(!bInCurrentGameState)
	{
		GotoState('disabled');
		Log("*** " $ string(self) $ " is NOT in the current GameState. CurrentGameState = " $ harry(Level.PlayerHarryActor).CurrentGameState);
	} 
	else 
	{
		GotoState('Idle');
		Log("*** " $ string(self) $ " is *IN* the current GameState. CurrentGameState = " $ harry(Level.PlayerHarryActor).CurrentGameState);
		if ( bDelayLevelFadeIn && bLevelLoadStarts )
		{
			//Log("Potential black screen cutscene: " $self$ " at time: " $Level.TimeSeconds);
			// Omega: Return if we're above 0 seconds, as we're likely to be a save
			if ( bPlayOnce && (nPlayedCount > 0) || Level.TimeSeconds != 0.00)
			{
				Log("*** " $ string(self) $ " Not setting faderate because we've either been played or loaded a save! Level time: " $Level.TimeSeconds);
				return;
			} 
			else 
			{
				//harry(Level.PlayerHarryActor).FadeRate = 0.0;
				pHarry.FadeRate = 0.0;
				pHarry.ConstantGlowFog.W = -1.0;
				
			}
		}
	}
	
	//log("ResolveGS");
}

event PostBeginPlay ()
{
	if(!bCheckedCmd)
	{
		CheckLaunchArgs();
	}

	if ((bLevelLoadStarts || bPlayByCmd) && !bDisabledByCmd)
	{
		bDoImmediateStart = True;
	}

	if(bDisabledByCmd)
	{
		GoToState('Disabled');
	}
	
	//log("Post");
}

function CreateThreads ()
{
	local int I;
	local int t;
	local string Line;
	local array<string> SA;

	if(UncompiledFileName != "")
	{
		CreateUncompiledThreads();
	}
	else
	if (FileName != "")
	{
		for(t = 0; t < MAX_THREADS; t++)
		{
			Line = Localize("thread_"$t,"line_0","Cutscenes\\" $FileName);
			if ( InStr(Line,"<?") == -1 )
			{
				//aThreads[t] = Spawn(Class'CutScriptDisk');
				//CutScriptDisk(aThreads[t]).load("thread_" $t,"Cutscenes\\" $FileName);

				// Omega: New cutscript disk spawn:
				aThreads[t] = Spawn(CutscriptDiskClass);
				aThreads[t].load("thread_" $t,"Cutscenes\\" $FileName);
				aThreads[t].parentCutScene = self;
				aThreads[t].threadNum = t;
				aThreads[t].Play();
				//Log(Self$ "Disk cutscript spawn: " $aThreads[t]);
			}
		}
	} 
	else 
	{
		for(I = 0; I < MAX_THREADS; I++)
		{
			if ( Len(aThreadScripts[I]) > 0 )
			{
				//aThreads[I] = Spawn(Class'CutScript');
				// Omega: New cutscript spawn:
				aThreads[I] = Spawn(CutscriptClass);
				aThreads[I].Script = aThreadScripts[I];
				aThreads[I].parentCutScene = self;
				// Omega: They had this using t instead of I...
				aThreads[I].threadNum = I;
				aThreads[I].Play();
				//Log(Self$ "Regular cutscript spawn: " $aThreads[t]);
			}
		}
	}
}

// Omega: Create our uncompiled threads
function CreateUncompiledThreads()
{
	local int i, t;
	local array<string> SA;
	local string Script;

	// Omega: Initialize ourselves at -1 so we end up at 0 starting out
	// Probably a better way to do this but eh, saves us a boolean and whatnot
	t = -1;

	LoadStringArray(SA, "..\\Cutscenes\\" $UncompiledFileName$UncompiledFileExtension);

	Log(UncompiledFileName$UncompiledFileExtension$ " lines: " $SA.Length);

	if(SA.Length == 0)
	{
		return;
	}

	// Omega: Start with a script, create new ones as needed
	aThreads[0] = Spawn(CutscriptClass);
	aThreads[0].parentCutscene = self;
	aThreads[0].ThreadNum = 0;

	for(i = 0; i < SA.Length; i++)
	{
		//Log("Thread " $Max(t, 0)$ " SA[i] = " $SA[i]);
		// Omega: KW used the right bracket only for this detection in their cut compiler. Man.
		if(instr(SA[i], "[") != -1 && instr(SA[i], "]") != -1)
		{
			// Omega: Find our first thread index
			t++;
			if(t > 0)
			{
				aThreads[t] = Spawn(CutscriptClass);
				aThreads[t].parentCutscene = self;
				aThreads[t].ThreadNum = t;
			}
			if(t > MAX_THREADS)
			{
				CMAndLog("ERROR!! Too many threads being created for uncompiled cutscene: " $UncompiledFileName$UncompiledFileExtension);

				// Omega: Play them for safety anyway:
				for(i = 0; i < MAX_THREADS; i++)
				{
					aThreads[i].Play();
				}

				return;
			}

			Log("Appending thread line into thread: " $Max(t, 0));
			// Omega: Comment it out so we don't get spew, but keep it for debugging purposes
			//aThreads[Max(t, 0)].Script = aThreads[Max(t, 0)].Script $ "//" $SA[i] $ Chr(10);
			Script = "//" $SA[i] $ Chr(10);
		}
		else
		{
			Script $= SA[i] $ Chr(10);
			//aThreads[Max(t, 0)].Script = aThreads[Max(t, 0)].Script $ SA[i] $ Chr(10);
		}
		
		// Omega: For some reason there seems to be a limitation directly addressing it? Odd
		aThreads[Max(t, 0)].Script = Script;
	}

	for(i = 0; i < MAX_THREADS; i++)
	{
		aThreads[i].Play();
	}
}


function DeleteThreads ()
{
	local int I;

	for(I = 0; I < MAX_THREADS; I++)
	{
		if ( aThreads[I] != None )
		{
			aThreads[I].Destroy();
		}
	}
}

auto state disabled
{
	event BeginState ()
	{
		harry(Level.PlayerHarryActor).ClientMessage(string(self) $ " Entering DISABLED state");
		if ( bPlaying || bFastForwarding )
		{
			CutSceneLog("Error. Entering disabled while still running. Forceing finish");
			ForceFinish();
			bPlaying = False;
			bFastForwarding = False;
		}
		if ( bInCurrentGameState )
		{
			harry(Level.PlayerHarryActor).ClientMessage(string(self) $ " Changing to ENABLED state");
			GotoState('Idle');
		}
	}
	
	event Touch (Actor Other)
	{
	}
	
	event Trigger (Actor Other, Pawn EventInstigator)
	{
	}
	
	function Play ()
	{
	}
  
}

state Idle
{
	event BeginState ()
	{
		if(!bCheckedCmd)
		{
			CheckLaunchArgs();

			if(bPlayByCmd)
			{
				bDoImmediateStart = True;
			}
			else
			if(bDisabledByCmd)
			{
				GoToState('Disabled');
			}
		}

		harry(Level.PlayerHarryActor).ClientMessage(string(self) $ " Entering ENABLED state");
		if (  !bInCurrentGameState )
		{
			harry(Level.PlayerHarryActor).ClientMessage(string(self) $ " Changing to DISABLED state");
			GotoState('disabled');
		}
	}
	
	event Touch (Actor Other)
	{
		if ( harry(Other) != None )
		{
			harry(Other).ClientMessage(string(self) $ " Bumped. bBumpStarts=" $ string(bBumpStarts));
			if ( bBumpStarts &&  !harry(Other).HarryIsDead() )
			{
				Play();
			}
		}
	}
	
	event Trigger (Actor Other, Pawn EventInstigator)
	{
		if ( harry(Other).HarryIsDead() )
		{
			return;
		}
		if ( bTriggerTogglesBumpStart )
		{
			bBumpStarts =  !bBumpStarts;
			harry(Level.PlayerHarryActor).ClientMessage(string(self) $ "+++++++++++++++++++ Triggered bTriggerTogglesBumpStart. bBumpStarts=" $ string(bBumpStarts));
		}
		if ( bInCurrentGameState && bTriggerStarts )
		{
			if ( bPlayOnce )
			{
				bTriggerStarts = False;
			}
			
			Play();
		}
	}
	
	begin:
		bPlaying = False;
		if ( bDoImmediateStart )
		{
			bDoImmediateStart = False;
			Sleep(0.2);
			Play();
		}
}

function ForceFinish ()
{
	local int I;

	CutSceneLog("***Force Finishing");

	for(I = 0; I < MAX_THREADS; I++)
	{
		if ( (aThreads[I] != None) && aThreads[I].bPlaying )
		{
			aThreads[I].GotoState('Finished');
		}
	}
}

function bool CheckFinished ()
{
	local int I;
	local bool bStillRunning;

	bStillRunning = False;

	for(I = 0; I < MAX_THREADS; I++)
	{
		if ( (aThreads[I] != None) && aThreads[I].bPlaying )
		{
			bStillRunning = True;
		}
	}
	return  !bStillRunning;
}

function bool CheckAdvancing ()
{
	local int I;
	local bool bStillAdvancing;

	bStillAdvancing = False;

	for(I = 0; I < MAX_THREADS; I++)
	{
		if ( (aThreads[I] != None) && aThreads[I].bPlaying && aThreads[I].bScriptAdvancing )
		{
			bStillAdvancing = True;
		}
	}
	return bStillAdvancing;
}

function FastForward ()
{
	if ( bPlaying || bFastForwarding )
	{
		CutSceneLog("***Error. Global FastForward called! StateName" $ string(GetStateName()));
		ForceFinish();
		bPlaying = False;
		bFastForwarding = False;
	}
}

state Running
{
	event Tick (float Time)
	{
	}
  
	function FastForward ()
	{
		if ( bSkipAllowed )
		{
			CutSceneLog("Starting Fastforward");
			GotoState('FastForwarding');
		} 
		else 
		{
			CutSceneLog("Refusing Fastforward: bSkipAllowed==false");
		}
	}
  
	begin:
		bPlaying = True;
		Default.numScriptsPlaying++;
	loop:
		if ( CheckFinished() )
		{
			GotoState('Finished');
		}
		Sleep(0.5);
		goto ('Loop');
}

function DumpCurState ()
{
	local int I;

	CutSceneLog("*****************************************************************************");
	CutSceneLog("*****************************************************************************");
	CutSceneLog("*CutScript Dump:" $ FileName $ "->" $ string(self));
	CutSceneLog("*CutScene Flags:" $ " bBumpStarts:" $ string(bBumpStarts) $ " bTriggerStarts:" $ string(bTriggerStarts) $ " bLevelLoadStarts:" $ string(bLevelLoadStarts) $ " bPlayOnce:" $ string(bPlayOnce) $ " bSkipAllowed:" $ string(bSkipAllowed) $ " bDoImmediateStart:" $ string(bDoImmediateStart) $ " BumpStarts:" $ string(bBumpStarts));
	CutSceneLog("*CutScene State:" $ string(GetStateName()));
	CutSceneLog("*CutScene Status:" $ " bPlaying:" $ string(bPlaying) $ " bFastForwarding:" $ string(bFastForwarding) $ " safetyLoopCount:" $ string(safetyLoopCount) $ " nPlayedCount:" $ string(nPlayedCount));
	CutSceneLog("*****************************************************************************");

	for(I = 0; I < MAX_THREADS; I++)
	{
		if ( (aThreads[I] != None) && aThreads[I].bPlaying )
		{
			aThreads[I].DumpCurState();
		}
	}
	CutSceneLog("*****************************************************************************");
	CutSceneLog("*****************************************************************************");
}

state FastForwarding
{
	event BeginState ()
	{
		safetyLoopCount = 0;
		bFastForwarding = True;
		harry(Level.PlayerHarryActor).ClientMessage(string(self) $ " FastForwarding");
	}
	
	function StartThreadsFF ()
	{
		local int I;
	
		for(I = 0; I < MAX_THREADS; I++)
		{
			if ( (aThreads[I] != None) && aThreads[I].bPlaying )
			{
				aThreads[I].FastForward();
			}
		}
	}
	
	function FastForward ()
	{
		CutSceneLog("***Fastforward called while already fastforwarding");
	}
	
	begin:
		Sleep(0.2);
		StartThreadsFF();
	loop:
		if (  !CheckAdvancing() )
		{
			safetyLoopCount++;
		}
		if ( CheckFinished() || (safetyLoopCount > 15) )
		{
			if ( safetyLoopCount > 15 )
			{
				CutSceneLog("***CUTERROR:SKIP ERROR:" $ string(self) $ " failed to advance after " $ string(safetyLoopCount) $ " loops");
				DumpCurState();
			}
			CutSceneLog(string(self) $ " skipped");
			bFastForwarding = False;
			GotoState('Finished');
		}
		Sleep(0.1);
		goto ('Loop');
}

state Finished
{
	Begin:
		bPlaying = False;
		Default.numScriptsPlaying--;
		DeleteThreads();
		if(bPlayByCmd)
		{
			Log(Self$ " Thank you for playing my cutscene! Good bye!");
			ConsoleCommand("exit");
		}
	Loop:
		if (  !bPlayOnce )
		{
			GotoState('Idle');
		}
}

function Play ()
{
	if ( bPlaying || bDisabledByCmd )
	{
		return;
	}
	if ( bPlayOnce && (nPlayedCount > 0) )
	{
		return;
	}
	nPlayedCount++;
	CutSceneLog(" starting for the " $ string(nPlayedCount) $ " time");
	CreateThreads();
	GotoState('Running');
}

// Omega: Force play
function ForcePlayFromEditor()
{
	nPlayedCount++;
	CutSceneLog(" starting for the " $ string(nPlayedCount) $ " time");
	CreateThreads();
	GotoState('Running');
}

function bool CutCommand (string Command, optional string cue, optional bool bFastFlag)
{
	local string sActualCommand;
	local string targetName;
	local Actor TempActor;

	sActualCommand = ParseDelimitedString(Command," ",1,False);
	if ( sActualCommand ~= "Capture" )
	{
		return True;
	} 
	else
	if ( sActualCommand ~= "Release" )
	{
		return True;
	}

	return Super.CutCommand(Command,cue,bFastFlag);
}

defaultproperties
{
    bBumpStarts=True

    bPlayOnce=True

    bSkipAllowed=True

    bHidden=True

    // DrawType=2
	DrawType=DT_Mesh

    Mesh=SkeletalMesh'HProps.skCutSceneMarkerMesh'

    AmbientGlow=75

    bCollideActors=True

	// Omega: Allow Cutscript classes to be swappable for people to make their own
	CutscriptClass=Class'CutScript'

	CutscriptDiskClass=Class'CutScriptDisk'

	UncompiledFileExtension=".txt"
}
