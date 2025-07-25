#Requires AutoHotkey v2.0

; Some macros for Starfield

#HotIf WinActive("ahk_exe Starfield.exe") ; Run only if Starfield is active
#SingleInstance Force ;Run only one instance

/*
Hotkeys
Reactive Shield = F2 - re-casts every x seconds. Effectively God mode at NG+10. Assumes '6' key is defined for Reactive Shield shortcut
Hold Shift = F6
Vehicle Flight = F7 - "Flight" mode for vehicles with infinite or extended boost
Release any held keys = F11 - releases Shift and Space
Invisibility = F12 - Void Form. Assumes '9' key is defined for Void Form shortcut

Adjust parameters below as required. Delay in ms before re-casting. The timings are for NG+10
*/

; ======================================

; Timings
ShieldTime := 16000
InvisibilityTime := 45000

; Keys - adjust as required
ReactiveShieldKey := 6
InvisibilityKey := 9

; Flight Parameters
MaxFlightTime := 5000 ; Maximum flight time in ms
MinFlightTime := 500 ; Minimum flight time in ms
FlightStep := 250 ; Step size for flight time adjustment in ms
FlightWaitTime := 500 ; Wait time after flight before checking toggle again
DefaultFlightTime := 3000 ; Default flight time in ms
MinFlightWaitTime := 250 ; Minimum wait time in ms
MaxFlightWaitTime := 3000 ; Maximum wait time in ms
DelayStep := 250 ; Step size for delay time adjustment in ms
FlightTime := DefaultFlightTime ; Set initial flight time to default

; End of parameters, start of code below
; ======================================

SetKeyDelay 50, 50
SendMode("Event")

ShowStatus(msg) ; Status messages
{
    ToolTip(msg, A_ScreenWidth - 200, A_ScreenHeight - 60) ; Display at bottom right hand corner of screen
    SetTimer(() => ToolTip(), -2000) ; Remove tooltip after 2 seconds
}

; Flight Presets
*NumpadEnd:: ; Low Preset
{
    global FlightTime, FlightWaitTime
    FlightTime := MinFlightTime
    FlightWaitTime := MaxFlightWaitTime
    ShowStatus("Low")
}

*NumpadLeft:: ; Medium Preset
{
    global FlightTime, FlightWaitTime
    FlightTime := MaxFlightTime / 2
    FlightWaitTime := MinFlightWaitTime + DelayStep
    ShowStatus("Medium")
}

*NumpadHome:: ; High Preset
{
    global FlightTime, FlightWaitTime
    FlightTime := MaxFlightTime
    FlightWaitTime := MinFlightWaitTime
    ShowStatus("High")
}

*NumpadRight:: ; Minimum Flight Wait Time
{
    global FlightWaitTime

    FlightWaitTime := MinFlightWaitTime ; Set minimum flight wait time
    ShowStatus("Flight Wait Time Minimum")
}

*Numpad5:: ; Show Flight Parameters
{
    global FlightTime, FlightWaitTime
    ShowStatus("Flight Time: " . FlightTime / 1000 . " seconds" . " | Flight Wait Time: " . FlightWaitTime / 1000 .
        " seconds") ; display current flight time and wait time
}

*NumpadPgup:: ; Reduce delay time
{
    global FlightWaitTime
    if FlightWaitTime > MinFlightWaitTime
        FlightWaitTime := FlightWaitTime - DelayStep ; reduce flight time
    else
        FlightWaitTime := MinFlightWaitTime ; set minimum flight delay time
    ShowStatus("Flight Wait Time: " . FlightWaitTime / 1000 . " seconds") ; display current flight time

}

*NumpadPgdn:: ; Increase delay time
{
    global FlightWaitTime
    if FlightWaitTime < MaxFlightWaitTime
        FlightWaitTime := FlightWaitTime + DelayStep ; increase flight time
    else
        FlightWaitTime := MaxFlightWaitTime ; set maximum flight delay time
    ShowStatus("Flight Wait Time: " . FlightWaitTime / 1000 . " seconds") ; display current flight time
}

