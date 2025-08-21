//================================================================================
// CutScript.
//================================================================================

// Omega: Cleaned the fuck out of this class and made it generally easier to read
// some array operations for your notes:
/*(.Add, .AddItem, .Empty, .Contains, .Find, .InsertItem, .RemoveItem)*/
// Relies on MiscFunctions for some backend stuff

class CutScript extends Actor;

// Omega: Misc functions class to call static stuff on
var Class<MiscFunctions> MiscFunctions;

var(Script) string Script;
var int curScriptPosition;

var(Script) string CurCommand, LastTextInBrackets;

// Omega: Macro support
struct SMacro
{
	var() String 	MacroName;
	var() String 	Macro;
};

struct SScriptLayers
{
	var() String 	Script;
	var() String 	LayerName;
	var() String	Conditional;
	var() int 		curScriptPosition;
};

struct SVariable
{
	var() String VarName;
	var() String Value;
};

// Omega: Array of macros
var(Script) Array<SMacro> Macros;

// Omega: Array of scripts
var(Script) Array<SScriptLayers> ScriptLayers;

var(Script) Array<SVariable> ScriptVariables;

var array<String> aCues;			// List of cues that have already happened
var array<String> aPendingCues;		// Used to queue cues, if you catch my drift
var array<String> aErrorCues;		// Used to catch cues in the queue that can't cue

var int nPendingCues;
var int nCues;
var int lastCueNum;					// Static var

var string pendingTimerCue; 		//cue to issue on timer event. Used by WAITFOR durration.

var array<Actor> aCapturedActors;

var bool bPlaying;					// True if the cutscene is currently playing

var CutScene parentCutScene;

var Actor CutQuestionActor;

// Thread info
var int threadNum;
var string sThreadName;

var bool bFastForward;				// Cutscene skipping

var string lastCommand;				

var bool bLogCutscene;

var bool bScriptAdvancing;			// True if the script is not waiting on a cue to happen

var bool bUsingBaseCam;				// True if the script is making use of Basecam. Appears to be unused otherwise, but may be useful elsewhere

var bool bAggressivelyRecapture;	// If true, whenever a cutname is used, FindCutSubject will attempt to error correct the subject into being captured

function bool CaptureActor (string actName)
{
	//local int I;
	local Actor Act;

	foreach AllActors(Class'Actor',Act)
	{
		if ( Act.CutName ~= actName )
		{
			break;
		}
	}
	cm("Attempting to capture: " $actName$ " Class: " $Act);
	
	if ( Act == None )
	{
		CutError("Can't Capture " $ actName $ ". Actor not found.");
		return False;
	}
	
	// Omega: check if the Actor is attached to any other cutscripts
	if ( Act.CutNotifyActor != None )
	{
		// Omega: Actors that are bumplining cutnotify themselves, this hack boots them out of this state
		if ( (Act.CutNotifyActor == Act) && Act.IsInState('DoingBumpLine') )
		{
			Act.CutCue("");
			if ( Act.CutNotifyActor != None )
			{
				CutError("Bump/Capture Hack Failed. " $ actName $ ". Actor already captured by" $ string(Act.CutNotifyActor) $ ".");
				return False;
			}
		} 
		// Omega: or else we just can't capture it because they're already captured elsewhere
		else 
		{
			CutError("Can't Capture " $ actName $ ". Actor already captured by" $ string(Act.CutNotifyActor) $ ".");
			return False;
		}
	}

	// Omega: if we've reached this point, we're able to capture this actor

	Act.CutCommand("CAPTURE");
	Act.CutNotifyActor = self;
	aCapturedActors.AddItem(Act);
	if ( Act.IsA('BaseCam') )
	{
		// Omega: This allows the camera to update only after the cutscene is updated, one of the few places where TickParent2 is useful
		// See Actor.uc for other potential uses of Owner, TickParent, and TickParent2
		Act.TickParent2 = self;
	}

	// Omega: Since this is a dynamic array, we can't fail this way
	return True;
}

// Omega: Similar to capturing, but only sets up the variables necessary to redirect the actor to our script here
function bool ReCaptureActor (string actName)
{
	//local int I;
	local Actor Act;

	foreach AllActors(Class'Actor',Act)
	{
		if ( Act.CutName ~= actName )
		{
			break;
		}
	}
	
	if ( Act == None )
	{
		CutError("Can't ReCapture " $ actName $ ". Actor not found.");
		return False;
	}
	
	if ( Act.CutNotifyActor == None )
	{
		CutError("Can't ReCapture " $ actName $ ". Actor not already captured.");
		return False;
	}

	Act.CutNotifyActor = self;
	aCapturedActors.AddItem(Act);

	if ( Act.IsA('BaseCam') )
	{
		Act.TickParent2 = self;
	}

	return true;
}

// Omega: Clears the variables necessary for capture, and sends the release command
function bool ReleaseActor (string actName)
{
	local int I;

	for(I = 0; I < aCapturedActors.Length; I++)
	{
		if ( (aCapturedActors[I] != None) && (aCapturedActors[I].CutName ~= actName) )
		{
			if ( aCapturedActors[I].CutCommand("RELEASE") )
			{
				if ( aCapturedActors[I].CutNotifyActor != self )
				{
					CutError("Failed to Release " $ actName $ ". Actor Notify doesn't match!?!?!?!.");
					return False;
				}
				
				aCapturedActors[I].CutNotifyActor = None;
				aCapturedActors[I] = None;
				return True;
			} 
			else 
			{
				CutError("Failed to Release " $ actName $ ". Actor refused Release!?!?!?!.");
				return False;
			}
		}
	}

	CutError("Failed to Release " $ actName $ ". Actor not captured.");
	return False;
}

// Omega: Used internally to search for our cut subject on various commands
// You will likely see this error logged when you inevitably forget to capture an actor lmao
function Actor FindCutSubject (string subjectName)
{
	local int I;

	// Omega: Love this KW hack of not just setting the baseCam name by default... 
	// it's already gonna conflict either way, might as well have just set the cutname of baseCam by default
	if ( subjectName ~= "baseCam" )
	{
		bUsingBaseCam = True;
		return harry(Level.PlayerHarryActor).Cam;
	}

	for(I = 0; I < aCapturedActors.Length; I++)
	{
		if(aCapturedActors[I].CutName ~= subjectName)
		{
			return aCapturedActors[I];
		}
	}

	// Omega: We fell through and should check if we can try this aggressively
	if(bAggressivelyRecapture)
	{
		CutError("Aggressive recapture mode is on! Locating " $subjectName$ " and gently coercing them into our cutscene!");
		if(CaptureActor(subjectName))
		{
			for(I = 0; I < aCapturedActors.Length; I++)
			{
				if(aCapturedActors[I].CutName ~= subjectName)
				{
					return aCapturedActors[I];
				}
			}
		}
		else
		if(ReCaptureActor(subjectName))
		{
			for(I = 0; I < aCapturedActors.Length; I++)
			{
				if(aCapturedActors[I].CutName ~= subjectName)
				{
					return aCapturedActors[I];
				}
			}
		}
	}
	
	CutError("Failed to find " $ subjectName $ ". Actor not captured.");
	return None;
}

