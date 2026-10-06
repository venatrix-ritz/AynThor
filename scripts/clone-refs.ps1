# Reproducible clone of every upstream reference into refs/ (gitignored).
#   .\scripts\clone-refs.ps1            clone default branches, write refs/MANIFEST.md + scripts/refs.lock.json
#   .\scripts\clone-refs.ps1 -UseLock   clone, then check out the SHAs pinned in scripts/refs.lock.json
param([switch]$UseLock)
$ErrorActionPreference = 'Stop'
$env:GIT_TERMINAL_PROMPT = '0'
$root = Split-Path $PSScriptRoot -Parent
$refs = Join-Path $root 'refs'
$lockPath = Join-Path $PSScriptRoot 'refs.lock.json'
$lock = @{}
if ($UseLock -and (Test-Path $lockPath)) { $lock = Get-Content $lockPath -Raw | ConvertFrom-Json -AsHashtable }
$maxShallowMB = 300

# mode: full = all branches/tags | shallow = depth 1 | sparse = blobless + sparse paths (+ branch)
$targets = @(
  @{ dir='upstream/armada';          repo='armada-os/armada';      mode='full';    note='canonical Armada OS (Fedora bootc, ROCKNIX-derived device support)' }
  @{ dir='upstream/armadaos.dev';    repo='armada-os/armadaos.dev';mode='full';    note='docs site source (Material for MkDocs)' }
  @{ dir='upstream/armada-efi';      repo='armada-os/armada-efi';  mode='full';    note='' }
  @{ dir='upstream/adtbloader';      repo='armada-os/adtbloader';  mode='full';    note='EFI driver: installs DeviceTree into UEFI config table' }
  @{ dir='upstream/armada-packages'; repo='armada-os/armada-packages'; mode='full';note='archived' }
  @{ dir='upstream/rocknix';         repo='ROCKNIX/distribution';  mode='sparse';  branch='next'
     paths=@('projects/ROCKNIX/devices/SM8550','projects/ROCKNIX/devices/SM8250','projects/ROCKNIX/devices/SM4450','documentation'); note='device support lineage (Thor dts: qcs8550-ayn-thor.dts)' }
  @{ dir='thor-linux/thorch';        repo='thorch-os/thorch';      mode='shallow'; note='Arch Linux on Thor' }
  @{ dir='thor-linux/ayn-thor-arch'; repo='Kitsumi/ayn-thor-arch'; mode='shallow'; note='' }
  @{ dir='thor-android/Thor-Launcher';  repo='Prof-Mags/Thor-Launcher';  mode='shallow'; note='Loki launcher' }
  @{ dir='thor-android/thor-wayfinder'; repo='Thor-Wayfinder/thor-wayfinder'; mode='shallow'; note='' }
  @{ dir='thor-android/Jarngreipr';     repo='BrianJr03/Jarngreipr'; mode='shallow'; note='' }
  @{ dir='thor-android/Heimdall';       repo='mastercook777/Heimdall-AYN-Thor-Assistant'; mode='shallow'; note='' }
  @{ dir='thor-android/dualscreen-mods';repo='JoeCorrell/AYN-Thor-Dualscreen-Mods'; mode='shallow'; note='' }
  @{ dir='thor-android/Dual-Screen-Games'; repo='codm2000/Dual-Screen-Games'; mode='shallow'; note='' }
  @{ dir='thor-android/AYN-Thor-Tweaks';repo='ItsRetroPup/AYN-Thor-Tweaks'; mode='shallow'; note='' }
  @{ dir='thor-android/thortune';       repo='androosio/thortune';   mode='shallow'; note='' }
  @{ dir='thor-android/AYNThorUnderclock'; repo='wirudecko/AYNThorUnderclock'; mode='shallow'; note='' }
  @{ dir='thor-android/ayn-thor-config';repo='dreulavelle/ayn-thor-config'; mode='shallow'; note='Obtainium + Cocoon config' }
  @{ dir='thor-android/Thor-Swapper';   repo='Emile86/Thor-Swapper'; mode='shallow'; note='' }
  @{ dir='thor-android/ayn-thor-auto-dim'; repo='JeromeGsq/ayn-thor-auto-dim'; mode='shallow'; note='' }
  @{ dir='thor-android/GAFT';           repo='andreyvelsk/GAFT';     mode='shallow'; note='' }
  @{ dir='thor-android/AynThorSecondScreen'; repo='exojosh/AynThorSecondScreen'; mode='shallow'; note='' }
  @{ dir='thor-android/ayn_thor_overlays'; repo='arcath-/ayn_thor_overlays'; mode='shallow'; note='' }
  @{ dir='thor-android/AYN-Thor-WiFi-Recovery'; repo='JoelMomo/AYN-Thor-WiFi-Recovery'; mode='shallow'; note='' }
  @{ dir='thor-android/ayn-thor-root-guide'; repo='meltingscales/ayn-thor-root-guide'; mode='shallow'; note='' }
  @{ dir='thor-android/trackpadDS';          repo='minhf1/trackpadDS';         mode='shallow'; note='bottom screen trackpad overlay' }
  @{ dir='thor-linux/DualCPY-Linux';         repo='DrSkyfaR/DualCPY-Linux';    mode='shallow'; note='multi-window dual-screen scrcpy launcher for Linux' }
  @{ dir='thor-tools/DualCPY';               repo='theswest/DualCPY';          mode='shallow'; note='multi-window dual-screen scrcpy launcher for Windows' }
)
# forks fetched as extra remotes into upstream/armada (shares objects; only diffs are downloaded)
$forkRemotes = @(
  @{ name='silentbob347'; repo='SilentBob347/armada-os' }
  @{ name='ga1dz1';       repo='Ga1dz1/armada' }
  @{ name='mgeeeek-thor'; repo='MgeeeeK/thor-armada' }
)

