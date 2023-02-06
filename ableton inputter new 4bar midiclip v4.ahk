#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
;IMPORTANT NOTE: originally this script had the below line, "SendMode Input", commented out... but this didn't work with holding alt and using mouseclickdrag function to change velocity of notes... so sendmode input line has been uncommented.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
;commented-out 'SendMode Input' caus afaik drawing to GIMP's screen with mouse macros etc. it worked without sendmode input here. maybe activate this line again when GIMP is replaced with Gdip.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance Force
SetBatchLines, -1		;what does this do?

SetKeyDelay, -1			;read manual about this. using 0 here instead of -1 might be more stable.

coordmode, mouse, screen
coordmode, tooltip, screen

; Uncomment if Gdip.ahk is not in your standard library
;#Include, Gdip.ahk

/*
ableton shortcut keypresses:
- show/hide browser															ctrl-alt-b
- change track width 			with track/s selected:						alt =  OR  alt -
- hide/show detail view														ctrl-alt-l
- optimize arrangement width	with qwerty-keyboard midi input off			w [if you press again, looks like it cycles between the horizontal zoom and position you were at and the 'optimal' arrangement width zoom and position.]
- optimize arrangement height												h [if you press again, looks like it cycles between the vertical zoom and position you were at and the 'optimal' arrangement height zoom and position.]
*/

/*

NOTES:
- sending alt= shortcut to any ableton track/s makes it/them the maximum height, which is 1 track width + 25 track widths = 26 track widths total. likewise, sending 25 alt- shortcuts to any max-height ableton track/s makes all those track/s 1 width high (from 26 widths down to 1 width high).
- with ableton in fullscreen mode on this screen (1920 by 1080 i think), and an ableton track at full 26 widths of height [1 trackheight + 25 presses of alt= shortcut..], the automation area is 531 possible pixels of height. this is like 1-531: endpoints included, or 0-530: endpoints included [i think...].
- there seems to be a glitch with M4L Device - Dead Simple Global Transpose, where if you duplicate a track that has this M4L Device on it, the duplicated track's instance of the plugin/knob will not be responsive. at some point it might become responsive again, dont know.
	- probably don't duplicate tracks with this plugin, or have a macro that removes the plugin, then duplicates the track, then puts the plugin on the duplicated track.
- since clipwait isn't working with ableton unless you de-activate the ableton window [only way ive found so far is with "send, !{esc}"]... it looks like ableton consistently takes either 31/47ms to load something into the clipboard when copying something, "send, !{esc}"'ing the ableton window and measuring 'A_TickCount' differences. so maybe a sleep of ~60ms will always do the same thing that 'clipwait' would do (with very low chance of it taking longer than this and creating a bug(?)).
- looks like the default for simpler is to have 'Snap' setting on. This setting being on can remove a lot of the tail of certain samples, so need to turn it off. once it's turned off for a certain track, if you replace it with another sample using ableton's Hotswap mode, the snap will still be OFF. if you don't use hotswap mode to replace the sample, im guessing a new instance of Simpler is loaded, and the 'Snap' setting will be back ON. So use the Hotswap mode to randomize/change samples... otherwise have to turn off the 'Snap' setting each time (or look at saving some type of default Simpler settings that override this behaviour).
- atm there's 2 blank tracks at the top:
	- the first blank track has a long blank midiclip in it from barline 1 to barline 65.
	- the second blank track has two 4bar midi clips in it:
		- THE 1ST MIDI CLIP:
			- the 1st midi clip is from barline 1 to barline 5. this midi clip has 2 notes in it:
			- a note at B7, one 16th long, from barline -1.4.3 to -1.4.4
			- a note at A-1, one 16th long, from barline -1.4.3 to -1.4.4
			- [this midiclip is also on the A minor scale, with the 'Scale' button (button next to 'Fold' button) clicked ON]. the horizontal zoom is set to be from barline 1 to barline 5. then fullscreen mode is turned on, and the vertical zoom is done by double clicking in the vertical-zoom-area so that the 2 notes mentioned above set the vertical-zoom-level.
		- THE 2ND MIDI CLIP:
			- the 2nd midi clip is from barline 5 to barline 9. this midi clip has 2 notes in it:
			- a note at F5, one 16th long, from barline -1.4.3 to -1.4.4
			- a note at F#0, one 16th long, from barline -1.4.3 to -1.4.4
			- [this midiclip has no scale or fold mode turned on]. the horizontal zoom is set to be from barline 1 to barline 5. then fullscreen mode is turned on, and the vertical zoom is done by double clicking in the vertical-zoom-area so that the 2 notes mentioned above set the vertical-zoom-level.


new NOTES on how to use ableton with this system:
- in ableton, when renaming a track, putting '# ' as the first character will make the track number appear as the first character/s with a space, then whatever you name it after.
- need to lower the 'Preview Volume' to -15dB. this slider can be found on the Master Track in Arrangement View, next to the Master Track 'Track Volume' slider.
- put all single-shot-audio-files on audio tracks. color ALL of these audio tracks YELLOW. always have these tracks at volume 0dB. then to get different volumes for each audio sample, double click the audio sample in the arrangement view timeline and drag down the 'Gain' slider until that sample is at the desired volume.[THE THING ABOUT THIS NOTE IS YOU HAVE TO REMEMBER THAT WHEN YOU CTRL-A TO SELECT ALL TRACKS TO CHANGE VOLUME OF MULTIPLE TRACKS AT ONCE, YOU HAVE TO THEN DE-SELECT ALL OF THESE YELLOW AUDIO TRACKS. dont know if theres a better way to do this so that ctrl-a can be used in a simpler way than this...]

;NOTE:
;these 2 lines appear everywhere and probably should be built into a function/built into functions and removed:
;currentInputLayer := "mainLayer"
;gosub, drawMainLayerIndicator
;not sure if those 2 lines always work as intended, and not sure how they will work if there are multiple different 'main' layers for different purposes, e.g. triplet-inputting or EQ-parameter-inputting or synthesizer-plugin-parameter-editing.

;NOTE:
;this line is probably missing in a couple of places, probably especially places where gosub's or macros are called NOT by 126options-type-chains:
;tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
;its the line to get rid of tooltips from screen, so that macro's don't click on the tooltip, instead of clicking through to the ableton window.
;probably have now added it in all the places it's needed atm. might forget to add it to future functions though. so leaving this comment block here. if macros arent sending to ableton window properly on rare occasions, it might be because of tooltips blocking mouseclick macros.

;NOTE:
;probably have to turn off 'snap' in ableton sampler for reverse cymbals. caus it cuts off the very end of the reverse sample, the loudest bit.
;might have to turn off 'snap' in ableton sampler for other types of samples as well, not just reverse cymbals.
/*
things to add:
- change instruments
- triplet inputting and showing something onscreen when triplet inputting is activated.
- 'velocity' abilities for FX such as distortion amount, overdrive amount, maybe even EQ settings.
	- other options: reverb amount, delay volume, phase-flanger dry-wet.
- shift velocity of multiple notes with curve. have parameters to define the curve shape(?).
- save/load
	- generate random filename
		- options to pick new filename/go back to previously suggested filenames
- system volume changing/mixer sliders
- randomize options
	- insert random note?
	- insert random chord?
	- insert random 2notes?
- pasting chords?
*/

