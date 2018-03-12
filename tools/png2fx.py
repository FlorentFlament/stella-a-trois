#!/usr/bin/env python3
from sys import argv
from PIL import Image

class BadImageException(Exception):
    pass

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

def lst2asm(lst):
    res = []
    for i,v in enumerate(lst):
        if i%8 == 0:
            if i != 0:
                res.append('\n')
            res.append('dc.b ')
        else:
            res.append(', ')
        res.append("${:02x}".format(v))
    return ''.join(res)

def main():
    fname = argv[1]
    # Convert to pure B&W without alpha picture
    im = Image.open(fname).convert('1')
    sanity_check(im)
    print(lst2asm(im2fx(im)))

main()
