# Core settings
DOCKER_IMAGE ?= ghcr.io/mike-callahan/devgame-builder
BUILD_ROOT ?= /tmp/build
SCRIPTS_DIR ?= $(CURDIR)/build-scripts
ARTIFACTS_DIR ?= $(CURDIR)/local-artifacts
DEBIAN_DIR ?= $(CURDIR)/debian

# List of packages
PACKAGES := $(patsubst build-%.sh,%,$(notdir $(wildcard build-scripts/build-*.sh)))


# Define build targets like "gamescope", "vkbasalt", etc.
define build_template
$(1):
	@echo "🚀 Building $(1)..."
	docker run --rm \
		-v "$(SCRIPTS_DIR):/scripts" \
		-v "$(DEBIAN_DIR)/$(1):/workspace/debian" \
		-v "$(ARTIFACTS_DIR)/$(1):/artifacts" \
		-e BUILD_ROOT=$(BUILD_ROOT)/$(1) \
		$(DOCKER_IMAGE) \
		bash /scripts/build-$(1).sh
endef

# Auto-generate each package rule
$(foreach pkg,$(PACKAGES),$(eval $(call build_template,$(pkg))))

# Clean artifacts
clean:
	rm -rf $(ARTIFACTS_DIR)

# Build all
all: $(PACKAGES)