; Start gdi+
If !pToken := Gdip_Startup()
{
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
OnExit, Exit

;*********************************************
;initializing vars:

; Set the width and height we want as our drawing area, to draw everything in. This will be the dimensions of our bitmap
gdipWidth := 1920
gdipHeight := 1080		; screen resolution probably

;took this out caus it needs to go inside function/gosub instead(???):
;isNoteLengthValid := 0			;this doesn't probably work properly, in at least one place.

suspendVal := 0		;using this so i can leave the script running and this toggles some gdip stuff on/off.

multvar := 0		; this is for verifying that the 126option chain input is a valid option with 1st and 3rd press being valid. 2nd press, i think, is always valid so long as its any value between 1 and 6, endpoints included.

areInputsValid := 0			;this needed/used still?

qwertyOrErgo := 0		;starts on ergo by default, atm.

isAutoVelocityOn := 0			;0 = off, 1 = on.
autoVelocityVal := 100

notTripletOrTriplet := 0			;starts off as not-triplet: 0 is not-triplet, 1 is triplet.
in4BarSectionOrNot := 0				;starts off in 4bar section.

	;initializing these 3 vars, so they can be used in executing macro functions.
yToClick := 0
xToClick := 0
velocityToInput := 0

whatIsCurrentAbletonView := "fourBarMidiClip"

whichMainLayerIndicator := 0
;0 = 4 bar midi clip 64options
;1 = 4 bar midi clip 48options
;2 = arrangement view

startPositionOfLastInputtedNoteInMidiClip64thNumberX := 1 		;initialized as 1, so that if the function that uses this variable is run before inputting ANY notes, function will play from the first 64th in the current 4bar midi clip.
/*
NOTES:
using these m4l devices:
- ntpd2
- dead simple global transpose
*/
;****************************************************************************************************************************
;****************************************************************************************************************************
;****************************************************************************************************************************
/*
numberOfMillisecondsToReversedSoundPeak := 			;get this value by writing macro that does ctrl-r on the sample filename(?)
currentProjectBPM := ;get BPM of track by sending ctrl-c macro to m4l device NTPD2, on master track.
;input a barNumber and 16thNumber you want to line the reversed sound peak up with.
amountOfTimePer16thInMilliseconds := (60 / (currentProjectBPM * 4)) * 1000			;this value will be, for example, ~136.xxxx ms per 16th at 110bpm.
*/
/*
notes for gdip gui:
can probably have everything on one gui, and just draw/delete things from that one gui when needed?
*/
;NOTES for getting ableton coords:
; - make sure ableton is in fullscreen mode.
; - make sure 'Overview' mode is disabled in 'View->Overview'.
; - make sure 'Track Delay' side panel on the far-right of the screen is open.

/*
NOTES FOR USING THIS SYSTEM:
- make sure "Track Delay" side panel on the far-right of the screen is open.
*/

newNumberOfPixelsX := 64
;58 does all the notes of the piano fixed-in-key with key-switching and input always the same finger combinations for each physical screen position:
newNumberOfPixelsY := 58

amountOfXCells := 64		;change this variable value to 48 when needed.

;all these coords are for fullscreen ableton:
;coordinates for MIDI clip things:
abletonMidiClipCoordToOpenSidePanelX := 24
abletonMidiClipCoordToOpenSidePanelY := 200
abletonMidiClipCoordToDoubleNotesX := 169
abletonMidiClipCoordToHalveNotesX := 74
abletonMidiClipCoordToHalveOrDoubleNotesY := 393
abletonMidiClipCoordToCloseSidePanelX := 121
abletonMidiClipCoordToCloseSidePanelY := 69
abletonMidiClipCoordToZoomHorizontallyX := 843
abletonMidiClipCoordToZoomHorizontallyY := 68
pixelCoordOfFirstBarlineInMidiClip4BarSectionX := 163	;these ones have different names, should rename all these so they all have similar naming convention.
pixelCoordOfLastBarlineInMidiClip4BarSectionX := 1904
pixelCoordOfRowJustAboveMidiClipY := 118
newBottomPixel := 1011			;should rename these two.
newTopPixel := 144

;coordinates for arrangement view things:
abletonTrackNamesX := 1499
abletonMiddleOfTrack1Y := 125
abletonMiddleOfMasterTrackDeviceViewClosedY := 1001
abletonMiddleOfMasterTrackDeviceViewOpenY := 746
abletonYDistanceBetweenTracksAtSmallestHeightInPixels := 23.74285714
abletonCoordToZoomArrangementViewHorizontallyX := 648
abletonCoordToZoomArrangementViewHorizontallyY := 63
abletonCoordTriangleToOpenLeftBrowserPanelX := 21
abletonCoordTriangleToOpenLeftBrowserPanelY := 56
abletonCoordToOpenMainSamplesFolderX := 30
abletonCoordToOpenMainSamplesFolderY := 659
abletonCoordForTrackVolumeX := 1688

;ableton top row button coords/blank space to place cursor utility:
abletonCoordToClickBPMSetterX := 129
abletonCoordToClickMetronomeX := 277
abletonCoordToClickBlankSpaceToPlaceCursorX := 485			;use 'abletonTopRowButtonsY' as the Y value, when using this coord in macros.
abletonCoordToClickPlayButtonX := 751
abletonCoordToClickStopButtonX := 782
abletonCoordToClickToggleLoopOnOff := 1135
abletonCoordToClickTopRowButtonsY := 22

;ableton bottom row coords:
abletonCoordToClickBottomRowY := 1058
abletonCoordToClickBottomRowDeviceViewSelectorX := 1838
abletonCoordToClickBottomRowBottomRightTriangleX := 1898
	;these two are for pixelgetcolor function:
	abletonBottomRightTriangleChangingPartX := 1894
	abletonBottomRightTriangleChangingPartY := 1061

;ableton device view coords:
abletonCoordToHotswapSimplerSampleX := 908
abletonCoordToHotswapSimplerSampleY := 924
abletonCoordToClickDeadSimpleGlobalTransposeKnobX := 97
abletonCoordToClickDeadSimpleGlobalTransposeKnobY := 886
abletonCoordToClickTransposeSimplerClick1X := 819
abletonCoordToClickTransposeSimplerClick1Y := 802
abletonCoordToClickTransposeSimplerClick2X := 808
abletonCoordToClickTransposeSimplerClick2Y := 948
abletonCoordToClickTransposeSimplerClick3X := 750
abletonCoordToClickTransposeSimplerClick3Y := 803

;other values:
sleepAmountForInputtingAndDuplicatingNotes := 30			;think this has failed once on 2ms in brief testing. 5ms should do it.
sleepAmountForAbletonBrowser := 500			;100ms is about the lowest value thats working consistently for this value atm [testing on multiple instrument randomizations in one macro]. 85ms failed at least once. so 100ms is good value for this for now.
numberOfDownArrowsForAbletonBrowserToDo := 0
abletonOpenDeviceViewSleep := 10			;10ms atm. this could probably be lowered to ~5ms or lower(?). or does it sometimes randomly fail even at 10ms?

;values that aren't good because no way of ensuring they're consistent with current ableton project(?):
currentTrackHeightInPixels := abletonYDistanceBetweenTracksAtSmallestHeightInPixels * 2

;temp values:
tempLocationToOpen4BarMidiClipX := 983
tempC3ValueForDrumsY := 569
tempLocationToProbablyClickArrangementLoopBraceX := 84
tempLocationToProbablyClickArrangementLoopBraceY := 82

;sample transpose arrays: (theres a VEDM2 array or three that aren't pasted here yet):
	;important note for owenJ808TransposeArray: derg 808 and thicc 808 are actually D#, not F# as they are labelled. just leaving it named the way it was though in the folder structure, anyway. can change it with macros and leave the filename the same, even if it is labelled wrong in the file names. (derg 808 is the 9 in this array atm, inbetween the 7's and 6's atm, the 'thicc 808' is the 9 shortly after that 9, atm.)
	owenJ808TransposeArray := [3,3,15,3,3,3,2,2,14,14,14,2,13,13,1,12,0,12,12,12,12,12,12,12,12,12,12,12,0,12,12,12,12,12,12,12,12,12,12,12,12,12,0,12,11,11,11,11,11,11,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,9,9,9,9,9,9,9,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,7,7,7,7,7,-5,7,7,7,7,7,7,7,7,7,7,9,6,6,6,6,6,6,9,5,5,-7,5,5,5,4,4,4,4,4,4,4,4]

	;these pitches have all been checked: they all resolve to the exact same frequency when all notes are played on C3 and pitched according to this array:
	vengeancePunchKickPitchArray := [3, 7, 5, 5, 6, 6, 6, 4, 6, 4, 5, 5, 5, 6, 2, 5, 0, 4, 8, 9, 4, 3, 3, 8, 4, 4, 5, 5, 5, 8, 4, 5, 7, 5, 4, 5, 4, 6, 6, 8, 6, 5, 6, 10, 5, 5, 6, 5, 4, 6, 6, 2, 7, 6, 6, 5, 8, 6, 5, 6, 6, 5, "invalid", 4, 6, 6, 6, 6, 7, 6, 5, 6, 6, 5, 5, 6, 5, 5, 7, 5, 7, 5, 6, 6, 8, 9, 5, 6, 5, 5, 5, 6, 6, 6, 3, 5, 5, 4, 8, 5, 6, 5, 8, 6, 6, 6, 4, 4, 5, 6, 4, 6, 1, 4, 4, 6, 8, 6, 5, 6, 5, 7, "invalid", 4]		;note there are 2 invalid options in here with no one fixed pitch.

;these depend on some values inputted somewhere above:
sizeOf1GridUnitInPixelsX := (pixelCoordOfLastBarlineInMidiClip4BarSectionX - pixelCoordOfFirstBarlineInMidiClip4BarSectionX) / newNumberOfPixelsX
sizeOf1GridUnitInPixelsY := (newBottomPixel - newTopPixel) / newNumberOfPixelsY
;****************************************************************************************************************************
;****************************************************************************************************************************
;****************************************************************************************************************************
/*
NOTES:
first 26 VEDM2 impacts, the impact always happens at 0ms in time. the 27th one is more like one that you'd want to put a track delay on.
ones that you would want a track delay on:
27, 35-40, 42, 44-50

delay amounts for VEDM2 impacts (in ms):
27: -193
35: -234
36: -234
37: -234
38: -234
39: -234
40: -234
42: -228
44: -228
45: -211
46: -194
47: -221
48: -228
49: -210
50: -221

delay times for VEDM2 reverse cymbals (in ms):
1: -3757
2: -1875
3: -1875
4: -2820
5: -2813
6: -1884
7:
8:
9:
10:
11:
12:
13:
14:
*/
currentInputLayer := "fourBarMidiClipMainLayer"
inputStorage := []
inputStorageRefined := []

gosub, gdipDrawFourBarGridOverlay
gosub, drawMainLayerIndicator
gosub, gdipDrawQwertyOrErgoIndicatorToScreen
gosub, gdipDrawClockToScreen
;update the clock every 3 seconds
SetTimer, gdipDrawClockToScreen, 3000, -2147483648		;-2147483648 is lowest possible thread priority. may need to increase this value
return			;end of auto-run section, all the above needs to run on script start

switchToFourBarMidiClipStuff:
	currentInputLayer := "fourBarMidiClipMainLayer"
	gosub, drawMainLayerIndicator
return
switchToArrangementViewStuff:
	currentInputLayer := "arrangementViewMainLayer"
	gosub, drawMainLayerIndicator
return
toggleBetweenNotTripletAndTripletGrid:
	if (notTripletOrTriplet == 0)				;currently not-triplet.
	{
		newNumberOfPixelsX := 48
		notTripletOrTriplet := 1				;now is triplet grid.
	}
	else if (notTripletOrTriplet == 1)			;currently triplet.
	{
		newNumberOfPixelsX := 64
		notTripletOrTriplet := 0				;now is not-triplet grid.
	}
return
return
firstPartOfCreatingGdipGUI(guiName)
{
	global
	; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
	Gui, %guiName%: -Caption +E0x20 +E0x80000 +LastFound +ToolWindow +OwnDialogs +AlwaysOnTop		;+E0x20 - this command makes gdip click-throughable, apparently.
	; Show the window
	Gui, %guiName%: Show, NA
	; Get a handle to this window we have created in order to update it later
	hwnd_%guiName% := WinExist()
	; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
	hbm_%guiName% := CreateDIBSection(gdipWidth, gdipHeight)
	; Get a device context compatible with the screen
	hdc_%guiName% := CreateCompatibleDC()
	; Select the bitmap into the device context
	obm_%guiName% := SelectObject(hdc_%guiName%, hbm_%guiName%)
	; Get a pointer to the graphics of the bitmap, for use with drawing functions
	G_%guiName% := Gdip_GraphicsFromHDC(hdc_%guiName%)
	; Set the smoothing mode to antialias = 4 to make shapes appear smoother (only used for vector drawing and filling)
	Gdip_SetSmoothingMode(G_%guiName%, 4)
	return
}
;below function used for gdip windows which don't need multiple things added to them and staying there. if you want to add things that stay on the screen over time over multiple function calls to gdip, don't use this function. although not using this function might be terrible for memory, or something. don't know how gdip works, really.
gdipCleanUpTrash(guiName)
{
	global
	; Select the object back into the hdc
	SelectObject(hdc_%guiName%, obm_%guiName%)
	; Now the bitmap may be deleted
	DeleteObject(hbm_%guiName%)
	; Also the device context related to the bitmap may be deleted
	DeleteDC(hdc_%guiName%)
	; The graphics may now be deleted
	Gdip_DeleteGraphics(G_%guiName%)
	return
}
gdipCleanUpTrashAndDestroyWindow(guiName)
{
	global
	gdipCleanUpTrash(guiName)			;this line only works if guiName is NOT enclosed in %%'s. you can test this by attempting to redraw things to a GUI window that has been 'made-inaccessible/uneditable' by this line, with and without enclosing % signs.
	gui %guiName%: destroy
}
gdipDrawQwertyOrErgoIndicatorToScreen:
	firstPartOfCreatingGdipGUI("qwertyOrErgoIndicator")
	if (qwertyOrErgo == 0)
	{
		pBrush := Gdip_BrushCreateSolid(0x99FFFF00)		;yellow if qwerty
	}
	else
	{
		pBrush := Gdip_BrushCreateSolid(0x99FF00FF)		;purple if ergo
	}
	Gdip_FillRectangle(G_qwertyOrErgoIndicator, pBrush, 1340, 0, 100, 40)
	UpdateLayeredWindow(hwnd_qwertyOrErgoIndicator, hdc_qwertyOrErgoIndicator, 0, 0, gdipWidth, gdipHeight)
	;gdipCleanUpTrashAndDestroyWindow("qwertyOrErgoIndicator")
	gdipCleanUpTrash("qwertyOrErgoIndicator")
return
drawMainLayerIndicator:			;should shorten all the code in here.
	if (whichMainLayerIndicator == 0)		;4 bar midi clip main layer 64 options
	{
		firstPartOfCreatingGdipGUI("mainLayerIndicator")
		if (isAutoVelocityOn == 0)							;auto-velocity off
			pBrush := Gdip_BrushCreateSolid(0xFFFFFF00)		;yellow
		else if (isAutoVelocityOn == 1)						;auto-velocity on
			pBrush := Gdip_BrushCreateSolid(0xFF0000FF)		;blue
		/*
	newBottomPixel := 1011			;should rename these two.
	newTopPixel := 144
	pixelCoordOfFirstBarlineInMidiClip4BarSectionX := 196	;these ones have different names, should rename all these so they all have similar naming convention.
	pixelCoordOfLastBarlineInMidiClip4BarSectionX := 1871
		*/
		Gdip_FillRectangle(G_mainLayerIndicator, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX - 40, newTopPixel - 40, 20, newBottomPixel - newTopPixel + 80)			;left side
		Gdip_FillRectangle(G_mainLayerIndicator, pBrush, pixelCoordOfLastBarlineInMidiClip4BarSectionX + 20, newTopPixel - 40, 20, newBottomPixel - newTopPixel + 80)		;right side
		Gdip_FillRectangle(G_mainLayerIndicator, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX - 40, newTopPixel - 40, pixelCoordOfLastBarlineInMidiClip4BarSectionX + 40, 20)		;top
		Gdip_FillRectangle(G_mainLayerIndicator, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX - 40, newBottomPixel + 20, pixelCoordOfLastBarlineInMidiClip4BarSectionX + 40, 20)		;bottom
		Gdip_DeleteBrush(pBrush)
		UpdateLayeredWindow(hwnd_mainLayerIndicator, hdc_mainLayerIndicator, 0, 0, gdipWidth, gdipHeight)
		;gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrash("mainLayerIndicator")
	}
	else if (whichMainLayerIndicator == 1)		;4 bar midi clip main layer 48 options (is this any different than 64 options though?)
	{
	}
	else if (whichMainLayerIndicator == 2)		;arrangment view main layer
	{
		firstPartOfCreatingGdipGUI("mainLayerIndicator")
		if (isAutoVelocityOn == 0)							;auto-velocity off
			pBrush := Gdip_BrushCreateSolid(0xFFFFFF00)		;yellow
		else if (isAutoVelocityOn == 1)						;auto-velocity on
			pBrush := Gdip_BrushCreateSolid(0xFF0000FF)		;blue
		/*
	newBottomPixel := 1011			;should rename these two.
	newTopPixel := 144
	pixelCoordOfFirstBarlineInMidiClip4BarSectionX := 196	;these ones have different names, should rename all these so they all have similar naming convention.
	pixelCoordOfLastBarlineInMidiClip4BarSectionX := 1871
		*/
		Gdip_FillRectangle(G_mainLayerIndicator, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX - 40, newTopPixel - 40, 20, newBottomPixel - newTopPixel + 80)			;left side
		Gdip_FillRectangle(G_mainLayerIndicator, pBrush, pixelCoordOfLastBarlineInMidiClip4BarSectionX + 20, newTopPixel - 40, 20, newBottomPixel - newTopPixel + 80)		;right side
		Gdip_FillRectangle(G_mainLayerIndicator, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX - 40, newTopPixel - 40, pixelCoordOfLastBarlineInMidiClip4BarSectionX + 40, 20)		;top
		Gdip_FillRectangle(G_mainLayerIndicator, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX - 40, newBottomPixel + 20, pixelCoordOfLastBarlineInMidiClip4BarSectionX + 40, 20)		;bottom
		Gdip_DeleteBrush(pBrush)
		UpdateLayeredWindow(hwnd_mainLayerIndicator, hdc_mainLayerIndicator, 0, 0, gdipWidth, gdipHeight)
		;gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrash("mainLayerIndicator")
	}
return
gdipDrawClockToScreen:
	firstPartOfCreatingGdipGUI("clock")
	FormatTime, systemTimeString
	trimmedSystemTimeString := SubStr(systemTimeString, 1, 8)
	; We can specify the font to use. Here we use Arial as most systems should have this installed
	Font = Arial
	; Next we can check that the user actually has the font that we wish them to use
	; If they do not then we can do something about it. I choose to give a wraning and exit!
	If !Gdip_FontFamilyCreate(Font)
	{
	   MsgBox, 48, Font error!, The font you have specified does not exist on the system
	   ExitApp
	}
	; There are a lot of things to cover with the function Gdip_TextToGraphics
	; The 1st parameter is the graphics we wish to use (our canvas)
	; The 2nd parameter is the text we wish to write. It can include new lines `n
	; The 3rd parameter, the options are where all the action takes place...
	; You can write literal x and y coordinates such as x20 y50 which would place the text at that position in pixels
	; or you can include the last 2 parameters (Width and Height of the Graphics we will use) and then you can use x10p
	; which will place the text at 10% of the width and y30p which is 30% of the height
	; The same percentage marker may be used for width and height also, so w80p makes the bounding box of the rectangle the text
	; will be written to 80% of the width of the graphics. If either is missed (as I have missed height) then the height of the bounding
	; box will be made to be the height of the graphics, so 100%
	; Any of the following words may be used also: Regular,Bold,Italic,BoldItalic,Underline,Strikeout to perform their associated action
	; To justify the text any of the following may be used: Near,Left,Centre,Center,Far,Right with different spelling of words for convenience
	; The rendering hint (the quality of the antialiasing of the text) can be specified with r, whose values may be:
	; SystemDefault = 0
	; SingleBitPerPixelGridFit = 1
	; SingleBitPerPixel = 2
	; AntiAliasGridFit = 3
	; AntiAlias = 4
	; The size can simply be specified with s
	; The colour and opacity can be specified for the text also by specifying the ARGB as demonstrated with other functions such as the brush
	; So cffff0000 would make a fully opaque red brush, so it is: cARGB (the literal letter c, follwed by the ARGB)
	; The 4th parameter is the name of the font you wish to use
	; As mentioned previously, you don not need to specify the last 2 parameters, the width and height, unless
	; you are planning on using the p option with the x,y,w,h to use the percentage
	Options = x70p y1p w80p cff000000 r4 s20 Underline Italic
	Gdip_TextToGraphics(G_clock, trimmedSystemTimeString, Options, Font, gdipWidth, gdipHeight)
	UpdateLayeredWindow(hwnd_clock, hdc_clock, 0, 0, gdipWidth, gdipHeight)
	;gdipCleanUpTrashAndDestroyWindow("clock")
	gdipCleanUpTrash("clock")
return
Exit:
; gdi+ may now be shutdown on exiting the program
Gdip_Shutdown(pToken)
ExitApp
Return
GdipShadeWholeScreen(colorVal)			;can this be merged with other gdip code/shortened?
{
	global		;this line is needed. i think is needed because a lot of these GDIP gui references are to global variables. putting this 'global' keyword i think gives the function access to all of them. or however many there are, maybe only 1. maybe 10. dont know.
	; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
	firstPartOfCreatingGdipGUI("shadeWholeScreen")
	pBrush := Gdip_BrushCreateSolid(colorVal)
	Gdip_FillRectangle(G_shadeWholeScreen, pBrush, 0, 0, 120, 1080)
	Gdip_DeleteBrush(pBrush)
	; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
	; So this will position our gui at (0,0) with the Width and Height specified earlier
	UpdateLayeredWindow(hwnd_shadeWholeScreen, hdc_shadeWholeScreen, 0, 0, gdipWidth, gdipHeight)
	;gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")
	gdipCleanUpTrash("shadeWholeScreen")
	return
}
gdipDrawFourBarGridOverlay:
	xOffset := -6			;this var is so that note start- and end- points are visible; not obfuscated by the gridlines.
	firstPartOfCreatingGdipGUI("fourBarGridOverlay")
	pBrush := Gdip_BrushCreateSolid(0xFFFFFFFF)		;white
	loopvar := 1
	Loop, 15		;15 vertical lines to separate 4 bars
	{
		if (loopvar == 4 || loopvar == 8 || loopvar == 12)
		{
			xToDrawAt := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + (loopvar * ((pixelCoordOfLastBarlineInMidiClip4BarSectionX - pixelCoordOfFirstBarlineInMidiClip4BarSectionX) / 64) * 4) - 4 + xOffset
			yToDrawAt := newBottomPixel - (sizeOf1GridUnitInPixelsY * newNumberOfPixelsY)
			Gdip_FillRectangle(G_fourBarGridOverlay, pBrush, xToDrawAt, yToDrawAt, 8, sizeOf1GridUnitInPixelsY * newNumberOfPixelsY)
		}
		else
		{
			xToDrawAt := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + (loopvar * ((pixelCoordOfLastBarlineInMidiClip4BarSectionX - pixelCoordOfFirstBarlineInMidiClip4BarSectionX) / 64) * 4) - 2 + xOffset
			yToDrawAt := newBottomPixel - (sizeOf1GridUnitInPixelsY * newNumberOfPixelsY)
			Gdip_FillRectangle(G_fourBarGridOverlay, pBrush, xToDrawAt, yToDrawAt, 4, sizeOf1GridUnitInPixelsY * newNumberOfPixelsY)
		}
		loopvar ++
	}
	loopvar := 1
	Loop, 8			; atm theres 8 bars. there were 9. probably hasn't caused any bugs changing this over though.
	{
		if (loopvar == 3 || loopvar == 6)
		{
			yToDrawAt := newBottomPixel - (loopvar * sizeOf1GridUnitInPixelsY * 7) - 4		;the 7 here is caus its 4 pixels per guidebar
			Gdip_FillRectangle(G_fourBarGridOverlay, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX + xOffset, yToDrawAt, ((pixelCoordOfLastBarlineInMidiClip4BarSectionX - pixelCoordOfFirstBarlineInMidiClip4BarSectionX) / 64) * newNumberOfPixelsX, 8)
		}
		else
		{
			yToDrawAt := newBottomPixel - (loopvar * sizeOf1GridUnitInPixelsY * 7) - 2		;the 7 here is caus its 4 pixels per guidebar
			Gdip_FillRectangle(G_fourBarGridOverlay, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX + xOffset, yToDrawAt, ((pixelCoordOfLastBarlineInMidiClip4BarSectionX - pixelCoordOfFirstBarlineInMidiClip4BarSectionX) / 64) * newNumberOfPixelsX, 4)
		}
		loopvar ++
	}
	;drawing the inside black bars:
	pBrush := Gdip_BrushCreateSolid(0xFF000000)		;black
	loopvar := 1
	Loop, 15		;15 vertical lines to separate 4 bars
	{
		if (loopvar == 4 || loopvar == 8 || loopvar == 12)
		{
			xToDrawAt := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + (loopvar * ((pixelCoordOfLastBarlineInMidiClip4BarSectionX - pixelCoordOfFirstBarlineInMidiClip4BarSectionX) / 64) * 4) - 3 + xOffset
			yToDrawAt := newBottomPixel - (sizeOf1GridUnitInPixelsY * newNumberOfPixelsY)
			Gdip_FillRectangle(G_fourBarGridOverlay, pBrush, xToDrawAt, yToDrawAt, 6, sizeOf1GridUnitInPixelsY * newNumberOfPixelsY)
		}
		else
		{
			xToDrawAt := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + (loopvar * ((pixelCoordOfLastBarlineInMidiClip4BarSectionX - pixelCoordOfFirstBarlineInMidiClip4BarSectionX) / 64) * 4) - 1 + xOffset
			yToDrawAt := newBottomPixel - (sizeOf1GridUnitInPixelsY * newNumberOfPixelsY)
			Gdip_FillRectangle(G_fourBarGridOverlay, pBrush, xToDrawAt, yToDrawAt, 2, sizeOf1GridUnitInPixelsY * newNumberOfPixelsY)
		}
		loopvar ++
	}
	loopvar := 1
	Loop, 8			; atm theres 8 bars. there were 9. probably hasn't caused any bugs changing this over though.
	{
		if (loopvar == 3 || loopvar == 6)
		{
			yToDrawAt := newBottomPixel - (loopvar * sizeOf1GridUnitInPixelsY * 7) - 3		;the 7 here is caus its 4 pixels per guidebar
			Gdip_FillRectangle(G_fourBarGridOverlay, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX + xOffset, yToDrawAt, ((pixelCoordOfLastBarlineInMidiClip4BarSectionX - pixelCoordOfFirstBarlineInMidiClip4BarSectionX) / 64) * newNumberOfPixelsX, 6)		;width of 4 for the black bars.
		}
		else
		{
			yToDrawAt := newBottomPixel - (loopvar * sizeOf1GridUnitInPixelsY * 7) - 1		;the 7 here is caus its 4 pixels per guidebar
			Gdip_FillRectangle(G_fourBarGridOverlay, pBrush, pixelCoordOfFirstBarlineInMidiClip4BarSectionX + xOffset, yToDrawAt, ((pixelCoordOfLastBarlineInMidiClip4BarSectionX - pixelCoordOfFirstBarlineInMidiClip4BarSectionX) / 64) * newNumberOfPixelsX, 2)		;width of 4 for the black bars.
		}
		loopvar ++
	}
	Gdip_DeleteBrush(pBrush)
	UpdateLayeredWindow(hwnd_fourBarGridOverlay, hdc_fourBarGridOverlay, 0, 0, gdipWidth, gdipHeight)
	;gdipCleanUpTrashAndDestroyWindow("fourBarGridOverlay")
	gdipCleanUpTrash("fourBarGridOverlay")
return
home::
;this key used to switch between ergo and qwerty
if (qwertyOrErgo == 0)
	qwertyOrErgo := 1
else
	qwertyOrErgo := 0
gosub, gdipDrawQwertyOrErgoIndicatorToScreen
return
esc::
	ExitApp
return
t::		;left hand
	%currentInputLayer%(1)			;same on both qwerty and ergo for t, r, e. [these are the only 3 values that are the same on both atm]
return
r::
	%currentInputLayer%(2)
return
e::
	%currentInputLayer%(3)
return
g::
	if (qwertyOrErgo == 0)	;do nothing on qwerty
	{}
	else
		%currentInputLayer%(4)
return
f::
	if (qwertyOrErgo == 0)
		%currentInputLayer%(4)
	else
		%currentInputLayer%(5)
return
d::
	if (qwertyOrErgo == 0)
		%currentInputLayer%(5)
	else
		%currentInputLayer%(6)
return
s::
	if (qwertyOrErgo == 0)
		%currentInputLayer%(6)
	;do nothing on ergo
return
b::
	if (qwertyOrErgo == 0)		;do nothing on qwerty
	{}
	else
		%currentInputLayer%(7)
return
v::
	if (qwertyOrErgo == 0)		;do nothing on qwerty
	{}
	else
		%currentInputLayer%(8)
return
c::
	if (qwertyOrErgo == 0)
		%currentInputLayer%(7)
	else
		%currentInputLayer%(9)
return
x::
	if (qwertyOrErgo == 0)
		%currentInputLayer%(8)
	;do nothing on ergo
return
z::
	if (qwertyOrErgo == 0)
		%currentInputLayer%(9)
	;do nothing on ergo
return
y::			;right hand
	if (qwertyOrErgo == 0)
	{}
	else
		%currentInputLayer%(10)
return
u::
	if (qwertyOrErgo == 0)
	{}
	else
		%currentInputLayer%(11)
return
i::
	if (qwertyOrErgo == 0)
		%currentInputLayer%(10)
	else
		%currentInputLayer%(12)
return
o::
	if (qwertyOrErgo == 0)
		%currentInputLayer%(11)
	;do nothing on ergo
return
p::
	if (qwertyOrErgo == 0)
		%currentInputLayer%(12)
	;do nothing on ergo
return
h::
	if (qwertyOrErgo == 0)
	{}
	else
		%currentInputLayer%(13)
return
j::
	if (qwertyOrErgo == 0)
	{}
	else
		%currentInputLayer%(14)
return
k::
	if (qwertyOrErgo == 0)
		%currentInputLayer%(13)
	else
		%currentInputLayer%(15)
return
l::
	if (qwertyOrErgo == 0)
		%currentInputLayer%(14)
	;do nothing on ergo

return
`;::
	if (qwertyOrErgo == 0)
		%currentInputLayer%(15)
	;do nothing on ergo
return
n::
	if (qwertyOrErgo == 0)
	{}
	else
		%currentInputLayer%(16)
return
m::
	if (qwertyOrErgo == 0)
	{}
	else
		%currentInputLayer%(17)
return
,::
	if (qwertyOrErgo == 0)
		%currentInputLayer%(16)
	;do nothing on ergo
return
.::
	if (qwertyOrErgo == 0)
		%currentInputLayer%(17)
	;do nothing on ergo
return
/::
	if (qwertyOrErgo == 0)
		%currentInputLayer%(18)
	;do nothing on ergo
return
NumpadHome::
	if (qwertyOrErgo == 0)
	{}
	else
		%currentInputLayer%(18)
return
Space::
%currentInputLayer%(19)			;putting space on 19 for now. its the same for qwerty and ergo keyboard layouts.
return
/*
unused: but shows the layout of each chain so keeping:
gimpRectangleChainStepArray := [1,0,1,0,1,0,1,0,1,0,1,0,1,0,1]
gimpHorizontalBarChainStepArray := [1,0,1,0,1,0,1,0,1,0,1,0]
gimpVerticalBarChainStepArray := [1,0,1,0,1,0,1,0,1,0,1,0]
gimp1PixelChainStepArray := [1,0,1,0,1,0,1,0,1]
*/
clearInputStorageArrays:
	inputStorage := []
	inputStorageRefined := []
return
incorrectSequenceInputted:			;THIS FUNCTION USED TO DESELECT ALL CURRENTLY-SELECTED NOTES, BY CLICKING ON A COORDINATE SPOT... left the block of code, just would need to remove the blockcomment start and end symbols and it would run as before, probably.
/*
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	if (in4BarSectionOrFull256OrNotInMidiClip == 0)				;currently in 4bar section.
	{
		mousemove, pixelCoordOfFirstBarlineInMidiClip4BarSectionX, pixelCoordOfRowJustAboveMidiClipY			;click cursor to 1:1
		Click		;this click deselects any currently-selected notes
	}
	else if (in4BarSectionOrFull256OrNotInMidiClip == 1)		;currently in full 256bar section.
	{
		mousemove, pixelCoordOfFirstBarlineInMidiClipFull256BarsX, pixelCoordOfRowJustAboveMidiClipY			;click cursor to 1:1
		Click		;this click deselects any currently-selected notes
	}
	else if (in4BarSectionOrFull256OrNotInMidiClip == 2)		;currently NOT in MIDI editor window.
	{
		;do nothing.			;maybe this should do something.
	}
*/
	GdipShadeWholeScreen("0x66ff0000")									;red
return
pushABunchOfKeysUpToTryPreventBugs:			;maybe should add stuff like '{Win up}' or ralt, rshift, lshift, etc.... but checked atm.
;does this add a lot of delay to the script, since it runs every time mainLayer happens?
	suspend, on
	send, {ctrl up}{shift up}{alt up}{lbutton up}{rbutton up}
	suspend, off
return
fourBarMidiClipMainLayer(inputNumber)
{
	global
		;putting this here atm to see if it prevents bugs:
		;does this add a lot of delay to the script, since it runs every time mainLayer happens(?):
		;does it cause bugs as well(?):
	;gosub, pushABunchOfKeysUpToTryPreventBugs
	gosub, clearInputStorageArrays
	gosub, drawMainLayerIndicator
	if (inputNumber == 1)
	{
		currentInputLayer := "pixel1Press1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")			;put this line on every layer that redirects away from mainLayer.
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 2)
	{
		currentInputLayer := "rectangleSelectPress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 3)
	{
		currentInputLayer := "removeNotePress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 4)
	{
		currentInputLayer := "horizontalNotePress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 5)
	{
		currentInputLayer := "verticalNotePress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 6)
	{
		currentInputLayer := "changeInstrumentPress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 7)
	{
		currentInputLayer := "editCurrentInstrumentAudioFXPress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 8)							;blank comment
	{
		currentInputLayer := "resizeEndOfNotePress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 9)
	{
		currentInputLayer := "moreOptions1Press1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 10)
	{
		currentInputLayer := "specialNoteInputOptionsPress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 11)							;blank comment
	{
		currentInputLayer := "abletonPlayStopOptionsPress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 12)
	{
		gosub, switchToArrangementViewStuff
		;gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")		;this line not needed here?
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 13)
	{
		currentInputLayer := "moreOptions2Press1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 14)
	{
		currentInputLayer := "moreOptions3Press1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 15)
	{
		currentInputLayer := "randomizationOptionsPress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 16)
	{
		currentInputLayer := "moreOptions4Press1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 18)			;blank comment
	{
		currentInputLayer := "abletonLoadSaveOptionsPress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 19)
	{
		;do nothing
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
arrangementViewMainLayer(inputNumber)				;UNFINISHED LAYER.
{
	global
		;putting this here atm to see if it prevents bugs:
		;does this add a lot of delay to the script, since it runs every time mainLayer happens(?):
		;does it cause bugs as well(?):
	;gosub, pushABunchOfKeysUpToTryPreventBugs
	gosub, clearInputStorageArrays
	gosub, drawMainLayerIndicator
	if (inputNumber == 1)
	{
		currentInputLayer := "pixel1Press1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")			;put this line on every layer that redirects away from mainLayer.
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 2)
	{
		currentInputLayer := "rectangleSelectPress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 3)
	{
		currentInputLayer := "removeNotePress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 4)
	{
		currentInputLayer := "horizontalNotePress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 5)
	{
		currentInputLayer := "verticalNotePress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 6)
	{
		currentInputLayer := "changeInstrumentPress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 7)
	{
		currentInputLayer := "editCurrentInstrumentAudioFXPress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 8)							;blank comment
	{
		currentInputLayer := "resizeEndOfNotePress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 9)
	{
		currentInputLayer := "moreOptions1Press1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 10)
	{
		currentInputLayer := "specialNoteInputOptionsPress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 11)							;blank comment
	{
		currentInputLayer := "abletonPlayStopOptionsPress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 12)
	{
		;gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")		;this line not needed here?
		;should this one switch into 4 bar midi clip??
	}
	else if (inputNumber == 13)
	{
		currentInputLayer := "moreOptions2Press1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 14)
	{
		currentInputLayer := "moreOptions3Press1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 18)							;blank comment
	{
		currentInputLayer := "abletonLoadSaveOptionsPress1"
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		gdipCleanUpTrashAndDestroyWindow("shadeWholeScreen")			;putting this line here for now.
	}
	else if (inputNumber == 19)
	{
		;do nothing
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
moreOptions1Press1(inputNumber)			;rh
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 10)
	{
		currentInputLayer := "BPMTyperMain"
	}
	else if (inputNumber == 11)			;a click to deselect all currently selected notes and return marker to 1:1:1
	{
		tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
		suspend, on
		send, {esc} ;gets rid of highlighted region before click (highlighted region can block the click from deselecting the region if the region starts at 1:1:1, where the click location happens [possibly also if the region ended at 1:1:1 but this seems unlikely to happen]).
		mousemove, pixelCoordOfFirstBarlineInMidiClip4BarSectionX, pixelCoordOfRowJustAboveMidiClipY
		click					;click here to deselect any notes and return midi cursor to 1:1:1
		suspend, off
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 12)			;key changer
	{
		currentInputLayer := "keyChangerPress1"
	}
	else if (inputNumber == 13)			;undo
	{
		;tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip			;commented this line out, doesn't seem necessary for undo.
		suspend, on
		send, {ctrl down}z{ctrl up}
		suspend, off
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 14)			;redo
	{
		;tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip			;commented this line out, doesn't seem necessary for redo.
		suspend, on
		send, {ctrl down}y{ctrl up}
		suspend, off
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 15)			;play scale
	{
		;tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip			;commented this line out, doesn't seem necessary for redo.
		suspend, on
		send, {ctrl down}y{ctrl up}
		suspend, off
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 16)			;halve selected note lengths
	{
		mousemove, abletonMidiClipCoordToOpenSidePanelX, abletonMidiClipCoordToOpenSidePanelY
		click 2					;open ableton midi side panel
		mousemove, abletonMidiClipCoordToHalveNotesX, abletonMidiClipCoordToHalveOrDoubleNotesY
		click					;double selected note lengths
		mousemove, abletonMidiClipCoordToCloseSidePanelX, abletonMidiClipCoordToCloseSidePanelY
		click 2					;close ableton midi side panel
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 17)			;double selected note lengths
	{
		mousemove, abletonMidiClipCoordToOpenSidePanelX, abletonMidiClipCoordToOpenSidePanelY
		click 2					;open ableton midi side panel
		mousemove, abletonMidiClipCoordToDoubleNotesX, abletonMidiClipCoordToHalveOrDoubleNotesY
		click					;double selected note lengths
		mousemove, abletonMidiClipCoordToCloseSidePanelX, abletonMidiClipCoordToCloseSidePanelY
		click 2					;close ableton midi side panel
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 18) ;remove all notes from current 4-bar region.
	{
		gosub, removeAllNotesFromCurrent4BarRegion
		gosub, switchToFourBarMidiClipStuff
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
moveFrom4BarMidiClipToArrangementView:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	suspend, on
	mousemove, abletonCoordToClickBottomRowBottomRightTriangleX, abletonCoordToClickBottomRowY
	click		;single click moves from midi clip view to arrangement view.
	suspend, off
return
removeAllNotesFromCurrent4BarRegion:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	suspend, on
	MouseClickDrag, left, pixelCoordOfFirstBarlineInMidiClip4BarSectionX, pixelCoordOfRowJustAboveMidiClipY, pixelCoordOfLastBarlineInMidiClip4BarSectionX, pixelCoordOfRowJustAboveMidiClipY + 1
	send, {enter}{delete}		;select all the notes from braces into active-selection in ableton, then delete them.
	suspend, off
return
moreOptions2Press1(inputNumber)			;lh
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	;input 1 is unused at the moment.
	else if (inputNumber == 2)			;select/deselect one note
	{
		currentInputLayer := "selectOrDeselectOneNotePress1"
	}
	else if (inputNumber == 3)			;resize start of note
	{
		currentInputLayer := "resizeStartOfNotePress1"
	}
	else if (inputNumber == 4)			;shift velocity of selected notes down by X amount of velocity values
	{
		currentInputLayer := "shiftVelocityOfSelectedNotesDownByZPress1"
	}
	else if (inputNumber == 5)			;shift velocity of selected notes up by X amount of velocity values
	{
		currentInputLayer := "shiftVelocityOfSelectedNotesUpByZPress1"
	}
	else if (inputNumber == 6)			;move 4bar section options 1
	{
		currentInputLayer := "move4BarSectionOptions1Press1"
	}
	else if (inputNumber == 7)			;move 4bar section options 2
	{
		currentInputLayer := "move4BarSectionOptions2Press1"			;haven't made these layers yet, theyre for bars above barnumber 126, i think.
	}
	else if (inputNumber == 8)			;copy selected notes (use only if in 4bar section of midi clip).
	{
		;tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip		;commented this line out. doesn't seem necessary for copy notes macro, with no mouse macros being performed.
		suspend, on
		send, {ctrl down}c{ctrl up}
		suspend, off
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 9)			;paste notes to location in 4bar midi clip (use only if in 4bar section of midi clip).
	{
		currentInputLayer := "pasteNotesPress1"
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
moreOptions3Press1(inputNumber)			;lh
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 1)			;move selected notes to new pitch.
	{
		currentInputLayer := "moveSelectedNotesToNewPitchPress1"
	}
	else if (inputNumber == 2)			;zero selected notes.
	{
		;tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip		;commented out this line. doesn't seem necessary here
		suspend, on
		send, 0				;does this always work?
		suspend, off
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 5)			;save ableton file
	{
		currentInputLayer := "saveFileEnsurerPress1"
	}
	else if (inputNumber == 6)			;load ableton file
	{
		currentInputLayer := "loadFileEnsurerPress1"
	}
	else if (inputNumber == 7)			;new ableton file
	{
		currentInputLayer := "newFileEnsurerPress1"
	}
	/*
	;old:
	else if (inputNumber == 8)			;copy and paste selected notes and move up one semitone [for further movement](use only if in 4bar section of midi clip).
	{
		;tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip		;commented this line out. doesn't seem necessary for copy notes macro, with no mouse macros being performed.
		suspend, on
		send, {ctrl down}cv{ctrl up}{up}
		suspend, off
		gosub, switchToFourBarMidiClipStuff
	}
	*/
	else if (inputNumber == 8)			;move notes up one octave
	{
		;tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip		;commented this line out. doesn't seem necessary for copy notes macro, with no mouse macros being performed.
		suspend, on
		send, {shift down}{up}{shift up}
		suspend, off
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 9)			;move notes down one octave
	{
		;tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip		;commented this line out. doesn't seem necessary for copy notes macro, with no mouse macros being performed.
		suspend, on
		send, {shift down}{down}{shift up}
		suspend, off
		gosub, switchToFourBarMidiClipStuff
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
moreOptions4Press1(inputNumber)			;lh
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 1)			;move from 4bar midi clip view to arrangement view. IMPORTANT NOTE: there's probably a better way to do this.
	{
		gosub, moveFrom4BarMidiClipToArrangementView
		gosub, switchToFourBarMidiClipStuff
		;in the future, the above line should probably be something more like the below line:
		;gosub, switchToArrangementViewStuff
	}
	else if (inputNumber == 2)			;move from arrangement view to specified temp-4bar-midiclip view of certain track. IMPORTANT NOTE: there's probably a better way to do this.
	{
		currentInputLayer := "moveFromArrangementViewToSpecifiedTemp4BarMidiClipPress1"
	}
	else if (inputNumber == 3)			;look at certain instrument device chain. IMPORTANT NOTE: there's probably a better way to do this.
	{
		currentInputLayer := "lookAtCertainInstrumentDeviceChainPress1"
	}
	else if (inputNumber == 4)			;set all instruments to -6dB
	{
		gosub, setAllInstrumentsToNegative6dB
		gosub, switchToFourBarMidiClipStuff
		;in the future, the above line should probably be something more like the below line:
		;gosub, switchToArrangementViewStuff
	}
	else if (inputNumber == 5)			;input a 16th at C3 [drum note input option]
	{
		currentInputLayer := "inputA16thAtC3Press1"
	}
	else if (inputNumber == 6)			;remove a 16th at C3 [drum note input option]
	{
		currentInputLayer := "removeA16thAtC3Press1"
	}
	else if (inputNumber == 7)			;C#3-C3 box select
	{
		currentInputLayer := "c3BoxSelectPress1"
	}
	else if (inputNumber == 9)			;limited-range edit track volume of a specified track, with possible values ranging from -0.1 to -12.6
	{
		currentInputLayer := "limitedRangeEditTrackVolumeOfSpecifiedTrackPress1"
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
randomizationOptionsPress1(inputNumber) ;lh
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 1) ;randomize certain instrument (instrument track number is first inputted).
	{
		currentInputLayer := "randomizeCertainInstrumentSamplePress1"		;these layers handle what mainlayer will be?? sort of... not if you do the layers halfway or incorrectly maybe? need to check. need to change the mainLayer in this code whenever a macro is sent to ableton that automatically changes the main layer maybe... or need to build things in to customly change the main layer if there's any bugs or incorrectly-inputted-macros-to-wrong-area-of-ableton-interface.
	}
	else if (inputNumber == 2) ;randomize all applicable instruments.
	{
		randomizeCertainInstrumentSample(2)			;randomize 808
		randomizeCertainInstrumentSample(3)			;randomize kick
		randomizeCertainInstrumentSample(4)			;randomize snare
		randomizeCertainInstrumentSample(5)			;randomize clap
		randomizeCertainInstrumentSample(6)			;randomize rim
		;putting this stuff here so arrangement zooms so 4bar clip fills screen after the above functions are finished (opening the browser(?) seems to change the arrangement zoom(?) so that the 4bar clip is zoomed out and on the left side of the screen(?), so this is to fix that quickly, remove/rewrite this code/put this code somewhere else later:
		tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
		suspend, on
		mousemove, tempLocationToProbablyClickArrangementLoopBraceX, tempLocationToProbablyClickArrangementLoopBraceY
		click		;select the loop brace (probably - just temp location clicking on atm).
		mousemove, abletonCoordToZoomArrangementViewHorizontallyX, abletonCoordToZoomArrangementViewHorizontallyY
		click 2		;zoom so loop brace fills the arrangement view.
		gosub, switchToFourBarMidiClipStuff
		suspend, off
	}
	else if (inputNumber == 3) ;randomize BPM.
	{
		random, tempRandomBPM, 80, 199
		changeBPM(tempRandomBPM)
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 4) ;randomize key of melodic instruments.
	{
		random, tempRandomKey, 0, -11
		changeKeyOfInstruments(tempRandomKey)
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 5) ;remove all notes from 4bar section for all 6 current-topmost-instruments, randomize bpm, randomize key, randomize samples for instruments 2-6, endpoints included. for instruments numbered 3 and 4 (kick and snare), it also inputs typical trap instrument pattern for these instruments, with autoVelocity value specified at start of this script.
	{
		;THIS FUNCTION SHOULD WORK FROM EITHER MIDICLIP VIEW OR ARRANGEMENT VIEW.
	;remove all notes from 4bar clip for each instrument:
		tempTrackNumberVar := 1
		Loop, 6
		{
			mousemove, abletonCoordToClickBottomRowDeviceViewSelectorX, abletonCoordToClickBottomRowY
			click		;single click moves from any-view to arrangement-view.
			;sleep, 150
			moveFromArrangementViewToSpecifiedTemp4BarMidiClip(tempTrackNumberVar)
			;sleep, 150
			gosub, removeAllNotesFromCurrent4BarRegion
			;sleep, 150
			if (tempTrackNumberVar == 3) ;kick
			{
				gosub, inputTypicalTrapKickPatternInCurrent4BarMidiClip
			}
			else if (tempTrackNumberVar == 4) ;snare
			{
				gosub, inputTypicalTrapSnarePatternInCurrent4BarMidiClip
			}
			;sleep, 150
			;gosub, moveFrom4BarMidiClipToArrangementView			;old way had this line, and no mousemove->click at start of loop.
			tempTrackNumberVar ++
		}
		;sleep, 150
	;randomize bpm:
		random, tempRandomBPM, 80, 199
		changeBPM(tempRandomBPM)
		;sleep, 150
	;randomize key:
		random, tempRandomKey, 0, -11
		changeKeyOfInstruments(tempRandomKey)			;does this function always work when called from any ableton screen-state???
		;sleep, 150
		;randomize instruments 2-6:
		randomizeCertainInstrumentSample(2)			;randomize 808
		;sleep, 100
		randomizeCertainInstrumentSample(3)			;randomize kick
		;sleep, 100
		randomizeCertainInstrumentSample(4)			;randomize snare
		;sleep, 100
		randomizeCertainInstrumentSample(5)			;randomize clap
		;sleep, 100
		randomizeCertainInstrumentSample(6)			;randomize rim
		;sleep, 100
		;putting this stuff here so arrangement zooms so 4bar clip fills screen after the above functions are finished (opening the browser(?) seems to change the arrangement zoom(?) so that the 4bar clip is zoomed out and on the left side of the screen(?), so this is to fix that quickly, remove/rewrite this code/put this code somewhere else later:
		tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
		suspend, on
		mousemove, tempLocationToProbablyClickArrangementLoopBraceX, tempLocationToProbablyClickArrangementLoopBraceY
		click		;select the loop brace (probably - just temp location clicking on atm).
		;sleep, 100
		mousemove, abletonCoordToZoomArrangementViewHorizontallyX, abletonCoordToZoomArrangementViewHorizontallyY
		click 2		;zoom so loop brace fills the arrangement view.
		suspend, off
		gosub, switchToFourBarMidiClipStuff
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
specialNoteInputOptionsPress1(inputNumber)			;lh
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 1)  		;input 2 notes with same start and end points, different velocities.
	{
		currentInputLayer := "input2NotesSameStartEndPointsDifferentVelocitiesPress1"
	}
	else if (inputNumber == 2)			;resize existing selection of notes
	{
		currentInputLayer := "resizeExistingSelectionOfNotesPress1"
	}
	else if (inputNumber == 3)			;remove existing selection of notes
	{
		;tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip			;not necessary here.
		suspend, on
		send, {delete}
		suspend, off
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 4)			;input 64 16ths at C3		;just using the autoVelocityVal value for the velocity of all these notes atm.
	{		;THIS FUNCTION USES OLD Y-VALUE FOR C3 PIXEL COORDINATE. NEEDS CHANGING OVER BEFORE USING THIS FUNCTION.
		;tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip			;not necessary here.
		suspend, on
		xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + (sizeOf1GridUnitInPixelsX / 2)
		mousemove, xToClick, tempC3ValueForDrumsY
		click 2			;input initial note, all velocities based on this inputted note, so next line does the velocity of the note.
		send % autoVelocityVal				;don't need to press enter after this for some reason
		send, {ctrl down}d{ctrl up}		;initial ctrl-d press to make next code Loop easier to read.
		tempExpCountVar := 1
		Loop, 5
		{
			send, {ctrl down}{shift down}{left %tempExpCountVar%}{shift up}d{ctrl up}
			tempExpCountVar *= 2
		}
		suspend, off
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 5)			;input typical trap kick pattern		;just using the autoVelocityVal value for the velocity of all these notes atm.
	{
		gosub, inputTypicalTrapKickPatternInCurrent4BarMidiClip
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 6)			;input typical trap snare pattern		;just using the autoVelocityVal value for the velocity of all these notes atm.
	{
		gosub, inputTypicalTrapSnarePatternInCurrent4BarMidiClip
		gosub, switchToFourBarMidiClipStuff
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
inputTypicalTrapKickPatternInCurrent4BarMidiClip:		;just using the autoVelocityVal value for the velocity of all these notes atm.
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip			;not necessary here.
	suspend, on
	yToClick := newBottomPixel - (sizeOf1GridUnitInPixelsY / 2) - (29 * sizeOf1GridUnitInPixelsY) ;c3 is always at the 30th y-value atm. 30 out of 58 values.
	xToClick1 := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + (sizeOf1GridUnitInPixelsX / 2)
	xToClick2 := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + (sizeOf1GridUnitInPixelsX / 2) + (sizeOf1GridUnitInPixelsX * 10)
	xToClick3 := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + (sizeOf1GridUnitInPixelsX * 16)
	xToClick4 := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + (sizeOf1GridUnitInPixelsX * 32)
	mousemove, xToClick1, yToClick
	click 2			;input 1st initial note, half of all the velocities based on this inputted note, so next line does the velocity of this 1st initial note.
	send % autoVelocityVal				;don't need to press enter after this for some reason
	mousemove, xToClick2, yToClick
	click 2			;input 2nd initial note, half of all the velocities based on this inputted note, so next line does the velocity of this 2nd initial note.
	send % autoVelocityVal				;don't need to press enter after this for some reason
	send, {shift down}
		sleep % sleepAmountForInputtingAndDuplicatingNotes
		mousemove, xToClick1, yToClick
		click		;shift-click the first note, so that now the 2 notes are selected.
		sleep % sleepAmountForInputtingAndDuplicatingNotes
		mousemove, xToClick3, pixelCoordOfRowJustAboveMidiClipY
		click		;shift-click so the 2 notes are selected and the entire first-bar-region is selected, ready for ctrl-d'ing
	send, {shift up}
	send, {ctrl down}d{ctrl up}		;now 2 bars have the desired note pattern.
	send, {shift down}
		sleep % sleepAmountForInputtingAndDuplicatingNotes
		mousemove, xToClick2, yToClick
		click		;re-select 2nd-inputted note into selection notes.
		sleep % sleepAmountForInputtingAndDuplicatingNotes
		mousemove, xToClick1, yToClick
		click		;re-select 1st-inputted note into selection notes.
		sleep % sleepAmountForInputtingAndDuplicatingNotes
		mousemove, xToClick4, pixelCoordOfRowJustAboveMidiClipY
		click		;shift-click so the 4 notes are selected and the entire first-2bar-region is selected, ready for final ctrl-d press.
	send, {shift up}
	send, {ctrl down}d{ctrl up}		;now 4 bars have the desired note pattern.
	suspend, off
return
inputTypicalTrapSnarePatternInCurrent4BarMidiClip:		;just using the autoVelocityVal value for the velocity of all these notes atm.
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	suspend, on
	yToClick := newBottomPixel - (sizeOf1GridUnitInPixelsY / 2) - (29 * sizeOf1GridUnitInPixelsY) ;c3 is always at the 30th y-value atm. 30 out of 58 values.
	xToClick1 := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + (sizeOf1GridUnitInPixelsX / 2) + (sizeOf1GridUnitInPixelsX * 4)
	xToClick2 := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + (sizeOf1GridUnitInPixelsX / 2) + (sizeOf1GridUnitInPixelsX * 12)
	xToClick3 := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + (sizeOf1GridUnitInPixelsX * 16)
	xToClick4 := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + (sizeOf1GridUnitInPixelsX * 32)
	xToClick5 := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + 1			;"+1" just to make sure the click registers.
	mousemove, xToClick1, yToClick
	click 2			;input 1st initial note, half of all the velocities based on this inputted note, so next line does the velocity of this 1st initial note.
	send % autoVelocityVal				;don't need to press enter after this for some reason
	mousemove, xToClick2, yToClick
	click 2			;input 2nd initial note, half of all the velocities based on this inputted note, so next line does the velocity of this 2nd initial note.
	send % autoVelocityVal				;don't need to press enter after this for some reason
	send, {shift down}
		sleep % sleepAmountForInputtingAndDuplicatingNotes
		mousemove, xToClick1, yToClick
		click		;shift-click the first note, so that now the 2 notes are selected.
		sleep % sleepAmountForInputtingAndDuplicatingNotes
		mousemove, xToClick3, pixelCoordOfRowJustAboveMidiClipY
		click		;shift-click so the 2 notes are selected and the end of the first-bar-region is selected
		sleep % sleepAmountForInputtingAndDuplicatingNotes
		mousemove, xToClick5, pixelCoordOfRowJustAboveMidiClipY
		click		;shift-click so the 2 notes are selected and the end of the first-bar-region is selected, now is ready for ctrl-d'ing
	send, {shift up}
	send, {ctrl down}d{ctrl up}		;now 2 bars have the desired note pattern.
	send, {shift down}
		sleep % sleepAmountForInputtingAndDuplicatingNotes
		mousemove, xToClick2, yToClick
		click		;re-select 2nd-inputted note into selection notes.
		sleep % sleepAmountForInputtingAndDuplicatingNotes
		mousemove, xToClick1, yToClick
		click		;re-select 1st-inputted note into selection notes.
		sleep % sleepAmountForInputtingAndDuplicatingNotes
		mousemove, xToClick4, pixelCoordOfRowJustAboveMidiClipY
		click		;shift-click so the 4 notes are selected and the end of the first-2bar-region is selected
		sleep % sleepAmountForInputtingAndDuplicatingNotes
		mousemove, xToClick5, pixelCoordOfRowJustAboveMidiClipY
		click		;shift-click so the 4 notes are selected and the entire first-2bar-region is selected, now is ready for final ctrl-d press.
	send, {shift up}
	send, {ctrl down}d{ctrl up}		;now 4 bars have the desired note pattern.
	suspend, off
return
abletonPlayStopOptionsPress1(inputNumber)			;lh
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 1)  ;ableton play audio
	{
		gosub, abletonPlayAudio
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 2)  ;play from start position of last-inputted note.
	{
		gosub, abletonPlayFromStartPositionOfLastInputtedNote
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 3)  ;ableton stop audio
	{
		gosub, abletonStopAudio
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 4)	;play from defined 16th in 4bar section
	{
		currentInputLayer := "playFromDefined16thIn4BarSectionPress1"
	}
	else if (inputNumber == 5)	;play from start of current 4bar section
	{
		tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip			;should work this line into a function for all macros that send mouseclicks to windows, maybe.
		suspend, on
		;the '+2' in the line below makes sure the click is just to the right of the line
		send, {esc}			;does this line remove selections etc.???
		mousemove, pixelCoordOfFirstBarlineInMidiClip4BarSectionX + 2, pixelCoordOfRowJustAboveMidiClipY
		click
		send, {ctrl down}{space}{ctrl up}
		suspend, off
		gosub, switchToFourBarMidiClipStuff
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
newFileEnsurerPress1(inputNumber)			;rh				;combo for this ensurer, on qwerty, is i-d-/, aka RH_1--LH_5--RH_9, aka code10-code5-code18
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 10)
	{
		currentInputLayer := "newFileEnsurerPress2"
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
newFileEnsurerPress2(inputNumber)			;lh
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 5)
	{
		currentInputLayer := "newFileEnsurerPress3"
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
newFileEnsurerPress3(inputNumber)			;rh
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 18)
	{
		tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
		suspend, on
		send, {ctrl down}n{ctrl up}
		wasAbletonPopupWindowEncountered := 0
		loopCount := 0
		Loop, 100
		{
			WinGetPos, , , w, h, A
			;531, 181
			if (w == 531 && h == 181)			;ableton's 'Save changes to "X" before closing?' popup has these exact dimensions.
			{
				;msgbox % loopCount				;this just for testing.
				wasAbletonPopupWindowEncountered := 1
				break
			}
			loopCount ++
			sleep, 1			;fails without this 1ms sleep..
		}
		if (wasAbletonPopupWindowEncountered == 0)		;success
		{
			;display something with gdip to indicate success
			gosub, switchToFourBarMidiClipStuff
		}
		else											;failure, ableton popup window was encountered.
		{
			;display something with gdip to indicate failure
			suspend, on
			send, {esc}
			suspend, off
			gosub, switchToFourBarMidiClipStuff
		}
		suspend, off
		currentInputLayer := "newFileEnsurerPress4"
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
keyChangerPress1(inputNumber)			;lh
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 1)
	{
		inputStorage.Push(inputNumber - 1)
		currentInputLayer := "keyChangerPress2"
	}
	else if (inputNumber == 2)
	{
		inputStorage.Push(inputNumber - 1)
		currentInputLayer := "keyChangerPress2"
	}
	else if (inputNumber == 3)
	{
		inputStorage.Push(inputNumber - 1)
		currentInputLayer := "keyChangerPress2"
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
keyChangerPress2(inputNumber)			;rh
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 10)				;the layer for 10-13 doesn't actually go back into midi clip view. it stays in device selector view and arrangement view atm. so this needs to be handled by input system to display something on screen, probably. (instead of displaying 4bar grid)...
		;these 2 lines in each of the 4 below elseif's probably need to be changed:
		;currentInputLayer := "mainLayer"
		;gosub, drawMainLayerIndicator
	{
		functionFor12Options(inputNumber)
		changeKeyOfInstruments(inputStorageRefined[1])
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 11)
	{
		functionFor12Options(inputNumber)
		functionFor12Options(inputNumber)
		changeKeyOfInstruments(inputStorageRefined[1])
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 12)
	{
		functionFor12Options(inputNumber)
		changeKeyOfInstruments(inputStorageRefined[1])
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 13)
	{
		functionFor12Options(inputNumber)
		changeKeyOfInstruments(inputStorageRefined[1])
		gosub, switchToFourBarMidiClipStuff
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
functionFor12Options(inputNumber)
{
	global
	inputNumberReEvaluated := inputNumber - 9
	valToPushToArray := (inputStorage[1] * -4) - inputNumberReEvaluated
	inputStorageRefined.Push(valToPushToArray)	;stores -1 to -12 value to be used later.
	return
}
changeKeyOfInstruments(funcKeyVal)
{
	global
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	suspend, on
	mousemove, abletonCoordToClickBottomRowDeviceViewSelectorX, abletonCoordToClickBottomRowY
	click		;open device view selector.
	mousemove, abletonTrackNamesX, abletonMiddleOfTrack1Y
	click		;make sure piano is selected [ableton track 1]
	sleep % abletonOpenDeviceViewSleep
	mousemove, abletonCoordToClickDeadSimpleGlobalTransposeKnobX, abletonCoordToClickDeadSimpleGlobalTransposeKnobY
	click		;click on dead simple global transpose knob, ready to send new pitch value to it.
	send, %funcKeyVal%{enter}		;send value and {enter} to knob
	suspend, off
	;still in arrangement view.
	return
}
moveSelectedNotesToNewPitchPress1(inputNumber)		;126options_press1_rh			;1st Y-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "moveSelectedNotesToNewPitchPress2")
	return
}
moveSelectedNotesToNewPitchPress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "moveSelectedNotesToNewPitchPress3")
	return
}
moveSelectedNotesToNewPitchPress3(inputNumber)		;126options_press3_rh
{
	global
	typical126OptionsPress3RH(inputNumber, "moveSelectedNotesToNewPitchPress4", 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
	return
}
moveSelectedNotesToNewPitchPress4(inputNumber)		;126options_press1_lh			;2nd Y-VALUE START
{
	global
	typical126OptionsPress1LH(inputNumber, "moveSelectedNotesToNewPitchPress5")
	return
}
moveSelectedNotesToNewPitchPress5(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "moveSelectedNotesToNewPitchPress6")
	return
}
moveSelectedNotesToNewPitchPress6(inputNumber)		;126options_press3_lh
{
	global
	typical126OptionsPress3LH(inputNumber, "moveSelectedNotesToNewPitchPress7", 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
	return
}
moveSelectedNotesToNewPitchPress7(inputNumber)		;126options_press1_rh			;ONLY X-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "moveSelectedNotesToNewPitchPress8")
	return
}
moveSelectedNotesToNewPitchPress8(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "moveSelectedNotesToNewPitchPress9")
	return
}
moveSelectedNotesToNewPitchPress9(inputNumber)		;126options_press3_rh_final
{
	global
	tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, 1, amountOfXCells)				;range of 1-48/64 for x value.
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, moveSelectedNotesToNewPitch
	}
		gosub, switchToFourBarMidiClipStuff
	return
}
moveSelectedNotesToNewPitch:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	yToClick := newBottomPixel - ((inputStorageRefined[1] - 0) * sizeOf1GridUnitInPixelsY)
	yToClick2 := newBottomPixel - ((inputStorageRefined[2] - 0) * sizeOf1GridUnitInPixelsY)			;what happens when inputStorageRefined[1] and inputStorageRefined[2] are the same value?
	xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[3] - 1) * sizeOf1GridUnitInPixelsX)
	;these two values were pointing to the top left corner of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	xToClick += 13			;its going to select based on the middlepoint of 16ths, should be fine at the moment. when triplet input/smaller-than16th-input is added, will need to change this, probably.
	yToClick += 10
	;this values was pointing to the top edge of the 16th, so this adjustment puts the coordinate in the middle height of the 16th instead. should rewrite the code later.
	yToClick2 += 10
	suspend, on
	MouseClickDrag, left, xToClick, yToClick, xToClick, yToClick2
	suspend, off
return
typical126OptionsPress1RH(inputNumber, nextLayer)
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber > 9 && inputNumber < 19)
	{
		inputNumberReEvaluated := inputNumber - 9
		inputStorage.Push(inputNumberReEvaluated)
		currentInputLayer := nextLayer
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
typical126OptionsPress2LH(inputNumber, nextLayer)
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber > 0 && inputNumber < 7)
	{
		inputStorage.Push(inputNumber)
		currentInputLayer := nextLayer
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
typical126OptionsPress3RH(inputNumber, nextLayer, min126Val, max126Val)
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber > 9 && inputNumber < 19)
	{
		inputNumberReEvaluated := inputNumber - 9
		inputStorage.Push(inputNumberReEvaluated)
		calculateMultvar(inputStorage[inputStorage.MaxIndex() - 2], inputStorage[inputStorage.MaxIndex()])
		if (multvar >= 0)		;there is a valid multvar where multvar equals 0, so this checks a valid multvar was calculated.
		{
			valToPushToArray := (multvar * 6) + inputStorage[inputStorage.MaxIndex() - 1]
			if (valToPushToArray >= min126Val && valToPushToArray <= max126Val)		;check val is between min and max values specified, endpoints included.
			{
				inputStorageRefined.Push(valToPushToArray)	;stores 1-126 value in array to be used later.
				currentInputLayer := nextLayer
			}
			else		;out of bounds of 1-58, endpoints included.
			{
				gosub, incorrectSequenceInputted
			}
		}
		else					;invalid press/es therefore invalid multvar, multvar was assigned as -1 to trigger this.
		{
			gosub, incorrectSequenceInputted
		}
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
typical126OptionsPress1LH(inputNumber, nextLayer)
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber > 0 && inputNumber < 10)
	{
		inputStorage.Push(inputNumber)
		currentInputLayer := nextLayer
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
typical126OptionsPress2RH(inputNumber, nextLayer)
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber > 9 && inputNumber < 16)
	{
		inputNumberReEvaluated := inputNumber - 9
		inputStorage.Push(inputNumberReEvaluated)
		currentInputLayer := nextLayer
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
typical126OptionsPress3LH(inputNumber, nextLayer, min126Val, max126Val)
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber > 0 && inputNumber < 10)
	{
		inputStorage.Push(inputNumber)
		calculateMultvar(inputStorage[inputStorage.MaxIndex() - 2], inputStorage[inputStorage.MaxIndex()])
		if (multvar >= 0)		;there is a valid multvar where multvar equals 0, so this checks a valid multvar was calculated.
		{
			valToPushToArray := (multvar * 6) + inputStorage[inputStorage.MaxIndex() - 1]
			if (valToPushToArray >= min126Val && valToPushToArray <= max126Val)		;check val is between min and max values specified, endpoints included.
			{
				inputStorageRefined.Push(valToPushToArray)	;stores 1-126 value in array to be used later.
				currentInputLayer := nextLayer
			}
			else
			{
				gosub, incorrectSequenceInputted
			}
		}
		else					;invalid press/es therefore invalid multvar, multvar was assigned as -1 to trigger this.
		{
			gosub, incorrectSequenceInputted
		}
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
typical126OptionsPress3RHFinal(inputNumber, min126Val, max126Val)
{
	global

	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
		return 0		;should this return 0 or 1? it doesnt really matter?
	}
	else if (inputNumber > 9 && inputNumber < 19)
	{
		inputNumberReEvaluated := inputNumber - 9
		inputStorage.Push(inputNumberReEvaluated)
		calculateMultvar(inputStorage[inputStorage.MaxIndex() - 2], inputStorage[inputStorage.MaxIndex()])
		if (multvar >= 0)		;there is a valid multvar where multvar equals 0, so this checks a valid multvar was calculated.
		{
			valToPushToArray := (multvar * 6) + inputStorage[inputStorage.MaxIndex() - 1]
			if (valToPushToArray >= min126Val && valToPushToArray <= max126Val)
			{
				inputStorageRefined.Push(valToPushToArray)	;stores 1-126 value in array to be used later.
				return 1
			}
			else
			{
				gosub, incorrectSequenceInputted
				return 0
			}
		}
		else					;invalid press/es therefore invalid multvar, multvar was assigned as -1 to trigger this.
		{
			gosub, incorrectSequenceInputted
			return 0
		}
	}
	else
	{
		gosub, incorrectSequenceInputted
		return 0
	}
}
typical126OptionsPress3LHFinal(inputNumber, min126Val, max126Val)
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
		return 0		;should this return 0 or 1? it doesnt really matter?
	}
	else if (inputNumber > 0 && inputNumber < 10)
	{
		inputStorage.Push(inputNumber)
		calculateMultvar(inputStorage[inputStorage.MaxIndex() - 2], inputStorage[inputStorage.MaxIndex()])
		if (multvar >= 0)		;there is a valid multvar where multvar equals 0, so this checks a valid multvar was calculated.
		{
			valToPushToArray := (multvar * 6) + inputStorage[inputStorage.MaxIndex() - 1]
			if (valToPushToArray >= min126Val && valToPushToArray <= max126Val)
			{
				inputStorageRefined.Push(valToPushToArray)	;stores 1-126 value in array to be used later.
				return 1
			}
			else
			{
				gosub, incorrectSequenceInputted
				return 0
			}
		}
		else					;invalid press/es therefore invalid multvar, multvar was assigned as -1 to trigger this.
		{
			gosub, incorrectSequenceInputted
			return 0
		}
	}
	else
	{
		gosub, incorrectSequenceInputted
		return 0
	}
}
selectOrDeselectOneNotePress1(inputNumber)		;126options_press1_rh			;16TH Y-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "selectOrDeselectOneNotePress2")
	return
}
selectOrDeselectOneNotePress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "selectOrDeselectOneNotePress3")
	return
}
selectOrDeselectOneNotePress3(inputNumber)		;126options_press3_rh
{
	global
	typical126OptionsPress3RH(inputNumber, "selectOrDeselectOneNotePress4", 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
	return
}
selectOrDeselectOneNotePress4(inputNumber)		;126options_press1_lh			;16TH X-VALUE START
{
	global
	typical126OptionsPress1LH(inputNumber, "selectOrDeselectOneNotePress5")
	return
}
selectOrDeselectOneNotePress5(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "selectOrDeselectOneNotePress6")
	return
}
selectOrDeselectOneNotePress6(inputNumber)		;126options_press3_lh_final
{
	global
	tempFuncVar := typical126OptionsPress3LHFinal(inputNumber, 1, amountOfXCells)			;range of 1-48/64 for this value(?).
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, selectOrDeselectOneNote
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
selectOrDeselectOneNote:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	yToClick := newBottomPixel - ((inputStorageRefined[1] - 0) * sizeOf1GridUnitInPixelsY)
	xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[2] - 1) * sizeOf1GridUnitInPixelsX)
	;these two values were pointing to the top left corner of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	xToClick += 13
	yToClick += 10
	suspend, on
	mousemove, xToClick, yToClick
	send, {shift down}
	click
	send, {shift up}
	suspend, off
return
pasteNotesPress1(inputNumber)		;126options_press1_rh			;1st X-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "pasteNotesPress2")
	return
}
pasteNotesPress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "pasteNotesPress3")
	return
}
pasteNotesPress3(inputNumber)		;126options_press3_rh_final
{
	global
	tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, 1, amountOfXCells)			;range of 1-48/64 for this value(?).
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, pasteNotes
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
pasteNotes:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[1] - 1) * sizeOf1GridUnitInPixelsX)
		;these two values were pointing to the top left corner of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	xToClick += 2		;add 2 pixels to value so that macro always clicks just to right of the intended vertical 16th line.
	suspend, on
	;is this {esc} needed here (to deselect any selected notes/selected region)? probably is needed? so that clicks in the horizontal bar just above midi clip area always send through and aren't blocked by clicking on the triangle region handle things...
	send, {esc}								;deselects any notes and gets rid of any region selection, so that nothing is selected for the next macros.
	mousemove, xToClick, pixelCoordOfRowJustAboveMidiClipY
	click
	send, {ctrl down}v{ctrl up}			;paste the notes that were just copied to the location specified.
	suspend, off
return
move4BarSectionOptions1Press1(inputNumber)		;126options_press1_rh			;1st X-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "move4BarSectionOptions1Press2")
	return
}
move4BarSectionOptions1Press2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "move4BarSectionOptions1Press3")
	return
}
move4BarSectionOptions1Press3(inputNumber)		;126options_press3_rh_final
{
	global
	tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, 1, 126)			;range of 1-126 for this value.
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, move4BarSectionOptions1
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
move4BarSectionOptions1:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	xToClick1 := pixelCoordOfFirstBarlineInMidiClipFull256BarsX + ((inputStorageRefined[1] - 1) * ((pixelCoordOfLastBarlineInMidiClipFull256BarsX - pixelCoordOfFirstBarlineInMidiClipFull256BarsX) / 256))
	xToClick2 := pixelCoordOfFirstBarlineInMidiClipFull256BarsX + ((inputStorageRefined[1] + 3) * ((pixelCoordOfLastBarlineInMidiClipFull256BarsX - pixelCoordOfFirstBarlineInMidiClipFull256BarsX) / 256))
	suspend, on
	send, {esc}								;deselects any notes and gets rid of any region selection, so that nothing is selected for the next macros.
	MouseMove, pixelCoordOfFirstBarlineInMidiClip4BarSectionX, pixelCoordOfRowJustAboveMidiClipY
	click right			;right clicks just above midi clip notes in that extra row timeline bar thing.
	send, 1{enter}		;the '1' here highlights the 1bar grid-segment option.
	mousemove, abletonMidiClipCoordToZoomHorizontallyX, abletonMidiClipCoordToZoomHorizontallyY
	Click 2									;doubleclick here to zoom midi clip all the way out so the range is from -2 barline to 257 barline. (-2 barline because there are 2 notes at different pitches, with both their X values from -2 barline to -1 barline that are used to determine vertical zoom macros.
	mouseclickdrag, left, xToClick1, pixelCoordOfRowJustAboveMidiClipY, xToClick2, pixelCoordOfRowJustAboveMidiClipY + 1		;don't know if i need the "+1" on the 2nd y value here, mouseclickdrag probably would work without it.
	mousemove, abletonMidiClipCoordToZoomHorizontallyX, abletonMidiClipCoordToZoomHorizontallyY
	Click 2									;doubleclick here to zoom midi clip to the 4bar selection that was just made.
	send, {esc}			;gets rid of the selection box around the 4 bars segment, placing cursor at the start of the first bar chosen.
	MouseMove, pixelCoordOfFirstBarlineInMidiClip4BarSectionX, pixelCoordOfRowJustAboveMidiClipY
	click right			;right clicks just above midi clip notes in that extra row timeline bar thing.
	send, n{enter}		;the 'n' here highlights 'Narrow' grid-segment option. which for a 4bar segment, will be 1/16 segments.
	suspend, off
return
abletonPlayFromStartPositionOfLastInputtedNote:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((startPositionOfLastInputtedNoteInMidiClip64thNumberX - 1) * sizeOf1GridUnitInPixelsX)
		;these two values were pointing to the top left corner of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	xToClick += 2		;add 2 pixels to value so that macro always clicks just to right of the intended vertical 16th line.
	suspend, on
	mousemove, xToClick, pixelCoordOfRowJustAboveMidiClipY
	click
	send, {ctrl down}{space}{ctrl up}
	suspend, off
return
abletonPlayAudio:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	suspend, on
	mousemove, abletonCoordToClickPlayButtonX, abletonCoordToClickTopRowButtonsY
	click
	suspend, off
return
abletonStopAudio:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	suspend, on
	mousemove, abletonCoordToClickStopButtonX, abletonCoordToClickTopRowButtonsY
	click
	suspend, off
return
playFromDefined16thIn4BarSectionPress1(inputNumber)		;126options_press1_rh			;1st X-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "playFromDefined16thIn4BarSectionPress2")
	return
}
playFromDefined16thIn4BarSectionPress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress1LH(inputNumber, "playFromDefined16thIn4BarSectionPress3")
	return
}
playFromDefined16thIn4BarSectionPress3(inputNumber)		;126options_press3_rh_final
{
	global
	tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, 1, amountOfXCells)			;range of 1-48/64 for this value(?).
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, abletonMovePlayMarkerInMidiClipAndPlay
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
abletonMovePlayMarkerInMidiClipAndPlay:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[1] - 1) * sizeOf1GridUnitInPixelsX)
		;these two values were pointing to the top left corner of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	xToClick += 2		;add 2 pixels to value so that macro always clicks just to right of the intended vertical 16th line.
	suspend, on
	mousemove, xToClick, pixelCoordOfRowJustAboveMidiClipY
	click
	;sleep, 50		;does this line stop bug happening, where ableton plays from start of project instead of specified location?
	send, {ctrl down}{space}{ctrl up}
	suspend, off
return
pixel1Press1(inputNumber)		;126options_press1_rh			;ONLY 16TH Y-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "pixel1Press2")
	return
}
pixel1Press2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "pixel1Press3")
	return
}
pixel1Press3(inputNumber)		;126options_press3_rh
{
	global
	typical126OptionsPress3RH(inputNumber, "pixel1Press4", 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
	return
}
pixel1Press4(inputNumber)		;126options_press1_lh			;ONLY 16TH X-VALUE START
{
	global
	typical126OptionsPress1LH(inputNumber, "pixel1Press5")
	return
}
pixel1Press5(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "pixel1Press6")
	return
}
pixel1Press6(inputNumber)		;126options_press3_lh / 126options_press3_lh_final
{
	global
	if (isAutoVelocityOn == 0)			;if auto velocity is off
		typical126OptionsPress3LH(inputNumber, "pixel1Press7", 1, amountOfXCells)				;range of 1-48/64 for this value(?).
	else if (isAutoVelocityOn == 1)		;if auto velocity is on
	{
		tempFuncVar := typical126OptionsPress3LHFinal(inputNumber, 1, amountOfXCells)			;range of 1-126 for velocity atm.
		if (tempFuncVar == 1)				;function succeeded.
		{
			gosub, input1GridSizedNote
		}
	gosub, switchToFourBarMidiClipStuff
	}
	return
}
pixel1Press7(inputNumber)		;126options_press1_rh			;velocity start
{
	global
	typical126OptionsPress1RH(inputNumber, "pixel1Press8")
	return
}
pixel1Press8(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "pixel1Press9")
	return
}
pixel1Press9(inputNumber)		;126options_press3_rh_final
{
	global
	tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, 1, 126)			;range of 1-126 for velocity atm.
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, input1GridSizedNote
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
input1GridSizedNote:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	yToClick := newBottomPixel - ((inputStorageRefined[1] - 0) * sizeOf1GridUnitInPixelsY)
	xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[2] - 1) * sizeOf1GridUnitInPixelsX)
		;these two values were pointing to the top left corner of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	xToClick += 13
	yToClick += 10
	if (isAutoVelocityOn == 0)			;auto velocity is off.
		velocityToInput := inputStorageRefined[3]
	if (isAutoVelocityOn == 1)			;auto velocity is on.
		velocityToInput := autoVelocityVal
	suspend, on
	mousemove, xToClick, yToClick
	click 2
	send % velocityToInput		;dont actually need to press enter after this, ableton will change the velocity to this value as soon as the next macro clicks somewhere else in the midi clip.
	mousemove, pixelCoordOfFirstBarlineInMidiClip4BarSectionX, pixelCoordOfRowJustAboveMidiClipY
	click					;click here to deselect the note that was just inputted, to make sure that if any note selection is done next, this note that was just inputted is not part of that selection.
	suspend, off
	startPositionOfLastInputtedNoteInMidiClip64thNumberX := inputStorageRefined[2]
	;can probably remove this line at some point, or incorporate the data into a Gdip display instead:
	tooltip, %velocityToInput%, xToClick + 10, yToClick
