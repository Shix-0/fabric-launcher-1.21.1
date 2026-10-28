Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$modsDir = Join-Path $root 'instance\mods'
$configDir = Join-Path $root 'instance\config'
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
$listLabel.Text = 'MODY W TYM LAUNCHERZE'
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
$status.Text = 'Mody są przechowywane w folderze instance\mods.'
$form.Controls.Add($status)

function Refresh-ModList {
    $list.Items.Clear()
    Get-ChildItem -LiteralPath $modsDir -Filter '*.jar' -File | Sort-Object Name | ForEach-Object {
        [void]$list.Items.Add($_.Name)
    }
    $status.Text = "Liczba modów: $($list.Items.Count)   •   Folder: instance\mods"
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

$addButton = New-Button 'Dodaj mody (.jar)' 31 435 175
$addButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = 'Wybierz mody Fabric dla Minecraft 1.21.1'
    $dialog.Filter = 'Pliki modów (*.jar)|*.jar'
    $dialog.Multiselect = $true
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        foreach ($file in $dialog.FileNames) {
            $destination = Join-Path $modsDir ([IO.Path]::GetFileName($file))
            if ((Resolve-Path -LiteralPath $file).Path -ne $destination) {
                Copy-Item -LiteralPath $file -Destination $destination -Force
            }
        }
        Refresh-ModList
    }
})

$removeButton = New-Button 'Usuń zaznaczony' 218 435 160
$removeButton.Add_Click({
    if ($list.SelectedItem) {
        Remove-Item -LiteralPath (Join-Path $modsDir ([string]$list.SelectedItem)) -Force
        Refresh-ModList
    }
})

$folderButton = New-Button 'Otwórz folder modów' 390 435 185
$folderButton.Add_Click({ Start-Process explorer.exe -ArgumentList "`"$modsDir`"" })

$exportButton = New-Button 'Spakuj do ZIP' 587 435 124
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
        [System.Windows.Forms.MessageBox]::Show("Gotowe. W archiwum są launcher i dodane mody.`n`nKażda osoba musi zalogować się na własne konto Microsoft i posiadać Minecraft Java Edition.", 'Paczka launchera', 'OK', 'Information') | Out-Null
    }
})

Refresh-ModList
[void]$form.ShowDialog()
