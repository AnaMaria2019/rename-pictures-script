<#
HOW TO RUN THE SCRIPT:
1. from cmd:            powershell.exe -file D:\first.ps1 D:\1_Ana\1_Poze\Categorii\2022_Nunta_Cristi\Poze_Telefon\ <base_text> <new_base_text> <start_number> <end_number> <added_number>
2. from PowerShell app: .\renumerotate-photos-in-a-directory.ps1 Cristi"&"Doris_ Cristi"&"Doris_ 44 417 3 
   (first navigate to
    the directory where
    the script is located)
#>


$path = "D:\1_Ana\1_Poze\Categorii\2022_Fundata\Transfagarasan\"

$base_text = $args[0]
$new_base_text = $args[1]
$start = $args[2]
$end = $args[3]
$add_value = $args[4]
Write-Output "Current base text: " $base_text
Write-Output "New base text: " $new_base_text
Write-Output "Start renumerating from picture with the following number in its name: " $start
Write-Output "End renumerating at picture with the following number in its name: " $end
Write-Output "Add number: " $add_value

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

# get the names of the images without the extension ordered numerically in descending order.
$fisiere = Get-ChildItem -Path $path | Where-Object $check | Sort-Object $numerical -Descending
Write-Output $fisiere


for($i = 0; $i -lt $fisiere.Length; $i++){
    $img_path = $path + $fisiere[$i]
    Write-Output $fisiere[$i].name

    $extension = [System.IO.Path]::GetExtension("$img_path")
    Write-Output $extension

    $img_name_without_extension = [io.path]::GetFileNameWithoutExtension("$img_path")
    # Write-Output $img_name_without_extension

    $new_number = [int]($fisiere[$i].name -Replace '\D+(\d+).+', '$1') + $add_value
    Write-Output "NEW NUMBER: " $new_number

    if($extension -eq ".jpg"){
        Rename-Item -Path $img_path -NewName "$new_base_text$new_number.jpg"
    }
    elseif ($extension -eq ".mp4"){
        Rename-Item -Path $img_path -NewName "$new_base_text$new_number.mp4"
    }
    #elseif ($extension -eq ".gif"){
    #    Rename-Item -Path $img_path -NewName "$base_text $i.gif"
    #}
}
