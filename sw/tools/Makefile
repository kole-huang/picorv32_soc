all: bin2rtlhex bin2mif

bin2rtlhex: bin2rtlhex.c
	$(CC) -pipe -O2 $< -o $@

bin2mif: bin2mif.c
	$(CC) -pipe -O2 $< -o $@

clean:
	rm -f bin2mif bin2rtlhex
