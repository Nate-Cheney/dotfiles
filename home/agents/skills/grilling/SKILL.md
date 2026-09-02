---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

This skill must use the **ask-user** skill's `ask_user` questionnaire for the session. Before asking, gather any facts that can be determined from the environment. Then ask one focused frontier decision per `ask_user` call, using the question title/body and recommended answer in the call's context or options. Do not batch unrelated decisions into a single questionnaire call. After each response, restate the decision in plain language and record it in the design tree.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled—the questions you can ask _now_ without guessing at answers you haven't heard yet. A round consists of asking every currently available frontier question sequentially through `ask_user`, then waiting for all answers before advancing to the next round. Number the questions within the round and give a recommended answer for each. If the questionnaire is unavailable, stop and explain that the required decision gate could not be used rather than silently falling back to plain-text questions.

Each round the user answers reshapes the tree; settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it—don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier through `ask_user`. The _decisions_ are the user's—put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding. At that point, summarize the agreed design and ask for confirmation through `ask_user` before implementation if implementation is requested.
