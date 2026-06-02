//==========================================================================//
// ShortCutWindow.
//
// ShortCut window class, holds the client window.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class ShortCutWindow extends UWindowFramedWindow;

var float OldParentWidth, OldParentHeight;	// Stored old parent width & height values


//=========
// Events
//=========

// Called after being created
event BeginPlay()
{
	// Call parent behavior
	Super.BeginPlay();

	// Set window title to Map Selector
	WindowTitle = "Map selector";

	// Set client window class to ShortCutClientWindow
	ClientClass = Class'ShortCutClientWindow';

	// Set if window accepts focus
	SetAcceptsFocus();

	// Set to not be transient
	bTransient = False;

	// Set UWindow as active
	bUWindowActive = True;

	// Set to leave on screen when UWindow is inactive
	bLeaveOnscreen = True;

	// Set to accept hotkeys
	bAcceptsHotKeys = True;

	// Set to be resizable
	bSizable = True;
}


//==========
// Display
//==========

// Called when created
function Created()
{
	// Call parent behavior
	Super.Created();
	
	// Set to be resizable
	bSizable = True;

	// Set to have status bar
	bStatusBar = True;

	// Set to leave on screen when UWindow is inactive
	bLeaveOnScreen = True;

	// Set old parent width & height to current parent width & height
	OldParentWidth = ParentWindow.WinWidth;
	OldParentHeight = ParentWindow.WinHeight;

	// Set dimensions
	SetDimensions();

	// Set if window accepts focus
	SetAcceptsFocus();
}

// Shows the window
function ShowWindow()
{
	// Call parent behavior
	Super.ShowWindow();

	// If parent window width or height does not equal old width or height
	if( ParentWindow.WinWidth != OldParentWidth || ParentWindow.WinHeight != OldParentHeight )
	{
		// Set dimensions
		SetDimensions();

		// Set old width & height to current width & height
		OldParentWidth = ParentWindow.WinWidth;
		OldParentHeight = ParentWindow.WinHeight;
	}
}

// Called when closed
function Close (optional bool bByParent)
{
	// Call parent behavior
	Super.Close(bByParent);

	// Set UWindow as inactive
	bUWindowActive = False;
}

// Called when activated
function Activated()
{
	local UWindowWindow Prev;
	local UWindowWindow Child;

	// Activate all children
	for( Child = LastChildWindow; Child != None; Child = Prev )
	{
		Prev = Child.PrevSiblingWindow;
		Child.Activated();
	}

	// Set UWindow as active
	bUWindowActive = True;
}

// Sets window dimensions
function SetDimensions()
{
	// If parent window's width is less than 500, set size to 200 by 150 units
	if (ParentWindow.WinWidth < 500)
	{
		SetSize(200, 150);
	}
	// Otherwise, set size to 410 by 310 units, accountin for height scale
	else 
	{
		SetSize(410 * GetHeightScale(), 310 * GetHeightScale());
	}

	// Set window left and top dimensions
	WinLeft = ParentWindow.WinWidth/2 - WinWidth/2;
	WinTop 	= ParentWindow.WinHeight/2 - WinHeight/2;
}

// Metallicafan212:	Quick math function
function float GetHeightScale()
{
	return Class'M212HScale'.Static.UWindowGetHeightScale(Root);//return (4.0 / 3.0) / (Root.RealWidth / Root.RealHeight);
}