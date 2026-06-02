//==========================================================================//
// ShortCutListLevels.
//
// List of levels to track in the shortcut browser.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class ShortCutListLevels extends ShortCutList;

var array<int> lableNumbers;	// Array of label numbers
var array<string> lableMapNames;// Array of label map names


//==========
// Display
//==========

// Called when created
function Created ()
{
	// Call parent behavior
	Super.Created();

	// Add level and map name columns
	AddColumn(" Level",28.0);
	AddColumn(" MapName",512.0);

	// Reset row count to 0
	NumRows = 0;

	// Reset row data
	Reset();
}

// Paint element onto canvas
function PaintColumn (Canvas C, UWindowGridColumn Column, float MouseX, float MouseY)
{
	local int TopMargin;
	local int BottomMargin;
	local int NumRowsVisible;
	local int CurRow;
	local int CurOffset;
	local int LastRow;

	// If show horizontal scrollbar, account for it in the bottom margin
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

	// Set current row to the vertical scrollbar position
	CurRow = VertSB.Pos;

	// Set last row to the current row plus rows visible
	LastRow = CurRow + NumRowsVisible;

	// Set offset to 0
	CurOffset = 0;

	// If last row exceeds the number of rows, set last row to number of rows
	if ( LastRow > NumRows )
	{
		LastRow = NumRows;
	}

	// Max out green value of draw color
	C.DrawColor.G = 255;
	
	// While the current row index is less than the last row index
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
		
		// Switch based on Column.ColumnNum value
		switch (Column.ColumnNum)
		{
			// In the case of ColumnNum == 0
			case 0:
				// Clip label number text
				Column.ClipText(C,2.0,TopMargin + CurOffset,lableNumbers[CurRow]);
				// Exit switch statement
				break;
			// In the case of ColumnNum == 1
			case 1:
				// Clip map name text
				Column.ClipText(C,2.0,TopMargin + CurOffset,lableMapNames[CurRow]);
				// Exit switch statement
				break;
		}
    
		// Add row height to current offset
		CurOffset += RowHeight;

		// Increment current row
		++CurRow;
	}
}


//======================
// Column/Row handling
//======================

// Reset list
function Reset ()
{
	// Old commented-out code removed. Please see old revisions if needed.
	// Metallicafan212:	Redo this to be much more efficient
	local Array<String> MapNames;
	local int i;
	
	// Get all map names
	GetPlayerOwner().GetAllMapNames(MapNames);
	
	// Get number of rows from MapNames length
	NumRows = MapNames.Length;
	
	// For the number of map names
	for(i = 0; i < MapNames.Length; i++)
	{
		// Add map name and number to global array
		lableMapNames[i] 	= MapNames[i];
		lableNumbers[i] 	= i;
	}
}

// Launch a shortcut from a given row
function LaunchShortcut (int Row)
{
	baseConsole(Root.Console).ChangeLevel(lableMapNames[Row],True);
}