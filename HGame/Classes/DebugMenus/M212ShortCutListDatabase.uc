//==========================================================================//
// M212ShortCutListDatabase.
//
// Omega: Super simple string database viewer and possibly editor if I can finger it out C:
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//

Class M212ShortCutListDatabase based on ShortCutList;

var array<Actor.GlobalStringEntry> GlobalKeys;	// Array of global string entries
var UWindowEditControl EditControl;				// Reference to edit control


// Called when created
function Created()
{
	// Call parent behavior
	Super.Created();

	// Set row height to 12.0 units
	RowHeight = 12.0;

	// Show the horizontal scrollbar
	bShowHorizSB = True;

	// Add a column "Key" with a width of 192.0 units
	AddColumn(" Key",192.0);

	// Add a column "Value" with a width of 512.0 units
	AddColumn(" Value",512.0);

	// Reset global key data
	Reset();
}

// Omega: Fill up our array with our string data for viewing pleasure
function Reset()
{
	// Empty the global keys array
	GlobalKeys.Empty();

	// Re-populate the array
	GlobalKeys = GetPlayerOwner().GetAllGlobalStrings();

	// Set our number of rows to the length of the global keys array
	NumRows = GlobalKeys.Length;

	// If we have zero rows, add a row with a notice message
	if(NumRows == 0)
	{
		NumRows = 1;
		GlobalKeys[0].Val = "No entries in string database";
	}
}

// Launch shortcut. Does nothing without extension.
function LaunchShortcut (int Row);

// Paint onto canvas
function PaintColumn (Canvas C, UWindowGridColumn Column, float MouseX, float MouseY)
{
	local int TopMargin;
	local int BottomMargin;
	local int NumRowsVisible;
	local int CurRow;
	local int CurOffset;
	local int LastRow;

	// If set to show horizontal scrollbar, account for it in our bottom margin
	if ( bShowHorizSB )
	{
		BottomMargin = LookAndFeel.Size_ScrollbarWidth; 
	}
	// Otherwise, we don't need a bottom margin
	else 
	{
		BottomMargin = 0;
	}

	// Account for the column heading height in the top margin
	TopMargin = LookAndFeel.ColumnHeadingHeight;

	// Calculate the number of rows visible based on window height, margins, and row height
	NumRowsVisible = (WinHeight - (TopMargin + BottomMargin)) / RowHeight;

	// Set the range of the vertical scrollbar
	VertSB.SetRange(0, NumRows, NumRowsVisible);

	// Set current row to the vertical scrollbar position
	CurRow = VertSB.Pos;

	// Set last row to the current row plus number of visible rows
	LastRow = CurRow + NumRowsVisible;

	// If our last row is greater than the number of rows, clamp it to NumRows
	if ( LastRow > NumRows )
	{
		LastRow = NumRows;
	}
	
	// Set current offset to 0.0
	CurOffset = 0;

	// Max out the green value on draw color
	C.DrawColor.G = 255;

	// While the current row is less than the last row
	while ( CurRow < LastRow )
	{
		// If the current row is the selected row, zero out the red and blue values
		if ( CurRow == SelectedRow )
		{
			C.DrawColor.R = 0;
			C.DrawColor.B = 0;
		}
		// Otherwise, max out the red and blue values
		else 
		{
			C.DrawColor.R = 255;
			C.DrawColor.B = 255;
		}

		// Switch based on the value of Column.ColumnNum
		switch (Column.ColumnNum)
		{
			// In the case of Column.ColumnNum == 0
			case 0:
				// Clip the text of the current GlobalKeys key
				Column.ClipText(C, 2.0, TopMargin + CurOffset, GlobalKeys[CurRow].Key);
				// Exit switch statement
				break;
			// In the case of Column.ColumnNum == 1
			case 1:
				// Clip the text of the current GlobalKeys value
				Column.ClipText(C, 2.0, TopMargin + CurOffset, GlobalKeys[CurRow].Val);
				// Exit switch statement
				break;
			
			// Otherwise, default to doing nothing and continuing
			default:
		}

		// Add row height to our current offset
		CurOffset += RowHeight;

		// Increment the current row value
		++CurRow;
	}
}

// Logs that a given column is being/should be sorted
function SortColumn (UWindowGridColumn Column)
{
    HPConsole(Root.Console).Viewport.Actor.ClientMessage("sort column " $ string(Column.ColumnNum));
}

