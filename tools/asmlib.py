def lst2asm(lst):
    res = []
    for i,v in enumerate(lst):
        if i%8 == 0:
            if i != 0:
                res.append('\n')
            res.append('\tdc.b ')
        else:
            res.append(', ')
        res.append("${:02x}".format(v))
    return ''.join(res)
