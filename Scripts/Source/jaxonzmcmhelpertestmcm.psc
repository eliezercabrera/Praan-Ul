Scriptname JaxonzMCMHelperTestMCM extends JaxonzMCMHelper
{Demonstrates use of JaxonMCMHelper functions}

import Debug

GlobalVariable Property giTestCheckbox Auto
GlobalVariable Property gfTestSlider Auto
GlobalVariable Property giTestKeymap Auto
GlobalVariable Property giGlobalMenuSelected Auto
GlobalVariable Property giGlobalTextToggleSelected Auto
GlobalVariable Property giBitField Auto
bool bToggle
float fSliderVal = 12.2
int iKeyMap = 32
int iMenuSelection = 3
int iTextToggleState = 1
int iGlobalBitFieldOID
int iTextOptionOID

event OnConfigInit()
    Pages = new string[4]
    Pages[0] = "Global Variables"
    Pages[1] = "Unbound"
    Pages[2] = "Bitmask"
    Pages[3] = "Paragraphs"
endEvent

Event OnPageReset(string page)
	SetCursorFillMode(TOP_TO_BOTTOM)
	int iOID
	if page == ""
		AddHeaderOption("Jaxonz MCM Helper Demonstration")
		DefineMCMParagraph("This mod just demonstrates the use of JaxonzMCMHelper functionality.\n\nTo a user, the menu is no different. But if one peeks at the source code, they will find that the menu declaration and management is much, much simpler.\n\nThis fully functional 5 page MCM menu is just 130 lines of code.")
	ElseIf page == "Global Variables"
		DefineMCMParagraph("This page demonstrates use of widgets tied to GlobalVariables.\n\nThis is by far the easiest and recommended method for leveraging MCM Helper.")
		SetCursorPosition(1)
		AddHeaderOption("Global widgets")
		DefineMCMToggleOptionGlobal("Global Toggle", giTestCheckbox, 0 , "DefineMCMToggleOptionGlobal creates a fully functional checkbox widget in a single line of code.\nThe GlobalVariable is toggled between 0 and 1 depending on state.\nYou don't need to write any special handlers.")
		DefineMCMSliderOptionGlobal("Global Slider", gfTestSlider, 40, -3, 201.4, 10.5, "DefineMCMSliderOptionGlobal defines a slider widget in a single line of code, automatically updating a global variable with the user-selected value.","{2}") 
		DefineMCMKeymapOptionGlobal("Global Keymap", giTestKeymap, OPTION_FLAG_WITH_UNMAP, 60, "DefineMCMKeymapOptionGlobal handles mapping of keys to functions in your mod. A single line is all that is needed to handle mapping, help, conflict detection and value storage in a GlobalVariable.")
		DefineMCMMenuOptionGlobal("Global Menu", "One,Two,Three,Four,Five", giGlobalMenuSelected, 2, 0, "DefineMCMMenuOptionGlobal creates a menu in one line of code, tied to a GlobalVariable. The list of choices is passed in as a comma-separated value string, which saves you from having to create string arrays for menus. Note, howerver, that this function requires SKSE 1.7.2 because it uses Utility.CreateStringArray to dynamically create the string array needed for the SetMenuDialogOptions function.")
		DefineMCMMenuOptionGlobal("Global Text Toggle", "Alpha,Beta,Gamma", giGlobalTextToggleSelected, 0, OPTION_FLAG_AS_TEXTTOGGLE, "DefineMCMMenuOptionGlobal can also be used to create a toggleable text widget, simply by using the OPTION_FLAG_AS_TEXTTOGGLE flag.\nText toggles are simpler than menus, requiring fewer clicks for users, but they are useful for 2 or 3 states. A menu dialog is more approprate if there are more choices. Requires SKSE 1.7.2.")
	ElseIf page == "Unbound"
		DefineMCMParagraph("This page demonstrates use of unbound widgets. Unlike Global widgets, no values are updated automatically when users manipulate these items.\nUse ModEvents to recieve updates when users have changed control values.\n\nUse of OnConfigClose to update variables is NOT ADVISED as it will be unreliable for menus with more than one page.")
		SetCursorPosition(1)
		RegisterForModEvent("MyModBooleanToggleClick","OnBooleanToggleClick")	;Callback for following line. Substitute your own ModEvent value to ensure that this event is unique
		DefineMCMToggleOption("Boolean Toggle", bToggle, 0 , "Creates a checkbox widget with a single line of code.\nUse ModEvents to signal when this value is changed.", "MyModBooleanToggleClick")
		RegisterForModEvent("MyModSliderChange","OnSliderChange")
		DefineMCMSliderOption("Float Slider", fSliderVal, 10.0, -3.0, 201.4, 10.0, "DefineMCMSliderOption define a slider in one line.\nLikewise, ModEvent callbacks are used to notify your code when a user has changed the value.","{3}", 0, "MyModSliderChange")
		RegisterForModEvent("MyModKeymapChange","OnKeymapChange")
		DefineMCMKeymapOption("Key Map", iKeyMap, OPTION_FLAG_WITH_UNMAP, 32, "DefineMCMKeymapOption creates a keyboard/control selection widget.", "test mod local keymap", "MyModKeymapChange")
		RegisterForModEvent("MyModTextOptionClick","OnTextOptionClick")
		iTextOptionOID = DefineMCMTextOption("Text Option", "text value", 0, "DefineMCMTextOption defines a text option widget.\nThis one demonstrates use of a ModEvent callback that pops a MessageBox displaying the values passed. The code also shows how to update the textoption value.", "MyModTextOptionClick")
		RegisterForModEvent("MyModMenuOptionChange","OnMenuOptionChange")
		DefineMCMMenuOption("Menu Option", "red,orange,green,blue", iMenuSelection, 2, 0, "DefineMCMMenuOption creates a menu in one line.\nAs with the GlobalVariable version, this function requires SKSE 1.7.2.", "MyModMenuOptionChange")
		RegisterForModEvent("MyModTextToggleChange","OnTextToggleChange")
		DefineMCMMenuOption("Text Toggle", "zero,1,two,three", iTextToggleState, 0, OPTION_FLAG_AS_TEXTTOGGLE, "DefineMCMMenuOption can also create toggle text type controls that will iterate through each option with each click", "MyModTextToggleChange")
	ElseIf page == "Bitmask"
		DefineMCMParagraph("This page demonstrates using a single GlobalVariable as a bitfield to store up to 21 different toggle states.\n\nThis is much more effiecient in terms of both data stored and also the speed of retrieval.\n\nCheck for values with Math.LogicalAnd(iBitField,0x4) [substituting your values for the bitfield and mask].\n\nMasks larger than 0x100000 should not be used.")
		SetCursorPosition(1)
		AddHeaderOption("Global Bitfield Value")
		iGlobalBitFieldOID = AddTextOption("Composite BitField Value", giBitField.GetValueInt())
		AddEmptyOption()
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00000001", giBitField, 0x1, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00000002", giBitField, 0x2, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00000004", giBitField, 0x4, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00000008", giBitField, 0x8, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00000010", giBitField, 0x10, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00000020", giBitField, 0x20, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00000040", giBitField, 0x40, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00000080", giBitField, 0x80, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00000100", giBitField, 0x100, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00000200", giBitField, 0x200, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00000400", giBitField, 0x400, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00000800", giBitField, 0x800, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00001000", giBitField, 0x1000, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00002000", giBitField, 0x2000, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00004000", giBitField, 0x4000, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00008000", giBitField, 0x8000, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00010000", giBitField, 0x10000, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00020000", giBitField, 0x20000, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00040000", giBitField, 0x40000, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00080000", giBitField, 0x80000, 0 , "toggle this bit")
		DefineMCMToggleOptionGlobalBitMask("Bitmask 0x00100000", giBitField, 0x100000, 0 , "toggle this bit")
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
		SetTextOptionValue(iGlobalBitFieldOID, giBitField.GetValueInt())	;update the value displayed
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