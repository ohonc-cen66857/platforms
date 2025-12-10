# WIN-DOM-SVC-GEN-T1

**ShrnutĂ­:** ServisnĂ­ ĂşÄŤet pro DomĂ©na na Windows. ProstĹ™edĂ­: GenerickĂ©, Tier: T1.

## KlĂ­ÄŤovĂ© vlastnosti
- **Povolit ruÄŤnĂ­ zmÄ›nu hesla:** Ano
- **PeriodickĂˇ zmÄ›na hesla:** Ano
- **OkamĹľitĂ˝ interval:** 5
- **Interval rotace:** 1440
- **Max. pokusĹŻ:** 5
- **Rozestup mezi pokusy:** 90
- **Timeout:** 30
- **DĂ©lka hesla:** 24
- **Min. velkĂˇ pĂ­smena:** 2
- **Min. malĂˇ pĂ­smena:** 2
- **Min. ÄŤĂ­slice:** Ano
- **Min. speciĂˇlnĂ­ znaky:** Ano
- **DLL konektoru:** PMWindows.dll
- **PovolenĂ© safy (regex):** (?!SH-).*_T1$

## Metadata
- INI: `I:\GitHub\platforms\platforms\WIN-DOM-SVC-GEN-T1\Policy-WIN-DOM-SVC-GEN-T1.ini`
- XML: `I:\GitHub\platforms\platforms\WIN-DOM-SVC-GEN-T1\Policy-WIN-DOM-SVC-GEN-T1.xml` â€” parsed

<details>
<summary>KompletnĂ­ vĂ˝pis INI</summary>

- AllowedSafes: (?!SH-).*_T1$
- AllowManualChange: Yes
- DaysNotifyPriorExpiration: 7
- DllName: PMWindows.dll
- FromHour: -1
- HeadStartInterval: 5
- ChangeNotificationPeriod: -1
- ChangeTask::EnforcePasswordPolicyOnManualChange: Yes
- ChangeTask::EnforcePasswordVersionsHistory: 12
- ImmediateInterval: 5
- Interval: 1440
- MaxConcurrentConnections: 3
- MaximumRetries: 5
- MinDelayBetweenRetries: 90
- MinDigit: 1
- MinLowerCase: 2
- MinSpecial: 1
- MinUpperCase: 2
- MinValidityPeriod: 60
- NFNotifyOnPasswordDisable: Yes
- NFNotifyOnPasswordUsed: No
- NFNotifyOnVerificationErrors: Yes
- NFNotifyPriorExpiration: No
- NFOnPasswordDisableRecipients: 
- NFOnPasswordUsedRecipients: 
- NFOnVerificationErrorsRecipients: 
- NFPriorExpirationRecipients: 
- PasswordLength: 24
- PerformPeriodicChange: Yes
- PolicyID: WIN-DOM-SVC-GEN-T1
- PolicyName: WIN-DOM-SVC-GEN-T1
- PolicyType: Regular
- PreventSameCharPerPrevPassPosition: No
- RCAllowManualReconciliation: Yes
- RCAutomaticReconcileWhenUnsynched: No
- RCFromHour: -1
- RCReconcileReasons: 2114,2115,2106,2101
- RCToHour: -1
- ResetOveridesMinValidity: Yes
- ResetOveridesTimeFrame: Yes
- SearchForUsages: Yes
- Timeout: 30
- ToHour: -1
- UnlockIfFail: No
- UnrecoverableErrors: 2103,2105,2121
- VFAllowManualVerification: Yes
- VFFromHour: -1
- VFPerformPeriodicVerification: Yes
- VFToHour: -1
- XMLFile: Yes

</details>

