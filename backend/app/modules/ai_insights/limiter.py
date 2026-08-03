import threading
import time
from typing import Tuple


class GroqRateLimiter:
    """Thread-safe rate limiter untuk Groq API untuk menjaga penggunaan tetap di bawah batas Free Tier."""

    def __init__(self, max_per_minute: int = 20, max_per_day: int = 1000):
        self.max_per_minute = max_per_minute
        self.max_per_day = max_per_day
        self._lock = threading.Lock()
        self._minute_timestamps = []
        self._day_timestamps = []

    def allow_request(self, max_rpm: int = None, max_rpd: int = None) -> Tuple[bool, str]:
        """Mengecek apakah request diizinkan berdasarkan sliding window 1 menit dan 24 jam."""
        limit_rpm = max_rpm if max_rpm is not None else self.max_per_minute
        limit_rpd = max_rpd if max_rpd is not None else self.max_per_day

        now = time.time()
        with self._lock:
            # Hapus timestamp yang lebih tua dari 60 detik
            self._minute_timestamps = [t for t in self._minute_timestamps if now - t < 60]
            # Hapus timestamp yang lebih tua dari 86400 detik (24 jam)
            self._day_timestamps = [t for t in self._day_timestamps if now - t < 86400]

            if len(self._minute_timestamps) >= limit_rpm:
                return False, f"Batas Groq API per menit ({len(self._minute_timestamps)}/{limit_rpm} req/min) tercapai. Menggunakan Fallback System."

            if len(self._day_timestamps) >= limit_rpd:
                return False, f"Batas kuota Groq API harian ({len(self._day_timestamps)}/{limit_rpd} req/day) tercapai. Menggunakan Fallback System."

            # Sediakan kuota & catat timestamp
            self._minute_timestamps.append(now)
            self._day_timestamps.append(now)
            return True, "OK"


groq_limiter = GroqRateLimiter()
