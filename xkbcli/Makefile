all: xkbcli

CC = cc
LIBS = -lcursesw -lXtst -lX11

%.o: %.c
	$(CC) -o $@ -c $<

xkbcli: xkbcli.o
	$(CC) -o $@ xkbcli.o $(LIBS)

clean:
	-rm -f -- xkbcli xkbcli.o