*NumpadUp:: ; Increase boost time
{
    global flightTime, FlightWaitTime
    if flightTime < MaxFlightTime
    {
        flightTime := flightTime + FlightStep ; increase flight time by 1 second if the Up key is pressed
        FlightWaitTime := FlightWaitTime - DelayStep ; increase flight wait time by 1 second
        if FlightWaitTime < MinFlightWaitTime
            FlightWaitTime := MinFlightWaitTime ; ensure wait time does not go below minimum
    }
    else
        flightTime := MaxFlightTime ; reset to default flight time if neither key is pressed

    ShowStatus("Flight Time: " . flightTime / 1000 . " seconds" . "Flight Wait Time: " . FlightWaitTime / 1000 .
        " seconds") ; display current flight time
}

*NumpadDown:: ; Reduce boost time
{
    global flightTime, FlightWaitTime
    if flightTime > MinFlightTime
    {
        flightTime := flightTime - FlightStep ; reduce flight time by 1 second if the Down key is pressed
        FlightWaitTime := FlightWaitTime + DelayStep ; increase flight wait time by 1 second
        if FlightWaitTime > MaxFlightWaitTime
            FlightWaitTime := MaxFlightWaitTime ; ensure wait time does not go above maximum
    }
    else
        flightTime := MinFlightTime ; set minimum flight time to 1 second

    ShowStatus("Flight Time: " . flightTime / 1000 . " seconds" . "Flight Wait Time: " . FlightWaitTime / 1000 .
        " seconds") ; display current flight time
}

*F2:: ; Reactive Shield
{
    static toggle := false
    SetTimer(Shield, 30 * (toggle ^= 1))
    if toggle
        ShowStatus("Shield On")
    else
        ShowStatus("Shield Off")

    Shield()
    {
        Sleep(50)
        SendEvent(ReactiveShieldKey) ; Reactive key shortcut
        Sleep(100)
        SendEvent('z') ; Activate power
        Sleep(ShieldTime)
    }
}

*F6:: ; Hold Shift
{
    static ShiftToggle := false
    ShiftToggle := !ShiftToggle ; Toggle the state of Shift

    if ShiftToggle
    {
        SendEvent("{LShift Down}") ; Hold down Left Shift
        ShowStatus("Shift Held")
    }
    else
    {
        SendEvent("{LShift Up}") ; Release Left Shift
        ShowStatus("Shift Released")
    }
}

*F11:: ;Release any held keys
{
    Send("{LShift Up}") ; Release Shift
    Send("{Space Up}") ; Release Space
    SetCapsLockState false
    SetNumLockState false
    SetScrollLockState false
    ShowStatus("Keys Released")
}

*F12:: ; Invisibility
{
    static toggle := false
    SetTimer(Invisibility, 30 * (toggle ^= 1))
    if toggle
        ShowStatus("Invisibility On")
    else
        ShowStatus("Invisibility Off")

    Invisibility()
    {
        Sleep(50)
        SendEvent(InvisibilityKey) ; Void Form shortcut
        Sleep(100)
        SendEvent('z') ; Activate power
        Sleep(InvisibilityTime)
    }
}

*F7:: Flight() ; Vehicle Flight Mode
; This function toggles flight mode on and off, allowing for extended flight duration in vehicles. Requires a suitably modded vehicle.

Flight()
{
    global flightTime, FlightWaitTime
    static toggle := false ; declare the toggle
    toggle := !toggle ; flip the toggle
    if toggle
    {
        ShowStatus("Flight Mode On")
        SetTimer(selfRunningInterruptibleSeq, -1) ; run the function once immediately
    }

    selfRunningInterruptibleSeq()
    {
        Send("{LShift Down}") ; Hold down Left Shift
        Sleep(100)
        Send("{Space Down}") ; Hold down Space

        Sleep flightTime ; Keep keys held down for x seconds
        Send("{Space Up}") ; Release Space
        Sleep(FlightWaitTime) ; Wait for FlightWaitTime seconds before checking the toggle again

        ; check if the toggle is off to run post-conditions and end the function early
        if !toggle
        {
            ShowStatus("Flight Mode Off")
            Send("{LShift Up}") ; Release Shift
            return ; end the function
        }

        ; check if the toggle is still on at the end to rerun the function
        if toggle
        {
            SetTimer(selfRunningInterruptibleSeq, -1) ; go again if the toggle is still active
        }
    }
}
