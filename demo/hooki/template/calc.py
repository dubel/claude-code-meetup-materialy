"""Mini-kalkulator — projekt demo na meetup Claude Code."""


def add(a: float, b: float) -> float:
    return a + b


def percent(value: float, pct: float) -> float:
    """Zwraca `pct` procent z `value`, np. percent(200, 10) == 20."""
    return value * pct / 10
