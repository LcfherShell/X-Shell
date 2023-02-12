$foregroundColor = 'white'
$Global:psVersion = $host.Version.Major
$Global:jsons = @"
{
    "code_color": []
}
"@
$Global:codeList = New-Object 'Collections.ArrayList'

function CheckKeys($codecolor, $color_List) {
    foreach ($group in $color_List) {
        $groupName = $($group | Get-Member -MemberType *Property).Name
        if ($codecolor -eq $groupName) {
            break
            return 1
        }
    }
    else {
        return 0
    }
    return 0
}

class SystemWInfox {

    [System.Object]$Os1_x
    [System.Object]$Os2_x
    [System.Object]$CoresX
    [System.Object]$DiskInfoe
    [System.Object]$Memoinfos
    [System.Object]$CoreIc
    [System.Object]$ScreenSize
    
    SystemWInfox([string]$tx){

        $this.Os1_x = ((get-ciminstance -ClassName "Win32_BaseBoard") | Select-Object Manufacturer, Product, SerialNumber, version | ConvertTo-Json)
        $this.Os2_x = ((get-ciminstance -ClassName "CIM_OperatingSystem") | Select-Object Caption, OSArchitecture, SerialNumber, MUILanguages, SystemDrive, RegisteredUser | ConvertTo-Json) 
        $this.ScreenSize = (Get-WmiObject -Class "Win32_VideoController").VideoModeDescription

        $this.CoresX = (get-ciminstance -class "Win32_processor" | Select-Object Caption, Name, SocketDesignation | ConvertTo-Json)
        $this.DiskInfoe = ([System.IO.DriveInfo]::getdrives() | ConvertTo-Json)
        $this.Memoinfos = (get-ciminstance -class "cim_physicalmemory" | Select-Object Manufacturer, PartNumber, SerialNumber, Capacity | ConvertTo-Json)
        $this.CoreIc = (get-ciminstance -class "Win32_BaseBoard" | Select-Object Manufacturer, Product, SerialNumber, version | ConvertTo-Json)
        
    }

}

class CustomUIX {
    [string]$session
    [System.Object]$output
    [string]$color_query
    
    CustomUIX([string]$session) {

        if ($session -is [string]) {
            $this.session = "<Empity>"
        }
        else {
            $_.Exception.Message("Not type Interger")
        }
        $this.output = [SystemWInfox]::new("see")

    }
    [System.Object]syetemminfo([string]$select, [int]$num=0){
        switch ($select.ToLower()) {
            
            "user" { 
                    $this.session = (Get-ChildItem Env:\USERNAME).Value
            }"hostname"{
                    $this.session = (Get-ChildItem Env:\COMPUTERNAME).Value
            }"time"{
                    $xtime = Get-Date
                    $CurrentTimeZone = [System.TimeZoneInfo]::Local.StandardName
                    $this.session = "$($xtime.ToUniversalTime().toString("r")) $($CurrentTimeZone)"
            }"os"{
                    $x = $this.output.Os1_x | ConvertFrom-Json
                    $xx= $this.output.Os2_x | ConvertFrom-Json
                    if ($num -eq 0 -or $num -eq 1) {

                        [System.Object]$y = $xx.Caption.toString()
                        [System.Object]$y2 = $xx.OSArchitecture.toString()
                        $this.session = "$($y.replace('Microsoft', '').Trim()) $($x.Manufacturer) $($y2.Trim())"

                    }else{
                        $this.session = "$($x.Manufacturer) [ $($xx.MUILanguages -join ', ') ] "
                    }
            }"screen"{
                    $this.session = $this.output.ScreenSize.toString()
            }"cpu"{
                    if($num -eq 0 -or $num -eq 1){
                        $xx = $this.output.CoresX | ConvertFrom-Json
                        try {
                            $words = $xx.Caption.Split(" ")
                            $result = $words[ $words.IndexOf("Family") +1]
                        }catch {
                            $searchWord = "Family"
                            if ($xx.Caption -match "($searchWord\s+\w+)") {
                                $result = $matches[0].replace($searchWord, "")
                            }else{
                                $words = $xx.Caption.Split(" ")
                                $result = $words[ $words.IndexOf("Family") +1]
                            }
                        }
                        $this.session = "$($xx.Name) Generation: $($result.Trim())"
                    }elseif ($num -eq 2){
                        $this.session = "<commingsoon>"
                    }else{
                        $this.session = "<Empity>"
                    }
            }"disk"{
                    $disksize = @()
                    $diskname = @()
                    $this.output.DiskInfoe | ConvertFrom-Json | foreach-object {
                        if($_.TotalSize){
                            $diskname += $_.Name
                            $disksize += $_.TotalSize
                        }
                    }
                    for ($i = 0; $i -lt $disksize.Length; $i++) {
                            $disksize[$i] = [math]::Round([decimal]$disksize[$i]/1073741824)
                    }

                    if ($num -eq 0 -or $num -eq 1) {
                            $this.session = "[ $($diskname -join ', ') ] "
                    }else{
                        $this.session = "[ $($disksize -join 'GB, ')GB ]"
                    }
            }"ram"{
                    $xx = $this.output.Memoinfos | ConvertFrom-Json
                    if ($num -eq 1) {
                        $this.session = "$($xx.Manufacturer) $($xx.PartNumber.Trim()) $($xx.SerialNumber.Trim())"
                    }elseif($num -eq 2){
                        $this.session = "$([math]::Round([decimal]$xx.Capacity/1048576))"
                    }else{
                        $this.session = "<Empity>"
                    }
            }"powershell"{
                $this.session = $Global:psVersion
            }
            Default {
                $this.session = "<Empity>"
            }
        }
        return  $this.session
    }
    [System.Object]color() {
        $codecolor = [enum]::GetValues([System.ConsoleColor])
        $obj = $Global:jsons | ConvertFrom-Json
        #$obj.code_color.Length = $codecolor.Length
        $jsonmas = @"
[
]
"@

        $jobj = ConvertFrom-Json -InputObject $jsonmas

        #$scc = 0
        foreach ($collection in $codecolor) {
            #$obj.code_color += [pscustomobject] @{$collection = $collection;}
            $key = $collection.toString()
            $key = $key.ToLower()
            $Global:codeList.Add($key)
            $toAdd = @"
{
    "$key" : '$key'
}
"@
            
            $jobj += (ConvertFrom-Json -InputObject $toAdd)
            #Write-Host $toAdd
            #$scc += 1
        }
        $obj.code_color = $jobj | ConvertTo-Json
        return $obj  #ConvertTo-Json -Depth 3
    }

