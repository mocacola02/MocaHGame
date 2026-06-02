//==========================================================================//
// HallwayRunBoss.
//
// Boss type used for hallway runs.
// 
// Formatting, commenting, & documentation by Moca unless stated otherwise.
//==========================================================================//
class HallwayRunBoss extends baseBoss;


//=========
// Events
//=========

// Called on trigger, tells Harry to stop the boss encounter
event Trigger (Actor Other, Pawn EventInstigator)
{
	PlayerHarry.StopBossEncounter();
}