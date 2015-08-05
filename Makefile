
#
# Binaries
#

export PATH := ./node_modules/.bin/:$(PATH)
BIN := ./node_modules/.bin

#
# Variables
#

HOST   ?= localhost
PORT   ?= 8080

SOURCE  = ./source
BUILD   = ./build

SCRIPTS = $(shell find $(SOURCE)/js  -type f -name '*.js')
STYLES  = $(shell find $(SOURCE)/css -type f -name '*.css')

ARGS      = -t [ babelify --loose all ] -t envify -t uglifyify
BROWSERS  = "last 2 versions"
NODE_ENV ?= development

#
# Tasks
#

build: assets scripts styles

develop: install
	@make -j2 develop-server develop-assets

develop-server:
	@$(BIN)/budo $(SOURCE)/js/index.js:assets/index.js \
		--dir $(BUILD) \
		--port $(PORT) \
		--live \
		-- $(ARGS) | $(BIN)/garnish
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

$(BUILD)/assets/index.js: $(SCRIPTS)
	@mkdir -p $(@D)
	@$(BIN)/browserify $(ARGS) $(SOURCE)/js/index.js -o $@

$(BUILD)/assets/styles.css: $(STYLES)
	@mkdir -p $(@D)
	@if [ $(NODE_ENV) == "development" ]; then $(BIN)/cssnext --sourcemap --browsers $(BROWSERS) $< $@; fi
	@if [ $(NODE_ENV) == "production" ]; then $(BIN)/cssnext --compress --browsers $(BROWSERS) $< $@; fi


#
# Phony
#

.PHONY: develop clean
