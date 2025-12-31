class HItem extends HActor
	Abstract;

var bool bDisplayCount;		// Moca: Display count when collected?
var bool bDisplayMaxCount;	// Moca: Display max count when collected?

var int CurrentCount;
var int MinCount;
var int MaxCount;			// Moca: Max number of this item that can be collected.

var float XScale;			// Moca: X Scale of HUD icon
var float YScale;			// Moca: Y Scale of HUD icon

var name HUDGroup;			// Moca: HUD Group name

var string GlobalKey;		// Moca: Global key to store the value under. If two items have the same GlobalKey, they will increment each other.
var string TooltipID;		// Moca: ID of localized tooltip

var Texture HUDTexture;		// Moca: Texture for HUD icon

var Color CountColor;		// Moca: Color of count text
var Color CountColorShadow;	// Moca: Color of count text shadow

var Font CountFont;



function IncrementCount(int Increment)
{
	SetCount(CurrentCount + Increment);
}

function SetCount(int NewCount)
{
	if ( !NewCount > MaxCount )
	{
		SetGlobalInt(GlobalKey, NewCount);
		CurrentCount = NewCount;
	}
}

function int GetCount()
{
	return GetGlobalInt(GlobalKey);
}

defaultproperties
{
	bDisplayCount=True

	MaxCount=99999

	XScale=1.0
	YScale=1.0

	CountColor=(R=200,G=200,B=190)
	CountColorShadow=(R=32,G=32,B=32)
}