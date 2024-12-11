; template fox32 application for tiny code christmas
    opton
    rcall window_struct
window_struct:
    pop r0
    mov r1, window_title
    mov r2, 160
    mov r3, 138
    mov r4, 160
    mov r5, 16
    mov r6, 0
    mov r7, 0
    call [OS_new_window]
start:
    ; program initialization code goes here
    mov r20, 40
    mov r21, 0
    mov r22, 120
    mov r23, 0
loop:
    ; code that runs every frame goes here
    ; swinging balls
    mov r0, 80
    sub r0, r20
    idiv.16 r0, 30
    add.16 r21, r0
    add.16 r20, r21
    mov r0, 80
    sub r0, r22
    idiv.16 r0, 17
    add.16 r23, r0
    add.16 r22, r23
    ; rendering
    mov r10, 138
pixels:
    mov r31, 160
rows:
    mov r1, [window_struct]
    mov r0, r10
    mul.16 r0, 160
    add.16 r0, r31
    add.16 r0, 2399
    mul r0, 4
    add r1, r0
    mov r0, 0
    mov r2, r20
    mov r3, 45
    call dist
    add r0, r5
    mov r2, r22
    mov r3, 95
    call dist
    add r0, r5
    cmp.8 r0, 128
    ifgt add r0, r0
    ifgt add r0, r0
    ifgt sub.16 r0, 384
    cmp.16 r0, 255
    ifgt mov r0, 255
    mul r0, 0x01010101
    mov [r1], r0
    loop rows
    dec r10
    ifnz jmp pixels
event_loop:
    ; yield so that other processes can run and so that we have a more consistent framerate
    mov r0, 16 ; 16 milliseconds, a bit less than 1/60th of a second for a target of ~60 FPS
    ; call [OS_save_state_and_yield_task]
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
    ifgteq mov r20, r1
    ifgteq mov r21, r2
    ifgteq ret
    mov r0, window_struct
    ; is the user clicking the close button?
    sub.8 r1, 8
    ; if not, drag the window
    ifgteq jmp [OS_start_dragging_window] ; tail call
    ; if so, exit
    call [OS_destroy_window]
    jmp [OS_end_current_task]

dist:
    sub r2, r31
    imul r2, r2
    sub r3, r10
    imul r3, r3
    mov r4, 2
    add r4, r2
    add r4, r3
    mov r5, 65535
    div r5, r4
    ret

window_title: data.str "Day 2" data.8 0 data.8 0

const OS_yield_task: 0xA14
const OS_end_current_task: 0xA18
const OS_save_state_and_yield_task: 0xA28
const OS_sleep_task: 0xA2C
const OS_new_window: 0xC10
const OS_destroy_window: 0xC14
const OS_get_next_window_event: 0xC1C
const OS_start_dragging_window: 0xC30
