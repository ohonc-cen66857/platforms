
param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,            # Directory with ZIPs / glob / single ZIP

    [Parameter()]
    [string]$RepoRoot = '.',       # Repo root

    [Parameter()]
    [switch]$Recurse,              # Search ZIPs recursively if InputPath is a directory

    [Parameter()]
    [string]$LogPath               # Optional: explicit log path; defaults to tools\logs\import-<timestamp>.log
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Resolve repo root and tools dir
$RepoRoot  = (Resolve-Path $RepoRoot).Path
$ScriptDir = Split-Path -Parent $PSCommandPath    # ...\tools

# ---------- Logging (ASCII, robust) ----------
# Default log location
if (-not $LogPath -or [string]::IsNullOrWhiteSpace($LogPath)) {
    $logDir = Join-Path $RepoRoot 'tools\logs'
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    $LogPath = Join-Path $logDir ("import-" + (Get-Date -Format 'yyyyMMdd-HHmmss') + ".log")
} else {
    # If someone passed a .ps1 as LogPath by accident, redirect to .log
    $ext = [IO.Path]::GetExtension($LogPath)
    if ($ext -eq '.ps1') { $LogPath = [IO.Path]::ChangeExtension($LogPath, '.log') }
    $logParent = Split-Path -Parent $LogPath
    if ($logParent -and -not (Test-Path $logParent -PathType Container)) {
        New-Item -ItemType Directory -Path $logParent -Force | Out-Null
    }
}
# StreamWriter (append, UTF-8 no BOM)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$logWriter = New-Object System.IO.StreamWriter($LogPath, $true, $utf8NoBom)
$logWriter.AutoFlush = $true

function Write-Log {
    param(
        [ValidateSet('INFO','WARN','ERROR')][string]$Level = 'INFO',
        [Parameter(Mandatory=$true)][string]$Message
    )
    $line = "[{0}] {1} {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
    $script:logWriter.WriteLine($line)
}

function Close-Log {
    try { $script:logWriter.Flush() } catch {}
    try { $script:logWriter.Dispose() } catch {}
}

Write-Log -Level INFO -Message ("Start import | InputPath={0} | RepoRoot={1} | Recurse={2}" -f $InputPath, $RepoRoot, ($Recurse.IsPresent))

# ---------- Helpers ----------
function Get-PlatformNameFromIni {
    param([string]$IniPath)
    $m = Select-String -Path $IniPath -Pattern '^\s*PolicyName\s*=\s*(.+)$' | Select-Object -First 1
    if ($m) { $val = ($m.Matches.Value.Split('=')[1]).Trim(); if ($val) { return $val } }
    return ([IO.Path]::GetFileNameWithoutExtension($IniPath) -replace '^Policy-','')
}

