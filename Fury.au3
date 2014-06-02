; Fury
$version = "0.1.3"
$created = "5/21/2014"
$modified = "6/2/2014"
; Author: Lucas Messenger
; Credits: Kenton Tofte, Luke Moore
; ------------------------------
; Fury icon: http://www.iconspedia.com/icon/fire-icon-35660.html
; CC Attribution license for icon: https://creativecommons.org/licenses/by/3.0/
; ------------------------------
; Extracting archives done by unzip.exe
;
; ------------------------------
; Error/Exit Codes
; 0 - Complete
; 1 - Error reading folders.txt
; 2 - Cannot find comma delimination
; 3 - Error importing to individual arrays


#include <GuiConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <file.au3>
#include <Array.au3>
#include <ListBoxConstants.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <GUIButton.au3>
#include <GUIListbox.au3>
#include <GuiEdit.au3>

Dim $height
Dim $width

; Locations
Global $File
Global $txtName = "folders.txt"
Global $serverPath = "https://helpdesk.liberty.edu/hdtools/Tech%20Projects%20&%20Source%20Code%20Files/Fury"
Global $alektoPath = "https://helpdesk.liberty.edu/hdtools/Alekto"
Global $ExportLoc = @DesktopDir & '\Fury'
Global $tempDir = @TempDir & "\"

; Arrays
Dim $aOrig
Dim $aClean[0]
Dim $aFresh[0]
Dim $aDiagnostics[0]
Dim $aRecovery[0]
Dim $aMerge[0]
Dim $aExport[0]

; Buttons
Dim $bRun, $bClear, $bExit

; Menu items
Dim $mFile, $mHelp, $iExit, $iNetwork, $iAbout, $iLicense

; Misc items
Dim $pBar, $oList

; Checkboxes
Dim $cClean, $cFresh, $cDiagnostics, $cRecovery, $cOpen, $cScreensaver, $cPostprep, $cPRCS, $cLaunch, $cExit

; Boolean
Dim $useServer = False

; Check if executing from Desktop or USB
If @ScriptDir = $ExportLoc Then
   CreateDesktopGUI()
Else
   CreateUSBGUI()
EndIf