function CutLog (string Str)
{
	local string MacroLogging;

	// Omega: Support for disabled cutlogs
	if(!bLogCutscene) return;

	Level.PlayerHarryActor.ClientMessage("CutLog:" $ sThreadName @ ScriptLayers[ScriptLayers.Length - 1].LayerName $ "->" $ Str);
	HPConsole(Level.PlayerHarryActor.Player.Console).CutConsoleLog("CutLog:" $ sThreadName @ ScriptLayers[ScriptLayers.Length - 1].LayerName $ "->" $ Str);

	if (!Class'Version'.Default.bDebugEnabled)
	{
		return;
	}
	Log("CutLog:" $ MacroLogging $ sThreadName $ "->" $ Str);
}

function CutError (string Str)
{
	local string sWhoIam;

	// Omega: Support for disabled cutlogs
	if(!bLogCutscene) return;

	Level.PlayerHarryActor.ClientMessage("*********************************************************");
	Level.PlayerHarryActor.ClientMessage("**** CutError:" $ sThreadName);
	Level.PlayerHarryActor.ClientMessage("**** CutError:" $ ScriptLayers[ScriptLayers.Length - 1].LayerName);
	Level.PlayerHarryActor.ClientMessage("**** CutError:" $ Str);

	Level.PlayerHarryActor.ClientMessage("*********************************************************");
	Log("*********************************************************");
	Log("**** CutError:" $ sThreadName);
	Log("**** CutError:" $ ScriptLayers[ScriptLayers.Length - 1].LayerName);
	Log("**** CutError:" $ Str);

	Log("*********************************************************");

	HPConsole(Level.PlayerHarryActor.Player.Console).CutConsoleLog("!!!ERROR!!!:" $ sThreadName @ ScriptLayers[ScriptLayers.Length - 1].LayerName $ "->" $ Str);
}

// Omega: Functions for working with script layers
function AddScriptLayer(String Script, String LayerName, optional String Conditional)
{
	local int i;

	if(Script ~= "")
	{
		CutError("Can't add new ScriptLayer, no Script!!");
		return;
	}

	i = ScriptLayers.Add();
	ScriptLayers[i].Script = Script;
	ScriptLayers[i].LayerName = LayerName;
	// Omega: If not none, whenever we reach the end of this layer we assess the condition
	// If true, we restart
	ScriptLayers[i].Conditional = Conditional;
}

function RemoveScriptLayer()
{
	//ScriptLayers.RemoveItem(ScriptLayers[ScriptLayers.Length - 1]);
	ScriptLayers.Remove(ScriptLayers.Length - 1);
}

// Omega: Used to move our execution back to main
function ClearAdditionalScriptLayers()
{
	local int i;

	for(i = 0; i < ScriptLayers.Length - 1; i++)
	{
		RemoveScriptLayer();
	}
}

function bool SetCutVariable(string Command)
{
	local string Variable, Val;
	local int i;

	Variable = ParseDelimitedString(Command, "=", 1, False);
	Val = ParseDelimitedString(Command, "=", 2, true);

	if(Variable ~= "" || InStr(Command, "=") == -1)
	{
		CutError("Failed to set variable! Check formatting! Command: " $Command);
		return false;
	}

	for(i = 0; i < ScriptVariables.Length; i++)
	{
		if(ScriptVariables[i].VarName ~= Variable)
		{
			ScriptVariables[i].Value = Val;
			CutLog("Updated var " $Variable$ "=" $val);
			return true;
		}
	}

	i = ScriptVariables.Add();
	ScriptVariables[i].VarName = Variable;
	ScriptVariables[i].Value = Val;

	CutLog("Added new var " $Variable$ "=" $Val);
	return true;
}

function bool RemoveCutVariable(string Command)
{
	local int i;
	for(i = 0; i < ScriptVariables.Length; i++)
	{
		if(ScriptVariables[i].VarName ~= Command)
		{
			ScriptVariables.Remove(i);
			CutLog("Removed variable " $Command);
			return true;
		}
	}

	// Omega: If we don't have one, don't error
	CutLog("No var for " $Command);
	return true;
}

function String GetMacro(String MacroName)
{
	local int i;

	for(i = 0; i < Macros.Length; i++)
	{
		if(MacroName ~= Macros[i].MacroName)
		{
			return Macros[i].Macro;
		}
	}

	return "";
}

// Omega: Some string filtering to get the next line
function bool GetNextLine (out string Line)
{
	local int eolIndex;
	local int OldEOL;
	local string TempStr;

	// Omega: Check execution of current script, drop down a layer if need be
	if ( ScriptLayers[ScriptLayers.Length - 1].curScriptPosition >= Len(ScriptLayers[ScriptLayers.Length - 1].Script) )
	{
		if(ScriptLayers.Length > 1)
		{
			if(ScriptLayers[ScriptLayers.Length - 1].Conditional != "")
			{
				// Omega: While loop support
				if(!EvaluateQuestionString(ScriptLayers[ScriptLayers.Length - 1].Conditional))
				{
					RemoveScriptLayer();
					return GetNextLine(Line);
				}
				else
				{
					ScriptLayers[ScriptLayers.Length - 1].curScriptPosition = 0;
					return GetNextLine(Line);
				}
			}
			else
			{
				RemoveScriptLayer();
				return GetNextLine(Line);
			}
		}
		return False;
	}
	
	// Metallicafan212:	Fix this shit!!!! They test for \r instead of \n!!!!
	//					Guys, imagine actually making your code portable!
	TempStr = Mid(ScriptLayers[ScriptLayers.Length - 1].Script, ScriptLayers[ScriptLayers.Length - 1].curScriptPosition);
	//eolIndex = InStr(TempStr,Chr(13));
	eolIndex = InStr(TempStr, Chr(10));

	if ( eolIndex < 0 )
	{
		eolIndex = Len(TempStr) + 1;
	}
	
	ScriptLayers[ScriptLayers.Length - 1].curScriptPosition += eolIndex + 1;//eolIndex + 2;
	
	// Metallicafan212:	Test for \r now
	OldEOL 		= eolIndex;
	eolIndex 	= InStr(TempStr, Chr(13));
	
	if(eolIndex < 0)
	{
		// Metallicafan212:	Restore, there's no \r
		eolIndex = OldEOL;
	}
	
	Line = Left(TempStr,eolIndex);
	
	return True;
}

// Omega: Looks for the next cut command using filtering
function bool GetNextCommand (out string Command, optional bool bUseVars)
{
	local string Line;

	if (!GetNextLine(Line) )
	{
		return false;
	}

	Command = FilterCommand(Line, bUseVars);

	CurCommand = Command;
	return True;
}

function String FilterCommand(string Command, bool bUseVars)
{
	local int commentIndex;
	local int OtherCommentIndex;

	// Omega: Two commenting formats supported here, woo!
	commentIndex = InStr(Command,";");
	OtherCommentIndex = InStr(Command,"/");

	if ( OtherCommentIndex > -1 )
	{
		if ( (commentIndex < 0) || (OtherCommentIndex < commentIndex) )
		{
			commentIndex = OtherCommentIndex;
		}
	}

	if ( commentIndex > -1 )
	{
		Command = Left(Command,commentIndex);
	}
	/*else 
	{
		Command = Line;
	}*/

	// Omega: Get rid of tabs and any double spaces
	ReplaceText(Command, "	", "");
	Command = MiscFunctions.Static.StripMultiSpaces(Command);

	if(bUseVars)
	{
		Command = PlaceVars(Command);
	}

	return Command;
}

