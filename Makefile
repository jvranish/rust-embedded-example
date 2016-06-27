
GCC_ARM_PATH := ../tools/gcc-arm-none-eabi-5_3-2016q1
STM32_CUBE_PATH := ../STM32Cube_FW_L1_V1.5.0
RUST_SRC_PATH := ../rust

CC := $(GCC_ARM_PATH)/bin/arm-none-eabi-gcc
GDB := $(GCC_ARM_PATH)/bin/arm-none-eabi-gdb

ODIR=build

ASM_SOURCES := $(wildcard src/*.s)
SOURCES := $(wildcard src/*.c)
STM32_CUBE_SOURCES := $(subst ../,,$(wildcard $(STM32_CUBE_PATH)/Drivers/STM32L1xx_HAL_Driver/Src/*.c))

C_OBJS := $(patsubst %.c,$(ODIR)/%.o,$(SOURCES)) $(patsubst %.c,$(ODIR)/%.o,$(STM32_CUBE_SOURCES))
S_OBJS := $(patsubst %.s,$(ODIR)/%.o,$(ASM_SOURCES))
OBJECTS := $(C_OBJS) $(S_OBJS)

TARGET := example.elf


COMMON_FLAGS := \
	-Wall \
	-Wextra \
	-Wcast-align \
	-Wstrict-prototypes \
	-O1 \
	-g \
	-std=c99 \
	-mcpu=cortex-m3 \
	-mthumb \
	-mlittle-endian \
	-mfloat-abi=soft \
	-mfpu=vfp

INC_FLAGS := \
  -Isrc \
  -I$(STM32_CUBE_PATH)/Drivers/BSP/STM32L152C-Discovery \
	-I$(STM32_CUBE_PATH)/Drivers/CMSIS/Include \
	-I$(STM32_CUBE_PATH)/Drivers/CMSIS/Device/ST/STM32L1xx/Include \
	-I$(STM32_CUBE_PATH)/Drivers/STM32L1xx_HAL_Driver/Inc


LD_FLAGS := \
	-Tsrc/linker_script.ld \
	-nostdlib \
	-nostartfiles \
	-nodefaultlibs \
	-Wl,--cref \
	-Wl,--gc-sections \
	-Wl,-Map,$(ODIR)/$(TARGET).map \
	-L$(GCC_ARM_PATH)/arm-none-eabi/lib/armv7-m \
	-Lbuild/thumbv7m-none-eabi/debug \
	-lrust_src \
	-lg \
	$(COMMON_FLAGS)

C_FLAGS := \
  -fdata-sections \
  -ffunction-sections \
  -DSTM32L152xB \
  $(INC_FLAGS) \
  $(COMMON_FLAGS)

DEPS := $(OBJECTS:.o=.d)

all: pre-build $(ODIR)/$(TARGET)

$(ODIR)/$(TARGET): $(OBJECTS)
	$(CC)  $(OBJECTS) -o $(ODIR)/$(TARGET) $(LD_FLAGS)

pre-build: build-rust
	echo $(OBJECTS)

LIBCORE := $(ODIR)/sysroot/lib/rustlib/thumbv7m-none-eabi/lib/libcore.rlib

build-rust: $(LIBCORE)
	cargo build --manifest-path rust_src/Cargo.toml

BINDGEN_ARGS := \
	$(STM32_CUBE_PATH)/Drivers/STM32L1xx_HAL_Driver/Inc/stm32l1xx_hal.h \
	--use-core \
	--output stm32l1hal_bindings/src/lib.rs -- \
	-target thumbv7m-none-eabi \
	-nostdlib \
	-nostdinc \
	-Dsection\(x\)= \
  -Doptimize\(x\)= \
  -DUSE_STDPERIPH_DRIVER \
	-isystem$(STM32_CUBE_PATH)/Drivers/CMSIS/Include \
	-isystem$(GCC_ARM_PATH)/arm-none-eabi/include \
  -isystem$(GCC_ARM_PATH)/lib/gcc/arm-none-eabi/5.3.1/include \
	$(C_FLAGS)

hal-bindings:
	export LD_LIBRARY_PATH=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib && 	bindgen $(BINDGEN_ARGS)

debug: all
	$(GDB) -iex "target remote localhost:3333" -iex "monitor reset halt" -ex "load" $(ODIR)/$(TARGET)

openocd:
	openocd -f open_ocd.cfg

$(LIBCORE):
	mkdir -p $(ODIR)/sysroot/lib/rustlib/thumbv7m-none-eabi/lib
	rustc --target thumbv7m-none-eabi $(RUST_SRC_PATH)/src/libcore/lib.rs --out-dir $(ODIR)/sysroot/lib/rustlib/thumbv7m-none-eabi/lib/

$(ODIR)/%.o: %.s
	mkdir -p `dirname $@`
	$(CC) $(C_FLAGS) -MMD -MP -c $< -o $@

$(ODIR)/%.o: %.c
	mkdir -p `dirname $@`
	$(CC) $(C_FLAGS) -MMD -MP -c $< -o $@

# for the STM32_CUBE_PATH, not ideal but oh well
$(ODIR)/%.o: ../%.c
	mkdir -p `dirname $@`
	$(CC) $(C_FLAGS) -MMD -MP -c $< -o $@


.PHONE: clean

clean:
	rm -r $(ODIR)

-include $(DEPS)


