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

;; Add an MCM for the mod:
;;    Mute music
;;    Enable Functionality
;;    Customizable phases
;;        regular vision
;;        blurry vision
;;        fade to black
;;        independent audio loss
;;    Three Profiles
;;        Deadly Blow (Instant Death)
;;        Powerfull Blow (Quick Death)
;;        Regular Blow (Slow Death)
;;    Darkness Duration
;;    Enable/Disable heartbeat and red screen effect
;;    Enable/Disable blood drops on screen
;;    Apply exagerated ragdoll physics fix (check spells and fists)
;;    Uninstall Mod
;;        Extend magical effect that can be dispelled for safe uninstallation

Event OnInit()
  Debug.Trace("Initializing script.")
  MasterSoundCategory.SetVolume(1.0)
  Game.SetGameSettingFloat("fPlayerDeathReloadTime", 7.0)
EndEvent

Event OnPlayerLoadGame()
  MasterSoundCategory.SetVolume(1.0)
  Game.SetGameSettingFloat("fPlayerDeathReloadTime", 7.0)
  QuomoZRealisticDeathQ.RegisterForModEvent("QuomoZRealisticDeath_PlayerDied", "OnPlayerDied")
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)
  If (player_property.GetActorValue("Health") <= 0 && is_player_alive)
    is_player_alive = false
    LastAggressor = akAggressor as Actor
    If (abPowerAttack || Math.abs(player_property.GetActorValuePercentage("Health")) >= 0.15)
      Game.SetGameSettingFloat("fPlayerDeathReloadTime", 5.0)
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

Event OnDying(Actor akKiller)
  If (died_quickly)
    SendDeathEvent()
  
    QuomoZBlurHoldIMod.ApplyCrossFade(0.2) ; Blur vision
    QuomoZFadeToBlackImod.ApplyCrossFade(0.2) ; Fade vision to black
    Utility.Wait(0.15)
	  QuomoZFadeToBlackImod.PopTo(QuomoZFadeToBlackHoldImod) ; Retain black vision
    Utility.Wait(10.0) ; Reflect about your death in darkness
  Else
    SendDeathEvent()
    Utility.Wait(0.5) ; regular vision
  
    QuomoZBlurHoldIMod.ApplyCrossFade(1.8) ; Blur vision
    Utility.Wait(1.6)
  
    QuomoZFadeToBlackImod.ApplyCrossFade(2.7) ; Fade vision to black
	  Utility.Wait(2.5)
  
	  QuomoZFadeToBlackImod.PopTo(QuomoZFadeToBlackHoldImod) ; Retain black vision
    Utility.Wait(10.0) ; Reflect about your death in darkness
    ;player_property.Kill()
  EndIf
EndEvent 

Spell Property QuomoZRealisticDeathDisarmSelf  Auto  
