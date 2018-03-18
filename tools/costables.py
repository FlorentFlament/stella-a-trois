#!/usr/bin/env python3
from math import *
from asmlib import lst2asm

MAX_DISC_SIZE = 16
RESOLUTION = 32

def gendisc(disc_n, disc_max, res):
    # Returns cos values in [0,1]
    c = lambda x : (cos(x * pi / res) + 1) / 2
    f = lambda x : c(x)*2*disc_n + disc_max - disc_n
    r = lambda x : round(f(x))
    return map(r, range(res))

def main():
    for i in range(1, MAX_DISC_SIZE + 1):
        print("fx_disc_{}:".format(i));
        print(lst2asm(gendisc(i, MAX_DISC_SIZE, RESOLUTION)))

    print("fx_disc_l:")
    print("\tdc.b #0 ; Unused")
    for i in range(1, MAX_DISC_SIZE + 1):
        print("\tdc.b #<fx_disc_{}".format(i))

    print("fx_disc_h:")
    print("\tdc.b #0 ; Unused")
    for i in range(1, MAX_DISC_SIZE + 1):
        print("\tdc.b #>fx_disc_{}".format(i))

main()
