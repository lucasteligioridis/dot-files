.PHONY: install
install:
	@for i in $$(ls -p1 | grep -v / | grep -v README | grep -v Makefile); do \
	  ln -sr $$i ~/.$$i; \
	done

.PHONY: uninstall
uninstall:
	@for i in $$(ls -p1 | grep -v / | grep -v README | grep -v Makefile); do \
	  [ ~/.$$i -ef $$i ] && rm -f ~/.$$i; \
	done
