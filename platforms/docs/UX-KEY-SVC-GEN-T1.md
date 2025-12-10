# UX-KEY-SVC-GEN-T1

**ShrnutĂ­:** ServisnĂ­ ĂşÄŤet pro KEY na UX. ProstĹ™edĂ­: GenerickĂ©, Tier: T1.

## KlĂ­ÄŤovĂ© vlastnosti
- **Povolit ruÄŤnĂ­ zmÄ›nu hesla:** Ano
- **PeriodickĂˇ zmÄ›na hesla:** Ano
- **OkamĹľitĂ˝ interval:** 5
- **Interval rotace:** 1440
- **Max. pokusĹŻ:** 5
- **Rozestup mezi pokusy:** 90
- **Timeout:** 90
- **DLL konektoru:** PMUnixSSHKeys.dll
- **PovolenĂ© safy (regex):** ^(?!SH).*_T1$

## Metadata
- INI: `I:\GitHub\platforms\platforms\UX-KEY-SVC-GEN-T1\Policy-UX-KEY-SVC-GEN-T1.ini`
- XML: `I:\GitHub\platforms\platforms\UX-KEY-SVC-GEN-T1\Policy-UX-KEY-SVC-GEN-T1.xml` â€” parsed

<details>
<summary>KompletnĂ­ vĂ˝pis INI</summary>

- AllowedSafes: ^(?!SH).*_T1$
- AllowManualChange: Yes
- DaysNotifyPriorExpiration: 7
- DllName: PMUnixSSHKeys.dll
- ExeName: CANetPluginInvoker.exe
- ExtraInfo::BackupFile: true
- ExtraInfo::CommandExecutionTimeout: 30
- ExtraInfo::ConnectionTimeout: 30
- ExtraInfo::ManagementType: SSHKey
- ExtraInfo::PopulateIfNotExist: No
- ExtraInfo::Port: 22
- ExtraInfo::protocol: ssh
- ExtraInfo::StandardPrompt: .*\$ ?$|.*\# ?$|.*\> ?$|.*\% ?$|.*\] ?$
- ExtraInfo::UseSudoOnReconcile: No
- FromHour: -1
- HeadStartInterval: 5
- ChangeNotificationPeriod: -1
- ChangeTask::EnforcePasswordVersionsHistory: -1
- ImmediateInterval: 5
- Interval: 1440
- KeyEncryption: RSA
- KeyGenerationTimeout: 90
- KeySize: 2048
- MaxConcurrentConnections: 3
- MaximumRetries: 5
- MinDelayBetweenRetries: 90
- MinValidityPeriod: 60
- NewKeyDistributionMethod: Direct
- NFNotifyOnPasswordDisable: Yes
- NFNotifyOnPasswordUsed: No
- NFNotifyOnVerificationErrors: Yes
- NFNotifyPriorExpiration: No
- NFOnPasswordDisableRecipients: 
- NFOnPasswordUsedRecipients: 
- NFOnVerificationErrorsRecipients: 
- NFPriorExpirationRecipients: 
- PerformPeriodicChange: Yes
- PolicyID: UX-KEY-SVC-GEN-T1
- PolicyName: UX-KEY-SVC-GEN-T1
- PolicyType: Regular
- PopulateKeyIfNotExist: No
- PrivateKeyFormat: OpenSSH
- PublicSSHKeyPath: ~/.ssh/authorized_keys
- RCAllowManualReconciliation: Yes
- RCAutomaticReconcileWhenUnsynched: No
- RCFromHour: -1
- RCReconcileReasons: 8030,8033,8035,8042,8046
- RCToHour: -1
- ResetOveridesMinValidity: Yes
- ResetOveridesTimeFrame: Yes
- SearchForUsages: Yes
- Timeout: 90
- ToHour: -1
- UnlockIfFail: No
- UnrecoverableErrors: 7378,8031,8032,8033,8034,8040,8042,8043,8044,8091,8101
- VFAllowManualVerification: Yes
- VFFromHour: -1
- VFPerformPeriodicVerification: Yes
- VFToHour: -1
- XMLFile: Yes

</details>

