//==========================================================================//
// ShortCutClientWindow.
//
// Client window class that attaches to ShortCutWindow.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class ShortCutClientWindow extends UWindowDialogClientWindow;

var ShortCutBrowser browser;				// Reference to ShortCutBrowser
var float OldParentWidth, OldParentHeight;	// Old parent width and height


//==========
// Display
//==========

// Called when created
function Created()
{
	local string curToken;
	local int I;

	// Call parent behavior
	Super.Created();

	// Save old parent width and height
	OldParentWidth 	= ParentWindow.WinWidth;
	OldParentHeight = ParentWindow.WinHeight;

	// Set dimensions
	SetDimensions();

	// Set if this accepts focus
	SetAcceptsFocus();
	
	// Create ShortCutBrowser
	browser = ShortCutBrowser(CreateWindow(Class'ShortCutBrowser', 0.0, 0.0, WinWidth, WinHeight));

	// Add levels, bookmarks, sounds, and string database lists
	browser.AddList("Levels", 			ShortCutListLevels(				CreateWindow(Class'ShortCutListLevels', 		0.0, 16.0, WinWidth, WinHeight - 12)));
	browser.AddList("Bookmarks", 		ShortCutListBookmarks(			CreateWindow(Class'ShortCutListBookmarks',		0.0, 16.0, WinWidth, WinHeight - 12)));
	browser.AddList("Sounds",			ShortCutListSounds(				CreateWindow(Class'ShortCutListSounds',			0.0, 16.0, WinWidth, WinHeight - 12)));
	browser.AddList("String Database",	M212ShortCutListDatabase(		CreateWindow(Class'M212ShortCutListDatabase',	0.0, 16.0, WinWidth, WinHeight - 12)));
	
	// Init I value
	I = 0;

	// Get current token
	curToken = GetPlayerOwner().GetGameStateMasterListToken(0);
	
	// While we have a valid token
	while ( curToken != "" )
	{
		// Add game state to browser
		browser.AddGameState(curToken);

		// Get next token
		curToken = GetPlayerOwner().GetGameStateMasterListToken( ++I );
	}

	// Update the game state selection
	browser.UpdateCurrentGameStateSelection();
}

// Called when resized
function Resized()
{
	// Call parent behavior
	Super.Resized();

	// Set browser width and height to current width and height
	browser.WinWidth  = WinWidth;
	browser.WinHeight = WinHeight;

	// Resize browser
	browser.Resized();
}

// Sets window dimensions
function SetDimensions()
{
	// If parent window width is less than 500, set size to 200 by 150 units
	if (ParentWindow.WinWidth < 500)
	{
		SetSize(200, 150);
	}
	// Otherwise, set size to 410 units by 310 units, adjusted by height scale
	else 
	{
		SetSize(410 * GetHeightScale(), 310 * GetHeightScale());
	}

	// Calculate window left and top dimensions
	WinLeft = ParentWindow.WinWidth/2 - WinWidth/2;
	WinTop 	= ParentWindow.WinHeight/2 - WinHeight/2;
}

// Paints element onto canvas
function Paint (Canvas Canvas, float X, float Y)
{
	// Call parent behavior
	Super.Paint(Canvas,X,Y);

	// Paint browser
	browser.Paint(Canvas,X,Y);
}


// Shows the window
function ShowWindow()
{
	// Call parent behavior
	Super.ShowWindow();

	// If parent window width or height does not equal the old parent width or height
	if( ParentWindow.WinWidth != OldParentWidth || ParentWindow.WinHeight != OldParentHeight )
	{
		// Set dimensions
		SetDimensions();

		// Set old parent width and height to current parent width and height
		OldParentWidth = ParentWindow.WinWidth;
		OldParentHeight = ParentWindow.WinHeight;
	}
}


// Called when activated
function Activated()
{
	// If we have a browser, activate it
	if ( browser != None )
	{
		browser.Activated();
	}
}


//===================
// Helper Functions
//===================

// Metallicafan212:	Quick math function
function float GetHeightScale()
{
	return Class'M212HScale'.Static.UWindowGetHeightScale(Root);//return (4.0 / 3.0) / (Root.RealWidth / Root.RealHeight);
}