// Omega: Insert our variables
function string PlaceVars(string Command)
{
	local int i;
	local string OldCommand;

	OldCommand = Command;

	for(i = 0; i < ScriptVariables.Length; i++)
	{
		// Omega: Changed from square brackets so we can keep the uncompiled cutscene idea compatible
		ReplaceText(Command, "@" $ScriptVariables[i].VarName, ScriptVariables[i].Value);
	}

	CutLog("Replaced Command " $OldCommand$ " With " $Command);
	return Command;
}

// Omega: Forward def so we can do swappable Cutscript classes more easily
function load (string threadName, string FileName);

// Omega: Cues a CutCue, adding it to the array of Cue'd Cues.
// This allows these to happen latently, but introduces the downside of being unable to reuse names of cues
// Ensure that you pick unique names for specified cues
function CutCue (string cue)
{
	local int I;

	if ( cue == "" )
	{
		CutError("Error blank cue");
	}

	aCues[aCues.Length]=cue;
	nCues++;

	if ( nPendingCues > 0 )
	{
		for(I = 0; I < nPendingCues; I++)
		{
			if(aPendingCues[I] ~= cue)
			{
				if ( nPendingCues - 1 == I )
				{
					aPendingCues[I] = "";
					nPendingCues--;
				}
				else
				{
					aPendingCues[I] = aPendingCues[nPendingCues - 1];
					nPendingCues--;
				}
			}
		}
	}
}

// Omega: Iterate and remove a list of cues
function RemoveCues(string cues)
{
	local int i;
	local string curCue, log, failed;

	do
	{
		curCue = ParseDelimitedString(cues," ",++i,False);

		// Omega: Make sure that's gone
		aErrorCues.RemoveItem(curCue);
		if(aCues.RemoveItem(curCue))
		{
			log = log$ " " $curCue;
		}
		else
		{
			failed = failed$ " " $curCue;
		}
	}
	until(curCue == "");

	if(log != "")
	{
		CutLog("Successfully removed cues:" $log$ " failed: " $failed);
	}
	else
	{
		CutError("Unsuccessful in removing cues: " $failed);
	}
}

function RemovePendingCues(string cues)
{
	local int i;
	local string curCue, log, failed;

	do
	{
		curCue = ParseDelimitedString(cues," ",++i,False);
		if(aPendingCues.RemoveItem(curCue))
		{
			log = log$ " " $curCue;
			nPendingCues--;
		}
		else
		{
			failed = failed$ " " $curCue;
		}
	}
	until(curCue == "");

	if(log != "")
	{
		CutLog("Successfully removed pending cues:" $log$ " failed: " $failed);
	}
	else
	{
		CutError("Unsuccessful in removing pending cues: " $failed);
	}
}

// Omega: Queues a cue. See above on limitations of the system
function AddPendingCue (string cue)
{
	local int I;

	if ( cue == "" )
	{
		CutError("Error blank Pending cue");
	}

	// Omega: If it exists in the error cue, do not
	for(I = 0; I < aErrorCues.Length; I++)
	{
		if(aErrorCues[I] ~= cue)
		{
			CutError("Pending cue added for error'd cue: " $cue$ ". Skipping!");
			return;
		}
	}

	// Omega: Tell the user that this cue has already been recieved, since there's probably a mistake in the cutscene scripting in this case
	for(I = 0; I < nCues; I++)
	{
		if(aCues[I] ~= cue)
		{
			// Omega: Seems there's kind of false positives that this handles, so I'm cutting this CutError message to cut down on spam
			//CutError("Error: Cue: " $cue$ " already recieved! Use a different cue!!!!");
			return;
		}
	}

	aPendingCues[nPendingCues] = cue;
	nPendingCues++;
}

// Omega: Generates a new cue name for any unnamed cues, allowing the user to not worry about it.
// Previously, the fact that every command required a cue meant that there was a pretty low limit on how long cutscenes could be.
// For example, the proto had a limit of 150, while the Basilisk cutscene that was finished after that time in development necessitated it
// to be expanded to 210 (and only a handful more commands will cause the script to throw errors). Dynamic arrays solve this issue and 
// typically will actually reduce the resources needed for smaller scenes, though this is only a really slight memory footprint.
function string GenerateUniqueCue ()
{
	// Omega: The clever thing about this is the fact that it will generate a persistent unique cue ID, eliminating overlap between cutscripts
	// This *might* pass over to other levels during the play session, but I haven't checked. Regardless, it only matters on a per-map basis
	Default.lastCueNum++;
	return "_" $ Default.lastCueNum $ "UniqueCue";
}

