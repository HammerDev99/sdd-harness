import sys
sys.path.insert(0, ".")

from modulo import suma


def test_suma():
    assert suma(1, 2) == 3
