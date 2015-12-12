Scriptname QuomoZRealisticDeathQuest extends Quest  

Event OnInit()
  RegisterForModEvent("QuomoZRealisticDeath_PlayerDied", "OnPlayerDied")
EndEvent

Event OnPlayerDied(Bool died_quickly)

  If (QuomoZInstantMusicMuteToggle.GetValue()  == 1)
    AudioCategoryMUS.Mute()
  EndIf

  Float initial_volume = 1.0
  Float final_volume   = 0.0
  
  While (initial_volume >= final_volume)
    MasterSoundCategory.SetVolume(initial_volume)
    initial_volume = initial_volume - 0.1
    Utility.Wait(0.35)
  EndWhile

EndEvent

SoundCategory Property MasterSoundCategory  Auto  

GlobalVariable Property QuomoZInstantMusicMuteToggle  Auto  

SoundCategory Property AudioCategoryMUS  Auto  