// Omega: The powerhouse of the class here, and how the scripting works
// Largely, just a block of checks to see what the commands are, and what to pass down to the commanded actors
function bool ParseCommand (string Command)
{
	local string subjectPart;
	local string actionPart;
	local string untilCue;
	local string TempCommand;
	local Actor subjectActor;
	local BossEncounterTrigger aTrigger;
	local int Index;
	//local int eow;
	local int I;
	local float timerDuration;
	local string questionString;
	local TimedCue tcue;
	//local name N;
	// Omega: Used for the Goto command's clear cues parameter
	local bool bClearCues;
	// DivingDeep39: Used for Comment's and ObjectiveId's section and localization
	local string m212, idCom, tempSec, tempInt, secCom, intCom;

	subjectPart = ParseDelimitedString(Command," ",1,False);
	if ( Len(subjectPart) == 0 )
	{
		return True;
	}

	// Omega: New cutquestion system
	/*
		ex:
		if(EnoughBeans)
		{
			Harry say SomeLine
		}

		Would ask the cut question "EnoughBeans" which is a test question in Harry that always returns true,
		then all script is executed within the brackets
		if the condition was false, the brackets get skipped

		ex:
		if(!(&(enoughbeans, gstate180)))
		{
			Harry say SomeLine
		}
		else if(enoughbeans)
		{
			Harry say AnotherLine
		}
		else
		{
			Harry say ACoolerLine
		}

		Would be if it's not enoughbeans and gstate180, then because it's enoughbeans, harry says "anotherline"

		There's also support for while loops, which recheck their conditional at the end of the script layer running
		They technically support chaining into if/else but you probably shouldn't

														   parens	and   or  not  seperator
		An expression is one of the following characters: "(", ")", "&", "|", "!", ","
	*/
	if(ParseNewQuestion(Command))
	{
		return true;
	}

	// Omega: Old conditional version. Not super great, and the stock scripts show the limits pretty well
	// Check the start of any spell lesson to see how those cutscenes work
	// tl;dr the only way to branching is with seperate scripts listening for cues
	if ( subjectPart ~= "IF" )
	{
		questionString = ParseDelimitedString(Command," ",2,False);
		if (	!CutQuestionActor.CutQuestion(questionString) )
		{
			if ( CutQuestionActor.CutErrorString != "" )
			{
				CutError(CutQuestionActor.CutErrorString);
			}
			return True;
		} 
		else 
		{
			Command = Mid(Command,InStr(Command,questionString) + Len(questionString) + 1);
			subjectPart = ParseDelimitedString(Command," ",1,False);
		}
	}

	if ( subjectPart ~= "IFNOT" )
	{
		questionString = ParseDelimitedString(Command," ",2,False);
		if ( CutQuestionActor.CutQuestion(questionString) )
		{
			if ( CutQuestionActor.CutErrorString != "" )
			{
				CutError(CutQuestionActor.CutErrorString);
			}
			return True;
		} 
		else 
		{
			Command = Mid(Command,InStr(Command,questionString) + Len(questionString) + 1);
			subjectPart = ParseDelimitedString(Command," ",1,False);
		}
	}

	switch (subjectPart)
	{
		// Ex: ToggleLogging
		// Toggles the logging variable, default true
		case "TOGGLELOGGING":
			CutLog("Issuing: Toggle logging: " $!bLogCutscene);
			bLogCutscene = !bLogCutscene;
			return True;
		// EX: Cue MyCue
		// Sends the cue, allowing any WaitFor commands to listen for it and resume script execution
		case "CUE":
			CutLog("Issuing: CUE: " $ ParseDelimitedString(Command," ",2,False));
			parentCutScene.CutCue(ParseDelimitedString(Command," ",2,False));
			return True;
			break;

		// Omega: Cue management functions
		// remove specific cues
		case "REMOVECUE":
			CutLog("Issuing: REMOVECUE: " $ ParseDelimitedString(Command," ",2,True));
			RemoveCues(ParseDelimitedString(Command," ",2,True));
			return True;
			break;
		// Clear all previously done cues
		case "CLEARCUES":
			CutLog("Issuing: CLEARCUES");
			aCues.Empty();
			aErrorCues.Empty();
			return True;
			break;

		// remove pending cues
		case "REMOVEPENDINGCUE":
			CutLog("Issuing: REMOVEPENDINGCUE: " $ ParseDelimitedString(Command," ",2,True));
			RemovePendingCues(ParseDelimitedString(Command," ",2,True));
			return True;
			break;

		// clear all pending cues and reset the pending cue count
		case "CLEARPENDINGCUES":
			CutLog("Issuing: CLEARPENDINGCUES");
			aPendingCues.Empty();
			nPendingCues = 0;
			return True;
			break;

		// EX: Waitfor MyCue
		// Pauses script execution until the cue is given
		case "WAITFOR":
			CutLog("Issuing: WAITFOR:" $ ParseDelimitedString(Command," ",2,False));
			AddPendingCue(ParseDelimitedString(Command," ",2,False));
			return True;
			break;
		
		// EX: Sleep 5
		// Pauses script execution for 5 seconds
		case "SLEEP":
			if ( bFastForward )
			{
				return True;
			}
			CutLog("Issuing: SLEEP:" $ ParseDelimitedString(Command," ",2,False));
			pendingTimerCue = GenerateUniqueCue();
			timerDuration = float(ParseDelimitedString(Command," ",2,False));
			
			// Omega: This restriction seems a bit arbitrary, only being able to do the lower limit of 100 seconds of sleep
			// This may be useful for non-cinematic cutscene usage, so I've elected to not limit it. Be smart, users!
			//if ( (timerDuration > 0) && (timerDuration < 100) )
			if(timerDuration > 0)
			{
				tcue = Spawn(Class'TimedCue');
				tcue.CutNotifyActor = self;
				tcue.SetupTimer(timerDuration,pendingTimerCue);
				AddPendingCue(pendingTimerCue);
			} 
			else 
			{
				CutError("Invalid SLEEP duration:" $ string(timerDuration));
			}
		
			return True;
			break;
		
		// EX: randsleep 2 5
		// Sleeps a random duration between 2 and 5, min must go before max
		case "RANDSLEEP":
			if ( bFastForward )
			{
				return True;
			}
			// Omega: Seems to account for this case anyway, so uh whatever
			/*if(float(ParseDelimitedString(Command," ",3,False)) < float(ParseDelimitedString(Command," ",2,False)))
			{
				CutError("Invalid use of RANDSLEEP, Max is less than Min: " $ParseDelimitedString(Command," ",2,False)$ " - " $float(ParseDelimitedString(Command," ",3,False)));
				return False;
			}*/

			timerDuration = RandRange(float(ParseDelimitedString(Command," ",2,False)), float(ParseDelimitedString(Command," ",3,False)));
			CutLog("Issuing: RANDSLEEP: " $ParseDelimitedString(Command," ",2,False)$ " - " $float(ParseDelimitedString(Command," ",3,False))$ ". Chose: " $timerDuration);
			pendingTimerCue = GenerateUniqueCue();
			
			if(timerDuration > 0)
			{
				tcue = Spawn(Class'TimedCue');
				tcue.CutNotifyActor = self;
				tcue.SetupTimer(timerDuration,pendingTimerCue);
				AddPendingCue(pendingTimerCue);
			} 
			else 
			{
				CutError("Invalid RANDSLEEP duration:" $ string(timerDuration));
			}
		
			return True;
			break;
		
		// EX: Capture BaseCam
		// Captures an actor and subscribes them to this script's commands
		case "CAPTURE":
			CutLog("Issuing: CAPTURE " $ ParseDelimitedString(Command," ",2,False));
			CaptureActor(ParseDelimitedString(Command," ",2,False));
			return True;
			break;
		
		// EX: ReCapture BaseCam
		// ReCaptures an actor and subscribes them to this script's commands. Used if already captured elsewhere, and passing the actor off to another script
		case "RECAPTURE":
			CutLog("Issuing: RECAPTURE " $ ParseDelimitedString(Command," ",2,False));
			ReCaptureActor(ParseDelimitedString(Command," ",2,False));
			return True;
			break;
		
		// EX: Release BaseCam
		// Returns the actor to its normal state
		case "RELEASE":
			CutLog("Issuing: RELEASE " $ ParseDelimitedString(Command," ",2,False));
			ReleaseActor(ParseDelimitedString(Command," ",2,False));
			return True;
			break;

		// Omega: Use on its own to enable an extremely aggressive capturing mode
		// If a command fails to run on an actor, it will capture them. It will do so violently, with a bat.
		// Ex: AggressiveCaptures True
		// turns it on
		// AggressiveCaptures False
		// turns it off
		case "AGGRESSIVECAPTURES":
			actionPart = ParseDelimitedString(Command," ",2,False);
			//ParseBool(actionPart, bAggressivelyRecapture);
			// Omega: The macro is causing a compile error for some reason... oh well!
			bAggressivelyRecapture = Bool(actionPart);
			CutLog("Issuing: AGGRESSIVECAPTURES for the running script! Aggresive capture mode: " $bAggressivelyRecapture);
			return True;
			break;

		// Omega: Set our cut question actor for new cut questions
		// Ex: SetCutQuestionActor MyActor
		case "SETCUTQUESTIONACTOR":
			actionPart = ParseDelimitedString(Command," ",2,False);

			if(actionPart ~= "")
			{
				CutError("No CutQuestionActor given!");
				return false;
			}

			CutLog("Issuing: SETCUTQUESTIONACTOR for the running script! New Actor: " $actionPart);

			foreach AllActors(Class'Actor',CutQuestionActor)
			{
				if ( CutQuestionActor.CutName ~= actionPart )
				{
					break;
				}
			}

			if(CutQuestionActor == None)
			{
				CutQuestionActor = Level.PlayerHarryActor;
				CutError("Cannot find CutQuestionActor: " $actionPart);
				return False;
			}

			return True;
			break;

		// EX: Trigger MyTag
		// Sends a trigger similarly to a level's trigger
		case "TRIGGER":
			CutLog("Issuing: TRIGGER " $ ParseDelimitedString(Command," ",2,False));
			TriggerEvent(name(ParseDelimitedString(Command," ",2,False)),self,harry(Level.PlayerHarryActor));
			return True;
			break;
		// EX: Camerashake time=2.0
		// Shakes the camera for 2.0 seconds
		case "CAMERASHAKE":
			CutLog("Issuing: CameraShake " $ ParseDelimitedString(Command," ",2,False));
			CutCommand_CameraShake(ParseDelimitedString(Command," ",2,False));
			return True;
			break;
		
		case "DISABLEPLAYERINPUT":
			CutLog("Issuing: DisablePlayerInput");
			harry(Level.PlayerHarryActor).DisablePlayerInput();
			return True;
			break;
		
		case "ENABLEPLAYERINPUT":
			CutLog("Issuing: EnablePlayerInput");
			harry(Level.PlayerHarryActor).EnablePlayerInput();
			return True;
			break;
		
		case "MESSAGE":
			CutLog(ParseDelimitedString(Command," ",2,True));
			return True;
			break;
		
		case "COMMENT":
			// DivingDeep: Added custom localization support to Comment CutCommand
			// EX: Comment idCom Section=secCom Localize=intCom (Section and Localize are optional)
			//questionString = Localize("all",ParseDelimitedString(Command," ",2,True),"HPMenu");
			idCom = ParseDelimitedString(Command," ",2,False);
			
			I = 3;
		
			m212 = ParseDelimitedString( command, " ", I, false );
			
			while ( m212 != "" )
			{
				if(Left(m212, 8) ~= "Section=")
				{
					// DivingDeep39: Parse Section's temporary var
					tempSec = (ParseDelimitedString(m212, "=", 2, false));
				}
				
				if(Left(m212, 9) ~= "Localize=")
				{
					// DivingDeep39: Parse Localize's temporary var
					tempInt = (ParseDelimitedString(m212, "=", 2, false));
				}

				I++;
				m212 = ParseDelimitedString( command, " ", I, false );
			}
			
			if ( tempSec == "" )
			{
				// DivingDeep39: If Section is missing or empty, use "All" as default
				secCom = "All";
			}
			else
			{
				secCom = tempSec;
				Log("Comment: Setting Section to: " $ secCom );
			}
			
			if ( tempInt == "" )
			{
				// DivingDeep39: If Localize is missing or empty, use "HPMenu" as default
				intCom = "HPMenu";
			}
			else
			{
				intCom = tempInt;
				Log("Comment: Setting Localization File to: " $ intCom );				
			}
			
			questionString = Localize(secCom,idCom,intCom);
			
			HPHud(harry(Level.PlayerHarryActor).myHUD).managerCutScene.SetCutCommentText(questionString);
			return True;
			break;
		
		case "SLOMO":
			harry(Level.PlayerHarryActor).SloMo(float(ParseDelimitedString(Command," ",2,True)));
			CutLog("Issuing: SloMo " $ string(float(ParseDelimitedString(Command," ",2,True))));
			return True;
			break;
		
		case "SAVEGAME":
			harry(Level.PlayerHarryActor).SaveGame();
			CutLog("Issuing: SaveGame ");
			return True;

		// Omega: Loadsave command, to make loading the game more convenient
		case "LOADSAVE":
			CutLog("Issuing: Loadsave ");
			harry(Level.PlayerHarryActor).ConsoleCommand("Loadgame 0");
			return True;

		// Omega: Numbered save and load commands as well
		// EX: Savenum 5
		// EX: Loadnum 5
		// Saves and loads from save slot 5
		case "SAVENUM":
			harry(Level.PlayerHarryActor).ConsoleCommand("Savegame " $int(ParseDelimitedString(Command," ",2,True)));
			CutLog("Issuing: SaveNum" $int(ParseDelimitedString(Command," ",2,True)));
			return True;
			break;

		case "LOADNUM":
			harry(Level.PlayerHarryActor).ConsoleCommand("Loadgame " $int(ParseDelimitedString(Command," ",2,True)));
			CutLog("Issuing: LoadNum" $int(ParseDelimitedString(Command," ",2,True)));
			return True;
			break;
		
		case "FORCEFINISH":
			parentCutScene.ForceFinish();
			CutLog("Issuing: FORCEFINISH");
			return True;
		
		// EX: ChangeGameState 180
		// Sets the gamestate to 180
		case "CHANGEGAMESTATE":
			CutLog("Issuing: SetGameState " $ ParseDelimitedString(Command," ",2,True));
			if (	!harry(Level.PlayerHarryActor).SetGameState(ParseDelimitedString(Command," ",2,True)) )
			{
				CutError("!E!R!R!O!R! GameState " $ ParseDelimitedString(Command," ",2,True) $ " is not a valid GameState in the *GameStateMasterList*!!!");
			}
			return True;

		// Omega: Console command for those that might need it
		// EX: ConsoleCommand Set Harry Fatness 255
		// Chungus
		case "CONSOLECOMMAND":
			harry(Level.PlayerHarryActor).ConsoleCommand((ParseDelimitedString(Command," ",2,True)));
			CutLog("Issuing: CONSOLECOMMAND: " $(ParseDelimitedString(Command," ",2,True)));
			return True;
		
		// EX: Goto Test
		// Goes to the label called "Test:"

		/*Capture Harry
		Capture Basecam

		Goto Test >>

		Harry M212Say Package=AllDialog Localize=HPDialog PC_Ara_Adv9aForest_10

	>>	Test:
		Release Harry
		Release Basecam */

		// Goto Test ClearCues will clear the script's previous cues, useful when going backwards into the script to do loops

		// This can skip over sections of script, especially powerful if used with If and IfNot statements
		// Omega: Currently going to scope this to just the main script
		case "GOTO":
			ClearAdditionalScriptLayers();
			// Metallicafan212:	Find the label to go to!
			Index = ScriptLayers[0].CurScriptPosition;
			// Omega: Appended a colon
			ActionPart = ParseDelimitedString(Command," ",2,False)$ ":";
			//CutLog("Goto ActionPart: " $ActionPart);

			if(ParseDelimitedString(Command, " ", 3, True) ~= "CLEARCUES")
			{
				bClearCues = True;
			}
			
			// Omega: we should start from the top of the script so we can do backwards gotos, allowing looping scripts
			ScriptLayers[0].CurScriptPosition = 0;

			while(GetNextCommand(TempCommand, true))
			{
				subjectPart = ParseDelimitedString(TempCommand," ",1,False);
				
				if(CharAt(SubjectPart, Len(SubjectPart) - 1) == ":" && subjectPart ~= ActionPart)
				{
					if(bClearCues)
					{
						CutLog("GOTO: Clearing cues!");
						aCues.Empty();
						aErrorCues.Empty();
					}
					// We shouldn't have to clear the pending cues
					//aPendingCues.Empty();

					// Metallicafan212:	Sucessfully found that label, skip to the next line
					CutLog("GOTO: Found label: " $subjectPart);
					return true;
				}
			}
			
			// Metallicafan212:	Failed to find the label! Go back
			ScriptLayers[0].CurScriptPosition = Index;
			
			CutError("Failed to Parse Command:" $ Command $ ". Can't find label");
			
			return false;

		// Omega: Set a Macro. Starts the macro recording and ends with "ENDMACRO"
		/* EX: SetMacro MyMacro
		   Trigger SomethingCool
		   Sleep .5
		   Harry say SomethingCool
		   EndMacro
		*/
		case "SETMACRO":
			ActionPart = ParseDelimitedString(Command," ",2,False);

			// Omega: Replace old macro. Too lazy to code that better for now lol
			for(i = 0; i < Macros.Length; i++)
			{
				if(Macros[i].MacroName ~= ActionPart)
				{
					CutLog("Already defined macro: " $actionPart$ " updating script");
					Macros.Remove(i);
					break;
				}
			}

			Macros.Add();

			Macros[Macros.Length - 1].MacroName = ActionPart;
			
			// Omega: Loop through the macro definition and find an ending
			while(GetNextCommand(TempCommand, true))
			{
				if(TempCommand ~= "ENDMACRO")
				{
					return true;
				}

				Macros[Macros.Length - 1].Macro $= TempCommand $ Chr(10);
			}

			CutError("Exhausted all of script before reaching an EndMacro command. MAKE SURE YOU FINISHED YOUR MACRO!");

			return false;

		// Omega: Play back a macro
		// EX: PlayMacro MyMacro
		case "PLAYMACRO":
			ActionPart = ParseDelimitedString(Command," ",2,False);
			for(i = 0; i < ScriptLayers.Length; i++)
			{
				if(ActionPart ~= ScriptLayers[i].LayerName)
				{
					CutError("Recursion is a really fuckign bad idea bro. Macro: " $actionPart$ " ScriptLayer: " $ScriptLayers[i].LayerName);
					return false;
				}
			}

			AddScriptLayer(GetMacro(ActionPart), ActionPart);
			return true;

		// Omega: Set variable to value
		case "SetVariable":
			ActionPart = ParseDelimitedString(Command," ",2,true);
			return SetCutVariable(ActionPart);

		case "RemoveVariable":
			ActionPart = ParseDelimitedString(Command," ",2,false);
			return RemoveCutVariable(ActionPart);
		
		default:
			// Metallicafan212:	See if it's just a label
			if(CharAt(SubjectPart, Len(SubjectPart) - 1) == ":")
			{
				// Metallicafan212:	It's a label
				return true;
			}

			if(subjectPart ~= "{" || subjectPart ~= "}")
			{
				return true;
			}
			break;
	}
	// DivingDeep39: Added custom localization support to Objectives
	// EX: SetObjectiveId SomeLine Section=sectId Localize=intFile (Section and Localize are optional)
	// Will set the pause menu's objective text to some line inside of any specified section and subtitle file
	if ( subjectPart ~= "SetObjectiveId" )
	{
		harry(Level.PlayerHarryActor).SetObjectiveTextId(ParseDelimitedString(Command," ",2,False));
		
		I = 3;
		
		m212 = ParseDelimitedString( command, " ", I, false );
		
		while ( m212 != "" )
        {
            if(Left(m212, 8) ~= "Section=")
            {
                // DivingDeep39: Parse Section's temporary var
				tempSec = (ParseDelimitedString(m212, "=", 2, false));
            }
            
            if(Left(m212, 9) ~= "Localize=")
            {
                // DivingDeep39: Parse Localize's temporary var
				tempInt = (ParseDelimitedString(m212, "=", 2, false));
            }

            I++;
            m212 = ParseDelimitedString( command, " ", I, false );
        }
		
		if ( tempSec == "" )
		{
			// DivingDeep39: If Section is missing or empty, use "All" as default
			harry(Level.PlayerHarryActor).strObjectiveSection = "All";
		}
		else
		{
			harry(Level.PlayerHarryActor).strObjectiveSection = tempSec;
			Log("SetObjectiveId: Setting Section to: " $ harry(Level.PlayerHarryActor).strObjectiveSection );
		}
		
		if ( tempInt == "" )
		{
			// DivingDeep39: If Localize is missing or empty, use "HPDialog" as default
			harry(Level.PlayerHarryActor).strObjectiveIntFile = "HPDialog";	
		}
		else
		{
			harry(Level.PlayerHarryActor).strObjectiveIntFile = tempInt;
			Log("SetObjectiveId: Setting Localization File to: " $ harry(Level.PlayerHarryActor).strObjectiveIntFile );
		}
		
		return True;
	}

	//====================================Generic CutSubject Commanding========================================
	subjectActor = FindCutSubject(subjectPart);
	
	if ( subjectActor == None )
	{
		untilCue = GetCue(Command);
		CutError("Failed to Parse Command:" $ Command $ ". Can't find subject. Saving cue to handle later " $untilCue$ ". Cutscene will not play back correctly!!!");
		
		aErrorCues.AddItem(untilCue);
		return False;
	}
	
	actionPart = ParseDelimitedString(Command," ",2,True);
	Index = InStr(actionPart,"*");
	
	if ( Index < 0 )
	{
		untilCue = GenerateUniqueCue();
		AddPendingCue(untilCue);
	} 
	else 
	{
		untilCue = ParseDelimitedString(Mid(actionPart,Index + 1)," ",1,False);
		if ( Len(untilCue) == 0 )
		{
			untilCue = GenerateUniqueCue();
		}
		actionPart = Left(actionPart,Index);
	}
	
	while ( (Asc(Right(actionPart,1)) == 32) || (Asc(Right(actionPart,1)) == 9) )
	{
		actionPart = Left(actionPart,Len(actionPart) - 1);
	}
	
	while ( (Asc(Right(untilCue,1)) == 32) || (Asc(Right(untilCue,1)) == 9) )
	{
		untilCue = Left(untilCue,Len(untilCue) - 1);
	}

	// Omega: In many cases, this is an intentional action even in official KW scripts. There's often times moves that take place during lines, for example.
	// Because of this, this is being reduced to a log about actions happening asynchronously, just in case this isn't intentional
	if ( (subjectActor.sCutNotifyCue != "") &&	!subjectActor.IsA('BaseCam') )
	{
		//CutError("Trying to issue command to:" $ string(subjectActor) $ " when previous CutCommand hasnt finished yet!!!!! PreviousCue:" $ subjectActor.sCutNotifyCue);
		CutLog(subjectActor.CutName$ " Doing asynchronous CutCommand. Previous Cue: " $subjectActor.sCutNotifyCue$ " Current cue: " $untilCue);
	}

	// Omega: Try and pass them onto a new cutscene if on nothing. Basecam needs to not be touched since it's able to be addressed outside of capture
	if( subjectActor.CutNotifyActor == None && bAggressivelyRecapture && !subjectActor.IsA('BaseCam'))
	{
		CaptureActor(subjectActor.CutName);
		ReCaptureActor(subjectActor.CutName);
	}
	
	if ( subjectActor.CutNotifyActor != self )
	{
		CutError("Trying to issue command to:" $ string(subjectActor) $ " when actor is captured by:" $ string(subjectActor.CutNotifyActor));
		// Omega: if we're not captured, special cues can fail
		aErrorCues.AddItem(untilCue);
	}

	// Omega: and now finally, issuing the command to the subject
	// If the if statement fails, it is because the command throws an error
	CutLog("Issuing to " $ subjectActor.CutName $ ":" $ actionPart $ " Cue:" $ untilCue);
	if (!subjectActor.CutCommand(actionPart,untilCue,bFastForward))
	{
		CutError("Command Error:" $ subjectActor.CutErrorString $ " From:" $ string(subjectActor));
		subjectActor.CutErrorString = "";
		aErrorCues.AddItem(untilCue);
	}
}

