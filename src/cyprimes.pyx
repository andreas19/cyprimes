cimport cython
from libc.math cimport sqrt
from libc.limits cimport ULONG_MAX
from libc.stdlib cimport calloc, free, ldiv, ldiv_t
from libc.string cimport memcpy

__version__ = '0.4.0'
max_ulong = ULONG_MAX


@cython.cdivision(True)
cpdef bint is_prime(number) except -1:
    if number < 0 or number > max_ulong:
        raise ValueError('out of range 0..%d' % max_ulong)
    cdef unsigned long n = <unsigned  long> number
    if n <= 1:
        return 0
    if n < 4:
        return 1
    if n % 2 == 0:
        return 0
    if n < 9:
        return 1
    if n % 3 == 0:
        return 0
    cdef unsigned long r = <unsigned long> sqrt(n)
    cdef unsigned long f = 5
    while f <= r:
        if n % f == 0 or n % (f + 2) == 0:
            return 0
        f += 6
    return 1


cdef long bits = sizeof(int) * 8


cdef class Primes:
    cdef int *data
    cdef readonly long limit
    cdef long len
    cdef long ar_len
    cdef size_t ar_size

    def __cinit__(self, limit):
        if limit <= 0:
            raise ValueError('limit must be > 0 (got %d)' % limit)
        cdef long n = <long> limit
        self.limit = n
        self.ar_len = (n - 3) // 2 + 1
        self.len = self.ar_len + 1 if n > 1 else 0
        cdef ldiv_t r = ldiv(self.ar_len, bits)
        self.ar_size = r.quot + (1 if r.rem else 0)
        self.data = <int*> calloc(self.ar_size, sizeof(int))
        if not self.data:
            raise MemoryError()

    def __init__(self, limit):
        cdef long i, k, s, n = <long> limit
        for i in range(3, <long> sqrt(n) + 1, 2):
            if self.get_bit((i - 3) // 2) == 1:
                continue
            k = i * i
            s = 2 * i
            while k <= n:
                self.set_bit((k - 3) // 2)
                k += s

    def __dealloc__(self):
        free(self.data)

    cdef void set_bit(self, long idx):
        cdef ldiv_t r = ldiv(idx, bits)
        if not self.data[r.quot] & (1 << r.rem):
            self.len -= 1
            self.data[r.quot] |= 1 << r.rem

    cdef int get_bit(self, long idx):
        cdef ldiv_t r = ldiv(idx, bits)
        return 1 if self.data[r.quot] & (1 << r.rem) else 0

    def __len__(self):
        return self.len

    def __contains__(self, num):
        self._check_range(num)
        if num == 2:
            return True
        if num < 2 or num % 2 == 0:
            return False
        return self.get_bit((num - 3) // 2) == 0

    def __iter__(self):
        def iterator():
            if self.limit >= 2:
                yield 2
                yield from (i * 2 + 3 for i in range(self.ar_len)
                            if self.get_bit(i) == 0)
        return iterator()

    def __reversed__(self):
        def iterator():
            if self.limit >= 2:
                yield from (i * 2 + 3 for i in range(self.ar_len, -1, -1)
                            if self.get_bit(i) == 0)
                yield 2
        return iterator()

    def __getitem__(self, idx):
        length = self.__len__()
        if isinstance(idx, slice):
            lst = []
            for x in range(*idx.indices(length)):
                lst.append(self.__getitem__(x))
            return tuple(lst)
        if idx < 0:
            idx = length + idx
        if idx < 0 or idx >= length:
            raise IndexError('list index out of range')
        if idx == 0:
            return 2
        cdef long c = 0, i = <long> idx, k
        for k in range(self.ar_len):
            if self.get_bit(k) == 0:
                c += 1
                if c == i:
                    return k * 2 + 3

    def _check_range(self, num):
        if num < 0 or num > self.limit:
            raise ValueError('out of range 0..%d' % self.limit)

    def index(self, num):
        self._check_range(num)
        if num == 2:
            return 0
        cdef long idx = <long> (num - 3) // 2
        if num < 2 or num % 2 == 0 or self.get_bit(idx) == 1:
            raise ValueError('not prime')
        cdef long c = 1, i
        for i in range(idx):
            if self.get_bit(i) == 0:
                c += 1
        return c

    cdef bytes get_data(self):
        return <bytes> (<char*> self.data)[:self.ar_size * sizeof(int)]

    cdef void set_data(self, bytes data, long length):
        memcpy(self.data, <char*> data, self.ar_size * sizeof(int))
        self.len = length

    def __reduce__(self):
        return _reconstruct, (self.get_data(), self.limit, self.len)

cpdef object _reconstruct(data, limit, length):
    obj = Primes.__new__(Primes, limit)
    Primes.set_data(obj, data, length)
    return obj
