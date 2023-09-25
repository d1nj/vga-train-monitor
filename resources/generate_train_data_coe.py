"""
Python Script putting the train data given as a string into a coe file
which can be loaded into an BRAM.

Usage: python generate_train_data_coe.py

author: Jakob Arndt
date: 2023-03-16
"""

LEN_STATION_NAME = 50
LEN_CURR_TIME = 4
LEN_CONNECTION = 80

def format_string(input_string: str, new_line: bool) -> str:
    out_str = ""
    add_zeros = True
    for i in range (0, len(input_string), 2):
        first_char = ord(input_string[i]).to_bytes(2, byteorder="little").hex()
        if new_line:
            out_str += f"{first_char},\n"
            new_line = False

        if i == len(input_string) - 1:
            out_str += "0000{}".format(first_char) + ",\n"
            add_zeros = False
            break

        second_char = ord(input_string[i+1]).to_bytes(2, byteorder="little").hex()
        out_str += "{}{}".format(second_char, first_char) + ",\n"

    newline = False
    if add_zeros:
        out_str += "0000,\n"
        newline = True

    return out_str, newline



station_name = "Rathaus Spandau"
curr_time = "1200"
connection1 = "U7 Richtung Rudow"
connection2 = "RE4 Richtung Jüterbog"

file_name = "train_data.coe"

gen_str = "; COE File with example train data\n" \
            + "memory_initialization_radix=16;\n" \
            + "memory_initialization_vector=\n"

station_str, newline = format_string(station_name, False)
time_str, newline = format_string(curr_time, newline)
conn_str, newline = format_string(connection1, newline)
conn2_str, newline = format_string(connection2, newline)

gen_str += station_str + time_str + conn_str + conn2_str

output_file = open(file_name, "w")
output_file.write(gen_str[:-2] + ";\n")
output_file.close()