; Fury - AutoIt
; Created: 5/21/2014
; Modifed: 5/21/2014
; Author: Lucas Messenger
; ------------------------------
; Exit Codes
; 0 - Complete

#include <GuiConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <file.au3>

;Dim $aRecords, $File = @ScriptDir & "\admin\folders.txt"
;_FileReadToArray ( $sFilePath, ByRef $aArray [, $iFlag = 1] )

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
GUICtrlCreateList("", 5, 110, 460, 126)

; GUI MESSAGE LOOP
GUISetState(@SW_SHOW)
While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE, $bExit, $iExit
			Exit 0

		 Case $iAbout
			   MsgBox($MB_SYSTEMMODAL, "About", $aRecords) ; may need to change to a form, not msgbox

		 Case $iLicense
			   MsgBox($MB_SYSTEMMODAL, "License", "Insert license information.") ; may need to change to a form, not msgbox

		 Case $bRun
			if BitAND(GUICtrlRead($cClean), $GUI_CHECKED) = $GUI_CHECKED then
			   CopyData()
			   MsgBox($MB_SYSTEMMODAL, "Checked", "Clean checked")
			Else
			   MsgBox($MB_SYSTEMMODAL, "Checked", "Clean Unchecked")
			EndIf

	EndSwitch
 WEnd

 EndFunc

 Func CopyData()

	DirCreate (@DesktopDir & '\Fury' ) ; Create Fury directory on local desktop
 EndFunc

