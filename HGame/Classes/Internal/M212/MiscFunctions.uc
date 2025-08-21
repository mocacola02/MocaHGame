// Omega: Misc functions that don't cleanly fit anywhere but have been copied around or referenced
// all over the place. Fits better as a static class

// also the ascii art is from https://patorjk.com/software/taag
// Slant font, characters width and height smushed lol
class MiscFunctions based on Object
	abstract;

// Omega: Part of projectile leading code placed in this class, see math section
//solutions to quart!
struct QuartSolution
{
  	var float u[4];
};

var array<String> BoolOperators;

/*
================================================================================
   _____ __       _                ______                 __  _                 
  / ___// /______(_)___  ____ _   / ____/_  ______  _____/ /_(_)___  ____  _____
  \__ \/ __/ ___/ / __ \/ __ `/  / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
 ___/ / /_/ /  / / / / / /_/ /  / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  ) 
/____/\__/_/  /_/_/ /_/\__, /  /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/  
                      /____/                                                    
================================================================================
*/

// Omega: Ported from actor so we don't need to have an actor reference to call it
static final function string ParseDelimitedString(string Text, string Delimiter, int Count, optional bool bToEndOfLine)
{
	local string Result;
	local int Found, i;
	local string s;

	Result = "";	
	Found = 1;
	
	for(i = 0; i < Len(Text); i++)
	{
		s = Mid(Text, i, 1);
		if(InStr(Delimiter, s) != -1)
		{
			if(Found == Count)
			{
				if(bToEndOfLine)
					return Result$Mid(Text, i);
				else
					return Result;
			}

			Found++;
		}
		else
		{
			if(Found >= Count)
				Result = Result $ s;
		}
	}
	
	return Result;
}

// Omega: From Uwindow:
static final function ReplaceText(out string Text, string Replace, string With)
{
	local int i;
	local string Input;
		
	Input = Text;
	Text = "";
	i = InStr(Input, Replace);
	while(i != -1)
	{	
		Text = Text $ Left(Input, i) $ With;
		Input = Mid(Input, i + Len(Replace));	
		i = InStr(Input, Replace);
	}
	Text = Text $ Input;
}

// Omega: From UWindow
static final function StripCRLF(out string Text)
{
	ReplaceText(Text, Chr(13)$Chr(10), "");
	ReplaceText(Text, Chr(13), "");
	ReplaceText(Text, Chr(10), "");
}

// Omega: From GameInfo originally:
//
// Grab the next option from a string.
//
static final function bool GrabOption( out string Options, out string Result, optional string Delimiter )
{
	if(Delimiter == "")
	{
		Delimiter = "?";
	}

	if( Left(Options,1) == Delimiter )
	{
		// Get result.
		Result = Mid(Options,1);
		if( InStr(Result, Delimiter)>=0 )
			Result = Left( Result, InStr(Result, Delimiter) );

		// Update options.
		Options = Mid(Options,1);
		if( InStr(Options, Delimiter)>=0 )
			Options = Mid( Options, InStr(Options, Delimiter) );
		else
			Options = "";

		return true;
	}
	else return false;
}

//
// Break up a key=value pair into its key and value.
//
static final function GetKeyValue( string Pair, out string Key, out string Value )
{
	if( InStr(Pair,"=")>=0 )
	{
		Key   = Left(Pair,InStr(Pair,"="));
		Value = Mid(Pair,InStr(Pair,"=")+1);
	}
	else
	{
		Key   = Pair;
		Value = "";
	}
}

//
// See if an option was specified in the options string.
//
static final function bool HasOption( string Options, string InKey, optional string Delimiter )
{
	local string Pair, Key, Value;
	while( GrabOption( Options, Pair, Delimiter ) )
	{
		GetKeyValue( Pair, Key, Value );
		if( Key ~= InKey )
			return true;
	}
	return false;
}

