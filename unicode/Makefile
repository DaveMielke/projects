all: uclist ucwide

uclist: uclist.o
	cc -o $@ uclist.o -licuuc

ucwide: ucwide.o
	cc -o $@ ucwide.o -licuuc

%.o: %.c
	cc -o $@ -c $<

