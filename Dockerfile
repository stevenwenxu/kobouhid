FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    wget \
    bc \
    bison \
    flex \
    make \
    xz-utils \
    lzop \
    lbzip2 \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /build

## Download kernel source (from Kobo)
## Note this doesn't actually build when running `make`
## Eventually get this error: make[1]: *** No rule to make target 'arch/arm/boot/dts/imx6sll-e70k14f00.dtb', needed by '__build'.  Stop.
#RUN wget -O kernel.tar.bz2 https://github.com/kobolabs/Kobo-Reader/raw/master/hw/imx6sll-clara2e/kernel.tar.bz2 \
#    && tar xf kernel.tar.bz2 \
#    && rm kernel.tar.bz2

# Official Linux kernel
RUN wget -O kernel.tar.bz2 https://mirrors.edge.kernel.org/pub/linux/kernel/v4.x/linux-4.9.77.tar.gz \
    && tar xf kernel.tar.bz2 \
    && mv linux-4.9.77 kernel \
    && rm kernel.tar.bz2

RUN wget -O xcomp.tar.xz https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/arm-linux-gnueabihf/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf.tar.xz && \
    tar xf xcomp.tar.xz && \
    mv gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf xcomp && \
    rm xcomp.tar.xz

ENV PATH=/build/xcomp/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Copy the kernel .config directly
COPY config /build/kernel/.config

# Fix the dtc-lexer.lex.c issue
RUN mv kernel/scripts/dtc/dtc-lexer.lex.c_shipped kernel/scripts/dtc/dtc-lexer.lex.c && \
    sed -i 's/YYLTYPE yylloc/extern YYLTYPE yylloc/' kernel/scripts/dtc/dtc-lexer.lex.c

# Run oldconfig and enable UHID module
WORKDIR /build/kernel
RUN make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- oldconfig
RUN make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j$(nproc)

# Build HID-related modules (UHID, HID_GENERIC, etc.)
RUN make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- drivers/hid/uhid.ko

# Create output directory for modules
RUN mkdir -p /build/output && \
    cp $(find . -name "*.ko") /build/output/

# By default, show the built modules
CMD ls -l /build/output