//
// Find an option in the options string and return it.
//
static final function string ParseOption( string Options, string InKey, optional string Delimiter )
{
	local string Pair, Key, Value;
	while( GrabOption( Options, Pair, Delimiter ) )
	{
		GetKeyValue( Pair, Key, Value );
		if( Key ~= InKey )
			return Value;
	}
	return "";
}

// Omega: Strip spaces (Or arbitrary character) from the start and end of a string
static final function string StripSpaces(string Input, optional string Space)
{
	local string S, Out, Front, End;
	local int i;

	if(Space ~= "")
	{
		Space = " ";
	}

	S = Input;

	Front = CharAt(Input, 0);
	End = CharAt(Input, Len(Input) - 1);

	if(Front ~= Space)
	{
		S = Right(S, Len(S) - 1);
	}

	if(End ~= Space)
	{
		S = Left(S, Len(S) - 1);
	}

	Out = S;

	Front = CharAt(Out, 0);
	End = CharAt(Out, Len(Out) - 1);

	if(Front ~= Space || End ~= Space)
	{
		return StripSpaces(Out);
	}

	return Out;
}

static final function string StripMultiSpaces(string Input, optional string Space)
{
	local string InputOld;

	if(Space ~= "")
	{
		Space = " ";
	}

	While(True)
	{
		ReplaceText(Input, Space$Space, Space);
		if(Input ~= InputOld)
		{
			Break;
		}
		InputOld = Input;
	}

	return Input;
}

// Omega: Get string between strings
static final function string GetStringBetweenStrings(string Input, string StartString, string EndString, out int Start, out int End, optional bool bEndFromRight)
{
	local int i, j;

	Start = InStr(Input, StartString);
	End = InStr(Input, EndString, bEndFromRight);

	// Omega: Just return the input if it's not correct
	if(Start == -1 || End == -1)
	{
		return Input;
	}
	// Omega: Move the start up so that we're actually between the strings
	Start += Len(StartString);

	return Mid(Input, Start, End - Start);
}

// Omega: Get all strings between a string as an array
static final function array<string> GetAllStringsBetweenStrings(string Input, string StartString, string EndString)
{
	local array<string> ret;
	local string In, Test;
	local int Start, End;

	In = Input;

	while(True)
	{
		Test = GetStringBetweenStrings(In, StartString, EndString, Start, End);

		if(Test ~= "" || Start == -1 || End == -1)
		{
			return ret;
		}

		ret.AddItem(Test);

		In = Mid(In, End + Len(EndString));
	}

	return ret;
}

// Omega: There to replace the parameter parsing method most cutscene parameters use
static final function bool IsStringParam(string Param, string In)
{
	return Left(In, Len(Param)) ~= Param;
}


// Omega: Parse a boolean expression from textual form
// Adapted from:
// https://leetcode.com/problems/parsing-a-boolean-expression/solutions/5939345/beats-100-optimized-solution-python-java-c-o-n-o-n/
// Realistically this is probably one of the fastest ways to do this kind of thing in unrealscript unless I ask for a specific bool parsing feature
/*
=====================================================================================
Some examples of expressions: 
"&(|(f))" == False
"|(f,f,f,t)" == True
"!(&(f,t))" == True

Expression is one of the following characters: "(", ")", "&", "|", "!", "t", "f", ","
=====================================================================================
*/
static final function bool ParseBoolExpression(string Expression)
{
	local array<String> Stack;
	local string C, TopValue, Op;
	local bool bHasTrue, bHasFalse;
	local int i;

	for(i = 0; i < Len(Expression); i++)
	{
		C = CharAt(Expression, i);

		if(C ~= "," || C ~= "(")
		{
			Continue;
		}

		if(C ~= "t" || C ~= "f" || C ~= "!" || C ~= "&" || C ~= "|")
		{
			Stack.Push(C);
		}
		else
		if(C ~= ")")
		{
			bHasTrue = false;
			bHasFalse = false;

			while(Stack.Peek() != "!" && Stack.Peek() != "&" && Stack.Peek() != "|")
			{
				TopValue = Stack.Pop();
				if(TopValue ~= "t")
				{
					bHasTrue = True;
				}
				if(TopValue ~= "f")
				{
					bHasFalse = True;
				}
			}

			Op = Stack.Pop();

			if(Op ~= "!")
			{
				Stack.Push(bHasTrue ? "f" : "t");
			}
			else
			if(Op ~= "&")
			{
				Stack.Push(bHasFalse ? "f" : "t");
			}
			else
			{
				Stack.Push(bHasTrue ? "t" : "f");
			}
		}
	}

	return Stack.Peek() ~= "t";
}

