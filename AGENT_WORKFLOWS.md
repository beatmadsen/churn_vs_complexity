# Agent Workflows for Balancing Rigor

Design document for new `churn_vs_complexity` workflows aimed at LLM coding agents.

## Problem

LLM-augmented coding involves a trade-off between speed and rigor. Single-agent "vibe coding" is fast and cheap. Multi-agent collaboration (mob programming, TDD, pair review) produces better code but costs 10x+ more in tokens.

You don't need rigor everywhere, all the time. The practical question is: **where should I invest?**

`churn_vs_complexity` already computes the data to answer this — churn frequency, complexity scores, and the gamma score (harmonic mean of churn and complexity). What's missing is packaging that data into formats and workflows that agents can consume directly as part of their decision-making.

## Enabling Prerequisite: `--json` Output

Before any workflow below, the single highest-leverage change is adding `--json` as a first-class output format across all modes.

`Normal::Serializer::SummaryHash` already computes mean, median, min, max, and gamma scores. The `values_by_file` hash has per-file churn and complexity. This data just needs to be serializable as JSON instead of only feeding into human-readable text and HTML.

This is the unlock for all five workflows below.

## Proposed Workflows

### 1. Triage — "Should I be careful with these files?"

**What it does:** Given a list of files (or a directory), returns per-file risk assessment based on churn history and complexity.

**CLI interface:**
```
churn_vs_complexity --triage file1.rb file2.rb lib/
churn_vs_complexity --triage --json .
```

**Example output (JSON):**
```json
{
  "files": [
    {
      "file": "lib/churn_vs_complexity/engine.rb",
      "churn": 47,
      "complexity": 23.4,
      "gamma_score": 31.2,
      "risk": "high",
      "recommendation": "Write tests before modifying. Consider multi-agent review."
    },
    {
      "file": "lib/churn_vs_complexity/version.rb",
      "churn": 12,
      "complexity": 1.0,
      "risk": "low",
      "recommendation": "Safe for quick changes."
    }
  ],
  "summary": {
    "high_risk": 1,
    "medium_risk": 0,
    "low_risk": 1
  }
}
```

**Why this matters:** This is the most natural fit for agent workflows. Before every edit, an agent faces the question "how careful should I be here?" Triage answers it directly. The cost of running triage is trivial compared to the cost of applying unnecessary rigor everywhere or missing a hotspot.

**Agent integration:** An agent (or a CLAUDE.md instruction) runs triage before modifying files. High-risk files trigger expensive workflows (TDD, mob programming, pair review). Low-risk files get fast treatment. The decision is data-driven rather than gut-feel.

**UX considerations:**
- Must accept file paths as arguments (not just directories) so agents can triage exactly the files they're about to touch
- Risk thresholds should be configurable but ship with sensible defaults
- The interpretive layer (risk levels + recommendations) is what makes this actionable — raw numbers force agents to re-derive the interpretation every time

### 2. Hotspot Map — "Where does this codebase hurt?"

**What it does:** Generates a ranked list of files by risk, suitable for embedding in project context (CLAUDE.md, `.hotspots.json`).

**CLI interface:**
```
churn_vs_complexity --hotspot-map .
churn_vs_complexity --hotspot-map --format json .
churn_vs_complexity --hotspot-map --format markdown .
```

**Example output (Markdown, for CLAUDE.md):**
```markdown
## Hotspot Map (generated 2026-02-18)

### High Risk — require tests and careful review
- `lib/engine.rb` (gamma: 31.2, churn: 47, complexity: 23.4)
- `lib/traveller.rb` (gamma: 28.7, churn: 39, complexity: 21.1)

### Medium Risk — exercise judgement
- `lib/cli/parser.rb` (gamma: 14.5, churn: 22, complexity: 11.3)

### Low Risk — safe for quick changes
- `lib/version.rb` (gamma: 0.9, churn: 12, complexity: 1.0)
```

**Why this matters:** Runs once (in CI or manually), produces a snapshot that informs every subsequent agent session. Zero per-task cost — the investment is amortised across all future work. Agents consulting CLAUDE.md at session start immediately know which areas demand care.

**Agent integration:** Generate periodically (CI pipeline, post-sprint). Include Markdown output in CLAUDE.md or a linked file. Every agent session starts informed without running any analysis.

**UX considerations:**
- Markdown format for CLAUDE.md inclusion; JSON format for programmatic consumption
- Should include a generation timestamp so staleness is visible
- Keep the output concise — agents have limited context windows too

### 3. Snapshot Diff — "Did I make things better or worse?"

> **Note: Overlap with existing Delta mode.** Delta already does per-commit analysis —
> it checks out specific commits via worktrees, finds changed files, and annotates each
> with complexity. Snapshot Diff would add an *aggregate* comparison layer on top (mean
> gamma before vs. after, per-file direction). This is a convenience wrapper — you could
> approximate it today by running Normal mode at two refs and comparing results. Consider
> whether this justifies a new mode or is better served by adding `--json` to Normal mode
> and letting agents do the comparison themselves.

**What it does:** Compares aggregate codebase health metrics between two git refs, showing overall direction and per-file changes.

**CLI interface:**
```
churn_vs_complexity --snapshot-diff HEAD~10 .
churn_vs_complexity --snapshot-diff v1.0.0 .
churn_vs_complexity --snapshot-diff --json HEAD~10 .
```

**Example output (JSON):**
```json
{
  "reference": "HEAD~10",
  "current": "HEAD",
  "overall": {
    "mean_gamma_before": 12.3,
    "mean_gamma_after": 14.1,
    "direction": "degraded"
  },
  "degraded": [
    {
      "file": "lib/engine.rb",
      "gamma_before": 20.1,
      "gamma_after": 31.2,
      "change": "+55%"
    }
  ],
  "improved": [
    {
      "file": "lib/calculator.rb",
      "gamma_before": 18.5,
      "gamma_after": 12.0,
      "change": "-35%"
    }
  ],
  "unchanged": 14
}
```

