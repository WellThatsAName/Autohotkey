/**
 On-Screen Picture Keyboard Overlay -- by WellThatsAName
 Version 2020-03-06 09-20
 Inspired by "On-Screen Keyboard" and OBS Input Overlay
 https://www.autohotkey.com/docs/scripts/KeyboardOnScreen.htm
 https://obsproject.com/forum/resources/input-overlay.552/
 This script creates a (partial) keyboard overlay at the bottom of your screen that shows
 the keys you are pressing in (almost) real time.
 I made it to help me to learn to control the move master.
 https://www.movemaster.biz/
 Simultanious key typing supported as far as the keyboard allows.
 The color and size of the on-screen keyboard can be customized at the top of the script.
 Also, you can double-click the tray icon to show or hide the overlay.
 Known limitations: Some keys can not be used, e.g. 'Ü', '+'
*/
; Keywords: Borderless overlay; Borderless window; Keyboard Overlay; Input Overlay; On-Screen Overlay


#SingleInstance force  ; script is allowed to run only one at a time. Skips the dialog box, replaces the old instance automatically
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


/**
 Configuration Section Start
*/

k_keyColorFirst = 2 ;choose 1 or 2 as the first color
k_keyspreset = 1 ;predefined keys selection; see subfolders in images\keys; use number only; only 1-9

k_KeyHeight = 40  ; Changing this key height size will make the entire on-screen keyboard get larger or smaller
k_KeyZoom = 1.0  ; Workaround: if replacement keys are too small or too big, specify a zoom factor other than 1.0

; Position
b_showLeft = 1
b_showCenter = 0
b_showRight = 0

;keys to listen for
a_keysToWatch := ["1", "2", "3", "4", "5", "Q", "W", "E", "R", "A", "S", "D", "F", "C", "Space", "Tab", "Shift", "Ctrl"]


; Names for the tray menu items
k_MenuItemHide = Hide on-screen keyboard overlay
k_MenuItemShow = Show on-screen keyboard overlay

; To have the keyboard appear on a monitor other than the primary, specify a number such as 2 for the following variable. 
; Leave it blank to use the primary
k_Monitor =


/**
 End of configuration section.
 Don't change anything below!
*/


k_keyColorSecond := k_keyColorFirst = 1 ? 2 : 1
k_bgColor := k_keyColorFirst = 1 ? "000000" : "FFFFFF"

k_tray_icon = images\icon_keyboard_left.png

for index, element in a_keysToWatch ; Enumeration is the recommended approach in most cases.
{
	; each key has two color images. Set paths
	key_%element%_colorFirst := "images\keys\preset" . k_keyspreset . "\" . element . k_keyColorFirst . ".png"
	key_%element%_colorSecond := "images\keys\preset" . k_keyspreset . "\" . element . k_keyColorSecond . ".png"

	;first state of each key is "not pressed" a.k.a. 0
	key_state_%element% := 0
}


;---- Alter the tray icon menu
Menu, Tray, Add, %k_MenuItemHide%, k_ShowHide
Menu, Tray, Add, &Exit, k_MenuExit
Menu, Tray, Default, %k_MenuItemHide%
Menu, Tray, NoStandard

Menu, Tray, Add
Menu, Tray, Icon, %k_tray_icon%


;---- Calculate object dimensions based on chosen key size
k_KeyWidth = %k_KeyHeight%
;use zoom workaround to prevent small button replacements
k_KeyWidth2Set := k_KeyWidth * k_KeyZoom
;use zoom workaround to prevent small button replacements
k_KeyHeight2Set := k_KeyHeight * k_KeyZoom
k_KeyMargin = %k_KeyHeight%
k_KeyMargin /= 20
k_SpacebarWidth = %k_KeyWidth%
;k_SpacebarWidth *= 4.2
k_SpacebarWidth *= 3.0

;use zoom workaround to prevent small/big button replacements
k_SpacebarWidth2Set := k_SpacebarWidth * k_KeyZoom
k_KeyWidthHalf = %k_KeyWidth%
k_KeyWidthHalf /= 2

