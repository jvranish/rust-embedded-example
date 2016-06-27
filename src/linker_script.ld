
ENTRY(Reset_Handler)

/* Address of stack (at the end of RAM) */
_estack = 0x20004000;

MEMORY
{
  FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 128K
  RAM (xrw)  : ORIGIN = 0x20000000, LENGTH = 16K
}

SECTIONS
{
  /* Put interrupt vector table at start of FLASH */
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector))
    . = ALIGN(4);
  } >FLASH

  .ARM : {
    *(.ARM.exidx*)
  } >FLASH

  .text :
  {
    . = ALIGN(4);
    *(.text*)          /* code */
    *(.rodata*)        /* constants, strings, etc. */
    *(.glue_7)
    *(.glue_7t)
    *(.eh_frame)

    . = ALIGN(4);
    _sidata = .;       /* data to be copied to RAM on startup */
    . = . + SIZEOF(.data);
    . = ALIGN(4);
  } >FLASH




  /* Initialized data sections in RAM. A copy is in ROM, 
     and copied into RAM on start */
  .data : AT ( _sidata )
  {
    . = ALIGN(4);
    _sdata = .;
    *(.data*)
    *(.ram_funcs)      /* code that needs to run from RAM */
    . = ALIGN(4);
    _edata = .;
  } >RAM

  /* Uninitialized data */
  .bss :
  {
    . = ALIGN(4);
    _sbss = .;
    *(.bss)
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;
  } >RAM
}
