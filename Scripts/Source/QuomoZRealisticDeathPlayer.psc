Scriptname QuomoZRealisticDeathPlayer extends ReferenceAlias  

Actor Property player_property  Auto

SoundCategory Property MasterSoundCategory  Auto

Actor Property LastAggressor  Auto
Actor Property LastSource  Auto
Actor Property LastProjectile  Auto

ImageSpaceModifier Property QuomoZFadeToBlackIMod  Auto
ImageSpaceModifier Property QuomoZFadeToBlackHoldImod  Auto

ImageSpaceModifier Property QuomoZFadeToWhiteIMod  Auto
ImageSpaceModifier Property QuomoZFadeToWhiteHoldImod  Auto  

GlobalVariable Property QuomoZBlankScreenToggle  Auto

ImageSpaceModifier Property QuomoZBlurHoldIMod  Auto

Quest Property QuomoZRealisticDeathQ Auto

Float healthAtDeath
Float instaDeathMultiplier = 1.0

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
  If (player_property.GetActorValue("Health") <= 0)
    Float percentageNegativeHealth = Math.abs(player_property.GetActorValuePercentage("Health"))
    
    If (percentageNegativeHealth >= QuomoZMinDamageForInstaDeath.GetValue())
      
      Float blockedPenalty = 1.0
      If (abHitBlocked)
        blockedPenalty = Utility.RandomFloat(1.5, 2.0)
      EndIf
      
      Float powerAttackBonus = 1.0
      If (abPowerAttack)
        powerAttackBonus = Utility.RandomFloat(0.3, 0.7)
      EndIf
      
      Float vampirismBonus = 1.0
      If (player_property.HasKeyword(Vampire))
        If (akSource.HasKeyword(WeapMaterialSilver) || akProjectile.HasKeyword(WeapMaterialSilver))
          vampirismBonus = Utility.RandomFloat(0.2, 0.5)
        EndIf
      EndIf
      
      Float healthBonus = Math.abs(QuomoZMinDamageForInstaDeath.GetValue() / percentageNegativeHealth)
      
      instaDeathMultiplier = blockedPenalty*powerAttackBonus*vampirismBonus*healthBonus
      
      If (Utility.RandomFloat()*instaDeathMultiplier < QuomoZBaseChanceForInstaDeath.GetValue())
        QuomoZDeathProfileToggle.SetValueInt(0)
        QuomoZTimeUntilLastSenseLost.SetValue(0.0)
      EndIf
      
    EndIf
  EndIf
EndEvent

Function SendDeathEvent(Float mult)
    Int handle = ModEvent.Create("QuomoZRealisticDeath_PlayerDied")
    If (handle)
        ModEvent.PushFloat(handle, mult)
        ModEvent.Send(handle)
    EndIf
EndFunction

Event OnEnterBleedout()
  Game.DisablePlayerControls(abMovement = true, abFighting = true)
	player_property.StopCombat()
	player_property.StopCombatAlarm()

  GotoState("PlayerDead")
EndEvent

Function KillPlayer()
  player_property.GetActorBase().SetEssential(False)
  player_property.KillEssential()
EndFunction

State PlayerDead
  
  Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)
    If (QuomoZPostmortemBlowInstaDeathToggle.GetValueInt() == 1 && healthAtDeath && healthAtDeath > player_property.GetActorValue("Health"))
      If (!(akSource as Enchantment) && !(akSource as Potion))
        
        ImageSpaceModifier blankHoldIMod = QuomoZFadeToBlackHoldImod;
    
        If (QuomoZBlankScreenToggle.GetValueInt() == 1)
          blankHoldIMod = QuomoZFadeToWhiteHoldImod;
        EndIf
        
        blankHoldIMod.Apply()
        blankHoldIMod = None ; prevent OnBeginState from overriding
        
        If (QuomoZBlankScreenReloadModeToggle.getValueInt() == 0)
          KillPlayer()
        ElseIf (QuomoZBlankScreenReloadModeToggle.getValueInt() == 1)
          Utility.Wait(QuomoZBlankScreenBeforeReloadTime.getValue()); Reflect about your death in darkness
          KillPlayer()
        Else
          RegisterForKey(QuomoZReloadKey.GetValueInt())
        EndIf
      EndIf
    EndIf
  EndEvent
  
  Event OnBeginState()
    healthAtDeath = player_property.GetActorValue("Health")
    ImageSpaceModifier blankHoldIMod = QuomoZFadeToBlackHoldImod;
    
    If (QuomoZBlankScreenToggle.GetValueInt() == 1)
      blankHoldIMod = QuomoZFadeToWhiteHoldImod;
    EndIf

    Float percentageNegativeHealth = Math.abs(player_property.GetActorValuePercentage("Health"))
    Float durationMultiplier = Utility.RandomFloat(1.0 - percentageNegativeHealth, 1.0)
    durationMultiplier = durationMultiplier*durationMultiplier
    
    If (durationMultiplier > 1.0)
      durationMultiplier = 1.0
    ElseIf (durationMultiplier < QuomoZDynamicMinMultiplier.GetValue())
      durationMultiplier = QuomoZDynamicMinMultiplier.GetValue()
    EndIf
    
    
    SendDeathEvent(durationMultiplier) ; allows some multithreading to occur
    
    If (QuomoZFadeVisionToggle.GetValueInt() == 1)
      If (QuomoZDeathProfileToggle.GetValueInt() == 0)
        blankHoldIMod.Apply()
      Else
        Utility.Wait(QuomoZFadeVisionOnset.GetValue()*durationMultiplier)
        blankHoldIMod.ApplyCrossFade(QuomoZFadeVisionSpan.GetValue()*durationMultiplier)
      EndIf
    Else
      ; do nothing
    EndIf
    Debug.Notification("ApplyCrossFade is asynchronous")
    Utility.Wait(QuomoZTimeUntilLastSenseLost.GetValue()*durationMultiplier)
    ;blankHoldIMod.PopTo(blankHoldIMod)
    
    ;Game.FadeOutGame(True, !QuomoZBlankScreenToggle.GetValueInt(), QuomoZFadeVisionOnset.GetValue(), QuomoZFadeVisionSpan.GetValue())
    
    If (QuomoZBlankScreenReloadModeToggle.getValueInt() == 0)
      KillPlayer()
    ElseIf (QuomoZBlankScreenReloadModeToggle.getValueInt() == 1)
      Utility.Wait(QuomoZBlankScreenBeforeReloadTime.getValue()); Reflect about your death in darkness
      KillPlayer()
    Else
      RegisterForKey(QuomoZReloadKey.GetValueInt())
    EndIf
  EndEvent
  
  Event OnKeyUp(Int keyCode, float holdTime)
  If (keyCode == QuomoZReloadKey.GetValue())
    UnregisterForKey(QuomoZReloadKey.GetValueInt())
    KillPlayer()
  EndIf
EndEvent
  
EndState

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

GlobalVariable Property QuomoZDynamicMinMultiplier  Auto  

GlobalVariable Property QuomoZMinDamageForInstaDeath  Auto  

Keyword Property Vampire  Auto  

Keyword Property WeapMaterialSilver  Auto  

GlobalVariable Property QuomoZBaseChanceForInstaDeath  Auto  

GlobalVariable Property QuomoZPostmortemBlowInstaDeathToggle  Auto  

SPELL Property FireboltRightHand  Auto  

SPELL Property QuomoZTestSelfHarm  Auto  
