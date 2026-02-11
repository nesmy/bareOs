#include <stdio.h>
#include "tty.h"

void kernel_main(void);

/* __attribute__((section(".text"))) */
void kernel_main(void) {

  terminal_init();
  volatile unsigned short *vga = (unsigned short *)0xB8000;

  /* const char* msg = "BNOS Neural Kernel Booted"; */
char msg[] = "BNOS Neural Kernel Booted";
 printf(msg);

    while (1) { }
}
