#########################################################################

depend: Makefile $(TOPDIR)/config.mk $(SRCS)
	@rm -f .depend
	@for f in $(SRCS); do \
		g=`basename $$f | sed -e 's/\(.*\)\.\w/\1.o/'`; \
		$(CC) -M $(CPPFLAGS) -MQ $$g $$f >> .depend ; \
	done

.depend: Makefile $(TOPDIR)/config.mk $(SRCS)
	@for f in $(SRCS); do \
		g=`basename $$f | sed -e 's/\(.*\)\.\w/\1.o/'`; \
		$(CC) -M $(CPPFLAGS) -MQ $$g $$f >> .depend ; \
	done

#########################################################################
