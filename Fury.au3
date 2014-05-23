; Fury
$version = 0.1
$created = "5/21/2014"
$modified = "5/23/2014"
; Author: Lucas Messenger
; Credits: Kenton Tofte, Luke Moore
; ------------------------------
; Fury icon: http://www.iconspedia.com/icon/fire-icon-35660.html
; CC Attribution license for icon: https://creativecommons.org/licenses/by/3.0/
; ------------------------------
; Error/Exit Codes
; 0 - Complete
; 1 - folders.txt does not exist or is corrupted
; 2 - Error reading folders.txt
; 3 - Cannot find comma delimination
; 4 - Error importing to individual arrays
; -------------------------------
; Comments
;
;

#include <GuiConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <file.au3>
#include <Array.au3>
#include <ListBoxConstants.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <GUIButton.au3>

Dim $height
Dim $width

; Locations
Dim $Folder = @ScriptDir
Dim $File = @ScriptDir & '\admin\folders.txt'
Dim $ExportLoc = @DesktopDir & '\Fury'

; Arrays
Dim $aOrig
Dim $aClean[0]
Dim $aFresh[0]
Dim $aDiagnostics[0]
Dim $aRecovery[0]
Dim $aMerge[0]
Dim $aExport[0]

; Buttons
Dim $bRun, $bCancel, $bClear, $bExit

; Menu items
Dim $mFile, $mHelp, $iExit, $iAbout, $iLicense

; Misc items
Dim $pBar, $oList

; Boolean
$Cancelled = False

; Checkboxes
Dim $cClean, $cFresh, $cDiagnostics, $cRecovery

; Check if executing from Desktop or USB
If $Folder = $ExportLoc Then
   CreateDesktopGUI()
Else

   dataImport()
   CreateUSBGUI()
EndIf

; Import data from folders.txt
Func dataImport()
   If Not FileExists($File) Then
	  MsgBox($MB_SYSTEMMODAL, "Import error", "Cannot find folders.txt. Is Fury running from the proper directory?" & @CRLF & @CRLF & "Error code: 1")
	  Exit 1
   Else
	  If Not _fileReadToArray($File, $aOrig) Then
		 MsgBox($MB_SYSTEMMODAL, "Import error", "There was an error reading the file. Does the file exist?" & @CRLF & @CRLF & "Error code: 2")
		 Exit 2
	  Else
		 _ArraySearch($aOrig, ",", 0, 0, 0, 1)
		 If @error Then
			MsgBox($MB_SYSTEMMODAL, "Import error", "There was an error reading the file. folders.txt is not comma delimited" & @CRLF & @CRLF & "Error code: 3")
			Exit 3
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
					 MsgBox($MB_SYSTEMMODAL, "Import error", "There was an error reading the file." & @CRLF & @CRLF & "Error code: 4")
					 Exit 4
				  EndSelect
			   Next
		 EndIf
	  EndIf
   EndIf
EndFunc

; Create USB GUI
Func CreateUSBGUI()

; Dimensions
$height = 470
$width = 305

; GUI Create
GUICreate("Fury", $height, $width)
GUISetIcon("Fury.exe", 0)

; Menu and menu items
 $mFile = GUICtrlCreateMenu("&File")
 $iExit = GUICtrlCreateMenuItem("&Exit", $mFile)
 $mHelp = GUICtrlCreateMenu("&Help")
 $iAbout = GUICtrlCreateMenuItem("&About", $mHelp)
 $iLicense = GUICtrlCreateMenuItem("&License", $mHelp)

; Buttons
$bRun = GUICtrlCreateButton("Run", 129, 77, 80, 25)
$bCancel = GUICtrlCreateButton("Cancel", 214, 77, 80, 25)
GUICtrlSetState($bCancel, $GUI_DISABLE)
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
$oList = GUICtrlCreateList("", 5, 130, 460, 140, -1)

