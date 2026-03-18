#include "idt.h"

idt_gate_t idt[IDT_ENTRIES];
idt_register_t idt_reg;


#define LOW_16(x)  ((x) & 0xFFFF)
#define HIGH_16(x) (((x) >> 16) & 0xFFFF)

void set_idt_gate(int n, u32 handler) {
    idt[n].low_offset = LOW_16(handler);
    idt[n].sel = KERNEL_CS;
    idt[n].always0 = 0;
    idt[n].flags = 0x8E;
    idt[n].high_offset = HIGH_16(handler);
}

void set_idt() {
    idt_reg.base = (u32)&idt;
    idt_reg.limit = sizeof(idt_gate_t) * IDT_ENTRIES - 1;

    __asm__ __volatile__("lidtl (%0)" : : "r"(&idt_reg));
}