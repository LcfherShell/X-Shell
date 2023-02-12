$global:RedactPreviousLine = $True
function Write-HostCenter-Default {
    param($Message, $codecolor = 0)
    if ($codecolor -eq 0) {
        Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Message.Length / 2)))), $Message) 
    }
    else {
        Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Message.Length / 2)))), $Message) -foregroundColor $codecolor
    } 
}
function Write-HostCenter-Default3 {

    param($Messages, $Messages2)
    $maxMessages2 = ($Messages2 | Measure-Object -Maximum -Property Length).Maximum
    foreach ($Message in $Messages) {
        #$text += ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Message.Length / 2)))), $Message)
        Write-Host -NoNewLine (( ' ' * ($Host.UI.RawUI.BufferSize.Width - [math]::floor($Message.Length / 2)) ), $Message)
        foreach ($Message2 in $Messages2) {
            Write-Host (( ' ' * ($maxMessages2 - $Messages.Length) ), $Message2)
        }
    }
    Write-Host "`n"

}

function Write-HostCenter-MeError {
    param($Messages1, $Messages2)
    $maxMessages2 = ($Messages2 | Measure-Object -Maximum -Property Length).Maximum
    $paggilan = 0
    $nu = 0
    $nx = 0
    foreach ($Message in $Messages1) {
        #Write-Host -NoNewLine (( ' ' * ($width - [math]::floor($Message.Length / 2)) ), $Message)
        Write-Host -NoNewLine (( ' ' * ($width - [math]::floor($Message.Length / 2)) ), $Message)
        foreach ($Message2 in $Messages2) {
            if ($paggilan -eq 0) {
                Write-Host (( ' ' * (($maxMessages2 - $nu) - $Messages2[$nu].Count ) ), $Messages2[$nu])
                $paggilan += 1
            }
            else {
                $paggilan = 0
            } 
            $nx += 1 
        }
        $nu += 1
    }
}
function Write-HostCenter {
    Param (
        [string] $text = $(Write-Error "You must specify some text"),
        [switch] $NoNewLine = $false,
        [int] $tabs = 0
    )

    $startColor = $host.UI.RawUI.ForegroundColor;
    #$newText = $text -replace '{(.*)}', ''
    #for ($i = 0; $width - [math]::floor($newText.Count / 2) ; $i++) {
    #        $tabs += "`t";
    #}
    #Write-Host -NoNewline (( ' ' * ($width - [math]::floor($newText.Count / 2)) ), "")
    if ($tabs -ge 1) {
        [string]$countabs = ""
        for ($nux = 0; $nux -lt $tabs; $nux++) {
            $countabs += "`t";
        }
        Write-Host -NoNewLine $countabs;
    }
    $text.Split( [char]"{", [char]"}" ) | ForEach-Object { $i = 0; } {
        if ($i % 2 -eq 0) {
            Write-Host $_ -NoNewline;
        }
        else {
            if ($_ -in [enum]::GetNames("ConsoleColor")) {
                $host.UI.RawUI.ForegroundColor = ($_ -as [System.ConsoleColor]);
            }
        }

        $i++;
    }

    if (!$NoNewLine) {
        Write-Host;
    }
    $host.UI.RawUI.ForegroundColor = $startColor;
}

$curUser = (Get-ChildItem Env:\USERNAME).Value
$curComp = (Get-ChildItem Env:\COMPUTERNAME).Value

clear -or cls
