  *=0x0FFE
  !byte $00, $10

  jsr clr_scr

start:
  sei         ; turn off interrupts

  ldy #$7f    ; $7f = %01111111
  sty $dc0d   ; Turn off CIAs Timer interrupts
  sty $dd0d   ; Turn off CIAs Timer interrupts
  ;; lda $dc0d   ; cancel all CIA-IRQs in queue/unprocessed
  ;; lda $dd0d   ; cancel all CIA-IRQs in queue/unprocessed
  lda #$01    ; Set Interrupt Request Mask...
  sta $d01a   ; ...we want IRQ by Rasterbeam

  lda #<irq   ; point IRQ Vector to our custom irq routine
  ldx #>irq
  sta $314    ; store in $314/$315
  stx $315

  lda #$00    ; trigger first interrupt at row zero
  sta $d012

  lda $d011   ; Bit#0 of $d011 is basically...
  and #$7f    ; ...the 9th Bit for $d012
  sta $d011   ; we need to make sure it is set to zero

  cli         ; clear interrupt disable flag

  jmp start   ; infinite loop

irq:
  dec $d019

	;; do stuff here
  jsr rand
  lda seed
  asl
  lsr
  cmp seed
  beq char_a

  lda #$6d

  jmp print_a
char_a:
  lda #$6e
print_a:
  jsr $ffd2
return:
  jmp $ea81   ; return to kernel interrupt routine

clr_scr:
  lda #$00
  sta $d020                     ; background black
  sta $d021
  jsr $e544                     ; clear text
  rts

seed:
  !byte $a9

rand:
  lda seed
  beq do_eor
  asl
  beq no_eor ;if the input was $80, skip the EOR
  bcc no_eor
do_eor:
  eor #$1d
no_eor:
  sta seed
  rts
