Scriptname QuomoZRealisticDeathQuest extends Quest  

Event OnInit()
  RegisterForModEvent("QuomoZRealisticDeath_PlayerDied", "OnPlayerDied")
EndEvent

Event OnPlayerDied(Bool died_quickly)
  If (died_quickly)
    Float initial_volume = 1.0
    Float final_volume   = 0.0
    
    While (initial_volume >= final_volume)
      MasterSoundCategory.SetVolume(initial_volume)
      initial_volume = initial_volume - 0.1
    EndWhile  
  Else
    Float initial_volume = 1.0
    Float final_volume   = 0.0
    
    While (initial_volume >= final_volume)
      MasterSoundCategory.SetVolume(initial_volume)
      initial_volume = initial_volume - 0.1
      Utility.Wait(0.35)
    EndWhile
  EndIf
EndEvent

SoundCategory Property MasterSoundCategory  Auto  