/*
===========================================================================
    __  ___      __  __       ______                 __  _                 
   /  |/  /___ _/ /_/ /_     / ____/_  ______  _____/ /_(_)___  ____  _____
  / /|_/ / __ `/ __/ __ \   / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
 / /  / / /_/ / /_/ / / /  / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  ) 
/_/  /_/\__,_/\__/_/ /_/  /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/                                                      
===========================================================================
*/

// Omega: Does this even count as math?
static final function int ConvertGameStateToNumber(string CurrentGameState)
{
	return int(Mid(CurrentGameState, 6));
}

// Omega: Vector Lerp
static final function vector VLerp(float Alpha, vector A, vector B)
{
	local vector V;

	V = A + ((B - A) * Alpha);

	return V;
}

// Omega: Need to test if this actually works, I think based on how Basecam's rotation math works this actually should
// The rotators may need to be normalized though
static final function rotator RLerp(float Alpha, rotator A, rotator B)
{
	local rotator R;

	R = A + ((B - A) * Alpha);

	return R;
}

// Omega: Easing functions
// Handy tutorial on them followed from here: https://www.febucci.com/2018/08/easing-functions/
// More to look at here: https://github.com/ai/easings.net/blob/master/src/easings/easingsFunctions.ts
// Also this: https://github.com/sole/tween.js/blob/master/src/Tween.js
static final function float EaseIn(float F)
{
	return F*F;
}

static final function float Flip(float F)
{
	return 1 - F;
}

static final function float EaseOut(float F)
{
	return Flip(Flip(F) ** 2);
}

static final function float EaseInOut(float F)
{
	return Lerp(F, EaseIn(F), EaseOut(F));
}

static final function float Spike(float F)
{
	if(f <= 0.5)
	{
		return EaseIn(f/ 0.5);
	}
	return EaseIn(Flip(F) / 0.5);
}

static final function float SpikeSquare(float F)
{
	return Spike(F ** 2);
}

// Omega: Projectile leading code lovingly borrowed from the BeyondUnreal folks at: https://wiki.beyondunreal.com/Legacy:Projectile_Aiming
// If the site is still broken (and hopefully not down), there's a tampermonkey script to fix it somewhere
// Code cleaned up a bit as well.

//quadratic solver (using everybody's favorite algebra formula)
static final function calculateQuadRoots(float a, float b, float c, out QuartSolution Q)
{
	local float sqterm;
	sqterm = b*b - 4*a*c;
	if (sqterm<0)//imaginary root. return t=1
	{ 
		Q.u[0]=-1;
		Q.u[1]=-1;
	}
	else
	{
		sqterm=sqrt(sqterm);
		a*=2;
		b*=-1;
		Q.u[0]=(b+sqterm)/(a);
		Q.u[1]=(b-sqterm)/(a);
	}
}
 
