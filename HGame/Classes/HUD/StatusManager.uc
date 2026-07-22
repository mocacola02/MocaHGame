//==========================================================================//
// StatusManager.
//
// HUD item class for managing and displaying StatusGroup item info.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class StatusManager extends HudItemManager;

//= Constants =//
const nTOTAL_WIZARD_CARDS= 101;	// Total number of wizard cards

//= General Variables =//
var int nCanvasSizeX;		// Canvas size X
var int nCanvasSizeY;		// Canvas size Y
var harry PlayerHarry;		// Ref to Harry
var StatusGroup sgList;		// Current StatusGroup list


//=========
// Events
//=========

// Called before gameplay starts
event PreBeginPlay()
{
	// Call parent behavior
	Super.PreBeginPlay();

	// Clear current StatusGroup
	sgList = None;

	// Set size to 0
	nCanvasSizeX = 0;
	nCanvasSizeY = 0;
}


//============
// Rendering
//============

// Render HUD items
function RenderHudItemManager (Canvas Canvas, bool bMenuMode, bool bFullCutMode, bool bHalfCutMode)
{
	local StatusGroup sgLoop;

	// Set canvas size to the current canvas size
	nCanvasSizeX = Canvas.SizeX;
	nCanvasSizeY = Canvas.SizeY;

	// For each StatusGroup in list, render it
	for(sgLoop = sgList; sgLoop != None; sgLoop = sgLoop.sgNext)
	{
		sgLoop.RenderHudItemManager(Canvas,bMenuMode,bFullCutMode,bHalfCutMode);
	}
}

// Returns the HUD location vector
function Vector GetHudLocation (HProp Prop)
{
	local StatusGroup sg;

	// If prop has no StatusGroup or StatusItem, log error and return (0, 0, 0)
	if ( (Prop.classStatusGroup == None) || (Prop.classStatusItem == None) )
	{
		Log("Error: StatusManager data not setup correctly for " $ string(Prop.Class));
		return vect(0.0, 0.0, 0.0);
	}

	// Get StatusGroup from prop
	sg = GetStatusGroup(Prop.classStatusGroup);

	// Return the item location
	return sg.GetItemLocation(Prop.classStatusItem,False);
}


//==================
// Pickup Handling
//==================

// Handle item pickup
function PickupItem (HProp Prop)
{
	local int nOthersInLevel;
	local Actor actorTemp;
	local StatusGroup sgUpdate;
	local StatusItem siUpdate;

	// If prop has no StatusGroup or StatusItem, do nothing and return
	if ( (Prop.classStatusGroup == None) || (Prop.classStatusItem == None) )
	{
		return;
	}

	// Get prop's StatusGroup
	sgUpdate = GetStatusGroup(Prop.classStatusGroup);

	// If we have a StatusGroup
	if ( sgUpdate != None )
	{
		// Get prop's StatusItem
		siUpdate = sgUpdate.GetStatusItem(Prop.classStatusItem);

		// If we have a StatusItem AND we should should max count AND StatusItem count is 0
		if ( (siUpdate != None) && (siUpdate.bDisplayMaxCount == True) && (siUpdate.nCount == 0) )
		{
			// Set others in level to 0
			nOthersInLevel = 0;

			// For each actor of the same class as prop, increment others in level count
			foreach AllActors(Prop.Class, actorTemp)
			{
				nOthersInLevel++;
			}

			// Set max count to the count of others in level
			siUpdate.nMaxCount = nOthersInLevel;
		}

		// Increment collected count
		sgUpdate.IncrementCount(Prop.classStatusItem, Prop.nPickupIncrement);
	}
}

// Drop off an item
function DropOffItem (HProp Prop)
{
	local StatusGroup sgUpdate;

	// If prop has no StatusGroup or StatusItem, do nothing and return
	if ( (Prop.classStatusGroup == None) || (Prop.classStatusItem == None) )
	{
		return;
	}

	// Get prop's StatusGroup
	sgUpdate = GetStatusGroup(Prop.classStatusGroup);

	// If we have a StatusGroup
	if ( sgUpdate != None )
	{
		// Increment count by the negated pickup increment of the prop, effectively decrementing count
		sgUpdate.IncrementCount(Prop.classStatusItem, -Prop.nPickupIncrement);
	}
}


//======================
// Item Count Handling
//======================

// Increments StatusGroup count by a given number
function IncrementCount (Class<StatusGroup> classGroup, Class<StatusItem> classItem, int nNum)
{
	local StatusGroup sgUpdate;
	local StatusItem siUpdate;

	// Get StatusGroup from class
	sgUpdate = GetStatusGroup(classGroup);

	// If we have a StatusGroup, increment count by nNum
	if ( sgUpdate != None )
	{
		sgUpdate.IncrementCount(classItem,nNum);
	}
}

