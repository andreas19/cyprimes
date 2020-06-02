# CyPrimes

Module for working with [prime numbers](https://en.wikipedia.org/wiki/Prime_number) written
in [Cython](https://cython.org/).

This is just a toy project to try out Cython.


## Installation

    # pip install cyprimes

To install *CyPrimes* a C-compiler ([GCC](https://en.wikipedia.org/wiki/GNU_Compiler_Collection),
[MinGW](https://en.wikipedia.org/wiki/MinGW)) is required.


## Usage

### Function is_prime(number)

This function returns `True` if the `number` is prime. Because it uses the C-type *unsigned long*
for `number` it raises a `ValueError` if `number < 0` or `number > cyprimes.max_ulong`.


### Class Primes(limit)

This class uses the *Sieve of Eratosthenes* to find all prime numbers up to `limit`. An instance of
this class supports the *len* function, the *in* operator, subscription (with integer indexes and slices),
has an *index* method, is iterable, and can be pickled.

**Warning**

Although this class uses a bitarray for the sieve be carefull not run out of memory:

|       limit       |   size   |
| ----------------: | -------: |
|               100 |      7 B |
|             1 000 |     63 B |
|            10 000 |    625 B |
|           100 000 |    6 KiB |
|         1 000 000 |   61 KiB |
|        10 000 000 |  610 KiB |
|       100 000 000 |    6 MiB |
|     1 000 000 000 |   60 MiB |
|    10 000 000 000 |  596 MiB |
|   100 000 000 000 |    6 GiB |
| 1 000 000 000 000 |   58 GiB |


## History

2020-06-02 (0.4.0)

* First public release
