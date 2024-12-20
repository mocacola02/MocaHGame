// Omega: Super simple string database viewer and possibly editor if I can finger it out C:
Class M212ShortCutListDatabase based on ShortCutList;

//var array<string> Key;
//var array<string> Value;

var array<Actor.GlobalStringEntry> GlobalKeys;

var UWindowEditControl	EditControl;

function Created()
{
	Super.Created();
	RowHeight = 12.0;
	bShowHorizSB = True;
	AddColumn(" Key",192.0);
	AddColumn(" Value",512.0);
	Reset();
}

// Omega: Fill up our array with our string data for viewing pleasure
function Reset()
{
	GlobalKeys.Empty();
	GlobalKeys = GetPlayerOwner().GetAllGlobalStrings();
	NumRows = GlobalKeys.Length;

	if(NumRows == 0)
	{
		NumRows = 1;
		GlobalKeys[0].Val = "No entries in string database";
	}
}

function LaunchShortcut (int Row)
{

}

function PaintColumn (Canvas C, UWindowGridColumn Column, float MouseX, float MouseY)
{
	local int TopMargin;
	local int BottomMargin;
	local int NumRowsVisible;
	local int CurRow;
	local int CurOffset;
	local int LastRow;

	if ( bShowHorizSB )
	{
		BottomMargin = LookAndFeel.Size_ScrollbarWidth; 
	}
	else 
	{
		BottomMargin = 0;
	}
	TopMargin = LookAndFeel.ColumnHeadingHeight;
	NumRowsVisible = (WinHeight - (TopMargin + BottomMargin)) / RowHeight; 
	VertSB.SetRange(0, NumRows, NumRowsVisible);
	CurRow = VertSB.Pos;
	LastRow = CurRow + NumRowsVisible;
	if ( LastRow > NumRows )
	{
		LastRow = NumRows;
	}
	CurOffset = 0;
	C.DrawColor.G = 255;
	while ( CurRow < LastRow )
	{
		if ( CurRow == SelectedRow )
		{
			C.DrawColor.R = 0;
			C.DrawColor.B = 0;
		} 
		else 
		{
			C.DrawColor.R = 255;
			C.DrawColor.B = 255;
		}
		switch (Column.ColumnNum)
		{
			case 0:
				Column.ClipText(C, 2.0, TopMargin + CurOffset, GlobalKeys[CurRow].Key);
				break;
			case 1:
				Column.ClipText(C, 2.0, TopMargin + CurOffset, GlobalKeys[CurRow].Val);
				break;
			default:
		}
		CurOffset += RowHeight;
		++CurRow;
	}
}

function SortColumn (UWindowGridColumn Column)
{
    HPConsole(Root.Console).Viewport.Actor.ClientMessage("sort column " $ string(Column.ColumnNum));
}