// Sets count of a StatusItem to a given number
function SetCount (Class<StatusGroup> classGroup, Class<StatusItem> classItem, int nNum)
{
	local StatusItem siUpdate;

	// Get StatusItem from class
	siUpdate = GetStatusItem(classGroup,classItem);

	// If we have a StatusItem, set its count to nNum
	if ( siUpdate != None )
	{
		siUpdate.SetCount(nNum);
	}
}

// Increments the count potential (allowed count amount)
function IncrementCountPotential (Class<StatusGroup> classGroup, Class<StatusItem> classItem, int nNum)
{
	local StatusGroup sgUpdate;
	local StatusItem siUpdate;

	// Get StatusGroup from class
	sgUpdate = GetStatusGroup(classGroup);

	// If we have a StatusGroup, increment the count potential by nNum
	if ( sgUpdate != None )
	{
		sgUpdate.IncrementCountPotential(classItem,nNum);
	}
}

// Add a given amount of housepoints to Gryffindor's StatusItem
function AddHPointsG (int nPoints)
{
	AddHousePoints(Class'StatusItemGryffindorPts',nPoints);
}

// Returns the number of housepoints owned by Gryffindor
function int GetHPointsG()
{
	return GetStatusItem(Class'StatusGroupHousePoints',Class'StatusItemGryffindorPts').nCount;
}

// Add a given amount of housepoints to Hufflepuff's StatusItem
function AddHPointsH (int nPoints)
{
	AddHousePoints(Class'StatusItemHufflePuffPts',nPoints);
}


// Returns the number of housepoints owned by Hufflepuff
function int GetHPointsH()
{
	return GetStatusItem(Class'StatusGroupHousePoints',Class'StatusItemHufflePuffPts').nCount;
}

// Add a given amount of housepoints to Slytherin's StatusItem
function AddHPointsS (int nPoints)
{
	AddHousePoints(Class'StatusItemSlytherinPts',nPoints);
}

// Returns the number of housepoints owned by Slytherin
function int GetHPointsS()
{
	return GetStatusItem(Class'StatusGroupHousePoints',Class'StatusItemSlytherinPts').nCount;
}

// Add a given amount of housepoints to Ravenclaw's StatusItem
function AddHPointsR (int nPoints)
{
	AddHousePoints(Class'StatusItemRavenclawPts',nPoints);
}

// Returns the number of housepoints owned by Ravenclaw
function int GetHPointsR()
{
	return GetStatusItem(Class'StatusGroupHousePoints',Class'StatusItemRavenclawPts').nCount;
}

// Adds a given number of housepoints to a given StatusItem class
function AddHousePoints (Class<StatusItem> classItem, int nPoints)
{
	local StatusGroup sgHousePts;
	local StatusItem siHousePts;

	// Get target StatusGroup
	sgHousePts = GetStatusGroup(Class'StatusGroupHousePoints');

	// Increment count for given class by nPoints
	sgHousePts.IncrementCount(classItem,nPoints);

	// Get status item from class
	siHousePts = sgHousePts.GetStatusItem(classItem);

	// Get housepoint count for Gryffindor and print it
	siHousePts = sgHousePts.GetStatusItem(Class'StatusItemGryffindorPts');
	PlayerHarry.ClientMessage("Gryffindor : " $ string(siHousePts.nCount));

	// Get housepoint count for Hufflepuff and print it
	siHousePts = sgHousePts.GetStatusItem(Class'StatusItemHufflePuffPts');
	PlayerHarry.ClientMessage("Hufflepuff : " $ string(siHousePts.nCount));

	// Get housepoint count for Ravenclaw and print it
	siHousePts = sgHousePts.GetStatusItem(Class'StatusItemRavenclawPts');
	PlayerHarry.ClientMessage("Ravenclaw : " $ string(siHousePts.nCount));

	// Get housepoint count for Slytherin and print it
	siHousePts = sgHousePts.GetStatusItem(Class'StatusItemSlytherinPts');
	PlayerHarry.ClientMessage("Slytherin : " $ string(siHousePts.nCount));
}

// Add a given amount of Flobberworm Mucus to the potion ingredients group
function AddFMucus (int nCount)
{
	IncrementCount(Class'StatusGroupPotionIngr',Class'StatusItemFlobberMucus',nCount);
}

// Return the amount of Flobberworm Mucus in the potion ingredients group
function int GetFMucusCount()
{
	return GetStatusItem(Class'StatusGroupPotionIngr',Class'StatusItemFlobberMucus').nCount;
}