return
inputA16thAtC3Press1(inputNumber)		;126options_press1_rh			;ONLY 16TH Y-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "inputA16thAtC3Press2")
	return
}
inputA16thAtC3Press2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "inputA16thAtC3Press3")
	return
}
inputA16thAtC3Press3(inputNumber)		;126options_press3_rh
{
	global
	typical126OptionsPress3RH(inputNumber, "inputA16thAtC3Press4", 1, amountOfXCells)			;range of 48/64 for x-value.
	return
}
inputA16thAtC3Press4(inputNumber)		;126options_press1_lh
{
	global
	typical126OptionsPress1LH(inputNumber, "inputA16thAtC3Press5")
	return
}
inputA16thAtC3Press5(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "inputA16thAtC3Press6")
	return
}
inputA16thAtC3Press6(inputNumber)		;126options_press1_lh_final
{
	global
	tempFuncVar := typical126OptionsPress3LHFinal(inputNumber, 1, 126) ;range of 1-126 for velocity atm.
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, inputA16thAtC3
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
inputA16thAtC3:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[1] - 1) * sizeOf1GridUnitInPixelsX)
		;this value was pointing to the left side of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	xToClick += 13
	;no auto-velocity capability for this input option atm, maybe build it in later.
	velocityToInput := inputStorageRefined[2]
	suspend, on
	mousemove, xToClick, tempC3ValueForDrumsY
	click 2
	send % velocityToInput		;dont actually need to press enter after this, ableton will change the velocity to this value as soon as the next macro clicks somewhere else in the midi clip.
	mousemove, pixelCoordOfFirstBarlineInMidiClip4BarSectionX, pixelCoordOfRowJustAboveMidiClipY
	click					;click here to deselect the note that was just inputted, to make sure that if any note selection is done next, this note that was just inputted is not part of that selection.
	suspend, off
	startPositionOfLastInputtedNoteInMidiClip64thNumberX := inputStorageRefined[1]
	;can probably remove this line at some point, or incorporate the data into a Gdip display instead:
	tooltip, %velocityToInput%, xToClick + 10, tempC3ValueForDrumsY
