#![no_std]
#![no_main]

use core::arch::global_asm;
use core::panic::PanicInfo;
use core::ptr::{read_volatile, write_volatile};

global_asm!(include_str!("../boot.S"));

const UART0_BASE: usize = 0xFE201000;
const UART_DR: *mut u32 = UART0_BASE as *mut u32;
const UART_FR: *const u32 = (UART0_BASE + 0x18) as *const u32;

const UART_FR_TXFF: u32 = 1 << 5;

fn uart_putc(byte: u8) {
    unsafe {
        while read_volatile(UART_FR) & UART_FR_TXFF != 0 {
            core::hint::spin_loop();
        }

        write_volatile(UART_DR, byte as u32);
    }
}

fn uart_write(message: &str) {
    for byte in message.bytes() {
        uart_putc(byte);
    }
}

#[no_mangle]
pub extern "C" fn kernel_main() -> ! {
    uart_write("Coffee OS\n");
    uart_write("Bare-metal Rust is running!\n");

    loop {
        core::hint::spin_loop();
    }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    uart_write("KERNEL PANIC\n");

    loop {
        core::hint::spin_loop();
    }
}
