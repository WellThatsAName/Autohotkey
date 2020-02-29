#SingleInstance force  ; script is allowed to run only one at a time. Skips the dialog box, replaces the old instance automatically
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; On-Screen Picture Mouse Overlay -- by WellThatsAName
; This script creates a mouse at the bottom of your screen that shows
; the buttons pressed in real time.
; Simultanious button pressing supported.
; The size and position of the mouse can be customized at the top of the script. Also, you
; can double-click the tray icon to show or hide the overlay.
; Known limitations: so far only two buttons included

;---- Configuration Section: Customize the size of the overlay

; Changing this mouse width size will make the entire on-screen mouse get
; larger or smaller:
k_MouseWidth = 100
;Workaround: if replacement images are too small or too big, specify a zoom factor other than 1.0
k_MouseZoom = 1.0

; To have the overlay appear on a monitor other than the primary, specify
; a number such as 2 for the following variable.  Leave it blank to use
; the primary:
k_Monitor =

b_showLeft = 1
b_showCenter = 0
b_showRight = 0

k_position_offset = 290

;predefined keys selection; see subfolders in keys/mouse; use number only; only 1-9
k_mousepreset = 1


;a_mousebuttons_to_watch := ["LButton", "RButton", "MButton", "XButton1", "XButton2", "WheelDown", "WheelUp"]
;a_mousebuttons_to_watch := ["LButton", "RButton", "MButton", "XButton1", "XButton2", "WheelDown", "WheelUp", "WheelLeft", "WheelRight"]
a_mousebuttons_to_watch := ["LButton","RButton"]

k_tray_icon = images\icon_mouse.png

; Names for the tray menu items:
k_MenuItemHide = Hide on-screen mouse overlay
k_MenuItemShow = Show on-screen mouse overlay

;---- End of configuration section.  Don't change anything below this point


completemouse := "images\mouse\preset" . k_mousepreset . "\completemouse.png"
for index, mousebutton in a_mousebuttons_to_watch ; Enumeration is the recommended approach in most cases.
{	
	; each mousebutton has two colors: first color file ends with 1, second with 2
	mb_%mousebutton%2 := "images\mouse\preset" . k_mousepreset . "\mousebutton" . mousebutton . "2.png"
	
	;first state of each mouse button is "not pressed" a.k.a. 0
	mouse_state_%mousebutton% := 0
}
;MsgBox, mb_LButton2 %mb_LButton2%


;---- Alter the tray icon menu:
Menu, Tray, Add, %k_MenuItemHide%, k_ShowHide
Menu, Tray, Add, &Exit, k_MenuExit
Menu, Tray, Default, %k_MenuItemHide%
Menu, Tray, NoStandard

Menu, Tray, Add
Menu, Tray, Icon, %k_tray_icon%

;---- Calculate object dimensions based on chosen mouse width
k_MouseHeight := k_MouseWidth * 1.7418
;use zoom workaround to prevent small button replacements
k_MouseHeight2Set := k_MouseHeight * k_MouseZoom
;use zoom workaround to prevent small button replacements
k_MouseWidth2Set := k_MouseWidth * k_MouseZoom

k_MouseSize = w%k_MouseWidth% h%k_MouseHeight%

;---- Create a GUI window for the mouse overlay
Gui, Font, s10 Bold, Verdana
Gui, -Caption +AlwaysOnTop +E0x200 +ToolWindow
Gui Margin, 0, 0
TransColor = F1ECED
Gui, Color, %TransColor%  ; This color will be made transparent later below.

;---- Add an image for mouse and each button.
Gui, Add, Picture, x0 y0 %k_MouseSize% +BackgroundTrans, %completemouse%
Gui, Add, Picture, x0 y0 %k_MouseSize% +BackgroundTrans vmb_LButton hidden, %mb_LButton2%
Gui, Add, Picture, x0 y0 %k_MouseSize% +BackgroundTrans vmb_RButton hidden, %mb_RButton2%

;---- Show the window:
Gui, Show
k_IsVisible = y

WinGet, k_ID, ID, A   ; Get its window ID.
WinGetPos,,, k_WindowWidth, k_WindowHeight, A

;---- Position the overlay  at the bottom of the screen (taking into account
; the position of the taskbar):
SysGet, k_WorkArea, MonitorWorkArea, %k_Monitor%

; Calculate window's X-position:
if b_showLeft
{
	k_WindowX = 0
	k_WindowX += %k_position_offset%
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
	k_WindowX += %k_position_offset%
}
if b_showRight
{
	k_WindowX = %k_WorkAreaRight%
	k_WindowX -= %k_WindowWidth%
	k_WindowX += %k_position_offset%
}

; Calculate window's Y-position:
k_WindowY = %k_WorkAreaBottom%
k_WindowY -= %k_WindowHeight%

WinMove, A,, %k_WindowX%, %k_WindowY%
WinSet, AlwaysOnTop, On, ahk_id %k_ID%
WinSet, TransColor, %TransColor% 220, ahk_id %k_ID%


SetTimer, CheckMousePressed, 99

return ; End of auto-execute section.

CheckMousePressed:
a_mouse_states := StrSplit(mouse_state)
for index, mousebutton in a_mousebuttons_to_watch
{
	mouse_current_state := GetKeyState(mousebutton,"P") ;0(not pressed) or 1(pressed)
	;MsgBox, mouse %mousebutton% has state %mouse_current_state%
	nameit := "mouse_state_" . mousebutton ;preparing to save current state to previous state; e.g. mouse_state_A
	
	mouse_previous_state := % %nameit% ;mouse_previous_state := mouse_state_A; forced expression, see https://stackoverflow.com/questions/17498589/autohotkey-assign-a-text-expression-to-a-variable#17498698
	;MsgBox % %nameit%
	
	if (mouse_current_state<>mouse_previous_state)
	{
		;MsgBox, mouse %mousebutton% has changed
		%nameit% := mouse_current_state
		
		if (mouse_current_state=1)
		{			
			mousePressed(mousebutton)
		}
		else
		{
			mouseReleased(mousebutton)
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

;---- When a mouse button is pressed by the user, click the corresponding button on-screen:
mousePressed(mousebutton)
{
global k_MouseHeight
global k_MouseWidth
	
	;GuiControl,, mb_%mousebutton%, *w%k_MouseWidth% *h%k_MouseHeight% %buttonInSecondColor%
	GuiControl Show w200 h200, mb_%mousebutton%
	Return
}
;---- When a mouse button is released by the user, release the corresponding button on-screen:
mouseReleased(mousebutton)
{
global k_MouseHeight
global k_MouseWidth
	
	;GuiControl,, mb_%mousebutton%, *w%k_MouseWidth% *h%k_MouseHeight% %buttonInFirstColor%
	GuiControl Hide, mb_%mousebutton%
	Return
}




GuiClose:
k_MenuExit:
ExitApp