return
c3BoxSelectPress1(inputNumber)		;126options_press1_rh			;ONLY 16TH Y-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "c3BoxSelectPress2")
	return
}
c3BoxSelectPress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "c3BoxSelectPress3")
	return
}
c3BoxSelectPress3(inputNumber)		;126options_press3_rh
{
	global
	typical126OptionsPress3RH(inputNumber, "c3BoxSelectPress4", 1, amountOfXCells)			;range of 48/64 for x-value.
	return
}
c3BoxSelectPress4(inputNumber)		;126options_press1_lh
{
	global
	typical126OptionsPress1LH(inputNumber, "c3BoxSelectPress5")
	return
}
c3BoxSelectPress5(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "c3BoxSelectPress6")
	return
}
c3BoxSelectPress6(inputNumber)		;126options_press1_lh_final
{
	global
	tempFuncVar := typical126OptionsPress3LHFinal(inputNumber, 1, amountOfXCells)			;range of 48/64 for x-value.
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, c3BoxSelect
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
c3BoxSelect:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	yToClick := tempC3ValueForDrumsY - 20			;the -20 is temporary, should fix this code so this var points to middle of C#3 y-value properly.
	xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[1] - 1) * sizeOf1GridUnitInPixelsX)
	yToClick2 := tempC3ValueForDrumsY
	xToClick2 := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[2] - 1) * sizeOf1GridUnitInPixelsX)
		;these two values were pointing to the top left corner of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	xToClick += 13			;its going to select based on the middlepoint of 16ths, should be fine at the moment. when triplet input/smaller-than16th-input is added, will need to change this, probably.
	yToClick += 10
		;these two values were pointing to the top left corner of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	xToClick2 += 13			;its going to select based on the middlepoint of 16ths, should be fine at the moment. when triplet input/smaller-than16th-input is added, will need to change this, probably.
	yToClick2 += 10
	suspend, on
	send, {shift down}		;shift is held down here so that multiple select macros can be executed in series.
	MouseClickDrag, left, xToClick, yToClick, xToClick2, yToClick2
	send, {shift up}
	suspend, off
