
param(
    [Parameter(Mandatory=$true)][string]$IniPath,
    [Parameter()][string]$XmlPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function ConvertFrom-Ini {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string]$Path)

    $flat = @{}
    $section = $null
    foreach ($line in Get-Content -LiteralPath $Path -Encoding UTF8) {
        $s = $line.Trim()
        if (-not $s -or $s.StartsWith(';') -or $s.StartsWith('#')) { continue }
        if ($s.StartsWith('[') -and $s.EndsWith(']')) {
            $section = $s.Substring(1, $s.Length - 2)
            continue
        }
        if ($s -like '*=*') {
            $kv = $s.Split('=',2)
            $k = $kv[0].Trim()
            $v = $kv[1].Trim()
            if ($section) { $flat["$section::$k"] = $v } else { $flat[$k] = $v }
        }
    }
    return $flat
}

function ConvertTo-YesNo {
    [CmdletBinding()]
    param([string]$Value)

    $s = ($Value -as [string])
    if ($null -eq $s) { return $Value }
    $s = $s.Trim().ToLower()
    switch ($s) {
        'yes'  { return 'Ano' }
        'true' { return 'Ano' }
        '1'    { return 'Ano' }
        'on'   { return 'Ano' }
        'no'   { return 'Ne' }
        'false'{ return 'Ne' }
        '0'    { return 'Ne' }
        'off'  { return 'Ne' }
        default{ return $Value }
    }
}

# --- Načtení INI a odvození názvu platformy ---
$flat = ConvertFrom-Ini -Path $IniPath
$name = $flat['PolicyName']
if (-not $name) { $name = ([IO.Path]::GetFileNameWithoutExtension($IniPath) -replace '^Policy-','') }

# OS-SCOPE-ACCT-ENV-TIER
$regex = '^(?<os>[A-Z]{2,6})-(?<scope>[A-Z]{2,10})-(?<acct>[A-Z]{3})-(?<env>[A-Z]{3})-(?<tier>T[0-3])$'
$m = [regex]::Match($name, $regex)

$mapOS    = @{ WIN='Windows'; LIN='Linux'; AIX='AIX'; UNX='Unix'; MAC='macOS'; DB='Databáze' }
$mapScope = @{ DOM='Doména';  LOC='Lokální'; DB='Databázový účet'; MSSQL='Microsoft SQL Server' }
$mapAcct  = @{ SVC='Servisní účet'; INT='Interaktivní účet'; ADM='Admin účet'; APP='Aplikační účet'; API='API/robotický účet' }
$mapEnv   = @{ GEN='Generické'; PROD='Produkce'; PRD='Produkce'; TEST='Test'; TST='Test'; DEV='Vývoj'; QA='QA'; UAT='UAT'; DR='DR' }

$os_h = $scope_h = $acct_h = $env_h = $tier_h = $null
if ($m.Success) {
    $osKey    = $m.Groups['os'].Value
    $scopeKey = $m.Groups['scope'].Value
    $acctKey  = $m.Groups['acct'].Value
    $envKey   = $m.Groups['env'].Value
    $tier_h   = $m.Groups['tier'].Value

    $os_h    = if ($mapOS.ContainsKey($osKey))    { $mapOS[$osKey] }    else { $osKey }
    $scope_h = if ($mapScope.ContainsKey($scopeKey)) { $mapScope[$scopeKey] } else { $scopeKey }
    $acct_h  = if ($mapAcct.ContainsKey($acctKey))  { $mapAcct[$acctKey] }   else { $acctKey }
    $env_h   = if ($mapEnv.ContainsKey($envKey))   { $mapEnv[$envKey] }     else { $envKey }
}

