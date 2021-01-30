
MAIN:=DList

SRC:=$(MAIN).d

DC?=dmd

DFLAGS:=-unittest -g -main

all:
	$(DC) $(DFLAGS) $(SRC)

run: all
	./$(MAIN)

clean:
	rm -f $(MAIN)
