param([string]$WorkDir = "")

$ErrorActionPreference = "Stop"

$AppDir = $PSScriptRoot
if (-not $WorkDir) { $WorkDir = Split-Path $AppDir -Parent }
if (-not $WorkDir) { $WorkDir = $AppDir }
try { $WorkDir = (Resolve-Path -LiteralPath $WorkDir).Path } catch { }
$WorkDir = $WorkDir.TrimEnd('\')
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }
try { [Console]::InputEncoding = [System.Text.Encoding]::UTF8 } catch { }
Add-Type -AssemblyName System.IO.Compression | Out-Null

$latin = [System.Text.Encoding]::GetEncoding(28591)
$streamRx = [regex]::new('stream\r?\n(.*?)\r?\nendstream', [System.Text.RegularExpressions.RegexOptions]::Singleline)

$BannerStyles = @(
    @{ N = 'Shadow'; D = '4paI4paI4paI4paI4paI4paI4pWXICDilojilojilojilojilojilojilZcgIOKWiOKWiOKWiOKWiOKWiOKWiOKVlwrilojilojilZTilZDilZDilojilojilZfilojilojilZTilZDilZDilZDilojilojilZfilojilojilZTilZDilZDilZDilZDilZ0K4paI4paI4pWRICDilojilojilZHilojilojilZEgICDilojilojilZHilojilojilZEgICAgIArilojilojilZEgIOKWiOKWiOKVkeKWiOKWiOKVkSAgIOKWiOKWiOKVkeKWiOKWiOKVkSAgICAgCuKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVneKVmuKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVneKVmuKWiOKWiOKWiOKWiOKWiOKWiOKVlwrilZrilZDilZDilZDilZDilZDilZ0gIOKVmuKVkOKVkOKVkOKVkOKVkOKVnSAg4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWd'; W = '4paI4paI4pWXICAgIOKWiOKWiOKVl+KWiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKWiOKVlyDilojilojilojilojilojilZcg4paI4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKWiOKWiOKWiOKWiOKVlyAK4paI4paI4pWRICAgIOKWiOKWiOKVkeKWiOKWiOKVkeKVmuKVkOKVkOKWiOKWiOKWiOKVlOKVneKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKWiOKWiOKVlwrilojilojilZEg4paI4pWXIOKWiOKWiOKVkeKWiOKWiOKVkSAg4paI4paI4paI4pWU4pWdIOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVkeKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVneKWiOKWiOKVkSAg4paI4paI4pWRCuKWiOKWiOKVkeKWiOKWiOKWiOKVl+KWiOKWiOKVkeKWiOKWiOKVkSDilojilojilojilZTilZ0gIOKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVkeKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVkSAg4paI4paI4pWRCuKVmuKWiOKWiOKWiOKVlOKWiOKWiOKWiOKVlOKVneKWiOKWiOKVkeKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKVkSAg4paI4paI4pWR4paI4paI4pWRICDilojilojilZHilojilojilojilojilojilojilZTilZ0KIOKVmuKVkOKVkOKVneKVmuKVkOKVkOKVnSDilZrilZDilZ3ilZrilZDilZDilZDilZDilZDilZDilZ3ilZrilZDilZ0gIOKVmuKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pWd4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWdIA==' }
    @{ N = 'Block'; D = '4paI4paI4paI4paI4paI4paIICAg4paI4paI4paI4paI4paI4paIICAg4paI4paI4paI4paI4paI4paIIArilojiloggICDilojilogg4paI4paIICAgIOKWiOKWiCDilojiloggICAgICAK4paI4paIICAg4paI4paIIOKWiOKWiCAgICDilojilogg4paI4paIICAgICAgCuKWiOKWiCAgIOKWiOKWiCDilojiloggICAg4paI4paIIOKWiOKWiCAgICAgIArilojilojilojilojilojiloggICDilojilojilojilojilojiloggICDilojilojilojilojilojilogg'; W = '4paI4paIICAgICDilojilogg4paI4paIIOKWiOKWiOKWiOKWiOKWiOKWiOKWiCAg4paI4paI4paI4paI4paIICDilojilojilojilojilojiloggIOKWiOKWiOKWiOKWiOKWiOKWiCAgCuKWiOKWiCAgICAg4paI4paIIOKWiOKWiCAgICDilojilojiloggIOKWiOKWiCAgIOKWiOKWiCDilojiloggICDilojilogg4paI4paIICAg4paI4paIIArilojiloggIOKWiCAg4paI4paIIOKWiOKWiCAgIOKWiOKWiOKWiCAgIOKWiOKWiOKWiOKWiOKWiOKWiOKWiCDilojilojilojilojilojiloggIOKWiOKWiCAgIOKWiOKWiCAK4paI4paIIOKWiOKWiOKWiCDilojilogg4paI4paIICDilojilojiloggICAg4paI4paIICAg4paI4paIIOKWiOKWiCAgIOKWiOKWiCDilojiloggICDilojiloggCiDilojilojilogg4paI4paI4paIICDilojilogg4paI4paI4paI4paI4paI4paI4paIIOKWiOKWiCAgIOKWiOKWiCDilojiloggICDilojilogg4paI4paI4paI4paI4paI4paIICA=' }
    @{ N = 'Classic'; D = 'IF9fX19fICAgX19fXyAgIF9fX19fIAp8ICBfXyBcIC8gX18gXCAvIF9fX198CnwgfCAgfCB8IHwgIHwgfCB8ICAgICAKfCB8ICB8IHwgfCAgfCB8IHwgICAgIAp8IHxfX3wgfCB8X198IHwgfF9fX18gCnxfX19fXy8gXF9fX18vIFxfX19fX3w='; W = 'X18gICAgICAgICAgX19fX19fXyBfX19fX18gICAgICAgICBfX19fXyAgX19fX18gIApcIFwgICAgICAgIC8gL18gICBffF9fXyAgLyAgIC9cICAgfCAgX18gXHwgIF9fIFwgCiBcIFwgIC9cICAvIC8gIHwgfCAgICAvIC8gICAvICBcICB8IHxfXykgfCB8ICB8IHwKICBcIFwvICBcLyAvICAgfCB8ICAgLyAvICAgLyAvXCBcIHwgIF8gIC98IHwgIHwgfAogICBcICAvXCAgLyAgIF98IHxfIC8gL19fIC8gX19fXyBcfCB8IFwgXHwgfF9ffCB8CiAgICBcLyAgXC8gICB8X19fX18vX19fX18vXy8gICAgXF9cX3wgIFxfXF9fX19fLyA=' }
    @{ N = 'Bold'; D = 'X19fX19fIF9fX19fIF9fX19fIAp8ICBfICBcICBfICAvICBfXyBcCnwgfCB8IHwgfCB8IHwgLyAgXC8KfCB8IHwgfCB8IHwgfCB8ICAgIAp8IHwvIC9cIFxfLyAvIFxfXy9cCnxfX18vICBcX19fLyBcX19fXy8='; W = 'IF8gICAgXyBfX19fXyBfX19fX18gIF9fXyAgX19fX19fX19fX19fIAp8IHwgIHwgfF8gICBffF9fXyAgLyAvIF8gXCB8IF9fXyBcICBfICBcCnwgfCAgfCB8IHwgfCAgICAvIC8gLyAvX1wgXHwgfF8vIC8gfCB8IHwKfCB8L1x8IHwgfCB8ICAgLyAvICB8ICBfICB8fCAgICAvfCB8IHwgfApcICAvXCAgL198IHxfLi8gL19fX3wgfCB8IHx8IHxcIFx8IHwvIC8gCiBcLyAgXC8gXF9fXy9cX19fX18vXF98IHxfL1xffCBcX3xfX18vICA=' }
    @{ N = 'Slim'; D = 'IF9fX19fXyAgIF9fX19fICBfX19fX19fCiB8ICAgICBcIHwgICAgIHwgfCAgICAgIAogfF9fX19fLyB8X19fX198IHxfX19fXyA='; W = 'IF8gIF8gIF8gX19fX18gX19fX19fIF9fX19fX18gIF9fX19fXyBfX19fX18gCiB8ICB8ICB8ICAgfCAgICBfX19fLyB8X19fX198IHxfX19fXy8gfCAgICAgXAogfF9ffF9ffCBfX3xfXyAvX19fX18gfCAgICAgfCB8ICAgIFxfIHxfX19fXy8=' }
    @{ N = 'Plain'; D = 'RE9D'; W = 'V0laQVJE' }
)

$script:BannerCache = $null

function Get-BannerArt {
    if ($script:BannerCache) { return $script:BannerCache }
    $idx = 0
    $v = Get-Setting 'BANNER'
    if ($v -match '^\d+$') { $idx = [int]$v }
    if ($idx -lt 0 -or $idx -ge $BannerStyles.Count) { $idx = 0 }
    $st = $BannerStyles[$idx]
    $script:BannerCache = @{
        Doc  = ([System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($st.D)) -split "`n")
        Wiz  = ([System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($st.W)) -split "`n")
        Name = $st.N
    }
    return $script:BannerCache
}

$doubl = "  " + ([string][char]0x2550 * 68)
$plainBar = "  " + ([string][char]0x2550 * 45)
$light = "  " + ([string][char]0x2500 * 68)

