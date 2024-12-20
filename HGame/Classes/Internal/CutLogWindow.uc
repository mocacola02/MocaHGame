//================================================================================
// CutLogWindow.
//================================================================================

class CutLogWindow extends UWindowFramedWindow;

// Metallicafan212:	Quick math function
function float GetHeightScale()
{
	return Class'M212HScale'.Static.UWindowGetHeightScale(Root);//return (4.0 / 3.0) / (Root.RealWidth / Root.RealHeight);
}

function Created()
{
    Super.Created();
    //bSizable = False;
    //bStatusBar = False;
    bLeaveOnscreen = True;
	bSizable = True;
	bStatusBar = True;

	SetDimensions();
}

function SetDimensions()
{
	if (ParentWindow.WinWidth < 500)
	{
		SetSize(200, 150);
	} 
	else 
	{
		SetSize(410 * GetHeightScale(), 310 * GetHeightScale());
	}
	WinLeft = ParentWindow.WinWidth/2 - WinWidth/2;
	WinTop 	= ParentWindow.WinHeight/2 - WinHeight/2;
}

defaultproperties
{
    ClientClass=Class'CutLogClientWindow'

    WindowTitle="CutScene Log"
}
