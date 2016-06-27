# rust-embedded-example
An example of using Rust in an embedded project

In order to actually run this example you'll need an STM32L1 Discovery Board. I don't expect many readers to have this exact board, but it should to relatively easy to port to other targets/board and I thought a complete example would be useful as a point of comparison.

## To run the example:

### Make a directory to work in

    mkdir embedded_rust_experiement
    cd embedded_rust_experiement

### clone example

    git clone https://github.com/jvranish/rust-embedded-example.git

### Clone rust src into sibling directory

    git clone git@github.com:rust-lang/rust.git

### Get ARM gcc
 
Download ARM gcc from [here](https://launchpad.net/gcc-arm-embedded) and put it into a sibling directory. In my case I put it in `../tools/gcc-arm-none-eabi-5_3-2016q1/`

### Get STM32 Cube for L1 line

Get the Cube HAL from [here](http://www.st.com/content/st_com/en/products/embedded-software/mcus-embedded-software/stm32-embedded-software/stm32cube-embedded-software/stm32cubel1.html#getsoftware-scroll) and put into sibling directory. In my case I put it in `../STM32Cube_FW_L1_V1.5.0/`

### Install openocd

My favorite debugger toolchain:

    brew install openocd

### Run example

Then to run the example:

- in one console run openocd

    cd embedded_rust_experiement
    make openocd

- in another console build and debug

    cd embedded_rust_experiement
    make debug

when the gdb prompt shows up you should be able to press `c` and enter and you should see blinking lights on your discovery board.

