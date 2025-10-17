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
MaxFlightTime := 1000 ; Maximum flight time in ms
MinFlightTime := 100 ; Minimum flight time in ms
FlightStep := 50 ; Step size for flight time adjustment in ms
DefaultFlightTime := 2000 ; Default flight time in ms
MinDelayTime := 0 ; Minimum wait time in ms
MaxDelayTime := 2000 ; Maximum wait time in ms
DelayTime := MinDelayTime ; Wait time after flight before checking toggle again
DelayStep := 50 ; Step size for delay time adjustment in ms
FlightTime := DefaultFlightTime ; Set initial flight time to default
StoredFlightTime := FlightTime
StoredDelayTime := DelayTime

; End of parameters, start of code below
; ======================================

SetKeyDelay 50, 50
SendMode("Event")

ShowStatus(msg) ; Status messages
{
    ToolTip(msg, A_ScreenWidth - 200, A_ScreenHeight - 60) ; Display at bottom right hand corner of screen
    SetTimer(() => ToolTip(), -5000) ; Remove tooltip after 5 seconds
}

ShowParams(msg) {
    global FlightTime, DelayTime
    ShowStatus(msg . " - Vertical Boost: " . FlightTime . " ms " . " | Delay: " . DelayTime . " ms") ; display current flight time and wait time
}

; Flight Presets
*NumpadEnd:: ; Low Preset
{
    global FlightTime, DelayTime
    FlightTime := MinFlightTime + 200
    DelayTime := MaxDelayTime
    ShowParams("Low Preset ")
}