return
removeA16thAtC3Press1(inputNumber)		;126options_press1_rh			;ONLY 16TH Y-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "removeA16thAtC3Press2")
	return
}
removeA16thAtC3Press2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "removeA16thAtC3Press3")
	return
}
removeA16thAtC3Press3(inputNumber)		;126options_press3_rh_final
{
	global
	tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, 1, amountOfXCells) ;range of 48/64 for x-value.
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, removeA16thAtC3
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
removeA16thAtC3:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[1] - 1) * sizeOf1GridUnitInPixelsX)
		;this value was pointing to the left side of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	xToClick += 13
	suspend, on
	mousemove, xToClick, tempC3ValueForDrumsY
	click 2
	mousemove, pixelCoordOfFirstBarlineInMidiClip4BarSectionX, pixelCoordOfRowJustAboveMidiClipY
	click					;click here to deselect the note that was just inputted, to make sure that if any note selection is done next, this note that was just inputted is not part of that selection.
	suspend, off
return
/*
- show/hide browser					ctrl-alt-b
abletonTrackNamesX := 1499
abletonMiddleOfTrack1Y := 125
abletonMiddleOfMasterTrackDeviceViewClosedY := 1001
abletonMiddleOfMasterTrackDeviceViewOpenY := 746
abletonYDistanceBetweenTracksAtSmallestHeightInPixels := 23.74285714
*/
;
; just copied pixel1 function names here and replaced all with 'changeInstrument' so far. probably the only thing thats been done on these, so far. need to fix.
;
changeInstrumentPress1(inputNumber)		;126options_press1_rh			;126 track options.
{
	global
	typical126OptionsPress1RH(inputNumber, "changeInstrumentPress2")
	return
}
changeInstrumentPress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "changeInstrumentPress3")
	return
}
changeInstrumentPress3(inputNumber)		;126options_press3_rh_final
{
	global
	tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, 1, 6)			;range of 1-6 for tracks atm. IMPORTANT NOTE: CHANGE THIS TO 1-126 LATER.
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, changeInstrument
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
changeInstrument:			;IMPORTANT NOTE: automatically goes back into 4bar midi clip. this needs to be re-written later, maybe.
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	yToClick := abletonMiddleOfTrack1Y + ((inputStorageRefined[1] - 1) * currentTrackHeightInPixels)
	suspend, on
	mousemove, abletonCoordToClickBottomRowBottomRightTriangleX, abletonCoordToClickBottomRowY
	click		;single click moves from midi clip view to arrangement view.
	mousemove, tempLocationToOpen4BarMidiClipX, yToClick
	click 2		;double-click opens 4bar midi clip.
	suspend, off