; Bottom label
GUICtrlCreateLabel("Created by Lucas Messenger | Fury v" & $version & " | Updated " & $modified, 5, $height - 201 )

; GUI MESSAGE LOOP
GUISetState(@SW_SHOW)
While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE, $bExit, $iExit
			Exit 0

		 Case $iAbout
			; May need to change to a form, not msgbox
			   MsgBox($MB_SYSTEMMODAL, "About", "Insert about information.")

		 Case $iLicense
			 ; May need to change to a form, not msgbox
			   MsgBox($MB_SYSTEMMODAL, "License", "Insert license information.")

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
			   CopyData()
			EndIF

		 Case $bClear
			GUIAdjustments(2)

		 Case $bCancel
			$Cancelled = True
	EndSwitch
 WEnd

 EndFunc

; Create Desktop GUI
 Func CreateDesktopGUI()

; Checkboxes
Dim $cClean, $cOpen, $cScreensaver, $cLaunch

; GUI
$height = 225
$width = 400
GUICreate("Fury Startup Manager", $width, $height)
GUISetIcon("Fury.exe", 0)

; Buttons
$bRun = GUICtrlCreateButton("Run", 230, 175, 80, 25)
$bExit = GUICtrlCreateButton("Exit", 315, 175, 80, 25)

; Group
GUICtrlCreateGroup("", 10, 75, 380, 85, $BS_GROUPBOX)

; Checkboxes
; Left column
$cClean = GUICtrlCreateCheckbox("Cleanup", 20, 85, 80, 20)
GUICtrlSetState($cClean, $GUI_CHECKED)
$cOpen = GUICtrlCreateCheckbox("Open", 20, 110, 80, 20)
GUICtrlSetState($cOpen, $GUI_DISABLE)
$cScreensaver = GUICtrlCreateCheckbox("Prevent Screensaver", 20, 135, 120, 20)
GUICtrlSetState($cScreensaver, $GUI_DISABLE)

; Right column
$cLaunch = GUICtrlCreateCheckbox("Launch Fury", 160, 85, 80, 20)
GUICtrlSetState($cLaunch, $GUI_DISABLE)
$cExit = GUICtrlCreateCheckbox("Exit", 160, 110, 80, 20)
GUICtrlSetState($cExit, $GUI_DISABLE)

GUICtrlCreateLabel("Created by Lucas Messenger | Fury v" & $version & " | Updated " & $modified, 5, $height - 15)

; GUI MESSAGE LOOP
GUISetState(@SW_SHOW)
$ckdClean = BitAND(GUICtrlRead($cClean), $GUI_CHECKED)
While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE, $bExit
			Exit

	    Case $bRun
		   ; GUI checks
			$ckdOpen = BitAND(GUICtrlRead($cOpen), $GUI_CHECKED)
			$ckdScreensaver = BitAND(GUICtrlRead($cScreensaver), $GUI_CHECKED)
			$ckdLaunch = BitAND(GUICtrlRead($cLaunch), $GUI_CHECKED)
			$ckdExit = BitAND(GUICtrlRead($cExit), $GUI_CHECKED)

			; If nothing is selected
			If NOT $ckdClean AND NOT $ckdOpen AND NOT $ckdScreensaver AND NOT $ckdLaunch _
			   AND NOT $ckdExit = $GUI_CHECKED Then
			   MsgBox($MB_SYSTEMMODAL, "Error", "Nothing is selected!")
			EndIf

	  Case $cClean
		 $clkClean = _GUICtrlButton_GetCheck($cClean)
		 Switch $clkClean
			Case $BST_CHECKED
			   GUIAdjustments(4)
			Case $BST_UNCHECKED
			   GUIAdjustments(3)
		 EndSwitch
	EndSwitch
 WEnd

 EndFunc