// Omega: Parsing for new question format
function bool ParseNewQuestion(string Command)
{
	local string subjectPart, actionPart, boolExpression;
	local int Start, End;
	local bool bResult;

	if(IsStringParam("IF(", Command) || IsStringParam("WHILE(", Command))
	{
		boolExpression = MiscFunctions.Static.GetStringBetweenStrings(Command, "(", ")", Start, End, true);
		//Cutlog("Evaluating CutQuestion expression: " $Command);
		//CutLog("Evaluate expression: (" $boolExpression$")");
		
		bResult = EvaluateQuestionString(boolExpression);
		CutLog("Expression evaluation: " $ Command $ " -> " $ bResult);

		if(IsStringParam("IF(", Command))
		{
			HandleIfStatement(bResult);
		}
		else
		if(IsStringParam("WHILE(", Command))
		{
			HandleWhileStatement(BoolExpression, bResult);
		}
		return true;
	}
	else
	if(IsStringParam("ELSE", Command))
	{
		Return true;
	}

	return false;
}

// Omega: Evaluating our question string
function bool EvaluateQuestionString(String Command)
{
	local string Temp, TempOld, Parse, Evaluate;
	local Array<String> Ops, Eval;
	local int i;

	Temp = Command;

	// Omega: Remove da opps so we have a list of things to evaluate
	for(i = 0; i < MiscFunctions.Default.BoolOperators.Length; i++)
	{
		ReplaceText(Temp, MiscFunctions.Default.BoolOperators[i], " ");
	}
	
	Temp = MiscFunctions.Static.StripSpaces(Temp);

	// Omega: Replace double spaces and shit:
	Temp = MiscFunctions.Static.StripMultiSpaces(Temp);

	//CutLog("EvaluateQuestionString Filtering: " $Temp);

	// Omega: Now create a list of
	i = 1;
	While(True)
	{
		Parse = ParseDelimitedString(Temp, " ", i, false);

		if(Parse ~= "") 
		{
			break;
		}

		if(!Eval.Contains(Parse))
		{
			Eval.AddItem(Parse);
		}

		i++;
	}

	Evaluate = Command;

	for(i = 0; i < Eval.Length; i++)
	{
		ReplaceText(Evaluate, Eval[i], AskQuestion(Eval[i]) ? "t" : "f");
	}

	CutLog("Evaluating boolean string: " $Evaluate);

	return MiscFunctions.Static.ParseBoolExpression(Evaluate);
}