// Add a given amount of Wiggentree Bark to the potion ingredients group
function AddWBark (int nCount)
{
	IncrementCount(Class'StatusGroupPotionIngr',Class'StatusItemWiggenBark',nCount);
}

// Return the amount of Wiggentree Bark in the potion ingredients group
function int GetWBarkCount()
{
	return GetStatusItem(Class'StatusGroupPotionIngr',Class'StatusItemWiggenBark').nCount;
}

// Add a given amount of Bicorn Horns to the polyjuice ingredient group
function AddBicorn (int nCount)
{
	IncrementCount(Class'StatusGroupPolyIngr',Class'StatusItemBicorn',nCount);
}

// Return the amount of Bicorn Horns in the polyjuice ingredient group
function int GetBicornCount()
{
	return GetStatusItem(Class'StatusGroupPolyIngr',Class'StatusItemBicorn').nCount;
}

// Add a given amount of Boomslang Skin to the polyjuice ingredient group
function AddBoomslang (int nCount)
{
	IncrementCount(Class'StatusGroupPolyIngr',Class'StatusItemBoomslang',nCount);
}

// Return the amount of Boomslang Skin in the polyjuice ingredient group
function int GetBoomslangCount()
{
	return GetStatusItem(Class'StatusGroupPolyIngr',Class'StatusItemBoomslang').nCount;
}

// Add a given amount of Nimbus 2001s to the quidditch gear group
function int AddNimbus (int nCount)
{
	IncrementCount(Class'StatusGroupQGear',Class'StatusItemNimbus',nCount);
}

// Return the amount of Nimbus 2001s in the quidditch gear group
function int GetNimbusCount()
{
	return GetStatusItem(Class'StatusGroupQGear',Class'StatusItemNimbus').nCount;
}

// Add a given amount of armor to the quidditch gear group
function int AddQArmor (int nCount)
{
	IncrementCount(Class'StatusGroupQGear',Class'StatusItemQArmor',nCount);
}

// Return the amount of armor in the quidditch gear group
function int GetQArmorCount()
{
	return GetStatusItem(Class'StatusGroupQGear',Class'StatusItemQArmor').nCount;
}

// Add a given amount of Jellybeans to the Jellybean group
function AddBeans (int nCount)
{
	IncrementCount(Class'StatusGroupJellybeans',Class'StatusItemJellybeans',nCount);
}

// Return the amount of Jellybeans in the Jellybean group
function int GetBeanCount()
{
	return GetStatusItem(Class'StatusGroupJellybeans',Class'StatusItemJellybeans').nCount;
}

// Add a given amount of potions to the potions group
function AddPotions (int nCount)
{
	IncrementCount(Class'StatusGroupPotions',Class'StatusItemWiggenwell',nCount);
}

// Return the amount of potions in the potions group
function int GetPotionCount()
{
	return GetStatusItem(Class'StatusGroupPotions',Class'StatusItemWiggenwell').nCount;
}

// Add a given amount of health to the health group
function AddHealth (int nCount)
{
	IncrementCount(Class'StatusGroupHealth',Class'StatusItemHealth',nCount);
}

// Return the amount of health in the health group
function int GetHealthCount()
{
	return GetStatusItem(Class'StatusGroupHealth',Class'StatusItemHealth').nCount;
}

// Set the amount of health in the health group to a given amuont
function SetHealthCount (int nCount)
{
	SetCount(Class'StatusGroupHealth',Class'StatusItemHealth',nCount);
}

// Add a given amount to the count potential of the health item
function AddHealthPotential (int nCount)
{
	IncrementCountPotential(Class'StatusGroupHealth',Class'StatusItemHealth',nCount);
}

// Returns the potential count of the health item
function int GetHealthPotentialCount()
{
	return GetStatusItem(Class'StatusGroupHealth',Class'StatusItemHealth').nCurrCountPotential;
}

// Adds a given amount of count potential to lock #1 in the locks group
function AddLock1 (int nCount)
{
	IncrementCountPotential(Class'StatusGroupLocks',Class'StatusItemLock1',nCount);
}

// Returns the amount of lock #1 in the locks group
function int GetLock1Count()
{
	return GetStatusItem(Class'StatusGroupLocks',Class'StatusItemLock1').nCount;
}

// Adds a given amount of count potential to lock #2 in the locks group
function AddLock2 (int nCount)
{
	IncrementCountPotential(Class'StatusGroupLocks',Class'StatusItemLock2',nCount);
}

// Returns the amount of lock #2 in the locks group
function int GetLock2Count()
{
	return GetStatusItem(Class'StatusGroupLocks',Class'StatusItemLock2').nCount;
}

