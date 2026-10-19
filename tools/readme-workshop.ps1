<#
.SYNOPSIS
    Converts README.md into README_workshop.txt, a Steam Workshop description (Steam BBCode).

.DESCRIPTION
    Converts the GitHub markdown of a readme into the BBCode the Steam Workshop description uses:
        headings, bold / italic / strikethrough, links, images, lists (also nested and numbered),
        code blocks, quotes and GitHub alerts (> [!IMPORTANT]), tables and horizontal rules.

    Relative links and images point to the GitHub repository (read from the "origin" remote, or -Repo).
    Lines of a paragraph are joined like GitHub renders them, pass -KeepLineBreaks to keep them.
    Images Steam can't show (SVG, like shields.io badges) are replaced by their alt text.

    Readme markers:
        <!-- workshop-skip --> ... <!-- /workshop-skip -->    left out of the workshop description
        <!-- workshop-only Text only on the workshop -->     only shown on the workshop

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\readme-workshop.ps1

.EXAMPLE
    pwsh tools/readme-workshop.ps1 -Path addons/csc/readme.md -OutFile csc_workshop.txt
#>
param (
    [string]$Path,
    [string]$OutFile,
    [string]$Repo,
    [string]$Branch = "main",
    [switch]$KeepLineBreaks
)

$ErrorActionPreference = "Stop"

$repoRoot  = Split-Path -Parent $PSScriptRoot
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$steamLimit = 8000

function Stop-WithError([string]$message) {
    Write-Host "ERROR: $message" -ForegroundColor Red
    exit 1
}

if (-not $Path) { $Path = Join-Path $repoRoot "README.md" }
if (-not (Test-Path $Path -PathType Leaf)) { Stop-WithError "Readme not found: $Path" }
$Path = (Resolve-Path $Path).Path
if (-not $OutFile) { $OutFile = Join-Path (Split-Path -Parent $Path) "README_workshop.txt" }

# --- Repository, for relative links ---
if (-not $Repo) {
    $remote = $null
    try { $remote = (git -C $repoRoot remote get-url origin 2>$null) } catch { }
    $match = [regex]::Match([string]$remote, 'github\.com[:/]([^/]+)/([^/]+?)(?:\.git)?/?$')
    if ($match.Success) { $Repo = "$($match.Groups[1].Value)/$($match.Groups[2].Value)" }
}