function bool AskQuestion(string Command)
{
	local string Subject;
	local Actor SubjectActor;

	//Command = MiscFunctions.Static.StripSpaces(Command);

	if(Command ~= "True")
	{
		return true;
	}

	if(Command ~= "False")
	{
		return false;
	}

	if(InStr(Command, ".") != -1)
	{
		Subject = ParseDelimitedString(Command, ".", 1, False);
		SubjectActor = FindCutSubject(Subject);
	}

	if(SubjectActor != None)
	{
		CutLog("Issuing cut question to " $SubjectActor$ " -> " $ParseDelimitedString(Command, ".", 2, True));
		return SubjectActor.CutQuestion(ParseDelimitedString(Command, ".", 2, True));
	}

	return CutQuestionActor.CutQuestion(Command);
}

function bool IsStringParam(string Param, string In)
{
	return MiscFunctions.Static.IsStringParam(Param, In);
}

function ReplaceText(out string Text, string Replace, string With)
{
	MiscFunctions.Static.ReplaceText(Text, Replace, With);
}

// Omega: Handle our conditonal logic branches
function bool HandleIfStatement(bool bResult)
{
	local int Start, End, OldScriptPos;
	local byte bHasElse, bHasIf;
	local string OutText, NewIf;

	if(bResult)
	{
		OutText = GetTextInBrackets(Start, End, OldScriptPos, bHasElse, bHasIf);

		// Omega: Move past else
		if(bool(bHasElse))
		{
			bHasElse = 0;
			bHasIf = 0;
			GetTextInBrackets(Start, End, OldScriptPos, bHasElse, bHasIf);

			// Omega: Let's try recursively moving through this??
			while(bool(bHasElse) || bool(bHasIf))
			{
				bHasElse = 0;
				bHasIf = 0;
				GetTextInBrackets(Start, End, OldScriptPos, bHasElse, bHasIf);
			}
		}

		AddScriptLayer(OutText, ScriptLayers[ScriptLayers.Length - 1].LayerName$ "_IFCONDITIONAL_" $ScriptLayers[ScriptLayers.Length - 1].curScriptPosition);
	}
	else // Move directly to else/nothing
	{
		OutText = GetTextInBrackets(Start, End, OldScriptPos, bHasElse, bHasIf);
		if(bool(bHasIf))
		{
			NewIf = Mid(CurCommand, InStr(Caps(CurCommand), "IF("));
			CutLog("New If from Else -> " $NewIf);
			return ParseNewQuestion(PlaceVars(NewIf));
		}
	}

	return true;
}