**Why this matters:** After a sprint of fast prototyping, this answers "what debt did we accumulate and where?" But honestly, the unique value over Delta + Normal is thin — it's mainly the aggregate summary and the "direction" interpretation. May not be worth building as a separate mode.

**Agent integration:** Run after a batch of changes to evaluate whether a prototyping sprint created debt worth addressing.

**UX considerations:**
- The unique value is the aggregate "direction" interpretation — if that's all that's needed, it might be a flag on Normal mode rather than a new mode
- Could be deferred until `--json` on Normal mode proves insufficient in practice

### 4. Gate — "Pass/fail quality check"

**What it does:** Binary pass/fail check against configurable thresholds. Returns exit code 0 (pass) or 1 (fail).

**CLI interface:**
```
churn_vs_complexity --gate .
churn_vs_complexity --gate --max-gamma 30 .
churn_vs_complexity --gate --max-gamma 30 --json .
```

**Example output (JSON, on failure):**
```json
{
  "passed": false,
  "threshold": { "max_gamma": 30 },
  "violations": [
    {
      "file": "lib/engine.rb",
      "gamma_score": 31.2,
      "exceeds_by": "4%"
    }
  ]
}
```

**Why this matters:** Dead simple for CI and git hooks. No interpretation needed — it's binary. Agents that trigger a failure know they need to circle back. This is the "guardrail" that prevents prototyping from going too far without manual oversight.

**Agent integration:** Add to pre-push hooks or CI. When the gate fails, the agent knows to apply rigorous workflows (refactoring, test writing) to the violating files before shipping.

**UX considerations:**
- Exit codes are the integration point — this is the simplest possible interface
- Thresholds should be configurable per-project (via CLI flags or config file)
- Must output violations even on pass (with `--json`) so agents can see what's close to the threshold

### 5. Focus — "Bracket a work session"

**What it does:** Captures a complexity snapshot before and after a coding session, producing a session report.

**CLI interface:**
```
churn_vs_complexity --focus-start .      # saves snapshot to .focus-baseline.json
# ... agent does work ...
churn_vs_complexity --focus-end .        # compares current state to baseline
churn_vs_complexity --focus-end --json . # structured output
```

**Example output (JSON):**
```json
{
  "session": {
    "started": "2026-02-18T10:00:00Z",
    "ended": "2026-02-18T10:45:00Z",
    "files_modified": 7
  },
  "impact": {
    "mean_gamma_before": 12.3,
    "mean_gamma_after": 13.1,
    "direction": "slight_degradation"
  },
  "files_touched": [
    {
      "file": "lib/new_feature.rb",
      "complexity_added": 15.2,
      "has_tests": false,
      "recommendation": "Add test coverage."
    }
  ]
}
```

**Why this matters:** Wraps an entire agent session with accountability. The human reviews the focus report to decide if the agent's output needs rigorous follow-up or is fine to ship. This is the feedback loop that makes "let agents run amok, then review" into a structured practice rather than wishful thinking.

**Agent integration:** A CLAUDE.md instruction or hook runs `--focus-start` at session begin and `--focus-end` at session close. The end report becomes part of the session output.

**UX considerations:**
- The baseline file (`.focus-baseline.json`) should be gitignored — it's ephemeral
- `--focus-end` should work even if `--focus-start` wasn't run (comparing against HEAD~N as fallback)
- The `has_tests` field requires heuristic detection (corresponding `_test.rb` / `_spec.rb` file exists)

## The Interpretive Layer

The deepest UX insight across all five workflows: **agents don't want data, they want decisions.**

The gamma score already exists in `SummaryHash` (lines 24-34). What's missing is the interpretive layer that turns `gamma_score: 63.2` into:
```json
{
  "risk": "high",
  "recommendation": "Write tests before modifying."
}
```

This interpretive layer is what makes output directly actionable. Without it, every agent must re-derive "what does this number mean?" from scratch, wasting tokens and introducing inconsistency. With it, the tool's output slots directly into an agent's decision tree.

### Default risk thresholds (configurable)

| Gamma Score | Risk Level | Recommendation |
|---|---|---|
| < 10 | Low | Safe for quick changes |
| 10 - 25 | Medium | Exercise judgement; consider tests for non-trivial changes |
| > 25 | High | Write tests before modifying; consider multi-agent review |

These defaults should be overridable via CLI flags or a `.churn_vs_complexity.yml` config file.

## Implementation Priority

1. **`--json` output** — enables everything else; touches serializer layer only
2. **Triage** — highest per-interaction value; answers the agent's immediate question
3. **Hotspot Map** — highest amortised value; one-time cost, ongoing benefit
4. **Gate** — simplest to implement; exit codes + threshold comparison
5. **Focus** — most ambitious; requires session state management
6. **Snapshot Diff** — lowest priority; mostly a convenience over existing Delta + Normal modes with `--json`

## Integration Patterns for Agents

### CLAUDE.md instruction (recommended starting point)
```markdown
Before modifying files with high churn and complexity, run:
  churn_vs_complexity --triage --json <files>
Files with risk "high" require tests before changes are made.
```

### Git pre-push hook
```bash
churn_vs_complexity --gate --max-gamma 30 . || echo "Quality gate failed"
```

### CI pipeline
```yaml
- name: Quality analysis
  run: churn_vs_complexity --hotspot-map --format markdown . > HOTSPOTS.md
```

### Session wrapper (hooks or scripted)
```bash
churn_vs_complexity --focus-start .
# ... agent session ...
churn_vs_complexity --focus-end --json .
```