; Copy data
 Func CopyData()
	GUIAdjustments(0)
	Sleep (100)
	If DirGetSize($ExportLoc) = -1 Then
	 DirCreate($ExportLoc)
	 GUICtrlSetData($oList, "Sucessfully created " & $ExportLoc)
  Else
	GUICtrlSetData($oList, "Did not create " & $ExportLoc)
	GUICtrlSetData($oList, "Directory already exists. Will only copy folders.")
 EndIf
 FileCopy(@ScriptDir & "\Fury.exe", $ExportLoc)
 RegWrite ("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "Fury", "REG_SZ", $ExportLoc & "\Fury.exe")
 ReDim $aMerge[0]
 If BitAND(GUICtrlRead($cClean), $GUI_CHECKED) = $GUI_CHECKED Then
   _ArrayConcatenate ($aMerge, $aClean)
  EndIf
  If BitAND(GUICtrlRead($cFresh), $GUI_CHECKED) = $GUI_CHECKED Then
	 _ArrayConcatenate ($aMerge, $aFresh)
  EndIf
   If BitAND(GUICtrlRead($cDiagnostics), $GUI_CHECKED) = $GUI_CHECKED Then
	  _ArrayConcatenate ($aMerge, $aDiagnostics)
   EndIf
   If BitAND(GUICtrlRead($cRecovery), $GUI_CHECKED) = $GUI_CHECKED Then
	  _ArrayConcatenate ($aMerge, $aRecovery)
   EndIf
   $aExport = _ArrayUnique($aMerge, 1, 0, 0, 0)
   For $i = 0 to UBound($aExport) - 1
	  If $Cancelled = False Then
		 If FileExists(@ScriptDir & "\" & $aExport[$i]) Then
			DirCopy(@ScriptDir & "\" & $aExport[$i], $ExportLoc & "\" & $aExport[$i])
			GUICtrlSetData($pBar, ($i/(UBound($aExport) - 1)) * 100)
			GUICtrlSetData($oList, "Copied " & @ScriptDir & '\' & $aExport[$i])
		 EndIf
	  Else
		 GUICtrlSetData($oList, "Operation cancelled.")
		 ExitLoop
	  EndIf
	  Sleep (100)
   Next
	  GUIAdjustments(1)
EndFunc

; GUI adjustments
 Func GUIAdjustments(ByRef $value)
   Select
   ; Extraction manager values (0 - 2)
   Case $value = 0
		 ; Disable Run and checkboxes, enable Cancel
		 GUICtrlSetState($bRun, $GUI_DISABLE)
		 GUICtrlSetState($bCancel, $GUI_ENABLE)
		 GUICtrlSetState($cClean, $GUI_DISABLE)
		 GUICtrlSetState($cFresh, $GUI_DISABLE)
		 GUICtrlSetState($cDiagnostics, $GUI_DISABLE)
		 GUICtrlSetState($cRecovery, $GUI_DISABLE)

	  Case $value = 1
		 ; Enable Run and checkboxes, disable Cancel
		 GUICtrlSetState($bRun, $GUI_ENABLE)
		 GUICtrlSetState($bCancel, $GUI_DISABLE)
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

	  ; Startup manager values (3 - 4)
	  Case $value = 3
		 ; Enable checkboxes
		 GUICtrlSetState($cClean, $GUI_UNCHECKED)
		 GUICtrlSetState($cOpen, $GUI_ENABLE)
		 GUICtrlSetState($cScreensaver, $GUI_ENABLE)
		 GUICtrlSetState($cLaunch, $GUI_ENABLE)
		 GUICtrlSetState($cExit, $GUI_ENABLE)

	  Case $value = 4
		 ; Disable checkboxes
		 GUICtrlSetState($cOpen, $GUI_DISABLE)
		 GUICtrlSetState($cScreensaver, $GUI_DISABLE)
		 GUICtrlSetState($cLaunch, $GUI_DISABLE)
		 GUICtrlSetState($cExit, $GUI_DISABLE)
   EndSelect
EndFunc