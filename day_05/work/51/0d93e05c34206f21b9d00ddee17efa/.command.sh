#!/bin/bash -ue
python3 - <<'PY'
import base64
from pathlib import Path

text = base64.b64decode("Q29tcHV0YXRpb25hbCBXb3JrZmxvd3M=").decode("utf-8")
block_size = 3
prefix = "c_w"

if block_size <= 0:
    raise ValueError("block_size must be greater than zero")

for index, start in enumerate(range(0, len(text), block_size), start=1):
    chunk = text[start:start + block_size]
    Path(f"{prefix}_{index:03d}.txt").write_text(chunk, encoding="utf-8")
PY
