MIX = mix
CFLAGS += -g -O3 -std=c99 -Wall -Wextra -Wno-unused-parameter

all: priv/reader

clean:
	rm -f priv/reader

.PHONY: all clean

priv/reader: src/reader.c priv
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

priv:
	mkdir $@
