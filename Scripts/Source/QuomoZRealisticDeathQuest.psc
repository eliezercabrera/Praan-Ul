Scriptname QuomoZRealisticDeathQuest extends Quest  

Event OnInit()
  RegisterForModEvent("QuomoZRealisticDeath_PlayerDied", "OnPlayerDied")
EndEvent

Event OnPlayerDied(Bool died_quickly)

  Float silence = 0.0

  If (QuomoZInstantSoundMuteToggle.GetValueInt() == 1)
    MasterSoundCategory.SetVolume(silence)
    Return
  ElseIf (QuomoZInstantMusicMuteToggle.GetValueInt() == 1)
    AudioCategoryMUS.Mute()
  EndIf

  Utility.Wait(QuomoZAuditoryLossOnset.GetValue())
  
  Float currentVolume = 1.0
  Float waitInterval = QuomoZAuditoryLossSpan.GetValue() * 0.1
  
  While (currentVolume + 0.05 >= silence) ; avoid float imprecision errors
    MasterSoundCategory.SetVolume(currentVolume)
    currentVolume = currentVolume - 0.1
    Utility.Wait(waitInterval)
  EndWhile

EndEvent

SoundCategory Property MasterSoundCategory  Auto  

GlobalVariable Property QuomoZInstantMusicMuteToggle  Auto  

SoundCategory Property AudioCategoryMUS  Auto  

GlobalVariable Property QuomoZInstantSoundMuteToggle  Auto  

GlobalVariable Property QuomoZAuditoryLossOnset  Auto  

GlobalVariable Property QuomoZAuditoryLossSpan  Auto  
