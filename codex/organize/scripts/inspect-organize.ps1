[CmdletBinding()]
param([Parameter(Mandatory = $true)][string]$TargetPath)

$ErrorActionPreference = 'Stop'
$protectedNames = @('frontend','backend','remotion','.claude','.codex','.git','node_modules','Untitled','.venv','dist','build','__pycache__','.trash-organize')
$projectMarkers = @('.git','package.json','pyproject.toml','requirements.txt','Cargo.toml','go.mod','composer.json')
$resolvedTarget = (Resolve-Path -LiteralPath $TargetPath).Path
if (-not (Test-Path -LiteralPath $resolvedTarget -PathType Container)) { throw "Target is not a directory: $resolvedTarget" }

function Test-ReparsePoint { param([System.IO.FileSystemInfo]$Item) return [bool]($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) }
function Get-Category {
    param([System.IO.FileInfo]$File, [bool]$IsProject)
    $name = $File.Name; $extension = $File.Extension.ToLowerInvariant()
    if ($name -match '^(old-|bkp-|backup-)' -or $name -match '(19|20)\d{2}[-_.]\d{1,2}[-_.]\d{1,2}') { return 'arquivo' }
    if ($extension -in @('.md','.txt','.pdf','.docx','.xlsx','.pptx') -or $name -match '^README(?:\.|$)') { return 'docs' }
    if ($extension -in @('.png','.jpg','.jpeg','.gif','.svg','.webp','.ico')) { return 'assets' }
    if ($extension -in @('.mp4','.mov','.avi','.mp3','.wav','.m4a','.webm')) { return 'media' }
    if (-not $IsProject -and $extension -in @('.py','.js','.ts','.sh','.bat','.ps1')) { return 'scripts' }
    if (-not $IsProject -and $extension -in @('.env','.json','.yaml','.yml','.toml','.ini')) { return 'config' }
    return $null
}

$rootItems = @(Get-ChildItem -LiteralPath $resolvedTarget -Force)
$isProject = [bool]($rootItems | Where-Object { $_.Name -in $projectMarkers } | Select-Object -First 1)
$protected = @($rootItems | Where-Object { $_.PSIsContainer -and $_.Name -in $protectedNames })
$links = @($rootItems | Where-Object { Test-ReparsePoint $_ })
$allFiles = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
$pendingDirectories = [System.Collections.Generic.Stack[System.IO.DirectoryInfo]]::new()
$pendingDirectories.Push((Get-Item -LiteralPath $resolvedTarget))
while ($pendingDirectories.Count -gt 0) {
    $directory = $pendingDirectories.Pop()
    foreach ($item in Get-ChildItem -LiteralPath $directory.FullName -Force) {
        if (Test-ReparsePoint $item) { continue }
        if ($item.PSIsContainer) { if ($item.Name -notin $protectedNames) { $pendingDirectories.Push($item) } }
        else { $allFiles.Add($item) }
    }
}

$movements = foreach ($file in $rootItems | Where-Object { -not $_.PSIsContainer -and -not (Test-ReparsePoint $_) }) {
    $category = Get-Category -File $file -IsProject $isProject
    if (-not $category) { continue }
    $destination = Join-Path (Join-Path $resolvedTarget $category) $file.Name
    [pscustomobject]@{ source=$file.FullName; destination=$destination; category=$category; confidence=if ($isProject -and $category -in @('docs','assets','media')) {'medium'} else {'high'}; conflict=Test-Path -LiteralPath $destination; sourceLength=$file.Length; sourceLastWriteUtc=$file.LastWriteTimeUtc.ToString('o') }
}

$discardCandidates = foreach ($file in $allFiles) {
    $ageDays = [math]::Floor(((Get-Date).ToUniversalTime() - $file.LastWriteTimeUtc).TotalDays); $reason = $null
    if ($file.Length -eq 0) { $reason = 'empty file' }
    elseif ($file.Name -match '^(Thumbs\.db|\.DS_Store|desktop\.ini|~\$)') { $reason = 'OS or application metadata' }
    elseif ($file.Extension.ToLowerInvariant() -in @('.tmp','.bak','.cache')) { $reason = 'temporary or backup extension' }
    elseif ($file.Extension.ToLowerInvariant() -eq '.log' -and $ageDays -gt 90) { $reason = 'log older than 90 days' }
    if ($reason) { [pscustomobject]@{ path=$file.FullName; reason=$reason; size=$file.Length; ageDays=$ageDays } }
}

$duplicateGroups = @()
foreach ($sizeGroup in $allFiles | Where-Object { $_.Length -gt 0 } | Group-Object Length | Where-Object Count -gt 1) {
    $hashed = foreach ($file in $sizeGroup.Group) { [pscustomobject]@{ path=$file.FullName; size=$file.Length; hash=(Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash } }
    foreach ($hashGroup in $hashed | Group-Object hash | Where-Object Count -gt 1) { $duplicateGroups += [pscustomobject]@{ sha256=$hashGroup.Name; size=$hashGroup.Group[0].size; paths=@($hashGroup.Group.path) } }
}

[pscustomobject]@{ target=$resolvedTarget; inspectedAtUtc=(Get-Date).ToUniversalTime().ToString('o'); isProject=$isProject; projectMarkers=@($rootItems | Where-Object { $_.Name -in $projectMarkers } | ForEach-Object Name); inScopeFileCount=$allFiles.Count; rootItemCount=$rootItems.Count; protectedDirectories=@($protected | ForEach-Object FullName); retainedLinks=@($links | ForEach-Object FullName); proposedMovements=@($movements); discardCandidates=@($discardCandidates); exactDuplicateGroups=@($duplicateGroups) } | ConvertTo-Json -Depth 7

