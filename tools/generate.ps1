
param(
    [Parameter(Mandatory=$true)][string]$IniPath,
    [Parameter()][string]$XmlPath,
    [Parameter()][string]$ConventionCsv # pokud se nepĹ™edĂˇ, vezme tools\name_convention.csv
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Pokud nenĂ­ CSV pĹ™edĂˇno, hledej v tools\name_convention.csv
if (-not $ConventionCsv -or [string]::IsNullOrWhiteSpace($ConventionCsv)) {
    $ScriptDir = Split-Path -Parent $PSCommandPath
    $ConventionCsv = Join-Path $ScriptDir 'name_convention.csv'
}

# --- IO helpery --------------------------------------------------------------
function Get-FileText {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string]$Path)
    try { Get-Content -LiteralPath $Path -Raw -Encoding UTF8 }
    catch { Get-Content -LiteralPath $Path -Raw -Encoding Default }
}

function ConvertFrom-Ini {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string]$Path)
    $flat = @{}
    $section = $null
    foreach ($line in (Get-FileText -Path $Path) -split '\r?\n') {
        $s = $line.Trim()
        if (-not $s -or $s.StartsWith(';') -or $s.StartsWith('#')) { continue }
        if ($s.StartsWith('[') -and $s.EndsWith(']')) { $section = $s.Substring(1, $s.Length - 2); continue }
        if ($s -like '*=*') {
            $kv = $s.Split('=',2); $k = $kv[0].Trim(); $v = $kv[1].Trim()
            if ($section) { $flat["$section::$k"] = $v } else { $flat[$k] = $v }
        }
    }
    return $flat
}

function ConvertTo-YesNo {
    [CmdletBinding()]
    param([string]$Value)
    $s = ($Value -as [string]); if ($null -eq $s) { return $Value }
    switch ($s.Trim().ToLowerInvariant()) {
        'yes' { 'Ano' } 'true' { 'Ano' } '1' { 'Ano' } 'on' { 'Ano' }
        'no'  { 'Ne'  } 'false'{ 'Ne'  } '0' { 'Ne'  } 'off'{ 'Ne'  }
        default { $Value }
    }
}

# --- Konvence z CSV ----------------------------------------------------------
function Get-ConventionsFromCsv {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string]$CsvPath)

    $conv = @{
        OS=@{}; Platform=@{}; Acct=@{}; Role=@{}; Env=@{}; Wf=@{}; Tier=@{}
    }

    $current = $null
    foreach ($raw in (Get-FileText -Path $CsvPath) -split '\r?\n') {
        $line = $raw.Trim()
        if (-not $line) { continue }

        # Sekce
        if ($line -ieq 'System')       { $current='OS';       continue }
        if ($line -ieq 'Platform')     { $current='Platform'; continue }
        if ($line -ieq 'Account Type') { $current='Acct';     continue }
        if ($line -ieq 'Role/SAS')     { $current='Role';     continue }
        if ($line -ieq 'Environment')  { $current='Env';      continue }
        if ($line -ieq 'Workflows')    { $current='Wf';       continue }
        if ($line -ieq 'Tier')         { $current='Tier';     continue }

        # PoloĹľky ve tvaru ;Popis;Zkratka
        $cols = $line.Split(';')
        if ($cols.Count -lt 3) { continue }
        $label = $cols[1].Trim()
        $code  = $cols[2].Trim()
        if ([string]::IsNullOrWhiteSpace($label) -or [string]::IsNullOrWhiteSpace($code)) { continue }
        if ($code -eq '<blank>') { $code = '' }

        switch ($current) {
            'OS'       { $conv.OS[$code]       = $label }
            'Platform' { $conv.Platform[$code] = $label }
            'Acct'     { $conv.Acct[$code]     = $label }
            'Role'     { $conv.Role[$code]     = $label }
            'Env'      { $conv.Env[$code]      = $label }
            'Wf'       { $conv.Wf[$code]       = $label }
            'Tier'     { $conv.Tier[$code]     = $label }
        }
    }
    return $conv
}

