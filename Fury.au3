; Fury - AutoIt
; Created: 5/21/2014
; Modifed: 5/21/2014
; Author: Lucas Messenger
; ------------------------------
; Fury icon: http://www.iconspedia.com/icon/fire-icon-35660.html
; CC Attribution license for icon: https://creativecommons.org/licenses/by/3.0/
; ------------------------------
; Error/Exit Codes
; 0 - Complete
; 1 - Error reading folders.txt, file does not exist or is corrupted
; 2 - Cannot find comma delimination
; 3 - Error importing to individual arrays

#include <GuiConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <file.au3>
#include <Array.au3>
#include <ListBoxConstants.au3>

Dim $ExportLoc = @DesktopDir & '\Fury'
Dim $FuryDir = @ScriptDir
Dim $oList

; Arrays
Dim $aOrig
Dim $aClean[0]
Dim $aFresh[0]
Dim $aDiagnostics[0]
Dim $aRecovery[0]

; folders.txt location
Dim $File = @ScriptDir & '\admin\folders.txt'

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

CreateGUI()

; Create GUI
Func CreateGUI()

Local $mFile, $mHelp, $iExit, $iAbout, $iLicense ; menu items
Local $bRun, $bCancel, $bClear, $bExit ; buttons
Local $cClean, $cFresh, $cDiagnostics, $cRecovery ; checkboxes

; Create GUI
GUICreate("Fury", 470, 270)
GUISetIcon("Fury.exe", 0)

; Create menu and menu items
 $mFile = GUICtrlCreateMenu("&File")
 $iExit = GUICtrlCreateMenuItem("&Exit", $mFile)
 $mHelp = GUICtrlCreateMenu("&Help")
 $iAbout = GUICtrlCreateMenuItem("&About", $mHelp)
 $iLicense = GUICtrlCreateMenuItem("&License", $mHelp)

; Create buttons
$bRun = GUICtrlCreateButton("Run", 129, 77, 80, 25)
$bCancel = GUICtrlCreateButton("Cancel", 214, 77, 80, 25)
$bClear = GUICtrlCreateButton("Clear", 299, 77, 80, 25)
$bExit = GUICtrlCreateButton("Exit", 384, 77, 80, 25)

; Create checkboxes
$cClean = GUICtrlCreateCheckbox("Clean", 10, 5, 80, 20)
$cFresh = GUICtrlCreateCheckbox("Fresh Install", 10, 30, 80, 20)
$cDiagnostics = GUICtrlCreateCheckbox("Diagnostics", 10, 55, 80, 20)
$cRecovery = GUICtrlCreateCheckbox("Recovery", 10, 80, 80, 20)

; create output box
$oList = GUICtrlCreateList("", 5, 110, 460, 140, -1)

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
				  CopyData("Clean")
			   EndIf
			   If BitAND(GUICtrlRead($cFresh), $GUI_CHECKED) = $GUI_CHECKED then
				  CopyData("Fresh Install")
			   EndIf
			   If BitAND(GUICtrlRead($cDiagnostics), $GUI_CHECKED) = $GUI_CHECKED then
				  CopyData("Diagnostics")
			   EndIf
			   If BitAND(GUICtrlRead($cRecovery), $GUI_CHECKED) = $GUI_CHECKED then
				  CopyData("Recovery")
			   EndIf
			EndIF
	EndSwitch
 WEnd

 EndFunc

 Func CopyData($group)
	If DirGetSize($ExportLoc) = -1 Then
	  DirCreate($ExportLoc)
	  GUICtrlSetData($oList, "Extracting folders...")

   Else
	 GUICtrlSetData($oList, "Did not create Fury directory, already exists.")
	 GUICtrlSetData($oList, $group)
	 For $i = 0 to UBound($aFolders, 1) -1
		For $j = 0 to UBound($aFolders, 2) -1

		   Next
		Next
   EndIf
 EndFunc