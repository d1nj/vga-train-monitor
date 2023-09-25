import random


def generate_image():
    f = open("framebuffer_init.coe", "w")
    f.write("memory_initialization_radix=16;\nmemory_initialization_vector=\n")

    horizontal = 640
    vertical = 480

    for pixel in range(horizontal * vertical):
        value = random.randint(0, 0xfff)

        hexstr = f"{value:#0{3}x}".split("x")[-1]
        f.write(hexstr + ",\n")

    f.close()


if __name__ == "__main__":
    generate_image()