$manifest = New-Object System.Collections.Generic.List[string]
$newLock = @{}
function Get-SizeMB($p) { [math]::Round(((Get-ChildItem $p -Recurse -Force -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum) / 1MB, 1) }

foreach ($t in $targets) {
  $dest = Join-Path $refs $t.dir
  $url = "https://github.com/$($t.repo).git"
  $apiKB = [int](gh api "repos/$($t.repo)" --jq .size)
  if ($t.mode -eq 'shallow' -and ($apiKB / 1024) -gt $maxShallowMB) { $manifest.Add("| $($t.dir) | $($t.repo) | SKIPPED (api size $([math]::Round($apiKB/1024))MB > cap) | | | |"); continue }
  if (-not (Test-Path (Join-Path $dest '.git'))) {
    New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
    switch ($t.mode) {
      'full'    { git clone --quiet $url $dest }
      'shallow' { git clone --quiet --depth 1 $url $dest }
      'sparse'  { git clone --quiet --filter=blob:none --sparse --branch $t.branch $url $dest
                  git -C $dest sparse-checkout set @($t.paths) }
    }
  }
  if ($lock.ContainsKey($t.dir)) { git -C $dest checkout --quiet $lock[$t.dir] }
  $sha = (git -C $dest rev-parse HEAD).Trim()
  $br  = (git -C $dest rev-parse --abbrev-ref HEAD).Trim()
  $newLock[$t.dir] = $sha
  $manifest.Add("| $($t.dir) | $($t.repo) | $($t.mode) | $br | $sha | $(Get-SizeMB $dest) MB |")
}

$arm = Join-Path $refs 'upstream/armada'
foreach ($f in $forkRemotes) {
  $existing = git -C $arm remote
  if ($existing -notcontains $f.name) { git -C $arm remote add $f.name "https://github.com/$($f.repo).git" }
  git -C $arm fetch --quiet --no-tags $f.name
  $heads = git -C $arm for-each-ref "refs/remotes/$($f.name)" --format='%(refname:short)@%(objectname:short)' | Out-String
  $manifest.Add("| (remote in upstream/armada) $($f.name) | $($f.repo) | remote-fetch | | $(($heads -split "`n" | Where-Object { $_ }) -join ', ') | |")
}

$hdr = @("# refs manifest", "", "Generated $(Get-Date -Format 'yyyy-MM-dd HH:mm') by scripts/clone-refs.ps1. Pinned SHAs also in scripts/refs.lock.json.", "", "| dir | repo | mode | branch | SHA | size |", "|---|---|---|---|---|---|")
($hdr + $manifest) | Set-Content (Join-Path $refs 'MANIFEST.md') -Encoding utf8
$newLock | ConvertTo-Json | Set-Content $lockPath -Encoding utf8
Write-Host "done: $($manifest.Count) rows"
