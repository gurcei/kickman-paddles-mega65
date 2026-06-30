; Kickman paddle patch loader and runtime hooks.
;
; This is an ACME source version of the patch represented in kickman-patch.txt.
; The tokenized BASIC loader/menu is kept as exact bytes for now; the patch
; installer and runtime hook routines are expressed as assembly with labels.

!cpu 6510

PADDLE_FILTER_CARRY = $f8
FILTERED_PADDLE_POS = $f9
PADDLE_READING      = $fb   ; latest transformed, unfiltered paddle reading
LAST_PADDLE_CMD = $fc

COPY_SRC        = $fa
COPY_SRC_HI     = $fb
COPY_DST        = $fc
COPY_DST_HI     = $fd

VIC_SPR0_X      = $d000
VIC_SPR1_X      = $d002
VIC_D011        = $d011
VIC_SPR_X_MSB   = $d010

SID_POTX        = $d419

ORIG_CONTROL_PROBE_CMP     = $2272
ORIG_CONTROL_PROBE_BRANCH  = $2273
ORIG_JOYSTICK_MASK_START   = $2279
ORIG_JOYSTICK_MASK_LDA     = $227d
ORIG_JOYSTICK_MASK_JMP     = $227f
ORIG_MENU_PORT_WRITE       = $22c2
ORIG_POLL_SKIP_DDR_SETUP   = $22e4
ORIG_FIRE_TEST_MASK        = $22fa
ORIG_INPUT_DECODE_HOOK     = $230f
ORIG_PLAYER_MOVE_HOOK      = $2836
ORIG_FRAME_WAIT_HOOK       = $20df

ORIG_AFTER_JOYSTICK_MASK   = $e2a6
ORIG_AFTER_POLL_DDR_SETUP  = $e2ec
ORIG_AFTER_FRAME_WAIT      = $e0e4
ORIG_AFTER_PLAYER_MOVE     = $e869
SPRITE_X_MSB_PAIR_TABLE    = $e8c8

* = $0801

basic_stub:
    ; Tokenized BASIC loader/menu, preserved as bytes from kickman-patch.txt.
    !byte $20, $08, $0a, $00, $97, $35, $33, $32, $38, $30, $2c, $30, $3a, $97, $35, $33
    !byte $32, $38, $31, $2c, $30, $3a, $8b, $4c, $b2, $31, $a7, $31, $32, $30, $00, $58
    !byte $08, $14, $00, $99, $22, $93, $11, $05, $22, $a3, $31, $30, $29, $22, $43, $4f
    !byte $4d, $4d, $4f, $44, $4f, $52, $45, $20, $50, $52, $45, $53, $45, $4e, $54, $53
    !byte $2e, $2e, $2e, $22, $3a, $99, $a3, $31, $36, $29, $22, $11, $12, $4b, $49, $43
    !byte $4b, $4d, $41, $4e, $92, $22, $00, $81, $08, $1e, $00, $99, $a3, $39, $29, $22
    !byte $11, $11, $11, $11, $11, $11, $11, $43, $48, $4f, $4f, $53, $45, $20, $47, $41
    !byte $4d, $45, $20, $43, $4f, $4e, $54, $52, $4f, $4c, $4c, $45, $52, $11, $22, $00
    !byte $a6, $08, $28, $00, $99, $a3, $39, $29, $22, $12, $4a, $92, $20, $4a, $4f, $59
    !byte $53, $54, $49, $43, $4b, $20, $20, $20, $12, $50, $92, $20, $50, $41, $44, $44
    !byte $4c, $45, $53, $22, $00, $c2, $08, $32, $00, $a1, $43, $24, $3a, $8b, $43, $24
    !byte $b3, $b1, $22, $4a, $22, $af, $43, $24, $b3, $b1, $22, $50, $22, $a7, $35, $30
    !byte $00, $e1, $08, $3c, $00, $8b, $43, $24, $b2, $22, $4a, $22, $a7, $99, $a3, $31
    !byte $31, $29, $22, $91, $12, $4a, $4f, $59, $53, $54, $49, $43, $4b, $92, $22, $00
    !byte $ff, $08, $46, $00, $8b, $43, $24, $b2, $22, $50, $22, $a7, $99, $a3, $32, $34
    !byte $29, $22, $91, $12, $50, $41, $44, $44, $4c, $45, $53, $92, $22, $00, $1a, $09
    !byte $50, $00, $54, $49, $4d, $45, $24, $b2, $22, $30, $30, $30, $30, $30, $30, $22
    !byte $3a, $92, $31, $36, $32, $2c, $33, $32, $00, $5c, $09, $5a, $00, $99, $a3, $39
    !byte $29, $22, $91, $91, $91, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
    !byte $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $22, $3a, $99, $a3, $39
    !byte $29, $22, $11, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
    !byte $20, $20, $20, $20, $20, $20, $20, $20, $20, $22, $00, $75, $09, $64, $00, $99
    !byte $a3, $31, $35, $29, $22, $91, $91, $91, $4c, $4f, $41, $44, $49, $4e, $47, $2e
    !byte $2e, $2e, $22, $00, $87, $09, $6e, $00, $4c, $b2, $31, $3a, $93, $22, $4b, $4d
    !byte $22, $2c, $38, $2c, $31, $00, $99, $09, $78, $00, $8b, $43, $24, $b2, $22, $4a
    !byte $22, $a7, $9e, $32, $34, $38, $30, $00, $a3, $09, $82, $00, $9e, $32, $34, $38
    !byte $33, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

