Scriptname QuomoZRealisticDeathMCMConfig extends JaxonzMCMHelper
{Demonstrates use of JaxonMCMHelper functions}

import Debug

bool bloodSplatterToggle
Int iDeathProfileToggle = 0
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
    DefineMCMSliderOptionGlobal("Blank Screen Duration (seconds)", QuomoZBlankScreenBeforeReloadTime, 5.0, 0.1, 100.0, 0.1, "Set the time you will reflect in front of the blank screen.","{2}")
    DefineMCMKeymapOptionGlobal("Reload Key", QuomoZReloadKey, OPTION_FLAG_WITH_UNMAP, 0, "Choose the key that will reload the game if you have chosen to reflect until keypress.")
    RegisterForModEvent("BloodSplatterToggle","OnBloodSplatterToggle")
		DefineMCMToggleOption("Show Blood Splatter", bloodSplatterToggle, 0 , "A cinematic effect you can disable.", "BloodSplatterToggle")
    
    RegisterForModEvent("DeathProfileToggle","OnDeathProfileToggle")
		DefineMCMMenuOption("Sensory Loss Mode", "Instant,Fixed,Dynamic", iDeathProfileToggle, 0, OPTION_FLAG_AS_TEXTTOGGLE, "Select the way in wish you will lose your senses: immediately, always the same way, or dynamically depending on the killing blow.", "DeathProfileToggle")
  ElseIf page == "Timing Settings"
		DefineMCMParagraph("Placeholder text. This text will be made dynamic depending on profile selected on general settings.")
		SetCursorPosition(1)
		AddHeaderOption("Help Topics")
		DefineMCMHelpTopic("Help Topic Example", "Help topics are simple, non-interactive text widgets that display topic info below when moused over.\nTopic info text wraps automatically and also allows newline characters. More than 3 lines of information starts making the text too small to read.")
		DefineMCMHelpTopic("Anopther Help Topic", "Help topics provide a simple way for you to include concise, in-game help for your mods.\nConsider adding a few help topics to cover those frequently asked questions or helpful tips.")
		AddEmptyOption()
		
		DefineMCMToggleOptionGlobal("Postmortem blows kill quickly", QuomoZPostmortemBlowInstaDeathToggle, 0, "When selected, when you receive an attack during the dying animation, you will lose your senses instantly.")
    DefineMCMSliderOptionGlobal("Duration Minimum Multiplier", QuomoZDynamicMinMultiplier, 0.3, 0.10, 1.00, 0.01, "This multiplier determines how much faster you can lose senses when dying from powerful blows.","{2}")
    DefineMCMSliderOptionGlobal("Minimum damage for insta-death", QuomoZMinDamageForInstaDeath, 0.20, 0.10, 1.00, 0.01, "You will never insta-die if the killing blow dealt less damage that this percentage of your health. Useful if your mods make most attacks take lots of HP but you don't want to always die instantly.","{2}")
    
    AddHeaderOption("Auditory Loss")
    DefineMCMToggleOptionGlobal("Enabled", QuomoZAuditoryLossToggle, 0, "Decide if you'll lose your hearing.")
    DefineMCMSliderOptionGlobal("Onset", QuomoZAuditoryLossOnset, 1.0, 0.1, 30.0, 0.1, "Select when you will start losing your hearing.","{2}")
    DefineMCMSliderOptionGlobal("Span", QuomoZAuditoryLossSpan, 9.0, 0.1, 30.0, 0.1, "Select how long it will take you to completely lose your hearing.","{2}")
    
    AddHeaderOption("Vision Blur")
    DefineMCMToggleOptionGlobal("Enabled", QuomoZVisionBlurToggle, 0, "Decide if your vision will blur.")
    DefineMCMSliderOptionGlobal("Onset", QuomoZVisionBlurOnset, 1.0, 0.1, 30.0, 0.1, "Select when your vision will start to blur.","{2}")
    DefineMCMSliderOptionGlobal("Span", QuomoZVisionBlurSpan, 4.0, 0.1, 30.0, 0.1, "Select how long it will take your vision to blur completely.","{2}")
    
    AddHeaderOption("Vision Fade")
    DefineMCMToggleOptionGlobal("Enabled", QuomoZFadeVisionToggle, 0, "Decide if your vision will fade.")
    DefineMCMSliderOptionGlobal("Onset", QuomoZFadeVisionOnset, 2.0, 0.1, 30.0, 0.1, "Select when you will start losing your vision.","{2}")
    DefineMCMSliderOptionGlobal("Span", QuomoZFadeVisionSpan, 6.0, 0.1, 30.0, 0.1, "Select how long it will take you to completely lose your vision.","{2}")
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

