# UX-PWD-SVC-AIX-GEN-T1

## KlĂ­ÄŤovĂ© vlastnosti
- **Povolit ruÄŤnĂ­ zmÄ›nu hesla:** Ano
- **PeriodickĂˇ zmÄ›na hesla:** Ano
- **OkamĹľitĂ˝ interval:** 5
- **Interval rotace:** 1440
- **Max. pokusĹŻ:** 5
- **Rozestup mezi pokusy:** 90
- **Timeout:** 90
- **DĂ©lka hesla:** 24
- **Min. velkĂˇ pĂ­smena:** 2
- **Min. malĂˇ pĂ­smena:** 2
- **Min. ÄŤĂ­slice:** Ano
- **Min. speciĂˇlnĂ­ znaky:** Ano
- **ZakĂˇzanĂ© znaky:** 
- **PovolenĂ© safy (regex):** (?!SH-).*_T1$

## Metadata
- INI: `I:\GitHub\platforms\platforms\UX-PWD-SVC-AIX-GEN-T1\Policy-UX-PWD-SVC-AIX-GEN-T1.ini`
- XML: `I:\GitHub\platforms\platforms\UX-PWD-SVC-AIX-GEN-T1\Policy-UX-PWD-SVC-AIX-GEN-T1.xml` â€” parsed

<details>
<summary>KompletnĂ­ vĂ˝pis INI</summary>

- AllowedSafes: (?!SH-).*_T1$
- AllowManualChange: Yes
- DaysNotifyPriorExpiration: 7
- ExeName: CyberArk.TPC.exe
- ExtraInfo::Debug: Yes
- ExtraInfo::Port: 22
- ExtraInfo::ProcessFilename: bin\UnixProcess.ini
- ExtraInfo::PromptsFilename: bin\UnixPrompts.ini
- ExtraInfo::protocol: ssh
- ExtraInfo::UseSudoOnReconcile: No
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
- PasswordForbiddenChars: 
- PasswordLength: 24
- PerformPeriodicChange: Yes
- PolicyID: UX-PWD-SVC-AIX-GEN-T1
- PolicyName: UX-PWD-SVC-AIX-GEN-T1
- PolicyType: Regular
- RCAllowManualReconciliation: Yes
- RCAutomaticReconcileWhenUnsynched: No
- RCFromHour: -1
- RCReconcileReasons: 2114,2115,2106,2101
- RCToHour: -1
- ResetOveridesMinValidity: Yes
- ResetOveridesTimeFrame: Yes
- Timeout: 90
- ToHour: -1
- UnlockIfFail: No
- UnrecoverableErrors: 8002,8003,8006,8007,8010,8011,8012,2117
- VFAllowManualVerification: Yes
- VFFromHour: -1
- VFPerformPeriodicVerification: Yes
- VFToHour: -1
- XMLFile: No

</details>

