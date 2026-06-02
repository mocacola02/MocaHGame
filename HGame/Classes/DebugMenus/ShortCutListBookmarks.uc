//==========================================================================//
// ShortCutListBookmarks.
//
// List of bookmarks to track in the shortcut browser.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class ShortCutListBookmarks extends ShortCutList;

var array<name> lableName;	// List of label names
var array<string> lableDesc;// List of label descriptions


//==========
// Display
//==========

// Called when created
function Created()
{
	// Call parent behavior
	Super.Created();

	// Set row height to 12.0 units
	RowHeight = 12.0;

	// Show horizontal scrollbar
	bShowHorizSB = True;

	// Add index, name, and description columns
	AddColumn(" Index",28.0);
	AddColumn(" Name",64.0);
	AddColumn(" Description",512.0);

	// Reset row data
	Reset();
}

// Paint column element onto canvas
function PaintColumn (Canvas C, UWindowGridColumn Column, float MouseX, float MouseY)
{
	local int TopMargin;
	local int BottomMargin;
	local int NumRowsVisible;
	local int CurRow;
	local int CurOffset;
	local int LastRow;

	// If showing horizontal scrollbar, account for it in bottom margin
	if ( bShowHorizSB )
	{
		BottomMargin = LookAndFeel.Size_ScrollbarWidth; 
	}
	// Otherwise, we don't need a bottom margin
	else 
	{
		BottomMargin = 0;
	}

	// Set top margin to column heading height
	TopMargin = LookAndFeel.ColumnHeadingHeight;

	// Calculate number of visible rows
	NumRowsVisible = (WinHeight - (TopMargin + BottomMargin)) / RowHeight;

	// Set vertical scrollbar range
	VertSB.SetRange(0, NumRows, NumRowsVisible);

	// Set current row to vertical scrollbar position
	CurRow = VertSB.Pos;

	// Set last row to current row plus number of visible rows
	LastRow = CurRow + NumRowsVisible;

	// If the last row is greater than the number of rows, set it to NumRows
	if ( LastRow > NumRows )
	{
		LastRow = NumRows;
	}

	// Set offset to 0
	CurOffset = 0;

	// Max out green value of draw color
	C.DrawColor.G = 255;
	
	// While current row is less than last row
	while ( CurRow < LastRow )
	{
		// If current row is the selected row, zero out red and blue values
		if ( CurRow == SelectedRow )
		{
			C.DrawColor.R = 0;
			C.DrawColor.B = 0;
		}
		// Otherwise, max out red and blue values
		else
		{
			C.DrawColor.R = 255;
			C.DrawColor.B = 255;
		}

		// Switch based on Column.ColumnNum
		switch (Column.ColumnNum)
		{
			// In the case of Column.ColumnNum == 0
			case 0:
				// Clip text with CurRow as text
				Column.ClipText(C,2.0,TopMargin + CurOffset,CurRow);
				// Exit switch statement
				break;
			// In the case of Column.ColumnNum == 1
			case 1:
				// Clip text with the current label name as text
				Column.ClipText(C,2.0,TopMargin + CurOffset,lableName[CurRow]);
				// Exit switch statement
				break;
			// In the case of Column.ColumnNum == 2
			case 2:
				// Clip text with the current label description as text
				Column.ClipText(C,2.0,TopMargin + CurOffset,lableDesc[CurRow]);
				// Exit switch statement
				break;
			// Otherwise default to doing nothing and continuing
			default:
		}

		// Add row height to current offset
		CurOffset += RowHeight;

		// Increment current row
		++CurRow;
	}
}


//======================
// Row/Column Handling
//======================

// Launches a shortcut from a given row
function LaunchShortcut (int Row)
{
	local navShortcut sc;
	local int I;

	// Init I to 0
	I = 0;

	// For each navShortcut actor
	foreach GetPlayerOwner().AllActors(Class'navShortcut',sc)
	{
		// If I equals the given row, move harry to the shortcut's location
		if ( I == Row )
		{
			harry(GetPlayerOwner()).GotoLocation(sc.Location);
		}

		// Increment I
		I++;
	}
}

// Resets row data
function Reset()
{
	local navShortcut sc;

	// Reset row count to 0
	NumRows = 0;

	// For each navShortcut actor
	foreach GetPlayerOwner().AllActors(Class'navShortcut',sc)
	{
		// Add label name and description from shortcut name and description
		lableName[NumRows] = sc.Name;
		lableDesc[NumRows] = sc.Description;

		// Increment row count
		NumRows++;
	}

	// If we have no rows, add a row with a notice message
	if ( NumRows == 0 )
	{
		NumRows = 1;
		lableName[0] = '0';
		lableDesc[0] = "Could not find any bookmarks!";
	}
}

// Log that a column has been/should be sorted
function SortColumn (UWindowGridColumn Column)
{
	HPConsole(Root.Console).Viewport.Actor.ClientMessage("sort column " $ string(Column.ColumnNum));
}