function Expand-PlatformZip {
    param([string]$ZipPath)

    $temp = Join-Path $env:TEMP ('plat_' + [guid]::NewGuid())
    New-Item -ItemType Directory -Path $temp | Out-Null
    try {
        try { Expand-Archive -Path $ZipPath -DestinationPath $temp -Force }
        catch { Add-Type -AssemblyName System.IO.Compression.FileSystem; [IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $temp) }

        $ini = Get-ChildItem $temp -Recurse -Filter *.ini -File | Select-Object -First 1
        $xml = Get-ChildItem $temp -Recurse -Filter *.xml -File | Select-Object -First 1
        if (-not $ini -or -not $xml) { throw "ZIP does not contain both .ini and .xml." }

        $plat = Get-PlatformNameFromIni -IniPath $ini.FullName
        if ([string]::IsNullOrWhiteSpace($plat)) { throw "Cannot derive platform name." }

        $platDir = Join-Path $RepoRoot ('platforms\' + $plat)
        New-Item -ItemType Directory -Path $platDir -Force | Out-Null

        $iniOut = Join-Path $platDir ("Policy-$plat.ini")
        $xmlOut = Join-Path $platDir ("Policy-$plat.xml")
        Copy-Item $ini.FullName $iniOut -Force
        Copy-Item $xml.FullName $xmlOut -Force

        # Call generator
        $genScript = Join-Path $ScriptDir 'generate.ps1'
        if (-not (Test-Path $genScript -PathType Leaf)) { $genScript = Join-Path $RepoRoot 'tools\generate.ps1' }
        if (-not (Test-Path $genScript -PathType Leaf)) { throw "tools\generate.ps1 not found." }

        $generatedPath = & $genScript -IniPath $iniOut -XmlPath $xmlOut

        Write-Log -Level INFO -Message ("Processed | ZIP={0} | Platform={1} | INI={2} | XML={3} | Doc={4}" -f $ZipPath, $plat, $iniOut, $xmlOut, $generatedPath)

        return [pscustomobject]@{ Zip=$ZipPath; Platform=$plat; Ini=$iniOut; Xml=$xmlOut; Doc=$generatedPath; Status='OK'; Message='' }
    }
    catch {
        Write-Log -Level ERROR -Message ("Error while processing ZIP={0} | {1}" -f $ZipPath, $_.Exception.Message)
        return [pscustomobject]@{ Zip=$ZipPath; Platform=$null; Ini=$null; Xml=$null; Doc=$null; Status='ERROR'; Message=$_.Exception.Message }
    }
    finally {
        Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ---------- Main with full exception logging ----------
try {
    # Build list of ZIPs
    $zipList = @()
    if (Test-Path $InputPath -PathType Leaf) {
        if ([IO.Path]::GetExtension($InputPath).ToLowerInvariant() -ne '.zip') {
            Write-Log -Level WARN -Message ("Given file is not .zip: {0}" -f $InputPath)
        } else {
            $zipList = @((Resolve-Path -LiteralPath $InputPath).Path)  # force array
        }
    }
    elseif (Test-Path $InputPath -PathType Container) {
        if ($Recurse) {
            $zipList = @(Get-ChildItem -LiteralPath $InputPath -Recurse -Filter *.zip -File | Select-Object -ExpandProperty FullName)
        } else {
            $zipList = @(Get-ChildItem -LiteralPath $InputPath -Filter *.zip -File | Select-Object -ExpandProperty FullName)
        }
    }
    else {
        # glob pattern, e.g. C:\Downloads\*.zip
        $zipList = @(Get-ChildItem -Path $InputPath -File -ErrorAction SilentlyContinue |
                     Where-Object { $_.Extension -ieq '.zip' } |
                     Select-Object -ExpandProperty FullName)
    }

    if (-not $zipList -or @($zipList).Count -eq 0) {
        Write-Log -Level WARN -Message ("No ZIPs found to process (input: {0})." -f $InputPath)
        Write-Log -Level INFO -Message ("End import | Log={0}" -f $LogPath)
        Close-Log
        return
    }

    Push-Location $RepoRoot
    try {
        $results = New-Object System.Collections.Generic.List[object]
        foreach ($zip in $zipList) {
            Write-Log -Level INFO -Message ("Processing ZIP: {0}" -f $zip)
            $res = Expand-PlatformZip -ZipPath $zip
            $results.Add($res) | Out-Null
        }

        # Summary
        $ok        = $results | Where-Object { $_.Status -eq 'OK' }
        $errs      = $results | Where-Object { $_.Status -ne 'OK' }
        $okCount   = @($ok).Count
        $errsCount = @($errs).Count

        Write-Log -Level INFO -Message ("Summary | OK={0} | ERRORS={1}" -f $okCount, $errsCount)
        foreach ($r in @($ok))  { Write-Log -Level INFO  -Message ("OK  | {0} -> {1}" -f $r.Platform, $r.Doc) }
        foreach ($e in @($errs)){ Write-Log -Level ERROR -Message ("ERR | {0} -> {1}" -f $e.Zip, $e.Message) }

        # Return array (pipe-friendly)
        @($results.ToArray())
    }
    finally {
        Pop-Location
        Write-Log -Level INFO -Message ("End import | Log={0}" -f $LogPath)
        Close-Log
    }
}
catch {
    # Log full exception details and rethrow for visibility
    $ex = $_.Exception
    Write-Log -Level ERROR -Message ("FATAL: {0}" -f $ex.Message)
    Write-Log -Level ERROR -Message ("TYPE: {0}" -f $ex.GetType().FullName)
    Write-Log -Level ERROR -Message ("STACK: {0}" -f ($ex.StackTrace -replace "`r?`n",' | '))
    Close-Log
    throw
}
