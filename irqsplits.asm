    icl 'hardware.asm'
    org $2000
main
    ; disable interrupts
    sei
    mva #0 NMIEN
    ; disable OS
    lda #$FE
    and:sta PORTB
    ; set IRQ vector
    mwa #irq IRQVEC
    ; sync to top
    lda:rne VCOUNT
    sta WSYNC
    ; initialize POKEY
    mva #0 AUDCTL
    mva #3 SKCTL
    mva #5 AUDCTL
    ; enable square wave sound to use Altirra audio monitor as debugging aid
    mva #$A8 AUDC4
    ; set number of lines to wait until first IRQ triggers
    mva #10 AUDF4
    sta STIMER
    ; enable IRQs
    mva #4 IRQEN
    cli
    ; spin
    jmp *
splitcount equ 4
index
    dta splitcount-1
    ; table of splitcount line counts (reversed), must sum to 312-splitcount (?)
counts
    dta 208
    dta 30
    dta 20
    dta 50
    ; color table (reversed)
colors
    dta $32 ; red
    dta $0
    dta $B8 ; green
    dta $0
irq
    pha
    txa:pha
    ldx index
    ; set color
    mva colors,x COLBAK
    ; set up next delay
    mva counts,x AUDF4
    dex
    spl:ldx #splitcount-1
    stx index
    ; acknowledge IRQ
    mva #0 IRQEN
    ; enable IRQ
    mva #4 IRQEN
    pla:tax
    pla
    rti
