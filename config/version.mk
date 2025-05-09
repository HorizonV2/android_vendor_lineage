HORIZON_REVISION := 5.3
HORIZON_CODENAME := Earth
HORIZON_BUILD_DATE := $(shell date +"%d%m%Y")

MAINTAINER_LIST = $(shell cat horizon-maintainers/maintainers.list)
DEVICE_LIST = $(shell cat horizon-maintainers/devices.list)

ifeq ($(filter $(LINEAGE_BUILD), $(DEVICE_LIST)), $(LINEAGE_BUILD))
   ifeq ($(filter $(HORIZON_MAINTAINER), $(MAINTAINER_LIST)), $(HORIZON_MAINTAINER))
      HORIZON_BUILD_TYPE := OFFICIAL
  else
     # the builder is overriding official flag on purpose
     ifeq ($(HORIZON_BUILD_TYPE), OFFICIAL)
       $(error **********************************************************)
       $(error *     A violation has been detected, aborting build      *)
       $(error **********************************************************)
       HORIZON_BUILD_TYPE := UNOFFICIAL
     else
       $(warning **********************************************************************)
       $(warning *   There is already an official maintainer for $(LINEAGE_BUILD)    *)
       $(warning *              Setting build type to UNOFFICIAL                      *)
       $(warning *    Please contact current official maintainer before distributing  *)
       $(warning *              the current build to the community.                   *)
       $(warning **********************************************************************)
       HORIZON_BUILD_TYPE := UNOFFICIAL
     endif
  endif
else
   ifeq ($(HORIZON_BUILD_TYPE), OFFICIAL)
     $(error **********************************************************)
     $(error *     A violation has been detected, aborting build      *)
     $(error **********************************************************)
   endif
  HORIZON_BUILD_TYPE := UNOFFICIAL
endif

ifeq ($(WITH_GMS),true)
HORIZON_BUILD_VARIANT := GAPPS
else
HORIZON_BUILD_VARIANT := VANILLA
endif

ifdef HORIZON_MAINTAINER
PRODUCT_PRODUCT_PROPERTIES += \
   ro.horizon.maintainer=$(HORIZON_MAINTAINER)
endif

HORIZON_VERSION := HorizonDroid-v$(HORIZON_REVISION)-$(HORIZON_CODENAME)-$(HORIZON_BUILD_VARIANT)-$(LINEAGE_BUILD)-$(HORIZON_BUILD_TYPE)-$(HORIZON_BUILD_DATE)

# HorizonDroid version properties
PRODUCT_SYSTEM_PROPERTIES += \
    ro.horizon.version=$(HORIZON_VERSION) \
    ro.horizon.revision=$(HORIZON_REVISION) \
    ro.horizon.codename=$(HORIZON_CODENAME) \
    ro.horizon.device=$(LINEAGE_BUILD) \
    ro.horizon.releasetype=$(HORIZON_BUILD_TYPE)

# Signing keys
-include vendor/horizon-priv/keys/keys.mk
