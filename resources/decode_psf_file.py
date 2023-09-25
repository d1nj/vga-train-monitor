"""
This script reads a psf file and prints the bytes holding
the data for a specific glyph.

Usage: python bytedump.py <file>

author: Jakob Arndt
date: 2023-03-16
"""
import sys

BYTESPERGLYPH = 16
HEADERSIZE = 4
NUMGLYPHS = 256
UNICODETABLEOFFSET = (BYTESPERGLYPH * NUMGLYPHS) + HEADERSIZE

# char = int(sys.argv[2])

file = open(sys.argv[1], "rb")
data = file.read()

# parse unicode table
unicodeTable = {}
offset = UNICODETABLEOFFSET
entry = 0
while entry < NUMGLYPHS:
    uint16_bytes = bytes([data[offset], data[offset+1]])
    uint16 = int.from_bytes(uint16_bytes, byteorder="little")
    offset += 2

    if uint16 == 0xFFFF:
        entry += 1
        continue

    if entry in unicodeTable:
        continue

    unicodeTable[entry] = uint16

print(unicodeTable)
for char in range(0, NUMGLYPHS):
    offset = HEADERSIZE + char * BYTESPERGLYPH

    # get unicode character

    print("========================")
    print(f"Char Number: {char}, Unicode Character: " + chr(unicodeTable[char]))
    print("---------")
    for i in range(offset, offset + BYTESPERGLYPH):
        byte = data[i]

        for bit in range(7, -1, -1):
            if byte & (1 << bit):
                print("\033[91m1\033[0m", end="")
            else:
                print("0", end="")

        print(f"{i-offset}", end="\n")
