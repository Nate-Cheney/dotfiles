---
name: research
description: "Source-driven research executed by a synchronous sub-agent. Orchestrates: plan, approval gate, delegate to an isolated pi process, then deliver an executive summary plus a cited Markdown report file. Use only when invoked deliberately as /skill:research with a research question."
disable-model-invocation: true
---

# Research

You are the **orchestrator**. You do not perform research: you plan, get approval, then delegate the research to a **sub-agent** (a separate `pi` process with an isolated context window) via a synchronous bash call. When the sub-agent finishes, you read its report and deliver an executive summary.

## Invocation

```text
/skill:research [quick|standard|deep] <research question>
```

If the first argument is `quick`, `standard`, or `deep`, use it as the depth and treat the remaining text as the question. Otherwise use `standard` as the default. If no meaningful question is supplied, ask the user to invoke the skill again with one; do not browse.

## Orchestrator workflow

### 1. Plan before browsing

Reason about the request without calling `websearch` or `webfetch`. Produce a concise research brief containing:

- The research objective.
- 3-7 key questions or decision points.
- The scope, time frame, definitions, and assumptions.
- The source strategy, including primary sources or authoritative institutions to seek.
- The expected final deliverable.

Do not present unsupported current facts as findings. The plan is not research evidence.

### 2. Approval gate

Call the `ask_user` tool with one focused question: "Should I begin this research plan?" and these choices:

- **Approve**: delegate to the sub-agent.
- **Cancel**: stop without any research work.
- `allowOther`: leave the default (true) to allow revision.

If `ask_user` is unavailable, stop and say the approval gate cannot be performed. Never silently replace it with a plain-text question or proceed unapproved.

### 3. Prepare artifacts

Only after approval:

1. Derive a kebab-case `slug` (≤ 40 chars) from the question.
2. Set `REPORT_PATH=.research/reports/$(date +%F)-<slug>.md` and `RUN_DIR=.research/runs/<slug>-$(date +%H%M%S)`.
3. `mkdir -p` both.
4. Write the approved research plan to `$RUN_DIR/research-plan.md`.

### 4. Worker prompt

The worker's system prompt consists of two parts: a main shared prompt and a secondary prompt. The supplemental prompt will be selected based on the research depth.

```
~/.agents/skills/research/worker/
├── system-prompt.md
└── depths/
    ├── quick.md
    ├── standard.md
    └── deep.md
```

The worker's main system prompt is always: `~/.agents/skills/research/worker/system-prompt.md`.
The worker's supplemental prompt will be: `~/.agents/skills/research/worker/depths/<research_depth>.md`.

The pi flags: `system-prompt` and `append-system-prompt` will be used when spawning the sub-agent. This prevents the **ochestrator** from needing to read and concatinate the prompts.

### 5. Sub-agent Timeout

The configured timeout will depend on the research depth. Use the following times (seconds) for each depth:
- **deep**: 900
- **standard**: 480
- **quick**: 240 

### 6. Spawn the sub-agent synchronously

Run **one bash call**, with the bash tool's `timeout` parameter set to the depth's configured timeout in seconds:

```bash
pi -p \
  --name "research: <slug>" \
  --tools websearch,webfetch,read,write \
  --system-prompt "$HOME/.agents/skills/research/worker/system-prompt.md" \
  --append-system-prompt "Today is $(date +%F)" \
  --append-system-prompt "$HOME/.agents/skills/research/worker/depths/<depth>.md" \
  > "$RUN_DIR/output.log" 2>&1
```

Notes:

- Do **not** pass `--no-extensions` or `--no-skills`: the web tools and the research skill itself must load.
- Do **not** background the process (`&`, `nohup`): this call is deliberately synchronous; your turn waits.
- One research run at a time per session.

### 7. Verify and deliver

After the bash call returns:

1. Check the exit code and that `$REPORT_PATH` exists and is non-empty. If not, follow **Failure handling**.
2. Read the report file.
3. Post to chat: an **executive summary** (succinct and direct answer to the objective, key claims with inline links to sources the sub-agent actually fetched), the report path, and any unresolved questions the report flags. Do not paste the full report; the file is the artifact.
4. If the report is labeled partial, preserve that label prominently.

### 8. Failure handling

Fail closed, never fabricate or fall back to memory:

- **Non-zero exit / missing report:** tell the user plainly, give `$RUN_DIR/output.log` for inspection, and report what was NOT established. Offer (a) inspect the log, (b) run inline with approval, or (c) abandon. Never auto-respawn.
- **Timeout:** the process was killed; state the timeout, point at `output.log` and any partial report. If a partial report exists, you may summarize it only when clearly labeled **Partial research report**.
- **Sub-agent asked a question instead of finishing** (visible in `output.log`): do not answer it blindly; surface it to the user.
