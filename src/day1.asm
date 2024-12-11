; template fox32 application for tiny code christmas
    opton
    rcall window_struct
window_struct:
    pop r0
    ; rta r0, window_struct
    ; rta r1, window_title
    mov r1, window_title
    mov r2, 160
    mov r3, 140
    mov r4, 0
    mov r5, 16
    mov r6, 0
    mov r7, 0
    call [OS_new_window]
start:
    ; program initialization code goes here
loop:
    ; code that runs every frame goes here
    mov r1, [window_struct]
    ; add r1, 97916 ; ((137 + 16) * 160 - 1) * 4
    add r1, 99836 ; ((140 + 16) * 160 - 1) * 4
    mov r31, 320
bottom_row:
    call [ROM_random]
    movz.8 r2, r0
    mul r2, 0x00010101
    mov [r1], r2
    sub r1, 4
    loop bottom_row
    mov r31, 22080 ; 138 * 160
upper_rows:
    mov r0, 0
    mov r2, r1
    movz.8 r3, [r2]
    add r0, r3
    add r2, 636
    movz.8 r3, [r2]
    add r0, r3
    movz.8 r3, [r2 + 8]
    add r0, r3
    add r2, 644
    movz.8 r3, [r2]
    add r0, r3
    mul.16 r0, 40
    div.16 r0, 161
    mul r0, 0x01010101
    ; add r0, 0xff000000
    mov [r1], r0
    sub r1, 4
    loop upper_rows
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

window_title: data.str "Day 1" data.8 0 data.8 0

const OS_yield_task: 0xA14
const OS_end_current_task: 0xA18
const OS_save_state_and_yield_task: 0xA28
const OS_sleep_task: 0xA2C
const OS_new_window: 0xC10
const OS_destroy_window: 0xC14
const OS_get_next_window_event: 0xC1C
const OS_fill_window: 0xC28
const OS_start_dragging_window: 0xC30

const ROM_random: 0xF0049000
