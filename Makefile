CFLAGS += -Wall -Os -g
CC ?= gcc
TCLINC=/usr/include/tcl8.6
TCLLIB=/usr/lib/x86_64-linux-gnu

BUILD_DIR := ./build
SRC_DIR := .
SRC := $(wildcard $(SRC_DIR)/*.c)
OBJ := $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRC))


all: $(BUILD_DIR) $(BUILD_DIR)/tcl 

$(BUILD_DIR)/tcl: $(BUILD_DIR)/linenoise linenoise_example linenoise_utf8_example

$(BUILD_DIR)/linenoise: linenoise.h 
	$(CC) $(CFLAGS) -fPIC -shared -DDEBUG_REFRESHLINE -DUSE_TCL_STUBS -o $@.so  -I$(TCLINC)  ./syntax.c ./tcl-linenoise.c -L$(TCLLIB) -ltclstub8.6

linenoise_example: linenoise.h linenoise-ship.c linenoise-win32.c example.c
	$(CC) $(CFLAGS) -o $(BUILD_DIR)/$@ -I$(SRC_DIR) $(BUILD_DIR)/linenoise-ship.c example.c

linenoise_utf8_example: linenoise.h linenoise-ship.c linenoise-win32.c
	$(CC) $(CFLAGS) -DUSE_UTF8 -o $(BUILD_DIR)/$@ -I$(SRC_DIR) $(BUILD_DIR)/linenoise-ship.c example.c

clean:
	@echo "clean build dir ..."
	@rm -f linenoise_example linenoise_utf8_example linenoise-ship.c *.so *.o
	@rm -f $(BUILD_DIR)/*
ship: linenoise-ship.c

# linenoise-ship.c simplifies delivery of linenoise support
# simple copy linenoise-ship.c to linenoise.c in your application, and also linenoise.h
# - If you want win32 support, also copy linenoise-win32.c
# - If you never want to support utf-8, you can omit utf8.h and utf8.c

linenoise-ship.c: utf8.h utf8.c stringbuf.h stringbuf.c syntax.h syntax.c linenoise.c
	for i in $^; do echo "#line 1 \"$$i\""; cat $$i; done >$(BUILD_DIR)/$@

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)
