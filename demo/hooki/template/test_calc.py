import unittest

from calc import add, percent


class TestCalc(unittest.TestCase):
    def test_add(self):
        self.assertEqual(add(2, 3), 5)

    def test_percent(self):
        self.assertEqual(percent(200, 10), 20)


if __name__ == "__main__":
    unittest.main()
