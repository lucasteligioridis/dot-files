SHELL := /bin/bash -eou pipefail
.SILENT:
DOT_FILES = $(shell ls -p1 dot/)
CONFIG_FILES = $(shell find config -type f -print)
BIN_FILES = $(shell ls -p1 bin/)

.PHONY: all
all: uninstall-all install-dots install-bins

.PHONY: uninstall-all
uninstall-all: uninstall-dots uninstall-bins

.PHONY: install-dots
install-dots: uninstall-dots
	for i in $(DOT_FILES); do \
		echo "Dots: Installing $$i to ~/.$$i"; \
	  gln -sr dot/$$i ~/.$$i; \
	done

.PHONY: install-configs
install-configs: uninstall-configs
	for i in $(CONFIG_FILES); do \
		echo "Configs: Installing $$i to ~/.$$i"; \
		mkdir -p "$(shell dirname ~/.$i)"; \
	  gln -sr $$i ~/.$$i; \
	done

.PHONY: uninstall-dots
uninstall-dots:
	for i in $(DOT_FILES); do \
	  rm -f ~/.$$i; \
	done

.PHONY: uninstall-configs
uninstall-configs:
	for i in $(CONFIG_FILES); do \
	  rm -f ~/.$$i; \
	done

.PHONY: install-bins
install-bins: uninstall-bins
	for i in $(BIN_FILES); do \
		echo "Bins: Installing $$i to ~/bin/$$i"; \
	  gln -sr bin/$$i ~/bin/$$i; \
	done

.PHONY: uninstall-bins
uninstall-bins:
	for i in $(BIN_FILES); do \
	  rm -f ~/bin/$$i; \
	done
