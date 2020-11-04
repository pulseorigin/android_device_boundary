MAKE += SHELL=/bin/bash

ifneq ($(AARCH64_GCC_CROSS_COMPILE),)
ATF_CROSS_COMPILE := $(strip $(AARCH64_GCC_CROSS_COMPILE))
else
ATF_TOOLCHAIN_ABS := $(realpath prebuilts/gcc/$(HOST_PREBUILT_TAG)/aarch64/aarch64-linux-android-4.9/bin)
ATF_CROSS_COMPILE := $(ATF_TOOLCHAIN_ABS)/aarch64-linux-androidkernel-
CLANG_TOOLCHAIN_ABS := $(realpath prebuilts/clang/host/linux-x86/clang-r349610/bin)
CLANG_TO_COMPILE := CC=$(CLANG_TOOLCHAIN_ABS)/clang
endif

define build_imx_uboot
    echo ================= Building i.MX U-Boot with firmware; \
    cp $(FSL_PROPRIETARY_PATH)/linux-firmware-imx/firmware/hdmi/cadence/signed_*.bin $(UBOOT_IMX_PATH)/uboot-imx/ ; \
    cp $(FSL_PROPRIETARY_PATH)/linux-firmware-imx/firmware/ddr/synopsys/lpddr4_pmu_train* $(UBOOT_IMX_PATH)/uboot-imx/ ; \
    if [ ${clean_build} = 1 ]; then \
        $(MAKE) -C $(ATF_IMX_PATH)/arm-trusted-firmware/ PLAT=`echo $(2) | cut -d '-' -f1` clean; \
    fi; \
    if [ `echo $(2) | cut -d '-' -f2` = "trusty" ] && [ `echo $(2) | rev | cut -d '-' -f1` != "uuu" ]; then \
        cp $(FSL_PROPRIETARY_PATH)/fsl-proprietary/uboot-firmware/imx8m/tee-imx8mm.bin $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/tee.bin; \
        $(MAKE) -C $(ATF_IMX_PATH)/arm-trusted-firmware/ CROSS_COMPILE="$(ATF_CROSS_COMPILE)" $(CLANG_TO_COMPILE) PLAT=`echo $(2) | cut -d '-' -f1` bl31 -B SPD=trusty || exit 1; \
    else \
        if [ -f $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/tee.bin ] ; then \
            rm -rf $(IMX_MKIMAGE_PATH)/imx-mkimage/iMX8M/tee.bin; \
        fi; \
        $(MAKE) -C $(ATF_IMX_PATH)/arm-trusted-firmware/ CROSS_COMPILE="$(ATF_CROSS_COMPILE)" $(CLANG_TO_COMPILE) PLAT=`echo $(2) | cut -d '-' -f1` bl31 -B || exit 1; \
    fi; \
    cp $(ATF_IMX_PATH)/arm-trusted-firmware/build/`echo $(2) | cut -d '-' -f1`/release/bl31.bin $(UBOOT_OUT)/bl31-iMX8MM.bin; \
    $(MAKE) -C $(UBOOT_IMX_PATH)/uboot-imx/ CROSS_COMPILE="$(ATF_CROSS_COMPILE)" O=$(realpath $(UBOOT_OUT)) flash.bin; \
    cp $(UBOOT_OUT)/flash.bin $(UBOOT_COLLECTION)/;
endef