function bool HandleWhileStatement(string Conditional, bool bResult)
{
	local int Start, End, OldScriptPos;
	local byte bHasElse, bHasIf;
	local string OutText, NewIf;

	if(bResult)
	{
		OutText = GetTextInBrackets(Start, End, OldScriptPos, bHasElse);

		// Omega: Move past else
		if(bool(bHasElse))
		{
			bHasElse = 0;
			bHasIf = 0;
			GetTextInBrackets(Start, End, OldScriptPos, bHasElse, bHasIf);

			// Omega: Let's try recursively moving through this??
			while(bool(bHasElse) || bool(bHasIf))
			{
				bHasElse = 0;
				bHasIf = 0;
				GetTextInBrackets(Start, End, OldScriptPos, bHasElse, bHasIf);
			}
		}

		AddScriptLayer(OutText, ScriptLayers[ScriptLayers.Length - 1].LayerName$ "_IFCONDITIONAL_" $ScriptLayers[ScriptLayers.Length - 1].curScriptPosition, Conditional);
	}
	else // Move directly to else/nothing
	{
		OutText = GetTextInBrackets(Start, End, OldScriptPos, bHasElse, bHasIf);
		if(bool(bHasIf))
		{
			NewIf = Mid(CurCommand, InStr(Caps(CurCommand), "IF("));
			CutLog("New If from Else -> " $NewIf);
			return ParseNewQuestion(PlaceVars(NewIf));
		}
	}

	return true;
}

