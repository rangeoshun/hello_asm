  *=0x0FFE
  !byte $00, $10

  sei         ; turn off interrupts

  jsr clr_scr

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
  jmp *       ; infinite loop

irq:
  dec $d019

  ;; do stuff fere

  jmp $ea81   ; return to kernel interrupt routine

clr_scr:
  lda #$00
  sta $d020
  sta $d021

  tax

  lda #$20

clr_loop:
  sta $0400,x
  sta $0500,x
  sta $0600,x
  sta $0700,x

  dex
  bne clr_loop
  rts
