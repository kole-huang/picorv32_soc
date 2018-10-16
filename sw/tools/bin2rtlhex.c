/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>

static const char short_opts[] = "+si:o:b:";
static const struct option long_opts[] = {
	{ "swap", no_argument, NULL, 's' },
	{ "if", required_argument, NULL, 'i' },
	{ "of", required_argument, NULL, 'o' },
	{ "bw", required_argument, NULL, 'b' },
	{ NULL, no_argument, NULL, 0 }
};

static void print_usage(char *prog)
{
	printf("USAGE (for QuartusII memory initialize file):\n");
	printf("%s [-s] -i file.bin -o file.hex -b [8,16,32,64,128,256,1024]\n", prog);
}

int main(int argc,char *argv[])
{
	FILE *fr = NULL;
	FILE *fw = NULL;
	char *ifname = NULL;
	char *ofname = NULL;
	int c;
	int i = 0;
	int size = 0;
	int pos = 0;
	int bus_width = 0;
	int depth = 0;
	int pending_zero_byte_cnt = 0;
	int swap = 0;
	unsigned char *rb;

	if (argc < 7) {
		print_usage(argv[0]);
		return -1;
	}
	while ((c = getopt_long(argc, argv, short_opts, long_opts, NULL)) != -1) {
		switch (c) {
		case 's':
			swap = 1;
			break;
		case 'i':
			if (optarg) {
				ifname = optarg;
			}
			break;
		case 'o':
			if (optarg) {
				ofname = optarg;
			}
			break;
		case 'b':
			if (optarg) {
				bus_width = strtoul(optarg, NULL, 10);
			}
			break;
		default:
			print_usage(argv[0]);
			return -2;
		}

	}
	if (ifname == NULL) {
		printf("no input file specified!!\n");
		return -3;
	}
	if (ofname == NULL) {
		printf("no output file specified!!\n");
		return -4;
	}
	switch (bus_width) {
	case 8:
	case 16:
	case 32:
	case 64:
	case 128:
	case 256:
	case 512:
	case 1024:
		/* right, nothing to do */
		break;
	default:
		printf("invalid bus_width = %d, only 8, 16, 32, ..., 1024 are supported.\n", bus_width);
		return -5;
	}
	fr = fopen(ifname, "rb");
	if (fr == NULL) {
		printf("open %s failed.\n", ifname);
		return -6;
	}
	fw = fopen(ofname, "wb");
	if (fw == NULL) {
		printf("open %s failed.\n", ofname);
		fclose(fr);
		return -7;
	}
	fseek(fr, 0, SEEK_END);
	size = ftell(fr);
	fseek(fr, 0, SEEK_SET);
	rb = malloc(bus_width >> 3);
	if (rb == NULL) {
		printf("malloc failed!!\n");
		fclose(fr);
		fclose(fw);
		return -8;
	}
	depth = size / (bus_width >> 3);
	// check file size is alinged to bus_width
	if (size & ((bus_width >> 3) - 1)) {
		pending_zero_byte_cnt = (bus_width >> 3) - (size & ((bus_width >> 3) - 1));
	}
	while (depth) {
		switch (bus_width) {
		case 8:
			fread(rb, 1, 1, fr);
			fprintf(fw, "%02x\n", rb[0]);
			size--;
			depth--;
			pos++;
			break;
		case 16:
			fread(rb, 2, 1, fr);
			if (swap) {
				fprintf(fw, "%02x%02x\n", rb[1], rb[0]);
			} else {
				fprintf(fw, "%02x%02x\n", rb[0], rb[1]);
			}
			size -= 2;
			depth--;
			pos++;
			break;
		case 32:
			fread(rb, 4, 1, fr);
			if (swap) {
				fprintf(fw, "%02x%02x%02x%02x\n", rb[3], rb[2], rb[1], rb[0]);
			} else {
				fprintf(fw, "%02x%02x%02x%02x\n", rb[0], rb[1], rb[2], rb[3]);
			}
			size -= 4;
			depth--;
			pos++;
			break;
		case 64:
		case 128:
		case 256:
		case 512:
		case 1024:
			fread(rb, (bus_width >> 3), 1, fr);
			for (i = 0; i < (bus_width >> 3); i++) {
				if (swap) {
					fprintf(fw, "%02x", rb[(bus_width >> 3) - 1 - i]);
				} else {
					fprintf(fw, "%02x", rb[i]);
				}
			}
			fprintf(fw,"\n");
			size -= (bus_width >> 3);
			depth--;
			pos++;
			break;
		default:
			return -9;
		}
	}
	if (pending_zero_byte_cnt) {
		fread(rb, size, 1, fr);
		for (i = 0; i < pending_zero_byte_cnt; i++) {
			rb[size + i] = 0;
		}
		for (i = 0; i < (bus_width >> 3); i++) {
			if (swap) {
				fprintf(fw, "%02x", rb[(bus_width >> 3) - 1 - i]);
			} else {
				fprintf(fw, "%02x", rb[i]);
			}
		}
		fprintf(fw,"\n");
	}

	return 0;
}

