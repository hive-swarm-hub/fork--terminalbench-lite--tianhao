#!/usr/bin/env bash
# Evaluate the local agent on Terminal-Bench 2.0 tasks via Harbor.
# Uses --agent-import-path to run the agent from ./agent/ folder.
set -euo pipefail

if [ ! -f "data/test.jsonl" ]; then
    echo "ERROR: data/test.jsonl not found. Run: bash prepare.sh" >&2
    exit 1
fi

MODEL="${SOLVER_MODEL:-openai/gpt-4.1}"
CONCURRENT="${EVAL_CONCURRENT:-4}"

# Build task-name flags
TASK_FLAGS=$(python3 -c "
import json
tasks = [json.loads(l)['task_name'] for l in open('data/test.jsonl')]
print(' '.join(f'--task-name {t}' for t in tasks))
")

TOTAL=$(wc -l < data/test.jsonl | xargs)
echo "Evaluating $TOTAL tasks with model $MODEL ($CONCURRENT concurrent)..." >&2

# Run harbor with our local agent
PYTHONPATH=. harbor run \
  --dataset terminal-bench@2.0 \
  --agent-import-path agent.terminus_2:Terminus2 \
  --model "$MODEL" \
  $TASK_FLAGS \
  --n-concurrent "$CONCURRENT"
