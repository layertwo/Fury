; Fury - AutoIt
; Created: 5/21/2014
; Modifed: 5/21/2014
; Author: Lucas Messenger
; ------------------------------
; Error/Exit Codes
; 0 - Complete
; 1 - Error reading folders.txt, file does not exist or is corrupted
; 2 - Cannot find comma delimination

#include <GuiConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <file.au3>
#include <Array.au3>

Dim $ExportLoc = @DesktopDir & '\Fury'
Dim $FuryDir = @ScriptDir
Dim $oList
Dim $aOrig
Dim $File = @ScriptDir & '\admin\folders.txt'
If Not _fileReadToArray($File, $aOrig) Then
   MsgBox($MB_SYSTEMMODAL, "Import error", "There was an error reading the file. Error code: 1")
   Exit 1
Else
   _ArraySearch($aOrig, ",", 0, 0, 0, 1)
	If @error Then
	  MsgBox($MB_SYSTEMMODAL, "Import error", "There was an error reading the file. Error code: 2")
	  Exit 2
   Else
   $CountCol = stringsplit($aOrig[1],",")
   Dim $aFolders[$aOrig[0] + 1][$CountCol[0] + 1]
   For $x = 1 to ($aOrig[0])
	  $OrigRow = StringSplit($aOrig[$x],",")
	  For $y = 1 to ($CountCol[0])
		 $aFolders[$x][$y] = $OrigRow[$y]
	  Next
   Next
   EndIf
EndIf

CreateGUI()

Func CreateGUI()

Local $mFile, $mHelp, $iExit, $iAbout, $iLicense ; menu items
Local $bRun, $bCancel, $bClear, $bExit ; buttons
Local $cClean, $cFresh, $cDiagnostics, $cRecovery ; checkboxes

; GUI
GUICreate("Fury", 470, 270)
GUISetIcon(@SystemDir & "\mspaint.exe", 0) ; need to change this

; MENU
 $mFile = GUICtrlCreateMenu("File")
 $iExit = GUICtrlCreateMenuItem("Exit", $mFile)
 $mHelp = GUICtrlCreateMenu("Help")
 $iAbout = GUICtrlCreateMenuItem("About", $mHelp)
 $iLicense = GUICtrlCreateMenuItem("License", $mHelp)


; BUTTON
$bRun = GUICtrlCreateButton("Run", 129, 77, 80, 25)
$bCancel = GUICtrlCreateButton("Cancel", 214, 77, 80, 25)
$bClear = GUICtrlCreateButton("Clear", 299, 77, 80, 25)
$bExit = GUICtrlCreateButton("Exit", 384, 77, 80, 25)

; CHECKBOX
$cClean = GUICtrlCreateCheckbox("Clean", 10, 5, 80, 20)
$cFresh = GUICtrlCreateCheckbox("Fresh Install", 10, 30, 80, 20)
$cDiagnostics = GUICtrlCreateCheckbox("Diagnostics", 10, 55, 80, 20)
$cRecovery = GUICtrlCreateCheckbox("Recovery", 10, 80, 80, 20)

; OUTPUT BOX
$oList = GUICtrlCreateList("", 5, 110, 460, 126)

; GUI MESSAGE LOOP
GUISetState(@SW_SHOW)
While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE, $bExit, $iExit
			Exit 0

		 Case $iAbout
			   MsgBox($MB_SYSTEMMODAL, "About", "Insert about information.") ; may need to change to a form, not msgbox

		 Case $iLicense
			   MsgBox($MB_SYSTEMMODAL, "License", "Insert license information.") ; may need to change to a form, not msgbox

		 Case $bRun
			$ckdClean = BitAND(GUICtrlRead($cClean), $GUI_CHECKED)
			$ckdFresh = BitAND(GUICtrlRead($cFresh), $GUI_CHECKED)
			$ckdDiagnostics = BitAND(GUICtrlRead($cDiagnostics), $GUI_CHECKED)
			$ckdRecovery = BitAND(GUICtrlRead($cRecovery), $GUI_CHECKED)
			If NOT $ckdClean AND NOT $ckdFresh AND NOT $ckdDiagnostics AND NOT $ckdRecovery = $GUI_CHECKED Then
			   MsgBox($MB_SYSTEMMODAL, "Error", "Nothing is selected!")
			Else
			   If BitAND(GUICtrlRead($cClean), $GUI_CHECKED) = $GUI_CHECKED then
				  CopyData()
			   Else

			   EndIf
			EndIF
	EndSwitch
 WEnd

 EndFunc

 Func CopyData()
	If DirGetSize($ExportLoc) = -1 Then
	  DirCreate($ExportLoc)
	  GUICtrlSetData($oList, "Extracting folders...")
   Else
	 GUICtrlSetData($oList, "Did not create Fury directory, already exists.")
   EndIf
 EndFunc