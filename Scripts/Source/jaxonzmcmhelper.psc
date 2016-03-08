Scriptname JaxonzMCMHelper extends SKI_ConfigBase
{Utility to make SkyUI MCM menu syntax a little easier.}
;This class provides single line functions to define and handle common Skyrim MCM menu functions.
;It makes laying out MCM menus much easier.

;INSTRUCTIONS
;1. Create a new script for your MCM menu extending this script.
;	Example: Scriptname MyModMCM extends JaxonzMCMHelperChild
;2. Use the the DefineMCM... functions in your OnPageReset event
;	The arguments for each DefineMCM... function provide all of the information needed for all MCM functionality

;Use of the DefineMCM...Global functions is recommended and easiest, because GlobalVariables are updated automatically without any extra work from you.

;Use of non-global functions requires use of ModEvent callbacks.
;	Example:
;		in OnPageReset...
;			RegisterForModEvent("MyModTextOptionClick","OnTextOptionClick")	;make sure your ModEvent name is unique!
;			DefineMCMTextOption("Text option", "text value", 0, "some helpful text about my text\nThis one uses a ModEvent callback", "MyModTextOptionClick")
;		MCMhelper will send MyModTextOptionClick when the option is clicked with current values as parameters

;If you need to do something particularly special, you can still use all normal MCM functions and events.

;CAVEATS
;Papyrus array size limits means this won't work with pages that have more than 128 elements (I think this is a SkyUI limitation as well.)
;REQUIRES SKSE 1.7.2 for toggle string, menu, and paragraph functions
;If a child implements MCM events, they must call Parent.eventname(args....) to pass the call up to this class.

import Debug
import JaxonzStringUtil
import StringUtil
import Math

;JaxonzMCMHelperChild Property scrChild Auto

int[] iOptionTypes
int kToggle = 1
int kToggleGlobal = -1
int kSlider = 2
int kSliderGlobal = -2
int kText = 3
int kMenu = 4
int kKeyMap = 5
int kKeyMapGlobal = -5
int kColor = 6
int kTextToggle = 7
int kToggleGlobalBitmask = 8

string[] sLabels
string[] sHelpInfos
GlobalVariable[] gGlobalVars
bool[] bBoolVals
float[] fFloatVals
float[] fSliderMaxs
float[] fSliderMins
float[] fSliderDefaults
float[] fSliderIntervals
string[] sSliderFormats
string[] sKeyConflicts
int[] iIntVals
string[] sStringVals
string[] sModEvents
int[] iBitMasks

Event OnInit()
	RegisterForSingleUpdate(1.0)
	InitArrays()
	Parent.OnInit()
EndEvent

Event OnUpdate()
	RegisterForModEvent("SKICP_pageSelected", "OnPageSelect")	;mod event registration does not endure game reload
	RegisterForModEvent("SKICP_configManagerReady", "OnConfigManagerReadyMCMHelper")
	RegisterForSingleUpdate(30.0)
EndEvent