k_KeySize = w%k_KeyWidth% h%k_KeyHeight%
k_KeySizeAlternative = *w%k_KeyWidth% *h%k_KeyHeight%
k_KeyPositionNext = x+%k_KeyMargin% %k_KeySize%
k_KeyPositionNextRow = xm y+%k_KeyMargin% %k_KeySize%

;---- Create a GUI window for the on-screen keyboard overlay
Gui, Font, s10 Bold, Verdana
Gui, -Caption +AlwaysOnTop +ToolWindow
Gui Margin, 0, 0
Gui, Color, %k_bgColor%  ; This color will be made transparent later below.

;---- Add a button for each key. Position the first button with absolute
; coordinates so that all other buttons can be positioned relative to it:
Gui, Add, Picture, %k_KeyPositionNextRow% +BackgroundTrans vpic_1, %key_1_colorFirst%
Gui, Add, Picture, %k_KeyPositionNext% +BackgroundTrans vpic_2, %key_2_colorFirst%
Gui, Add, Picture, %k_KeyPositionNext% +BackgroundTrans vpic_3, %key_3_colorFirst%
Gui, Add, Picture, %k_KeyPositionNext% +BackgroundTrans vpic_4, %key_4_colorFirst%
Gui, Add, Picture, %k_KeyPositionNext% +BackgroundTrans vpic_5, %key_5_colorFirst%

Gui, Add, Picture, %k_KeyPositionNextRow% +BackgroundTrans vpic_Tab, %key_Tab_colorFirst%
Gui, Add, Picture, %k_KeyPositionNext% +BackgroundTrans vpic_q, %key_q_colorFirst%
Gui, Add, Picture, %k_KeyPositionNext% +BackgroundTrans vpic_w, %key_w_colorFirst%
Gui, Add, Picture, %k_KeyPositionNext% +BackgroundTrans vpic_e, %key_e_colorFirst%
Gui, Add, Picture, %k_KeyPositionNext% +BackgroundTrans vpic_r, %key_r_colorFirst%

Gui, Add, Picture, %k_KeyPositionNextRow% +BackgroundTrans vpic_Shift, %key_Shift_colorFirst%

Gui, Add, Picture, %k_KeyPositionNext% +BackgroundTrans vpic_a, %key_a_colorFirst%
Gui, Add, Picture, %k_KeyPositionNext% +BackgroundTrans vpic_s, %key_s_colorFirst%
Gui, Add, Picture, %k_KeyPositionNext% +BackgroundTrans vpic_d, %key_d_colorFirst%
Gui, Add, Picture, %k_KeyPositionNext% +BackgroundTrans vpic_f, %key_f_colorFirst%

Gui, Add, Picture, %k_KeyPositionNextRow% +BackgroundTrans vpic_Ctrl, %key_Ctrl_colorFirst%
Gui, Add, Picture, %k_KeyPositionNext% +BackgroundTrans vpic_c, %key_c_colorFirst%
Gui, Add, Picture, x+%k_KeyMargin% w%k_SpacebarWidth% h%k_KeyHeight% +BackgroundTrans vpic_Space, %key_Space_colorFirst%


;---- Show the window
Gui, Show
k_IsVisible = y

WinGet, k_ID, ID, A   ; Get its window ID.
WinGetPos,,, k_WindowWidth, k_WindowHeight, A

;---- Position the keyboard at the bottom of the screen (taking into account the position of the taskbar)
SysGet, k_WorkArea, MonitorWorkArea, %k_Monitor%

