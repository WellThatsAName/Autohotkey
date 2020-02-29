#SingleInstance force  ; script is allowed to run only one at a time. Skips the dialog box, replaces the old instance automatically
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; On-Screen Picture Keyboard Overlay -- by WellThatsAName, inspired by "On-Screen Keyboard"
; https://www.autohotkey.com/docs/scripts/KeyboardOnScreen.htm
; This script creates a (partial) keyboard at the bottom of your screen that shows
; the keys you are pressing in real time. I made it to help me to learn to
; control the move master.  https://www.movemaster.biz/
; Simultanious key typing supported as far as the keyboard allows.
; The size of the on-screen keyboard can be customized at the top of the script. Also, you
; can double-click the tray icon to show or hide the overlay.
; Known limitations: Some keys can not be used, e.g. 'Ü', '+'


;---- Configuration Section


k_KeyHeight = 40  ; Changing this key height size will make the entire on-screen keyboard get larger or smaller
k_KeyZoom = 1.2  ; Workaround: if replacement keys are too small or too big, specify a zoom factor other than 1.0

; To have the keyboard appear on a monitor other than the primary, specify a number such as 2 for the following variable. 
; Leave it blank to use the primary
k_Monitor =

; Position
b_showLeft = 1
b_showCenter = 0
b_showRight = 0

;predefined keys selection; see subfolders in images\keys; use number only; only 1-9
k_keyspreset = 1

;keys to listen for
a_keysToWatch := ["1", "2", "3", "4", "5", "Q", "W", "E", "R", "A", "S", "D", "F", "C", "Space", "Tab", "Shift", "Ctrl"]

;a_keysToWatch := ["1", "2", "3", "4", "5", "Q", "W", "E", "R", "T", "Z", "U", "I", "O", "P", "Ü", "A", "S", "D", "F", "G", "H", "J", "K", "L", "Ö", "Ä", "#", "Space", "Enter", "Tab","Backspace", "Shift", "Ctrl", "Alt", "Win"]
;a_keysToWatch := ["A"]

;chose 1 or 2 as the first color
k_keyColorFirst = 2
k_keyColorSecond := k_keyColorFirst = 1 ? 2 : 1

; Names for the tray menu items
k_MenuItemHide = Hide on-screen keyboard overlay
k_MenuItemShow = Show on-screen keyboard overlay


;---- End of configuration section.  Don't change anything below this point



k_tray_icon = images\icon_keyboard_left.png

k_keyColorSecond := k_keyColorFirst = 1 ? 2 : 1

for index, element in a_keysToWatch ; Enumeration is the recommended approach in most cases.
{	
	; each key has two colors: first color ends with 1, second with 2
	key_%element%_colorFirst := "images\keys\preset" . k_keyspreset . "\" . element . k_keyColorFirst . ".png"
	key_%element%_colorSecond := "images\keys\preset" . k_keyspreset . "\" . element . k_keyColorSecond . ".png"

	;first state of each key is "not pressed" a.k.a. 0
	key_state_%element% := 0
}


;---- Alter the tray icon menu:
Menu, Tray, Add, %k_MenuItemHide%, k_ShowHide
Menu, Tray, Add, &Exit, k_MenuExit
Menu, Tray, Default, %k_MenuItemHide%
Menu, Tray, NoStandard

Menu, Tray, Add
Menu, Tray, Icon, %k_tray_icon%


;---- Calculate object dimensions based on chosen font size:
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

;use zoom workaround to prevent small button replacements
k_SpacebarWidth2Set := k_SpacebarWidth * k_KeyZoom
k_KeyWidthHalf = %k_KeyWidth%
k_KeyWidthHalf /= 2

k_KeySize = w%k_KeyWidth% h%k_KeyHeight%
k_KeySizeAlternative = *w%k_KeyWidth% *h%k_KeyHeight%
k_Position = x+%k_KeyMargin% %k_KeySize%
k_PositionAlternative = xm y+%k_KeyMargin% %k_KeySize%