//Solve a 4th Degree Polynomial (Quartic) equation for 0s.
//taken from a javascript webpage (Explicitly states in source that source may be reused in any way)
//uses the quartic formula! :)
static final function calculateQ(float aq, float bq, float cq, float dq, float eqin, out QuartSolution Q)
{
	local float eq;
	local float fq;
	local float gq;
	//local float hq;
	
	
	// These are the squares of the local floatiables used to calculate the 4 roots-->
	local float kq;
	local float lq;
	local float mq;
	local float nq;
	local float mq2;
	
	local float compsw;
	local float kqsw;
	local float lqsw;
	local float mqsw;
	
	// Switch used in calculating REAL quartic roots)-->
	local float sw;
	
	// local floatiables for calculating REAL quartic roots)-->
	
	local float kans;
	local float lans;
	local float theta;
	
	
	local float x1;
	local float x2;
	local float x3;
	local float x4;
	
	local float x2a, x2b, x2c, x2d;
	//local float x1b, x1b2, x2b2, x3b, x3b2, x4b, x4b2;
	//more:
	local float dnm;
	local float a, b, c, d, f, g, h, k, m, m2,n,n2,r,rc;
	local float calcy, calcp, calcr, calcq, calcx, calcmod;
	local float dnmsw;
	local int i;
	
	// the 'q' suffix  denotes local floatiables used in the quartic equation
	for (i=0;i<4;i++) 
	{
		Q.u[i]=-1.0; //set to complex solutions
	}

	compsw=0;
	kqsw=0;
	lqsw=0;
	mqsw=0;
	dnmsw=0;
	sw=0;
	
	
	dnm=aq;      //note: this assumes aq is non-zero.  Of course it should be (eval 0.25g!)
	
	//Simplifying by dividing all terms by the aq term called 'dnm' meaning denominator
	aq=bq/dnm;
	bq=cq/dnm;
	cq=dq/dnm;
	dq=eqin/dnm;
	//Which yields an equation of the form X^4 + AX^3 + BX^2 + CX + D = 0
	
	eq= bq-((3*aq*aq)/8);
	fq= cq+ (aq*aq*aq/8) -(aq*bq/2);
	gq= dq- (3*aq*aq*aq*aq/256) + (aq*aq*bq/16) - (aq*cq/4);
	
	// SOLVING THE RESULTANT CUBIC EQUATION
	// EVALUATING THE 'f'TERM
	
	a=1; b=eq/2; c=((eq*eq)-(4*gq))/16; d= ((fq*fq)/64)*-1;
	
	f = (((3*c)/a) - (((b*b)/(a*a))))/3;
	//EVALUATING THE 'g'TERM
	
	g = ((2*((b*b*b)/(a*a*a))-(9*b*c/(a*a)) + ((27*(d/a)))))/27;
	
	//EVALUATING THE 'h'TERM
	h = (((g*g)/4) + ((f*f*f)/27));
	if (h > 0)
	{
		compsw=2;
		m = (-(g/2)+ (sqrt(h)));
		// K is used because math.pow cannot compute negative cube roots?
		k=1;

		if (m < 0) 
			k=-1;
		else 
			k=1;

		m2 = ((m*k)**(1.0/3.0));
		
		m2 = m2*k;
		k=1;
		n = (-(g/2)- (sqrt(h)));

		if (n < 0)
			k=-1;
		else
			k=1;
		
		n2 = (n*k)**(1.0/3.0);
		n2 *=k;
		k=1;
		kq=  ((m2 + n2) - (b/(3*a)));
		kq=sqrt(kq);

		// ((S+U)     - (b/(3*a)))
		calcmod= sqrt((-1*(m2 + n2)/2 - (b/(3*a)))*(-1*(m2 + n2)/2 - (b/(3*a))) + (((m2 - n2)/2)*sqrt(3))*(((m2 - n2)/2)*sqrt(3)));
		calcy=sqrt((calcmod-(-1*(m2 + n2)/2 - (b/(3*a))))/2);
		calcx=(((m2 - n2)/2)*sqrt(3))/(2*calcy);
		calcp=calcx+calcy;
		calcq=calcx-calcy;
		calcr=kq;
		
		nq=(aq/4);
		x1=kq+calcp+calcq-nq;
		x4=kq-calcp-calcq-nq;
		
		
		Q.u[0]=-x1; //appearently was incorrect by a factor of -1
		Q.u[1]=-1; //complex
		Q.u[2]=-1; //complex
		Q.u[3]=-x4;
	}
	
	
	// FOR H < 0
	
	if (h<=0)
	{
		r = sqrt((g*g/4)-h);
		k=1;
		
		if (r<0)
			k=-1;
		// rc is the cube root of 'r'
		
		rc = ((r*k)**(1.0/3.0))*k;
		k=1;
		theta =acos((-g/(2*r)));
		
		kq= (2*(rc*cos(theta/3))-(b/(3*a)));
		
		x2a=rc*-1;
		x2b= cos(theta/3.0);
		x2c= sqrt(3)*(sin(theta/3));
		x2d= (b/3.0*a)*-1;
		
		lq=(x2a*(x2b + x2c))-(b/(3*a));
		
		mq=(x2a*(x2b - x2c))-(b/(3*a));
		
		nq=(aq/4.0);
	}
	
	if (h<=0)
	{
		// psudo-fix 0 bug.. not the best.. but works
		if (abs(kq)<1.0/(10000.0))
			kq=0;
		if (abs(lq)<1.0/(10000.0))
			lq=0;
		if (abs(mq)<-1.0/(10000.0))
			mq=0;

		if (kq<0) {return;} else {kq=sqrt(kq);}
		if (lq<0) {return;} else {lq=sqrt(lq);}
		if (mq<0) {return;} else {mq=sqrt(mq);}
		
		if (kq*lq>0){mq2=((fq*-1)/(8*kq*lq));kans=kq;lans=lq;}
		if (kq*mq>0){mq2=((fq*-1)/(8*kq*mq));kans=kq;lans=mq;}
		if (lq*mq>0){mq2=((fq*-1)/(8*lq*mq));kans=lq;lans=mq;}
		
		if (compsw==0)
		{
			x1=kans+lans+mq2-nq;
			Q.u[0]=x1;
			x2=kans-lans-mq2-nq;
			Q.u[1]=x2;
			x3=(kans*-1)+lans-mq2-nq;
			Q.u[2]=x3;
			x4=(kans*-1)-lans+mq2-nq;
			Q.u[3]=x4;
		}
	}
}
 
