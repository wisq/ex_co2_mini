#include <errno.h>
#include <fcntl.h>
#include <linux/hidraw.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#define MAX_SIZE 1024
#define TRUE 1

#define STDIN 0
#define STDOUT 1
#define STDERR 2

int main(int argc, char **argv) {
	char key[9];
	char buf[MAX_SIZE + 1];

	if (argc != 10) {
		fprintf(stderr, "Usage: %s <k1> <k2> ... <k7> <k8> <device>\n", argv[0]);
		return -1;
	}

	key[0] = 0;
	for (int i = 1; i <= 8; i++) {
		key[i] = atoi(argv[i]);
	}

	char *filename = argv[9];
	int fd = open(filename, 0);

	if (fd < 0) {
		fprintf(stderr, "Can't open %s: %s\n",
			filename, strerror(errno));
		return -1;
	}

	int res = ioctl(fd, HIDIOCSFEATURE(9), key);

	if (res < 0) {
		perror("ioctl(HIDIOCSFEATURE)");
		return -1;
	}

	while (TRUE) {
		int bytes = read(fd, buf, MAX_SIZE);
		if (bytes < 0) {
			perror("read");
			return -1;
		}

		res = write(STDOUT, buf, bytes);
		if (res < 0) {
			perror("write");
			return -1;
		}
	}

	return 0;
}
