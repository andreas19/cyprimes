import pathlib
import pickle

import pytest
import cyprimes as p


@pytest.fixture(scope='module')
def primes_from_file():
    with open(pathlib.Path(__file__).parent / 'primes.txt') as fh:
        return tuple(int(s) for line in fh for s in line.split())


@pytest.fixture(scope='module')
def primes_100():
    return p.Primes(100)


def test_is_prime(primes_from_file):
    with pytest.raises(TypeError):
        p.is_prime(1.2)
    with pytest.raises(ValueError):
        p.is_prime(-1)
    with pytest.raises(ValueError):
        p.is_prime(p.max_ulong + 1)
    assert p.is_prime(p.max_ulong) is False
    assert p.is_prime(0) is False
    assert p.is_prime(1) is False
    for prime in primes_from_file:
        assert p.is_prime(prime)
    with pytest.raises(TypeError):
        p.is_prime(2.3)


def test_primes(primes_from_file):
    with pytest.raises(TypeError):
        p.Primes('x')
    with pytest.raises(ValueError):
        p.Primes(0)
    limit = 7919
    primes = p.Primes(limit)
    assert len(primes) == len(primes_from_file)
    assert primes[0] == 2
    assert primes[-1] == limit
    assert primes[50:100:2] == primes_from_file[50:100:2]
    assert primes[500:300:-1] == primes_from_file[500:300:-1]
    for x in primes:
        assert x in primes_from_file
    for x in primes_from_file:
        assert x in primes
    assert 4 not in primes
    with pytest.raises(ValueError):
        -1 in primes
    with pytest.raises(ValueError):
        7920 in primes
    assert list(reversed(primes)) == list(reversed(primes_from_file))
    with pytest.raises(TypeError):
        p.Primes(2.3)


def test_primes_index(primes_100):
    assert primes_100.index(2) == 0
    assert primes_100.index(97) == len(primes_100) - 1
    with pytest.raises(TypeError):
        primes_100.index(1.1)
    with pytest.raises(ValueError):
        primes_100.index(-1)
    with pytest.raises(ValueError):
        primes_100.index(101)


def test_primes_next(primes_100):
    assert primes_100.next(0) == 2
    assert primes_100.next(2) == 3
    assert primes_100.next(90) == 97
    assert primes_100.next(97) is None
    assert primes_100.next(100) is None
    with pytest.raises(TypeError):
        primes_100.next(1.1)
    with pytest.raises(ValueError):
        primes_100.next(-1)
    with pytest.raises(ValueError):
        primes_100.next(101)


def test_primes_previous(primes_100):
    assert primes_100.previous(0) is None
    assert primes_100.previous(2) is None
    assert primes_100.previous(3) == 2
    assert primes_100.previous(97) == 89
    assert primes_100.previous(100) == 97
    with pytest.raises(TypeError):
        primes_100.previous(1.1)
    with pytest.raises(ValueError):
        primes_100.previous(-1)
    with pytest.raises(ValueError):
        primes_100.previous(101)


def test_primes_between(primes_100):
    assert primes_100.between(0, 10) == (2, 3, 5, 7)
    assert primes_100.between(2, 7) == (2, 3, 5, 7)
    assert primes_100.between(89, 100) == (89, 97)
    assert primes_100.between(3, 3) == (3,)
    assert primes_100.between(4, 4) == ()
    with pytest.raises(TypeError):
        primes_100.between(1.1, 2)
    with pytest.raises(TypeError):
        primes_100.between(0, 1.1)
    with pytest.raises(ValueError):
        primes_100.between(-1, 2)
    with pytest.raises(ValueError):
        primes_100.between(0, 101)
    with pytest.raises(ValueError):
        primes_100.between(1, 0)


def test_pickle():
    primes = p.Primes(1000)
    pickled = pickle.dumps(primes)
    assert list(primes) == list(pickle.loads(pickled))