// Adds a given amount of count potential to lock #3 in the locks group
function AddLock3 (int nCount)
{
	IncrementCountPotential(Class'StatusGroupLocks',Class'StatusItemLock3',nCount);
}

// Returns the amount of lock #3 in the locks group
function int GetLock3Count()
{
	return GetStatusItem(Class'StatusGroupLocks',Class'StatusItemLock3').nCount;
}

// Adds a given amount of count potential to lock #4 in the locks group
function AddLock4 (int nCount)
{
	IncrementCountPotential(Class'StatusGroupLocks',Class'StatusItemLock4',nCount);
}

// Returns the amount of lock #4 in the locks group
function int GetLock4Count()
{
	return GetStatusItem(Class'StatusGroupLocks',Class'StatusItemLock4').nCount;
}

// Gives a card of the given ID to Harry
function GiveCardToHarry (int nCardId)
{
	GiveCard(nCardId,True);
}

// Gives a card of the given ID to vendors
function GiveCardToVendors (int nCardId)
{
	GiveCard(nCardId,False);
}

// Gives a card of the given ID to Harry if bHarry == True, else gives to vendors
function GiveCard (int nCardId, bool bHarry)
{
	local StatusItemWizardCards siWC;
	local Class<Actor> classWC;
	local string strDebug;

	// If giving to Harry, set our debug string to mention him
	if ( bHarry )
	{
		strDebug = "Harry has ";
	}
	// Otherwise, mention vendors
	else
	{
		strDebug = "Vendors have ";
	}

	// Get the Wizard Cards status item
	siWC = StatusItemWizardCards(GetStatusItem(Class'StatusGroupWizardCards',Class'StatusItemBronzeCards'));
	
	// Get card's class from the card ID
	classWC = siWC.GetCardClassFromId(nCardId);

	// If we have a valid class
	if ( classWC != None )
	{
		// If card is a bronze card, add it to debug string and get Bronze Cards StatusItem
		if ( ClassIsChildOf(classWC,Class'BronzeCards') )
		{
			strDebug = strDebug $ "bronze card ";
			siWC = StatusItemWizardCards(GetStatusItem(Class'StatusGroupWizardCards',Class'StatusItemBronzeCards'));
		}
		// Otherwise, if card is a silver card, add it to debug string and get Silver Cards StatusItem
		else if ( ClassIsChildOf(classWC,Class'SilverCards') )
		{
			strDebug = strDebug $ "silver card ";
			siWC = StatusItemWizardCards(GetStatusItem(Class'StatusGroupWizardCards',Class'StatusItemSilverCards'));
		}
		// Otherwise, if card is a gold card, add it to debug string and get Gold Cards StatusItem
		else if ( ClassIsChildOf(classWC,Class'Goldcards') )
		{
			strDebug = strDebug $ "gold card ";
			siWC = StatusItemWizardCards(GetStatusItem(Class'StatusGroupWizardCards',Class'StatusItemGoldCards'));
		}

		// Add card ID to the debug string
		strDebug = strDebug $ string(nCardId);

		// Print the debug string
		PlayerHarry.ClientMessage(strDebug);

		// If giving to Harry, set card owner as Harry
		if ( bHarry )
		{
			siWC.SetCardOwner(nCardId,siWC.ECardOwner.CardOwner_Harry);
		}
		// Otherwise, set card owner as vendor
		else
		{
			siWC.SetCardOwner(nCardId,siWC.ECardOwner.CardOwner_Vendor);
		}
	}
}

