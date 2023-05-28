<#
HOW TO RUN THE SCRIPT:
1. from cmd:            powershell.exe -file D:\first.ps1 D:\1_Ana\1_Poze\Categorii\2022_Nunta_Cristi\Poze_Telefon\ <base_text> <new_base_text> <start_number> <end_number> <added_number> <starting_number>
2. from PowerShell app: .\renumerotate-photos-in-a-directory.ps1 Cristi"&"Doris_ Cristi"&"Doris_ 44 417 3 
   (first navigate to
    the directory where
    the script is located)
#>


$path = "D:\1_Ana\1_Poze\Categorii\2022_Mallorca\rename\"

$base_text = $args[0]
$new_base_text = $args[1]
$start = $args[2]
$end = $args[3]
$add_value = $args[4]
$starting_number = $args[5]
Write-Output "Current base text: " $base_text
Write-Output "New base text: " $new_base_text
Write-Output "Start renumerating from picture with the following number in its name: " $start
Write-Output "End renumerating at picture with the following number in its name: " $end
Write-Output "Add number: " $add_value
Write-Output "We start to numerotate from this number: " $starting_number

# Different regex I had to use depending on the initial name of the images files
# \D+\d+-(\d+).+ - matches 'FMI_31072022-407' this pattern (encountered in 2022_Absolvire_Master\Poze_Fotografi\Aparat_Alex_Vlase\)
#                  wraps in a group only the digits that come after '-' (in this example, 407)
# 1E0A(\d+).+    - matching '1E0A00356.jpg' (encountered in 2022_Absolvire_Master\Poze_Fotografi\Aparat_Siluk)
# \d+_(\d+).+    - matching '20221003_114525.jpg', wraps in a group only the digits that come after '_' (in this example, 114525)
# \D+(\d+).+     - matching any name that starts with any non-digits characters and ends with one or more digit characters, wraps
#                  in a group only the ending digit characters (one example of string, 'mallorca-112.jpg', the group is 112)
$numerical = {
    if ($_.name -match '\d+_(\d+).+') {
        [int]($_.name -replace '\d+_(\d+).+', '$1')
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

# get the names of the images without the extension ordered numerically in descending order.
# $fisiere = Get-ChildItem -Path $path | Where-Object $check | Sort-Object $numerical # -Descending
$fisiere = Get-ChildItem -Path $path | Sort-Object $numerical
Write-Output $fisiere


# $new_number = 1
$new_number = $starting_number
for($i = 0; $i -lt $fisiere.Length; $i++){
    $img_path = $path + $fisiere[$i]
    Write-Output $fisiere[$i].name

    $extension = [System.IO.Path]::GetExtension("$img_path")
    Write-Output $extension

    $img_name_without_extension = [io.path]::GetFileNameWithoutExtension("$img_path")
    # Write-Output $img_name_without_extension

    # $new_number = [int]($fisiere[$i].name -Replace '\D+(\d+).+', '$1') + $add_value
    Write-Output "NEW NUMBER: " $new_number

    if($extension -eq ".jpg"){
        Rename-Item -Path $img_path -NewName "$new_base_text$new_number.jpg"
    }
    elseif ($extension -eq ".mp4"){
        Rename-Item -Path $img_path -NewName "$new_base_text$new_number.mp4"
    }
    elseif ($extension -eq ".jpeg"){
        Rename-Item -Path $img_path -NewName "$new_base_text$new_number.jpeg"
    }
    elseif ($extension -eq ".MOV"){
        Rename-Item -Path $img_path -NewName "$new_base_text$new_number.mov"
    }
    elseif ($extension -eq ".PNG"){
        Rename-Item -Path $img_path -NewName "$new_base_text$new_number.png"
    }
    #elseif ($extension -eq ".gif"){
    #    Rename-Item -Path $img_path -NewName "$base_text $i.gif"
    #}

    $new_number = $new_number + 1
}
