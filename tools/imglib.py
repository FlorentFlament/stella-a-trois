class BadImageException(Exception):
    pass

def lbool2int(lst):
    """Converts a list of boolean to an integer.
    The list usually contains 8 items for a corresponding an 8 bits integer.
    """
    r = 0
    for b in lst:
        r <<= 1
        r |= b
    return r

