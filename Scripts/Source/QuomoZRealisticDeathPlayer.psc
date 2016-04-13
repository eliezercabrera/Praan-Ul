Scriptname QuomoZRealisticDeathPlayer extends ReferenceAlias  

Actor Property player_property  Auto

SoundCategory Property MasterSoundCategory  Auto

Actor Property LastAggressor  Auto

ImageSpaceModifier Property QuomoZFadeToBlackIMod  Auto
ImageSpaceModifier Property QuomoZFadeToBlackHoldImod  Auto

ImageSpaceModifier Property QuomoZFadeToWhiteIMod  Auto
ImageSpaceModifier Property QuomoZFadeToWhiteHoldImod  Auto  

GlobalVariable Property QuomoZBlankScreenToggle  Auto

ImageSpaceModifier Property QuomoZBlurHoldIMod  Auto

Quest Property QuomoZRealisticDeathQ Auto

Bool died_quickly = true
Bool is_player_alive = true

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

Function FadeToBlank()
  ImageSpaceModifier blankIMod = QuomoZFadeToBlackImod;
  ImageSpaceModifier blankHoldIMod = QuomoZFadeToBlackHoldImod;
  
  If (QuomoZBlankScreenToggle.GetValueInt() == 1)
    blankIMod = QuomoZFadeToWhiteImod;
    blankHoldIMod = QuomoZFadeToWhiteHoldImod;
  EndIf

  Utility.Wait(0.5) ; regular vision

  QuomoZBlurHoldIMod.ApplyCrossFade(1.8) ; Blur vision
  Utility.Wait(1.6)

  blankIMod.ApplyCrossFade(2.7) ; Fade vision to black
  Utility.Wait(3.0)

  blankIMod.PopTo(blankHoldIMod) ; Retain black vision
  
EndFunction

Event OnEnterBleedout()
  Game.DisablePlayerControls(abMovement = true, abFighting = true)
	player_property.StopCombat()
	player_property.StopCombatAlarm()
  ;If (died_quickly)

  SendDeathEvent()
  
  FadeToBlank()
  
  If (QuomoZBlankScreenReloadModeToggle.getValueInt() == 0)
    player_property.GetActorBase().SetEssential(False)
    player_property.KillEssential()
    ;player_property.EndDeferredKill()
  ElseIf (QuomoZBlankScreenReloadModeToggle.getValueInt() == 1)
    Utility.Wait(QuomoZBlankScreenBeforeReloadTime.getValue()); Reflect about your death in darkness
    player_property.GetActorBase().SetEssential(False)
    player_property.KillEssential()
    ;player_property.EndDeferredKill()
  Else
    RegisterForKey(QuomoZReloadKey.GetValueInt())
    is_player_alive = False
  EndIf

EndEvent

Event OnKeyUp(Int keyCode, float holdTime)
  If (keyCode == QuomoZReloadKey.GetValue() && !is_player_alive)
  
    UnregisterForKey(QuomoZReloadKey.GetValueInt())
  
    player_property.GetActorBase().SetEssential(False)
    player_property.KillEssential()
    ;player_property.EndDeferredKill()
  EndIf

EndEvent

Spell Property QuomoZRealisticDeathDisarmSelf  Auto  

SoundCategory Property AudioCategoryMUS  Auto   

GlobalVariable Property QuomoZBlankScreenBeforeReloadTime  Auto  

GlobalVariable Property QuomoZBlankScreenReloadModeToggle  Auto  

GlobalVariable Property QuomoZReloadKey  Auto  