$MonthsDE = @('Januar', 'Februar', ("M" + [char]0x00E4 + "rz"), 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember')
$MonthsEN = @('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')
$MonthAbbrDE = @('Jan', 'Feb', 'Mrz', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez')
$MonthAbbrEN = @('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')
$MonthPat = @(
    'jan(uar|uary)?',
    'feb(ruar|ruary)?',
    ('m(ae|' + [char]0x00E4 + '|a)?rz|mrz|march|mar'),
    'apr(il)?',
    'mai|may',
    'jun(i|e)?',
    'jul(i|y)?',
    'aug(ust)?',
    'sept(ember)?|sep',
    'okt(ober)?|oct(ober)?',
    'nov(ember)?',
    'dez(ember)?|dec(ember)?'
)

$CountryNames = @{
    'DE' = @('deutschland', 'germany', 'allemagne')
    'FR' = @('frankreich', 'france')
    'BE' = @('belgien', 'belgium', 'belgique')
    'NL' = @('niederlande', 'netherlands', 'holland')
    'CZ' = @('tschechien', 'czech', 'czechia', 'thech')
    'AT' = @('osterreich', 'austria')
    'CH' = @('schweiz', 'switzerland', 'suisse')
    'IT' = @('italien', 'italy', 'italia')
    'ES' = @('spanien', 'spain', 'espana')
    'PL' = @('polen', 'poland', 'polska')
    'DK' = @('danemark', 'denmark')
    'SE' = @('schweden', 'sweden')
    'NO' = @('norwegen', 'norway')
    'FI' = @('finnland', 'finland')
    'PT' = @('portugal')
    'GB' = @('grossbritannien', 'united kingdom', 'england', 'britain')
    'IE' = @('irland', 'ireland')
    'HU' = @('ungarn', 'hungary')
    'SK' = @('slowakei', 'slovakia')
    'RO' = @('rumanien', 'romania')
    'LU' = @('luxemburg', 'luxembourg')
    'MT' = @('malta')
    'CY' = @('zypern', 'cyprus')
    'GR' = @('griechenland', 'greece')
    'TR' = @('turkei', 'turkey')
    'SI' = @('slowenien', 'slovenia')
    'HR' = @('kroatien', 'croatia')
    'RS' = @('serbien', 'serbia')
    'BG' = @('bulgarien', 'bulgaria')
    'LT' = @('litauen', 'lithuania')
    'LV' = @('lettland', 'latvia')
    'EE' = @('estland', 'estonia')
    'IS' = @('island', 'iceland')
    'US' = @('usa', 'united states', 'vereinigte staaten')
    'CA' = @('kanada', 'canada')
    'MX' = @('mexiko', 'mexico')
    'BR' = @('brasilien', 'brazil')
    'AE' = @('uae', 'dubai', 'emirate', 'vereinigte arabische emirate')
    'SA' = @('saudi arabien', 'saudi arabia', 'saudi')
    'QA' = @('katar', 'qatar')
    'IL' = @('israel')
    'EG' = @('agypten', 'egypt')
    'MA' = @('marokko', 'morocco')
    'TN' = @('tunesien', 'tunisia')
    'ZA' = @('sudafrika', 'south africa')
    'SG' = @('singapur', 'singapore')
    'VN' = @('vietnam', 'viertnam')
    'JP' = @('japan')
    'CN' = @('china')
    'IN' = @('indien', 'india')
    'AU' = @('australien', 'australia')
    'NZ' = @('neuseeland', 'new zealand')
    'RU' = @('russland', 'russia')
    'UA' = @('ukraine')
}

function Show-Header {
    $art = Get-BannerArt
    if ($art.Name -eq 'Plain') {
        Write-Host ""
        Write-Host $plainBar -ForegroundColor Magenta
        Write-Host -NoNewline "  DOC" -ForegroundColor Cyan
        Write-Host -NoNewline " WIZARD" -ForegroundColor Yellow
        Write-Host ("   Version " + $script:AppVersion + "  |  by Engin Sarak") -ForegroundColor Red
        Write-Host $plainBar -ForegroundColor Magenta
        return
    }
    Write-Host ""
    Write-Host $doubl -ForegroundColor Magenta
    Write-Host ""
    for ($i = 0; $i -lt $art.Doc.Count; $i++) {
        Write-Host -NoNewline ("  " + $art.Doc[$i]) -ForegroundColor Cyan
        Write-Host (" " + $art.Wiz[$i]) -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host ("         Version " + $script:AppVersion + "  |  by Engin Sarak") -ForegroundColor Red
    Write-Host $doubl -ForegroundColor Magenta
}

$script:CanPosition = $false
try {
    $__orig = [Console]::CursorTop
    [Console]::SetCursorPosition(0, 0)
    if ([Console]::CursorTop -eq 0) { $script:CanPosition = $true }
    [Console]::SetCursorPosition(0, $__orig)
} catch { $script:CanPosition = $false }

function Get-HeaderRows {
    $rows = New-Object System.Collections.Generic.List[object]
    $art = Get-BannerArt
    if ($art.Name -eq 'Plain') {
        $rows.Add(@(@{ T = ""; F = "Gray" }))
        $rows.Add(@(@{ T = $plainBar; F = "Magenta" }))
        $rows.Add(@(@{ T = "  DOC"; F = "Cyan" }, @{ T = " WIZARD"; F = "Yellow" }, @{ T = ("   Version " + $script:AppVersion + "  |  by Engin Sarak"); F = "Red" }))
        $rows.Add(@(@{ T = $plainBar; F = "Magenta" }))
        return ,$rows
    }
    $rows.Add(@(@{ T = ""; F = "Gray" }))
    $rows.Add(@(@{ T = $doubl; F = "Magenta" }))
    $rows.Add(@(@{ T = ""; F = "Gray" }))
    for ($i = 0; $i -lt $art.Doc.Count; $i++) {
        $rows.Add(@(@{ T = ("  " + $art.Doc[$i]); F = "Cyan" }, @{ T = (" " + $art.Wiz[$i]); F = "Yellow" }))
    }
    $rows.Add(@(@{ T = ""; F = "Gray" }))
    $rows.Add(@(@{ T = ("         Version " + $script:AppVersion + "  |  by Engin Sarak"); F = "Red" }))
    $rows.Add(@(@{ T = $doubl; F = "Magenta" }))
    return ,$rows
}

function Render-FrameSimple($rows) {
    Clear-Host
    foreach ($row in $rows) {
        foreach ($seg in $row) {
            $txt = [string]$seg.T
            if ($txt.Length -gt 0) {
                if ($seg.B) { Write-Host -NoNewline $txt -ForegroundColor $seg.F -BackgroundColor $seg.B }
                else { Write-Host -NoNewline $txt -ForegroundColor $seg.F }
            }
        }
        Write-Host ""
    }
}

function Test-SnowSeason {
    $v = Get-Setting 'SNOW'
    if ($v -ieq 'on') { return $true }
    if ($v -ieq 'off') { return $false }
    $now = Get-Date
    return (($now.Month -eq 12) -and ($now.Day -le 25))
}

function New-SnowFlakes($grid) {
    $flakes = New-Object System.Collections.Generic.List[object]
    $h = $grid.Count
    if ($h -lt 6) { return ,$flakes }
    $w = 80
    try { $w = [Console]::WindowWidth - 1 } catch { }
    $chars = @('*', '.', '+')
    $count = [math]::Min(28, [int]($w / 4))
    for ($i = 0; $i -lt $count; $i++) {
        $flakes.Add(@{
            X = (Get-Random -Minimum 0 -Maximum $w)
            Y = (Get-Random -Minimum 0 -Maximum $h)
            C = $chars[(Get-Random -Minimum 0 -Maximum $chars.Count)]
            S = (Get-Random -Minimum 1 -Maximum 3)
            T = 0
        })
    }
    return ,$flakes
}

function Show-Snow($grid, $flakes, $erase) {
    $h = $grid.Count
    $w = 80
    try { $w = [Console]::WindowWidth - 1 } catch { }
    foreach ($f in $flakes) {
        $y = [int]$f.Y
        $x = [int]$f.X
        if ($y -lt 0 -or $y -ge $h -or $x -lt 0 -or $x -ge $w) { continue }
        $line = [string]$grid[$y]
        if ($x -ge $line.Length) { continue }
        if ($line[$x] -ne ' ') { continue }
        try {
            [Console]::SetCursorPosition($x, $y)
            if ($erase) { Write-Host -NoNewline " " }
            else { Write-Host -NoNewline $f.C -ForegroundColor White }
        } catch { }
    }
}

function Step-Snow($grid, $flakes) {
    $h = $grid.Count
    $w = 80
    try { $w = [Console]::WindowWidth - 1 } catch { }
    foreach ($f in $flakes) {
        $f.T = $f.T + 1
        if (($f.T % $f.S) -eq 0) {
            $f.Y = [int]$f.Y + 1
            if ((Get-Random -Minimum 0 -Maximum 3) -eq 0) { $f.X = [int]$f.X + (Get-Random -Minimum -1 -Maximum 2) }
        }
        if ([int]$f.Y -ge $h -or [int]$f.X -lt 0 -or [int]$f.X -ge $w) {
            $f.Y = 0
            $f.X = (Get-Random -Minimum 0 -Maximum $w)
        }
    }
}

function Wait-KeyWithSnow($grid) {
    if (-not $script:CanPosition) {
        return [Console]::ReadKey($true)
    }
    if (-not (Test-SnowSeason)) {
        return [Console]::ReadKey($true)
    }
    $flakes = New-SnowFlakes $grid
    try {
        while (-not [Console]::KeyAvailable) {
            Show-Snow $grid $flakes $false
            Start-Sleep -Milliseconds 180
            Show-Snow $grid $flakes $true
            Step-Snow $grid $flakes
        }
    } catch { }
    return [Console]::ReadKey($true)
}

function Render-Frame($rows) {
    $grid = New-Object System.Collections.Generic.List[string]
    if (-not $script:CanPosition) {
        Render-FrameSimple $rows
        return ,$grid
    }
    try {
        $w = [Console]::WindowWidth
        $h = [Console]::WindowHeight
        $maxw = $w - 1
        [Console]::SetCursorPosition(0, 0)
        $total = $h - 1
        for ($i = 0; $i -lt $total; $i++) {
            $used = 0
            $lineText = ""
            if ($i -lt $rows.Count) {
                foreach ($seg in $rows[$i]) {
                    $txt = [string]$seg.T
                    if ($used + $txt.Length -gt $maxw) { $txt = $txt.Substring(0, [math]::Max(0, $maxw - $used)) }
                    if ($txt.Length -gt 0) {
                        if ($seg.B) { Write-Host -NoNewline $txt -ForegroundColor $seg.F -BackgroundColor $seg.B }
                        else { Write-Host -NoNewline $txt -ForegroundColor $seg.F }
                        $used += $txt.Length
                        $lineText += $txt
                    }
                }
            }
            if ($used -lt $maxw) { Write-Host -NoNewline (" " * ($maxw - $used)) }
            $grid.Add($lineText.PadRight($maxw))
            if ($i -lt $total - 1) { Write-Host "" }
        }
    } catch {
        $script:CanPosition = $false
        Render-FrameSimple $rows
    }
    return ,$grid
}

function Get-ViewRows {
    $h = 24
    try { $h = [Console]::WindowHeight } catch { }
    $bannerLines = 6
    $extra = 6
    try {
        $art = Get-BannerArt
        $bannerLines = $art.Doc.Count
        if ($art.Name -eq 'Plain') { $extra = 3 }
    } catch { }
    $rows = $h - 1 - ($bannerLines + $extra) - 5
    if ($rows -lt 5) { $rows = 5 }
    return $rows
}

function Show-Menu {
    param([string]$Title, [string[]]$Items)
    $selectable = @()
    for ($i = 0; $i -lt $Items.Count; $i++) { if ($Items[$i] -ne "") { $selectable += $i } }
    if ($selectable.Count -eq 0) { return -1 }
    $pos = 0
    $top = 0
    try { [Console]::CursorVisible = $false } catch { }
    while ($true) {
        $rows = Get-ViewRows
        $cur = $selectable[$pos]
        if ($cur -lt $top) { $top = $cur }
        if ($cur -ge $top + $rows) { $top = $cur - $rows + 1 }
        if ($top -gt $Items.Count - $rows) { $top = $Items.Count - $rows }
        if ($top -lt 0) { $top = 0 }
        $end = [math]::Min($top + $rows - 1, $Items.Count - 1)

        $frame = Get-HeaderRows
        $frame.Add(@(@{ T = ""; F = "Gray" }))
        $frame.Add(@(@{ T = ("   " + $Title); F = "Cyan" }))
        $frame.Add(@(@{ T = ""; F = "Gray" }))
        for ($i = $top; $i -le $end; $i++) {
            if ($Items[$i] -eq "") {
                $frame.Add(@(@{ T = ""; F = "Gray" }))
            } elseif ($i -eq $cur) {
                $frame.Add(@(@{ T = ("   > " + $Items[$i].PadRight(58)); F = "Black"; B = "Cyan" }))
            } else {
                $frame.Add(@(@{ T = ("     " + $Items[$i]); F = "Gray" }))
            }
        }
        $frame.Add(@(@{ T = ""; F = "Gray" }))
        $hint = "   Up/Down = move     Enter = select     Esc / Backspace = back"
        if ($top -gt 0 -or $end -lt $Items.Count - 1) {
            $hint = $hint + "     " + ($pos + 1) + "/" + $selectable.Count
        }
        $frame.Add(@(@{ T = $hint; F = "DarkGray" }))
        $grid = Render-Frame $frame

        $key = Wait-KeyWithSnow $grid
        switch ($key.Key) {
            'UpArrow'   { $pos = ($pos - 1 + $selectable.Count) % $selectable.Count }
            'DownArrow' { $pos = ($pos + 1) % $selectable.Count }
            'Home'      { $pos = 0 }
            'End'       { $pos = $selectable.Count - 1 }
            'PageUp'    { $pos = [math]::Max(0, $pos - 10) }
            'PageDown'  { $pos = [math]::Min($selectable.Count - 1, $pos + 10) }
            'Enter'     { try { [Console]::CursorVisible = $true } catch { }; Clear-Host; return $selectable[$pos] }
            'Escape'    { try { [Console]::CursorVisible = $true } catch { }; Clear-Host; return -1 }
            'Backspace' { try { [Console]::CursorVisible = $true } catch { }; Clear-Host; return -1 }
            'Delete'    { try { [Console]::CursorVisible = $true } catch { }; Clear-Host; return -1 }
        }
    }
}

function Inflate([byte[]]$bytes) {
    foreach ($skip in 2,0) {
        try {
            $ms = New-Object System.IO.MemoryStream
            $ms.Write($bytes, $skip, $bytes.Length - $skip)
            $ms.Position = 0
            $ds = New-Object System.IO.Compression.DeflateStream($ms, [System.IO.Compression.CompressionMode]::Decompress)
            $out = New-Object System.IO.MemoryStream
            $ds.CopyTo($out)
            $ds.Dispose()
            $r = $out.ToArray()
            if ($r.Length -gt 0) { return $r }
        } catch { }
    }
    return $null
}

function Get-PdfText([string]$path) {
    $bytes = [System.IO.File]::ReadAllBytes($path)
    $s = $latin.GetString($bytes)
    $sb = New-Object System.Text.StringBuilder
    foreach ($m in $streamRx.Matches($s)) {
        $chunk = $latin.GetBytes($m.Groups[1].Value)
        $dec = Inflate $chunk
        if ($dec) { [void]$sb.Append($latin.GetString($dec)) }
    }
    [void]$sb.Append($s)
    return $sb.ToString()
}

function First([string]$text, [string]$pattern) {
    $m = [regex]::Match($text, $pattern)
    if ($m.Success) { return $m.Value } else { return $null }
}

function Get-Kunde([string]$text) {
    $m = [regex]::Match($text, '\(Destination\)\s*Tj.*?Td\s*\(([^)]*)\)\s*Tj', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $m.Success) { return $null }
    $v = $m.Groups[1].Value
    $v = $v -replace '\\\(', '(' -replace '\\\)', ')'
    $v = $v.Trim()
    if ($v.Length -eq 0) { return $null }
    $v = $v -replace '[\\/:*?"<>|]', ' '
    $parts = @($v -split '\s+' | Where-Object { $_ -ne '' -and $_ -notmatch '^[&+]+$' -and $_ -notmatch '^(and|und)$' })
    if ($parts.Count -eq 0) { return $null }
    if ($parts.Count -gt 2) { $parts = $parts[0..1] }
    return ($parts -join '_')
}

function Get-PwsFromPdf([string]$path) {
    try { $t = Get-PdfText $path } catch { return $null }
    return (First $t 'PWS\d+')
}

function Test-WorkFileExists([string]$nameOrPrefix) {
    if (-not $nameOrPrefix) { return $false }
    if ($nameOrPrefix -match '^GROUPAGE_(.+)$') {
        $key = $matches[1]
        $n = @(Get-ChildItem -LiteralPath $WorkDir -Filter ('WP*_' + $key + '_SORD*.pdf') -ErrorAction SilentlyContinue).Count
        return ($n -ge 2)
    }
    if ($nameOrPrefix -match '^(PAC|PWS|WP)\d+$') {
        return (@(Get-ChildItem -LiteralPath $WorkDir -Filter ($nameOrPrefix + '*.pdf') -ErrorAction SilentlyContinue).Count -gt 0)
    }
    return (Test-Path -LiteralPath (Join-Path $WorkDir $nameOrPrefix))
}

function Invoke-Housekeeping {
    $pf = Join-Path $AppDir "_doc_wizard_pairs.txt"
    if (Test-Path -LiteralPath $pf) {
        $keep = New-Object System.Collections.Generic.List[string]
        foreach ($l in (Get-Content -LiteralPath $pf)) {
            if ($l -match '^(PAC\d+)=(PWS\d+)$') {
                if (Test-WorkFileExists $matches[1]) { $keep.Add($l) }
            }
        }
        try { Set-Content -LiteralPath $pf -Value $keep } catch { }
    }

    $prf = Join-Path $AppDir "_doc_wizard_printed.txt"
    if (Test-Path -LiteralPath $prf) {
        $keep = New-Object System.Collections.Generic.List[string]
        foreach ($l in (Get-Content -LiteralPath $prf)) {
            $t = $l.Trim()
            if (-not $t) { continue }
            if (Test-WorkFileExists $t) { $keep.Add($t) }
        }
        try { Set-Content -LiteralPath $prf -Value $keep } catch { }
    }
}



function Get-GroupageXlsx([string]$key) {
    $cand = @(Get-ChildItem -LiteralPath $WorkDir -Filter ("*Groupage_" + $key + ".xls*") -ErrorAction SilentlyContinue)
    if ($cand.Count -eq 0) {
        $nk = Normalize-Name $key
        $cand = @(Get-ChildItem -LiteralPath $WorkDir -Filter "*roupage*.xls*" -ErrorAction SilentlyContinue | Where-Object { (Normalize-Name $_.Name) -match [regex]::Escape($nk) })
    }
    if ($cand.Count -gt 0) { return $cand[$cand.Count - 1].FullName }
    return ""
}

function Get-ActiveGroupages {
    $result = New-Object System.Collections.Generic.List[object]
    $wpFiles = @(Get-ChildItem -LiteralPath $WorkDir -Filter 'WP*.pdf' -ErrorAction SilentlyContinue | Sort-Object Name)

    $byCustomer = @{}
    foreach ($f in $wpFiles) {
        if ($f.Name -match '^WP\d+_(.+)_SORD\d+-\d+\.pdf$') {
            $key = $matches[1]
            if (-not $byCustomer.ContainsKey($key)) { $byCustomer[$key] = New-Object System.Collections.Generic.List[object] }
            $byCustomer[$key].Add($f)
        }
    }

    foreach ($key in ($byCustomer.Keys | Sort-Object)) {
        $list = $byCustomer[$key]
        if ($list.Count -lt 2) { continue }

        $stamped = New-Object System.Collections.Generic.List[object]
        foreach ($f in $list) {
            try { if ((Get-PdfText $f.FullName) -match 'GROUPAGE') { $stamped.Add($f) } } catch { }
        }
        if ($stamped.Count -lt 2) { continue }

        $xlsx = Get-GroupageXlsx $key
        $result.Add(@{
            Customer = $key
            Label    = (($key -replace '_', ' ') + " Groupage   (" + $stamped.Count + " pick lists)")
            Names    = @($stamped | ForEach-Object { $_.Name })
            Paths    = @($stamped | ForEach-Object { $_.FullName })
            Xlsx     = $xlsx
            HasXlsx  = ($xlsx -ne "")
            Id       = ("GROUPAGE_" + $key)
        })
    }
    return ,$result
}

function Set-GroupageData([string]$path, [string]$customer, [string[]]$wpNums) {
    $spin = Start-Spin ("filling " + [System.IO.Path]::GetFileName($path) + " in Excel...")
    $xl = $null
    $wb = $null
    try {
        try { $xl = New-Object -ComObject Excel.Application } catch {
            throw "Microsoft Excel could not be started (COM). Is Excel installed?"
        }
        $xl.Visible = $false
        $xl.DisplayAlerts = $false
        $xl.ScreenUpdating = $false

        $wb = $xl.Workbooks.Open($path)
        $ws = $wb.Worksheets.Item(1)

        $labelRow = 0
        $tableRow = 0
        for ($r = 1; $r -le 40; $r++) {
            $v = $ws.Cells($r, 1).Value2
            if (-not $v) { continue }
            $t = ([string]$v).Trim()
            if ($t -eq 'Kunde') { $labelRow = $r }
            if ($t -eq 'Picknummer') { $tableRow = $r }
        }
        if ($labelRow -gt 0) { $ws.Cells($labelRow, 2).Value2 = $customer }

        $n = $wpNums.Count
        if ($tableRow -gt 0 -and $n -gt 0) {
            $firstRow = $tableRow + 1
            $lastRow = $tableRow + $n
            try {
                if ($ws.ListObjects.Count -gt 0) {
                    $lo = $ws.ListObjects.Item(1)
                    $curLast = $lo.Range.Row + $lo.Range.Rows.Count - 1
                    if ($lastRow -gt $curLast) {
                        $lo.Resize($ws.Range($ws.Cells($tableRow, 1), $ws.Cells($lastRow, 3))) | Out-Null
                    }
                }
            } catch { }
            for ($i = 0; $i -lt $n; $i++) {
                $ws.Cells($firstRow + $i, 1).Value2 = $wpNums[$i]
            }
        }

        $wb.Save()
        $wb.Close($true)
        $xl.Quit()
        Stop-Spin $spin
        return $true
    } catch {
        Stop-Spin $spin
        try { if ($wb) { $wb.Close($false) } } catch { }
        try { if ($xl) { $xl.Quit() } } catch { }
        Write-Host ("     WARNING: could not prefill the groupage file: " + $_.Exception.Message) -ForegroundColor DarkYellow
        return $false
    } finally {
        foreach ($o in @($wb, $xl)) {
            try { if ($o) { [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($o) } } catch { }
        }
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
    }
}

function Invoke-GroupageCheck {
    $wpFiles = @(Get-ChildItem -LiteralPath $WorkDir -Filter 'WP*.pdf' -ErrorAction SilentlyContinue)
    if ($wpFiles.Count -lt 2) { return }

    $groups = @{}
    foreach ($f in $wpFiles) {
        if ($f.Name -match '^WP\d+_(.+)_SORD\d+-\d+\.pdf$') {
            $key = $matches[1]
            if (-not $groups.ContainsKey($key)) { $groups[$key] = New-Object System.Collections.Generic.List[object] }
            $groups[$key].Add($f)
        }
    }

    foreach ($key in ($groups.Keys | Sort-Object)) {
        $list = $groups[$key]
        if ($list.Count -lt 2) { continue }
        $display = $key -replace '_', ' '

        $ext = ".xlsx"
        $tpl = @(Get-ChildItem -LiteralPath $AppDir -Filter 'groupage_template.xls*' -ErrorAction SilentlyContinue)
        if ($tpl.Count -eq 0) { $tpl = @(Get-ChildItem -LiteralPath $AppDir -Filter '*Groupage TEMPLATE.xls*' -ErrorAction SilentlyContinue) }
        if ($tpl.Count -gt 0) { $ext = [System.IO.Path]::GetExtension($tpl[0].Name) }
        $newName = (Get-Date -Format 'yyyy-MM-dd') + "_Groupage_" + $key + $ext
        $newPath = Join-Path $WorkDir $newName

        $existing = @(Get-ChildItem -LiteralPath $WorkDir -Filter ('*_Groupage_' + $key + '.xls*') -ErrorAction SilentlyContinue)
        if ($existing.Count -gt 0) {
            Write-Host ("   Groupage " + $display + " already created: " + $existing[0].Name) -ForegroundColor DarkGray
            continue
        }

        Write-Host ""
        Write-Host $light -ForegroundColor DarkCyan
        Write-Host ("   GROUPAGE detected:  " + $display + "   (" + $list.Count + " pick lists)") -ForegroundColor Yellow
        foreach ($f in $list) { Write-Host ("     " + $f.Name) -ForegroundColor DarkGray }
        Write-Host ""
        $ans = Read-Host "   Create groupage? (Y/N)"
        if (-not ($ans -match '^\s*[yj]')) {
            Write-Host "   Skipped." -ForegroundColor DarkGray
            continue
        }

        foreach ($f in $list) {
            try {
                if ((Get-PdfText $f.FullName) -match 'GROUPAGE') {
                    Write-Host ("     already marked : " + $f.Name) -ForegroundColor DarkGray
                } else {
                    Add-Stamp $f.FullName @("GROUPAGE")
                    Write-Host ("     marked GROUPAGE: " + $f.Name) -ForegroundColor Green
                }
            } catch {
                Write-Host ("     ERROR marking " + $f.Name + ": " + $_.Exception.Message) -ForegroundColor Red
            }
        }

        if ($tpl.Count -eq 0) {
            Write-Host "     Template not found in the DOC WIZARD folder." -ForegroundColor Yellow
            Write-Host "     Put 'groupage_template.xlsx' there, then run again." -ForegroundColor DarkGray
            continue
        }

        try {
            if (Test-Path -LiteralPath $newPath) {
                Write-Host ("     exists already : " + $newName) -ForegroundColor DarkYellow
            } else {
                Copy-Item -LiteralPath $tpl[0].FullName -Destination $newPath
                try { Unblock-File -LiteralPath $newPath -ErrorAction SilentlyContinue } catch { }
                Write-Host ("     created        : " + $newName) -ForegroundColor Green

                $wpNums = New-Object System.Collections.Generic.List[string]
                foreach ($f in ($list | Sort-Object Name)) {
                    if ($f.Name -match '^(WP\d+)') {
                        if (-not $wpNums.Contains($matches[1])) { $wpNums.Add($matches[1]) }
                    }
                }
                if (Set-GroupageData $newPath $display $wpNums.ToArray()) {
                    Write-Host ("     prefilled      : customer + " + $wpNums.Count + " pick number(s)") -ForegroundColor Green
                    Write-Host "     please fill in the remaining fields" -ForegroundColor Yellow
                }
            }
            Start-Process -FilePath $newPath
        } catch {
            Write-Host ("     ERROR creating groupage file: " + $_.Exception.Message) -ForegroundColor Red
        }
    }
}

function Start-Spin([string]$text) {
    try {
        $sync = [hashtable]::Synchronized(@{ Stop = $false; Text = $text })
        $rs = [runspacefactory]::CreateRunspace()
        $rs.Open()
        $rs.SessionStateProxy.SetVariable('sync', $sync)
        $ps = [powershell]::Create()
        $ps.Runspace = $rs
        [void]$ps.AddScript({
            $frames = @('|', '/', '-', '\')
            $i = 0
            while (-not $sync.Stop) {
                try {
                    [Console]::Write("`r   " + $frames[$i % 4] + "  " + $sync.Text + "        ")
                } catch { }
                Start-Sleep -Milliseconds 110
                $i++
            }
        })
        $handle = $ps.BeginInvoke()
        return @{ Sync = $sync; Ps = $ps; Rs = $rs; Handle = $handle }
    } catch {
        try { Write-Host ("   " + $text) -ForegroundColor DarkCyan } catch { }
        return $null
    }
}

function Stop-Spin($spin) {
    if (-not $spin) { return }
    try { $spin.Sync.Stop = $true } catch { }
    try { [void]$spin.Ps.EndInvoke($spin.Handle) } catch { }
    try { $spin.Ps.Dispose() } catch { }
    try { $spin.Rs.Close(); $spin.Rs.Dispose() } catch { }
    try { [Console]::Write("`r" + (' ' * 78) + "`r") } catch { }
}

$script:AppVersion = '1.0.5'
$script:UpdateOwner = 'EnginSarak'
$script:UpdateRepo = 'DOC-WIZARD'
$script:UpdateBranch = 'main'

function Get-UpdateBaseUrl {
    $owner = $script:UpdateOwner
    $repo = $script:UpdateRepo
    $branch = $script:UpdateBranch
    $cfg = Join-Path $AppDir '_doc_wizard_update.txt'
    if (Test-Path -LiteralPath $cfg) {
        foreach ($l in (Get-Content -LiteralPath $cfg)) {
            $t = $l.Trim()
            if ($t -match '^OWNER=(.+)$') { $owner = $matches[1].Trim() }
            if ($t -match '^REPO=(.+)$') { $repo = $matches[1].Trim() }
            if ($t -match '^BRANCH=(.+)$') { $branch = $matches[1].Trim() }
        }
    }
    return ("https://raw.githubusercontent.com/" + $owner + "/" + $repo + "/" + $branch + "/")
}

function Get-ProxyParams([string]$url) {
    $p = @{}
    try {
        $dest = [Uri]$url
        $proxy = [System.Net.WebRequest]::GetSystemWebProxy()
        $pxUri = $proxy.GetProxy($dest)
        if ($pxUri -and $pxUri.Host -ne $dest.Host) {
            $p['Proxy'] = $pxUri.AbsoluteUri
            $p['ProxyUseDefaultCredentials'] = $true
        }
    } catch { }
    return $p
}

function Get-WebText([string]$url) {
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch { }
    $bust = "?t=" + [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $full = $url + $bust
    $params = @{ Uri = $full; UseBasicParsing = $true; TimeoutSec = 12 }
    $px = Get-ProxyParams $full
    foreach ($k in $px.Keys) { $params[$k] = $px[$k] }
    $r = Invoke-WebRequest @params
    return [System.Text.Encoding]::UTF8.GetString($r.Content)
}

function Compare-Version([string]$a, [string]$b) {
    $pa = @($a -split '\.' | ForEach-Object { [int]($_ -replace '\D', '0') })
    $pb = @($b -split '\.' | ForEach-Object { [int]($_ -replace '\D', '0') })
    for ($i = 0; $i -lt 4; $i++) {
        $x = 0; $y = 0
        if ($i -lt $pa.Count) { $x = $pa[$i] }
        if ($i -lt $pb.Count) { $y = $pb[$i] }
        if ($x -gt $y) { return 1 }
        if ($x -lt $y) { return -1 }
    }
    return 0
}

function Get-UpdateInfo {
    $base = Get-UpdateBaseUrl
    try { $txt = Get-WebText ($base + 'update.txt') } catch { return $null }
    if (-not $txt) { return $null }

    $info = @{ Version = ''; Files = (New-Object System.Collections.Generic.List[string]); Notes = (New-Object System.Collections.Generic.List[string]); Base = $base }
    foreach ($l in ($txt -split "`n")) {
        $t = $l.Trim()
        if (-not $t) { continue }
        if ($t -match '^VERSION=(.+)$') { $info.Version = $matches[1].Trim() }
        elseif ($t -match '^FILE=(.+)$') { $info.Files.Add($matches[1].Trim()) }
        elseif ($t -match '^NOTE=(.+)$') { $info.Notes.Add($matches[1].Trim()) }
    }
    if (-not $info.Version) { return $null }
    return $info
}

function Install-Update($info) {
    $tmp = Join-Path $env:TEMP ("docwizard_update_" + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tmp -Force | Out-Null
    $ok = $true

    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch { }

    foreach ($f in $info.Files) {
        $spin = Start-Spin ("downloading " + $f + "...")
        try {
            $url = $info.Base + ($f -replace ' ', '%20') + "?t=" + [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
            $dest = Join-Path $tmp $f
            $destDir = Split-Path $dest -Parent
            if (-not (Test-Path -LiteralPath $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
            $dlParams = @{ Uri = $url; OutFile = $dest; UseBasicParsing = $true; TimeoutSec = 60 }
            $dlPx = Get-ProxyParams $url
            foreach ($k in $dlPx.Keys) { $dlParams[$k] = $dlPx[$k] }
            Invoke-WebRequest @dlParams
            Stop-Spin $spin
            Write-Host ("   downloaded : " + $f) -ForegroundColor DarkGray
        } catch {
            Stop-Spin $spin
            Write-Host ("   FAILED     : " + $f + "  (" + $_.Exception.Message + ")") -ForegroundColor Red
            $ok = $false
        }
    }

    if (-not $ok) {
        Write-Host ""
        Write-Host "   Update aborted, nothing was changed." -ForegroundColor Yellow
        try { Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue } catch { }
        return $false
    }

    Write-Host ""
    foreach ($f in $info.Files) {
        $srcF = Join-Path $tmp $f
        $dstF = Join-Path $AppDir $f
        try {
            Copy-Item -LiteralPath $srcF -Destination $dstF -Force
            Write-Host ("   updated    : " + $f) -ForegroundColor Green
        } catch {
            Write-Host ("   locked     : " + $f + "  (close it and run the update again)") -ForegroundColor Yellow
        }
    }
    try { Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue } catch { }
    return $true
}

function Invoke-UpdatePrompt($info) {
    while ($true) {
        Clear-Host
        Show-Header
        Write-Host ""
        Write-Host $light -ForegroundColor DarkCyan
        Write-Host ("   UPDATE AVAILABLE:   " + $script:AppVersion + "   ->   " + $info.Version) -ForegroundColor Yellow
        Write-Host ""
        foreach ($n in $info.Notes) { Write-Host ("     " + $n) -ForegroundColor Gray }
        if ($info.Notes.Count -gt 0) { Write-Host "" }
        Write-Host $light -ForegroundColor DarkCyan
        Write-Host ""
        $ans = Read-Host "   Install the update now? (Y/N)"
        if (-not ($ans -match '^\s*[yj]')) { return }

        Clear-Host
        Show-Header
        Write-Host ""
        if (Install-Update $info) {
            Write-Host ""
            Write-Host $light -ForegroundColor DarkCyan
            Write-Host ("   Updated to version " + $info.Version + ".") -ForegroundColor Green
            Write-Host "   DOC WIZARD needs to restart now." -ForegroundColor Gray
            Write-Host ""
            Write-Host "   Press any key to restart..." -ForegroundColor DarkGray
            [void][Console]::ReadKey($true)
            $bat = Join-Path $AppDir 'DOC WIZARD.bat'
            if (Test-Path -LiteralPath $bat) {
                Start-Process -FilePath $bat
            }
            exit
        }
        Write-Host ""
        Write-Host "   Press any key to continue without updating..." -ForegroundColor DarkGray
        [void][Console]::ReadKey($true)
        return
    }
}

function Invoke-UpdateCheck {
    $spin = Start-Spin "checking for updates..."
    $info = Get-UpdateInfo
    Stop-Spin $spin
    if (-not $info) { return }
    if ((Compare-Version $script:AppVersion $info.Version) -ge 0) { return }
    Invoke-UpdatePrompt $info
}

function Invoke-UpdateCheckManual {
    Clear-Host
    Show-Header
    Write-Host ""
    $spin = Start-Spin "checking for updates..."
    $info = Get-UpdateInfo
    Stop-Spin $spin

    if (-not $info) {
        Write-Host $light -ForegroundColor DarkCyan
        Write-Host "   Could not reach the update server." -ForegroundColor Red
        Write-Host ""
        Write-Host "   On a company network a firewall or proxy often blocks GitHub." -ForegroundColor Gray
        Write-Host "   Ask IT to allow raw.githubusercontent.com, or copy the new files" -ForegroundColor Gray
        Write-Host "   in by hand from the shared folder." -ForegroundColor Gray
        Write-Host $light -ForegroundColor DarkCyan
        return
    }

    if ((Compare-Version $script:AppVersion $info.Version) -ge 0) {
        Write-Host $light -ForegroundColor DarkCyan
        Write-Host ("   You already have the latest version (" + $script:AppVersion + ").") -ForegroundColor Green
        Write-Host $light -ForegroundColor DarkCyan
        return
    }

    Invoke-UpdatePrompt $info
}

function Get-PdfTjTokens([string]$path) {
    $bytes = [System.IO.File]::ReadAllBytes($path)
    $raw = $latin.GetString($bytes)
    $sb = New-Object System.Text.StringBuilder
    foreach ($m in $streamRx.Matches($raw)) {
        $dec = Inflate ($latin.GetBytes($m.Groups[1].Value))
        if ($dec) { [void]$sb.Append($latin.GetString($dec)) }
    }
    $txt = $sb.ToString()
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($m in [regex]::Matches($txt, '\(((?:[^()\\]|\\.)*)\)\s*Tj')) {
        $v = $m.Groups[1].Value
        $v = $v -replace '\\\(', '(' -replace '\\\)', ')' -replace '\\\\', '\'
        $out.Add($v.Trim())
    }
    return $out
}

function Get-PumpDataFromPdf([string]$path) {
    $toks = Get-PdfTjTokens $path
    if ($toks.Count -eq 0) { return $null }

    $res = @{ Wp = ''; Kunde = ''; Rows = (New-Object System.Collections.Generic.List[object]) }
    $seen = @{}
    $curBin = ''
    $isPick = $false

    for ($i = 0; $i -lt $toks.Count; $i++) {
        $v = $toks[$i]
        if (-not $v) { continue }

        if ($v -match 'Warehouse Activity Header') { $isPick = $true }
        if (-not $res.Wp -and $v -match '(WP\d+)') { $res.Wp = $matches[1] }
        if (-not $res.Kunde -and $v -eq 'Destination') {
            $nx = $i + 1
            if ($nx -lt $toks.Count) { $res.Kunde = $toks[$nx].Trim() }
        }

        if ($v -match '^(PICKING|[A-Z][A-Z0-9]{0,6}\d\.\d+)$') { $curBin = $v; continue }

        if ($v -match '^N\d{8,}$') {
            if ($curBin -and $curBin -ne 'PICKING' -and -not $seen.ContainsKey($v)) {
                $seen[$v] = $true
                $res.Rows.Add(@{ Serial = $v; Bin = $curBin })
            }
        }
    }

    if (-not $isPick) { return $null }
    return $res
}

function Format-KundeName([string]$v) {
    if (-not $v) { return '' }
    $v = $v -replace '[\\/:*?"<>|]', ' '
    $parts = @($v -split '\s+' | Where-Object { $_ -ne '' -and $_ -notmatch '^[&+]+$' -and $_ -notmatch '^(?i)(and|und)$' })
    if ($parts.Count -eq 0) { return '' }
    if ($parts.Count -gt 2) { $parts = $parts[0..1] }
    return ($parts -join '_')
}

function Get-PumpTemplate {
    foreach ($pat in @('pumplist_template.xls*', '*Pumpen TEMPLATE.xls*', '*pump*template*.xls*')) {
        $t = @(Get-ChildItem -LiteralPath $AppDir -Filter $pat -ErrorAction SilentlyContinue)
        if ($t.Count -gt 0) { return $t[0] }
    }
    return $null
}

function Get-ControlTemplate {
    foreach ($pat in @('pump_control_template.xls*', '*control*template*.xls*')) {
        $t = @(Get-ChildItem -LiteralPath $AppDir -Filter $pat -ErrorAction SilentlyContinue)
        if ($t.Count -gt 0) { return $t[0] }
    }
    return $null
}

function New-ControlWorkbook($data) {
    $tpl = Get-ControlTemplate
    if (-not $tpl) {
        Write-Host "     Control template not found ('pump_control_template.xlsx')." -ForegroundColor Yellow
        return $null
    }

    $wp = $data.Wp
    if (-not $wp) { $wp = 'WP' }
    $kunde = Format-KundeName $data.Kunde
    $baseName = $wp + "_Control.xlsx"
    if ($kunde) { $baseName = $wp + "_" + $kunde + "_Control.xlsx" }

    $newName = $baseName
    $newPath = Join-Path $WorkDir $newName
    $n = 2
    while (Test-Path -LiteralPath $newPath) {
        $stem = [System.IO.Path]::GetFileNameWithoutExtension($baseName)
        $newName = $stem + " (" + $n + ").xlsx"
        $newPath = Join-Path $WorkDir $newName
        $n++
    }

    Copy-Item -LiteralPath $tpl.FullName -Destination $newPath
    try { Unblock-File -LiteralPath $newPath -ErrorAction SilentlyContinue } catch { }

    $spin = Start-Spin ("building " + $newName + " in Excel...")
    $xl = $null
    $wbT = $null
    try {
        try { $xl = New-Object -ComObject Excel.Application } catch {
            throw "Microsoft Excel could not be started (COM). Is Excel installed?"
        }
        $xl.Visible = $false
        $xl.DisplayAlerts = $false
        $xl.ScreenUpdating = $false

        $wbT = $xl.Workbooks.Open($newPath)
        $wsP = $wbT.Worksheets.Item("Warehouse Pick")

        $serCol = 0
        for ($c = 1; $c -le 60; $c++) {
            $h = $wsP.Cells(1, $c).Value2
            if ($h -and ([string]$h).Trim() -eq 'Serial No.') { $serCol = $c; break }
        }
        if ($serCol -eq 0) { throw "Column 'Serial No.' not found in sheet 'Warehouse Pick'." }

        $rows = $data.Rows
        $cnt = $rows.Count
        $arr = New-Object 'object[,]' $cnt, 1
        for ($i = 0; $i -lt $cnt; $i++) {
            $arr[$i, 0] = $rows[$i].Serial
        }
        $lastRow = $cnt + 1
        $c1 = $wsP.Cells(2, $serCol)
        $c2 = $wsP.Cells($lastRow, $serCol)
        $wsP.Range($c1, $c2).Value2 = $arr

        $xl.CalculateFullRebuild()
        $wsS = $wbT.Worksheets.Item("Scan")
        $wsS.Activate()
        try { $wsS.Range("D5").Select() | Out-Null } catch { }
        $wbT.Save()
        $wbT.Close($true)
        $xl.Quit()

        Stop-Spin $spin
        Write-Host ("     created        : " + $newName + "   (" + $cnt + " serials to scan)") -ForegroundColor Green
        return @{ Path = $newPath; Name = $newName }
    } catch {
        Stop-Spin $spin
        try { if ($wbT) { $wbT.Close($false) } } catch { }
        try { if ($xl) { $xl.Quit() } } catch { }
        try { Remove-Item -LiteralPath $newPath -Force -ErrorAction SilentlyContinue } catch { }
        Write-Host ("     ERROR: " + $_.Exception.Message) -ForegroundColor Red
        return $null
    } finally {
        foreach ($o in @($wbT, $xl)) {
            try { if ($o) { [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($o) } } catch { }
        }
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
    }
}

function Get-PumpFileName($data) {
    $wp = $data.Wp
    if (-not $wp) { $wp = 'WP' }
    $kunde = Format-KundeName $data.Kunde
    if ($kunde) { return ($wp + "_" + $kunde + "_Pumpen.xlsx") }
    return ($wp + "_Pumpen.xlsx")
}

function New-PumpWorkbook($data, [string]$srcName) {
    $tpl = Get-PumpTemplate
    if (-not $tpl) {
        Write-Host "     Template not found in the DOC WIZARD folder." -ForegroundColor Yellow
        Write-Host "     Put 'pumplist_template.xlsx' there, then run again." -ForegroundColor DarkGray
        return $null
    }

    $wp = $data.Wp
    if (-not $wp) { $wp = 'WP' }
    $kunde = (Format-KundeName $data.Kunde) -replace '_', ' '
    $title = ($wp + " " + $kunde + " Pumpen") -replace "\s+", " "

    $baseName = Get-PumpFileName $data
    $newName = $baseName
    $newPath = Join-Path $WorkDir $newName
    $n = 2
    while (Test-Path -LiteralPath $newPath) {
        $stem = [System.IO.Path]::GetFileNameWithoutExtension($baseName)
        $newName = $stem + " (" + $n + ").xlsx"
        $newPath = Join-Path $WorkDir $newName
        $n++
    }

    Copy-Item -LiteralPath $tpl.FullName -Destination $newPath
    try { Unblock-File -LiteralPath $newPath -ErrorAction SilentlyContinue } catch { }

    $spin = Start-Spin ("building " + $newName + " in Excel...")
    $xl = $null
    $wbT = $null
    $ok = $false
    try {
        try { $xl = New-Object -ComObject Excel.Application } catch {
            throw "Microsoft Excel could not be started (COM). Is Excel installed?"
        }
        $xl.Visible = $false
        $xl.DisplayAlerts = $false
        $xl.ScreenUpdating = $false

        $wbT = $xl.Workbooks.Open($newPath)
        $wsT = $wbT.Worksheets.Item("Lines")

        $rows = $data.Rows
        $cnt = $rows.Count
        $lastRow = $cnt + 1
        $arr = New-Object 'object[,]' $lastRow, 2
        $arr[0, 0] = 'Serial No.'
        $arr[0, 1] = 'Bin Code'
        for ($i = 0; $i -lt $cnt; $i++) {
            $t = $i + 1
            $arr[$t, 0] = $rows[$i].Serial
            $arr[$t, 1] = $rows[$i].Bin
        }
        $c1 = $wsT.Cells(1, 1)
        $c2 = $wsT.Cells($lastRow, 2)
        $wsT.Range($c1, $c2).Value2 = $arr

        $wsA = $wbT.Worksheets.Item("Pump Bins")
        $wsA.Range("A1").Value2 = $title
        $xl.CalculateFullRebuild()

        $pumps = 0
        try { $pumps = [int]$wsA.Range("K3").Value2 } catch { }

        $wsA.Activate()
        try { $wsA.Range("A1").Select() | Out-Null } catch { }
        $wbT.Save()
        $wbT.Close($true)
        $xl.Quit()
        $ok = $true

        Stop-Spin $spin
        Write-Host ("     created        : " + $newName + "   (" + $pumps + " pumps)") -ForegroundColor Green
        return @{ Path = $newPath; Name = $newName; Pumps = $pumps }
    } catch {
        Stop-Spin $spin
        try { if ($wbT) { $wbT.Close($false) } } catch { }
        try { if ($xl) { $xl.Quit() } } catch { }
        try { Remove-Item -LiteralPath $newPath -Force -ErrorAction SilentlyContinue } catch { }
        Write-Host ("     ERROR: " + $_.Exception.Message) -ForegroundColor Red
        return $null
    } finally {
        foreach ($o in @($wbT, $xl)) {
            try { if ($o) { [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($o) } } catch { }
        }
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
    }
}

function Get-PumpSources {
    $sources = New-Object System.Collections.Generic.List[object]
    $spin = Start-Spin "scanning pick lists for pumps..."
    foreach ($f in @(Get-ChildItem -LiteralPath $WorkDir -Filter '*.pdf' -ErrorAction SilentlyContinue | Sort-Object Name)) {
        $data = $null
        try { $data = Get-PumpDataFromPdf $f.FullName } catch { $data = $null }
        if ($data -and $data.Rows.Count -gt 0) {
            $sources.Add(@{ File = $f; Data = $data })
        }
    }
    Stop-Spin $spin
    return $sources
}

function Invoke-PumpCheck {
    $sources = Get-PumpSources
    if ($sources.Count -eq 0) { return }

    foreach ($s in $sources) {
        $data = $s.Data
        $kunde = (Format-KundeName $data.Kunde) -replace '_', ' '
        $target = Join-Path $WorkDir (Get-PumpFileName $data)
        if (Test-Path -LiteralPath $target) { continue }

        Write-Host ""
        Write-Host $light -ForegroundColor DarkCyan
        Write-Host ("   PUMPS detected:  " + $data.Wp + "  " + $kunde + "   (" + $data.Rows.Count + " Compat Ella pumps)") -ForegroundColor Yellow
        Write-Host ("     " + $s.File.Name) -ForegroundColor DarkGray
        Write-Host ""
        $ans = Read-Host "   Create pump list? (Y/N)"
        if (-not ($ans -match '^\s*[yj]')) {
            Write-Host "   Skipped." -ForegroundColor DarkGray
            continue
        }

        $res = New-PumpWorkbook $data $s.File.Name
        if ($res) {
            [void](New-ControlWorkbook $data)
            Start-Process -FilePath $res.Path
        }
    }
}

function Invoke-PumpList {
    $sources = Get-PumpSources

    if ($sources.Count -eq 0) {
        Write-Host "  No pick list with pumps found in this folder." -ForegroundColor Yellow
        Write-Host "  Put the picking list PDF from Business Central here first." -ForegroundColor DarkGray
        return
    }

    $src = $sources[0]
    if ($sources.Count -gt 1) {
        $items = @($sources | ForEach-Object {
            $k = (Format-KundeName $_.Data.Kunde) -replace '_', ' '
            $_.Data.Wp.PadRight(10) + $k.PadRight(22) + $_.Data.Rows.Count.ToString().PadLeft(4) + " pumps    " + $_.File.Name
        })
        $sel = Show-Menu "PUMP LIST  -  SELECT PICK LIST" ($items + @("", "Back"))
        if ($sel -lt 0 -or $sel -ge $sources.Count) { return }
        $src = $sources[$sel]
    }

    $kunde = (Format-KundeName $src.Data.Kunde) -replace '_', ' '
    Clear-Host
    Show-Header
    Write-Host ""
    Write-Host ("   Source   : " + $src.File.Name) -ForegroundColor DarkGray
    Write-Host ("   WP       : " + $src.Data.Wp + "  " + $kunde) -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "   Working..." -ForegroundColor DarkCyan
    Write-Host ""

    $res = New-PumpWorkbook $src.Data $src.File.Name
    if ($res) {
        [void](New-ControlWorkbook $src.Data)
        Write-Host ""
        Start-Process -FilePath $res.Path
    }
}

function Invoke-Rename {
    $files = Get-ChildItem -LiteralPath $WorkDir -Filter *.pdf | ForEach-Object { $_.FullName }
    if (-not $files -or $files.Count -eq 0) {
        Write-Host "  No PDF files found in this folder." -ForegroundColor Yellow
        return
    }

    $renamed = 0
    $skipped = 0
    $fail = 0
    $missingPairs = 0

    $pairFile = Join-Path $AppDir "_doc_wizard_pairs.txt"
    $pairs = @{}
    if (Test-Path -LiteralPath $pairFile) {
        foreach ($l in (Get-Content -LiteralPath $pairFile)) {
            if ($l -match '^(PAC\d+)=(PWS\d+)$') { $pairs[$matches[1]] = $matches[2] }
        }
    }

    foreach ($f in $files) {
        $orig = [System.IO.Path]::GetFileName($f)
        $spin = Start-Spin ("reading " + $orig + "...")
        $text = $null
        try { $text = Get-PdfText $f } catch { $text = $null }
        Stop-Spin $spin
        if (-not $text) {
            Write-Host ("  ERROR reading: " + $orig) -ForegroundColor Red
            $fail++
            continue
        }

        $pac  = First $text 'PAC\d+'
        $pws  = First $text 'PWS\d+'
        $wp   = First $text 'WP\d+'
        $sord = First $text 'SORD\d+-\d+'

        if ($pac -and $pws) { $pairs[$pac] = $pws }

        $newName = $null
        if ($pac -and $sord) {
            $newName = "${pac}_${sord}.pdf"
        } elseif ($pws -and $sord) {
            $newName = "${pws}_${sord}.pdf"
        } elseif ($wp -and $sord) {
            $kunde = Get-Kunde $text
            if ($kunde) { $newName = "${wp}_${kunde}_${sord}.pdf" }
            else { $newName = "${wp}_${sord}.pdf" }
        }

        if (-not $newName) {
            Write-Host ("  skipped (not a delivery document): " + $orig) -ForegroundColor DarkGray
            continue
        }

        if ($orig -eq $newName) { $skipped++; continue }

        $target = Join-Path $WorkDir $newName
        if (Test-Path -LiteralPath $target) {
            Write-Host ("  skipped (target already exists): " + $orig) -ForegroundColor DarkYellow
            $skipped++
            continue
        }

        Move-Item -LiteralPath $f -Destination $target
        Write-Host ("  " + $orig + "  ->  " + $newName) -ForegroundColor Green
        $renamed++
    }

    if ($pairs.Count -gt 0) {
        try { Set-Content -LiteralPath $pairFile -Value (@($pairs.GetEnumerator() | ForEach-Object { $_.Key + "=" + $_.Value })) } catch { }
    }

    $pacFiles = @(Get-ChildItem -LiteralPath $WorkDir -Filter 'PAC*.pdf' -ErrorAction SilentlyContinue)
    $pwsFiles = @(Get-ChildItem -LiteralPath $WorkDir -Filter 'PWS*.pdf' -ErrorAction SilentlyContinue)
    $pwsByNum = @{}
    foreach ($f in $pwsFiles) { if ($f.Name -match '^(PWS\d+)') { $pwsByNum[$matches[1]] = $true } }
    $pacByNum = @{}
    foreach ($f in $pacFiles) { if ($f.Name -match '^(PAC\d+)') { $pacByNum[$matches[1]] = $true } }

    foreach ($f in $pacFiles) {
        if ($f.Name -notmatch '^(PAC\d+)') { continue }
        $pacNum = $matches[1]
        $pwsNum = $pairs[$pacNum]
        if (-not $pwsNum) { $pwsNum = Get-PwsFromPdf $f.FullName }
        if ($pwsNum -and -not $pwsByNum.ContainsKey($pwsNum)) {
            Write-Host ("  ERROR: " + $pacNum + " is missing its PWS pair (" + $pwsNum + ")") -ForegroundColor Red
            $missingPairs++
        }
    }

    $pwsToPac = @{}
    foreach ($e in $pairs.GetEnumerator()) { $pwsToPac[$e.Value] = $e.Key }
    foreach ($f in $pwsFiles) {
        if ($f.Name -notmatch '^(PWS\d+)') { continue }
        $pwsNum = $matches[1]
        $pacNum = $pwsToPac[$pwsNum]
        if ($pacNum -and -not $pacByNum.ContainsKey($pacNum)) {
            Write-Host ("  ERROR: " + $pwsNum + " is missing its PAC pair (" + $pacNum + ")") -ForegroundColor Red
            $missingPairs++
        }
    }

    Invoke-GroupageCheck
    Invoke-PumpCheck

    Write-Host ""
    Write-Host $light -ForegroundColor DarkCyan
    Write-Host "   SUMMARY" -ForegroundColor Cyan
    Write-Host ("     Renamed        : " + $renamed) -ForegroundColor Green
    Write-Host ("     Already ok     : " + $skipped) -ForegroundColor DarkGray
    $failColor = if ($fail -gt 0) { "Red" } else { "DarkGray" }
    Write-Host ("     Errors         : " + $fail) -ForegroundColor $failColor
    $pairColor = if ($missingPairs -gt 0) { "Red" } else { "DarkGray" }
    Write-Host ("     Missing pairs  : " + $missingPairs) -ForegroundColor $pairColor
}

function Add-Stamp([string]$path, [string[]]$lines) {
    $bytes = [System.IO.File]::ReadAllBytes($path)
    $s = $latin.GetString($bytes)

    $prevMatches = [regex]::Matches($s, 'startxref\s+(\d+)\s+%%EOF')
    if ($prevMatches.Count -eq 0) { throw "No startxref found" }
    $prev = $prevMatches[$prevMatches.Count - 1].Groups[1].Value

    $sizeMatches = [regex]::Matches($s, '/Size\s+(\d+)')
    $newObj = [int]$sizeMatches[$sizeMatches.Count - 1].Groups[1].Value

    $root = [regex]::Match($s, '/Root\s+(\d+\s+0\s+R)').Groups[1].Value
    $infoM = [regex]::Match($s, '/Info\s+(\d+\s+0\s+R)')

    $pageNum = $null
    $pageBody = $null
    foreach ($m in [regex]::Matches($s, '(\d+)\s+0\s+obj(.*?)endobj', [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
        if ($m.Groups[2].Value -match '/Type\s*/Page(?!s)') {
            $pageNum = $m.Groups[1].Value
            $pageBody = $m.Groups[2].Value
            break
        }
    }
    if (-not $pageNum) { throw "No page object found" }

    $defs = [regex]::Matches($s, '(?<![0-9])' + $pageNum + '\s+0\s+obj(.*?)endobj', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($defs.Count -gt 0) { $pageBody = $defs[$defs.Count - 1].Groups[1].Value }

    $cm = [regex]::Match($pageBody, '/Contents\s*(\d+\s+0\s+R)')
    if (-not $cm.Success) { $cm = [regex]::Match($pageBody, '/Contents\s*\[([^\]]*)\]') }
    $existing = $cm.Groups[1].Value.Trim()
    $newPage = [regex]::Replace($pageBody, '/Contents\s*(?:\d+\s+0\s+R|\[[^\]]*\])', "/Contents[$existing $newObj 0 R]")

    $font = [regex]::Match($pageBody, '/Font\s*<<\s*/([A-Za-z0-9]+)').Groups[1].Value
    if (-not $font) { $font = "F1" }

    $x = 495
    $y = 560
    $size = 14
    $lh = 22

    $marks = [regex]::Matches($s, '%\s*DWSTAMP\s+END=(\d+)')
    if ($marks.Count -gt 0) {
        $minY = 999999
        foreach ($mk in $marks) {
            $v = [int]$mk.Groups[1].Value
            if ($v -lt $minY) { $minY = $v }
        }
        $y = $minY - $lh - 6
        if ($y -lt 460) { $y = 460 }
    }

    $ops = New-Object System.Collections.Generic.List[string]
    $ops.Add("q BT /$font $size Tf 0 0 0 rg $x $y Td $lh TL")
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $t = $lines[$i]
        $t = $t -replace '\\', '\\'
        $t = $t -replace '\(', '\('
        $t = $t -replace '\)', '\)'
        if ($i -eq 0) { $ops.Add("($t) Tj") } else { $ops.Add("T* ($t) Tj") }
    }
    $ops.Add("ET Q")
    $lastY = $y - (($lines.Count - 1) * $lh)
    $content = ($ops -join " ") + "`n% DWSTAMP END=" + $lastY + "`n"
    $contentLen = $latin.GetBytes($content).Length

    $pageObj = "$pageNum 0 obj`n$newPage`nendobj`n"
    $strmObj = "$newObj 0 obj`n<</Length $contentLen>>`nstream`n$content`nendstream`nendobj`n"

    if (-not $s.EndsWith("`n")) { $s += "`n" }
    $offPage = $s.Length
    $s += $pageObj
    $offStrm = $s.Length
    $s += $strmObj
    $xrefPos = $s.Length

    $xref = "xref`n0 1`n0000000000 65535 f`r`n"
    $xref += "$pageNum 1`n" + ('{0:D10} 00000 n' -f $offPage) + "`r`n"
    $xref += "$newObj 1`n" + ('{0:D10} 00000 n' -f $offStrm) + "`r`n"

    $info = ""
    if ($infoM.Success) { $info = "/Info " + $infoM.Groups[1].Value }
    $trailer = "trailer`n<</Size $($newObj + 1)/Root $root$info/Prev $prev>>`nstartxref`n$xrefPos`n%%EOF`n"

    $s += $xref + $trailer
    [System.IO.File]::WriteAllBytes($path, $latin.GetBytes($s))
}

function Invoke-Annotate {
    $wpFiles = @(Get-ChildItem -LiteralPath $WorkDir -Filter 'WP*.pdf' | Sort-Object Name)
    if ($wpFiles.Count -eq 0) {
        Write-Host "  No WP documents found. Rename your picking lists first (option 1)." -ForegroundColor Yellow
        return
    }

    $items = @($wpFiles | ForEach-Object { $_.Name }) + "" + "Back"
    $sel = Show-Menu "SELECT WP DOCUMENT" $items
    if ($sel -lt 0 -or $items[$sel] -eq "Back") { $script:SkipPause = $true; return }
    $file = $wpFiles[$sel].FullName

    $docName = $wpFiles[$sel].Name
    $isGroupage = $false
    $aspin = Start-Spin ("reading " + $docName + "...")
    try { if ((Get-PdfText $file) -match 'GROUPAGE') { $isGroupage = $true } } catch { }
    Stop-Spin $aspin

    $lines = New-Object System.Collections.Generic.List[string]
    while ($true) {
        Clear-Host
        Show-Header
        Write-Host ""
        Write-Host ("   ANNOTATE:  " + $docName) -ForegroundColor Cyan
        if ($isGroupage) {
            Write-Host "   This document is marked GROUPAGE - your text is placed below it." -ForegroundColor DarkYellow
        }
        Write-Host ""
        Write-Host "   ENTER on empty line = save     del = delete last line     cancel = cancel" -ForegroundColor DarkGray
        Write-Host $light -ForegroundColor DarkCyan
        Write-Host ""
        if ($lines.Count -eq 0) {
            Write-Host "   (no text yet)" -ForegroundColor DarkGray
        } else {
            for ($i = 0; $i -lt $lines.Count; $i++) {
                Write-Host ("   " + ($i + 1) + ":  " + $lines[$i]) -ForegroundColor Green
            }
        }
        Write-Host ""
        $line = Read-Host ("   " + ($lines.Count + 1))

        if ([string]::IsNullOrEmpty($line)) { break }
        $cmd = $line.Trim()
        if (($cmd -ieq 'del') -or ($cmd -eq '-')) {
            if ($lines.Count -gt 0) { $lines.RemoveAt($lines.Count - 1) }
            continue
        }
        if ($cmd -ieq 'cancel') {
            $script:SkipPause = $true
            return
        }
        $lines.Add($line)
    }

    Clear-Host
    Show-Header
    Write-Host ""

    if ($lines.Count -eq 0) {
        Write-Host "   Nothing entered, cancelled." -ForegroundColor Yellow
        $script:SkipPause = $true
        return
    }

    $sspin = Start-Spin ("stamping " + $docName + "...")
    try {
        Add-Stamp $file $lines.ToArray()
        Stop-Spin $sspin
        Write-Host ("   Saved. Stamped " + $lines.Count + " line(s) onto page 1 of") -ForegroundColor Green
        Write-Host ("   " + $docName) -ForegroundColor Green
    } catch {
        Stop-Spin $sspin
        Write-Host ("   ERROR while stamping: " + $_.Exception.Message) -ForegroundColor Red
    }
}

function Show-DocMenu {
    param([string]$Title, [object[]]$Entries)
    $selectable = @()
    for ($i = 0; $i -lt $Entries.Count; $i++) { if (-not $Entries[$i].Header) { $selectable += $i } }
    if ($selectable.Count -eq 0) { return -1 }
    $pos = 0
    $top = 0
    try { [Console]::CursorVisible = $false } catch { }
    while ($true) {
        $rows = Get-ViewRows
        $cur = $selectable[$pos]
        if ($cur -lt $top) { $top = $cur }
        if ($cur -ge $top + $rows) { $top = $cur - $rows + 1 }
        if ($top -gt $Entries.Count - $rows) { $top = $Entries.Count - $rows }
        if ($top -lt 0) { $top = 0 }
        $end = [math]::Min($top + $rows - 1, $Entries.Count - 1)

        $frame = Get-HeaderRows
        $frame.Add(@(@{ T = ""; F = "Gray" }))
        $frame.Add(@(@{ T = ("   " + $Title); F = "Cyan" }))
        $frame.Add(@(@{ T = ""; F = "Gray" }))
        for ($i = $top; $i -le $end; $i++) {
            $e = $Entries[$i]
            if ($e.Header) {
                if ($e.Text -eq "") { $frame.Add(@(@{ T = ""; F = "Gray" })) }
                else { $frame.Add(@(@{ T = ("   " + $e.Text); F = "Yellow" })) }
            } elseif ($i -eq $cur) {
                $frame.Add(@(@{ T = ("   > " + ([string]$e.Text).PadRight(58)); F = "Black"; B = "Cyan" }))
            } elseif ($e.Done) {
                $frame.Add(@(@{ T = ("     " + $e.Text); F = "DarkGreen" }))
            } else {
                $frame.Add(@(@{ T = ("     " + $e.Text); F = "Gray" }))
            }
        }
        $frame.Add(@(@{ T = ""; F = "Gray" }))
        $hint = "   Up/Down = move     Enter = select     Esc / Backspace = back"
        if ($top -gt 0 -or $end -lt $Entries.Count - 1) {
            $hint = $hint + "     " + ($pos + 1) + "/" + $selectable.Count
        }
        $frame.Add(@(@{ T = $hint; F = "DarkGray" }))
        $grid = Render-Frame $frame

        $key = Wait-KeyWithSnow $grid
        switch ($key.Key) {
            'UpArrow'   { $pos = ($pos - 1 + $selectable.Count) % $selectable.Count }
            'DownArrow' { $pos = ($pos + 1) % $selectable.Count }
            'Home'      { $pos = 0 }
            'End'       { $pos = $selectable.Count - 1 }
            'PageUp'    { $pos = [math]::Max(0, $pos - 10) }
            'PageDown'  { $pos = [math]::Min($selectable.Count - 1, $pos + 10) }
            'Enter'     { try { [Console]::CursorVisible = $true } catch { }; Clear-Host; return $selectable[$pos] }
            'Escape'    { try { [Console]::CursorVisible = $true } catch { }; Clear-Host; return -1 }
            'Backspace' { try { [Console]::CursorVisible = $true } catch { }; Clear-Host; return -1 }
            'Delete'    { try { [Console]::CursorVisible = $true } catch { }; Clear-Host; return -1 }
        }
    }
}

function Print-Pdf([string]$path, [string]$printerName, [int]$copies) {
    Add-Type -AssemblyName System.Runtime.WindowsRuntime | Out-Null
    Add-Type -AssemblyName System.Drawing | Out-Null

    $asOp = [System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
        $_.Name -eq 'AsTask' -and $_.IsGenericMethodDefinition -and $_.GetParameters().Count -eq 1 -and
        $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
    } | Select-Object -First 1

    $asAct = [System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
        $_.Name -eq 'AsTask' -and -not $_.IsGenericMethodDefinition -and $_.GetParameters().Count -eq 1 -and
        $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncAction'
    } | Select-Object -First 1

    [void][Windows.Storage.StorageFile, Windows.Storage, ContentType = WindowsRuntime]
    [void][Windows.Data.Pdf.PdfDocument, Windows.Data.Pdf, ContentType = WindowsRuntime]
    [void][Windows.Storage.Streams.InMemoryRandomAccessStream, Windows.Storage.Streams, ContentType = WindowsRuntime]
    [void][Windows.Data.Pdf.PdfPageRenderOptions, Windows.Data.Pdf, ContentType = WindowsRuntime]

    $fileOp = [Windows.Storage.StorageFile]::GetFileFromPathAsync($path)
    $fileTask = $asOp.MakeGenericMethod([Windows.Storage.StorageFile]).Invoke($null, @($fileOp))
    $fileTask.Wait(-1) | Out-Null
    $file = $fileTask.Result

    $pdfOp = [Windows.Data.Pdf.PdfDocument]::LoadFromFileAsync($file)
    $pdfTask = $asOp.MakeGenericMethod([Windows.Data.Pdf.PdfDocument]).Invoke($null, @($pdfOp))
    $pdfTask.Wait(-1) | Out-Null
    $pdf = $pdfTask.Result

    $bitmaps = New-Object System.Collections.Generic.List[System.Drawing.Image]
    for ($i = 0; $i -lt $pdf.PageCount; $i++) {
        $page = $pdf.GetPage([uint32]$i)
        $ras = New-Object Windows.Storage.Streams.InMemoryRandomAccessStream
        $opts = New-Object Windows.Data.Pdf.PdfPageRenderOptions
        $opts.DestinationWidth = [uint32]([math]::Round($page.Size.Width * 3))
        $renderAct = $page.RenderToStreamAsync($ras, $opts)
        $renderTask = $asAct.Invoke($null, @($renderAct))
        $renderTask.Wait(-1) | Out-Null
        $net = [System.IO.WindowsRuntimeStreamExtensions]::AsStream($ras)
        $net.Position = 0
        $bitmaps.Add([System.Drawing.Image]::FromStream($net))
        $page.Dispose()
    }

    $pd = New-Object System.Drawing.Printing.PrintDocument
    $pd.PrinterSettings.PrinterName = $printerName
    if (-not $pd.PrinterSettings.IsValid) { throw "Printer not available: $printerName" }
    $pd.PrinterSettings.Copies = [int16]$copies
    $pd.DocumentName = [System.IO.Path]::GetFileName($path)
    $pd.OriginAtMargins = $false
    try { $pd.DefaultPageSettings.Margins = New-Object System.Drawing.Printing.Margins(0, 0, 0, 0) } catch { }
    if ($bitmaps.Count -gt 0) {
        $pd.DefaultPageSettings.Landscape = ($bitmaps[0].Width -gt $bitmaps[0].Height)
    }

    $script:__printIdx = 0
    $handler = {
        param($sender, $e)
        $img = $bitmaps[$script:__printIdx]
        $rect = $e.PageBounds
        $ratio = [math]::Min($rect.Width / $img.Width, $rect.Height / $img.Height)
        $w = [int]($img.Width * $ratio)
        $h = [int]($img.Height * $ratio)
        $x = [int](($rect.Width - $w) / 2)
        $y = [int](($rect.Height - $h) / 2)
        try {
            $x = $x - [int]$e.PageSettings.HardMarginX
            $y = $y - [int]$e.PageSettings.HardMarginY
        } catch { }
        $e.Graphics.DrawImage($img, $x, $y, $w, $h)
        $script:__printIdx++
        $e.HasMorePages = $script:__printIdx -lt $bitmaps.Count
    }
    $pd.add_PrintPage($handler)
    $pd.Print()
    $pd.remove_PrintPage($handler)

    foreach ($b in $bitmaps) { $b.Dispose() }
}

function Invoke-Print {
    $printer = Get-Setting 'PRINTER'
    $valid = $false
    if ($printer) {
        try { $valid = (@(Get-Printer -ErrorAction Stop | Select-Object -ExpandProperty Name) -contains $printer) }
        catch { $valid = $true }
    }
    if (-not $valid) {
        $printer = Select-Printer
        if (-not $printer) { $script:SkipPause = $true; return }
        Set-Setting 'PRINTER' $printer
    }

    $printedFile = Join-Path $AppDir "_doc_wizard_printed.txt"
    $printed = New-Object System.Collections.Generic.HashSet[string]
    if (Test-Path -LiteralPath $printedFile) {
        foreach ($ln in (Get-Content -LiteralPath $printedFile)) {
            $t = $ln.Trim()
            if ($t) { [void]$printed.Add($t) }
        }
    }

    $pairFile = Join-Path $AppDir "_doc_wizard_pairs.txt"
    $pairs = @{}
    if (Test-Path -LiteralPath $pairFile) {
        foreach ($l in (Get-Content -LiteralPath $pairFile)) {
            if ($l -match '^(PAC\d+)=(PWS\d+)$') { $pairs[$matches[1]] = $matches[2] }
        }
    }

    while ($true) {
        $spin = Start-Spin "reading documents..."
        $pacFiles = @(Get-ChildItem -LiteralPath $WorkDir -Filter 'PAC*.pdf' | Sort-Object Name)
        $pwsFiles = @(Get-ChildItem -LiteralPath $WorkDir -Filter 'PWS*.pdf' | Sort-Object Name)
        $wp = @(Get-ChildItem -LiteralPath $WorkDir -Filter 'WP*.pdf' | Sort-Object Name)

        $pwsByNum = @{}
        foreach ($f in $pwsFiles) { if ($f.Name -match '^(PWS\d+)') { $pwsByNum[$matches[1]] = $f } }

        $groups = New-Object System.Collections.Generic.List[object]
        $usedPws = @{}
        $pairsDirty = $false
        foreach ($f in $pacFiles) {
            $pacNum = if ($f.Name -match '^(PAC\d+)') { $matches[1] } else { $f.BaseName }
            $sord = if ($f.Name -match 'SORD\d+-\d+') { $matches[0] } else { "" }
            $pwsNum = $pairs[$pacNum]
            if (-not $pwsNum) {
                $pwsNum = Get-PwsFromPdf $f.FullName
                if ($pwsNum) { $pairs[$pacNum] = $pwsNum; $pairsDirty = $true }
            }
            $paths = @()
            $label = $pacNum
            if ($pwsNum -and $pwsByNum.ContainsKey($pwsNum)) {
                $paths += $pwsByNum[$pwsNum].FullName
                $usedPws[$pwsNum] = $true
                $label = "$pwsNum + $pacNum"
            }
            $paths += $f.FullName
            if ($sord) { $label = $label + "   (" + $sord + ")" }
            $groups.Add(@{ Id = $pacNum; Label = $label; Paths = $paths })
        }
        foreach ($num in ($pwsByNum.Keys | Sort-Object)) {
            if (-not $usedPws[$num]) {
                $f = $pwsByNum[$num]
                $sord = if ($f.Name -match 'SORD\d+-\d+') { $matches[0] } else { "" }
                $label = $num
                if ($sord) { $label = $label + "   (" + $sord + ")" }
                $groups.Add(@{ Id = $num; Label = $label; Paths = @($f.FullName) })
            }
        }
        if ($pairsDirty -and $pairs.Count -gt 0) {
            try { Set-Content -LiteralPath $pairFile -Value (@($pairs.GetEnumerator() | ForEach-Object { $_.Key + "=" + $_.Value })) } catch { }
        }

        $entries = New-Object System.Collections.Generic.List[object]
        $entries.Add(@{ Text = "Delivery documents   (2 copies)"; Header = $true })
        if ($groups.Count -eq 0) { $entries.Add(@{ Text = "(none)"; Header = $true }) }
        foreach ($g in $groups) {
            $done = $printed.Contains($g.Id)
            $disp = $g.Label
            if ($done) { $disp = $disp + "   [printed]" }
            $entries.Add(@{ Text = $disp; Header = $false; Paths = $g.Paths; Copies = 2; Id = $g.Id; Done = $done })
        }
        $entries.Add(@{ Text = ""; Header = $true })
        $entries.Add(@{ Text = "Warehouse picks   (1 copy)"; Header = $true })

        $groupages = Get-ActiveGroupages
        $covered = @{}
        foreach ($g in $groupages) { foreach ($n in $g.Names) { $covered[$n] = $true } }

        if ($wp.Count -eq 0 -and $groupages.Count -eq 0) { $entries.Add(@{ Text = "(none)"; Header = $true }) }

        foreach ($g in $groupages) {
            $done = $printed.Contains($g.Id)
            $t = $g.Label
            if ($done) { $t = $t + "   [printed]" }
            $entries.Add(@{ Text = $t; Header = $false; Paths = $g.Paths; Copies = 1; Id = $g.Id; Done = $done; Open = $g.Xlsx })
        }
        foreach ($f in $wp) {
            if ($covered.ContainsKey($f.Name)) { continue }
            $done = $printed.Contains($f.Name)
            $t = $f.Name
            if ($done) { $t = $t + "   [printed]" }
            $entries.Add(@{ Text = $t; Header = $false; Paths = @($f.FullName); Copies = 1; Id = $f.Name; Done = $done })
        }
        $entries.Add(@{ Text = ""; Header = $true })
        $entries.Add(@{ Text = "Back"; Header = $false; Paths = $null; Copies = 0 })

        Stop-Spin $spin
        $sel = Show-DocMenu ("PRINTER  ->  " + $printer) $entries.ToArray()
        if ($sel -lt 0) { $script:SkipPause = $true; return }
        $chosen = $entries[$sel]
        if (-not $chosen.Paths) { $script:SkipPause = $true; return }

        Clear-Host
        Show-Header
        Write-Host ""
        $allOk = $true
        for ($set = 1; $set -le $chosen.Copies; $set++) {
            if ($chosen.Copies -gt 1) {
                Write-Host ("  --- Set " + $set + " of " + $chosen.Copies + " ---") -ForegroundColor DarkGray
            }
            foreach ($p in $chosen.Paths) {
                Write-Host ("  Printing " + [System.IO.Path]::GetFileName($p) + "  ->  " + $printer) -ForegroundColor Cyan
                $pspin = Start-Spin ("sending " + [System.IO.Path]::GetFileName($p) + " to " + $printer + "...")
                try {
                    Print-Pdf $p $printer 1
                    Stop-Spin $pspin
                    Write-Host "    Sent." -ForegroundColor Green
                } catch {
                    Stop-Spin $pspin
                    Write-Host ("    ERROR: " + $_.Exception.Message) -ForegroundColor Red
                    $allOk = $false
                }
            }
        }
        if ($chosen.Open -and (Test-Path -LiteralPath $chosen.Open)) {
            Write-Host ("  Opening " + [System.IO.Path]::GetFileName($chosen.Open) + " (print it manually)") -ForegroundColor Cyan
            try { Start-Process -FilePath $chosen.Open } catch { }
        }
        if ($allOk -and $chosen.Id) {
            [void]$printed.Add($chosen.Id)
            try { Set-Content -LiteralPath $printedFile -Value (@($printed)) } catch { }
        }
        Write-Host ""
        Write-Host "   Press any key to continue..." -ForegroundColor DarkGray
        [void][Console]::ReadKey($true)
    }
}

function Get-PageBody([string]$s) {
    foreach ($m in [regex]::Matches($s, '\d+\s+0\s+obj(.*?)endobj', [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
        if ($m.Groups[1].Value -match '/Type\s*/Page(?!s)') { return $m.Groups[1].Value }
    }
    return ""
}

function Get-Obj([string]$s, [int]$num) {
    $m = [regex]::Match($s, '(?<![0-9])' + $num + '\s+0\s+obj(.*?)endobj', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($m.Success) { return $m.Groups[1].Value } else { return "" }
}

function Expand-ObjStream([string]$body) {
    $st = $body.IndexOf('stream')
    $en = $body.IndexOf('endstream')
    if ($st -lt 0 -or $en -lt 0) { return "" }
    $raw = $body.Substring($st + 6, $en - $st - 6).TrimStart("`r", "`n")
    $d = Inflate ($latin.GetBytes($raw))
    if ($d) { return $latin.GetString($d) } else { return "" }
}

function Decode-Hex([string]$s, [string]$page, [string]$fname, [string]$hex) {
    $fm = [regex]::Match($page, '/' + $fname + '\s+(\d+)\s+0\s+R')
    if (-not $fm.Success) { return "" }
    $fobj = Get-Obj $s ([int]$fm.Groups[1].Value)
    $tm = [regex]::Match($fobj, '/ToUnicode\s+(\d+)\s+0\s+R')
    if (-not $tm.Success) { return "" }
    $cmap = Expand-ObjStream (Get-Obj $s ([int]$tm.Groups[1].Value))
    $single = @{}
    $bc = [regex]::Match($cmap, 'beginbfchar(.*?)endbfchar', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($bc.Success) {
        foreach ($m in [regex]::Matches($bc.Groups[1].Value, '<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>')) {
            $u = $m.Groups[2].Value
            if ($u.Length -gt 4) { $u = $u.Substring(0, 4) }
            $single[[Convert]::ToInt32($m.Groups[1].Value, 16)] = [Convert]::ToInt32($u, 16)
        }
    }
    $ranges = New-Object System.Collections.Generic.List[object]
    $br = [regex]::Match($cmap, 'beginbfrange(.*?)endbfrange', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($br.Success) {
        foreach ($m in [regex]::Matches($br.Groups[1].Value, '<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>')) {
            $ranges.Add(@{ A = [Convert]::ToInt32($m.Groups[1].Value, 16); B = [Convert]::ToInt32($m.Groups[2].Value, 16); U = [Convert]::ToInt32($m.Groups[3].Value, 16) })
        }
    }
    $sb = New-Object System.Text.StringBuilder
    for ($i = 0; $i + 4 -le $hex.Length; $i += 4) {
        $g = [Convert]::ToInt32($hex.Substring($i, 4), 16)
        if ($single.ContainsKey($g)) { [void]$sb.Append([char]$single[$g]) }
        else { foreach ($r in $ranges) { if ($g -ge $r.A -and $g -le $r.B) { [void]$sb.Append([char]($r.U + ($g - $r.A))); break } } }
    }
    return $sb.ToString()
}

function Get-DeliveryInfo([string]$path) {
    $bytes = [System.IO.File]::ReadAllBytes($path)
    $s = $latin.GetString($bytes)
    $t = Get-PdfText $path

    $month = 0; $year = ""
    $dm = [regex]::Match($t, '(\d{2})\.(\d{2})\.(\d{4})')
    if ($dm.Success) { $month = [int]$dm.Groups[2].Value; $year = $dm.Groups[3].Value }

    $label = if ($t -match 'Sold To\) Tj') { 'Sold To' } else { 'Customer' }
    $customer = ""
    $li = $t.IndexOf($label + ') Tj')
    if ($li -ge 0) {
        $seg = $t.Substring($li + 5, [math]::Min(450, $t.Length - $li - 5))
        $fm = [regex]::Match($seg, '/(F\d+)\s+[\d.]+\s+Tf[^)>]*?(?:\(((?:[^()\\]|\\.)*)\)|<([0-9A-Fa-f]+)>)\s*Tj', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        if ($fm.Success) {
            if ($fm.Groups[2].Success) {
                $customer = $fm.Groups[2].Value -replace '\\\(', '(' -replace '\\\)', ')'
            } else {
                $customer = Decode-Hex $s (Get-PageBody $s) $fm.Groups[1].Value $fm.Groups[3].Value
            }
            $customer = $customer.Trim()
        }
    }

    $siteSb = New-Object System.Text.StringBuilder
    foreach ($m in [regex]::Matches($t, '\(((?:[^()\\]|\\.)*)\)\s*Tj')) {
        $val = $m.Groups[1].Value
        if ($val -match 'Marienh|Siegen|57080') { continue }
        [void]$siteSb.Append(" ")
        [void]$siteSb.Append($val)
    }
    $siteText = $siteSb.ToString()
    $country = Get-CountryCode $siteText

    return @{ Customer = $customer; Month = $month; Year = $year; SiteText = $siteText; Country = $country }
}

function Normalize-Name([string]$n) {
    if (-not $n) { return "" }
    $x = $n.ToLower()
    $x = $x -replace '[' + [char]0xe0 + '-' + [char]0xe5 + ']', 'a'
    $x = $x -replace '[' + [char]0xe8 + '-' + [char]0xeb + ']', 'e'
    $x = $x -replace '[' + [char]0xec + '-' + [char]0xef + ']', 'i'
    $x = $x -replace '[' + [char]0xf2 + '-' + [char]0xf6 + ']', 'o'
    $x = $x -replace '[' + [char]0xf9 + '-' + [char]0xfc + ']', 'u'
    $x = $x -replace [char]0xe7, 'c'
    $x = $x -replace [char]0xdf, 'ss'
    $x = $x -replace '\b(gmbh|ag|sas|sarl|sro|ab|bv|nv|sa|srl|spa|ltd|limited|oy|as|aps|co|kg|se|plc|inc|the)\b', ' '
    $x = $x -replace '[^a-z0-9]', ' '
    $x = $x -replace '\s+', ' '
    return $x.Trim()
}

function Score-Name([string]$a, [string]$b) {
    $na = Normalize-Name $a
    $nb = Normalize-Name $b
    if (-not $na -or -not $nb) { return 0 }
    if ($na -eq $nb) { return 100 }
    if ($nb.Contains($na) -or $na.Contains($nb)) { return 80 }
    $ta = @($na -split ' ')
    $tb = @($nb -split ' ')
    $common = 0
    foreach ($w in $ta) { if ($w.Length -ge 2 -and ($tb -contains $w)) { $common++ } }
    if ($common -gt 0) { return 40 + $common * 10 }
    if ($ta[0] -eq $tb[0]) { return 25 }
    foreach ($w in $ta) { if ($w.Length -ge 4 -and $nb.Contains($w)) { return 20 } }
    foreach ($w in $tb) { if ($w.Length -ge 4 -and $na.Contains($w)) { return 15 } }
    return 0
}

function Find-BestBase([string]$root, [hashtable]$info) {
    $bestCust = $null; $bestCustScore = 0
    $bestCountry = $null; $bestCountryScore = -1
    foreach ($cd in (Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue)) {
        $cScore = Score-Country $cd.Name $info.Country
        if ($cScore -gt $bestCountryScore) { $bestCountryScore = $cScore; $bestCountry = $cd.FullName }
        foreach ($ud in (Get-ChildItem -LiteralPath $cd.FullName -Directory -ErrorAction SilentlyContinue)) {
            $s = Score-Name $info.Customer $ud.Name
            if ($s -gt 0) {
                $s = $s + ($cScore * 15)
                if ($s -gt $bestCustScore) { $bestCustScore = $s; $bestCust = $ud.FullName }
            }
        }
    }
    if ($bestCust) { return $bestCust }
    if ($bestCountryScore -ge 1) { return $bestCountry }
    return $root
}

function Test-FolderMonth([string]$name, [int]$month, [string]$year) {
    $fm = Get-FolderMonth $name
    if ($fm -ne 0 -and $fm -ne $month) { return -1 }
    $y2 = $year.Substring($year.Length - 2)
    $hasYear = ($name -match $year) -or ($name -match ('(^|\D)' + $y2 + '(\D|$)'))
    $hasMonth = ($fm -eq $month)
    if ($hasMonth -and $hasYear) { return 3 }
    if ($hasMonth) { return 2 }
    if ($hasYear) { return 1 }
    return 0
}

function Score-FolderSite([string]$name, [string]$siteText) {
    $nf = Normalize-Name $name
    if (-not $nf) { return 0 }
    $ns = Normalize-Name $siteText
    if (-not $ns) { return 0 }
    $docTokens = @($ns -split ' ' | Where-Object { $_.Length -ge 3 })
    if ($docTokens.Count -eq 0) { return 0 }
    $score = 0
    foreach ($t in ($nf -split ' ')) {
        if ($t.Length -lt 3) { continue }
        foreach ($d in $docTokens) {
            if ($d -eq $t) { $score += 2; break }
            if ($t.Length -ge 4 -and $d.Length -ge 4 -and ($d.StartsWith($t) -or $t.StartsWith($d))) { $score += 1; break }
        }
    }
    return $score
}

function Test-FolderSite([string]$name, [string]$siteText) {
    return ((Score-FolderSite $name $siteText) -ge 2)
}

function Get-CountryCode([string]$siteText) {
    if (-not $siteText) { return "" }
    $m = [regex]::Match($siteText, '\b([A-Za-z]{2})-\d{3,5}')
    if ($m.Success -and $CountryNames.ContainsKey($m.Groups[1].Value.ToUpper())) { return $m.Groups[1].Value.ToUpper() }
    $ns = Normalize-Name $siteText
    foreach ($code in $CountryNames.Keys) {
        foreach ($v in $CountryNames[$code]) {
            if ($ns -match ('\b' + $v + '\b')) { return $code }
        }
    }
    foreach ($mm in [regex]::Matches($siteText, '\b([A-Z]{2})\b')) {
        if ($CountryNames.ContainsKey($mm.Groups[1].Value)) { return $mm.Groups[1].Value }
    }
    return ""
}

function Score-Country([string]$folderName, [string]$code) {
    if (-not $code) { return 0 }
    $nf = Normalize-Name $folderName
    if (-not $nf) { return 0 }
    $lc = $code.ToLower()
    if ($nf -eq $lc) { return 1 }
    if ($nf -match ('\b' + $lc + '\b')) { return 1 }
    foreach ($v in $CountryNames[$code]) { if ($nf -eq $v -or $nf.Contains($v)) { return 1 } }
    return 0
}

function Get-FolderMonth([string]$name) {
    if (-not $name) { return 0 }
    for ($i = 0; $i -lt 12; $i++) {
        if ([regex]::IsMatch($name, ('\b(' + $MonthPat[$i] + ')\b'), [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) { return ($i + 1) }
    }
    if ($name -match '^\s*(0?[1-9]|1[0-2])\s*$') { return [int]$matches[1] }
    if ($name -match '\b20\d{2}\b') {
        $rest = $name -replace '\b20\d{2}\b', ' '
        if ($rest -match '(?<!\d)(0?[1-9]|1[0-2])(?!\d)') { return [int]$matches[1] }
    }
    return 0
}

function Fold-Text([string]$s) {
    if (-not $s) { return "" }
    $x = $s.ToLower()
    $x = $x -replace [char]0xe4, 'a'
    $x = $x -replace [char]0xf6, 'o'
    $x = $x -replace [char]0xfc, 'u'
    return $x
}

function Apply-Case([string]$src, [string]$dst) {
    if ($src -ceq $src.ToUpper()) { return $dst.ToUpper() }
    if ($src.Substring(0, 1) -ceq $src.Substring(0, 1).ToUpper()) { return ($dst.Substring(0, 1).ToUpper() + $dst.Substring(1)) }
    return $dst.ToLower()
}

function Build-MonthFolderName([string]$sample, [int]$month, [string]$year) {
    $out = $sample
    $mi = 0
    $mm = $null
    for ($i = 0; $i -lt 12; $i++) {
        $m = [regex]::Match($sample, ('\b(' + $MonthPat[$i] + ')\b'), [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($m.Success) { $mi = $i + 1; $mm = $m; break }
    }
    if ($mi -gt 0) {
        $tok = $mm.Value
        $f = Fold-Text $tok
        $new = $MonthAbbrDE[$month - 1]
        if ($f -eq (Fold-Text $MonthsDE[$mi - 1])) { $new = $MonthsDE[$month - 1] }
        elseif ($f -eq (Fold-Text $MonthsEN[$mi - 1])) { $new = $MonthsEN[$month - 1] }
        elseif ($f -eq (Fold-Text $MonthAbbrDE[$mi - 1])) { $new = $MonthAbbrDE[$month - 1] }
        elseif ($f -eq (Fold-Text $MonthAbbrEN[$mi - 1])) { $new = $MonthAbbrEN[$month - 1] }
        $new = Apply-Case $tok $new
        $out = $out.Substring(0, $mm.Index) + $new + $out.Substring($mm.Index + $mm.Length)
    } else {
        $nm = [regex]::Match($sample, '(?<!\d)(0[1-9]|1[0-2])(?!\d)')
        if ($nm.Success) { $out = $out.Substring(0, $nm.Index) + ('{0:D2}' -f $month) + $out.Substring($nm.Index + $nm.Length) }
    }
    $y4 = [regex]::Match($out, '\b20\d{2}\b')
    if ($y4.Success) {
        $out = $out.Substring(0, $y4.Index) + $year + $out.Substring($y4.Index + $y4.Length)
    } else {
        $y2 = [regex]::Match($out, '(?<!\d)(\d{2})(?!\d)')
        if ($y2.Success -and (-not ($y2.Groups[1].Value -match '^(0[1-9]|1[0-2])$'))) {
            $out = $out.Substring(0, $y2.Index) + $year.Substring(2) + $out.Substring($y2.Index + $y2.Length)
        }
    }
    return $out
}

function Get-FolderYear([string]$name) {
    $m = [regex]::Match($name, '\b(20\d{2})\b')
    if ($m.Success) { return $m.Groups[1].Value }
    if ($name -match '^\s*(\d{2})\s*$') { return ("20" + $matches[1]) }
    return ""
}

function Suggest-MonthFolder([string]$container, [int]$month, [string]$year) {
    if ($container -and (Test-Path -LiteralPath $container)) {
        $sibs = @(Get-ChildItem -LiteralPath $container -Directory -ErrorAction SilentlyContinue | Where-Object { (Get-FolderMonth $_.Name) -ne 0 })
        if ($sibs.Count -gt 0) {
            $sameYear = @($sibs | Where-Object { (Get-FolderYear $_.Name) -eq $year })
            $model = $sibs[$sibs.Count - 1].Name
            if ($sameYear.Count -gt 0) { $model = $sameYear[$sameYear.Count - 1].Name }
            return (Build-MonthFolderName $model $month $year)
        }
    }
    return ($MonthsDE[$month - 1] + " " + $year)
}

function Resolve-CreateTarget([string]$cur, [int]$month, [string]$year) {
    $p = $cur
    if ((Get-FolderMonth (Split-Path $p -Leaf)) -ne 0) { $p = Split-Path $p -Parent }

    $chain = @()
    $probe = $p
    for ($i = 0; $i -lt 5; $i++) {
        if (-not $probe) { break }
        $leaf = Split-Path $probe -Leaf
        $py = Get-FolderYear $leaf
        if ($py -and ((Get-FolderMonth $leaf) -eq 0)) {
            if ($py -eq $year) { break }
            $parent = Split-Path $probe -Parent
            $sib = @(Get-ChildItem -LiteralPath $parent -Directory -ErrorAction SilentlyContinue | Where-Object { ((Get-FolderMonth $_.Name) -eq 0) -and ((Get-FolderYear $_.Name) -eq $year) })
            if ($sib.Count -gt 0) {
                $newBase = $sib[0].FullName
                foreach ($seg in $chain) {
                    $cand = Join-Path $newBase $seg
                    if (Test-Path -LiteralPath $cand) { $newBase = $cand } else { break }
                }
                return @{ Parent = $newBase; NeedYear = "" }
            }
            return @{ Parent = $parent; NeedYear = $year }
        }
        $chain = @($leaf) + $chain
        $probe = Split-Path $probe -Parent
    }

    $yearDirs = @(Get-ChildItem -LiteralPath $p -Directory -ErrorAction SilentlyContinue | Where-Object { ((Get-FolderMonth $_.Name) -eq 0) -and (Get-FolderYear $_.Name) })
    if ($yearDirs.Count -gt 0) {
        $match = @($yearDirs | Where-Object { (Get-FolderYear $_.Name) -eq $year })
        if ($match.Count -gt 0) { return @{ Parent = $match[0].FullName; NeedYear = "" } }
        return @{ Parent = $p; NeedYear = $year }
    }

    return @{ Parent = $p; NeedYear = "" }
}

function Resolve-StartFolder([string]$root, [hashtable]$info) {
    $start = Find-BestBase $root $info
    if ($start -eq $root) { return $root }
    for ($d = 0; $d -lt 6; $d++) {
        $children = @(Get-ChildItem -LiteralPath $start -Directory -ErrorAction SilentlyContinue)
        if ($children.Count -eq 0) { break }
        $bestChild = $null; $bestScore = 0; $bestMy = 0
        foreach ($c in $children) {
            $my = Test-FolderMonth $c.Name $info.Month $info.Year
            $si = Score-FolderSite $c.Name $info.SiteText
            $cu = 0
            if ((Score-Name $info.Customer $c.Name) -ge 40) { $cu = 1 }
            $sc = $my * 10 + $si * 2 + $cu * 3
            if ($my -lt 0) { $sc = -1 }
            if ($sc -gt $bestScore) { $bestScore = $sc; $bestChild = $c.FullName; $bestMy = $my }
        }
        if ($bestScore -eq 0) { break }
        $start = $bestChild
        if ($bestMy -ge 2) { return $start }
    }
    return $start
}

function Browse-ForFolder([string]$desc) {
    try {
        $sh = New-Object -ComObject Shell.Application
        $f = $sh.BrowseForFolder(0, $desc, 0, 0)
        if ($f -and $f.Self) { return $f.Self.Path }
    } catch { }
    return $null
}

function Get-SettingsFile { return (Join-Path $AppDir "_doc_wizard_settings.txt") }

function Get-Settings {
    $f = Get-SettingsFile
    $h = @{}
    if (Test-Path -LiteralPath $f) {
        foreach ($l in (Get-Content -LiteralPath $f)) {
            if ($l -match '^([A-Z_]+)=(.*)$') { $h[$matches[1]] = $matches[2] }
        }
        return $h
    }
    $oldRoot = Join-Path $AppDir "_doc_wizard_root.cfg"
    $oldPrn = Join-Path $AppDir "_doc_wizard.cfg"
    if (Test-Path -LiteralPath $oldRoot) { try { $h['ROOT'] = (Get-Content -LiteralPath $oldRoot -TotalCount 1).Trim() } catch { } }
    if (Test-Path -LiteralPath $oldPrn) { try { $h['PRINTER'] = (Get-Content -LiteralPath $oldPrn -TotalCount 1).Trim() } catch { } }
    if ($h.Count -gt 0) { Save-Settings $h }
    return $h
}

function Save-Settings([hashtable]$h) {
    $f = Get-SettingsFile
    $merged = @{}
    if (Test-Path -LiteralPath $f) {
        try {
            foreach ($l in (Get-Content -LiteralPath $f)) {
                if ($l -match '^([A-Z_]+)=(.*)$') { $merged[$matches[1]] = $matches[2] }
            }
        } catch { }
    }
    foreach ($k in @($h.Keys)) { $merged[$k] = $h[$k] }
    if ($merged.Count -eq 0) { return }
    try { Set-Content -LiteralPath $f -Value (@($merged.GetEnumerator() | ForEach-Object { $_.Key + "=" + $_.Value })) } catch { }
}

function Get-Setting([string]$key) {
    $h = Get-Settings
    if ($h.ContainsKey($key)) { return $h[$key] } else { return "" }
}

function Set-Setting([string]$key, [string]$val) {
    $h = Get-Settings
    $h[$key] = $val
    Save-Settings $h
}

function Get-OrAskFolder([string]$key, [string]$desc) {
    $p = Get-Setting $key
    if ($p -and (Test-Path -LiteralPath $p)) { return $p }
    $picked = Browse-ForFolder $desc
    if ($picked -and (Test-Path -LiteralPath $picked)) { Set-Setting $key $picked; return $picked }
    return $null
}

function Get-RootFolder {
    return (Get-OrAskFolder 'ROOT' "Select the ROOT folder (contains the country folders)")
}

function Select-Printer {
    try { $printers = @(Get-Printer -ErrorAction Stop | Sort-Object Name | Select-Object -ExpandProperty Name) }
    catch { $printers = @(Get-CimInstance Win32_Printer -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name) }
    if (-not $printers -or $printers.Count -eq 0) {
        Write-Host "  No printers found on this PC." -ForegroundColor Yellow
        [void][Console]::ReadKey($true)
        return $null
    }
    $items = @($printers) + "" + "Back"
    $sel = Show-Menu "SELECT PRINTER" $items
    if ($sel -lt 0 -or $items[$sel] -eq "Back") { return $null }
    return $items[$sel]
}

function Move-FileSafe([string]$src, [string]$dest) {
    try {
        Move-Item -LiteralPath $src -Destination $dest
        return $true
    } catch {
        Write-Host ("  In use, not moved: " + [System.IO.Path]::GetFileName($src)) -ForegroundColor Red
        Write-Host "  Close it in the PDF viewer or preview pane, then run Move again." -ForegroundColor DarkGray
        return $false
    }
}

function Move-PairInteractive([string]$root, [string]$startDir, [string]$title, [int]$month, [string]$year, [string]$siteText, [string[]]$files) {
    $cur = $startDir
    if (-not (Test-Path -LiteralPath $cur)) { $cur = $root }
    $suggest = $MonthsDE[$month - 1] + " " + $year

    while ($true) {
        $subs = @(Get-ChildItem -LiteralPath $cur -Directory -ErrorAction SilentlyContinue | Sort-Object Name)

        $entries = New-Object System.Collections.Generic.List[object]
        $entries.Add(@{ Text = $title; Header = $true })
        $entries.Add(@{ Text = ("Current: " + $cur); Header = $true })
        $entries.Add(@{ Text = ""; Header = $true })
        $entries.Add(@{ Text = "[ Move here ]"; Header = $false; Act = "SELECT" })
        if ($cur.TrimEnd('\').Length -gt $root.TrimEnd('\').Length) {
            $entries.Add(@{ Text = "[ .. up ]"; Header = $false; Act = "UP" })
        }
        $ct = Resolve-CreateTarget $cur $month $year
        $createParent = $ct.Parent
        $needYear = $ct.NeedYear
        $effContainer = $createParent
        if ($needYear) { $effContainer = Join-Path $createParent $needYear }
        $suggest = Suggest-MonthFolder $effContainer $month $year
        if ($needYear) {
            $createHint = "   -> creates " + $needYear + "\" + $suggest
        } elseif ($effContainer -ne $cur) {
            $createHint = "   -> in " + (Split-Path $effContainer -Leaf)
        } else {
            $createHint = ""
        }
        $entries.Add(@{ Text = ("[ + Create folder: " + $suggest + " ]" + $createHint); Header = $false; Act = "CREATE" })
        $entries.Add(@{ Text = "[ + New folder here (own name) ]"; Header = $false; Act = "NEWDIR" })
        $entries.Add(@{ Text = "[ Change root folder ]"; Header = $false; Act = "ROOT" })
        $entries.Add(@{ Text = "[ Back to list ]"; Header = $false; Act = "SKIP" })
        $entries.Add(@{ Text = ""; Header = $true })
        $entries.Add(@{ Text = "Subfolders:"; Header = $true })
        if ($subs.Count -eq 0) { $entries.Add(@{ Text = "(no subfolders)"; Header = $true }) }
        foreach ($d in $subs) {
            $mark = ""
            $mv = Test-FolderMonth $d.Name $month $year
            if ($mv -ge 2) { $mark = "   <-- month match" }
            elseif ($mv -eq 1) { $mark = "   <-- year" }
            elseif (Test-FolderSite $d.Name $siteText) { $mark = "   <-- location" }
            $entries.Add(@{ Text = ($d.Name + $mark); Header = $false; Act = ("DIR|" + $d.FullName) })
        }

        $sel = Show-DocMenu "MOVE DELIVERY DOCUMENTS" $entries.ToArray()
        if ($sel -lt 0) { return "SKIP" }
        $act = $entries[$sel].Act

        if ($act -eq "SELECT") {
            Clear-Host
            Show-Header
            Write-Host ""
            $ok = $true
            foreach ($f in $files) {
                $dest = Join-Path $cur ([System.IO.Path]::GetFileName($f))
                if (Test-Path -LiteralPath $dest) {
                    Write-Host ("  Target exists, skipped: " + [System.IO.Path]::GetFileName($f)) -ForegroundColor DarkYellow
                    $ok = $false
                    continue
                }
                if (-not (Move-FileSafe $f $dest)) { $ok = $false }
            }
            if ($ok) { Write-Host ("  Moved to: " + $cur) -ForegroundColor Green }
            return "MOVED"
        } elseif ($act -eq "UP") {
            $cur = [System.IO.Path]::GetDirectoryName($cur)
        } elseif ($act -eq "ROOT") {
            $picked = Browse-ForFolder "Select the ROOT folder"
            if ($picked -and (Test-Path -LiteralPath $picked)) {
                Set-Setting 'ROOT' $picked
                $script:__root = $picked
                $cur = $picked
            }
        } elseif ($act -eq "CREATE") {
            Write-Host ""
            $target = $effContainer
            Write-Host ("  Creating in: " + $target) -ForegroundColor DarkGray
            $name = Read-Host ("  Folder name (Enter = " + $suggest + ")")
            if ([string]::IsNullOrWhiteSpace($name)) { $name = $suggest }
            $newDir = Join-Path $target $name
            try {
                if ($needYear -and (-not (Test-Path -LiteralPath $target))) { New-Item -ItemType Directory -Path $target | Out-Null }
                if (-not (Test-Path -LiteralPath $newDir)) { New-Item -ItemType Directory -Path $newDir | Out-Null }
                $cur = $newDir
            } catch {
                Write-Host ("  Could not create folder: " + $_.Exception.Message) -ForegroundColor Red
                [void][Console]::ReadKey($true)
            }
        } elseif ($act -eq "NEWDIR") {
            Write-Host ""
            Write-Host ("  Creating in: " + $cur) -ForegroundColor DarkGray
            $name = Read-Host "  New folder name (empty = cancel)"
            if (-not [string]::IsNullOrWhiteSpace($name)) {
                $newDir = Join-Path $cur $name
                try {
                    if (-not (Test-Path -LiteralPath $newDir)) { New-Item -ItemType Directory -Path $newDir | Out-Null }
                    $cur = $newDir
                } catch {
                    Write-Host ("  Could not create folder: " + $_.Exception.Message) -ForegroundColor Red
                    [void][Console]::ReadKey($true)
                }
            }
        } elseif ($act -eq "SKIP") {
            return "SKIP"
        } elseif ($act -like "DIR|*") {
            $cur = $act.Substring(4)
        }
    }
}

function Move-ControlFile([string]$path) {
    $dest = Get-OrAskFolder 'PUMPCONTROL' "Select the PUMP CONTROL folder"
    if (-not $dest) { return 0 }

    Clear-Host
    Show-Header
    Write-Host ""

    $name = [System.IO.Path]::GetFileName($path)
    if (-not (Test-Path -LiteralPath $path)) { return 0 }
    $target = Join-Path $dest $name
    if (Test-Path -LiteralPath $target) {
        Write-Host ("  Target exists, skipped: " + $name) -ForegroundColor DarkYellow
        return 0
    }
    if (Move-FileSafe $path $target) {
        Write-Host ("  Moved " + $name + " -> " + $dest) -ForegroundColor Green
        return 1
    }
    return 0
}

function Move-WpBundle([string]$title, [string[]]$paths) {
    $opts = @("Pick list folder", "'Noch zu drucken' folder", "", "Back")
    $c = Show-Menu $title $opts
    if ($c -lt 0) { return 0 }
    $pick = $opts[$c]
    if ($pick -eq "Back") { return 0 }
    if ($pick -eq "Pick list folder") { $dest = Get-OrAskFolder 'PICKLIST' "Select the PICK LIST folder" }
    else { $dest = Get-OrAskFolder 'REPRINT' "Select the 'Noch zu drucken' folder" }
    if (-not $dest) { return 0 }

    Clear-Host
    Show-Header
    Write-Host ""

    $n = 0
    foreach ($p in $paths) {
        $name = [System.IO.Path]::GetFileName($p)
        if (-not (Test-Path -LiteralPath $p)) { continue }
        $target = Join-Path $dest $name
        if (Test-Path -LiteralPath $target) {
            Write-Host ("  Target exists, skipped: " + $name) -ForegroundColor DarkYellow
            continue
        }
        if (Move-FileSafe $p $target) {
            Write-Host ("  Moved " + $name + " -> " + $dest) -ForegroundColor Green
            $n++
        }
    }
    return $n
}

function Get-PumpXlsxFor([string[]]$names) {
    $res = New-Object System.Collections.Generic.List[string]
    $wpNums = @{}
    foreach ($n in $names) {
        if ($n -match '^(WP\d+)') { $wpNums[$matches[1]] = $true }
    }
    if ($wpNums.Count -eq 0) { return @() }
    foreach ($x in @(Get-ChildItem -LiteralPath $WorkDir -Filter 'WP*_Pumpen*.xls*' -ErrorAction SilentlyContinue | Sort-Object Name)) {
        if ($x.Name -match '^(WP\d+)') {
            if ($wpNums.ContainsKey($matches[1])) { $res.Add($x.FullName) }
        }
    }
    return $res.ToArray()
}

function Invoke-Move {
    $script:__root = Get-RootFolder
    if (-not $script:__root) {
        Write-Host "  No root folder selected." -ForegroundColor Yellow
        return
    }

    $pairFile = Join-Path $AppDir "_doc_wizard_pairs.txt"
    $pairs = @{}
    if (Test-Path -LiteralPath $pairFile) {
        foreach ($l in (Get-Content -LiteralPath $pairFile)) {
            if ($l -match '^(PAC\d+)=(PWS\d+)$') { $pairs[$matches[1]] = $matches[2] }
        }
    }

    $moved = 0

    while ($true) {
        $spin = Start-Spin "reading documents..."
        $pacFiles = @(Get-ChildItem -LiteralPath $WorkDir -Filter 'PAC*.pdf' -ErrorAction SilentlyContinue | Sort-Object Name)
        $pwsFiles = @(Get-ChildItem -LiteralPath $WorkDir -Filter 'PWS*.pdf' -ErrorAction SilentlyContinue)
        $pwsByNum = @{}
        foreach ($f in $pwsFiles) { if ($f.Name -match '^(PWS\d+)') { $pwsByNum[$matches[1]] = $f } }

        $delEntries = New-Object System.Collections.Generic.List[object]
        $usedPws = @{}
        foreach ($f in $pacFiles) {
            $pacNum = if ($f.Name -match '^(PAC\d+)') { $matches[1] } else { $f.BaseName }
            $sord = if ($f.Name -match 'SORD\d+-\d+') { $matches[0] } else { "" }
            $pwsNum = $pairs[$pacNum]
            if (-not $pwsNum) { $pwsNum = Get-PwsFromPdf $f.FullName }
            $paths = @()
            $label = $pacNum
            if ($pwsNum -and $pwsByNum.ContainsKey($pwsNum)) {
                $paths += $pwsByNum[$pwsNum].FullName
                $usedPws[$pwsNum] = $true
                $label = "$pwsNum + $pacNum"
            }
            $paths += $f.FullName
            if ($sord) { $label = $label + "   (" + $sord + ")" }
            $delEntries.Add(@{ Label = $label; Paths = $paths; Src = $f })
        }
        foreach ($num in ($pwsByNum.Keys | Sort-Object)) {
            if (-not $usedPws[$num]) {
                $f = $pwsByNum[$num]
                $sord = if ($f.Name -match 'SORD\d+-\d+') { $matches[0] } else { "" }
                $label = $num
                if ($sord) { $label = $label + "   (" + $sord + ")" }
                $delEntries.Add(@{ Label = $label; Paths = @($f.FullName); Src = $f })
            }
        }

        $groupages = Get-ActiveGroupages
        $covered = @{}
        foreach ($g in $groupages) { foreach ($n in $g.Names) { $covered[$n] = $true } }
        $wpFiles = @(Get-ChildItem -LiteralPath $WorkDir -Filter 'WP*.pdf' -ErrorAction SilentlyContinue | Sort-Object Name)

        $entries = New-Object System.Collections.Generic.List[object]
        $entries.Add(@{ Text = "Delivery documents   (to customer folder)"; Header = $true })
        if ($delEntries.Count -eq 0) { $entries.Add(@{ Text = "(none)"; Header = $true }) }
        foreach ($d in $delEntries) {
            $entries.Add(@{ Text = $d.Label; Header = $false; Act = 'DEL'; Data = $d })
        }
        $entries.Add(@{ Text = ""; Header = $true })
        $entries.Add(@{ Text = "Warehouse picks   (to pick list / noch zu drucken)"; Header = $true })
        $pickCount = 0
        $usedPumps = @{}
        foreach ($g in $groupages) {
            $p = @($g.Paths)
            if ($g.HasXlsx) { $p += $g.Xlsx }
            $pumps = Get-PumpXlsxFor $g.Names
            $txt = $g.Label
            if ($pumps.Count -gt 0) {
                $p += $pumps
                foreach ($u in $pumps) { $usedPumps[$u] = $true }
                $txt = $txt + "  + " + $pumps.Count + " pump list(s)"
            }
            $entries.Add(@{ Text = $txt; Header = $false; Act = 'WP'; Title = ("MOVE GROUPAGE:   " + ($g.Customer -replace '_', ' ')); Paths = $p })
            $pickCount++
        }
        foreach ($f in $wpFiles) {
            if ($covered.ContainsKey($f.Name)) { continue }
            $p = @($f.FullName)
            $pumps = Get-PumpXlsxFor @($f.Name)
            $txt = $f.Name
            if ($pumps.Count -gt 0) {
                $p += $pumps
                foreach ($u in $pumps) { $usedPumps[$u] = $true }
                $txt = $txt + "   + pump list"
            }
            $entries.Add(@{ Text = $txt; Header = $false; Act = 'WP'; Title = ("MOVE PICK LIST:   " + $f.Name); Paths = $p })
            $pickCount++
        }
        foreach ($x in @(Get-ChildItem -LiteralPath $WorkDir -Filter 'WP*_Pumpen*.xls*' -ErrorAction SilentlyContinue | Sort-Object Name)) {
            if ($usedPumps.ContainsKey($x.FullName)) { continue }
            $entries.Add(@{ Text = $x.Name; Header = $false; Act = 'WP'; Title = ("MOVE PUMP LIST:   " + $x.Name); Paths = @($x.FullName) })
            $pickCount++
        }
        if ($pickCount -eq 0) { $entries.Add(@{ Text = "(none)"; Header = $true }) }
        $entries.Add(@{ Text = ""; Header = $true })
        $entries.Add(@{ Text = "Pump control files   (to pump control folder)"; Header = $true })
        $ctrlFiles = @(Get-ChildItem -LiteralPath $WorkDir -Filter 'WP*_Control*.xls*' -ErrorAction SilentlyContinue |
                       Where-Object { $_.Name -notmatch '^~\$' } | Sort-Object Name)
        if ($ctrlFiles.Count -eq 0) { $entries.Add(@{ Text = "(none)"; Header = $true }) }
        foreach ($c in $ctrlFiles) {
            $entries.Add(@{ Text = $c.Name; Header = $false; Act = 'CTRL'; Path = $c.FullName })
        }
        $entries.Add(@{ Text = ""; Header = $true })
        $entries.Add(@{ Text = "Back"; Header = $false; Act = 'BACK' })

        Stop-Spin $spin
        $sel = Show-DocMenu "MOVE DOCUMENTS" $entries.ToArray()
        if ($sel -lt 0) { break }
        $e = $entries[$sel]
        if ($e.Act -eq 'BACK') { break }

        $did = 0
        if ($e.Act -eq 'CTRL') {
            $did = Move-ControlFile $e.Path
        } elseif ($e.Act -eq 'WP') {
            $did = Move-WpBundle $e.Title $e.Paths
        } else {
            $d = $e.Data
            $dspin = Start-Spin ("analysing " + $d.Src.Name + "...")
            $info = Get-DeliveryInfo $d.Src.FullName
            if (-not $info.Month -or -not $info.Year) {
                $info.Month = (Get-Date).Month
                $info.Year = (Get-Date).Year.ToString()
            }
            $monthLabel = $MonthsDE[$info.Month - 1] + " " + $info.Year
            $title = $d.Label + "    Customer: " + $info.Customer + "    Date: " + $monthLabel
            $start = Resolve-StartFolder $script:__root $info
            Stop-Spin $dspin
            $res = Move-PairInteractive $script:__root $start $title $info.Month $info.Year $info.SiteText $d.Paths
            if ($res -eq "MOVED") { $did = $d.Paths.Count }
        }

        if ($did -gt 0) {
            $moved += $did
            Write-Host ""
            Write-Host "   Press any key to continue..." -ForegroundColor DarkGray
            [void][Console]::ReadKey($true)
        }
    }

    Invoke-Housekeeping

    Clear-Host
    Show-Header
    Write-Host ""
    Write-Host $light -ForegroundColor DarkCyan
    Write-Host "   MOVE SUMMARY" -ForegroundColor Cyan
    Write-Host ("     Files moved : " + $moved) -ForegroundColor Green
}

function Format-Setting([string]$value, [int]$max) {
    if (-not $value) { return "(not set)" }
    if ($value.Length -le $max) { return $value }
    return "..." + $value.Substring($value.Length - ($max - 3))
}

function Test-SetupComplete {
    $s = Get-Settings
    foreach ($k in @('PRINTER', 'ROOT', 'PICKLIST', 'REPRINT', 'PUMPCONTROL')) {
        if (-not $s[$k]) { return $false }
    }
    return $true
}

function Invoke-Settings([bool]$requireAll) {
    while ($true) {
        $s = Get-Settings
        $complete = Test-SetupComplete

        $entries = New-Object System.Collections.Generic.List[object]
        if ($requireAll) {
            $entries.Add(@{ Text = "Please configure all entries below."; Header = $true })
            $entries.Add(@{ Text = "They are stored, so you only do this once."; Header = $true })
            $entries.Add(@{ Text = ""; Header = $true })
        }
        if ($s['WORKDIR']) {
            $wdShow = Format-Setting $s['WORKDIR'] 46
        } else {
            $wdShow = (Format-Setting (Split-Path $AppDir -Parent) 38) + "   (auto)"
        }
        $entries.Add(@{ Text = ("Downloads folder".PadRight(24) + ":  " + $wdShow); Header = $false; Act = 'WORKDIR'; Done = [bool]$s['WORKDIR'] })
        $entries.Add(@{ Text = ""; Header = $true })
        $entries.Add(@{ Text = ("Default printer".PadRight(24) + ":  " + (Format-Setting $s['PRINTER'] 46)); Header = $false; Act = 'PRINTER'; Done = [bool]$s['PRINTER'] })
        $entries.Add(@{ Text = ("Outbound main folder".PadRight(24) + ":  " + (Format-Setting $s['ROOT'] 46)); Header = $false; Act = 'ROOT'; Done = [bool]$s['ROOT'] })
        $entries.Add(@{ Text = ("Pick list folder".PadRight(24) + ":  " + (Format-Setting $s['PICKLIST'] 46)); Header = $false; Act = 'PICKLIST'; Done = [bool]$s['PICKLIST'] })
        $entries.Add(@{ Text = ("'Noch zu drucken' folder".PadRight(24) + ":  " + (Format-Setting $s['REPRINT'] 46)); Header = $false; Act = 'REPRINT'; Done = [bool]$s['REPRINT'] })
        $entries.Add(@{ Text = ("Pump control folder".PadRight(24) + ":  " + (Format-Setting $s['PUMPCONTROL'] 46)); Header = $false; Act = 'PUMPCONTROL'; Done = [bool]$s['PUMPCONTROL'] })
        $bIdx = 0
        if ($s['BANNER'] -match '^\d+$') { $bIdx = [int]$s['BANNER'] }
        if ($bIdx -lt 0 -or $bIdx -ge $BannerStyles.Count) { $bIdx = 0 }
        $entries.Add(@{ Text = ("Banner style".PadRight(24) + ":  " + $BannerStyles[$bIdx].N); Header = $false; Act = 'BANNER'; Done = $true })
        $entries.Add(@{ Text = ""; Header = $true })
        if ($requireAll) {
            if ($complete) { $entries.Add(@{ Text = "Continue"; Header = $false; Act = 'DONE' }) }
            else { $entries.Add(@{ Text = "(set all entries above to continue)"; Header = $true }) }
        } else {
            $entries.Add(@{ Text = "Back"; Header = $false; Act = 'DONE' })
        }

        $title = if ($requireAll) { "WELCOME TO DOC WIZARD" } else { "SETTINGS" }
        $sel = Show-DocMenu $title $entries.ToArray()

        if ($sel -lt 0) {
            if ($requireAll -and -not $complete) { continue }
            $script:SkipPause = $true
            return
        }

        switch ($entries[$sel].Act) {
            'PRINTER'  { $pr = Select-Printer; if ($pr) { Set-Setting 'PRINTER' $pr } }
            'ROOT'     { $p = Browse-ForFolder "Select the OUTBOUND main folder (contains the country folders)"; if ($p) { Set-Setting 'ROOT' $p } }
            'PICKLIST' { $p = Browse-ForFolder "Select the PICK LIST folder"; if ($p) { Set-Setting 'PICKLIST' $p } }
            'REPRINT'  { $p = Browse-ForFolder "Select the 'Noch zu drucken' folder"; if ($p) { Set-Setting 'REPRINT' $p } }
            'PUMPCONTROL' { $p = Browse-ForFolder "Select the PUMP CONTROL folder"; if ($p) { Set-Setting 'PUMPCONTROL' $p } }
            'WORKDIR'  {
                $p = Browse-ForFolder "Select the DOWNLOADS folder (where the PDFs are downloaded)"
                if ($p) { Set-Setting 'WORKDIR' $p; $script:WorkDir = $p.TrimEnd('\') }
            }
            'BANNER'   {
                $names = @($BannerStyles | ForEach-Object { $_.N })
                $bsel = Show-Menu "BANNER STYLE" (@($names) + "" + "Back")
                if ($bsel -ge 0 -and $bsel -lt $names.Count) {
                    Set-Setting 'BANNER' ([string]$bsel)
                    $script:BannerCache = $null
                }
            }
            'DONE'     { $script:SkipPause = $true; return }
        }
    }
}

$mainItems = @("Auto rename/create documents", "Annotate WP documents", "Print", "Auto move to folders", "Settings", "Check for updates", "", "Quit")

$cfgWork = Get-Setting 'WORKDIR'
if ($cfgWork -and (Test-Path -LiteralPath $cfgWork)) { $WorkDir = $cfgWork.TrimEnd('\') }

try {
    Invoke-UpdateCheck

    if (-not (Test-SetupComplete)) { Invoke-Settings $true }

    Invoke-Housekeeping

    while ($true) {
        $choice = Show-Menu "MAIN MENU" $mainItems

        if ($choice -lt 0 -or $mainItems[$choice] -eq "Quit") {
            Clear-Host
            Show-Header
            Write-Host ""
            Write-Host "   Bye." -ForegroundColor DarkGray
            Write-Host ""
            try { [Console]::CursorVisible = $true } catch { }
            return
        }

        Clear-Host
        Show-Header
        Write-Host ""

        $script:SkipPause = $false
        switch ($mainItems[$choice]) {
            "Auto rename/create documents" { Invoke-Rename }
            "Annotate WP documents" { Invoke-Annotate }
            "Print"                 { Invoke-Print }
            "Auto move to folders"  { Invoke-Move }
            "Settings"              { Invoke-Settings $false }
            "Check for updates"     { Invoke-UpdateCheckManual }
        }

        if (-not $script:SkipPause) {
            Write-Host ""
            Write-Host $light -ForegroundColor DarkCyan
            Write-Host "   Press any key to return to the menu..." -ForegroundColor DarkGray
            [void][Console]::ReadKey($true)
        }
    }
} catch {
    try { [Console]::CursorVisible = $true } catch { }
    Clear-Host
    Write-Host ""
    Write-Host "   ERROR" -ForegroundColor Red
    Write-Host ("   " + $_.Exception.Message) -ForegroundColor Red
    Write-Host ""
    if ($_.InvocationInfo) {
        Write-Host ("   Line " + $_.InvocationInfo.ScriptLineNumber + ":  " + $_.InvocationInfo.Line.Trim()) -ForegroundColor DarkGray
        Write-Host ""
    }
    Write-Host "   Press any key to exit..." -ForegroundColor DarkGray
    [void][Console]::ReadKey($true)
}
