
#
# Binaries
#

export PATH := ./node_modules/.bin/:$(PATH)
BIN := ./node_modules/.bin

#
# Variables
#

PORT    = 8080
SOURCE  = ./source
BUILD   = ./build
SCRIPTS = $(shell find $(SOURCE)/js -type f -name '*.js')
STYLES  = $(shell find $(SOURCE)/css -type f -name '*.scss')


#
# Tasks
#

all: assets scripts styles
	@true

develop: install
	@make -j2 develop-server develop-assets

develop-server:
	@$(BIN)/budo $(SOURCE)/js/index.js:assets/index.js \
		--dir $(BUILD) \
		--port $(PORT) \
		--transform babelify \
		--live | $(BIN)/garnish
develop-assets:
	@watch make assets styles --silent

install: node_modules

clean:
	@rm -rf node_modules
	@rm -rf build

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
	@browserify $(SOURCE)/js/index.js -t babelify -o $@

$(BUILD)/assets/styles.css: $(STYLES)
	@mkdir -p $(@D)
	@sassc --sourcemap --load-path $(SOURCE)/css/ $(SOURCE)/css/styles.scss $@
	@$(BIN)/autoprefixer $@ --clean --map --browsers "last 2 versions"

#
# Phony
#

.PHONY: develop clean