# --- Parser nĂˇzvu: OS-Platform-Account-[Role?]-Env-[Workflow?]-[Tier?] --------
function Get-PlatformParts {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)]$Conv
    )
    $parts = $Name.Split('-')
    if ($parts.Count -lt 3) { return $null }

    $i=0; $os=$parts[$i]; $i++; $plat=$parts[$i]; $i++; $acct=$parts[$i]; $i++
    $role=$null
    if ($i -lt $parts.Count -and $Conv.Role.ContainsKey($parts[$i])) { $role=$parts[$i]; $i++ }
    if ($i -ge $parts.Count) { return $null }
    $env=$parts[$i]; $i++
    $wf=$null
    if ($i -lt $parts.Count -and $Conv.Wf.ContainsKey($parts[$i])) { $wf=$parts[$i]; $i++ }
    $tier=$null
    if ($i -lt $parts.Count -and $parts[$i] -match '^T[0-2]$') { $tier=$parts[$i]; $i++ }

    $osName   = (if ($Conv.OS.ContainsKey($os))       { $Conv.OS[$os]       } else { $os })
    $platName = (if ($Conv.Platform.ContainsKey($plat)){ $Conv.Platform[$plat]} else { $plat })
    $acctName = (if ($Conv.Acct.ContainsKey($acct))   { $Conv.Acct[$acct]   } else { $acct })
    $roleName = (if ($role -and $Conv.Role.ContainsKey($role)) { $Conv.Role[$role] } else { $null })
    $envName  = (if ($Conv.Env.ContainsKey($env))     { $Conv.Env[$env]     } else { $env })
    $wfName   = (if ($wf -and $Conv.Wf.ContainsKey($wf)) { $Conv.Wf[$wf]     } else { $null })
    $tierName = (if ($tier -and $Conv.Tier.ContainsKey($tier)) { $Conv.Tier[$tier] } else { $null })

    [pscustomobject]@{
        OsCode=$os;   OsName=$osName
        PlatCode=$plat;PlatName=$platName
        AcctCode=$acct;AcctName=$acctName
        RoleCode=$role;RoleName=$roleName
        EnvCode=$env;  EnvName=$envName
        WfCode=$wf;    WfName=$wfName
        TierCode=$tier;TierName=$tierName
    }
}

# --- UĹľivatelskĂ˝ popis --------------------------------------------------------
function Get-UserSummary {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)]$Parsed)

    $psmNote = $null
    if     ($Parsed.AcctCode -eq 'INT') { $psmNote = 's moĹľnostĂ­ pĹ™ipojenĂ­ pĹ™es PSM' }
    elseif ($Parsed.AcctCode -eq 'SVC') { $psmNote = 'bez interaktivnĂ­ho pĹ™ipojenĂ­ (SVC)' }

    $envNote  = if ($Parsed.EnvCode -eq 'GEN') { 'vhodnĂˇ pro vĹˇechna prostĹ™edĂ­ bez speciĂˇlnĂ­ho nastavenĂ­' } else { ("prostĹ™edĂ­: {0}" -f $Parsed.EnvName) }
    $tierNote = $null; if ($Parsed.TierName)   { $tierNote = $Parsed.TierName.ToLower() }
    $roleNote = $null; if ($Parsed.RoleName)   { $roleNote = ("role/SAS: {0}" -f $Parsed.RoleName) }
    $wfNote   = $null; if ($Parsed.WfName)     { $wfNote   = ("workflow: {0}" -f $Parsed.WfName) }

    $fragments = @("Platforma pro {0}" -f $Parsed.PlatName, "ĂşÄŤty typu {0}" -f $Parsed.AcctName)
    if ($psmNote) { $fragments += $psmNote }
    $sentence1 = ($fragments -join ' ')

    $more = @($envNote)
    if ($tierNote) { $more += $tierNote }
    if ($roleNote) { $more += $roleNote }
    if ($wfNote)   { $more += $wfNote }
    $sentence2 = ($more -join ', ')

    ("{0}. {1}." -f $sentence1, $sentence2)
}

# --- NaÄŤti INI, CSV, rozparsuj nĂˇzev -----------------------------------------
$flat   = ConvertFrom-Ini -Path $IniPath
$name   = $flat['PolicyName']; if (-not $name) { $name = ([IO.Path]::GetFileNameWithoutExtension($IniPath) -replace '^Policy-','') }
$conv   = Get-ConventionsFromCsv -CsvPath $ConventionCsv
$parsed = Get-PlatformParts -Name $name -Conv $conv