# Folder of the readme inside the repository, relative links start there
$readmeDir = ""
$parent = Split-Path -Parent $Path
if ($parent.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    $readmeDir = $parent.Substring($repoRoot.Length).Replace('\', '/').Trim('/')
}

$script:warnedNoRepo = $false

function Resolve-Url([string]$url, [bool]$image) {
    if ($url.StartsWith("#")) { return $null }                       # Steam has no anchors
    if ($url -match '^[a-zA-Z][a-zA-Z0-9+.\-]*:') { return $url }
    if ($url.StartsWith("//")) { return "https:$url" }
    if (-not $Repo) {
        if (-not $script:warnedNoRepo) {
            Write-Host "No GitHub remote found - relative links are left as text. Pass -Repo owner/repo to link them." -ForegroundColor Yellow
            $script:warnedNoRepo = $true
        }
        return $null
    }

    $suffix = ""
    $cut = $url.IndexOfAny([char[]]"?#")
    if ($cut -ge 0) { $suffix = $url.Substring($cut); $url = $url.Substring(0, $cut) }

    $full = if ($url.StartsWith("/")) { $url } else { "$readmeDir/$url" }
    $parts = New-Object System.Collections.Generic.List[string]
    foreach ($part in $full.Split("/")) {
        if ($part -eq "" -or $part -eq ".") { continue }
        if ($part -eq "..") { if ($parts.Count -gt 0) { $parts.RemoveAt($parts.Count - 1) }; continue }
        $parts.Add($part)
    }
    $relative = ($parts -join "/").Replace(" ", "%20")

    if ($image) { return "https://raw.githubusercontent.com/$Repo/$Branch/$relative" }
    return "https://github.com/$Repo/blob/$Branch/$relative$suffix"
}

# BBCode for an image, or $null when Steam can't show it
function Get-Image([string]$src) {
    $url = Resolve-Url $src $true
    if (-not $url) { return $null }
    if ($url -match '\.svg($|[?#])' -or $url -match '^https?://(img\.shields\.io|badgen\.net)/') { return $null }
    return "[img]$url[/img]"
}

function Convert-Inline([string]$text) {
    $stash = New-Object System.Collections.Generic.List[string]
    $open  = [string][char]1
    $close = [string][char]2
    # Finished parts are stashed behind a token, so later steps can't change them
    $save  = { param($value) $stash.Add($value); return "$open$($stash.Count - 1)$close" }

    $target = '\(\s*<?([^)\s>]+)>?(?:\s+"[^"]*")?\s*\)'

    $text = [regex]::Replace($text, '(`+)\s?(.+?)\s?\1', {
        param($m)
        $code = $m.Groups[2].Value
        if ($code -match '\[/?[A-Za-z*]') { $code = "[noparse]$code[/noparse]" }
        & $save $code
    })
    $text = [regex]::Replace($text, '\\([\\`*_{}\[\]()#+\-.!|<>~])', { param($m) & $save $m.Groups[1].Value })
    $text = [regex]::Replace($text, '<(https?://[^>\s]+)>', { param($m) & $save $m.Groups[1].Value })

    # Image inside a link, like a badge
    $text = [regex]::Replace($text, '\[!\[([^\]]*)\]' + $target + '\]' + $target, {
        param($m)
        $inner = Get-Image $m.Groups[2].Value
        if (-not $inner) { $inner = $m.Groups[1].Value }
        $href = Resolve-Url $m.Groups[3].Value $false
        if (-not $inner) { $inner = $href }
        if ($href) { & $save "[url=$href]$inner[/url]" } else { & $save $inner }
    })
    $text = [regex]::Replace($text, '!\[([^\]]*)\]' + $target, {
        param($m)
        $img = Get-Image $m.Groups[2].Value
        if ($img) { & $save $img } else { $m.Groups[1].Value }
    })
    $text = [regex]::Replace($text, '<img\b[^>]*>', {
        param($m)
        $src = [regex]::Match($m.Value, '\bsrc\s*=\s*["'']([^"'']+)["'']').Groups[1].Value
        $alt = [regex]::Match($m.Value, '\balt\s*=\s*["'']([^"'']*)["'']').Groups[1].Value
        $img = if ($src) { Get-Image $src } else { $null }
        if ($img) { & $save $img } else { $alt }
    })
    $text = [regex]::Replace($text, '\[([^\]]+)\]' + $target, {
        param($m)
        $href = Resolve-Url $m.Groups[2].Value $false
        if ($href) { "[url=" + (& $save $href) + "]" + $m.Groups[1].Value + "[/url]" } else { $m.Groups[1].Value }
    })
    $text = [regex]::Replace($text, '(?<![=\w])https?://[^\s\[\]<>"]+', { param($m) & $save $m.Value })

    # Remaining HTML
    $text = [regex]::Replace($text, '<br\s*/?>', "`n", "IgnoreCase")
    $text = [regex]::Replace($text, '</?[A-Za-z][^>]*>', "")

    $text = [regex]::Replace($text, '\*\*(?=\S)(.+?)(?<=\S)\*\*', '[b]$1[/b]')
    $text = [regex]::Replace($text, '(?<!\w)__(?=\S)(.+?)(?<=\S)__(?!\w)', '[b]$1[/b]')
    $text = [regex]::Replace($text, '(?<!\w)\*(?=\S)(.+?)(?<=\S)\*(?!\w)', '[i]$1[/i]')
    $text = [regex]::Replace($text, '(?<!\w)_(?=\S)(.+?)(?<=\S)_(?!\w)', '[i]$1[/i]')
    $text = [regex]::Replace($text, '~~(?=\S)(.+?)(?<=\S)~~', '[strike]$1[/strike]')

    $text = [System.Net.WebUtility]::HtmlDecode($text)

    # Stashed parts can contain tokens themselves
    $token = [regex]::Escape($open) + '(\d+)' + [regex]::Escape($close)
    while ($text -match $token) {
        $text = [regex]::Replace($text, $token, { param($m) $stash[[int]$m.Groups[1].Value] })
    }
    return $text
}

function Join-Paragraph($lines) {
    $result = ""
    for ($n = 0; $n -lt $lines.Count; $n++) {
        $line = $lines[$n]
        $hardBreak = $KeepLineBreaks -or $line -match '(\s{2,}|\\)$'
        $line = $line.Trim()
        if ($line.EndsWith("\") -and -not $line.EndsWith("\\")) { $line = $line.Substring(0, $line.Length - 1).TrimEnd() }
        $result += $line
        if ($n -lt $lines.Count - 1) { $result += $(if ($hardBreak) { "`n" } else { " " }) }
    }
    return Convert-Inline $result
}

function Split-TableRow([string]$row) {
    $row = $row.Trim()
    if ($row.StartsWith("|")) { $row = $row.Substring(1) }
    if ($row.EndsWith("|") -and -not $row.EndsWith("\|")) { $row = $row.Substring(0, $row.Length - 1) }
    return @($row -split '(?<!\\)\|' | ForEach-Object { Convert-Inline $_.Trim().Replace('\|', '|') })
}

function Join-Blocks($blocks) {
    $result = ""
    for ($n = 0; $n -lt $blocks.Count; $n++) {
        if ($n -gt 0) { $result += $(if ($blocks[$n - 1].Kind -eq "heading") { "`n" } else { "`n`n" }) }
        $result += $blocks[$n].Text
    }
    return $result
}

function Convert-Blocks([string[]]$lines) {
    $blocks   = New-Object System.Collections.Generic.List[object]
    $para     = New-Object System.Collections.Generic.List[string]
    $lists    = New-Object System.Collections.Generic.List[object]    # open lists, innermost last
    $listText = New-Object System.Text.StringBuilder
    $item     = $null                                                  # current list item, written when it ends

    # Run with "." so they share this scope
    $flushPara = {
        if ($para.Count -gt 0) {
            $paraText = Join-Paragraph $para
            if ($paraText.Trim()) { $blocks.Add(@{ Kind = "text"; Text = $paraText.Trim() }) }
            $para.Clear()
        }
    }
    $flushItem = {
        if ($null -ne $item) {
            [void]$listText.AppendLine("[*]" + (Convert-Inline $item))
            $item = $null
        }
    }
    $closeList = {
        . $flushItem
        [void]$listText.AppendLine("[/" + $lists[$lists.Count - 1].Tag + "]")
        $lists.RemoveAt($lists.Count - 1)
        if ($lists.Count -eq 0) {
            $blocks.Add(@{ Kind = "list"; Text = $listText.ToString().TrimEnd() })
            [void]$listText.Clear()
        }
    }
    $closeAll = {
        . $flushPara
        while ($lists.Count -gt 0) { . $closeList }
    }

    $i = 0
    while ($i -lt $lines.Count) {
        $line      = $lines[$i]
        $prevBlank = ($i -eq 0) -or -not $lines[$i - 1].Trim()

        if (-not $line.Trim()) {
            . $flushPara
            $i++; continue
        }

        # Fenced code block
        if ($line -match '^(\s*)(```|~~~)') {
            $fenceIndent = $Matches[1].Length
            $fence       = $Matches[2]
            . $closeAll
            $code = New-Object System.Collections.Generic.List[string]
            $i++
            while ($i -lt $lines.Count -and $lines[$i] -notmatch ('^\s*' + [regex]::Escape($fence))) {
                $codeLine = $lines[$i]
                $lead = $codeLine.Length - $codeLine.TrimStart().Length
                $code.Add($codeLine.Substring([Math]::Min($lead, $fenceIndent)))
                $i++
            }
            $i++
            $blocks.Add(@{ Kind = "code"; Text = "[code]`n" + ($code -join "`n") + "`n[/code]" })
            continue
        }

        # Heading - an empty one ("##") is used as a divider
        if ($line -match '^\s{0,3}(#{1,6})(?:\s+(.*?))?(?:\s+#+)?\s*$') {
            $level   = [Math]::Min($Matches[1].Length, 3)
            $heading = [string]$Matches[2]
            . $closeAll
            if ($heading.Trim()) {
                $blocks.Add(@{ Kind = "heading"; Text = "[h$level]" + (Convert-Inline $heading.Trim()) + "[/h$level]" })
            } else {
                $blocks.Add(@{ Kind = "rule"; Text = "[hr][/hr]" })
            }
            $i++; continue
        }

        # Underlined heading
        if ($para.Count -gt 0 -and $line -match '^\s{0,3}(=+|-+)\s*$') {
            $level = if ($Matches[1].StartsWith("=")) { 1 } else { 2 }
            $heading = Join-Paragraph $para
            $para.Clear()
            $blocks.Add(@{ Kind = "heading"; Text = "[h$level]$heading[/h$level]" })
            $i++; continue
        }

        if ($line -match '^\s{0,3}([-*_])(\s*\1){2,}\s*$') {
            . $closeAll
            $blocks.Add(@{ Kind = "rule"; Text = "[hr][/hr]" })
            $i++; continue
        }

        # Quote, GitHub alerts get their type as a title
        if ($line -match '^\s{0,3}>') {
            . $closeAll
            $quote = New-Object System.Collections.Generic.List[string]
            while ($i -lt $lines.Count -and $lines[$i] -match '^\s{0,3}>\s?(.*)$') { $quote.Add($Matches[1]); $i++ }
            $title = ""
            if ($quote[0] -match '^\s*\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*$') {
                $title = "[b]" + $Matches[1].Substring(0, 1) + $Matches[1].Substring(1).ToLower() + "[/b]`n"
                $quote.RemoveAt(0)
            }
            $inner = Join-Blocks (Convert-Blocks $quote.ToArray())
            $blocks.Add(@{ Kind = "quote"; Text = "[quote]`n$title$inner`n[/quote]" })
            continue
        }

        # Table
        if ($line.Contains("|") -and $i + 1 -lt $lines.Count -and $lines[$i + 1].Contains("|") -and
            $lines[$i + 1] -match '^\s*\|?\s*:?-+:?\s*(\|\s*:?-+:?\s*)*\|?\s*$') {
            . $closeAll
            $rows = New-Object System.Collections.Generic.List[string]
            $rows.Add("[tr]" + ((Split-TableRow $line | ForEach-Object { "[th]$_[/th]" }) -join "") + "[/tr]")
            $i += 2
            while ($i -lt $lines.Count -and $lines[$i].Trim() -and $lines[$i].Contains("|")) {
                $rows.Add("[tr]" + ((Split-TableRow $lines[$i] | ForEach-Object { "[td]$_[/td]" }) -join "") + "[/tr]")
                $i++
            }
            $blocks.Add(@{ Kind = "table"; Text = "[table]`n" + ($rows -join "`n") + "`n[/table]" })
            continue
        }

        # List item
        if ($line -match '^(\s*)([-*+]|\d{1,9}[.)])\s+(.*)$') {
            $indent   = $Matches[1].Replace("`t", "    ").Length
            $itemText = $Matches[3]
            $tag      = if ($Matches[2] -match '^\d') { "olist" } else { "list" }
            . $flushPara
            . $flushItem
            while ($lists.Count -gt 0 -and $lists[$lists.Count - 1].Indent -gt $indent) { . $closeList }
            if ($lists.Count -gt 0 -and $lists[$lists.Count - 1].Indent -eq $indent -and $lists[$lists.Count - 1].Tag -ne $tag) { . $closeList }
            if ($lists.Count -eq 0 -or $lists[$lists.Count - 1].Indent -lt $indent) {
                [void]$listText.AppendLine("[$tag]")
                $lists.Add([pscustomobject]@{ Indent = $indent; Tag = $tag })
            }
            $item = $itemText
            $i++; continue
        }

        # Continued list item - indented, or directly below it
        if ($lists.Count -gt 0) {
            $lead = ([regex]::Match($line, '^\s*').Value.Replace("`t", "    ")).Length
            if ($null -ne $item -and ($lead -ge 2 -or -not $prevBlank)) {
                $item += $(if ($prevBlank) { "`n" } else { " " }) + $line.Trim()
                $i++; continue
            }
            . $closeAll
        }

        $para.Add($line)
        $i++
    }
    . $closeAll
    return ,$blocks
}

# --- Read and prepare ---
$source = [System.IO.File]::ReadAllText($Path)
$source = $source.Replace("`r`n", "`n").Replace("`r", "`n")

# Markers and comments are handled outside of code blocks only
$kept  = New-Object System.Collections.Generic.List[string]
$chunk = New-Object System.Collections.Generic.List[string]
$skip  = $false
$fence = $null
$flushChunk = {
    $text = $chunk -join "`n"
    $text = [regex]::Replace($text, '(?s)<!--\s*workshop-only\s?(.*?)\s*-->', '$1')
    $text = [regex]::Replace($text, '(?s)<!--.*?-->', '')
    if ($chunk.Count -gt 0) { $kept.AddRange([string[]]$text.Split("`n")) }
    $chunk.Clear()
}
foreach ($line in $source.Split("`n")) {
    if ($fence) {
        if ($line -match ('^\s*' + [regex]::Escape($fence))) { $fence = $null }
        if (-not $skip) { $kept.Add($line) }
        continue
    }
    if ($line -match '^\s*(```|~~~)') {
        $fence = $Matches[1]
        . $flushChunk
        if (-not $skip) { $kept.Add($line) }
        continue
    }
    if ($line -match '<!--\s*workshop-skip\s*-->')  { $skip = $true;  continue }
    if ($line -match '<!--\s*/workshop-skip\s*-->') { $skip = $false; continue }
    if (-not $skip) { $chunk.Add($line) }
}
. $flushChunk
if ($skip) { Write-Host "<!-- workshop-skip --> without <!-- /workshop-skip --> - skipped to the end of the file" -ForegroundColor Yellow }

$source = $kept -join "`n"

# --- Convert and write ---
$result = Join-Blocks (Convert-Blocks $source.Split("`n"))
$result = [regex]::Replace($result, '\n{3,}', "`n`n").Trim()

[System.IO.File]::WriteAllText($OutFile, ($result.Replace("`n", "`r`n") + "`r`n"), $utf8NoBom)

Write-Host "Created $OutFile ($($result.Length) characters)" -ForegroundColor Green
if ($result.Length -gt $steamLimit) {
    Write-Host "Steam Workshop descriptions are limited to $steamLimit characters - shorten the readme or skip parts with <!-- workshop-skip -->" -ForegroundColor Yellow
}
