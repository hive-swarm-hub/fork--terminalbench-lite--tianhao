# Terminal-Bench Lite Solver

Improve the terminus-2 AI coding agent to maximize pass rate on Terminal-Bench Lite (16 tasks sampled from Terminal-Bench 2.0).

## Setup

1. **Read the agent source** in `agent/`:
   - `agent/terminus_2.py` — the main agent loop. Primary file to evolve.
   - `agent/templates/terminus-json-plain.txt` — the system prompt template.
   - `agent/tmux_session.py` — terminal interaction layer.
   - `agent/terminus_json_plain_parser.py` — response parser.
   - `eval/eval.sh` — runs evaluation via Harbor. Do not modify.
   - `prepare.sh` — creates the task list. Do not modify.
2. **Prerequisites**: Docker must be running. Harbor CLI must be installed (`uv tool install harbor`).
3. **Run prepare**: `bash prepare.sh` to create the task list.
4. **Initialize results.tsv**: Create `results.tsv` with just the header row.
5. **Run baseline**: `bash eval/eval.sh` to establish the starting accuracy.

## The benchmark

Terminal-Bench Lite is a 16-task subset of Terminal-Bench 2.0 spanning:
- **Build/compile**: build-cython-ext, build-pmars
- **Git/config**: configure-git-webserver, fix-git
- **Security**: fix-code-vulnerability, openssl-selfsigned-cert, vulnerable-secret
- **Systems**: custom-memory-heap-crash, headless-terminal
- **Data/ML**: code-from-image, financial-document-processor, sam-cell-seg, torch-pipeline-parallelism
- **Optimization**: constraints-scheduling, query-optimize
- **Parsing**: gcode-to-text

Each task runs in a Docker container. The agent receives a natural language instruction and uses shell commands to solve the problem. A test script verifies the solution.

## Experimentation

**What you CAN do:**
- Modify files in `agent/` — the agent source you evolve:
  - `terminus_2.py` — the core agent loop (tool-use, parsing, summarization)
  - `templates/terminus-json-plain.txt` — the system prompt template
  - `terminus_json_plain_parser.py` — JSON response parser
  - `tmux_session.py` — terminal interaction
  - Any file in `agent/` is fair game

**What you CANNOT do:**
- Modify `eval/`, `prepare.sh`, or Harbor itself.
- Change the model (set via `SOLVER_MODEL` env var).
- Modify task definitions or test scripts.

**The goal: maximize pass rate.** A task passes when the test script succeeds (reward = 1.0). Accuracy = fraction of 16 tasks passed.

**Cost** is a soft constraint.

**Simplicity criterion**: All else being equal, simpler is better.

## Output format

```
---
accuracy:         0.5000
correct:          8
total:            16
```

## Logging results

Log each experiment to `results.tsv` (tab-separated):

```
commit	accuracy	cost_usd	status	description
a1b2c3d	0.375000	10.00	keep	baseline
b2c3d4e	0.500000	12.00	keep	improved system prompt for build tasks
```

## The experiment loop

LOOP FOREVER:

1. **THINK** — decide what to try next. Review results.tsv. Consider:
   - Read the system prompt in `agent/templates/terminus-json-plain.txt` — can it be improved?
   - Is the agent exploring enough before making changes?
   - Could the parser be more robust?
   - Would task-category-specific strategies help?
2. Modify files in `agent/` with your experimental idea.
3. git commit
4. Run the experiment: `bash eval/eval.sh > run.log 2>&1`
5. Read the results from the summary at the end of run.log.
6. Record in results.tsv (do not commit results.tsv).
7. If accuracy improved, keep. If not, `git reset --hard HEAD~1`.

**Timeout**: If a full run exceeds 2 hours, kill it.

**NEVER STOP**: Once the loop begins, do NOT pause to ask the human. You are autonomous. The loop runs until interrupted.
