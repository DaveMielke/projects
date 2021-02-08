all: uclist

uclist: uclist.o
	cc -o $@ uclist.o -licuuc

%.o: %.c
	cc -o $@ -c $<