# --- KlĂ­ÄŤovĂ© vlastnosti (vĂ˝bÄ›r z INI) ----------------------------------------
$keys = [ordered]@{
    'AllowManualChange'            = 'Povolit ruÄŤnĂ­ zmÄ›nu hesla'
    'PerformPeriodicChange'        = 'PeriodickĂˇ zmÄ›na hesla'
    'ImmediateInterval'            = 'OkamĹľitĂ˝ interval'
    'Interval'                     = 'Interval rotace'
    'MaximumRetries'               = 'Max. pokusĹŻ'
    'MinDelayBetweenRetries'       = 'Rozestup mezi pokusy'
    'Timeout'                      = 'Timeout'
    'PasswordLength'               = 'DĂ©lka hesla'
    'MinUpperCase'                 = 'Min. velkĂˇ pĂ­smena'
    'MinLowerCase'                 = 'Min. malĂˇ pĂ­smena'
    'MinDigit'                     = 'Min. ÄŤĂ­slice'
    'MinSpecial'                   = 'Min. speciĂˇlnĂ­ znaky'
    'PasswordForbiddenChars'       = 'ZakĂˇzanĂ© znaky'
    'ExtraInfo::ChangeCommand'     = 'ChangeCommand'
    'ExtraInfo::ReconcileCommand'  = 'ReconcileCommand'
    'ExtraInfo::ConnectionCommand' = 'ConnectionCommand'
    'DllName'                      = 'DLL konektoru'
    'AllowedSafes'                 = 'PovolenĂ© safy (regex)'
}

function Get-IniValue {
    [CmdletBinding()]
    param([string]$Key)
    if ($flat.ContainsKey($Key)) { return $flat[$Key] }
    if ($Key -like '*::*') {
        $base = $Key.Split('::',2)[1]
        if ($flat.ContainsKey($base)) { return $flat[$base] }
    }
    $null
}

# --- SloĹľ Markdown ------------------------------------------------------------
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine(("# {0}" -f $name))
[void]$sb.AppendLine("")

if ($null -ne $parsed) {
    $tierBit = ''
    if ($parsed.TierName) { $tierBit = ", Tier: $($parsed.TierName)" }
    [void]$sb.AppendLine( ("**ShrnutĂ­:** {0} pro {1} na {2}. ProstĹ™edĂ­: {3}{4}." -f $parsed.AcctName, $parsed.PlatName, $parsed.OsName, $parsed.EnvName, $tierBit) )
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("### UĹľivatelskĂ˝ popis")
    [void]$sb.AppendLine( (Get-UserSummary -Parsed $parsed) )
    [void]$sb.AppendLine("")
}

[void]$sb.AppendLine("## KlĂ­ÄŤovĂ© vlastnosti")
$foundAny = $false
foreach ($kvp in $keys.GetEnumerator()) {
    $v = Get-IniValue -Key $kvp.Key
    if ($null -ne $v) {
        $foundAny = $true
        $lower = $v.ToString().ToLowerInvariant()
        if (@('yes','no','true','false','0','1','on','off') -contains $lower) {
            $v = ConvertTo-YesNo -Value $v
        }
        [void]$sb.AppendLine( ("- **{0}:** {1}" -f $kvp.Value, $v) )
    }
}
if (-not $foundAny) { [void]$sb.AppendLine("- (Nenalezeny znĂˇmĂ© klĂ­ÄŤe.)") }
[void]$sb.AppendLine("")

# --- Metadata (opraveno) -----------------------------------------------------
[void]$sb.AppendLine("## Metadata")
$bt = [char]0x60  # backtick
$iniResolved = (Resolve-Path -LiteralPath $IniPath)
[void]$sb.AppendLine( ("- INI: {0}{1}{0}" -f $bt, $iniResolved) )
if ($XmlPath) {
    try {
        $null = xml
        $xmlResolved = (Resolve-Path -LiteralPath $XmlPath)
        [void]$sb.AppendLine( ("- XML: {0}{1}{0} â€” parsed" -f $bt, $xmlResolved) )
    } catch {
        $xmlResolved = (Resolve-Path -LiteralPath $XmlPath)
        [void]$sb.AppendLine( ("- XML: {0}{1}{0} â€” error: {2}" -f $bt, $xmlResolved, $_.Exception.Message) )
    }
}
[void]$sb.AppendLine("")

# --- KompletnĂ­ vĂ˝pis INI -----------------------------------------------------
[void]$sb.AppendLine("<details>")
[void]$sb.AppendLine("<summary>KompletnĂ­ vĂ˝pis INI</summary>")
[void]$sb.AppendLine("")
foreach ($k in ($flat.Keys | Sort-Object)) {
    [void]$sb.AppendLine( ('- {0}: {1}' -f $k, $flat[$k]) )
}
[void]$sb.AppendLine("")
[void]$sb.AppendLine("</details>")
[void]$sb.AppendLine("")

# --- ZĂˇpis souboru -----------------------------------------------------------
$platformDir   = Split-Path -Parent $IniPath
$platformsRoot = Split-Path -Parent $platformDir
$outDir  = Join-Path $platformsRoot 'docs'
$outPath = Join-Path $outDir "$name.md"

New-Item -ItemType Directory -Path $outDir -Force | Out-Null

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($outPath, $sb.ToString(), $utf8NoBom)

Write-Output $outPath
