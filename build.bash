#!/bin/bash

# сборка main.cpp
# clang++ -c ./src/main.cpp -o ./obj/main.o

# сборка ассемблерного файла
nasm -g -f elf64 -o ./obj/lzw64.o -l ./build/lzw64.list ./src/lzw64.asm

# линковка объектных файлов
# clang++ -o ./build/main ./obj/asm.o ./obj/main.o