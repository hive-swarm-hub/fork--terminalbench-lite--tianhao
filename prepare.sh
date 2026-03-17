#!/usr/bin/env bash
set -euo pipefail

echo "Checking prerequisites..."
which harbor >/dev/null 2>&1 || { echo "ERROR: harbor not installed. Run: uv tool install harbor"; exit 1; }
docker ps >/dev/null 2>&1 || { echo "ERROR: Docker not running."; exit 1; }

mkdir -p data

python3 << 'PY'
import json, pathlib

# 16 randomly sampled tasks from Terminal-Bench 2.0 (seed=42)
tasks = [
    {"task_name": "build-cython-ext"},
    {"task_name": "build-pmars"},
    {"task_name": "code-from-image"},
    {"task_name": "configure-git-webserver"},
    {"task_name": "constraints-scheduling"},
    {"task_name": "custom-memory-heap-crash"},
    {"task_name": "financial-document-processor"},
    {"task_name": "fix-code-vulnerability"},
    {"task_name": "fix-git"},
    {"task_name": "gcode-to-text"},
    {"task_name": "headless-terminal"},
    {"task_name": "openssl-selfsigned-cert"},
    {"task_name": "query-optimize"},
    {"task_name": "sam-cell-seg"},
    {"task_name": "torch-pipeline-parallelism"},
    {"task_name": "vulnerable-secret"},
]

out = pathlib.Path("data/test.jsonl")
with out.open("w") as f:
    for t in tasks:
        f.write(json.dumps(t) + "\n")
print(f"Wrote {len(tasks)} tasks to {out}")
PY

echo "Done. $(wc -l < data/test.jsonl | xargs) tasks in data/test.jsonl"
