# DB-ORA-INT-SYSDBA-GEN-T1

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
- **ZakĂˇzanĂ© znaky:** '\/@".;{}()-|*>~!^#
- **ChangeCommand:** alter user %USER% identified by "%NEWPASSWORD%" replace "%OLDPASSWORD%";
- **ReconcileCommand:** alter user %USER% identified by "%NEWPASSWORD%";
- **ConnectionCommand:** Driver={Oracle in instantclient_19_26};Dbq=//%ADDRESS%:%PORT%/%DATABASE%;Uid=%USER%;Pwd=%LOGONPASSWORD% AS SYSDBA;
- **DLL konektoru:** PMODBC.dll
- **PovolenĂ© safy (regex):** (?!SH-).*_T1$

## Metadata
- INI: `I:\GitHub\platforms\platforms\DB-ORA-INT-SYSDBA-GEN-T1\Policy-DB-ORA-INT-SYSDBA-GEN-T1.ini`
- XML: `I:\GitHub\platforms\platforms\DB-ORA-INT-SYSDBA-GEN-T1\Policy-DB-ORA-INT-SYSDBA-GEN-T1.xml` â€” parsed

<details>
<summary>KompletnĂ­ vĂ˝pis INI</summary>

- AllowedSafes: (?!SH-).*_T1$
- AllowManualChange: Yes
- DaysNotifyPriorExpiration: 7
- DllName: PMODBC.dll
- ExtraInfo::CommandBlackList: delete,drop,exec,create,alter,rename,truncate,comment,select,insert,update,merge,call,explain,lock,grant,revoke
- ExtraInfo::CommandForbiddenCharacters: '\/@".{}()
- ExtraInfo::ConnectionCommand: Driver={Oracle in instantclient_19_26};Dbq=//%ADDRESS%:%PORT%/%DATABASE%;Uid=%USER%;Pwd=%LOGONPASSWORD% AS SYSDBA;
- ExtraInfo::Debug: No
- ExtraInfo::ChangeCommand: alter user %USER% identified by "%NEWPASSWORD%" replace "%OLDPASSWORD%";
- ExtraInfo::Port: 1521
- ExtraInfo::ReconcileCommand: alter user %USER% identified by "%NEWPASSWORD%";
- FromHour: -1
- HeadStartInterval: 5
- ChangeNotificationPeriod: -1
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
- PasswordForbiddenChars: '\/@".;{}()-|*>~!^#
- PasswordLength: 24
- PerformPeriodicChange: Yes
- PolicyID: DB-ORA-INT-SYSDBA-GEN-T1
- PolicyName: DB-ORA-INT-SYSDBA-GEN-T1
- PolicyType: Regular
- RCAllowManualReconciliation: Yes
- RCAutomaticReconcileWhenUnsynched: No
- RCFromHour: -1
- RCReconcileReasons: 2114,2115,2106,2101,2118
- RCToHour: -1
- ResetOveridesMinValidity: Yes
- ResetOveridesTimeFrame: Yes
- Timeout: 30
- ToHour: -1
- UnlockIfFail: No
- UnrecoverableErrors: 5001,5002,5003,5004,5005,5006,2117
- VFAllowManualVerification: Yes
- VFFromHour: -1
- VFPerformPeriodicVerification: Yes
- VFToHour: -1
- XMLFile: Yes

</details>

