#!/usr/bin/env python3
import itertools
from sys import argv
from PIL import Image

from asmlib import lst2asm
from imglib import BadImageException

class HiResPF:
    # A couple of static methods and fields

    def __lbool2int(lst):
        r = 0
        for b in lst:
            r <<= 1
            r |= b
        return r

    __line_pf = [
        lambda l: HiResPF.__lbool2int(itertools.chain(reversed(l[0:4]), [False]*4)),
        lambda l: HiResPF.__lbool2int(l[4:12]),
        lambda l: HiResPF.__lbool2int(reversed(l[12:20])),
        lambda l: HiResPF.__lbool2int(itertools.chain(reversed(l[20:24]), [False]*4)),
        lambda l: HiResPF.__lbool2int(l[24:32]),
        lambda l: HiResPF.__lbool2int(reversed(l[32:40])),
    ]

    def __init__(self, image):
        self.__transparency = image.info['transparency']
        self.__width, self.__height = image.size

        # Slicing image data into a "list" of lines to allow iterating over it multiple times
        raw = list(image.getdata())
        lines = [raw[x:x+self.__width] for x in range(0, len(raw), self.__width)]

        # Building lists to allow more freedom on their usage
        self.__data = [[x != self.__transparency for x in l] for l in lines]
        self.__colors = [next((x for x in l if x != self.__transparency), None) for l in lines]

    def get_pf(self, n):
        return (HiResPF.__line_pf[n](list(l)) for l in self.__data)

    def get_all_pfs(self):
        return (self.get_pf(n) for n in range(6))

    # Arbitrarily replace None with color 0
    # This shouldn't be an issue since the color is unused
    def get_all_cols(self):
        return (x if x else 0 for x in self.__colors)

def print_block(lst, name):
    print("{}:".format(name))
    print(lst2asm(lst))

def main():
    fname = argv[1] # filename
    sname = argv[2] # symbol name

    hrpf = HiResPF(Image.open(fname))
    for i,pf in enumerate(hrpf.get_all_pfs()):
        print_block(pf, "{}_pf{}".format(sname, i))
    print_block(hrpf.get_all_cols(), "{}_cols".format(sname))

main()