return
randomizeCertainInstrumentSamplePress1(inputNumber)		;126options_press1_rh			;126 track options.
{
	global
	typical126OptionsPress1RH(inputNumber, "randomizeCertainInstrumentSamplePress2")
	return
}
randomizeCertainInstrumentSamplePress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "randomizeCertainInstrumentSamplePress3")
	return
}
randomizeCertainInstrumentSamplePress3(inputNumber)		;126options_press3_rh_final
{
	global
	tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, 2, 6)			;range of 2-6 for tracks atm. IMPORTANT NOTE: CHANGE THIS TO 1-126 LATER.
	if (tempFuncVar == 1)				;function succeeded.
	{
		randomizeCertainInstrumentSample(inputStorageRefined[1])
	}
	;gosub, switchToArrangementViewStuff			;ends in arrangement view.
	;whatIsCurrentAbletonView := "arrangementView"
	whatIsCurrentAbletonView := "fourBarMidiClip"			;should this line be in 'switchToFourBarMidiClipStuff' gosub instead?
	gosub, switchToFourBarMidiClipStuff				;IMPORTANT NOTE: this isn't accurate, in arrangement view atm, not 4bar midi clip view. doing it all manually atm though, so it hasn't been built in that this does anything atm.
	return
}
randomizeCertainInstrumentSample(funcTrackNumber)
{
	global
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	yToClick := abletonMiddleOfTrack1Y + ((funcTrackNumber - 1) * currentTrackHeightInPixels)
	suspend, on
	mousemove, abletonCoordToClickBottomRowDeviceViewSelectorX, abletonCoordToClickBottomRowY
	click		;single click moves from any-view to arrangement-view.
	mousemove, abletonTrackNamesX, yToClick
	click 2		;double click opens up device view bar along bottom of ableton, for desired track.
	if (funcTrackNumber == 2)			;IMPORTANT NOTE: CHANGE THIS CODE LATER. input option 2 is 808's atm, which are the only option atm that need transposing currently.
	{
		;NOTE: ~154 is amount of x pixels added when dead simple global transpose knob is used, such as on the 808 track atm.
		mousemove, abletonCoordToHotswapSimplerSampleX + 154, abletonCoordToHotswapSimplerSampleY
	}
	else
	{
		mousemove, abletonCoordToHotswapSimplerSampleX, abletonCoordToHotswapSimplerSampleY
	}
	click
	sleep % sleepAmountForAbletonBrowser			;55 is about the lowest value thats working for this value atm [when you have to down arrow ~133 times], with 808 folder being tested (~133 samples in folder). don't know if amount of samples in folder makes a difference though. went with 65ms so ~10ms extra, i guess.
	send, {left}		;go to root folder of current-samples-folder being used.
	createRandomSampleChoiceNumberForCertainFolder(funcTrackNumber)
	send, {down %numberOfDownArrowsForAbletonBrowserToDo%}		;down-arrows through the folder to desired sample.
	;empty the clipboard, so clipwait works later on in the code. could save the clipboard contents here to be later restored.. maybe edit this into this code later.
	clipboard := ""
	send, {ctrl down}rc{ctrl up}{esc}{enter}			;copy sample name, {esc} out of rename, {enter} again to load specified sample to ableton track.
	sleep, 250
	send, q												;have to exit hotswap mode.
	sleep, 250
	send, {ctrl down}{alt down}b{alt up}{ctrl up}		;closes Ableton Browser, which was automatically opened when hotswap mode was clicked.
	;should probably have a 'ClipWait' about here, but ClipWait doesn't seem to work with ableton, unless you activate and deactivate Ableton's window with something like "send, !{esc}". so far the code has worked without clipwait.
	if (funcTrackNumber == 2)			;IMPORTANT NOTE: CHANGE THIS CODE LATER. input option 2 is 808's atm, which are the only option atm that need transposing currently.
	{
		;NOTE: ~154 is amount of x pixels added when dead simple global transpose knob is used, such as on the 808 track atm.
		mousemove, abletonCoordToClickTransposeSimplerClick1X + 154, abletonCoordToClickTransposeSimplerClick1Y
		click
		mousemove, abletonCoordToClickTransposeSimplerClick2X + 154, abletonCoordToClickTransposeSimplerClick2Y
		click
		tempVar := owenJ808TransposeArray[numberOfDownArrowsForAbletonBrowserToDo - 1]			;probably can put this line in the line below, without 'tempVar'
		send % tempVar
		send, {enter}
		mousemove, abletonCoordToClickTransposeSimplerClick3X + 154, abletonCoordToClickTransposeSimplerClick3Y
		click
	}
	;this section of code is to re-name Track Name so it has the number of down arrows, ie. with the top-most sample always being numbered '1':
	mousemove, abletonTrackNamesX, yToClick
	click			;click on specified Track Name field.
	if (funcTrackNumber == 2)		;Owen J 808s are a special case where they require an extra down arrow to get past the "Bass" folder. this 'if' is accounting for that extra down arrow, so that the sample number isn't affected by the folder.
	{
		tempVar := numberOfDownArrowsForAbletonBrowserToDo - 1
		send, {ctrl down}r{ctrl up}{backspace}{#}|%tempVar% {ctrl down}v{ctrl up}{enter}		;change track name to string with sample number in folder.
	}
	else
	{
		send, {ctrl down}r{ctrl up}{backspace}{#}|%numberOfDownArrowsForAbletonBrowserToDo% {ctrl down}v{ctrl up}{enter}		;change track name to string with sample number in folder.
	}
	;putting this stuff here so arrangement zooms so 4bar clip fills screen after the above function is finished (opening the browser(?) seems to change the arrangement zoom(?) so that the 4bar clip is zoomed out and on the left side of the screen(?), so this is to fix that quickly, remove/rewrite this code/put this code somewhere else later:
	sleep, 50			;is this sleep necessary? just putting this here anyway.
	mousemove, tempLocationToProbablyClickArrangementLoopBraceX, tempLocationToProbablyClickArrangementLoopBraceY
	click		;select the loop brace (probably - just temp location clicking on atm).
	mousemove, abletonCoordToZoomArrangementViewHorizontallyX, abletonCoordToZoomArrangementViewHorizontallyY
	click 2		;zoom so loop brace fills the arrangement view.
	suspend, off
	return
}
lookAtCertainInstrumentDeviceChainPress1(inputNumber)		;126options_press1_rh			;1-6 track options atm. later it will be 126 track options.
{
	global
	typical126OptionsPress1RH(inputNumber, "lookAtCertainInstrumentDeviceChainPress2")
	return
}
lookAtCertainInstrumentDeviceChainPress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "lookAtCertainInstrumentDeviceChainPress3")
	return
}
lookAtCertainInstrumentDeviceChainPress3(inputNumber)		;126options_press3_rh_final
{
	global
	tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, 1, 6)			;range of 1-6 for tracks atm. IMPORTANT NOTE: CHANGE THIS TO 1-126 LATER.
	if (tempFuncVar == 1)				;function succeeded.
	{
		lookAtCertainInstrumentDeviceChain(inputStorageRefined[1])
	}
	;gosub, switchToArrangementViewStuff			;ends in arrangement view.
	;whatIsCurrentAbletonView := "arrangementView"
	whatIsCurrentAbletonView := "fourBarMidiClip"			;should this line be in 'switchToFourBarMidiClipStuff' gosub instead?
	gosub, switchToFourBarMidiClipStuff				;IMPORTANT NOTE: this isn't accurate, in arrangement view atm, not 4bar midi clip view. doing it all manually atm though, so it hasn't been built in that this does anything atm.
	return
}
lookAtCertainInstrumentDeviceChain(funcTrackNumber)
{
	global
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	yToClick := abletonMiddleOfTrack1Y + ((funcTrackNumber - 1) * currentTrackHeightInPixels)
	suspend, on
	mousemove, abletonCoordToClickBottomRowDeviceViewSelectorX, abletonCoordToClickBottomRowY
	click		;single click moves from any-view to arrangement-view.
	mousemove, abletonTrackNamesX, yToClick
	click 2		;double click opens up device view bar along bottom of ableton, for desired track.
	suspend, off
	;still in arrangement view.
	return
}
setAllInstrumentsToNegative6dB:
;NOTE ABOUT THIS FUNCTION:
;in ableton, if you have multiple tracks selected, the only way to make all tracks have the same volume is to double click any of the NON-ZERO-DB selected-tracks. so if you're double clicking one of the selected tracks, you have to first make sure the volume of that specific track does not equal exactly 0dB, because nothing will happen to the other selected tracks if you double click a selected track with volume of 0dB. it is a quirk of ableton.
;with the above in mind, a value of ".1" is first sent to the track that is double-clicked on, to make sure it is first non-zero before double-clicking.
;ANOTHER NOTE ABOUT THIS FUNCTION:
;there's another peculiarity of ableton, where if multiple tracks are selected, you can't always double-click a track to de-select all the other tracks.
;with this peculiarity in mind, two tracks are clicked on, so that all tracks are de-selected.
	tooltip ;get rid of any tooltip, so that mouse macros dont click on tooltip
	suspend, on
	mousemove, abletonCoordToClickBottomRowDeviceViewSelectorX, abletonCoordToClickBottomRowY
	click ;single click moves from any-other-view to arrangement-view.
	mousemove, abletonTrackNamesX, abletonMiddleOfTrack1Y
	click ;single click selects track 1.
	send, {ctrl down}a{ctrl up} ;selects all tracks.
	tempYVar := abletonMiddleOfTrack1Y + abletonYDistanceBetweenTracksAtSmallestHeightInPixels - 5		;the minus 5 was needed for this, i think.
	mousemove, abletonCoordForTrackVolumeX, tempYVar
	click ;single-click on track, so that ".1" can be sent to it, to make sure it is first non-zero before it can 100%-of-the-time zero-out the other tracks.
	send, .1{enter}
	click 2 ;double-click on track volume of 1st track, WITH ALL tracks selected, this double-click makes ALL selected tracks (ALL TRACKS atm) SET TO 0dB.
	sleep, 20			;20ms sleep is required for function to work. 15ms is not long enough. so far, 20ms has always worked.
	send, -6{enter}
	tempYVar := abletonMiddleOfTrack1Y + currentTrackHeightInPixels
	mousemove, abletonTrackNamesX, tempYVar
	click ;single-click on 2nd track first, for the reason listed in the 2nd NOTE detailed at the top of this function. this is a part of de-selecting all selected tracks.
	mousemove, abletonTrackNamesX, abletonMiddleOfTrack1Y
	click ;single-click then selects track 1.
	suspend, off
	;still in arrangement view.
return
moveFromArrangementViewToSpecifiedTemp4BarMidiClipPress1(inputNumber)		;126options_press1_rh			;126 track options.
{
	global
	typical126OptionsPress1RH(inputNumber, "moveFromArrangementViewToSpecifiedTemp4BarMidiClipPress2")
	return
}
moveFromArrangementViewToSpecifiedTemp4BarMidiClipPress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "moveFromArrangementViewToSpecifiedTemp4BarMidiClipPress3")
	return
}
moveFromArrangementViewToSpecifiedTemp4BarMidiClipPress3(inputNumber)		;126options_press3_rh_final
{
	global
	tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, 1, 6)			;range of 1-6 for tracks atm. IMPORTANT NOTE: CHANGE THIS TO 1-126 LATER.
	if (tempFuncVar == 1)				;function succeeded.
	{
		moveFromArrangementViewToSpecifiedTemp4BarMidiClip(inputStorageRefined[1])
	}
	whatIsCurrentAbletonView := "fourBarMidiClip"			;should this line be in 'switchToFourBarMidiClipStuff' gosub instead?
	gosub, switchToFourBarMidiClipStuff
	return
}
moveFromArrangementViewToSpecifiedTemp4BarMidiClip(tempFuncVar)
{
	global
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	yToClick := abletonMiddleOfTrack1Y + ((tempFuncVar - 1) * currentTrackHeightInPixels)
	suspend, on
	mousemove, tempLocationToProbablyClickArrangementLoopBraceX, tempLocationToProbablyClickArrangementLoopBraceY
	click		;select the loop brace (probably - just temp location clicking on atm).
	mousemove, abletonCoordToZoomArrangementViewHorizontallyX, abletonCoordToZoomArrangementViewHorizontallyY
	click 2		;zoom so loop brace fills the arrangement view.
	mousemove, tempLocationToOpen4BarMidiClipX, yToClick
	click 2		;double click to open up the desired temp 4 bar midi clip.
	suspend, off
	return
}
limitedRangeEditTrackVolumeOfSpecifiedTrackPress1(inputNumber)		;126options_press1_rh			;126 track options.
{
	global
	typical126OptionsPress1RH(inputNumber, "limitedRangeEditTrackVolumeOfSpecifiedTrackPress2")
	return
}
limitedRangeEditTrackVolumeOfSpecifiedTrackPress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "limitedRangeEditTrackVolumeOfSpecifiedTrackPress3")
	return
}
;typical126OptionsPress3RH(inputNumber, "pixel1Press4", 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
limitedRangeEditTrackVolumeOfSpecifiedTrackPress3(inputNumber)		;126options_press3_rh
{
	global
	typical126OptionsPress3RH(inputNumber, "limitedRangeEditTrackVolumeOfSpecifiedTrackPress4", 1, 6)			;temp range of 1-6 for this atm.
	return
}
limitedRangeEditTrackVolumeOfSpecifiedTrackPress4(inputNumber)		;126options_press_lh
{
	global
	typical126OptionsPress1LH(inputNumber, "limitedRangeEditTrackVolumeOfSpecifiedTrackPress5")
	return
}
limitedRangeEditTrackVolumeOfSpecifiedTrackPress5(inputNumber)		;126options_press_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "limitedRangeEditTrackVolumeOfSpecifiedTrackPress6")
	return
}
limitedRangeEditTrackVolumeOfSpecifiedTrackPress6(inputNumber)		;126options_press3_lh_final
{
	global
	tempFuncVar := typical126OptionsPress3LHFinal(inputNumber, 1, 126)			;range of 1-126 for this. gets converted to -0.1 to -12.6 range of values.
	if (tempFuncVar == 1)				;function succeeded.
	{
		limitedRangeEditTrackVolumeOfSpecifiedTrack(inputStorageRefined[1], inputStorageRefined[2])
	}
	whatIsCurrentAbletonView := "fourBarMidiClip"			;should this line be in 'switchToFourBarMidiClipStuff' gosub instead?
	gosub, switchToFourBarMidiClipStuff				;IMPORTANT NOTE: this isn't accurate, in arrangement view atm, not 4bar midi clip view. doing it all manually atm though, so it hasn't been built in that this does anything atm.
	return
}
limitedRangeEditTrackVolumeOfSpecifiedTrack(tempFuncTrackNumber, tempFuncTrackVolume)
{
	global
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	;the next line probably/definitely needs to be re-written so that it can work with multiple different track heights:
	yToClick := (abletonMiddleOfTrack1Y + abletonYDistanceBetweenTracksAtSmallestHeightInPixels) + ((tempFuncTrackNumber - 1) * currentTrackHeightInPixels)
	yToClick -= 5			;this coord is sometimes too low, so minusing 5 pixels should fix it. might still not work for lower-down-on-the-screen tracks, maybe it is actually a calculation error/bug in the code, dont know.
	suspend, on
	mousemove, abletonCoordToClickBottomRowDeviceViewSelectorX, abletonCoordToClickBottomRowY
	click ;single click moves from any-other-view to arrangement-view.
	sleep, 50
	mousemove, abletonCoordForTrackVolumeX, yToClick
	click		;single-click, ready to enter specified velocity.
	tempVar := Format("{:s}", tempFuncTrackVolume)
	leftSideOfStrTempVar := SubStr(tempVar, 1, -1)		;gets the 1st 1 or 2 characters.
	rightSideOfStrTempVar := SubStr(tempVar, 0)		;gets the last character.
	tempVar := "-" . leftSideOfStrTempVar . "." . rightSideOfStrTempVar
	tempVar := Format("{:.1f}", tempVar)		;the flags for ahk's Format() function are confusingly documented... this {:.1f} flag seems to trim all but 1 digit after the decimal place, while converting to floating point number format.
	send % tempVar
	send, {enter}
	suspend, off
	return
}
createRandomSampleChoiceNumberForCertainFolder(funcValue)
{
	global
	;atm the value should already be being made sure to be between 2-6, endpoints included.
	if (funcValue == 2)				;Owen J 808s
	{
		;this folder has 133 options. this folder has the special requirement that first down-arrow press lands on folder, so it must be skipped, and account for this extra down arrow press for all sample selections.
		random, numberOfDownArrowsForAbletonBrowserToDo, 2, 134
	}
	else if (funcValue == 3)		;Owen J Kicks
	{
		;this folder has 99 options.
		random, numberOfDownArrowsForAbletonBrowserToDo, 1, 99
	}
	else if (funcValue == 4)		;Owen J Snares
	{
		;this folder has 210 options.
		random, numberOfDownArrowsForAbletonBrowserToDo, 1, 210
	}
	else if (funcValue == 5)		;Owen J Claps
	{
		;this folder has 84 options.
		random, numberOfDownArrowsForAbletonBrowserToDo, 1, 84
	}
	else if (funcValue == 6)		;Owen J Rims
	{
		;this folder has 37 options.
		random, numberOfDownArrowsForAbletonBrowserToDo, 1, 37
	}
	return
}
removeNotePress1(inputNumber)		;126options_press1_rh			;16TH Y-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "removeNotePress2")
	return
}
removeNotePress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "removeNotePress3")
	return
}
removeNotePress3(inputNumber)		;126options_press3_rh
{
	global
	typical126OptionsPress3RH(inputNumber, "removeNotePress4", 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
	return
}
removeNotePress4(inputNumber)		;126options_press1_lh			;16TH X-VALUE START
{
	global
	typical126OptionsPress1LH(inputNumber, "removeNotePress5")
	return
}
removeNotePress5(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "removeNotePress6")
	return
}
removeNotePress6(inputNumber)		;126options_press3_lh_final
{
	global
	tempFuncVar := typical126OptionsPress3LHFinal(inputNumber, 1, amountOfXCells)			;range of 1-48/64 for this value(?).
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, remove1Note
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
remove1Note:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	yToClick := newBottomPixel - ((inputStorageRefined[1] - 0) * sizeOf1GridUnitInPixelsY)
	xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[2] - 1) * sizeOf1GridUnitInPixelsX)
		;these two values were pointing to the top left corner of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	xToClick += 13
	yToClick += 10
	suspend, on
		;msgbox, %xToClick%, %yToClick%
	mousemove, xToClick, yToClick
	click 2
		;should put in a check somewhere so that note cant be inputted out of bounds by macros.
	mousemove, pixelCoordOfFirstBarlineInMidiClip4BarSectionX, pixelCoordOfRowJustAboveMidiClipY
	click					;click here to deselect the note that was just inputted, to make sure that if any note selection is done next, this note that was just inputted is not part of that selection.
	suspend, off
