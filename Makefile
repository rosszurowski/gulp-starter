
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

develop:
	@echo "  "
	@echo "  \033[0;32mDevelopment server is running...\033[0m"
	@echo "  Listening on http://localhost:$(PORT)"
	@echo "  \033[0;90mCtrl+C to shut down\033[0m"
	@echo "  "
	@budo $(SOURCE)/js/index.js:assets/index.js \
		--dir $(BUILD) \
		--port $(PORT) \
		--transform babelify \
		--no-stream \
		--live & watch make --silent assets styles

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
	@autoprefixer $@ --clean --map --browsers "last 2 versions"

#
# Phony
#

.PHONY: develop clean