;---- Create a GUI window for the on-screen keyboard:
Gui, Font, s10 Bold, Verdana
Gui, -Caption +E0x200 +ToolWindow
TransColor = F1ECED
Gui, Color, %TransColor%  ; This color will be made transparent later below.

;---- Add a button for each key. Position the first button with absolute
; coordinates so that all other buttons can be positioned relative to it:
Gui, Add, Picture, %k_PositionAlternative% vpic_1, %key_1_colorFirst%
Gui, Add, Picture, %k_Position% vpic_2, %key_2_colorFirst%
Gui, Add, Picture, %k_Position% vpic_3, %key_3_colorFirst%
Gui, Add, Picture, %k_Position% vpic_4, %key_4_colorFirst%
Gui, Add, Picture, %k_Position% vpic_5, %key_5_colorFirst%

Gui, Add, Picture, %k_PositionAlternative% vpic_Tab, %key_Tab_colorFirst%
Gui, Add, Picture, %k_Position% vpic_q, %key_q_colorFirst%
Gui, Add, Picture, %k_Position% vpic_w, %key_w_colorFirst%
Gui, Add, Picture, %k_Position% vpic_e, %key_e_colorFirst%
Gui, Add, Picture, %k_Position% vpic_r, %key_r_colorFirst%

Gui, Add, Picture, %k_PositionAlternative% vpic_Shift, %key_Shift_colorFirst%

Gui, Add, Picture, %k_Position% vpic_a, %key_a_colorFirst%
Gui, Add, Picture, %k_Position% vpic_s, %key_s_colorFirst%
Gui, Add, Picture, %k_Position% vpic_d, %key_d_colorFirst%
Gui, Add, Picture, %k_Position% vpic_f, %key_f_colorFirst%

Gui, Add, Picture, %k_PositionAlternative% vpic_Ctrl, %key_Ctrl_colorFirst%
Gui, Add, Picture, %k_Position% vpic_c, %key_c_colorFirst%
Gui, Add, Picture, x+%k_KeyMargin% w%k_SpacebarWidth% h%k_KeyHeight% vpic_Space, %key_Space_colorFirst%


;---- Show the window:
Gui, Show
k_IsVisible = y

WinGet, k_ID, ID, A   ; Get its window ID.
WinGetPos,,, k_WindowWidth, k_WindowHeight, A

;---- Position the keyboard at the bottom of the screen (taking into account
; the position of the taskbar):
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

; Calculate window's Y-position:
k_WindowY = %k_WorkAreaBottom%
k_WindowY -= %k_WindowHeight%

WinMove, A,, %k_WindowX%, %k_WindowY%
WinSet, AlwaysOnTop, On, ahk_id %k_ID%
WinSet, TransColor, %TransColor% 220, ahk_id %k_ID%


SetTimer, CheckKeysPressed, 100


return ; End of auto-execute section.



CheckKeysPressed:
for index, element in a_keysToWatch ; Enumeration is the recommended approach in most cases.
{
    ; Using "Loop", indices must be consecutive numbers from 1 to the number
    ; of elements in the array (or they must be calculated within the loop).
    ; MsgBox % "Element number " . A_Index . " is " . Array[A_Index]

    ; Using "for", both the index (or "key") and its associated value
    ; are provided, and the index can be *any* value of your choosing.
    ;MsgBox % "Element number " . index . " is " . element
	
	key_current_state := GetKeyState(element,"P") ;0(not pressed) or 1(pressed)
	;MsgBox, key %element% has state %key_current_state%
	nameit := "key_state_" . element ;preparing to save current state to previous state; e.g. key_state_A
	
	key_previous_state := % %nameit% ;key_previous_state := key_state_A; forced expression, see https://stackoverflow.com/questions/17498589/autohotkey-assign-a-text-expression-to-a-variable#17498698
	;MsgBox % %nameit%
	
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


;---- When a key is pressed by the user, click the corresponding button on-screen:
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
;---- When a key is released by the user, release the corresponding button on-screen:
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