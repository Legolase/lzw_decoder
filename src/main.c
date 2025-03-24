#define _CRT_SECURE_NO_WARNINGS
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef _MSC_VER
#include <intrin.h>
#else
#include <x86intrin.h>
#endif

#include <errno.h>
#include <stdbool.h>
#include <stddef.h>

size_t __attribute__((ms_abi)) lzw_decode(const uint8_t *in, size_t in_size,
                                          uint8_t *restrict out,
                                          size_t out_size);

int get_file(const char *fname, uint8_t **buffer, size_t *buffer_size) {
  int exit_code = 0;
  FILE *fd = fopen(fname, "rb");
  if (!fd) {
    exit_code = -2;
    goto clean;
  }
  fseek(fd, 0, SEEK_END);
  *buffer_size = ftell(fd);
  fseek(fd, 0, SEEK_SET);
  *buffer = malloc(sizeof(uint8_t) * *buffer_size);
  if (!*buffer) {
    exit_code = -3;
    goto clean;
  }
  size_t read_size = fread(*buffer, sizeof(uint8_t), *buffer_size, fd);
  if (read_size != *buffer_size) {
    fprintf(stderr, "read_size != *buffer_size -- %zd != %zd", read_size,
            *buffer_size);
    exit_code = -4;
    goto clean;
  }
clean:
  if (fd)
    fclose(fd);
  return exit_code;
}

int test(const char *fin, const char *fref) {
  int exit_code = 0;
  uint8_t *in = NULL, *out = NULL, *ref = NULL;
  size_t in_size = 0, ref_size = 0;

  if ((exit_code = get_file(fin, &in, &in_size))) {
    if (exit_code == -2)
      fprintf(stderr, "[FATAL ERROR] '%s' cannot opened!", fin);
    else if (exit_code == -3)
      fprintf(stderr, "[FATAL ERROR] not enought memory");
    else
      fprintf(stderr, "[FATAL ERROR] error during reading '%s'", fin);
    goto clean_all;
  }
  if ((exit_code = get_file(fref, &ref, &ref_size))) {
    if (exit_code == -2)
      fprintf(stderr, "[FATAL ERROR] '%s' cannot opened!", fref);
    else if (exit_code == -3)
      fprintf(stderr, "[FATAL ERROR] not enought memory");
    else
      fprintf(stderr, "[FATAL ERROR] error during reading '%s'", fref);
    goto clean_all;
  }
  out = malloc(sizeof(uint8_t) * ref_size + 0x100);
  if (!out) {
    exit_code = -3;
    goto clean_all;
  }

  size_t retcode = lzw_decode(in, in_size, out, ref_size);

  if (retcode == -1) {
    fprintf(stderr, "[ERROR] retcode lzw_decode() == -1");
    exit_code = -1;
    goto clean_all;
  }
  if (retcode != ref_size) {
    fprintf(stderr,
            "[ERROR] retcode lzw_decode() != expected count bytes - %zd != %zd",
            retcode, ref_size);
    exit_code = -1;
    goto clean_all;
  }

  exit_code = memcmp(ref, out, ref_size);
  if (exit_code) {
    fprintf(stderr, "[ERROR] out != expected");
    FILE *result_data =
        fopen("/home/nikita/assembler/x64/test_data/result", "wb");
    size_t written_bytes_count =
        fwrite(out, sizeof(uint8_t), ref_size, result_data);
    if (written_bytes_count != ref_size) {
      fprintf(stderr, "[ERROR] result not written");
    }
    fclose(result_data);
    exit_code = -1;
    goto clean_all;
  }

  unsigned int dummy;
  volatile uint64_t tr = __builtin_ia32_rdtscp(&dummy);
  for (unsigned int i = 0; i < 10000; i++)
    lzw_decode(in, in_size, out, ref_size);
  tr = __builtin_ia32_rdtscp(&dummy) - tr;
  printf("Time '%s': %llu\n", fin, tr / 1000000);

clean_all:
  if (in)
    free(in);
  if (out)
    free(out);
  if (ref)
    free(ref);
  return exit_code;
}

int main(void) {
  int exit_code;
  exit_code = test("/home/nikita/assembler/x64/test_data/in1",
                   "/home/nikita/assembler/x64/test_data/ref1");
  if (!exit_code)
    exit_code = test("/home/nikita/assembler/x64/test_data/in2",
                     "/home/nikita/assembler/x64/test_data/ref2");
  //>>>>>>>>>>>>>>>>>>>>>
  if (!exit_code)
    exit_code =
        test("/home/nikita/assembler/x64/test_data/lorem_ipsum_encoded.bin",
             "/home/nikita/assembler/x64/test_data/lorem_ipsum.txt");

  if (!exit_code)
    exit_code =
        test("/home/nikita/assembler/x64/test_data/in5",
             "/home/nikita/assembler/x64/test_data/ref5");

  if (!exit_code)
    exit_code = test("/home/nikita/assembler/x64/test_data/snail.pnm.out",
                     "/home/nikita/assembler/x64/test_data/snail.pnm.in");

  if (!exit_code)
    exit_code = test("/home/nikita/assembler/x64/test_data/circle.pnm.out",
                     "/home/nikita/assembler/x64/test_data/circle.pnm.in");

  if (!exit_code)
    exit_code = test("/home/nikita/assembler/x64/test_data/rays.pnm.out",
                     "/home/nikita/assembler/x64/test_data/rays.pnm.in");

  if (!exit_code)
    exit_code = test("/home/nikita/assembler/x64/test_data/rays2.pnm.out",
                     "/home/nikita/assembler/x64/test_data/rays2.pnm.in");

  if (!exit_code)
    exit_code = test("/home/nikita/assembler/x64/test_data/circle2.pnm.out",
                     "/home/nikita/assembler/x64/test_data/circle2.pnm.in");

  if (!exit_code)
    exit_code = test("/home/nikita/assembler/x64/test_data/snail2.pnm.out",
                     "/home/nikita/assembler/x64/test_data/snail2.pnm.in");

  return exit_code;
}