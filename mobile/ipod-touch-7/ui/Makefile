CC ?= cc
CFLAGS ?= -O2 -std=c11 -Wall -Wextra -Werror
LDFLAGS ?=

.PHONY: all test clean
all: darth-shell

darth-shell: darth-shell.c
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

test: darth-shell
	./darth-shell --self-test

clean:
	rm -f darth-shell
