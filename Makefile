CFLAGS += -Wall -Os -g
CC ?= gcc
TCLINC=/usr/include/tcl8.6
TCLLIB=/usr/lib/x86_64-linux-gnu

all:  linenoise_example linenoise_utf8_example tcl

tcl: linenoise

linenoise: linenoise.h linenoise-ship.c 
	$(CC) $(CFLAGS) -fPIC -shared -DDEBUG_REFRESHLINE -DUSE_TCL_STUBS -o $@.so -I$(TCLINC) linenoise-ship.c tcl-linenoise.c  -L$(TCLLIB) -ltclstub8.6

linenoise_example: linenoise.h linenoise-ship.c linenoise-win32.c example.c
	$(CC) $(CFLAGS) -o $@ linenoise-ship.c example.c

linenoise_utf8_example: linenoise.h linenoise-ship.c linenoise-win32.c
	$(CC) $(CFLAGS) -DUSE_UTF8 -o $@ linenoise-ship.c example.c

clean:
	rm -f linenoise_example linenoise_utf8_example linenoise-ship.c *.so *.o

ship: linenoise-ship.c

# linenoise-ship.c simplifies delivery of linenoise support
# simple copy linenoise-ship.c to linenoise.c in your application, and also linenoise.h
# - If you want win32 support, also copy linenoise-win32.c
# - If you never want to support utf-8, you can omit utf8.h and utf8.c

linenoise-ship.c: utf8.h utf8.c stringbuf.h stringbuf.c linenoise.c
	for i in $^; do echo "#line 1 \"$$i\""; cat $$i; done >$@