// Gives all Wizard Cards to Harry
function GiveAllCardsToHarry()
{
	local StatusItemWizardCards siBronzeCards;
	local StatusItemWizardCards siSilverCards;
	local StatusItemWizardCards siGoldCards;
	local Class<Actor> classWC;
	local int I;

	// Get all three Wizard Card StatusItems
	siBronzeCards = StatusItemWizardCards(GetStatusItem(Class'StatusGroupWizardCards',Class'StatusItemBronzeCards'));
	siSilverCards = StatusItemWizardCards(GetStatusItem(Class'StatusGroupWizardCards',Class'StatusItemSilverCards'));
	siGoldCards = StatusItemWizardCards(GetStatusItem(Class'StatusGroupWizardCards',Class'StatusItemGoldCards'));

	// For each wizard card
	for(I = 1; I <= nTOTAL_WIZARD_CARDS; I++)
	{
		// Get card class from card ID
		classWC = siBronzeCards.GetCardClassFromId(I);

		// If class is not Harry's card
		if ( classWC != Class'WCPotter' )
		{
			// If card is a bronze card, set the card's owner to Harry in the bronze group
			if ( ClassIsChildOf(classWC,Class'BronzeCards') )
			{
				siBronzeCards.SetCardOwner(I,siBronzeCards.ECardOwner.CardOwner_Harry);
			}
			// Otherwise, if card is a silver card, set the card's owner to Harry in the silver group
			else if ( ClassIsChildOf(classWC,Class'SilverCards') )
			{
				siSilverCards.SetCardOwner(I,siSilverCards.ECardOwner.CardOwner_Harry);
			}
			// Otherwise, if card is a gold card, set the card's owner to Harry in the gold group
			else if ( ClassIsChildOf(classWC,Class'Goldcards') )
			{
				siGoldCards.SetCardOwner(I,siGoldCards.ECardOwner.CardOwner_Harry);
			}
		}
	}

	// Set Harry's card owner to Harry
	siGoldCards.SetCardOwner(Class'WCPotter'.Default.Id,siGoldCards.ECardOwner.CardOwner_Harry);

	// Unlock all locks
	GetStatusItem(Class'StatusGroupLocks',Class'StatusItemLock1').SetCount(1);
	GetStatusItem(Class'StatusGroupLocks',Class'StatusItemLock2').SetCount(1);
	GetStatusItem(Class'StatusGroupLocks',Class'StatusItemLock3').SetCount(1);
	GetStatusItem(Class'StatusGroupLocks',Class'StatusItemLock4').SetCount(1);
}


//================
// Misc. Helpers
//================

// Returns a StatusItem reference from a StatusGroup and StatusItem class
function StatusItem GetStatusItem (Class<StatusGroup> classGroup, Class<StatusItem> classItem)
{
	local StatusGroup sgFound;

	// Get status group from class
	sgFound = GetStatusGroup(classGroup);

	// If we found the status group, return the status item from class
	if ( sgFound != None )
	{
		return sgFound.GetStatusItem(classItem);
	}
	// Otherwise, log an error
	else
	{
		Log("Error: could not create or find StatusGroup " $ string(classGroup));
	}
}

// Returns a StatusGroup reference from a StatusGroup class
function StatusGroup GetStatusGroup (Class<StatusGroup> classGroup)
{
	local StatusGroup sgLoop;

	// If we don't have a StatusGroup list
	if ( sgList == None )
	{
		// Spawn the group
		sgList = Spawn(classGroup);

		// Set the next group to none
		sgList.sgNext = None;

		// Set group's manager parent to self
		sgList.smParent = self;

		// Return new list
		return sgList;
	}

	// For groups in group list
	for(sgLoop = sgList; sgLoop != None; sgLoop = sgLoop.sgNext)
	{
		// If group's class is the given group class, return this group
		if ( sgLoop.Class == classGroup )
		{
			return sgLoop;
		}

		// If we've reached the end without finding the group
		if ( sgLoop.sgNext == None )
		{
			// Spawn the group as the next group
			sgLoop.sgNext = Spawn(classGroup);

			// Set the new group's manager parent to self
			sgLoop.sgNext.smParent = self;

			// Return new group
			return sgLoop.sgNext;
		}
	}

	// Log an error
	Log("Error: StatusManager::GetStatusGroup- should not get to here");

	// Return none
	return None;
}

// Create startup StatusItems
function CreateStartupItems()
{
	GetStatusItem(Class'StatusGroupHealth',		Class'StatusItemHealth'			);
	GetStatusItem(Class'StatusGroupHousePoints',Class'StatusItemGryffindorPts'	);
	GetStatusItem(Class'StatusGroupHousePoints',Class'StatusItemRavenclawPts'	);
	GetStatusItem(Class'StatusGroupHousePoints',Class'StatusItemHufflePuffPts'	);
	GetStatusItem(Class'StatusGroupHousePoints',Class'StatusItemSlytherinPts'	);
	GetStatusItem(Class'StatusGroupJellybeans',	Class'StatusItemJellybeans'		);
	GetStatusItem(Class'StatusGroupWizardCards',Class'StatusItemBronzeCards'	);
	GetStatusItem(Class'StatusGroupWizardCards',Class'StatusItemSilverCards'	);
	GetStatusItem(Class'StatusGroupWizardCards',Class'StatusItemGoldCards'		);
}

// Shows card data
function ShowCardData()
{
	local StatusGroupWizardCards sgWC;

	// Get Wizard Card group
	sgWC = StatusGroupWizardCards(GetStatusGroup(Class'StatusGroupWizardCards'));

	// Show group's card data
	sgWC.ShowCardData();
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bHidden=True
}