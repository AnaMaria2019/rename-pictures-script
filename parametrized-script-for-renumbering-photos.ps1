<#
HOW TO RUN THE SCRIPT (from PowerShell app):
- first navigate to the directory where the script is located
- run the following command:
    .\parametrized-script-for-renumbering-photos.ps1 -path D:\1_Ana\1_Poze\rename-pictures-script\test-images\ -basename 'Noiembrie_' -newbasename 'noiembrie-' -photosNameRegex '\D(\d+).+'
#>

# Different regex I had to use depending on the initial name of the images files
# \D+\d+-(\d+).+ - matches 'FMI_31072022-407' this pattern (encountered in 2022_Absolvire_Master\Poze_Fotografi\Aparat_Alex_Vlase\)
#                  wraps in a group only the digits that come after '-' (in this example, 407)
# 1E0A(\d+).+    - matching '1E0A00356.jpg' (encountered in 2022_Absolvire_Master\Poze_Fotografi\Aparat_Siluk)
# \d+_(\d+).+    - matching '20221003_114525.jpg', wraps in a group only the digits that come after '_' (in this example, 114525)
# \D+(\d+).+     - matching any name that starts with any non-digits characters and ends with one or more digit characters, wraps
#                  in a group only the ending digit characters (one example of string, 'mallorca-112.jpg', the group is 112)

param (
    [Parameter(Mandatory)][string]$path,
    $basename,
    [Parameter(Mandatory)][string]$newbasename,
    [Parameter(Mandatory)][string]$photosNameRegex,
    [int]$start,
    [int]$end,
    [int]$addValue,
    [int]$startingNr
)
write-host "Path for the directory that contains the photos you want to rename: $path"
write-host "Photo name matching regex: $photosNameRegex"

if ($null -ne $basename) {
    write-host "Photos current base name: $basename"
}
write-host "Photos new base name: $newbasename"

if (0 -eq $end -and 0 -ne $start) {
    $end = read-host -Prompt "Please enter an end number (from the photo's name) where the renumerating process will stop: "
    write-host "Start renumerating from photo with the following number in its name: $start"
    write-host "End renumerating at photo with the following number in its name: $end"
} elseif (0 -eq $start -and 0 -ne $end) {
    $start = read-host -Prompt "Please enter a start number (from the photo's name) where the renumerating process will start: "
    write-host "Start renumerating from photo with the following number in its name: $start"
    write-host "End renumerating at photo with the following number in its name: $end"
}

if (0 -ne $start -and 0 -ne $end -and 0 -eq $addValue) {
    $addValue = read-host -Prompt "Enter the number (it can be either positive, or negative) to be added to the initial number from the photo's name: "
    write-host "Add number: $addValue"
}

if (0 -ne $startingNr) {
    write-host "We start to numerotate from this number:  $startingNr"
}

$numerical = {
    if ($_.name -match '\D+(\d+).+') {
        [int]($_.name -replace '\D+(\d+).+', '$1')
    } else {
        $_.name
    }
}

$check = {
    if($_.name -match '\D+(\d+).+') {
        $nr = [int]($_.name -replace '\D+(\d+).+', '$1')
        return $nr -ge $start -and $nr -le $end
    }
}

# NOTE: get the names of the images without the extension ordered numerically
#       in descending/ascending order (depending on the $addValue number's sign)
if (0 -ne $start -and 0 -ne $end){
    if ($addValue -lt 0){
        $fisiere = Get-ChildItem -Path $path | Where-Object $check | Sort-Object $numerical
    } else {
        $fisiere = Get-ChildItem -Path $path | Where-Object $check | Sort-Object $numerical -Descending
    }
} else {
    $fisiere = Get-ChildItem -Path $path | Sort-Object $numerical
}
write-host $fisiere

if (0 -eq $fisiere.count) {
    exit
} 


if ($startingNr -ne 0) {
    $newPhotoNameNr = $startingNr
} elseif (0 -ne $addValue) {
    $newPhotoNameNr = [int]($fisiere[0].name -Replace '\D+(\d+).+', '$1') + $addValue
} 
else {
    $newPhotoNameNr = 1
}

for($i = 0; $i -lt $fisiere.Length; $i++){
    $img_path = $path + $fisiere[$i]
    $extension = [System.IO.Path]::GetExtension("$img_path")
    write-host "$($fisiere[$i].name) has extension $extension"

    # $img_name_without_extension = [io.path]::GetFileNameWithoutExtension("$img_path")

    if($extension -eq ".jpg"){
        Rename-Item -Path $img_path -NewName "$newbasename$newPhotoNameNr.jpg"
    }
    elseif ($extension -eq ".mp4"){
        Rename-Item -Path $img_path -NewName "$newbasename$newPhotoNameNr.mp4"
    }
    elseif ($extension -eq ".jpeg"){
        Rename-Item -Path $img_path -NewName "$newbasename$newPhotoNameNr.jpeg"
    }
    elseif ($extension -eq ".MOV"){
        Rename-Item -Path $img_path -NewName "$newbasename$newPhotoNameNr.mov"
    }
    elseif ($extension -eq ".PNG" -or $extension -eq ".png"){
        Rename-Item -Path $img_path -NewName "$newbasename$newPhotoNameNr.png"
    }

    if (0 -ne $addValue) {
        if ($addValue -gt 0) {
            $newPhotoNameNr = $newPhotoNameNr - 1    
        } else {
            $newPhotoNameNr = $newPhotoNameNr + 1
        } 
    } else {
        $newPhotoNameNr = $newPhotoNameNr + 1
    }
    write-host "New number for the photo's name: " $newPhotoNameNr
}
