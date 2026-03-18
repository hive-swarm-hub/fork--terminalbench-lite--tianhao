#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "data/test.jsonl" ]; then
    echo "ERROR: data/test.jsonl not found. Run: bash prepare.sh" >&2
    exit 1
fi

MODEL="${SOLVER_MODEL:-openai/gpt-4.1}"

TASK_FLAGS=$(python3 -c "
import json
tasks = [json.loads(l)['task_name'] for l in open('data/test.jsonl')]
print(' '.join(f'--task-name {t}' for t in tasks))
")

TOTAL=$(wc -l < data/test.jsonl | xargs)
echo "Evaluating $TOTAL tasks with model $MODEL (8 concurrent)..." >&2

PYTHONPATH=. harbor run \
  --dataset terminal-bench@2.0 \
  --agent-import-path agent.terminus_2:Terminus2 \
  --model "$MODEL" \
  $TASK_FLAGS \
  --n-concurrent 8
