"""
This file generates a VHDL multplexer from the PSF Unicode table,
to translate the Unicode character to the correct glyph number.

Usage: python generate_mux.py <psf-file>

author: Jakob Arndt
date: 2023-03-16
"""

import sys

BYTESPERGLYPH = 16
HEADERSIZE = 4
NUMGLYPHS = 256
UNICODETABLEOFFSET = (BYTESPERGLYPH * NUMGLYPHS) + HEADERSIZE

def parse_unicode_table(file_name: str) -> dict:
    """
    parses the unicode table from the psf file

    :param file_name: the name of the psf file

    :return: a dictionary with the glyph number as key and the unicode character as value
    """
    file = open(file_name, "rb")
    data = file.read()

    unicodeTable = {}
    offset = UNICODETABLEOFFSET
    entry = 0
    while entry < NUMGLYPHS:
        # get unicode character
        uint16_bytes = bytes([data[offset], data[offset+1]])
        uint16 = int.from_bytes(uint16_bytes, byteorder="little")
        offset += 2

        if uint16 == 0xFFFF:
            entry += 1
            continue

        if entry in unicodeTable:
            continue

        unicodeTable[entry] = uint16

    return unicodeTable


unicode_table = parse_unicode_table(sys.argv[1])

output_str = "char_addr_out <="

for i in range(0, NUMGLYPHS):
    unicode = unicode_table[i].to_bytes(2, byteorder="big").hex()
    output_str += f" x\"{i:02x}\" when char_addr_in = x\"{unicode}\" else -- {chr(unicode_table[i])}\n"

file = open("mux.vhd", "w")
output_str += "x\"3f\"; -- ?\n"
file.write(output_str)
file.close()
print(output_str)