    [void]banner($codecolor = 1, [string]$filename) {
        if ($filename -is [int]) {
            $_.Exception.Message("Not type String")
        }
        $color = $this.color()
        $color_List = $color.code_color | ConvertFrom-Json
        if ($codecolor -is [int] ) {
            #check if 12 > 2 or 2<3
            if ([int]$codecolor -le 0) {
                $_.Exception.Message("Not type Positive Interger")
            }
            if ($codecolor -le $Global:codeList.Count) {
                #$codecolor -eq $Global:codeList.Length -or 
                $this.color_query = $Global:codeList[$codecolor]
            }
            else {
                $_.Exception.Message("Not type String")
            }

        }
        elseif ($codecolor -is [string]) {
            <# Action when this condition is true #>
            if (CheckKeys($codecolor, $color_List) -eq 1) {
                $this.color_query = $codecolor
            }
        }
        else {
            $_.Exception
        }

        [System.IO.File]::ReadLines($filename.ToString()) | ForEach-Object {
            try{
                $x = [regex]::match($_, "#'(.*)'").Groups[1].Value
                if ($x) {
                    $y = [regex]::match($x, "([^a-zA-Z-])").Groups[1].Value
                    if ($y) {
                        $selected = $x.replace($y, '')
                        $numx = [int]$y
                    }else{
                        $selected = $x
                        $numx = 0
                        
                    }
                    $_ = $_.replace("[#'$($x)']", "$($this.syetemminfo($selected, $numx))")
                    #[System.Object]$output = $this.syetemminfo($selected, $numx)
                } 
                
                #$_.replace($x, $output)
                
            }catch{
                $_=$_
            }
            Write-HostCenter -text $_ -tabs 1 #$this.color_query
        
        }

    }
}
#$color = $classes.color().code_color | ConvertFrom-Json

function Banner{
    param($Message = 1)
    $classes = [CustomUIX]::new("mob")
    $systemdrive = ((get-ciminstance -ClassName "CIM_OperatingSystem") | Select-Object SystemDrive) | ConvertTo-Json
    $chostDrive = $systemdrive | ConvertFrom-Json
    Write-Host
    if($Message -is [int]){
        if ($Message -eq 1) {
            $classes.banner(6, "$($chostDrive.SystemDrive)\Users\$($curUser)\Documents\WindowsPowerShell\spann.txt")
        }
    }elseif ($Message -is [string]){
         if ( $Message.ToLower() -eq "true" ) {
            $classes.banner(6, "$($chostDrive.SystemDrive)\Users\$($curUser)\Documents\WindowsPowerShell\spann.txt")
         }
    }
    Write-Host
}
Banner

function Prompt {
    if ( Test-Path Variable:Global:RedactPreviousLine ) { 
        $cursor = New-Object System.Management.Automation.Host.Coordinates
        $cursor.X = $host.ui.rawui.CursorPosition.X
        $cursor.Y = $host.ui.rawui.CursorPosition.Y - 1
        $host.ui.rawui.CursorPosition = $cursor
        Write-host $( " " * ( $host.ui.RawUI.WindowSize.Width - 1 ) )
        $host.ui.rawui.CursorPosition = $cursor

        Remove-Variable RedactPreviousLine -scope global
    }
    Write-Host "[" -NoNewline
    Write-Host "$($curUser.ToUpper())" -NoNewline -ForegroundColor Yellow
    Write-Host "]" -NoNewline -ForegroundColor White
    return " $($(Get-Location).Path)> "
}