; Import data from folders.txt
Func dataImport()

   ; Clear list output
   GUICtrlDelete($oList)
   $oList = GUICtrlCreateList("", 5, 130, 460, 140, BitOr($WS_VSCROLL, $WS_BORDER))

   ; Check if can reach server, and download file from there, else use local copy
   If $useServer = True Then
	  If Ping("10.254.10.29",1000) >=1 Then
		 GUICtrlSetData($oList, "Server found. Downloading folders.txt from server...")
		 $txtGet = InetGet($serverPath & '/admin/folders.txt', $TempDir & $txtName, 2)
		 InetClose($txtGet)
		 $File = $TempDir & $txtName
		 GUICtrlSetData($oList, "Downloaded folders.txt from server")
	  Else
		 GUICtrlSetData($oList, "Cannot locate server. Using local copy of folders.txt.")
		 $File = @ScriptDir & '\admin\folders.txt'
	  EndIf
   Else
		$File = @ScriptDir & '\admin\folders.txt'
   EndIf

	 If NOT FileExists($File) Then
			MsgBox($MB_SYSTEMMODAL, "Import error", "There was an error reading the file. Does the file exist?" & @CRLF & @CRLF & "Error code: 1")
		 EndIf

	  If Not _fileReadToArray($File, $aOrig) Then
		 MsgBox($MB_SYSTEMMODAL, "Import error", "There was an error reading the file. Does the file exist?" & $File & @CRLF & @CRLF & "Error code: 1")
	  Else
		 _ArraySearch($aOrig, ",", 0, 0, 0, 1)
		 If @error Then
			MsgBox($MB_SYSTEMMODAL, "Import error", "There was an error reading the file. folders.txt is not comma delimited, or is missing commas." & @CRLF & @CRLF & "Error code: 2")
		 Else
			For $x = 1 to ($aOrig[0])
			   $curLine = $aOrig[$x]
			   $strClean = StringInStr($curLine, "Clean")
			   $strFresh = StringInStr($curLine, "Fresh Install")
			   $strDiagnostics = StringInStr($curLine, "Diagnostics")
			   $strRecovery = StringInStr($curLine, "Recovery")
			   $strSplit = StringSplit($curLine, ",")
			   Select
				  Case $strClean = 1
						_ArrayAdd($aClean, $strSplit[2])
				  Case $strFresh = 1
					 _ArrayAdd($aFresh, $strSplit[2])
				  Case $strDiagnostics = 1
					 _ArrayAdd($aDiagnostics, $strSplit[2])
				  Case $strRecovery = 1
					 _ArrayAdd($aRecovery, $strSplit[2])
				  Case Else
					 MsgBox($MB_SYSTEMMODAL, "Import error", "There was an error reading the file." & @CRLF & @CRLF & "Error code: 3")
			   EndSelect
			Next
		 EndIf
	  EndIf

	  FileDelete($ExportLoc & '\' & $txtName)
EndFunc

; Create USB GUI
Func CreateUSBGUI()

; Dimensions
$height = 475
$width = 310

; GUI Create
GUICreate("Fury", $height, $width)
GUISetIcon("Fury.exe", 0)

; Menu and menu items
$mFile = GUICtrlCreateMenu("&File")
$iExit = GUICtrlCreateMenuItem("&Exit", $mFile)
$mHelp = GUICtrlCreateMenu("&Help")
$iNetwork = GUICtrlCreateMenuItem("&Use server", $mHelp)
GUICtrlCreateMenuItem("", $mHelp)
$iAbout = GUICtrlCreateMenuItem("&About", $mHelp)
$iLicense = GUICtrlCreateMenuItem("&License", $mHelp)

; Buttons
$bRun = GUICtrlCreateButton("Run", 214, 77, 80, 25)
$bClear = GUICtrlCreateButton("Clear", 299, 77, 80, 25)
$bExit = GUICtrlCreateButton("Exit", 384, 77, 80, 25)

; Checkboxes
$cClean = GUICtrlCreateCheckbox("Clean", 10, 5, 80, 20)
$cFresh = GUICtrlCreateCheckbox("Fresh Install", 10, 30, 80, 20)
$cDiagnostics = GUICtrlCreateCheckbox("Diagnostics", 10, 55, 80, 20)
$cRecovery = GUICtrlCreateCheckbox("Recovery", 10, 80, 80, 20)

; Progress bar
GUICtrlCreateLabel("Progress:", 5, 109)
$pBar = GUICtrlCreateProgress(55, 109, 410, 14)

; Output box
$oList = GUICtrlCreateList("", 5, 130, 460, 140, BitOr($WS_VSCROLL, $WS_BORDER))

; Bottom label
GUICtrlCreateLabel("Fury v" & $version & " | Updated " & $modified, 5, $height - 201 )

; GUI MESSAGE LOOP
GUISetState(@SW_SHOW)
While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE, $bExit, $iExit
			Exit 0

		 Case $iAbout
			CreateInfoGUI("About")

		 Case $iLicense
			 CreateInfoGUI("License")

		  Case $iNetwork
			If BitAND(GUICtrlRead($iNetwork), $GUI_CHECKED) = $GUI_CHECKED Then
                GUICtrlSetState($iNetwork, $GUI_UNCHECKED)
				$useServer = False
            Else
                GUICtrlSetState($iNetwork, $GUI_CHECKED)
				$useServer = True
            EndIf

		 Case $bRun
			; GUI checks
			$ckdClean = BitAND(GUICtrlRead($cClean), $GUI_CHECKED)
			$ckdFresh = BitAND(GUICtrlRead($cFresh), $GUI_CHECKED)
			$ckdDiagnostics = BitAND(GUICtrlRead($cDiagnostics), $GUI_CHECKED)
			$ckdRecovery = BitAND(GUICtrlRead($cRecovery), $GUI_CHECKED)

			; If nothing is selected
			If NOT $ckdClean AND NOT $ckdFresh AND NOT $ckdDiagnostics AND NOT $ckdRecovery = $GUI_CHECKED Then
			   MsgBox($MB_SYSTEMMODAL, "Error", "Nothing is selected!")
			Else
			   dataImport()
			   CopyData()
			EndIF

		 Case $bClear
			GUIAdjustments(2)

	EndSwitch
 WEnd

 EndFunc

; Create Desktop GUI
 Func CreateDesktopGUI()

; GUI
$height = 205
$width = 405
GUICreate("Fury Startup Manager", $width, $height)
GUISetIcon("Fury.exe", 0)

; Buttons
$bRun = GUICtrlCreateButton("Run", 230, 155, 80, 25)
$bExit = GUICtrlCreateButton("Exit", 315, 155, 80, 25)

; Group
GUICtrlCreateGroup("Options", 10, 40, 385, 105, $BS_GROUPBOX)

; Checkboxes
; Left column
$cClean = GUICtrlCreateCheckbox("Cleanup", 20, 60, 80, 20)
GUICtrlSetState($cClean, $GUI_CHECKED)
$cOpen = GUICtrlCreateCheckbox("Open Folder", 20, 85, 80, 20)
GUICtrlSetState($cOpen, $GUI_DISABLE)
$cLaunch = GUICtrlCreateCheckbox("Launch Fury", 20, 110, 80, 20)
GUICtrlSetState($cLaunch, $GUI_DISABLE)

; Center column
$cScreensaver = GUICtrlCreateCheckbox("Prevent Screensaver", 160, 60, 120, 20)
GUICtrlSetState($cScreensaver, $GUI_DISABLE)
$cPostprep = GUICtrlCreateCheckbox("Postprep", 160, 85, 120, 20)
GUICtrlSetState($cPostprep, $GUI_DISABLE)
$cPRCS = GUICtrlCreateCheckbox("PRCS", 160, 110, 80, 20)
GUICtrlSetState($cPRCS, $GUI_DISABLE)

; Right column
$cExit = GUICtrlCreateCheckbox("Exit", 300, 60, 80, 20)
GUICtrlSetState($cExit, $GUI_DISABLE)

; Create labels
GUICtrlCreateLabel("If you are NOT a Help Desk technician, please press Run now.", 17, 15, 405)
GUICtrlSetFont (-1, 8.5, 800)
GUICtrlCreateLabel("Fury v" & $version, 5, $height - 15)

; GUI MESSAGE LOOP
GUISetState(@SW_SHOW)
While 1
	Switch GUIGetMsg()
	Case $GUI_EVENT_CLOSE, $bExit
			Exit

	    Case $bRun
		   ; GUI checks
			$ckdClean = BitAND(GUICtrlRead($cClean), $GUI_CHECKED)
			$ckdOpen = BitAND(GUICtrlRead($cOpen), $GUI_CHECKED)
			$ckdLaunch = BitAND(GUICtrlRead($cLaunch), $GUI_CHECKED)
			$ckdScreensaver = BitAND(GUICtrlRead($cScreensaver), $GUI_CHECKED)
			$ckdPostprep = BitAND(GUICtrlRead($cPostprep), $GUI_CHECKED)
			$ckdPRCS = BitAND(GUICtrlRead($cPRCS), $GUI_CHECKED)
			$ckdExit = BitAND(GUICtrlRead($cExit), $GUI_CHECKED)

			; If nothing is selected
			If NOT $ckdClean AND NOT $ckdOpen AND NOT $ckdScreensaver AND NOT $ckdLaunch _
			   AND NOT $ckdPostprep AND NOT $ckdPRCS AND NOT $ckdExit = $GUI_CHECKED Then
			   MsgBox($MB_SYSTEMMODAL, "Error", "Nothing is selected!")
			EndIf

			If $ckdClean = 1 Then
			   ; Removes registry entry
			   RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "Fury")
			   ; Removes directory, may not work on operating systems older than Windows 7
			   Run(@SystemDir & '\cmd.exe /C rmdir /S /Q "' & @ScriptDir & '"', @TempDir, @SW_HIDE)
			   Exit
			EndIf

			If $ckdOpen = 1 Then
			   Run("Explorer.exe " & $ExportLoc)
			EndIf

			If $ckdLaunch = 1 Then
			   WinSetState ("Fury Startup Manager", "", @SW_HIDE)
			   CreateUSBGUI()
			EndIf

			If $ckdScreensaver = 1 Then
			   ; Keep from sleeping for forever
			   Run(@ComSpec& ' /c "' & @ScriptDir & '\admin\ScreensaverX.exe -q"')
			EndIf

			If $ckdPostprep = 1 Then
			   Run($ExportLoc & "\Liberty\Postprep.exe")
			EndIf

			If $ckdPRCS = 1 Then
			   Run($ExportLoc & "\Liberty\PRCS.exe")
			EndIf

			If $ckdExit = 1 Then
			   Exit
			EndIf

	  Case $cClean
		 $clkClean = _GUICtrlButton_GetCheck($cClean)
		 Switch $clkClean
			Case $BST_CHECKED
			   GUIAdjustments(4)
			Case $BST_UNCHECKED
			   GUIAdjustments(3)
			EndSwitch

	  Case $cOpen
		 $clkOpen = _GUICtrlButton_GetCheck($cOpen)
		 Switch $clkOpen
			Case $BST_CHECKED
			   GUIAdjustments(6)
			Case $BST_UNCHECKED
			   GUIAdjustments(5)
			EndSwitch

	  Case $cLaunch
		 $clkLaunch = _GUICtrlButton_GetCheck($cLaunch)
		 Switch $clkLaunch
			Case $BST_CHECKED
			   GUIAdjustments(6)
			Case $BST_UNCHECKED
			   GUIAdjustments(5)
			EndSwitch

	  Case $cScreensaver
		 $clkScreensaver = _GUICtrlButton_GetCheck($cScreensaver)
		 Switch $clkScreensaver
			Case $BST_CHECKED
			   GUIAdjustments(6)
			Case $BST_UNCHECKED
			   GUIAdjustments(5)
			EndSwitch

	  Case $cPostprep
		 $clkPostprep = _GUICtrlButton_GetCheck($cPostprep)
		 Switch $clkPostprep
			Case $BST_CHECKED
			   GUIAdjustments(6)
			Case $BST_UNCHECKED
			   GUIAdjustments(5)
			EndSwitch

	  Case $cPRCS
		 $clkPRCS = _GUICtrlButton_GetCheck($cPRCS)
		 Switch $clkPRCS
			Case $BST_CHECKED
			   GUIAdjustments(6)
			Case $BST_UNCHECKED
			   GUIAdjustments(5)
			EndSwitch

	  Case $cExit
		 $clkExit = _GUICtrlButton_GetCheck($cExit)
		 Switch $clkExit
			Case $BST_CHECKED
			   GUIAdjustments(6)
			Case $BST_UNCHECKED
			   GUIAdjustments(5)
			EndSwitch

	EndSwitch
 WEnd

 EndFunc

 Func CreateInfoGUI($type)
     $gWindow = GUICreate($type, 380, 250, 350, 350, BitOr($WS_CAPTION, $WS_POPUP, $WS_SYSMENU))
	 GUISetIcon("Fury.exe", 0)
     $bClose = GUICtrlCreateButton("Close", 150, 220, 80, 25)
	 $eText = GUICtrlCreateEdit ("", 5, 5, 370, 210, BitOR($ES_NOHIDESEL, $WS_VSCROLL,$ES_READONLY, $ES_MULTILINE))

	 If $type = "About" Then
	  GUICtrlSetData($eText, "Fury is an computer maintenance and administration application originally designed for use in the Liberty University IT HelpDesk." & @CRLF & "It replaces the former application Alekto, and brings dynamic folder extraction." _
		 & "The former application, Alekto was created as being a punisher of malicious software, Fury is named in a similar manner. Alekto was angry, and Fury is furious." & @CRLF & @CRLF & "Copyright (c) 2014, Lucas Messenger")
	  ElseIf $type = "License" Then
		GUICtrlSetData($eText, "Copyright (c) 2014, Lucas Messenger" & @CRLF & "All rights reserved." & @CRLF & @CRLF & "Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:" _
		& @CRLF & @CRLF & "* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer." & @CRLF & @CRLF & "* Redistributions in binary form must reproduce the above copyright notice," _
		& " this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution." & @CRLF & @CRLF & "* Neither the name of the author nor the names of its contributors may be used to endorse or promote products derived from" _
		& " this software without specific prior written permission." & @CRLF & @CRLF & "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 'AS IS' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE" _
		& " IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL" _
		& " DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY," _
		& " OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.")
	  EndIf

     GUISetState()

     While 1
         Switch GUIGetMsg()
             Case $GUI_EVENT_CLOSE, $bClose
                 GUIDelete($gWindow)
                 ExitLoop
 		EndSwitch
 	WEnd
 EndFunc