event OnConfigManagerReadyMCMHelper(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	;eliminates the need to have a player ReferenceAlias with ski_playerloadgamealias to get MCM menus to show
	OnGameReload()
EndEvent

int Function DefineMCMToggleOption(string sTextLabel, bool bInitialState = false, int iFlags = 0, String sHelpInfo = "", string sModEvent = "") 
;A single line of code that sets up a menu item for toggling value of a GlobalVariable without all the event handling stuff
;just add to OnPageReset area
	int iOID = AddToggleOption(sTextLabel, bInitialState, iFlags) % 128	;- iOIDOffset
;Trace("JaxonzMCMHelper::DefineMCMToggleOption, iOID:" + iOID + ", iOID % 128:" + iOID % 128 + ", iOID - iOIDOffset:" + (iOID - iOIDOffset))
	sLabels[iOID] = sTextLabel
	sHelpInfos[iOID] = sHelpInfo
	bBoolVals[iOID] = bInitialState
	iOptionTypes[iOID] = kToggle
	sModEvents[iOID] = sModEvent
	return iOID
EndFunction

int Function DefineMCMToggleOptionGlobal(string sTextLabel, GlobalVariable gToggleVar, int iFlags = 0, String sHelpInfo = "", string sModEvent = "") 
;A single line of code that sets up a menu item for toggling value of a GlobalVariable without all the event handling stuff
;just add to OnPageReset area
	int iOID = DefineMCMToggleOption(sTextLabel, gToggleVar.GetValueInt() as bool, iFlags, sHelpInfo, sModEvent) % 128	;
	gGlobalVars[iOID] = gToggleVar
	iOptionTypes[iOID] = kToggle	;Global
	return iOID
EndFunction

int Function DefineMCMToggleOptionGlobalBitmask(string sTextLabel, GlobalVariable gToggleVar, int iBitmask, int iFlags = 0, String sHelpInfo = "", string sModEvent = "") 
;A single line of code that sets up a menu item for toggling value of a bitmask value within a GlobalVariable without all the event handling stuff
;just add to OnPageReset area
;NOTE: DUE TO FLOAT ROUNDING OF GlobalVariables, THIS FUNCTION ONLY SUPPORTS BITMASKS UP TO 0x100000 (= 21 DIFFERENT BIT VALUES)
;Trace("DefineMCMToggleOptionGlobalBitmask sTextLabel:" + sTextLabel + ", gToggleVar.GetValue():" + gToggleVar.GetValue() + ", iBitmask:" + iBitmask)
	bool bVal = LogicalAnd(gToggleVar.GetValue() as int, iBitMask) as bool
	int iOID = DefineMCMToggleOption(sTextLabel, bVal, iFlags, sHelpInfo, sModEvent) % 128	;
	gGlobalVars[iOID] = gToggleVar
	bBoolVals[iOID] = bVal
	iOptionTypes[iOID] = kToggleGlobalBitmask
	iBitmasks[iOID] = iBitmask
	return iOID
EndFunction

int Function DefineMCMSliderOption(string sTextLabel, float fValue, float fDefault, float fMin, float fMax, float fInterval, String sHelpInfo = "", string formatString = "{0}", int flags = 0, string sModEvent = "") 
	int iOID = AddSliderOption(sTextLabel, fValue, formatString, flags) % 128	; - iOIDOffset
;Trace("JaxonzMCMHelper::DefineMCMSliderOption, iOID:" + iOID)
	sLabels[iOID] = sTextLabel
	sHelpInfos[iOID] = sHelpInfo
	fFloatVals[iOID] = fValue
	fSliderMaxs[iOID] = fMax
	fSliderMins[iOID] = fMin
	fSliderDefaults[iOID] = fDefault
	fSliderIntervals[iOID] = fInterval
	iOptionTypes[iOID] = kSlider
	sSliderFormats[iOID] = formatString
	sModEvents[iOID] = sModEvent
	return iOID
EndFunction

int Function DefineMCMSliderOptionGlobal(string sTextLabel, GlobalVariable gSliderVar, float fDefault, float fMin, float fMax, float fInterval, String sHelpInfo = "", string formatString = "{0}", int flags = 0, string sModEvent = "")
	int iOID = DefineMCMSliderOption(sTextLabel, gSliderVar.GetValue(), fDefault, fMin, fMax, fInterval, sHelpInfo, formatString, flags, sModEvent) % 128	; 
	gGlobalVars[iOID] = gSliderVar
	iOptionTypes[iOID] = kSliderGlobal
	return iOID
EndFunction

int Function DefineMCMKeymapOption(string sTextLabel, int iKeyCode, int iFlags = 0, int iDefault, String sHelpInfo = "", string sKeyConflict = "", string sModEvent = "") 
	int iOID = AddKeyMapOption(sTextLabel, iKeyCode, iFlags) % 128	; - iOIDOffset
;Trace("JaxonzMCMHelper::DefineMCMKeymapOption, iOID:" + iOID)
	iOptionTypes[iOID] = kKeyMap
	sLabels[iOID] = sTextLabel
	sHelpInfos[iOID] = sHelpInfo
	sKeyConflicts[iOID] = sKeyConflict
	iIntVals[iOID] = iKeyCode
	fSliderDefaults[iOID] = iDefault as Float
	sModEvents[iOID] = sModEvent
	return iOID
EndFunction

int Function DefineMCMKeymapOptionGlobal(string sTextLabel, GlobalVariable gGlobalVar, int iFlags = 0, int iDefault = -1, String sHelpInfo = "", string sKeyConflict = "", string sModEvent = "") 
	int iOID = DefineMCMKeymapOption(sTextLabel, gGlobalVar.GetValueInt(), iFlags, iDefault, sHelpInfo, sKeyConflict, sModEvent) % 128	; 
	gGlobalVars[iOID] = gGlobalVar
	iOptionTypes[iOID] = kKeyMapGlobal
	return iOID
EndFunction

int Function DefineMCMTextOption(string sTextLabel, String sValue, int iFlags = 0, String sHelpInfo = "", string sModEvent = "") 
	int iOID = AddTextOption(sTextLabel, sValue, iFlags) % 128	; - iOIDOffset
;Trace("JaxonzMCMHelper::DefineMCMTextOption, iOID:" + iOID)
	iOptionTypes[iOID] = kText
	sLabels[iOID] = sTextLabel
	sHelpInfos[iOID] = sHelpInfo
	sStringVals[iOID] = sValue
	sModEvents[iOID] = sModEvent
	return iOID
EndFunction

int property		OPTION_FLAG_AS_TEXTTOGGLE	= 0x64 autoReadonly	;show a menu alternatively as a toggling value text option

int Function DefineMCMMenuOption(string sTextLabel, String sValuesCSV, int iSelected = 0, int iDefault = 0, int iFlags = 0, String sHelpInfo = "", string sModEvent = "")
	int iOID
	string[] sValues
	sValues = ParseCSVtoArray(sValuesCSV)
	if Math.LogicalAnd(iFlags, OPTION_FLAG_AS_TEXTTOGGLE)
		iOID = AddTextOption(sTextLabel, sValues[iSelected], iFlags) % 128	; - iOIDOffset
		iOptionTypes[iOID] = kTextToggle
	Else
		iOID = AddMenuOption(sTextLabel, sValues[iSelected], iFlags) % 128	; - iOIDOffset
		iOptionTypes[iOID] = kMenu
		SetMenuOptionValue(iOID, sValues[iSelected])
	EndIf
;Trace("JaxonzMCMHelper::DefineMCMMenuOption, iOID:" + iOID)
	iIntVals[iOID] = iSelected
	sLabels[iOID] = sTextLabel
	sHelpInfos[iOID] = sHelpInfo
	sStringVals[iOID] = sValuesCSV
	fSliderDefaults[iOID] = iDefault as float
	sModEvents[iOID] = sModEvent
	return iOID
EndFunction

int Function DefineMCMMenuOptionGlobal(string sTextLabel, String sValuesCSV, GlobalVariable giSelected, int iDefault = 0, int iFlags = 0, String sHelpInfo = "", string sModEvent = "")
	int iSelected  = giSelected.GetValue() as Int
	int iOID = DefineMCMMenuOption(sTextLabel, sValuesCSV, iSelected, iDefault, iFlags, sHelpInfo, sModEvent)
	gGlobalVars[iOID] = giSelected
	return iOID
EndFunction

Function DefineMCMParagraph(string sText, int flags = 0x1)	;disabled type text by default
;display a paragraph of text, parsing for long lines and newlines
;Trace("JaxonzMCMHelper::DefineMCMParagraph, sText:" + sText)
	int iMaxLength = 47
	int i = 0
	int iFound	;used for location of found character
	While GetLength(sText) > iMaxLength
		iFound = Find(sText, "\n")
		if (iFound < iMaxLength) && (iFound	!= -1)	;if there's a newline character shorter than max line length
			AddTextOption(SubString(sText, 0, iFound), "", flags)
			sText = SubString(sText, iFound + 1)	;shorten the text string as we go
		Else
			iFound = iMaxLength
			While (GetNthChar(sText, iFound) != " ") || (iFound < 0)	;find the furthest space character starting from max line length and working backwards
				iFound -= 1
			EndWhile
			if iFound < 0	;just in case there's no space at all, break the line at max line length
				iFound = iMaxLength
			EndIf
			AddTextOption(SubString(sText, 0, iFound), "", flags)
			sText = SubString(sText, iFound + 1)	;shorten the text string as we go
		EndIf
	EndWhile
	AddTextOption(sText, "", flags)	;send the last line
;Trace("JaxonzMCMHelper::DefineMCMParagraph, ending")
EndFunction

int Function DefineMCMHelpTopic(string sTopic, string sHelpInfo = "")
;simplified call to display a string of text with topic info
	return DefineMCMTextOption(sTopic, "", 0, sHelpInfo)
EndFunction

bool Function GetMCMValueBool (string sTextLabel)
;return the current state for a toggle by its label
	return bBoolVals[GetMCMiOID(sTextLabel)]
EndFunction

int Function GetMCMValueInt (string sTextLabel)
	return iIntVals[GetMCMiOID(sTextLabel)]
EndFunction

float Function GetMCMValueFloat (string sTextLabel)
	return fFloatVals[GetMCMiOID(sTextLabel)]
EndFunction

string Function GetMCMValueString (string sTextLabel)
	int iOID = GetMCMiOID(sTextLabel)
	if (iOptionTypes[iOID] == kMenu) || (iOptionTypes[iOID] == kTextToggle)
		string[] sValues
		sValues = ParseCSVtoArray(sStringVals[iOID])
		return sValues[iIntVals[iOID]]
	Else
		return sStringVals[iOID]
	EndIf
EndFunction

int Function GetMCMiOID (string sTextLabel)
	int iOID = 0
	While iOID < 128	;sLabels.Length
		if sLabels[iOID] == sTextLabel
			return iOID
		EndIf
		iOID += 1
	EndWhile
	return 0
EndFunction

;MCM EVENTS
;if child uses any of these events, they should call Parent.eventname(args,...) as part of their function or the event will be masked

Event OnOptionSelect(int iMCMOID)
;Trace("JaxonzMCMHelper::OnOptionSelect, iOID:" + iOID + ", iOID % 128:" + iOID % 128 + ", iOID - iOIDOffset:" + (iOID - iOIDOffset))
	int iOID = iMCMOID  % 128	;-= iOIDOffset
;Trace("JaxonzMCMHelper::OnOptionSelect, iOID:" + iOID)	; + ", iOptionTypes[iOID]:" + iOptionTypes[iOID] + ", iOIDOffset:" + iOIDOffset)
	if iOptionTypes[iOID] == kTextToggle
		string[] sValues
		sValues = ParseCSVtoArray(sStringVals[iOID])
		iIntVals[iOID] = (iIntVals[iOID] + 1) % sValues.Length
		if gGlobalVars[iOID]
			gGlobalVars[iOID].SetValue(iIntVals[iOID] as float)
		EndIf		
		SetTextOptionValue(iMCMOID, sValues[iIntVals[iOID]])