start:
    jmp copy_game_to_e000          ; SYS 2480 = joystick mode, no patch needed

install_paddle_patch:
    sei                            ; SYS 2483 = paddle mode

    lda #$ff
    sta ORIG_CONTROL_PROBE_CMP
    lda #$d0
    sta ORIG_CONTROL_PROBE_BRANCH

    lda #$c0
    sta ORIG_JOYSTICK_MASK_START
    lda #$a9
    sta ORIG_JOYSTICK_MASK_LDA
    lda #$1f
    sta ORIG_JOYSTICK_MASK_LDA + 1
    lda #$4c
    sta ORIG_JOYSTICK_MASK_JMP
    lda #<ORIG_AFTER_JOYSTICK_MASK
    sta ORIG_JOYSTICK_MASK_JMP + 1
    lda #>ORIG_AFTER_JOYSTICK_MASK
    sta ORIG_JOYSTICK_MASK_JMP + 2

    lda #$40
    sta ORIG_MENU_PORT_WRITE

    lda #$86
    sta ORIG_POLL_SKIP_DDR_SETUP
    lda #$1d
    sta ORIG_POLL_SKIP_DDR_SETUP + 1
    lda #$4c
    sta ORIG_POLL_SKIP_DDR_SETUP + 2
    lda #<ORIG_AFTER_POLL_DDR_SETUP
    sta ORIG_POLL_SKIP_DDR_SETUP + 3
    lda #>ORIG_AFTER_POLL_DDR_SETUP
    sta ORIG_POLL_SKIP_DDR_SETUP + 4

    lda #$04
    sta ORIG_FIRE_TEST_MASK

install_runtime_hooks:
    lda #$4c
    sta ORIG_INPUT_DECODE_HOOK
    lda #<update_horizontal_input_from_paddle
    sta ORIG_INPUT_DECODE_HOOK + 1
    lda #>update_horizontal_input_from_paddle
    sta ORIG_INPUT_DECODE_HOOK + 2

    lda #$4c
    sta ORIG_PLAYER_MOVE_HOOK
    lda #<apply_paddle_position_to_player_sprite
    sta ORIG_PLAYER_MOVE_HOOK + 1
    lda #>apply_paddle_position_to_player_sprite
    sta ORIG_PLAYER_MOVE_HOOK + 2

    lda #$4c
    sta ORIG_FRAME_WAIT_HOOK
    lda #<sample_paddle_during_frame_wait
    sta ORIG_FRAME_WAIT_HOOK + 1
    lda #>sample_paddle_during_frame_wait
    sta ORIG_FRAME_WAIT_HOOK + 2

copy_game_to_e000:
    lda #$00
    sta COPY_SRC
    sta COPY_DST
    lda #$20
    sta COPY_SRC_HI
    lda #$e0
    sta COPY_DST_HI
    ldy #$00

