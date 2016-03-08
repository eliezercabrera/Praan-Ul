Scriptname QuomoZRealisticDeathPlayer extends ReferenceAlias  

Actor Property player_property  Auto

SoundCategory Property MasterSoundCategory  Auto

Actor Property LastAggressor  Auto

ImageSpaceModifier Property QuomoZFadeToBlackIMod  Auto
ImageSpaceModifier Property QuomoZFadeToBlackHoldImod  Auto
ImageSpaceModifier Property QuomoZBlurHoldIMod  Auto

Quest Property QuomoZRealisticDeathQ Auto

Bool is_player_alive = true
Bool died_quickly = true

;Allow testing mode to be toggeable via the in-game configuration menu for development purposes

Event OnInit()
  ;Debug.Trace("Initializing script.") Set for removal
  MasterSoundCategory.SetVolume(1.0)
  AudioCategoryMUS.UnMute() ; Mute preserves user audio settings better
  ;Game.SetGameSettingFloat("fPlayerDeathReloadTime", 10.0) Set for removal
  player_property.GetActorBase().SetEssential(True)
  ;player_property.StartDeferredKill()
EndEvent

Event OnPlayerLoadGame()
  MasterSoundCategory.SetVolume(1.0)
  AudioCategoryMUS.UnMute() ; Mute preserves user audio settings better
  ;Game.SetGameSettingFloat("fPlayerDeathReloadTime", 10.0) Set for removal
  QuomoZRealisticDeathQ.RegisterForModEvent("QuomoZRealisticDeath_PlayerDied", "OnPlayerDied")
  player_property.GetActorBase().SetEssential(True)
  ;player_property.StartDeferredKill()
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)
  If (player_property.GetActorValue("Health") <= 0 && is_player_alive)
    is_player_alive = false
    LastAggressor = akAggressor as Actor
    If (abPowerAttack || Math.abs(player_property.GetActorValuePercentage("Health")) >= 0.15)
      ;Game.SetGameSettingFloat("fPlayerDeathReloadTime", 5.0)
      died_quickly = true
    EndIf
  EndIf
EndEvent

Function SendDeathEvent()
    Int handle = ModEvent.Create("QuomoZRealisticDeath_PlayerDied")
    If (handle)
        ModEvent.PushBool(handle, died_quickly)
        ModEvent.Send(handle)
    EndIf
EndFunction

Event OnEnterBleedout()
  Debug.Notification("Entering bleedout state.")
  Game.DisablePlayerControls(abMovement = true, abFighting = true)
	player_property.StopCombat()
	player_property.StopCombatAlarm()
  ;If (died_quickly)

  SendDeathEvent()
  Utility.Wait(0.5) ; regular vision

  QuomoZBlurHoldIMod.ApplyCrossFade(1.8) ; Blur vision
  Utility.Wait(1.6)

  QuomoZFadeToBlackImod.ApplyCrossFade(2.7) ; Fade vision to black
  Utility.Wait(2.5)

  QuomoZFadeToBlackImod.PopTo(QuomoZFadeToBlackHoldImod) ; Retain black vision
  Utility.Wait(5.0) ; Reflect about your death in darkness
  
  player_property.GetActorBase().SetEssential(False)
  player_property.KillEssential()
  ;player_property.EndDeferredKill()
  
EndEvent 

Spell Property QuomoZRealisticDeathDisarmSelf  Auto  

SoundCategory Property AudioCategoryMUS  Auto  
