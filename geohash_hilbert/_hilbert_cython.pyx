cdef unsigned long long cy_xy2hash_cython(unsigned long long x,
                                          unsigned long long y,
                                          const unsigned long long dim):
    cdef unsigned long long d = 0
    cdef unsigned long long lvl = dim >> 1
    cdef unsigned long long rx, ry

    while (lvl > 0):
        rx = <unsigned long long>((x & lvl) > 0)
        ry = <unsigned long long>((y & lvl) > 0)
        d += lvl * lvl * ((3 * rx) ^ ry)
        _rotate(lvl, &x, &y, rx, ry)
        lvl >>= 1
    return d

def xy2hash_cython(x: long, y: long, dim: int) -> long:
    return cy_xy2hash_cython(x, y, dim)


cdef void cy_hash2xy_cython(unsigned long long hashcode,
                            const unsigned long long dim,
                            unsigned long long* x,
                            unsigned long long* y):
    cdef unsigned long long lvl = 1
    cdef unsigned long long rx, ry
    x[0] = y[0] = 0

    while (lvl < dim):
        rx = 1 & (hashcode >> 1)
        ry = 1 & (hashcode ^ rx)
        _rotate(lvl, x, y, rx, ry)
        x[0] += lvl * rx
        y[0] += lvl * ry
        hashcode >>= 2
        lvl <<= 1


cpdef hash2xy_cython(unsigned long long hashcode, const unsigned long long dim):
    cdef unsigned long long x, y
    x = y = 0

    cy_hash2xy_cython(hashcode, dim, &x, &y)

    return x, y


cdef void _rotate(unsigned long long n,
                  unsigned long long* x,
                  unsigned long long* y,
                  unsigned long long rx,
                  unsigned long long ry):
    if ry == 0:
        if rx == 1:
            x[0] = n - 1 - x[0]
            y[0] = n - 1 - y[0]
        # swap x, y
        x[0] ^= y[0]
        y[0] ^= x[0]
        x[0] ^= y[0]