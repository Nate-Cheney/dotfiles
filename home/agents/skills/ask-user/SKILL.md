---
name: ask-user
description: "Ask the user structured multiple-choice questions via the ask_user tool. Use in lieu of plain-text questions that require a response, including (but not limited to): clarification, preferences, and confirmation."
---

# Ask User

Call the `ask_user` tool to ask the user one or more questions with selectable options. Single question renders a simple list; multiple render a tabbed UI. TUI mode only.

## Schema

```json
{
  "questions": [{
    "id": "scope",
    "label": "Scope",
    "prompt": "Which modules should the change touch?",
    "options": [
      { "value": "api", "label": "API only", "description": "Route handlers and schemas" },
      { "value": "all", "label": "Full stack" }
    ],
    "allowOther": false
  }]
}
```

Per question:

- `id` (required): stable slug; echoed in results.
- `prompt` (required): full question text.
- `options` (required): `{value, label, description?}`. `value` is returned to you, `label` is shown, `description` is optional one-line elaboration.
- `label`: short tab label for multi-question UI (default `Q1`, `Q2`…).
- `allowOther`: defaults `true` (adds a "Type something" free-text option). Set `false` only when choices are truly exhaustive.

## Result

One line per question: `<label>: user selected: <n>. <label>` or `<label>: user wrote: <text>`. `User cancelled the questionnaire` if Esc.

## Best practices

- Batch related questions into one call; don't drip single questions when they belong together.
- Order options most-likely-first; keep labels short, details in `description`.
- `value` = machine-friendly slug; `label` = human-readable.
- Don't ask what you can infer from code, use only for genuine user-only decisions.