;	ElseIf iOptionTypes[iOID] == kText
;		;do nothing
	ElseIf iOptionTypes[iOID] == kToggle
		bBoolVals[iOID] = !bBoolVals[iOID]
		SetToggleOptionValue(iMCMOID, bBoolVals[iOID])		
		if gGlobalVars[iOID]
			gGlobalVars[iOID].SetValue(bBoolVals[iOID] as float)
		EndIf
	ElseIf iOptionTypes[iOID] == kToggleGlobalBitmask
		bBoolVals[iOID] = !bBoolVals[iOID]
		SetToggleOptionValue(iMCMOID, bBoolVals[iOID])		
		gGlobalVars[iOID].SetValue(logicalOr(logicalAnd(gGlobalVars[iOID].GetValueInt(), logicalNot(iBitMasks[iOID])), (iBitMasks[iOID] * (bBoolVals[iOID] as int))) as float)
;Trace("JaxonzMCMHelper::OnOptionSelect kGlobalBitmask iOID:" + iOID + ", sLabels[iOID]:" + sLabels[iOID] + ", bBoolVals[iOID]:" + bBoolVals[iOID] + ", gGlobalVars[iOID].GetValueInt():" + gGlobalVars[iOID].GetValueInt() + ", iBitmasks[iOID]:" + iBitmasks[iOID])
	EndIf