// Omega: Gets text in brackets and sends execution after it
function string GetTextInBrackets(out int Start, out int End, optional out int OldScriptPos, optional out byte HasElse, optional out byte HasIf)
{
	// Omega: Count brackets
	local int Left, Right, BackupPos;
	local String Search, Text;

	OldScriptPos = ScriptLayers[ScriptLayers.Length - 1].curScriptPosition;

	While(True)
	{
		if(!GetNextCommand(Search))
		{
			CutError("Ran out of script before finding second bracket!!!!");
			return "CUTERROR";
		}

		if(InStr(Search, "{") != -1)
		{
			Left++;
			if(Left == 1)
			{
				Start = ScriptLayers[ScriptLayers.Length - 1].curScriptPosition;
			}
		}
		else
		if(InStr(Search, "}") != -1)
		{
			Right++;
		}

		Text = Text ~= "" ? Search : Text $ Chr(10) $ Search;

		// Omega: If the left equals right
		if(Left == Right)
		{
			End = ScriptLayers[ScriptLayers.Length - 1].curScriptPosition;

			// Omega: Else handling
			if(InStr(Caps(CurCommand), "ELSE") != -1)
			{
				HasElse = 1;
				if(InStr(Caps(CurCommand), "IF(") != -1)
				{
					HasIf = 1;
				}
			}
			else
			{
				// Omega: Check next line
				BackupPos = ScriptLayers[ScriptLayers.Length - 1].curScriptPosition;
				GetNextCommand(Search);
				// Omega: Else handling on new line
				if(InStr(Caps(CurCommand), "ELSE") != -1)
				{
					HasElse = 1;
					if(InStr(Caps(CurCommand), "IF(") != -1)
					{
						HasIf = 1;
					}
				}
				else
				{
					ScriptLayers[ScriptLayers.Length - 1].curScriptPosition = BackupPos;
				}
			}
			CutLog("Found " $Right$ " Bracket sets to end");
			break;
		}
	}
	LastTextInBrackets = Text;
	return Text;
}

// Omega: Helper function for getting cues for bad commands
function string GetCue(string Command)
{
	local int Index;
	local string untilCue, actionPart;

	actionPart = ParseDelimitedString(Command," ",2,True);
	Index = InStr(actionPart,"*");
	
	if ( Index != -1 )
	{
		untilCue = ParseDelimitedString(Mid(actionPart,Index + 1)," ",1,False);

		if ( Len(untilCue) == 0 )
		{
			untilCue = GenerateUniqueCue();
		}
		actionPart = Left(actionPart,Index);
	}
	
	while ( (Asc(Right(actionPart,1)) == 32) || (Asc(Right(actionPart,1)) == 9) )
	{
		actionPart = Left(actionPart,Len(actionPart) - 1);
	}
	
	while ( (Asc(Right(untilCue,1)) == 32) || (Asc(Right(untilCue,1)) == 9) )
	{
		untilCue = Left(untilCue,Len(untilCue) - 1);
	}

	return untilCue;
}

function bool CutCommand_CameraShake (string Command)
{
	local Actor A;
	local string sString;
	local int I;
	local float magnitude;
	local float Time;

	magnitude = 100.0;
	Time = 0.5;
	I = 2;

	for(I = I; I < 20; I++)
	{
		sString = ParseDelimitedString(Command," ",I,False);
		if ( sString == "" )
		{
			break;
		}
		else
		if ( float(sString) > 0 )
		{
			magnitude = float(sString);
		} 
		else
		if ( Left(sString,Len("time=")) ~= "time=" )
		{
			Time = float(Mid(sString,Len("time=")));
		}
	}
	harry(Level.PlayerHarryActor).ShakeView(Time,magnitude,magnitude);
	return True;
}

function Play ()
{
	AddScriptLayer(Script, "MAIN");

	// Omega: Initiate custom cut question actor to Harry
	CutQuestionActor = Level.PlayerHarryActor;
	GotoState('Running');
}

function Pause ()
{
	GotoState('Idle');
}

// Omega: Triggers the fast forward for cutscene skipping
function FastForward ()
{
	local TimedCue TC;
	local Actor Act;
	local int I;

	CutLog("***Starting fastforward:");
	foreach AllActors(Class'TimedCue',TC)
	{
		if ( TC.CutNotifyActor == self )
		{
			TC.Timer();
		}
	}

	for(I = 0; I < aCapturedActors.Length; I++)
	{
		aCapturedActors[I].CutByPass();
		aCapturedActors[I].GlobalCutByPass();
	}
	bFastForward = True;
}

function Reset ()
{
}

auto state Idle
{
	begin:
		bPlaying = False;
}

// Omega: Obviously the state for running the script. Simple, only parses commands if there's no pending cues
state Running
{
	function BeginState ()
	{
		bPlaying = True;
		bFastForward = False;
		bUsingBaseCam = False;
		if ( parentCutScene.FileName != "" )
		{
			sThreadName = "<" $ parentCutScene.FileName $ ">." $threadNum;
		}
		else 
		{
			sThreadName = parentCutScene $ "." $threadNum;
		}
		CutLog("***CutScript Starting");
	}
	
	event Tick (float DeltaTime)
	{
		local string Command;
	
		bScriptAdvancing = False;

		while ( nPendingCues == 0 )
		{
			if (!GetNextCommand(Command, True) )
			{
				CutLog("***CutScript Finishing");
				GotoState('Finished');
				return;
			}
			lastCommand = Command;
			bScriptAdvancing = true;
			
			/*if ( !ParseCommand(Command) )
			{
				//KW left this empty? -AdamJD
			}*/
			// Omega: No reason to if this, in that case
			ParseCommand(Command);
		
			if ( bFastForward )
			{
				return;
			}
		}
	}
	
}

function DumpCurState ()
{
	CutLog("*****************************************************************************");
	CutLog("*CutDump" $ string(self));
	CutLog("*bPlaying:" $ string(bPlaying) $ "*bFastForward:" $ string(bFastForward) $ "*bScriptAdvancing:" $ string(bScriptAdvancing));
	CutLog("*Pending Cues:" $ string(nPendingCues));
	CutLog("*Last Command:" $ lastCommand);
	CutLog("*****************************************************************************");
}

state Finished
{
	function BeginState()
	{
		bPlaying = False;
	}
	/*begin:
		bPlaying = False;*/
}

defaultproperties
{
	bHidden=True

	// Omega: Test true by default
	//bAggressivelyRecapture=True

	bLogCutscene=True

	MiscFunctions=Class'MiscFunctions'
}