# Klíče, které vytáhneme z INI
$keys = [ordered]@{
    'AllowManualChange'            = 'Povolit ruční změnu hesla'
    'PerformPeriodicChange'        = 'Periodická změna hesla'
    'ImmediateInterval'            = 'Okamžitý interval'
    'Interval'                     = 'Interval rotace'
    'MaximumRetries'               = 'Max. pokusů'
    'MinDelayBetweenRetries'       = 'Rozestup mezi pokusy'
    'Timeout'                      = 'Timeout'
    'PasswordLength'               = 'Délka hesla'
    'MinUpperCase'                 = 'Min. velká písmena'
    'MinLowerCase'                 = 'Min. malá písmena'
    'MinDigit'                     = 'Min. číslice'
    'MinSpecial'                   = 'Min. speciální znaky'
    'PasswordForbiddenChars'       = 'Zakázané znaky'
    'ExtraInfo::ChangeCommand'     = 'ChangeCommand'
    'ExtraInfo::ReconcileCommand'  = 'ReconcileCommand'
    'ExtraInfo::ConnectionCommand' = 'ConnectionCommand'
    'DllName'                      = 'DLL konektoru'
    'AllowedSafes'                 = 'Povolené safy (regex)'
}

function Get-IniValue {
    [CmdletBinding()]
    param([string]$Key)

    if ($flat.ContainsKey($Key)) { return $flat[$Key] }
    if ($Key -like '*::*') {
        $base = $Key.Split('::',2)[1]
        if ($flat.ContainsKey($base)) { return $flat[$base] }
    }
    return $null
}

# --- Sestavení Markdownu ---
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine(("# {0}" -f $name))
[void]$sb.AppendLine("")

if ($os_h) {
    [void]$sb.AppendLine(("**Shrnutí:** {0} pro {1} na {2}. Prostředí: {3}, Tier: {4}." -f $acct_h, $scope_h, $os_h, $env_h, $tier_h))
    [void]$sb.AppendLine("")
}

[void]$sb.AppendLine("## Klíčové vlastnosti")
$foundAny = $false
foreach ($kvp in $keys.GetEnumerator()) {
    $v = Get-IniValue -Key $kvp.Key
    if ($null -ne $v) {
        $foundAny = $true
        $lower = $v.ToString().ToLower()
        if (@('yes','no','true','false','0','1','on','off') -contains $lower) {
            $v = ConvertTo-YesNo -Value $v
        }
        [void]$sb.AppendLine(("- **{0}:** {1}" -f $kvp.Value, $v))
    }
}
if (-not $foundAny) {
    [void]$sb.AppendLine("- (Nenalezeny známé klíče.)")
}
[void]$sb.AppendLine("")

[void]$sb.AppendLine("## Metadata")
[void]$sb.AppendLine( ('- INI: `{0}`' -f (Resolve-Path -LiteralPath $IniPath)) )
if ($XmlPath) {
    try {
        [xml]$xmlObj = Get-Content -LiteralPath $XmlPath -ErrorAction Stop
        [void]$sb.AppendLine( ('- XML: `{0}` — parsed' -f (Resolve-Path -LiteralPath $XmlPath)) )
    } catch {
        [void]$sb.AppendLine( ('- XML: `{0}` — error: {1}' -f (Resolve-Path -LiteralPath $XmlPath), $_.Exception.Message) )
    }
}
[void]$sb.AppendLine("")

[void]$sb.AppendLine('<details>')
[void]$sb.AppendLine('<summary>Kompletní výpis INI</summary>')
[void]$sb.AppendLine('')
foreach ($k in ($flat.Keys | Sort-Object)) {
    [void]$sb.AppendLine( ('- {0}: {1}' -f $k, $flat[$k]) )
}
[void]$sb.AppendLine('')
[void]$sb.AppendLine('</details>')
[void]$sb.AppendLine('')

# Výstupní cesta: platforms\docs\<NAME>.md (stejně jako generate.py)
$platformDir  = Split-Path -Parent $IniPath         # ...\platforms\<NAME>
$platformsRoot = Split-Path -Parent $platformDir    # ...\platforms
$outDir  = Join-Path $platformsRoot 'docs'
$outPath = Join-Path $outDir "$name.md"

New-Item -ItemType Directory -Path $outDir -Force | Out-Null

# UTF-8 bez BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($outPath, $sb.ToString(), $utf8NoBom)

Write-Output $outPath