;	scrChild.OnOptionSelect(iOID + iOIDOffset)
	DispatchModEvent(iOID)
endEvent

event OnOptionHighlight(int iOID)
	iOID = iOID  % 128	; -= iOIDOffset
;Trace("JaxonzMCMHelper::OnOptionHighlight, iOID:" + iOID)
	SetInfoText(sHelpInfos[iOID])
endEvent

Event OnOptionSliderOpen(int iOID)
	iOID = iOID  % 128	; -= iOIDOffset
;Trace("JaxonzMCMHelper::OnOptionSliderOpen, iOID:" + iOID)
    SetSliderDialogStartValue(fFloatVals[iOID])
    SetSliderDialogDefaultValue(fSliderDefaults[iOID])
    SetSliderDialogRange(fSliderMins[iOID], fSliderMaxs[iOID])
    SetSliderDialogInterval(fSliderIntervals[iOID])
EndEvent

Event OnOptionSliderAccept(int iMCMOID, float value)
	int iOID = iMCMOID  % 128	; -= iOIDOffset
;Trace("JaxonzMCMHelper::OnOptionSliderAccept iOID:" + iOID + ", value:" + value)
	fFloatVals[iOID] = value
	if gGlobalVars[iOID]
		gGlobalVars[iOID].SetValue(value)
	EndIf
	SetSliderOptionValue(iMCMOID, value, sSliderFormats[iOID])
	DispatchModEvent(iOID)
EndEvent

Event OnOptionDefault(int iMCMOID)
	int iOID = iMCMOID  % 128	; -= iOIDOffset
