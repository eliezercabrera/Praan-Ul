Scriptname QuomoZRealisticDeathMCMConfig extends JaxonzMCMHelper
{Demonstrates use of JaxonMCMHelper functions}

import Debug

bool bToggle
float fSliderVal = 12.2
int iKeyMap = 32
int iMenuSelection = 3
int iTextToggleState = 1
int iGlobalBitFieldOID
int iTextOptionOID

GlobalVariable Property QuomoZTestCheckbox Auto ;Marked for deletion when reattaching script to Creation Kit.
GlobalVariable Property QuomoZInstantMusicMuteToggle  Auto

GlobalVariable Property QuomoZInstantSoundMuteToggle  Auto
GlobalVariable Property QuomoZBlankScreenToggle  Auto  

event OnConfigInit()
    Pages = new string[3]
    Pages[0] = "General Settings"
    Pages[1] = "Timing Settings"
endEvent

Event OnPageReset(string page)
	SetCursorFillMode(TOP_TO_BOTTOM)
	int iOID
	if page == ""
		AddHeaderOption("Realistic Death")
		DefineMCMParagraph("Blank page description of Realistic Death")
	ElseIf page == "General Settings"
		DefineMCMParagraph("This page demonstrates use of widgets tied to GlobalVariables.\n\nThis is by far the easiest and recommended method for leveraging MCM Helper.")
		SetCursorPosition(1)
		AddHeaderOption("Audio settings")
    DefineMCMToggleOptionGlobal("Mute all sound instantly", QuomoZInstantSoundMuteToggle, 0, "If selected, all sound will mute instantly instead of fading away.")
		DefineMCMToggleOptionGlobal("Mute music instantly", QuomoZInstantMusicMuteToggle, QuomoZInstantSoundMuteToggle.GetValue() as Int, "If not selected, the background music will fade away alongside other sounds.")
    DefineMCMMenuOptionGlobal("Blank Screen Color", "Black,White", QuomoZBlankScreenToggle, 0, OPTION_FLAG_AS_TEXTTOGGLE, "In lieu of showing literal nothingness, choose a color to represent the emptiness of death.")
    DefineMCMMenuOptionGlobal("Blank Screen Duration", "Reload Immediately,Fixed Period,Until Keypress", QuomoZBlankScreenReloadModeToggle, 0, OPTION_FLAG_AS_TEXTTOGGLE, "Choose when the game will reload after the death sequence is over.")
    DefineMCMSliderOptionGlobal("Blank Screen Duration (seconds)", QuomoZBlankScreenBeforeReloadTime, 3, 0.1, 100.0, 0.1, "Set the time you will reflect in front of the blank screen.","{2}")
    DefineMCMKeymapOptionGlobal("Reload Key", QuomoZReloadKey, OPTION_FLAG_WITH_UNMAP, 0, "Choose the key that will reload the game if you have chosen to reflect until keypress.")
  ElseIf page == "Paragraphs"
		DefineMCMParagraph("Paragraphs are intented to display multi-line information in MCM menus.\nAll of the text your are reading comes from a single line of code.\nStrings in paragraphs are automatically wrapped so as to stay within bounds.\nNewline characters are also supported in paragraphs.\nThe default flag for paragraphs is as disabled, which makes them easy to read, differentiate them from usable controls, and not highlight when moused over.")
		SetCursorPosition(1)
		AddHeaderOption("Help Topics")
		DefineMCMHelpTopic("Help Topic Example", "Help topics are simple, non-interactive text widgets that display topic info below when moused over.\nTopic info text wraps automatically and also allows newline characters. More than 3 lines of information starts making the text too small to read.")
		DefineMCMHelpTopic("Anopther Help Topic", "Help topics provide a simple way for you to include concise, in-game help for your mods.\nConsider adding a few help topics to cover those frequently asked questions or helpful tips.")
		AddEmptyOption()
		AddHeaderOption("One Last Benefit...")
		DefineMCMHelpTopic("No More Missing MCM Menus", "A common challenge with MCM menus is that they sometimes fail to register and display.\nOne frequen mistake is that we modders keep forgetting to add the SKI_PlayerLoadGameAlias script.\nMCM Helper makes that step unneccessary by nudging your MCM menu to always initialize correctly.")
	EndIf
EndEvent

event OnOptionSelect(int iOID)
	;We are using this event to capture any click on the global bitmask toggles.
	;It is a bit lazier than using ModEvent callbacks, but also gives us an opportunity to explain one caveat.
	;Because we have implemented an MCM event, the parent JaxonzMCMHelper script will not recieve it.
	;We must explicitly pass the event up to the parent for any MCM event that we use.
    Parent.OnOptionSelect(iOID)	;pass event to JaxonMCMHelper

	if CurrentPage == "Bitmask"
		;SetTextOptionValue(iGlobalBitFieldOID, giBitField.GetValueInt())	;update the value displayed
	EndIf
endEvent

Event OnBooleanToggleClick(string eventName, string strArg, float numArg, Form sender)
	bToggle = numArg as bool
EndEvent

Event OnSliderChange(string eventName, string strArg, float numArg, Form sender)
	fSliderVal = numArg
EndEvent

Event OnTextOptionClick(string eventName, string strArg, float numArg, Form sender)
;demonstrates use of ModEvent callback
	MessageBox("Event " + eventName + " Received\nstrArg:" + strArg + "\nnumArg:" + numArg + "\nsender:" + sender)
	SetTextOptionValue(iTextOptionOID, "New string")
EndEvent

Event OnKeymapChange(string eventName, string strArg, float numArg, Form sender)
	iKeyMap = numArg as int
EndEvent

Event OnMenuOptionChange(string eventName, string strArg, float numArg, Form sender)
	iMenuSelection = numArg as int
EndEvent

Event OnTextToggleChange(string eventName, string strArg, float numArg, Form sender)
	iTextToggleState = numArg as int
EndEvent

GlobalVariable Property QuomoZBlankScreenReloadModeToggle  Auto  

GlobalVariable Property QuomoZBlankScreenBeforeReloadTime  Auto  

GlobalVariable Property QuomoZReloadKey  Auto  
