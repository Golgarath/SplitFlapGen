function Get-ScriptDirectory {
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
    Split-Path $Invocation.MyCommand.Path;
}
function createSTL ([string]$OpenScad, [string]$Letter1, [string]$Letter2, [string]$Filename, [string]$Model, [string]$File, [string]$ScriptPath, [string]$STLPath) {

    $sOutFile = "SplitFlap-$Filename-$Model.stl";
    $sOut = "-o `"$STLPath\$sOutFile`"";
    $sScadArguments1a = "-D ""letter1=""""`"$Letter1`"""""""";
    $sScadArguments1b = "-D ""letter2=""""`"$Letter2`"""""""";
    $sScadArguments1c = "-D ""model=""""`"$Model`"""""""";
    $sScadArguments2 = """$ScriptPath\$File""";    

    if (Test-Path "$STLPath\$sOutFile") { 
        Write-Host "INFO: Überspringe >>$STLPath\$sOutFile<< STL Datei existiert bereits."
    }
    else {     
        Write-Host "INFO: Erzeuge >>$STLPath\$sOutFile<<";
        #Write-Host "Start-Process -FilePath $OpenScad -ArgumentList $sOut, $sScadArguments1a, $sScadArguments1b, $sScadArguments1c, $sScadArguments2 -NoNewWindow -Wait;" 
        Start-Process -FilePath $OpenScad -ArgumentList $sOut, $sScadArguments1a, $sScadArguments1b,$sScadArguments1c, $sScadArguments2 -NoNewWindow -Wait;
        #Start-Sleep -Seconds 15; 
        Write-Host "INFO: Fertig >>$STLPath\$sOutFile<<";
    }

}

# Aktuellen Pfad ermitteln
$sScriptPath = Get-ScriptDirectory;

$sOpenScad = "E:\Program Files\OpenSCAD\openscad.com";
$sList = "SplitFlapLetterGen.csv";
$sFile = "SplitFlapLetterGen.scad";
$sSTLPath = "$sScriptPath\STL";

$maxThreads = 20;

# Prüfen ob .scad vorhanden
if (-Not(Test-Path "$sScriptPath\$sFile")) { 
    Write-Host "ERROR: OpenScad Datei >>$sScriptPath\$sFile<< existiert nicht. Ausführung abgebrochhen"
    Exit  
}
# Prüfen ob .csv vorhanden
if (-Not(Test-Path "$sScriptPath\$sList")) { 
    Write-Host "ERROR: CSV Datei >>$sScriptPath\$sList<< existiert nicht. Ausführung abgebrochhen"
    Exit;  
}
    
# Prüfen ob Ordner "STL" existiert
if (-Not(Test-Path "$sSTLPath")) { 
    # -- Ordner anlegen
    Write-Host "INFO: Das Verzeichnis >>$sSTLPath<< existiert nicht. Wird erstellt..."
    New-Item -Path "$sSTLPath" -ItemType Directory;
}

# CSV Datei durcharbeiten....
Write-Host "INFO: Importdatei >>$sScriptPath\$sList<< wird eingelesen..."
$things = Import-Csv -Delimiter ";" "$sScriptPath\$sList";

# Get the function's definition *as a string*
$funcDef = $function:createSTL.ToString()

#foreach  ($i in $filaments) {
$things | ForEach-Object -Parallel {
    #   New-Item -type directory $i.foldername
    # -- Falls datei nicht existiert
    # -- -- Erzeuge Datei      
    #  Define the function inside this thread...
    $function:createSTL = $using:funcDef
    #  ... and call it.
    createSTL $($using:sOpenScad) $_.Letter1 $_.Letter2 $_.Filename "letter" $($using:sFile) $($using:sScriptPath) $($using:sSTLPath);
    createSTL $($using:sOpenScad) $_.Letter1 $_.Letter2 $_.Filename "card" $($using:sFile) $($using:sScriptPath) $($using:sSTLPath);
} -ThrottleLimit $maxThreads 

Write-Host "Ausführung beendet.";
Read-Host "Press ENTER to exit...";