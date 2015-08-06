
#
# Binaries
#

export PATH := ./node_modules/.bin:$(PATH)
BIN := ./node_modules/.bin

#
# Variables
#

HOST   ?= localhost
PORT   ?= 8080

SOURCE  = ./source
BUILD   = ./build

SCRIPTS = $(shell find $(SOURCE)/**/*.js)
STYLES  = $(shell find $(SOURCE)/**/*.css)

TRANSFORM = [ babelify --loose all ]
BROWSERS  = "last 2 versions"

#
# Tasks
#

build: assets scripts styles

develop: install
	@make -j2 develop-server develop-assets

develop-server:
	@budo $(SOURCE)/js/index.js:assets/index.js \
		--dir $(BUILD) \
		--port $(PORT) \
		--live \
		-- -t $(TRANSFORM) | garnish
develop-assets:
	@watch make assets styles --silent

install: node_modules

clean:
	@rm -rf $(BUILD)

#
# Shorthands
#

assets: $(BUILD)/index.html
scripts: $(BUILD)/assets/index.js
styles: $(BUILD)/assets/styles.css

#
# Targets
#

node_modules: package.json
	@npm install

$(BUILD)/%: $(SOURCE)/%
	@mkdir -p $(@D)
	@cp $< $@

$(BUILD)/assets/%.js: $(SCRIPTS)
	@mkdir -p $(@D)
	@browserify -t $(TRANSFORM) $(SOURCE)/js/index.js -o $@

$(BUILD)/assets/%.css: $(STYLES)
	@mkdir -p $(@D)
	@cssnext --browsers $(BROWSERS) --sourcemap  $< $@

#
# These tasks will be run every time regardless of dependencies.
#

.PHONY: develop clean
