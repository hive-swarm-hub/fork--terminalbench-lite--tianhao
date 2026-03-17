#!/usr/bin/env bash
# Evaluate the local agent on Terminal-Bench 2.0 tasks via Harbor.
# Uses --agent-import-path to run the agent from ./agent/ folder.
set -euo pipefail

if [ ! -f "data/test.jsonl" ]; then
    echo "ERROR: data/test.jsonl not found. Run: bash prepare.sh" >&2
    exit 1
fi

MODEL="${SOLVER_MODEL:-openai/gpt-4.1}"

# Build task-name flags
TASK_FLAGS=$(python3 -c "
import json
tasks = [json.loads(l)['task_name'] for l in open('data/test.jsonl')]
print(' '.join(f'--task-name {t}' for t in tasks))
")

TOTAL=$(wc -l < data/test.jsonl | xargs)
echo "Evaluating $TOTAL tasks with model $MODEL..." >&2

# Run harbor with our local agent
PYTHONPATH=. harbor run \
  --dataset terminal-bench@2.0 \
  --agent-import-path agent.terminus_2:Terminus2 \
  --model "$MODEL" \
  $TASK_FLAGS \
  --n-concurrent 1

# Parse results from latest job
CORRECT=$(python3 -c "
import json, glob
jobs = sorted(glob.glob('jobs/*/result.json'))
if not jobs:
    print(0)
else:
    d = json.load(open(jobs[-1]))
    results = d.get('results', [])
    correct = sum(1 for r in results if r.get('verifier_result', {}).get('rewards', {}).get('reward', 0) == 1.0)
    print(correct)
")

ACCURACY=$(python3 -c "
t, c = int('$TOTAL'), int('$CORRECT')
print(f'{c/t:.6f}' if t > 0 else '0.000000')
")

echo "---"
echo "accuracy:         $ACCURACY"
echo "correct:          $CORRECT"
echo "total:            $TOTAL"
