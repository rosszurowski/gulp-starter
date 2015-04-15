# Paths
SOURCE = ./source
BUILD  = ./build

# Globs
SCRIPTS = $(shell find $(SOURCE)/js -type f -name '*.js')
STYLES  = $(shell find $(SOURCE)/css -type f -name '*.scss')

# Default tasks
all: build
	@true
build: assets scripts styles
assets: $(BUILD)/index.html
scripts: $(BUILD)/assets/index.js
styles: $(BUILD)/assets/styles.css


# Copy assets
$(BUILD)/%.png: $(SOURCE)/%.png
	@mkdir -p $(@D)
	@cp $< $@
$(BUILD)/%.html: $(SOURCE)/%.html
	@mkdir -p $(@D)
	@cp $< $@

# Compile scripts with Browserify
$(BUILD)/assets/index.js: $(SCRIPTS)
	@mkdir -p $(@D)
	@browserify $(SOURCE)/js/index.js -o $@


# Compile styles with sass
$(BUILD)/assets/styles.css: $(STYLES)
	@mkdir -p $(@D)
	@sassc --sourcemap --load-path $(SOURCE)/css/ $(SOURCE)/css/styles.scss $@
	@autoprefixer $@ --clean --browsers "last 2 versions"

# Clean built directories
clean:
	@rm -rf ./build/
	@rm -rf ./components/

.PHONY: all build clean assets scripts styles