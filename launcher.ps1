Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$modsDir = Join-Path $root 'instance\mods'
$configDir = Join-Path $root 'instance\config'
$repoOwner = 'Shix-0'
$repoName = 'fabric-launcher-1.21.1'
$repoBranch = 'main'
New-Item -ItemType Directory -Force -Path $modsDir, $configDir | Out-Null

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Fabric Launcher — Minecraft 1.21.1'
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(760, 540)
$form.MinimumSize = New-Object System.Drawing.Size(680, 480)
$form.BackColor = [System.Drawing.Color]::FromArgb(24, 28, 36)
$form.ForeColor = [System.Drawing.Color]::White
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10)

$title = New-Object System.Windows.Forms.Label
$title.Text = 'FABRIC LAUNCHER'
$title.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 19)
$title.ForeColor = [System.Drawing.Color]::FromArgb(113, 218, 155)
$title.Location = New-Object System.Drawing.Point(28, 20)
$title.AutoSize = $true
$form.Controls.Add($title)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = 'Minecraft Java Edition 1.21.1  •  Fabric'
$subtitle.Location = New-Object System.Drawing.Point(31, 62)
$subtitle.AutoSize = $true
$subtitle.ForeColor = [System.Drawing.Color]::FromArgb(192, 201, 214)
$form.Controls.Add($subtitle)

$listLabel = New-Object System.Windows.Forms.Label
$listLabel.Text = 'ZATWIERDZONE MODY'
$listLabel.Location = New-Object System.Drawing.Point(31, 106)
$listLabel.AutoSize = $true
$listLabel.ForeColor = [System.Drawing.Color]::FromArgb(192, 201, 214)
$form.Controls.Add($listLabel)

$list = New-Object System.Windows.Forms.ListBox
$list.Location = New-Object System.Drawing.Point(31, 134)
$list.Size = New-Object System.Drawing.Size(680, 250)
$list.Anchor = 'Top, Bottom, Left, Right'
$list.BackColor = [System.Drawing.Color]::FromArgb(35, 41, 52)
$list.ForeColor = [System.Drawing.Color]::White
$list.BorderStyle = 'FixedSingle'
$list.IntegralHeight = $false
$form.Controls.Add($list)

$status = New-Object System.Windows.Forms.Label
$status.Location = New-Object System.Drawing.Point(31, 397)
$status.Size = New-Object System.Drawing.Size(680, 24)
$status.Anchor = 'Bottom, Left, Right'
$status.ForeColor = [System.Drawing.Color]::FromArgb(192, 201, 214)
$status.Text = 'Przy starcie launcher pobiera zatwierdzony zestaw modów.'
$form.Controls.Add($status)

function Refresh-ModList {
    $list.Items.Clear()
    Get-ChildItem -LiteralPath $modsDir -Filter '*.jar' -File | Sort-Object Name | ForEach-Object {
        [void]$list.Items.Add($_.Name)
    }
    $status.Text = "Liczba zatwierdzonych modów: $($list.Items.Count)   •   Minecraft 1.21.1 Fabric"
}

