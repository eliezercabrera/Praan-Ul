Scriptname QuomoZRealisticDeathQuest extends Quest  

Event OnInit()
  RegisterForModEvent("QuomoZRealisticDeath_PlayerDied", "OnPlayerDied")
EndEvent

Event OnPlayerDied(Bool died_quickly)
  If (QuomoZInstantMusicMuteToggle.GetValueInt() == 1)
    AudioCategoryMUS.Mute()
  EndIf
  
  If (QuomoZAuditoryLossToggle.GetValueInt() == 1)
    Float silence = 0.0

    If (QuomoZInstantSoundMuteToggle.GetValueInt() == 1 || QuomoZDeathProfileToggle.GetValueInt() == 0)
      MasterSoundCategory.SetVolume(silence)
      Return
    EndIf

    Utility.Wait(QuomoZAuditoryLossOnset.GetValue())
  
    Float currentVolume = 1.0
    Float waitInterval = QuomoZAuditoryLossSpan.GetValue() * 0.1
  
    While (currentVolume + 0.05 >= silence) ; avoid float imprecision errors
      MasterSoundCategory.SetVolume(currentVolume)
      currentVolume = currentVolume - 0.1
      Utility.Wait(waitInterval)
    EndWhile
  EndIf
EndEvent

SoundCategory Property MasterSoundCategory  Auto  

GlobalVariable Property QuomoZInstantMusicMuteToggle  Auto  

SoundCategory Property AudioCategoryMUS  Auto  

GlobalVariable Property QuomoZInstantSoundMuteToggle  Auto  

GlobalVariable Property QuomoZAuditoryLossOnset  Auto  

GlobalVariable Property QuomoZAuditoryLossSpan  Auto  

GlobalVariable Property QuomoZAuditoryLossToggle  Auto  

GlobalVariable Property QuomoZDeathProfileToggle  Auto  