return
rectangleSelectPress1(inputNumber)		;126options_press1_rh			;1st Y-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "rectangleSelectPress2")
	return
}
rectangleSelectPress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "rectangleSelectPress3")
	return
}
rectangleSelectPress3(inputNumber)		;126options_press3_rh
{
	global
	typical126OptionsPress3RH(inputNumber, "rectangleSelectPress4", 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
	return
}
rectangleSelectPress4(inputNumber)		;126options_press1_lh			;2nd Y-VALUE START
{
	global
	typical126OptionsPress1LH(inputNumber, "rectangleSelectPress5")
	return
}
rectangleSelectPress5(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "rectangleSelectPress6")
	return
}
rectangleSelectPress6(inputNumber)		;126options_press3_lh
{
	global
	typical126OptionsPress3LH(inputNumber, "rectangleSelectPress7", 1, inputStorageRefined[1])			;has to be <= first y-value
	return
}
rectangleSelectPress7(inputNumber)		;126options_press1_rh			;1st X-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "rectangleSelectPress8")
	return
}
rectangleSelectPress8(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "rectangleSelectPress9")
	return
}
rectangleSelectPress9(inputNumber)		;126options_press3_rh
{
	global
	typical126OptionsPress3RH(inputNumber, "rectangleSelectPress10", 1, amountOfXCells)			;range of 1-64 for this value.
	return
}
rectangleSelectPress10(inputNumber)		;126options_press1_lh			;2ND X-VALUE START
{
	global
	typical126OptionsPress1LH(inputNumber, "rectangleSelectPress11")
	return
}
rectangleSelectPress11(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "rectangleSelectPress12")
	return
}
rectangleSelectPress12(inputNumber)		;126options_press3_lh_final
{
	global
	tempFuncVar := typical126OptionsPress3LHFinal(inputNumber, inputStorageRefined[3], amountOfXCells)		;range of 1-48/64 for this value.
																											;AND has to be >= to the first x-value inputted.
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, addRectangleAreaToSelection
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
addRectangleAreaToSelection:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	yToClick := newBottomPixel - ((inputStorageRefined[1] - 0) * sizeOf1GridUnitInPixelsY)
	xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[3] - 1) * sizeOf1GridUnitInPixelsX)
	yToClick2 := newBottomPixel - ((inputStorageRefined[2] - 0) * sizeOf1GridUnitInPixelsY)
	xToClick2 := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[4] - 1) * sizeOf1GridUnitInPixelsX)
	;originally:
	;xSize := (inputStorageRefined[4] - inputStorageRefined[3] + 1) * newPixelSize
	;ySize := (inputStorageRefined[1] - inputStorageRefined[2] + 1) * newPixelSize
	;then it was:
	;xToClick2 := (inputStorageRefined[4] - inputStorageRefined[3]) * sizeOf1GridUnitInPixelsX
	;yToClick2 := (inputStorageRefined[1] - inputStorageRefined[2]) * sizeOf1GridUnitInPixelsY
		;these two values were pointing to the top left corner of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	xToClick += 13			;its going to select based on the middlepoint of 16ths, should be fine at the moment. when triplet input/smaller-than16th-input is added, will need to change this, probably.
	yToClick += 10
		;these two values were pointing to the top left corner of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	xToClick2 += 13			;its going to select based on the middlepoint of 16ths, should be fine at the moment. when triplet input/smaller-than16th-input is added, will need to change this, probably.
	yToClick2 += 10
	suspend, on
	send, {shift down}		;shift is held down here so that multiple select macros can be executed in series.
	MouseClickDrag, left, xToClick, yToClick, xToClick2, yToClick2
	send, {shift up}
	suspend, off
return
resizeEndOfNotePress1(inputNumber)		;126options_press1_rh			;1st 16TH Y-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "resizeEndOfNotePress2")
	return
}
resizeEndOfNotePress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "resizeEndOfNotePress3")
	return
}
resizeEndOfNotePress3(inputNumber)		;126options_press3_rh
{
	global
	typical126OptionsPress3RH(inputNumber, "resizeEndOfNotePress4", 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
	return
}
resizeEndOfNotePress4(inputNumber)		;126options_press1_lh			;1st 16TH X-VALUE START
{
	global
	typical126OptionsPress1LH(inputNumber, "resizeEndOfNotePress5")
	return
}
resizeEndOfNotePress5(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "resizeEndOfNotePress6")
	return
}
resizeEndOfNotePress6(inputNumber)		;126options_press3_lh
{
	global
	typical126OptionsPress3LH(inputNumber, "resizeEndOfNotePress7", 1, amountOfXCells)			;can't be more than 64 for this (4 bars).
	return
}
resizeEndOfNotePress7(inputNumber)		;126options_press1_rh			;2ND 16TH X-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "resizeEndOfNotePress8")
	return
}
resizeEndOfNotePress8(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "resizeEndOfNotePress9")
	return
}
resizeEndOfNotePress9(inputNumber)		;126options_press3_rh_final
{
	global
	tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, 1, amountOfXCells)			;range of 1-48/64 for this value(?).
																							;dont have the data from ableton for where this note starts, so anything from 1-48/64 is accepted as valid, even if it makes the note an impossible, negative length.
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, resizeEndOfNote
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
resizeEndOfNote:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	yToClick := newBottomPixel - ((inputStorageRefined[1] - 0) * sizeOf1GridUnitInPixelsY)
	xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[2] - 0) * sizeOf1GridUnitInPixelsX)
	xToClick2 := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[3] - 0) * sizeOf1GridUnitInPixelsX)
	;this value was pointing to the top of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	yToClick += 10
	;this "-= 2" makes sure that the resize handle is clicked on, by shifting x value 2 pixels to the left.
	xToClick -= 2
	suspend, on
	mouseclickdrag, left, xToClick, yToClick, xToClick2, yToClick
	;should put in a check somewhere so that note cant be inputted out of bounds by macros.
	/*
	;commenting these out for now:
	mousemove, pixelCoordOfFirstBarlineInMidiClip4BarSectionX, pixelCoordOfRowJustAboveMidiClipY
	click					;click here to deselect the note that was just inputted, to make sure that if any note selection is done next, this note that was just inputted is not part of that selection.
	*/
	suspend, off
	;startPositionOfLastInputtedNoteInMidiClip64thNumberX := inputStorageRefined[2]
	;can't store start position of this note, as this script doesn't have that data, that data is only in ableton atm. so e.g. the above line can't be used to store the data.
return
resizeStartOfNotePress1(inputNumber)		;126options_press1_rh			;1st 16TH Y-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "resizeStartOfNotePress2")
	return
}
resizeStartOfNotePress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "resizeStartOfNotePress3")
	return
}
resizeStartOfNotePress3(inputNumber)		;126options_press3_rh
{
	global
	typical126OptionsPress3RH(inputNumber, "resizeStartOfNotePress4", 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
	return
}
resizeStartOfNotePress4(inputNumber)		;126options_press1_lh			;1st 16TH X-VALUE START
{
	global
	typical126OptionsPress1LH(inputNumber, "resizeStartOfNotePress5")
	return
}
resizeStartOfNotePress5(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "resizeStartOfNotePress6")
	return
}
resizeStartOfNotePress6(inputNumber)		;126options_press3_lh
{
	global
	typical126OptionsPress3LH(inputNumber, "resizeStartOfNotePress7", 1, amountOfXCells)			;can't be more than 64 for this (4 bars).
	return
}
resizeStartOfNotePress7(inputNumber)		;126options_press1_rh			;2ND 16TH X-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "resizeStartOfNotePress8")
	return
}
resizeStartOfNotePress8(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "resizeStartOfNotePress9")
	return
}
resizeStartOfNotePress9(inputNumber)		;126options_press3_rh_final
{
	global
	tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, 1, amountOfXCells)			;range of 1-48/64 for this value(?).
																							;dont have the data from ableton for where this note ends, so anything from 1-48/64 is accepted as valid, even if it makes the note an impossible, negative length.
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, resizeStartOfNote
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
resizeStartOfNote:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	yToClick := newBottomPixel - ((inputStorageRefined[1] - 0) * sizeOf1GridUnitInPixelsY)
	xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[2] - 1) * sizeOf1GridUnitInPixelsX)
	xToClick2 := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[3] - 1) * sizeOf1GridUnitInPixelsX)
	;this value was pointing to the top of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	yToClick += 10
	;this "+= 2" makes sure that the resize handle is clicked on, by shifting x value 2 pixels to the right.
	xToClick += 2
	suspend, on
	mouseclickdrag, left, xToClick, yToClick, xToClick2, yToClick
	;should put in a check somewhere so that note cant be inputted out of bounds by macros.
	/*
	;commenting these out for now:
	mousemove, pixelCoordOfFirstBarlineInMidiClip4BarSectionX, pixelCoordOfRowJustAboveMidiClipY
	click					;click here to deselect the note that was just inputted, to make sure that if any note selection is done next, this note that was just inputted is not part of that selection.
	*/
	suspend, off
	;startPositionOfLastInputtedNoteInMidiClip64thNumberX := inputStorageRefined[2]
	;can't store start position of this note, as this script doesn't have that data, that data is only in ableton atm. so e.g. the above line can't be used to store the data.
return
resizeExistingSelectionOfNotesPress1(inputNumber)		;126options_press1_rh			;1st 16TH Y-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "resizeExistingSelectionOfNotesPress2")
	return
}
resizeExistingSelectionOfNotesPress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "resizeExistingSelectionOfNotesPress3")
	return
}
resizeExistingSelectionOfNotesPress3(inputNumber)		;126options_press3_rh
{
	global
	typical126OptionsPress3RH(inputNumber, "resizeExistingSelectionOfNotesPress4", 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
	return
}
resizeExistingSelectionOfNotesPress4(inputNumber)		;126options_press1_lh			;1st 16TH X-VALUE START
{
	global
	typical126OptionsPress1LH(inputNumber, "resizeExistingSelectionOfNotesPress5")
	return
}
resizeExistingSelectionOfNotesPress5(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "resizeExistingSelectionOfNotesPress6")
	return
}
resizeExistingSelectionOfNotesPress6(inputNumber)		;126options_press3_lh
{
	global
	typical126OptionsPress3LH(inputNumber, "resizeExistingSelectionOfNotesPress7", 1, amountOfXCells)			;can't be more than 64 for this (4 bars).
	return
}
resizeExistingSelectionOfNotesPress7(inputNumber)		;126options_press1_rh			;2ND 16TH X-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "resizeExistingSelectionOfNotesPress8")
	return
}
resizeExistingSelectionOfNotesPress8(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "resizeExistingSelectionOfNotesPress9")
	return
}
resizeExistingSelectionOfNotesPress9(inputNumber)		;126options_press3_rh_final
{
	global
	tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, 1, amountOfXCells)			;range of 1-48/64 for this value(?).
																							;i think this function is for resizing the end of notes, but theres no data from ableton for where the start of the note is available, so this value just limited here between 1-64, endpoints included.
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, resizeExistingSelectionOfNotes
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
resizeExistingSelectionOfNotes:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	xSize := inputStorageRefined[3] - inputStorageRefined[2]		;xSize being used a bit differently here. it ranges from -64 to +64, i think. xSize being used here to store the number of arrow key presses that need to be sent to resize the note in question. negative value means resize with left arrow that many presses, positive value means resize with right arrow that many presses.
	suspend, on
	;should put in a check somewhere so that note cant be inputted out of bounds by macros.
	if (xSize > 0)
	{
		send, {shift down}{right %xSize%}{shift up}
	}
	if (xSize < 0)
	{
		tempvar := Abs(xSize)
		send, {shift down}{left %tempvar%}{shift up}
	}
	;nothing happens if xSize == 0, currently.
	mousemove, pixelCoordOfFirstBarlineInMidiClip4BarSectionX, pixelCoordOfRowJustAboveMidiClipY
	click					;click here to deselect the note that was just inputted, to make sure that if any note selection is done next, this note that was just inputted is not part of that selection.
	suspend, off
	;startPositionOfLastInputtedNoteInMidiClip64thNumberX := inputStorageRefined[2]
	;can't store start position of this note, as this script doesn't have that data, that data is only in ableton atm. so e.g. the above line can't be used to store the data.
return
horizontalNotePress1(inputNumber)		;126options_press1_rh			;1st 16TH Y-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "horizontalNotePress2")
	return
}
horizontalNotePress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "horizontalNotePress3")
	return
}
horizontalNotePress3(inputNumber)		;126options_press3_rh
{
	global
	typical126OptionsPress3RH(inputNumber, "horizontalNotePress4", 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
	return
}
horizontalNotePress4(inputNumber)		;126options_press1_lh			;1st 16TH X-VALUE START
{
	global
	typical126OptionsPress1LH(inputNumber, "horizontalNotePress5")
	return
}
horizontalNotePress5(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "horizontalNotePress6")
	return
}
horizontalNotePress6(inputNumber)		;126options_press3_lh
{
	global
	typical126OptionsPress3LH(inputNumber, "horizontalNotePress7", 1, amountOfXCells)			;can't be more than 64 for this (4 bars).
	return
}
horizontalNotePress7(inputNumber)		;126options_press1_rh			;2ND 16TH X-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "horizontalNotePress8")
	return
}
horizontalNotePress8(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "horizontalNotePress9")
	return
}
horizontalNotePress9(inputNumber)		;126options_press3_rh / 126options_press3_rh_final
{
	global
	if (isAutoVelocityOn == 0)			;auto velocity is off.
	{
		typical126OptionsPress3RH(inputNumber, "horizontalNotePress10", inputStorageRefined[2], amountOfXCells)			;can't be more than 64 for this (4 bars).
																													;check this value is >= the first x-value (which is 'inputStorageRefined[2]')
	}
	else if (isAutoVelocityOn == 1)			;auto velocity is on.
	{
		tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, inputStorageRefined[2], amountOfXCells)			;can't be more than 64 for this (4 bars).
																													;check this value is >= the first x-value (which is 'inputStorageRefined[2]')
		if (tempFuncVar == 1)				;function succeeded.
		{
			gosub, inputNoteOfVariableLength
		}
		gosub, switchToFourBarMidiClipStuff
	}
	return
}
horizontalNotePress10(inputNumber)		;126options_press1_lh			;velocity start
{
	global
	typical126OptionsPress1LH(inputNumber, "horizontalNotePress11")
	return
}
horizontalNotePress11(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "horizontalNotePress12")
	return
}
horizontalNotePress12(inputNumber)		;126options_press3_lh_final
{
	global
	tempFuncVar := typical126OptionsPress3LHFinal(inputNumber, 1, 126)			;range of 1-126 for velocity atm.
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, inputNoteOfVariableLength
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
inputNoteOfVariableLength:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	yToClick := newBottomPixel - ((inputStorageRefined[1] - 0) * sizeOf1GridUnitInPixelsY)
	xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[2] - 1) * sizeOf1GridUnitInPixelsX)
	xToClick2 := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[2] - 0) * sizeOf1GridUnitInPixelsX)
	xToClick3 := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[3] - 0) * sizeOf1GridUnitInPixelsX)
	;these two values were pointing to the top left corner of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	xToClick += 13
	yToClick += 10
	;this "-= 2" makes sure that the resize handle is clicked on, by shifting x value 2 pixels to the left.
	xToClick2 -= 2
	if (isAutoVelocityOn == 0)			;auto velocity is off.
		velocityToInput := inputStorageRefined[4]
	else if (isAutoVelocityOn == 1)			;auto velocity is on.
		velocityToInput := autoVelocityVal
	suspend, on
	mousemove, xToClick, yToClick
	click 2
	send % velocityToInput		;dont actually need to press enter after this, ableton will change the velocity to this value as soon as the macro starts dragging the side of the note to make it the right note length. so might need to use {enter} for 16th input, as there is no resizing of the note by dragging in that input chain at the moment.
	mouseclickdrag, left, xToClick2, yToClick, xToClick3, yToClick
	mousemove, pixelCoordOfFirstBarlineInMidiClip4BarSectionX, pixelCoordOfRowJustAboveMidiClipY
	click					;click here to deselect the note that was just inputted, to make sure that if any note selection is done next, this note that was just inputted is not part of that selection.
	suspend, off
	startPositionOfLastInputtedNoteInMidiClip64thNumberX := inputStorageRefined[2]
	;can probably remove this line at some point, or incorporate the data into a Gdip display instead:
	tooltip, %velocityToInput%, xToClick3, yToClick
