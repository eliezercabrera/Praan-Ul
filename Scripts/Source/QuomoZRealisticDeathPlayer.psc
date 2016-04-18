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

Event OnInit()
  MasterSoundCategory.SetVolume(1.0)
  AudioCategoryMUS.UnMute() ; Mute preserves user audio settings better

  player_property.GetActorBase().SetEssential(True)
EndEvent

Event OnPlayerLoadGame()
  MasterSoundCategory.SetVolume(1.0)
  AudioCategoryMUS.UnMute() ; Mute preserves user audio settings better

  QuomoZRealisticDeathQ.RegisterForModEvent("QuomoZRealisticDeath_PlayerDied", "OnPlayerDied")
  player_property.GetActorBase().SetEssential(True)
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)
  If (player_property.GetActorValue("Health") <= 0 && is_player_alive)
    is_player_alive = false
    LastAggressor = akAggressor as Actor
    If (abPowerAttack || Math.abs(player_property.GetActorValuePercentage("Health")) >= 0.15)
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
  Game.DisablePlayerControls(abMovement = true, abFighting = true)
	player_property.StopCombat()
	player_property.StopCombatAlarm()

  SendDeathEvent() ; allows some multithreading to occur
  
  ImageSpaceModifier blankIMod = QuomoZFadeToBlackImod;
  ImageSpaceModifier blankHoldIMod = QuomoZFadeToBlackHoldImod;
  
  If (QuomoZBlankScreenToggle.GetValueInt() == 1)
    blankIMod = QuomoZFadeToWhiteImod;
    blankHoldIMod = QuomoZFadeToWhiteHoldImod;
  EndIf

  If (QuomoZFadeVisionToggle.GetValueInt() == 1)
    Debug.Notification("Enter If statement in fadevisiontoggle")
    If (QuomoZDeathProfileToggle.GetValueInt() == 0)
      blankHoldIMod.Apply()
    Else
      Utility.Wait(QuomoZFadeVisionOnset.GetValue())
      blankHoldIMod.ApplyCrossFade(QuomoZFadeVisionSpan.GetValue())
    EndIf
  Else
    ; do nothing
  EndIf

  Utility.Wait(QuomoZTimeUntilLastSenseLost.GetValue())
  ;blankHoldIMod.PopTo(blankHoldIMod)
  
  ;Game.FadeOutGame(True, !QuomoZBlankScreenToggle.GetValueInt(), QuomoZFadeVisionOnset.GetValue(), QuomoZFadeVisionSpan.GetValue())
  
  If (QuomoZBlankScreenReloadModeToggle.getValueInt() == 0)
    KillPlayer()
  ElseIf (QuomoZBlankScreenReloadModeToggle.getValueInt() == 1)
    Utility.Wait(QuomoZBlankScreenBeforeReloadTime.getValue()); Reflect about your death in darkness
    KillPlayer()
  Else
    RegisterForKey(QuomoZReloadKey.GetValueInt())
    is_player_alive = False
  EndIf

EndEvent

Event OnKeyUp(Int keyCode, float holdTime)
  If (keyCode == QuomoZReloadKey.GetValue() && !is_player_alive)
    UnregisterForKey(QuomoZReloadKey.GetValueInt())
    KillPlayer()
  EndIf
EndEvent

Function KillPlayer()
  player_property.GetActorBase().SetEssential(False)
  player_property.KillEssential()
EndFunction

Spell Property QuomoZRealisticDeathDisarmSelf  Auto  

SoundCategory Property AudioCategoryMUS  Auto   

GlobalVariable Property QuomoZBlankScreenBeforeReloadTime  Auto  

GlobalVariable Property QuomoZBlankScreenReloadModeToggle  Auto  

GlobalVariable Property QuomoZReloadKey  Auto  

GlobalVariable Property QuomoZFadeVisionOnset  Auto  

GlobalVariable Property QuomoZFadeVisionSpan  Auto  

GlobalVariable Property QuomoZTimeUntilLastSenseLost  Auto  

GlobalVariable Property QuomoZDeathProfileToggle  Auto  

GlobalVariable Property QuomoZFadeVisionToggle  Auto  
