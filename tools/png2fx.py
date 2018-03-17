#!/usr/bin/env python3
from sys import argv
from PIL import Image

from asmlib import lst2asm
from imglib import BadImageException

# Check that each line has not more than 1 white pixel
def sanity_check(im):
    width, height = im.size

    for y in range(height):
        cnt = 0
        for x in range(width):
            if im.getpixel((x,y)) != 0:
                cnt += 1
        if cnt > 1:
            raise BadImageException("Line {} has {} white pixels".format(y, cnt))

def im2fx(im):
    width, height = im.size
    res = [None]*height

    for y in range(height):
        for x in range(width):
            if im.getpixel((x,y)) != 0:
                res[y] = x;
                break

    res.reverse()
    return res

def main():
    fname = argv[1]
    # Convert to pure B&W without alpha picture
    im = Image.open(fname).convert('1')
    sanity_check(im)
    print(lst2asm(im2fx(im)))

main()
