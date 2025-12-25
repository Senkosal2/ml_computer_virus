import os
import socket
import time
import sys

HOST = os.getenv("ORACLE_HOST", "oradb")
PORT = int(os.getenv("ORACLE_PORT", "1521"))

timeout_s = int(os.getenv("ORACLE_WAIT_TIMEOUT", "900"))  # 15 minutes
interval_s = float(os.getenv("ORACLE_WAIT_INTERVAL", "3"))

deadline = time.time() + timeout_s

print(f"[wait_for_oracle] Waiting for Oracle at {HOST}:{PORT} (timeout={timeout_s}s)...", flush=True)

while True:
    try:
        with socket.create_connection((HOST, PORT), timeout=5):
            print("[wait_for_oracle] Oracle port is open.", flush=True)
            sys.exit(0)
    except OSError as e:
        if time.time() > deadline:
            print(f"[wait_for_oracle] TIMEOUT: could not connect to {HOST}:{PORT}. Last error: {e}", flush=True)
            sys.exit(1)
        time.sleep(interval_s)