; Copy data
Func CopyData()
	GUIAdjustments(0)
	Sleep (100)

DirCreate($ExportLoc & "\admin")
FileInstall(".\admin\unzip.exe", $ExportLoc & "\admin\unzip.exe")

	If DirGetSize($ExportLoc) = -1 Then
	 DirCreate($ExportLoc)
	 GUICtrlSetData($oList, "Created " & $ExportLoc)
  Else
	GUICtrlSetData($oList, "Did not create " & $ExportLoc)
	GUICtrlSetData($oList, "Directory already exists. Will only copy folders.")
 EndIf

 ; Clear progress bar
 GUICtrlSetData($pBar, 0)

 ; Clear and merge array
 ReDim $aMerge[0]
 If _GUICtrlButton_GetCheck($cClean) = 1 Then
   _ArrayConcatenate ($aMerge, $aClean)
  EndIf
  If _GUICtrlButton_GetCheck($cFresh) = 1 Then
	 _ArrayConcatenate ($aMerge, $aFresh)
  EndIf
   If _GUICtrlButton_GetCheck($cDiagnostics) = 1 Then
	  _ArrayConcatenate ($aMerge, $aDiagnostics)
   EndIf
   If _GUICtrlButton_GetCheck($cRecovery) = 1 Then
	  _ArrayConcatenate ($aMerge, $aRecovery)
   EndIf

   ; Add default folders to array
   _ArrayAdd($aMerge, "admin")
   _ArrayAdd($aMerge, "Liberty")
   $aExport = _ArrayUnique($aMerge, 1, 0, 0, 0)
   _ArraySort($aExport, 0)

   ; Determine array size
   $vSize = UBound($aExport) + 3

   FileCopy(@ScriptDir & "\Fury.exe", $ExportLoc)
   GUICtrlSetData($oList, "Copied " & @ScriptDir & "\Fury.exe")
   GUICtrlSetData($pBar, (1/($vSize)) * 100)
   RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "Fury", "REG_SZ", $ExportLoc & "\Fury.exe")
   GUICtrlSetData($oList, "Created HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run\Fury")
   GUICtrlSetData($pBar, (2/($vSize)) * 100)

   ; Copy files to $ExportLoc
   If $useServer = True Then
	  $InputLoc = $ExportLoc
	  For $i = 0 to UBound($aExport) - 1
		  _GUICtrlListBox_BeginUpdate($oList)
		 _GUICtrlListBox_AddString($oList, "Downloading " & $aExport[$i] & ".zip... 0%")
		 $fileGet = InetGet($alektoPath & '/' & $aExport[$i] & ".zip", $ExportLoc & '\' & $aExport[$i] & ".zip", 2, 1)
		 $serverSize = InetGetSize($alektoPath & '/' & $aExport[$i] & ".zip", 2)
		 _GUICtrlListBox_EndUpdate($oList)
		 GUICtrlSetData($pBar, (($i + 3) /($vSize)) * 100)
		 Do
			 _GUICtrlListBox_BeginUpdate($oList)
			$fileSize = InetGetInfo($fileGet, 0)
			_GUICtrlListBox_DeleteString($oList, _GUICtrlListBox_GetCount($oList) - 1)
			Sleep(50)
			_GUICtrlListBox_AddString($oList, "Downloading " & $aExport[$i] & ".zip... " & Round((($fileSize/$serverSize) * 100), 0) & "%")
			_GUICtrlListBox_EndUpdate($oList)
		 Until InetGetInfo($fileGet, 2)

		 InetClose($fileGet)

		 _GUICtrlListBox_BeginUpdate($oList)
		 _GUICtrlListBox_DeleteString($oList, _GUICtrlListBox_GetCount($oList) - 1)
		 Sleep(10)
		 _GUICtrlListBox_AddString($oList, "Downloading " & $aExport[$i] & ".zip... 100%")
		 _GUICtrlListBox_EndUpdate($oList)
	  Next
	  GUICtrlSetData($oList, "Unzipping folders. Please wait... (this may take some time)")
	  For $i = 0 to Ubound($aExport) - 1
		 RunWait(@ComSpec & ' /c "' & @ScriptDir & '\admin\unzip.exe -o ' & $ExportLoc & '\' & $aExport[$i] & '.zip -d ' & $ExportLoc & '"', "", @SW_HIDE)
		 FileDelete($ExportLoc &  '\' & $aExport[$i] & ".zip")
	  Next
	  GUICtrlSetData($oList, "All folders unzipped.")
   Else
	  For $i = 0 to UBound($aExport) - 1
	  $FolderInput = @ScriptDir & "\" & $aExport[$i]
		 If FileExists($FolderInput) Then
			$FolderOutput = $ExportLoc & "\" & $aExport[$i]
			RunWait(@ComSpec & ' /c xcopy /E /H /I /Y "' & $FolderInput & '" "' & $FolderOutput &'"', "", @SW_HIDE)
			GUICtrlSetData($oList, "Copied " & $FolderInput)
		 Else
			GUICtrlSetData($oList, $FolderInput & " does not exist")
		 EndIf
		 GUICtrlSetData($pBar, (($i + 3) /($vSize)) * 100)
	  Sleep(100)
   Next
EndIf
	  GUICtrlSetData($pBar, 100)
	  GUICtrlSetData($oList, "Operation completed.")
	  GUIAdjustments(1)
EndFunc

; GUI adjustments
 Func GUIAdjustments(ByRef $value)
   Select
   ; Extraction manager values (0 - 2)
   Case $value = 0
		 ; Disable Run and checkboxes
		 GUICtrlSetState($bRun, $GUI_DISABLE)
		 GUICtrlSetState($cClean, $GUI_DISABLE)
		 GUICtrlSetState($cFresh, $GUI_DISABLE)
		 GUICtrlSetState($cDiagnostics, $GUI_DISABLE)
		 GUICtrlSetState($cRecovery, $GUI_DISABLE)

	  Case $value = 1
		 ; Enable Run and checkboxes
		 GUICtrlSetState($bRun, $GUI_ENABLE)
		 GUICtrlSetState($cClean, $GUI_ENABLE)
		 GUICtrlSetState($cFresh, $GUI_ENABLE)
		 GUICtrlSetState($cDiagnostics, $GUI_ENABLE)
		 GUICtrlSetState($cRecovery, $GUI_ENABLE)

	  Case $value = 2
		 ; Clear checkboxes
		 GUICtrlSetState($cClean, $GUI_UNCHECKED)
		 GUICtrlSetState($cFresh, $GUI_UNCHECKED)
		 GUICtrlSetState($cDiagnostics, $GUI_UNCHECKED)
		 GUICtrlSetState($cRecovery, $GUI_UNCHECKED)

	  ; Startup manager values (3 - 6)
	  Case $value = 3
		 ; Enable checkboxes
		 GUICtrlSetState($cClean, $GUI_UNCHECKED)
		 GUICtrlSetState($cOpen, $GUI_ENABLE)
		 GUICtrlSetState($cLaunch, $GUI_ENABLE)
		 If FileExists($ExportLoc & "\admin\ScreensaverX.exe") Then
			GUICtrlSetState($cScreensaver, $GUI_ENABLE)
		 EndIf
		 If FileExists($ExportLoc & "\Liberty\Postprep.exe") Then
			GUICtrlSetState($cPostprep, $GUI_ENABLE)
		 EndIf
		 If FileExists($ExportLoc & "\Liberty\PRCS.exe") Then
			GUICtrlSetState($cPRCS, $GUI_ENABLE)
		 EndIf
		 GUICtrlSetState($cExit, $GUI_ENABLE)

	  Case $value = 4
		 ; Disable checkboxes
		 GUICtrlSetState($cOpen, $GUI_DISABLE)
		 GUICtrlSetState($cScreensaver, $GUI_DISABLE)
		 GUICtrlSetState($cLaunch, $GUI_DISABLE)
		 GUICtrlSetState($cExit, $GUI_DISABLE)
		 GUICtrlSetState($cPostprep, $GUI_DISABLE)
		 GUICtrlSetState($cPRCS, $GUI_DISABLE)

	  Case $value = 5
		 ; Enable cleanup checkbox
		 GUICtrlSetState($cClean, $GUI_ENABLE)

	  Case $value = 6
		 ; Disable cleanup checkbox
		 GUICtrlSetState($cClean, $GUI_DISABLE)

   EndSelect
EndFunc