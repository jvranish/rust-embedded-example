#![no_std]
#![feature(lang_items)]

extern crate stm32l1hal;


use stm32l1hal::*;

// const GPIO_PIN_0 : u16 = 0x0001;
// const GPIO_PIN_1 : u16 = 0x0002;
// const GPIO_PIN_2 : u16 = 0x0004;
// const GPIO_PIN_3 : u16 = 0x0008;
// const GPIO_PIN_4 : u16 = 0x0010;
// const GPIO_PIN_5 : u16 = 0x0020;
const GPIO_PIN_6 : u16 = 0x0040;
const GPIO_PIN_7 : u16 = 0x0080;
// const GPIO_PIN_8 : u16 = 0x0100;

const PERIPH_BASE : u32 = 0x40000000;
const AHBPERIPH_BASE : u32 = PERIPH_BASE + 0x00020000;

const GPIOB_BASE : u32 = AHBPERIPH_BASE + 0x00000400;

const GPIOB : *mut GPIO_TypeDef = GPIOB_BASE as *mut GPIO_TypeDef;

#[no_mangle]
pub extern "C" fn rust_main() -> () {
    loop {
      unsafe {
        HAL_GPIO_TogglePin(GPIOB, GPIO_PIN_7);
        HAL_Delay(200);
        HAL_GPIO_TogglePin(GPIOB, GPIO_PIN_6);
        HAL_Delay(200);
      }
    }

}



#[lang="eh_personality"] extern fn eh_personality() {}

#[lang="panic_fmt"]
extern fn panic_fmt(_: ::core::fmt::Arguments, _: &'static str, _: u32) -> ! {
    loop {}
}