function Get-GitBlobSha1([string]$path) {
    $content = [System.IO.File]::ReadAllBytes($path)
    $prefix = [System.Text.Encoding]::ASCII.GetBytes(('blob ' + $content.Length + [char]0))
    $payload = New-Object byte[] ($prefix.Length + $content.Length)
    [Array]::Copy($prefix, 0, $payload, 0, $prefix.Length)
    [Array]::Copy($content, 0, $payload, $prefix.Length, $content.Length)
    $sha = [System.Security.Cryptography.SHA1]::Create()
    try {
        return [BitConverter]::ToString($sha.ComputeHash($payload)).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

function Sync-RemoteMods {
    $status.Text = 'Sprawdzam zatwierdzone mody w GitHub...'
    [System.Windows.Forms.Application]::DoEvents()
    $stageDir = Join-Path $env:TEMP ([Guid]::NewGuid().ToString())
    $updates = New-Object 'System.Collections.Generic.List[object]'
    $known = @{}
    try {
        New-Item -ItemType Directory -Path $stageDir | Out-Null
        $apiUrl = "https://api.github.com/repos/$repoOwner/$repoName/contents/mods?ref=$repoBranch"
        $headers = @{
            'User-Agent' = 'FabricLauncher'
            'Accept' = 'application/vnd.github+json'
            'X-GitHub-Api-Version' = '2022-11-28'
        }
        $entries = @(Invoke-RestMethod -Uri $apiUrl -Headers $headers -TimeoutSec 20)
        $jarEntries = @($entries | Where-Object { $_.type -eq 'file' -and $_.name -match '^[A-Za-z0-9._ -]+\.jar$' })

        foreach ($entry in $jarEntries) {
            if ($known.ContainsKey($entry.name)) { throw "Powtarzająca się nazwa moda: $($entry.name)" }
            if (-not $entry.download_url -or $entry.download_url -notmatch '^https://raw\.githubusercontent\.com/') {
                throw "Nieprawidłowy adres moda: $($entry.name)"
            }
            $known[$entry.name] = $true
            $destination = Join-Path $modsDir $entry.name
            if ((Test-Path -LiteralPath $destination -PathType Leaf) -and (Get-GitBlobSha1 $destination) -eq $entry.sha) {
                continue
            }

            $stagedFile = Join-Path $stageDir $entry.name
            Invoke-WebRequest -Uri $entry.download_url -OutFile $stagedFile -TimeoutSec 60 -UseBasicParsing
            if ((Get-GitBlobSha1 $stagedFile) -ne $entry.sha) { throw "Nie zgadza się suma pliku: $($entry.name)" }
            $updates.Add([pscustomobject]@{ Source = $stagedFile; Destination = $destination })
        }

        foreach ($update in $updates) {
            Move-Item -LiteralPath $update.Source -Destination $update.Destination -Force
        }
        Get-ChildItem -LiteralPath $modsDir -Filter '*.jar' -File | Where-Object { -not ($known.ContainsKey($_.Name)) } | Remove-Item -Force
        return $true
    }
    catch {
        $status.Text = 'Nie udało się pobrać aktualizacji. Zachowałem dotychczasowe pliki modów.'
        [System.Windows.Forms.MessageBox]::Show("Nie udało się zsynchronizować modów z GitHub.`n`n$($_.Exception.Message)`n`nDotychczasowe mody pozostają na miejscu.", 'Synchronizacja modów', 'OK', 'Warning') | Out-Null
        return $false
    }
    finally {
        if (Test-Path -LiteralPath $stageDir) { Remove-Item -LiteralPath $stageDir -Recurse -Force }
    }
}

function New-Button($text, $x, $y, $width) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $text
    $button.Location = New-Object System.Drawing.Point($x, $y)
    $button.Size = New-Object System.Drawing.Size($width, 38)
    $button.FlatStyle = 'Flat'
    $button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(83, 98, 118)
    $button.BackColor = [System.Drawing.Color]::FromArgb(45, 54, 68)
    $button.ForeColor = [System.Drawing.Color]::White
    $button.Anchor = 'Bottom, Left'
    $form.Controls.Add($button)
    return $button
}

$syncButton = New-Button 'Sprawdź aktualizacje' 31 435 170
$syncButton.Add_Click({
    if (Sync-RemoteMods) { Refresh-ModList }
})

$folderButton = New-Button 'Folder modów' 211 435 160
$folderButton.Add_Click({ Start-Process explorer.exe -ArgumentList "`"$modsDir`"" })

$manageButton = New-Button 'Dodaj / aktualizuj mody' 383 435 190
$manageButton.Add_Click({
    Start-Process "https://github.com/$repoOwner/$repoName/upload/main/mods"
})

$exportButton = New-Button 'Spakuj ZIP' 586 435 125
$exportButton.Anchor = 'Bottom, Right'
$exportButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.SaveFileDialog
    $dialog.Title = 'Zapisz kopię launchera do wysłania'
    $dialog.Filter = 'Archiwum ZIP (*.zip)|*.zip'
    $dialog.FileName = 'Fabric-Launcher-1.21.1.zip'
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $temporaryZip = Join-Path $env:TEMP ([Guid]::NewGuid().ToString() + '.zip')
        Compress-Archive -Path (Join-Path $root '*') -DestinationPath $temporaryZip -CompressionLevel Optimal
        Move-Item -LiteralPath $temporaryZip -Destination $dialog.FileName -Force
        [System.Windows.Forms.MessageBox]::Show("Gotowe. W archiwum są launcher i aktualne mody.`n`nKażda osoba musi zalogować się na własne konto Microsoft i posiadać Minecraft Java Edition.", 'Paczka launchera', 'OK', 'Information') | Out-Null
    }
})

Refresh-ModList
$form.Add_Shown({
    if (Sync-RemoteMods) { Refresh-ModList }
})
[void]$form.ShowDialog()