copy_game_loop:
    lda (COPY_SRC),y
    sta (COPY_DST),y
    iny
    bne copy_game_loop

    inc COPY_SRC_HI
    inc COPY_DST_HI
    bne copy_game_loop

init_paddle_state:
    lda #$00
    sta PADDLE_FILTER_CARRY
    sta FILTERED_PADDLE_POS
    sta PADDLE_READING
    sta LAST_PADDLE_CMD

start_game:
    sei
    lda #$35
    sta $01
    jmp ($fffc)

update_horizontal_input_from_paddle:
    lda FILTERED_PADDLE_POS
    cmp LAST_PADDLE_CMD
    bne new_paddle_command
    rts

new_paddle_command:
    sta LAST_PADDLE_CMD
    sta $1e
    rts

apply_paddle_position_to_player_sprite:
    sta $b0
    ldx #$00
    jsr update_primary_sprite_x_from_paddle
    ldx VIC_SPR0_X
    stx VIC_SPR1_X
    lda VIC_SPR_X_MSB
    and #$01
    tax
    lda VIC_SPR_X_MSB
    and #$fc
    ora SPRITE_X_MSB_PAIR_TABLE,x
    sta VIC_SPR_X_MSB
    jmp ORIG_AFTER_PLAYER_MOVE

update_primary_sprite_x_from_paddle:
    lda #$ff
    sta $06
    sta $07
    sta $08
    lda $98,x
    bpl active_player_slot
    rts

active_player_slot:
    lda $10
    and $b8,x
    bne frame_mask_allows_update
    rts

frame_mask_allows_update:
    dec $a0,x
    beq slot_countdown_expired
    rts

slot_countdown_expired:
    lda $a8,x
    sta $a0,x
    inc $06
    clc
    lda $b0
    adc #$30
    sta VIC_SPR0_X
    sta $03
    lda #$00
    bcc x_high_bit_ready
    lda #$01

x_high_bit_ready:
    sta $04
    lda VIC_SPR_X_MSB
    and #$fe
    ora $04
    sta VIC_SPR_X_MSB
    lda $04
    beq low_x_range
    lda $03
    cmp #$0c
    bcc done_updating_primary_sprite_x
    inc $08
    lda #$0b
    sta VIC_SPR0_X
    bne done_updating_primary_sprite_x

low_x_range:
    lda $03
    cmp #$3e
    bcs done_updating_primary_sprite_x
    inc $08
    lda #$3d
    sta VIC_SPR0_X

done_updating_primary_sprite_x:
    rts

sample_paddle_during_frame_wait:
    ; Read once per frame and smooth like Sea Wolf:
    ; filtered = (new_reading + 3 * previous_filtered) / 4.
    jsr read_filtered_paddle_position

frame_wait_loop:
    lda VIC_D011
    bmi leave_frame_wait_hook
    bpl frame_wait_loop

leave_frame_wait_hook:
    jmp ORIG_AFTER_FRAME_WAIT

read_filtered_paddle_position:
    lda SID_POTX
    eor #$ff
    and #$fe
    sta PADDLE_READING

    ldy #$00
    sty PADDLE_FILTER_CARRY
    ldy #$03
add_prior_filtered_position:
    clc
    adc FILTERED_PADDLE_POS
    bcc carry_done
    inc PADDLE_FILTER_CARRY
carry_done:
    dey
    bne add_prior_filtered_position

    clc
    ror PADDLE_FILTER_CARRY
    ror
    ror PADDLE_FILTER_CARRY
    ror
    and #$fe
    sta FILTERED_PADDLE_POS
    rts

credits:
    !byte $4b, $49, $43, $4b, $4d, $41, $4e, $20, $50, $41, $54, $43, $48, $20, $46, $4f
    !byte $52, $20, $50, $41, $44, $44, $4c, $45, $20, $43, $4f, $4e, $54, $52, $4f, $4c
    !byte $2e, $20, $44, $45, $56, $45, $4c, $4f, $50, $45, $44, $20, $42, $59, $20, $43
    !byte $52, $49, $53, $50, $59, $46, $50, $47, $41, $2c, $20, $31, $31, $2f, $32, $31
    !byte $2f, $31, $39, $2e, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    !byte $00, $00, $00, $00
