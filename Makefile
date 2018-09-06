DOT_FILES = $(shell ls -p1 | grep -vE '/|README|Makefile')

.PHONY: install
install:
	@for i in $(DOT_FILES); do \
	  ln -sr $$i ~/.$$i; \
	done

.PHONY: uninstall
uninstall:
	@for i in $(DOT_FILES); do \
	  [ ~/.$$i -ef $$i ] && rm -f ~/.$$i; \
	done