return
input2NotesSameStartEndPointsDifferentVelocitiesPress1(inputNumber)		;126options_press1_rh			;note startpoint
{
	global
	typical126OptionsPress1RH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesPress2")
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesPress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesPress3")
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesPress3(inputNumber)		;126options_press3_rh
{
	global
	typical126OptionsPress3RH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesPress4", 1, amountOfXCells)			;can't be more than 64 for this (4 bars).
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesPress4(inputNumber)		;126options_press1_lh			;note endpoint
{
	global
	typical126OptionsPress1LH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesPress5")
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesPress5(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesPress6")
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesPress6(inputNumber)		;126options_press3_lh
{
	global
	typical126OptionsPress3LH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesPress7", inputStorageRefined[1], amountOfXCells)			;can't be more than 64 for this (4 bars).
																													;check this value is >= the first x-value (which is 'inputStorageRefined[1]')
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesPress7(inputNumber)		;126options_press1_rh			;pitch of first note
{
	global
	typical126OptionsPress1RH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesPress8")
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesPress8(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesPress9")
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesPress9(inputNumber)		;126options_press3_rh / CHAIN SPLITS HERE DEPENDING ON AUTO-VELOCITY.
{
	global
	if (isAutoVelocityOn == 0)			;auto velocity is off.
	{
		typical126OptionsPress3RH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesPress10", 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
	}
	else if (isAutoVelocityOn == 1)			;auto velocity is on.
	{
		typical126OptionsPress3RH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesAUTOVELOCITYPress10", 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
	}
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesAUTOVELOCITYPress10(inputNumber)		;126options_press1_lh			;pitch of second note.
{
	global
	typical126OptionsPress1LH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesAUTOVELOCITYPress11")
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesAUTOVELOCITYPress11(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesAUTOVELOCITYPress12")
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesAUTOVELOCITYPress12(inputNumber)		;126options_press3_lh				;END OF SPLIT CHAIN BIT. GOES TO NORMAL FUNCTION: 'input2NotesSameStartEndPointsDifferentVelocities'
{
	global
	tempFuncVar := typical126OptionsPress3LHFinal(inputNumber, 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, input2NotesSameStartEndPointsDifferentVelocities
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesPress10(inputNumber)		;126options_press1_lh			;velocity of first note
{
	global
	typical126OptionsPress1LH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesPress11")
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesPress11(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesPress12")
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesPress12(inputNumber)		;126options_press3_lh
{
	global
	typical126OptionsPress3LH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesPress13", 1, 126)			;range of 1-126 for velocity atm.
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesPress13(inputNumber)		;126options_press1_rh			;pitch of second note.
{
	global
	typical126OptionsPress1RH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesPress14")
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesPress14(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesPress15")
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesPress15(inputNumber)		;126options_press3_rh
{
	global
	typical126OptionsPress3RH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesPress16", 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesPress16(inputNumber)		;126options_press1_lh			;velocity of second note.
{
	global
	typical126OptionsPress1LH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesPress17")
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesPress17(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "input2NotesSameStartEndPointsDifferentVelocitiesPress18")
	return
}
input2NotesSameStartEndPointsDifferentVelocitiesPress18(inputNumber)		;126options_press3_lh_final
{
	global
	tempFuncVar := typical126OptionsPress3LHFinal(inputNumber, 1, 126)			;range of 1-126 for velocity atm.
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, input2NotesSameStartEndPointsDifferentVelocities
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
input2NotesSameStartEndPointsDifferentVelocities:
	if (inputStorageRefined[3] != inputStorageRefined[5])		;make sure two different pitches were inputted. should this be put earlier in the code(?).
	{
		tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
		yToClick1 := newBottomPixel - ((inputStorageRefined[3] - 0) * sizeOf1GridUnitInPixelsY)
		xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[1] - 1) * sizeOf1GridUnitInPixelsX)
		xToClick2 := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[1] - 0) * sizeOf1GridUnitInPixelsX)
		xToClick3 := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[2] - 0) * sizeOf1GridUnitInPixelsX)
		if (isAutoVelocityOn == 0)			;auto velocity is off.
		{
			yToClick2 := newBottomPixel - ((inputStorageRefined[5] - 0) * sizeOf1GridUnitInPixelsY)
			velocityToInput1 := inputStorageRefined[4]
			velocityToInput2 := inputStorageRefined[6]
		}
		else if (isAutoVelocityOn == 1)			;auto velocity is on.
		{
			yToClick2 := newBottomPixel - ((inputStorageRefined[4] - 0) * sizeOf1GridUnitInPixelsY)
			velocityToInput1 := autoVelocityVal
			velocityToInput2 := autoVelocityVal
		}
		;these two values were pointing to the top left corner of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
		xToClick += 13
		yToClick1 += 10
		yToClick2 += 10
		;this "-= 2" makes sure that the resize handle is clicked on, by shifting x value 2 pixels to the left.
		xToClick2 -= 2
		suspend, on
		startPositionOfLastInputtedNoteInMidiClip64thNumberX := inputStorageRefined[1]
	;first note:
		mousemove, xToClick, yToClick1
		click 2
		send % velocityToInput1		;dont actually need to press enter after this, ableton will change the velocity to this value as soon as the macro starts dragging the side of the note to make it the right note length. so might need to use {enter} for 16th input, as there is no resizing of the note by dragging in that input chain at the moment.
		mouseclickdrag, left, xToClick2, yToClick1, xToClick3, yToClick1
	;second note:
		mousemove, xToClick, yToClick2
		click 2
		send % velocityToInput2		;dont actually need to press enter after this, ableton will change the velocity to this value as soon as the macro starts dragging the side of the note to make it the right note length. so might need to use {enter} for 16th input, as there is no resizing of the note by dragging in that input chain at the moment.
		mouseclickdrag, left, xToClick2, yToClick2, xToClick3, yToClick2
		mousemove, pixelCoordOfFirstBarlineInMidiClip4BarSectionX, pixelCoordOfRowJustAboveMidiClipY
		click					;click here to deselect the note that was just inputted, to make sure that if any note selection is done next, this note that was just inputted is not part of that selection.
		suspend, off
		;can probably remove this line at some point, or incorporate the data into a Gdip display instead:
		varToTooltip := velocityToInput1 . ", " . velocityToInput2
		yVarForTooltip := 0		;initialize var.
		if (yToClick1 < yToClick2)
			yVarForTooltip := ((yToClick2 - yToClick1) / 2) + yToClick1
		else
			yVarForTooltip := ((yToClick1 - yToClick2) / 2) + yToClick2
		tooltip, %varToTooltip%, xToClick3, yVarForTooltip			;put the tooltip in the midpoint between the two pitches.
	}
	else
	{
		gosub, incorrectSequenceInputted			;these are usually in the 'typical126Options...' functions at the moment. this one isn't.
	}
return
shiftVelocityOfSelectedNotesDownByZPress1(inputNumber)		;126options_press1_rh			;1st 16TH Y-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "shiftVelocityOfSelectedNotesDownByZPress2")
	return
}
shiftVelocityOfSelectedNotesDownByZPress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "shiftVelocityOfSelectedNotesDownByZPress3")
	return
}
shiftVelocityOfSelectedNotesDownByZPress3(inputNumber)		;126options_press3_rh
{
	global
	typical126OptionsPress3RH(inputNumber, "shiftVelocityOfSelectedNotesDownByZPress4", 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
	return
}
shiftVelocityOfSelectedNotesDownByZPress4(inputNumber)		;126options_press1_lh			;1st 16TH X-VALUE START
{
	global
	typical126OptionsPress1LH(inputNumber, "shiftVelocityOfSelectedNotesDownByZPress5")
	return
}
shiftVelocityOfSelectedNotesDownByZPress5(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "shiftVelocityOfSelectedNotesDownByZPress6")
	return
}
shiftVelocityOfSelectedNotesDownByZPress6(inputNumber)		;126options_press3_lh
{
	global
	typical126OptionsPress3LH(inputNumber, "shiftVelocityOfSelectedNotesDownByZPress7", 1, amountOfXCells)			;can't be more than 64 for this (4 bars).
	return
}
shiftVelocityOfSelectedNotesDownByZPress7(inputNumber)		;126options_press1_rh			;2ND 16TH X-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "shiftVelocityOfSelectedNotesDownByZPress8")
	return
}
shiftVelocityOfSelectedNotesDownByZPress8(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "shiftVelocityOfSelectedNotesDownByZPress9")
	return
}
shiftVelocityOfSelectedNotesDownByZPress9(inputNumber)		;126options_press3_rh_final
{
	global
	tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, 1, 126)			;range of 1-126 for velocity atm.
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, shiftVelocityOfSelectedNotesDownByZ
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
shiftVelocityOfSelectedNotesDownByZ:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	yToClick := newBottomPixel - ((inputStorageRefined[1] - 0) * sizeOf1GridUnitInPixelsY)
	xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[2] - 1) * sizeOf1GridUnitInPixelsX)
		;these two values were pointing to the top left corner of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	xToClick += 13
	yToClick += 10
	velocityToInput := inputStorageRefined[3]
	velocityToInputAlteredByValue := velocityToInput * 1.2569169960474308300395256916996	;velocity stays positive here, because that results in ableton reducing velocity.
	suspend, on
	tempForMouse := Format("{:d}", Round(yToClick + velocityToInputAlteredByValue))
	xToClickTemp := Format("{:d}", Round(xToClick))
	yToClickTemp := Format("{:d}", Round(yToClick))
	send, {alt down}
	mouseclickdrag, left, xToClickTemp, yToClickTemp, xToClickTemp, tempForMouse		;do i need to change the 'speed' option here in mouseclickdrag function? ie make it faster?
	send, {alt up}
	;notes stay selected here. should this be changed?
	suspend, off
	startPositionOfLastInputtedNoteInMidiClip64thNumberX := inputStorageRefined[2]
	tooltip, -%velocityToInput%, xToClick + 26, yToClick			;rewrite this to get rid of the 26 here.
return
shiftVelocityOfSelectedNotesUpByZPress1(inputNumber)		;126options_press1_rh			;1st 16TH Y-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "shiftVelocityOfSelectedNotesUpByZPress2")
	return
}
shiftVelocityOfSelectedNotesUpByZPress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "shiftVelocityOfSelectedNotesUpByZPress3")
	return
}
shiftVelocityOfSelectedNotesUpByZPress3(inputNumber)		;126options_press3_rh
{
	global
	typical126OptionsPress3RH(inputNumber, "shiftVelocityOfSelectedNotesUpByZPress4", 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
	return
}
shiftVelocityOfSelectedNotesUpByZPress4(inputNumber)		;126options_press1_lh			;1st 16TH X-VALUE START
{
	global
	typical126OptionsPress1LH(inputNumber, "shiftVelocityOfSelectedNotesUpByZPress5")
	return
}
shiftVelocityOfSelectedNotesUpByZPress5(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "shiftVelocityOfSelectedNotesUpByZPress6")
	return
}
shiftVelocityOfSelectedNotesUpByZPress6(inputNumber)		;126options_press3_lh
{
	global
	typical126OptionsPress3LH(inputNumber, "shiftVelocityOfSelectedNotesUpByZPress7", 1, amountOfXCells)			;can't be more than 64 for this (4 bars).
	return
}
shiftVelocityOfSelectedNotesUpByZPress7(inputNumber)		;126options_press1_rh			;2ND 16TH X-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "shiftVelocityOfSelectedNotesUpByZPress8")
	return
}
shiftVelocityOfSelectedNotesUpByZPress8(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "shiftVelocityOfSelectedNotesUpByZPress9")
	return
}
shiftVelocityOfSelectedNotesUpByZPress9(inputNumber)		;126options_press3_rh_final
{
	global
	tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, 1, 126)			;range of 1-126 for velocity atm.
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, shiftVelocityOfSelectedNotesUpByZ
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
shiftVelocityOfSelectedNotesUpByZ:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	yToClick := newBottomPixel - ((inputStorageRefined[1] - 0) * sizeOf1GridUnitInPixelsY)
	xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[2] - 1) * sizeOf1GridUnitInPixelsX)
		;these two values were pointing to the top left corner of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	xToClick += 13
	yToClick += 10
	velocityToInput := inputStorageRefined[3]
	velocityToInputAlteredByValue := velocityToInput * -1.2569169960474308300395256916996	;velocity made negative here, because that results in ableton increasing velocity.
	suspend, on
	tempForMouse := Format("{:d}", Round(yToClick + velocityToInputAlteredByValue))
	xToClickTemp := Format("{:d}", Round(xToClick))
	yToClickTemp := Format("{:d}", Round(yToClick))
	send, {alt down}
	mouseclickdrag, left, xToClickTemp, yToClickTemp, xToClickTemp, tempForMouse		;do i need to change the 'speed' option here in mouseclickdrag function? ie make it faster?
	send, {alt up}
	;notes stay selected here. should this be changed?
	suspend, off
	startPositionOfLastInputtedNoteInMidiClip64thNumberX := inputStorageRefined[2]
	tooltip, %velocityToInput%, xToClick + 26, yToClick			;rewrite this to get rid of the 26 here.
return
verticalNotePress1(inputNumber)		;126options_press1_rh			;1st Y-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "verticalNotePress2")
	return
}
verticalNotePress2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "verticalNotePress3")
	return
}
verticalNotePress3(inputNumber)		;126options_press3_rh
{
	global
	typical126OptionsPress3RH(inputNumber, "verticalNotePress4", 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
	return
}
verticalNotePress4(inputNumber)		;126options_press1_lh			;2nd Y-VALUE START
{
	global
	typical126OptionsPress1LH(inputNumber, "verticalNotePress5")
	return
}
verticalNotePress5(inputNumber)		;126options_press2_rh
{
	global
	typical126OptionsPress2RH(inputNumber, "verticalNotePress6")
	return
}
verticalNotePress6(inputNumber)		;126options_press3_lh
{
	global
	;used to be that vertical select would only work if you inputted top pitch before bottom pitch, with this line enforcing that:
	;typical126OptionsPress3LH(inputNumber, "verticalNotePress7", 1, inputStorageRefined[1])			;has to be <= first y-value.
	;now bottom pitch can be put first, or top pitch can be put first, doesn't matter, with this line:
	typical126OptionsPress3LH(inputNumber, "verticalNotePress7", 1, newNumberOfPixelsY)			;newNumberOfPixelsY = fixed at 58 atm.
	return
}
verticalNotePress7(inputNumber)		;126options_press1_rh			;ONLY X-VALUE START
{
	global
	typical126OptionsPress1RH(inputNumber, "verticalNotePress8")
	return
}
verticalNotePress8(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "verticalNotePress9")
	return
}
verticalNotePress9(inputNumber)		;126options_press3_rh_final
{
	global
	tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, 1, amountOfXCells)				;range of 1-48/64 for x value.
	if (tempFuncVar == 1)				;function succeeded.
	{
		gosub, addVerticalSelectToSelection
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
addVerticalSelectToSelection:
	tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip
	yToClick := newBottomPixel - ((inputStorageRefined[1] - 0) * sizeOf1GridUnitInPixelsY)
	yToClick2 := newBottomPixel - ((inputStorageRefined[2] - 0) * sizeOf1GridUnitInPixelsY)			;what happens when inputStorageRefined[1] and inputStorageRefined[2] are the same value?
	xToClick := pixelCoordOfFirstBarlineInMidiClip4BarSectionX + ((inputStorageRefined[3] - 1) * sizeOf1GridUnitInPixelsX)
		;these two values were pointing to the top left corner of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	xToClick += 13			;its going to select based on the middlepoint of 16ths, should be fine at the moment. when triplet input/smaller-than16th-input is added, will need to change this, probably.
	yToClick += 10
		;these two values were pointing to the top left corner of the 16th, so this adjustment puts the coordinates in the middle of the 16th instead. should rewrite the code later.
	xToClick2 += 13			;its going to select based on the middlepoint of 16ths, should be fine at the moment. when triplet input/smaller-than16th-input is added, will need to change this, probably.
	yToClick2 += 10
	suspend, on
	send, {shift down}		;shift is held down here so that multiple select macros can be executed in series.
	;unsure if {shift down} works with MouseClickDrag function in next line, need to test this.
	MouseClickDrag, left, xToClick, yToClick, xToClick + 1, yToClick2			;its "xToClick + 1" just to make select box 2 pixels wide.
		;should put in a check somewhere so that vertical select cant be inputted in out of bounds area.
	send, {shift up}
	suspend, off
return
BPMTyperMain(inputNumber)			;lh
{
	global
	if (inputNumber == 19)
	{
		gosub, switchToFourBarMidiClipStuff
	}
	else if (inputNumber == 6)
	{
		currentInputLayer := "BPMTyperChoice1Layer1"
	}
	else if (inputNumber == 9)
	{
		currentInputLayer := "BPMTyperChoice2Layer1"
	}
	else
	{
		gosub, incorrectSequenceInputted
	}
	return
}
BPMTyperChoice1Layer1(inputNumber)		;126options_press1_rh			;Choice1 does BPMs between 80 and 126, endpoints included.
{
	global
	typical126OptionsPress1RH(inputNumber, "BPMTyperChoice1Layer2")
	return
}
BPMTyperChoice1Layer2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "BPMTyperChoice1Layer3")
	return
}
BPMTyperChoice1Layer3(inputNumber)		;126options_press3_rh_final
{
	global
	tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, 80, 126)			;Choice1 does BPMs between 80 and 126, endpoints included.
	if (tempFuncVar == 1)				;function succeeded.
	{
		changeBPM(inputStorageRefined[1])
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
BPMTyperChoice2Layer1(inputNumber)		;126options_press1_rh			;Choice2 does BPMs between 127 and 199, endpoints included.
{
	global
	typical126OptionsPress1RH(inputNumber, "BPMTyperChoice2Layer2")
	return
}
BPMTyperChoice2Layer2(inputNumber)		;126options_press2_lh
{
	global
	typical126OptionsPress2LH(inputNumber, "BPMTyperChoice2Layer3")
	return
}
BPMTyperChoice2Layer3(inputNumber)		;126options_press3_rh_final
{
	global
	tempFuncVar := typical126OptionsPress3RHFinal(inputNumber, 27, 99)			;Choice2 does BPMs between 127 and 199, endpoints included.
	if (tempFuncVar == 1)				;function succeeded.
	{
		inputStorageRefined[1] += 100				;you input normal 126 options 27-99, endpoints included. and then 100 is added to make the values range between 127-199. this is just spread across these 2 different functions atm. NOTE SURE THIS ADDITION THING WORKS WITH ARRAYS.
		changeBPM(inputStorageRefined[1])
	}
	gosub, switchToFourBarMidiClipStuff
	return
}
changeBPM(bpmToChangeTo)
{
	global
	;tooltip		;get rid of any tooltip, so that mouse macros dont click on tooltip		;line didn't seem necessary here. bpm switcher is different screen region than tooltips will probably be appearing.
	suspend, on
	mousemove, abletonCoordToClickBPMSetterX, abletonCoordToClickTopRowButtonsY
	Click
	send % bpmToChangeTo
	send, {enter}			;don't know that this {enter} press is necessary.
	suspend, off
	return
}
calculateMultvar(inputVar1, inputVar3)
{
	global
	if (inputVar1 == 1)
	{
		if (inputVar3 == 1)
			multvar := 0
		else if (inputVar3 == 4)
			multvar := 1
	}
	else if (inputVar1 == 2)
	{
		if (inputVar3 == 2)
			multvar := 2
		else if (inputVar3 == 5)
			multvar := 3
	}
	else if (inputVar1 == 3)
	{
		if (inputVar3 == 3)
			multvar := 4
		else if (inputVar3 == 6)
			multvar := 5
	}
	else if (inputVar1 == 4)
	{
		if (inputVar3 == 1)
			multvar := 6
		else if (inputVar3 == 4)
			multvar := 7
		else if (inputVar3 == 7)
			multvar := 8
	}
	else if (inputVar1 == 5)
	{
		if (inputVar3 == 2)
			multvar := 9
		else if (inputVar3 == 5)
			multvar := 10
		else if (inputVar3 == 8)
			multvar := 11
	}
	else if (inputVar1 == 6)
	{
		if (inputVar3 == 3)
			multvar := 12
		else if (inputVar3 == 6)
			multvar := 13
		else if (inputVar3 == 9)
			multvar := 14
	}
	else if (inputVar1 == 7)
	{
		if (inputVar3 == 4)
			multvar := 15
		else if (inputVar3 == 7)
			multvar := 16
	}
	else if (inputVar1 == 8)
	{
		if (inputVar3 == 5)
			multvar := 17
		else if (inputVar3 == 8)
			multvar := 18
	}
	else if (inputVar1 == 9)
	{
		if (inputVar3 == 6)
			multvar := 19
		else if (inputVar3 == 9)
			multvar := 20
	}
	else
		multvar := -1				;this is used to trigger an invalid input check later
	return
}
return		;putting this here as a stop so all these hotkeys aren't triggered.
;function keys dont work on laptop
f1::
f2::
f3::
f4::
f5::
f6::
f7::
f8::
f9::
f10::
;f11::			;'f11': using this for fullscreen game atm
f12::
`::				;does this need to be escaped?
1::
;gosub, saveGdipBitmapToFile			;'1' press was the temporary save bitmap file shortcut, when this script was for gdip pixel drawing.
2::
3::
4::
5::
6::
7::
8::
9::
0::
-::
=::
Backspace::
Tab::
q::
w::
[::
]::
\::
CapsLock::
a::
'::
Enter::
LShift::
RShift::
LCtrl::
LWin::
LAlt::
RAlt::
RWin:
AppsKey::
RCtrl::
Left::
Up::
Right::
Down::
Delete::
PgUp::
PgDn::
return

End::
	suspend, permit ;this line just means the hotkey end-press doesn't get suspended. so that this keypress can be used to toggle suspend on and off.
	if (suspendVal == 0)
	{
		gdipCleanUpTrashAndDestroyWindow("fourBarGridOverlay")
		gdipCleanUpTrashAndDestroyWindow("mainLayerIndicator")
		suspendVal := 1
	}
	else
	{
		gosub, gdipDrawFourBarGridOverlay
		suspendVal := 0
	}
	suspend, toggle			;temp suspend key
return

;atm only key missing on laptop keyboard is entire top row (including the function keys, EXCEPT esc and delete), and laptop trackpad+clickers, and the fn key in bottom left corner.