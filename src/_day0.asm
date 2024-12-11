; template fox32 application for tiny code christmas
    opton
    rcall window_struct
window_struct:
    pop r0
    mov r1, window_title
    mov r2, 160
    mov r3, 138
    mov r4, 0
    mov r5, 16
    mov r6, 0
    mov r7, 0
    call [OS_new_window]
start:
    ; program initialization code goes here
loop:
    ; code that runs every frame goes here
event_loop:
    ; yield so that other processes can run and so that we have a more consistent framerate
    mov r0, 16 ; 16 milliseconds, a bit less than 1/60th of a second for a target of ~60 FPS
    call [OS_sleep_task]
    ; check the window events we've received
    mov r0, window_struct
    call [OS_get_next_window_event]
    ; is this a null event (e.g. the event queue is empty)?
    add r0, 1
    ifz rjmp loop
    push event_loop
handle_event:
    ; is this a mouse click event?
    sub r0, 1
    ifnz ret
    ; NOTE: we use `sub.8` here under the assumption that the window is smaller than 256x256
    ; is the user clicking the title bar?
    sub.8 r2, 16
    ifgteq ret
    mov r0, window_struct
    ; is the user clicking the close button?
    sub.8 r1, 8
    ; if not, drag the window
    ifgteq jmp [OS_start_dragging_window] ; tail call
    ; if so, exit
    call [OS_destroy_window]
    jmp [OS_end_current_task]

window_title: data.str "Day 0" data.8 0 data.8 0

const OS_yield_task: 0xA14
const OS_end_current_task: 0xA18
const OS_sleep_task: 0xA2C
const OS_new_window: 0xC10
const OS_destroy_window: 0xC14
const OS_get_next_window_event: 0xC1C
const OS_start_dragging_window: 0xC30
