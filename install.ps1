# GeckoGraph CLI installer for Windows.
# Checks the download against the published SHA256SUMS. The release is not signed.
$ErrorActionPreference = "Stop"

$Origin = "https://app.geckograph.com"
$Version = if ($env:GECKOGRAPH_VERSION) { $env:GECKOGRAPH_VERSION } else { "latest" }
$BinDir = if ($env:GECKOGRAPH_BIN_DIR) { $env:GECKOGRAPH_BIN_DIR } else { Join-Path $env:USERPROFILE ".geckograph\bin" }

$Arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "aarch64" } else { "x86_64" }
$FileName = "geckograph-windows-$Arch"

if ($Version -eq "latest") {
  $Version = (Invoke-WebRequest -UseBasicParsing "$Origin/cli/latest").Content.Trim()
  $Url = "$Origin/cli/$FileName"
  $SumsUrl = "$Origin/cli/SHA256SUMS"
} else {
  $Url = "$Origin/cli/v$Version/$FileName"
  $SumsUrl = "$Origin/cli/v$Version/SHA256SUMS"
}

if ($Version -notmatch '^\d+\.\d+\.\d+$') {
  throw "Invalid version: $Version (expected X.Y.Z)"
}

$Temp = Join-Path ([System.IO.Path]::GetTempPath()) ("geckograph-" + [guid]::NewGuid().ToString("n"))
New-Item -ItemType Directory -Path $Temp | Out-Null
try {
  $Bin = Join-Path $Temp "geckograph.exe"
  Write-Host "Downloading GeckoGraph CLI $Version ($FileName)"
  Invoke-WebRequest -UseBasicParsing $Url -OutFile $Bin

  Write-Host "Verifying checksum from $SumsUrl"
  $Sums = (Invoke-WebRequest -UseBasicParsing $SumsUrl).Content
  $Expected = $null
  foreach ($Line in ($Sums -split "`n")) {
    $Parts = $Line.Trim() -split '\s+'
    if ($Parts.Length -ge 2 -and ($Parts[1] -eq $FileName -or $Parts[1] -eq "*$FileName")) {
      $Expected = $Parts[0].ToLower()
      break
    }
  }
  if (-not $Expected -or $Expected.Length -ne 64) {
    throw "No SHA256 for $FileName in $SumsUrl"
  }
  $Actual = (Get-FileHash -Algorithm SHA256 $Bin).Hash.ToLower()
  if ($Actual -ne $Expected) {
    throw "Checksum mismatch for $FileName"
  }

  New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
  $Dest = Join-Path $BinDir "geckograph.exe"
  Copy-Item $Bin $Dest -Force
  $UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
  if ($UserPath -notlike "*$BinDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$BinDir;$UserPath", "User")
    Write-Host "Added $BinDir to the user PATH. Open a new terminal."
  }
  Write-Host "Installed geckograph $Version to $Dest"
  Write-Host "Run 'geckograph login' to get started."
} finally {
  Remove-Item -Recurse -Force $Temp
}
