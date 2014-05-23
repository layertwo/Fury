; Fury v. 0.1
$version = 0.1
; Created: 5/21/2014
; Modifed: 5/22/2014
$modified = "5/22/2014"
; Author: Lucas Messenger
; Credits: Kenton Tofte, Luke Moore
; ------------------------------
; Fury icon: http://www.iconspedia.com/icon/fire-icon-35660.html
; CC Attribution license for icon: https://creativecommons.org/licenses/by/3.0/
; ------------------------------
; Error/Exit Codes
; 0 - Complete
; 1 - Error reading folders.txt, file does not exist or is corrupted
; 2 - Cannot find comma delimination
; 3 - Error importing to individual arrays
; -------------------------------
; Comments
;
;

#include <GuiConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <file.au3>
#include <Array.au3>
#include <ListBoxConstants.au3>

; Arrays
Dim $aOrig
Dim $aClean[0]
Dim $aFresh[0]
Dim $aDiagnostics[0]
Dim $aRecovery[0]
Dim $aMerge[0]
Dim $aExport[0]

; Locations
Dim $File = @ScriptDir & '\admin\folders.txt'
Dim $ExportLoc = @DesktopDir & '\Fury'

; Menu items
Dim $mFile, $mHelp, $iExit, $iAbout, $iLicense

; Buttons
Dim $bRun, $bCancel, $bClear, $bExit

; Checkboxes
Dim $cClean, $cFresh, $cDiagnostics, $cRecovery

; Misc items
Dim $pBar, $oList

; Boolean
$Cancelled = False

dataImport()

; Import data from folders.txt
Func dataImport()
   If Not _fileReadToArray($File, $aOrig) Then
	  MsgBox($MB_SYSTEMMODAL, "Import error", "There was an error reading the file. Error code: 1")
	  Exit 1
   Else
	  _ArraySearch($aOrig, ",", 0, 0, 0, 1)
	  If @error Then
		 MsgBox($MB_SYSTEMMODAL, "Import error", "There was an error reading the file. Error code: 2")
		 Exit 2
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
				  MsgBox($MB_SYSTEMMODAL, "Import error", "There was an error reading the file. Error code: 3")
				  Exit 3
			   EndSelect
			Next
	  EndIf
   EndIf
EndFunc

CreateUSBGUI()
GUIAdjustments(1)

; Create GUI
Func CreateUSBGUI()

; GUI
GUICreate("Fury", 470, 305)
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
GUICtrlCreateLabel("Created by Lucas Messenger | Fury v" & $version & " | Updated " & $modified, 5, 269)

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
		 _CopyDir(@ScriptDir & "\" & $aExport[$i] & "\*", $ExportLoc & "\" & $aExport[$i])
		 GUICtrlSetData($pBar, ($i/(UBound($aExport) - 1)) * 100)
		 GUICtrlSetData($oList, "Copied " & @ScriptDir & '\' & $aExport[$i])
	  Else
		 GUICtrlSetData($oList, "Operation cancelled.")
		 ExitLoop
	  EndIf
	  Sleep (100)
   Next
	  GUIAdjustments(1)
EndFunc

Func GUIAdjustments(ByRef $value)
   Select
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
   EndSelect
EndFunc


