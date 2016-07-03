# rust-embedded-example
An example of using Rust in an embedded project

In order to actually run this example you'll need an STM32L1 Discovery Board. I don't expect many readers to have this exact board, but it should to relatively easy to port to other targets/board and I thought a complete example would be useful as a point of comparison.

This is basically just STM's GPIO_IOToggle example but with the core inner loop replaced with some Rust code.

Essentially what I did:

- Started with STM's GPIO_IOToggle example.
- Added a Makefile to build the example.
- Setup the Cargo configuration necessary to target a Cortex-M3 in `.cargo/config`
- Added rules to the Makefile to build a Rust `sysroot` with `libcore`
- Used bindgen to wrap the STM32 HAL libraries for use in Rust
- Replaced the core inner loop in `main.c` of the GPIO_IOToggle example with Rust code.
- Added rules to the Makefile to build the Rust code and link the resulting static library into the final binary.

## To run the example:

### Grab a Rust nightly

- Install multirust from [here](https://github.com/brson/multirust) if you haven't already
- Run `multirust update nightly`

### Make a directory to work in

    mkdir embedded_rust_experiment
    cd embedded_rust_experiment
    multirust override nightly

### Clone my embedded Rust example

    git clone https://github.com/jvranish/rust-embedded-example.git

### Clone Rust src into sibling directory

We nee to clone the Rust repo:

    git clone git@github.com:rust-lang/rust.git

And then we need to checkout the commit that matches the version of our compiler. To find the commit for our current compiler you can do:

    $ rustc -vV
    rustc 1.11.0-nightly (ad7fe6521 2016-06-23)
    binary: rustc
    commit-hash: ad7fe6521b8a59d84102113ad660edb21de2cba6
    commit-date: 2016-06-23
    host: x86_64-apple-darwin
    release: 1.11.0-nightly

And then checkout that specific commit:

    cd rust
    git checkout 8903c21d618fd25dca61d9bb668c5299d21feac9
    cd ..

Your commit-hash will almost certainly be different than what I have here. Don’t just copy what I have :)

### Get ARM gcc
 
Download ARM gcc from [here](https://launchpad.net/gcc-arm-embedded) and put it into a sibling directory. In my case I put it in `../tools/gcc-arm-none-eabi-5_3-2016q1/`

### Get STM32 Cube for L1 line

Get the Cube HAL from [here](http://www.st.com/content/st_com/en/products/embedded-software/mcus-embedded-software/stm32-embedded-software/stm32cube-embedded-software/stm32cubel1.html#getsoftware-scroll) and put into sibling directory. In my case I put it in `../STM32Cube_FW_L1_V1.5.0/`

### Install openocd

Install my favorite debugger toolchain. On macOS, if you have homebrew installed you can just do:

    brew install openocd

### Run example

Open up `Makefile` in `embedded_rust_experiment ` and make sure the variables: `GCC_ARM_PATH`, `STM32_CUBE_PATH` and `RUST_SRC_PATH` are set to sensible values.

Then to run the example:

- In one console run openocd

    cd rust-embedded-example
    make openocd

- In another console build and debug

    cd rust-embedded-example
    make debug

When the gdb prompt shows up you should be able to press `c` and enter and you should see blinking lights on your discovery board.
