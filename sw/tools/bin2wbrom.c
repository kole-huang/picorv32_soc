/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define LOWER(x) (((x)>='A' && (x)<='Z')?(((x)-'A')+'a'):(x))

int main(int argc,char *argv[])
{
	FILE *fr = NULL;
	FILE *fw = NULL;

	unsigned char buf[4];
	int i;
	int len = 0;
	int size = 0;
	int pos = 0;
	int ret;

	if (argc == 3) {
		/* check bus width */
		fr = fopen(argv[1], "r");
		if (fr == NULL) {
			printf("open %s failed.\n", argv[1]);
			return -4;
		}
		fw = fopen(argv[2], "w");
		if (fw == NULL) {
			printf("open %s failed.\n", argv[2]);
			fclose(fr);
			return -5;
		}
		fseek(fr, 0, SEEK_END);
		size = ftell(fr);
		fseek(fr, 0, SEEK_SET);
		if (size & 3) {
			printf("size of input file %s is not 4bytes alignment\n", argv[1]);
			fclose(fr);
			fclose(fw);
			return -6;
		}
		while (size) {
			fprintf(fw, "%d:    wb_dat_o <= 32'h", pos);
			ret = fread(&buf, 4, 1, fr);
			for (i = 0; i < 4; i++) {
				fprintf(fw, "%02x", buf[i]);
			}
			fprintf(fw, ";\n");
			pos++;
			size -= 4;
		}
		if (fr != NULL)
			fclose(fr);
		if (fw != NULL)
			fclose(fw);
	} else {
		printf("USAGE:\n  %s file.bin file.txt\n", argv[0]);
		return -7;
	}

	return 0;
}