/*Calculate aiming ideal rotation for firing a projectile at a potentially moving target (assumes pawn physics)
 IN:
 -StartLoc = world location where projectile is starting at
 -EndLoc = world Location we wish to Target (should lie in the targetted actor)
 -ProjSpeed = speed of the projectile being fired
 -Gravity = a vector describing the gravity
 -Target = the actual targetted ACTOR
 -bLeadTarget = Can we track the target?  (the entire point of this function)
 OUT:
 -dest: Location where the projectile will collide with Target
 -returns vector describing direction for projectile to leave at
*/
static final function vector GetShootVect(vector StartLoc, vector EndLoc, float ProjSpeed, vector Gravity, actor Target, bool bLeadTarget, out vector Dest)
{
	local QuartSolution Q;
	local float best, speed2D, HitTime;
	local vector Pr;
	local int i;
	local vector HitNorm, HitLoc;
	local vector D; //EndLoc-StartLoc
	local vector V; //Target.velocity
 
	D = EndLoc-StartLoc;
	V = Target.Velocity;
	//track falling actors
	if (bLeadTarget && Target.Physics==Phys_Falling)
	{
		calculateQuadRoots(V dot V - ProjSpeed*ProjSpeed, 2*(V dot D),D dot D,Q); //use quadratic formula
		for (i=0;i<2;i++)
		{
			if (best<=0||(q.u[i]>0 && q.u[i]<best))
				best=q.u[i];
		}
			
		Pr = normal(D/best + V)*ProjSpeed;
		if (best<=0 || Target.Trace(HitLoc,HitNorm,EndLoc+V*best+0.5*Gravity*best*best,EndLoc+vect(1,1,0)*V*best) == none)
		{
			//will be falling:
			Dest = StartLoc + PR*best+0.5*Gravity*best*best;
			return normal(PR)*ProjSpeed;
		}
		else if (best>0)  //determine how long actor will be in air
			HitTime = vsize(HitLoc - (EndLoc+vect(1,1,0)*V*best))/vsize(vect(0,0,1)*V*best+0.5*Gravity*best);
		else
			HitTime = 0; //assume most time not in air?
	}
 
  	//ASSUME GROUND TRACKING

	if (bLeadTarget && Target.Physics==Phys_Falling)//trace down from target to get ground normal
	{   
  		Target.Trace(HitLoc,HitNorm,EndLoc+normal(Gravity)*5000,EndLoc);
		D.z=HitLoc.z-StartLoc.Z;  //set destination.z to floor, wipe out velocity.z and re-eval assuming ground
		V.z=0;    //no longer falling - view velcocity in 2D
		if (HitTime>0.5)
		{  //True if likely in air most of time (in which case keep current V.X and V.y)
			V.z -= HitNorm.Z * (V dot HitNorm);
		}
		else
		{ //otherwise alter all of velocity vector, but keep current 2D speed
			speed2D = vsize(V);
			V=normal(V)*speed2D; //assume the same x and y speed if in air most time
			V -= HitNorm * (V dot HitNorm);   //recalculate players velocity on a slope using hitnormal  (assumes v.x and v.y is "ground speed")
			V=normal(V)*speed2D; //assume the same x and y speed if in air most time
		}
  	}
	//todo: add traces to check side walls?
	//note: walking velocity *should* factor in current slope
	best=0;
	if (bLeadTarget && V!=vect(0,0,0))
	{
		calculateQ(0.25*(Gravity dot Gravity),(-Gravity) dot V,(-Gravity) dot D + V dot V - ProjSpeed*ProjSpeed,2*(V dot D),D dot D,Q);
		for (i=0;i<4;i++)
		{
			if (best<=0||(q.u[i]>0 && q.u[i]<best))
		    	best=q.u[i];
		}
	}
	else
	{ //don't lead. assume stationary target
		calculateQuadRoots(0.25*(Gravity dot Gravity),(-Gravity) dot D - ProjSpeed*ProjSpeed,D dot D,Q);
		for (i=0;i<2;i++)
		{
			if (best<=0||(q.u[i]>0 && q.u[i]<best))
				best=q.u[i];
		}
      	if (best>0)
			best=sqrt(best);
  	}
 
	if (best<=0)//projectile is out of range
	{   
		//Warning: Out of range adjustments assume gravity is parallel to the z axis and pointed downward!!
		Pr.z =ProjSpeed/sqrt(2.0); //determine z direction of firing
		best = -2*Pr.z/Gravity.z;
		best+=(vsize(D)-pr.Z*best)/ProjSpeed; //note p.z = 2D vsize(p)  (this assumes ball travels in a straight line after bounce)
		//now recalculate PR to handle velocity prediction (so ball at least partially moves in direction of player)
		Pr = D/best + V - 0.5*Gravity*best;
		//now force maximum height again:
		Pr.z=0;
		Pr = (ProjSpeed/sqrt(2.0))*normal(Pr);
		Pr.z = ProjSpeed/sqrt(2.0); //maxmimum
		Dest = StartLoc + PR*best+0.5*Gravity*best*best;
		return Pr;
	}
 
  	Pr = normal(D/best + V - 0.5*Gravity*best)*ProjSpeed;
 
	Dest = StartLoc + PR*best+0.5*Gravity*best*best;
	return Pr;
}

defaultproperties
{
	BoolOperators(0)="("
	BoolOperators(1)=")"
	BoolOperators(2)="&"
	BoolOperators(3)="|"
	BoolOperators(4)="!"
	BoolOperators(5)=","
}