Event OnBloodSplatterToggle(string eventName, string strArg, float numArg, Form sender)
  bloodSplatterToggle = numArg as Bool
  
  If (bloodSplatterToggle)
    Game.SetGameSettingFloat("fBloodSplatterMaxOpacity", QuomoZBloodSplatterMaxOpacity.GetValue())
    Game.SetGameSettingFloat("fBloodSplatterMaxOpacity2", QuomoZBloodSplatterMaxOpacity2.GetValue())
    Game.SetGameSettingFloat("fBloodSplatterMinOpacity", QuomoZBloodSplatterMinOpacity.GetValue())
    Game.SetGameSettingFloat("fBloodSplatterMinOpacity2", QuomoZBloodSplatterMinOpacity2.GetValue())
  Else
    QuomoZBloodSplatterMaxOpacity.SetValue(Game.GetGameSettingFloat("fBloodSplatterMaxOpacity"))
    QuomoZBloodSplatterMaxOpacity2.SetValue(Game.GetGameSettingFloat("fBloodSplatterMaxOpacity2"))
    QuomoZBloodSplatterMinOpacity.SetValue(Game.GetGameSettingFloat("fBloodSplatterMinOpacity"))
    QuomoZBloodSplatterMinOpacity2.SetValue(Game.GetGameSettingFloat("fBloodSplatterMinOpacity2"))
    
    Game.SetGameSettingFloat("fBloodSplatterMaxOpacity", 0.00)
    Game.SetGameSettingFloat("fBloodSplatterMaxOpacity2", 0.00)
    Game.SetGameSettingFloat("fBloodSplatterMinOpacity", 0.00)
    Game.SetGameSettingFloat("fBloodSplatterMinOpacity2", 0.00)
  EndIf
EndEvent

Event OnDeathProfileToggle(string eventName, string strArg, float numArg, Form sender)
  QuomoZDeathProfileToggle.SetValueInt(iDeathProfileToggle)
  
  If (iDeathProfileToggle == 0)
    QuomoZTimeUntilLastSenseLost.SetValue(0.0)
  Else
    Float auditoryLossTotalSpan = 0.0
    If (QuomoZAuditoryLossToggle.GetValueInt() as Bool)
      auditoryLossTotalSpan = QuomoZAuditoryLossOnset.GetValue() + QuomoZAuditoryLossSpan.GetValue()
    EndIf
    
    Float blurVisionTotalSpan = 0.0
    If (QuomoZVisionBlurToggle.GetValueInt() as Bool)
      blurVisionTotalSpan = QuomoZVisionBlurOnset.GetValue() + QuomoZVisionBlurSpan.GetValue()
    EndIf
    
    Float fadeVisionTotalSpan = 0.0
    If (QuomoZFadeVisionToggle.GetValueInt() as Bool)
      blurVisionTotalSpan = QuomoZVisionBlurOnset.GetValue() + QuomoZVisionBlurSpan.GetValue()
    EndIf
    
    Float maxTotalSpan = max(max(auditoryLossTotalSpan, blurVisionTotalSpan), fadeVisionTotalSpan)
    
    QuomoZTimeUntilLastSenseLost.SetValue(maxTotalSpan)

  EndIf
EndEvent

Float Function max(Float a, Float b)
  If (a > b)
    return a
  Else
    return b
  EndIf
EndFunction

Event OnPlayerDied(Bool died_quickly)

  If (QuomoZVisionBlurToggle.GetValueInt() as Bool)
    Utility.Wait(QuomoZVisionBlurOnset.GetValue())
    QuomoZBlurHoldIMod.ApplyCrossFade(QuomoZVisionBlurSpan.GetValue())
  Else
    return
  EndIf

EndEvent

GlobalVariable Property QuomoZBlankScreenReloadModeToggle  Auto  

GlobalVariable Property QuomoZBlankScreenBeforeReloadTime  Auto  

GlobalVariable Property QuomoZReloadKey  Auto  

GlobalVariable Property QuomoZBloodSplatterMaxOpacity  Auto  

GlobalVariable Property QuomoZBloodSplatterMaxOpacity2  Auto  

GlobalVariable Property QuomoZBloodSplatterMinOpacity  Auto  

GlobalVariable Property QuomoZBloodSplatterMinOpacity2  Auto  

GlobalVariable Property QuomoZAuditoryLossOnset  Auto  

GlobalVariable Property QuomoZAuditoryLossSpan  Auto  

GlobalVariable Property QuomoZVisionBlurOnset  Auto  

GlobalVariable Property QuomoZVisionBlurSpan  Auto  

GlobalVariable Property QuomoZFadeVisionOnset  Auto  

GlobalVariable Property QuomoZFadeVisionSpan  Auto  

GlobalVariable Property QuomoZDynamicMinMultiplier  Auto  

GlobalVariable Property QuomoZMinDamageForInstaDeath  Auto  

GlobalVariable Property QuomoZDeathProfileToggle  Auto  

GlobalVariable Property QuomoZPostmortemBlowInstaDeathToggle  Auto  

ImageSpaceModifier Property QuomoZBlurHoldIMod  Auto  

GlobalVariable Property QuomoZTimeUntilLastSenseLost  Auto  

GlobalVariable Property QuomoZAuditoryLossToggle  Auto  

GlobalVariable Property QuomoZVisionBlurToggle  Auto  

GlobalVariable Property QuomoZFadeVisionToggle  Auto  
