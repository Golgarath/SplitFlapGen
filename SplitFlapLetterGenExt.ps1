function Get-ScriptDirectory {
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
    Split-Path $Invocation.MyCommand.Path;
}
function createSTL ([string]$OpenScad, [PSCustomObject]$Headers, [PSCustomObject]$row, [string]$Model, [string]$File, [string]$ScriptPath, [string]$STLPath) {
    Function Is-Numeric ($Value) {
        return $Value -match "^[\d\.]+$"
    }; 
    
    $sFileName = $row.Filename;
    $sOutFile = "$sFileName-$Model.stl";
    $sOut = "-o `"$STLPath\$sOutFile`"";

    # Argumentliste aufbauen... 

    $sArguments = [System.Collections.Generic.List[string]]::new()

    $sArguments.Add($sOut);

    foreach ($head in $Headers)
    {
        # Dateiname und leere Werte nicht in die Parameter Liste übernehmen.
        if($head -ne "Filename" -and $row.$head -ne "") 
        {
            $value = $row.$head;
            
            if( Is-Numeric($value) -eq $true) {
                $sArguments.Add("-D ""$head=`"$value`"`"");
             } else {
                $sArguments.Add("-D `"$head=`"`"`"$value`"`"`"`"");
             } 
        }
    }

    $sArguments.Add("-D ""model=`"`"`"$Model`"`"`"`"");
    $sArguments.Add("`"$ScriptPath\$File`"");    

    # Dateien erzeugen
    if (Test-Path "$STLPath\$sOutFile") { 
        Write-Host "INFO: Überspringe >>$STLPath\$sOutFile<< STL Datei existiert bereits."
    }
    else {     
        Write-Host "INFO: Erzeuge >>$STLPath\$sOutFile<<";
        #Write-Host "Start-Process -FilePath $OpenScad -ArgumentList $sArguments -NoNewWindow -Wait;" 
        Start-Process -FilePath $OpenScad -ArgumentList $sArguments -NoNewWindow -Wait;
        #Start-Sleep -Seconds 15; 
        Write-Host "INFO: Fertig >>$STLPath\$sOutFile<<";
    }

}


# Aktuellen Pfad ermitteln
$sScriptPath = Get-ScriptDirectory;

$sOpenScad = "E:\Program Files\OpenSCAD\openscad.com";
$sList = "SplitFlapLetterGenExt.csv";
$sFile = "SplitFlapLetterGen.scad";
$sSTLPath = "$sScriptPath\STL";

$maxThreads = 22;   ## Passend zum verwendeten Prozessor anpassen!!!

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

# CSV Datei Header ermitteln
$Header = (Get-Content $sList | Select-Object -First 1).Split(';')

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
    createSTL $($using:sOpenScad) $($using:Header) $_ "letter" $($using:sFile) $($using:sScriptPath) $($using:sSTLPath);
    createSTL $($using:sOpenScad) $($using:Header) $_ "card" $($using:sFile) $($using:sScriptPath) $($using:sSTLPath);
} -ThrottleLimit $maxThreads 

Write-Host "`n`nAusführung beendet.";
Read-Host "Press ENTER to exit...";