; Calculate window's X-position:
if b_showLeft
{
	k_WindowX = 0
}
if b_showCenter
{
	k_WindowX = %k_WorkAreaRight%
	k_WindowX -= %k_WorkAreaLeft%  ; Now k_WindowX contains the width of this monitor.
	k_WindowX -= %k_WindowWidth%
	k_WindowX /= 2  ; Calculate position to center it horizontally.
	; The following is done in case the window will be on a non-primary monitor
	; or if the taskbar is anchored on the left side of the screen:
	k_WindowX += %k_WorkAreaLeft%
}
if b_showRight
{
	k_WindowX = %k_WorkAreaRight%
	k_WindowX -= %k_WindowWidth%
}

;---- Calculate window's Y-position
k_WindowY = %k_WorkAreaBottom%
k_WindowY -= %k_WindowHeight%

WinMove, A,, %k_WindowX%, %k_WindowY%

WinSet, AlwaysOnTop, On, ahk_id %k_ID%
WinSet, TransColor, %k_bgColor%, ahk_id %k_ID%


;---- Watching for keys pressed every 0.1 seconds
SetTimer, CheckKeysPressed, 100

return ; End of auto-execute section.







k_ShowHide:
if k_IsVisible = y
{
	Gui, Cancel
	Menu, Tray, Rename, %k_MenuItemHide%, %k_MenuItemShow%
	k_IsVisible = n
}
else
{
	Gui, Show
	Menu, Tray, Rename, %k_MenuItemShow%, %k_MenuItemHide%
	k_IsVisible = y
}
return


CheckKeysPressed:
for index, element in a_keysToWatch ; Enumeration is the recommended approach in most cases.
{	
	key_current_state := GetKeyState(element,"P") ;0(not pressed) or 1(pressed)
	nameit := "key_state_" . element ;preparing to save current state to previous state; e.g. key_state_A
	
	key_previous_state := % %nameit% ;key_previous_state := key_state_A; forced expression, see https://stackoverflow.com/questions/17498589/autohotkey-assign-a-text-expression-to-a-variable#17498698
	
	if (key_current_state<>key_previous_state)
	{
		;MsgBox, key %element% has changed
		%nameit% := key_current_state
		
		my_string := "~*" . element
		
		if (key_current_state=1)
		{			
			keyPressed(my_string)
		}
		else
		{
			keyReleased(my_string)
		}
	}
}
return


;---- When a key is pressed by the user, switch the corresponding button images
keyPressed(MyHotkey)
{
global k_SpacebarWidth2Set
global k_KeyWidth2Set
global k_KeyHeight2Set

	StringReplace, k_ThisHotkey, MyHotkey, ~
	StringReplace, k_ThisHotkey, k_ThisHotkey, *
	SetTitleMatchMode, 3  ; Prevents the T and B keys from being confused with Tab and Backspace.

	If k_ThisHotkey = Space
	{
	k_KeyWidthAlternative := k_SpacebarWidth2Set
	}
	else
	{
	k_KeyWidthAlternative := k_KeyWidth2Set
	}
	buttonInSecondColor:= key_%k_ThisHotkey%_colorSecond
	GuiControl,, pic_%k_ThisHotkey%, *w%k_KeyWidthAlternative% *h%k_KeyHeight2Set% %buttonInSecondColor%
	Return
}

;---- When a key is released by the user, switch the corresponding button images
keyReleased(MyHotkey)
{
global k_SpacebarWidth2Set
global k_KeyWidth2Set
global k_KeyHeight2Set

	StringReplace, k_ThisHotkey, MyHotkey, ~
	StringReplace, k_ThisHotkey, k_ThisHotkey, *
	SetTitleMatchMode, 3  ; Prevents the T and B keys from being confused with Tab and Backspace.

	If k_ThisHotkey = Space
	{
	k_KeyWidthAlternative := k_SpacebarWidth2Set
	}
	else
	{
	k_KeyWidthAlternative := k_KeyWidth2Set
	}
	buttonInFirstColor:= key_%k_ThisHotkey%_colorFirst
	GuiControl,, pic_%k_ThisHotkey%, *w%k_KeyWidthAlternative% *h%k_KeyHeight2Set% %buttonInFirstColor%
	Return
}

GuiClose:
k_MenuExit:
ExitApp