;Trace("JaxonzMCMHelper::OnOptionDefault, iOID:" + iOID)
	if iOptionTypes[iOID] == kSlider
		OnOptionSliderAccept(iMCMOID, fSliderDefaults[iOID])
	ElseIf iOptionTypes[iOID] == kKeyMap || iOptionTypes[iOID] == kKeyMapGlobal
		OnOptionKeyMapChange(iMCMOID, fSliderDefaults[iOID] as int, "", "")
	EndIf
EndEvent

event OnOptionKeyMapChange(int iMCMOID, int KeyCode, string conflictControl, string conflictName)
	int iOID = iMCMOID  % 128	; -= iOIDOffset
;Trace("JaxonzMCMHelper::OnOptionKeyMapChange iOID:" + iOID + ", KeyCode:" + KeyCode)
    if (conflictControl != "") && !ShowMessage("This key is already mapped to:\n\"" + conflictControl + "\"\n(" + conflictName + ")\n\nAre you sure you want to continue?", true, "Yes", "No")
    	;if conflict avoided
    Else
    	iIntVals[iOID] = KeyCode
		SetKeyMapOptionValue(iMCMOID, KeyCode)
		if gGlobalVars[iOID]
			gGlobalVars[iOID].SetValue(KeyCode)
		EndIf
		DispatchModEvent(iOID)
    endIf
endEvent

Event OnOptionMenuOpen(int iOID)
	iOID = iOID  % 128	; -= iOIDOffset
;Trace("JaxonzMCMHelper::OnOptionMenuOpen, iOID:" + iOID)
	SetMenuDialogOptions(ParseCSVtoArray(sStringVals[iOID]))
	SetMenuDialogStartIndex(iIntVals[iOID])
	SetMenuDialogDefaultIndex(fSliderDefaults[iOID] as int)
EndEvent

Event OnOptionMenuAccept(int iMCMOID, int index)
	int iOID = iMCMOID  % 128	; -= iOIDOffset
;Trace("JaxonzMCMHelper::OnOptionMenuAccept iOID:" + iOID + ", index:" + index)
	string[] sValues
	sValues = ParseCSVtoArray(sStringVals[iOID])
	iIntVals[iOID] = index
	if gGlobalVars[iOID]
		gGlobalVars[iOID].SetValue(index as float)
	EndIf
	SetMenuOptionValue(iMCMOID, sValues[index])
EndEvent

;UTILITY INTERNAL FUNCTIONS

bool Function DispatchModEvent (int iOID)
;sent ModEvent calls to the child or any listener
;Trace("JaxonzMCMHelper::DispatchModEvent iOID:" + iOID )
;dispatch any ModEvents
	iOID = iOID % 128
	if sModEvents[iOID] != ""
		if iOptionTypes[iOID] == kToggle
			SendModEvent(sModEvents[iOID], sStringVals[iOID], bBoolVals[iOID] as Float)
		ElseIf iOptionTypes[iOID] == kSlider
			SendModEvent(sModEvents[iOID], sStringVals[iOID], fFloatVals[iOID])
		Else
			SendModEvent(sModEvents[iOID], sStringVals[iOID], iIntVals[iOID] as float)
		EndIf
		return true
	Else
		return false
	EndIf
EndFunction

string function GetCustomControl(int keyCode)
;helper to notify other plugins of keymapping conflict
	int iOID
	While iOID < iIntVals.Length
		if iIntVals[iOID] == keyCode
			return sKeyConflicts[iOID]
		EndIf
		iOID += 1
	EndWhile
endFunction

event OnPageSelect(string a_eventName, string a_page, float a_index, Form a_sender)
;listen for this ModEvent and to reinitialize the page
;trace("JaxonzMCMHelper::OnPageSelect, a_page:" + a_page + ", a_index:" + a_index)
	InitArrays()
EndEvent

Function InitArrays()
	iOptionTypes = new int[128]
	sHelpInfos = New String[128]
	sLabels = New String[128]
	gGlobalVars = New GlobalVariable[128]
	bBoolVals = New bool[128]
	fFloatVals = New float[128]
	fSliderMaxs = New float[128]
	fSliderMins = New float[128]
	fSliderDefaults = New float[128]
	fSliderIntervals = New float[128]
	sSliderFormats = New String[128]
	sKeyConflicts = New String[128]
	iIntVals = new int[128]
	sStringVals = New String[128]
	sModEvents = New String[128]
	iBitMasks = new int[128]
	
EndFunction
