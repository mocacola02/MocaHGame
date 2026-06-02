//==========================================================================//
// ShortCutList.
//
// Window grid class for shortcut list.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class ShortCutList extends UWindowGrid;

var int SelectedRow;	// Current selected row
var int NumRows;		// Total number of rows


//==================
// Shortcut Launch
//==================

// Launches a shortcut based on a given row, does nothing without extension
function LaunchShortcut (int Row);

// Called when launch button is pressed, launches the shortcut at the SelectedRow
function OnLaunchButton()
{
	LaunchShortcut(SelectedRow);
}

// Called when double clicking a row, launches shortcut as the given row
function DoubleClickRow (int Row)
{
	LaunchShortcut(SelectedRow);
}

// Called when right clicking a row, does nothing without extension
function RightClickRow (int Row, float X, float Y);


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

	// Element on top
	bAlwaysOnTop = True;
}

// Paints element onto canvas, does nothing without extension
function Paint (Canvas Canvas, float X, float Y);

// Paints column, does nothing without extension
function PaintColumn (Canvas C, UWindowGridColumn Column, float MouseX, float MouseY);


//=================
// Row Management
//=================

// Selects a given row
function SelectRow (int Row)
{
	local int CurRow;

	// Sets current row to the vertical scrollbar position plus the given row
	CurRow = VertSB.Pos + Row;

	// If row is not the selected row and current row is less than number of rows
	if ( Row != SelectedRow && CurRow < NumRows )
	{
		// Set current row as the selected row
		SelectedRow = CurRow;
	}
}

// Sorts a given column, does nothing without extension
function SortColumn (UWindowGridColumn Column);

// Resets list, does nothing without extension
function Reset();