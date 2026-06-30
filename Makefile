ACME ?= acme

BUILD_DIR := build
SRC_DIR := src

PATCH_SRC := $(SRC_DIR)/kickman-patch.asm
PATCH_PRG := $(BUILD_DIR)/kickman-patch.prg

.PHONY: all clean

all: $(PATCH_PRG)

$(BUILD_DIR):
	mkdir -p $@

$(PATCH_PRG): $(PATCH_SRC) | $(BUILD_DIR)
	$(ACME) -f cbm -o $@ $<

clean:
	rm -rf $(BUILD_DIR)
