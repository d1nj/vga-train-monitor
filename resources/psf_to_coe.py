"""
This script generates a .coe file from a .psf file. The .coe file is used to
initialize the BRAMs in the FPGA.

Usage: python psf_to_coe.py <psf-file> <coe-file>

author: Jakob Arndt
date: 2023-07-02
"""
import sys

BYTESPERGLYPH = 16
HEADERSIZE = 4
NUMGLYPHS = 256
UNICODETABLEOFFSET = (BYTESPERGLYPH * NUMGLYPHS) + HEADERSIZE

psf_name = sys.argv[1]
coe_name = sys.argv[2]
input_file = open(psf_name, "rb")
data = input_file.read()
gen_str = "; COE File generated from " + psf_name + "\n" \
            + "memory_initialization_radix=16;\n" \
            + "memory_initialization_vector=\n"

for char in range(0, NUMGLYPHS):
    offset = HEADERSIZE + char * BYTESPERGLYPH

    # get unicode character
    bytes = data[offset:offset+BYTESPERGLYPH]
    gen_str += (bytes.hex() + ",\n")

output_file = open(coe_name, "w")
output_file.write(gen_str[:-2] + ";\n")
output_file.close()
