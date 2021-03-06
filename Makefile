PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
include $(abspath $(PROJECT_DIR)/scripts/makeops/system-detect/init.mk)

# ==============================================================================
# Public targets

system-detect: ### Detect operating system info
	./scripts/makeops/system-detect/system-detect.sh

test: ### Run the test suite
	./scripts/makeops/system-detect/system-detect.test.sh

# ==============================================================================

.SILENT: \
	system-detect \
	test
