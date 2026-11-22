import os


def database_url() -> str:
    """Adres bazy bierzemy WYŁĄCZNIE ze zmiennej środowiskowej (patrz .env.example)."""
    url = os.environ.get("DATABASE_URL")
    if not url:
        raise RuntimeError("DATABASE_URL is not set — skopiuj .env.example do .env i uzupełnij")
    return url