*NumpadLeft:: ; Medium Preset
{
    global FlightTime, DelayTime
    FlightTime := MaxFlightTime - (MaxFlightTime // 5)
    DelayTime := MaxDelayTime // 4
    ShowParams("Medium Preset ")
}

*NumpadHome:: ; High Preset
{
    global FlightTime, DelayTime
    FlightTime := MaxFlightTime
    DelayTime := MinDelayTime
    ShowParams("High Preset ")
}

*F4:: ; Continuous Boost (Space + Shift)
{
    static MaxToggle := false
    MaxToggle := !MaxToggle ; Toggle the state of Space/Shift

    if MaxToggle {
        SendEvent("{Space Down}") ; Hold down Space
        SendEvent("{LShift Down}") ; Hold down Left Shift
        ShowStatus("Continuous Boost")
    }
    else {
        SendEvent("{Space Up}") ; Release Space
        SendEvent("{LShift Up}") ; Release Left Shift

        ShowStatus("Continuous Boost Off")
    }

}

*NumpadRight:: ; Minimum Flight Wait Time
{
    global DelayTime

    DelayTime := MinDelayTime ; Set minimum flight wait time
    ShowParams("Flight Delay Minimum")
}

*NumpadMult:: ; Show Flight Parameters
{
    ShowParams("Flight Parameters")
}

*NumpadDiv:: ; Store flight parameters
{
    global StoredFlightTime, StoredDelayTime, FlightTime, DelayTime

    StoredFlightTime := FlightTime
    StoredDelayTime := DelayTime
    ShowStatus("Flight Parameters Stored")
}
*NumpadSub:: ; Recall stored flight parameters
{
    global StoredFlightTime, StoredDelayTime, FlightTime, DelayTime

    FlightTime := StoredFlightTime
    DelayTime := StoredDelayTime
    ShowStatus("Flight Parameters Recalled")
}

*NumpadAdd:: ; Increase flight step
{
    global FlightStep, DelayStep
    FlightStep := 200
    DelayStep := 200
    ShowStatus("Flight/Delay Step Increased to " . FlightStep . " ms")
}

*NumpadEnter:: ; Default flight steps
{
    global FlightStep, DelayStep
    FlightStep := 50
    DelayStep := 50
    ShowStatus("Flight/Delay Step Reset to 50 ms")
}

*NumpadDel:: ; Drop down a bit
{
    Send("{Space Up}")
}

*NumpadPgup:: ; Reduce delay time
{
    global DelayTime
    if DelayTime > MinDelayTime
        DelayTime := DelayTime - DelayStep ; reduce flight time
    else
        DelayTime := MinDelayTime ; set minimum flight delay time
    ShowStatus("Delay: " . DelayTime . " ms") ; display current flight time
}

*NumpadPgdn:: ; Increase delay time
{
    global DelayTime
    if DelayTime < MaxDelayTime
        DelayTime := DelayTime + DelayStep ; increase flight time
    else
        DelayTime := MaxDelayTime ; set maximum flight delay time
    ShowStatus("Delay: " . DelayTime . " ms") ; display current flight time
}

*NumpadUp:: ; Increase boost time
{
    global flightTime, DelayTime
    if flightTime < MaxFlightTime
        flightTime := flightTime + FlightStep ; increase flight time
    if FlightTime > MaxFlightTime
        flightTime := MaxFlightTime ; ensure flight time does not go above maximum
    if DelayTime > MinDelayTime
        DelayTime := DelayTime - DelayStep ; increase flight wait time
    if DelayTime < MinDelayTime
        DelayTime := MinDelayTime ; ensure wait time does not go below minimum

    ShowStatus("Vertical Boost: " . flightTime . " ms " . "Delay: " . DelayTime .
        " ms") ; display current flight time
}

*NumpadDown:: ; Decrease boost time
{
    global flightTime, DelayTime
    if flightTime > MinFlightTime
        flightTime := flightTime - FlightStep ; reduce flight time
    if flightTime < MinFlightTime
        flightTime := MinFlightTime ; ensure flight time does not go below minimum
    if DelayTime < MaxDelayTime
        DelayTime := DelayTime + DelayStep ; increase flight wait time
    if DelayTime > MaxDelayTime
        DelayTime := MaxDelayTime ; ensure wait time does not go above maximum

    ShowStatus("Vertical Boost: " . flightTime . " ms " . "Delay: " . DelayTime .
        " ms") ; display current flight time
}

*F2:: ; Reactive Shield
{
    static ReactiveToggle := false
    SetTimer(Shield, 30 * (ReactiveToggle ^= 1))
    if ReactiveToggle
        ShowStatus("Shield On")
    else
        ShowStatus("Shield Off")

    Shield() {
        Sleep(50)
        SendEvent(ReactiveShieldKey) ; Reactive key shortcut
        Sleep(100)
        SendEvent('z') ; Activate power
        Sleep(ShieldTime)
    }
}

*F3:: ; Tap Space with delays
{
    Hover()
}

*F6:: ; Hold Shift
{
    static ShiftToggle := false
    ShiftToggle := !ShiftToggle ; Toggle the state of Shift

    if ShiftToggle {
        SendEvent("{LShift Down}") ; Hold down Left Shift
        ShowStatus("Horizontal Boost On")
    }
    else {
        SendEvent("{LShift Up}") ; Release Left Shift
        ShowStatus("Horizontal Boost Off")
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

    Invisibility() {
        Sleep(50)
        SendEvent(InvisibilityKey) ; Void Form shortcut
        Sleep(100)
        SendEvent('z') ; Activate power
        Sleep(InvisibilityTime)
    }
}

*F7:: Flight() ; Vehicle Flight Mode
; This function toggles flight mode on and off, allowing for extended flight duration in vehicles. Requires a suitably modded vehicle.

Flight() {
    global flightTime, DelayTime
    static toggle := false ; declare the toggle
    toggle := !toggle ; flip the toggle
    if toggle {
        ShowStatus("Flight Mode On")
        SetTimer(selfRunningInterruptibleSeq, -1) ; run the function once immediately
    }

    selfRunningInterruptibleSeq() {
        Send("{LShift Down}") ; Hold down Left Shift
        Send("{Space Down}") ; Hold down Space

        Sleep flightTime ; Keep space key held down for DelayTime ms
        Send("{Space Up}") ; Release Space
        Sleep(DelayTime) ; Wait for DelayTime seconds before checking the toggle again

        ; check if the toggle is off to run post-conditions and end the function early
        if !toggle {
            ShowStatus("Flight Mode Off")
            Send("{LShift Up}") ; Release Shift
            return ; end the function
        }

        ; check if the toggle is still on at the end to rerun the function
        if toggle {
            SetTimer(selfRunningInterruptibleSeq, -1) ; go again if the toggle is still active
        }
    }
}

Hover() {
    global flightTime, DelayTime
    static toggle := false ; declare the toggle
    toggle := !toggle ; flip the toggle
    if toggle {
        ShowStatus("Hover Mode On")
        SetTimer(selfRunningInterruptibleSeq, -1) ; run the function once immediately
    }

    selfRunningInterruptibleSeq() {
        Send("{Space Down}") ; Hold down Space

        Sleep flightTime ; Keep space key held down for DelayTime ms
        Send("{Space Up}") ; Release Space
        Sleep(DelayTime) ; Wait for DelayTime seconds before checking the toggle again

        ; check if the toggle is off to run post-conditions and end the function early
        if !toggle {
            ShowStatus("Hover Mode Off")
            return ; end the function
        }

        ; check if the toggle is still on at the end to rerun the function
        if toggle {
            SetTimer(selfRunningInterruptibleSeq, -1) ; go again if the toggle is still active
        }
    }
}
