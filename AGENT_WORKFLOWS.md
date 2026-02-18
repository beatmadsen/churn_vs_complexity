# Agent Workflows for Balancing Rigor

Design document for new `churn_vs_complexity` workflows aimed at LLM coding agents.

## Problem

LLM-augmented coding involves a trade-off between speed and rigor. Single-agent "vibe coding" is fast and cheap. Multi-agent collaboration (mob programming, TDD, pair review) produces better code but costs 10x+ more in tokens.

You don't need rigor everywhere, all the time. The practical question is: **where should I invest?**

`churn_vs_complexity` already computes the data to answer this -- churn frequency, complexity scores, and the gamma score (harmonic mean of churn and complexity). What's missing is packaging that data into formats and workflows that agents can consume directly as part of their decision-making.

## Enabling Prerequisite: `--json` Output

Before any workflow below, the single highest-leverage change is adding `--json` as a first-class output format across all modes.

> **Design note -- `--json` vs `--format json`:** The existing CLI uses bare flags for serializer selection (`--csv`, `--graph`, `--summary`). New output formats should follow the same convention. `--json` is consistent with existing style, easier to type, and unambiguous. A `--format` meta-flag would be warranted if there were many formats or format-specific options, but for a single addition, the simpler pattern wins.

`Normal::Serializer::SummaryHash` already computes mean, median, min, max, and gamma scores. The `values_by_file` hash has per-file churn and complexity. This data just needs to be serializable as JSON instead of only feeding into human-readable text and HTML.

This is the unlock for all workflows below.

---

## CLI Design Conventions

> **Design note:** This section establishes the rules the proposed workflows follow. Documenting them explicitly makes the design reviewable and helps future contributors stay consistent.

The existing CLI has a clear pattern. New workflows should follow it:

| Concept | Convention | Examples |
|---|---|---|
| **Mode** | `--flag [VALUE]` sets `options[:mode]` | `--timetravel 30`, `--delta SHA` |
| **Language** | Bare flag | `--ruby`, `--java`, `--python` |
| **Output format** | Bare flag | `--csv`, `--graph`, `--summary`, `--json` (new) |
| **Target** | Positional argument (last) | `.`, `lib/`, `src/` |
| **Modifiers** | `--flag VALUE` | `--since 2025-01-01`, `--excluded vendor` |

**Rules for new workflows:**

1. **New workflows are modes**, selected by `--flag`, same as `--timetravel` and `--delta`. They set `options[:mode]`.
2. **Output format is always a separate flag** (`--json`, `--csv`, etc.), never bundled into a mode flag.
3. **The positional argument is always the target directory or file list**, always last.
4. **Default output format is human-readable text** (matching existing behavior). `--json` opts in to structured output.
5. **Workflows that accept file paths instead of a directory** take them as positional arguments after flags, just like a folder would be.

---

## Proposed Workflows

### 1. Triage -- "Should I be careful with these files?"

**What it does:** Given a list of files (or a directory), returns per-file risk assessment based on churn history and complexity.

**CLI interface:**
```
churn_vs_complexity --triage --ruby file1.rb file2.rb lib/
churn_vs_complexity --triage --ruby --json .
```

> **Design note -- naming:** `--triage` is strong. It's a real word developers use naturally ("let me triage these changes"), it implies urgency-based sorting, and it's short. Alternatives considered: `--assess`, `--risk` (too vague), `--analyze` (too generic, overlaps with what every mode does).

> **Design note -- file arguments:** Triage is the only workflow that takes individual file paths as positional arguments (in addition to directories). This matches the use case exactly: an agent knows which files it's about to touch and wants a risk check on those specific files. The parser should accept multiple positional args and treat any that are files as a file list, any that are directories as a directory to scan.

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
- The interpretive layer (risk levels + recommendations) is what makes this actionable -- raw numbers force agents to re-derive the interpretation every time
- Default (no `--json`) should output a compact human-readable table: `file | risk | gamma` -- scannable in a terminal

### 2. Hotspots -- "Where does this codebase hurt?"

**What it does:** Generates a ranked list of files by risk, suitable for embedding in project context (CLAUDE.md, `.hotspots.json`).

**CLI interface:**
```
churn_vs_complexity --hotspots --ruby .
churn_vs_complexity --hotspots --ruby --json .
churn_vs_complexity --hotspots --ruby --markdown .
```

> **Design note -- `--markdown`:** This is a new output format flag alongside `--json`, `--csv`, etc. Hotspots is the primary consumer, but `--markdown` could be useful for any mode. It follows the bare-flag convention for output formats.

**Example output (Markdown, for CLAUDE.md):**
```markdown
## Hotspots (generated 2026-02-18)

### High Risk -- require tests and careful review
- `lib/engine.rb` (gamma: 31.2, churn: 47, complexity: 23.4)
- `lib/traveller.rb` (gamma: 28.7, churn: 39, complexity: 21.1)

### Medium Risk -- exercise judgement
- `lib/cli/parser.rb` (gamma: 14.5, churn: 22, complexity: 11.3)

### Low Risk -- safe for quick changes
- `lib/version.rb` (gamma: 0.9, churn: 12, complexity: 1.0)
```

**Why this matters:** Runs once (in CI or manually), produces a snapshot that informs every subsequent agent session. Zero per-task cost -- the investment is amortised across all future work. Agents consulting CLAUDE.md at session start immediately know which areas demand care.

**Agent integration:** Generate periodically (CI pipeline, post-sprint). Include Markdown output in CLAUDE.md or a linked file. Every agent session starts informed without running any analysis.

**UX considerations:**
- Markdown format for CLAUDE.md inclusion; JSON format for programmatic consumption
- Should include a generation timestamp so staleness is visible
- Keep the output concise -- agents have limited context windows too

### 3. Gate -- "Pass/fail quality check"

> **Design note -- priority reordering:** Gate moved from position 4 to position 3. It is simpler than Snapshot Diff and Focus, and its implementation shares infrastructure with Triage (same Normal mode + threshold comparison). Building Gate right after Triage means the threshold/risk classification code gets exercised in two workflows immediately.

**What it does:** Binary pass/fail check against configurable thresholds. Returns exit code 0 (pass) or 1 (fail).

**CLI interface:**
```
churn_vs_complexity --gate --ruby .
churn_vs_complexity --gate --ruby --max-gamma 30 .
churn_vs_complexity --gate --ruby --max-gamma 30 --json .
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

**Why this matters:** Dead simple for CI and git hooks. No interpretation needed -- it's binary. Agents that trigger a failure know they need to circle back. This is the "guardrail" that prevents prototyping from going too far without manual oversight.

**Agent integration:** Add to pre-push hooks or CI. When the gate fails, the agent knows to apply rigorous workflows (refactoring, test writing) to the violating files before shipping.

**UX considerations:**
- Exit codes are the integration point -- this is the simplest possible interface
- Thresholds should be configurable per-project (via CLI flags or config file)
- Default `--max-gamma` should match the "high" threshold from the risk table (25) so Gate and Triage agree on what "high risk" means
- Must output violations even on pass (with `--json`) so agents can see what's close to the threshold
- Without `--json`, output should be a single line on pass (`PASS: no files exceed gamma 25`) and a violation list on fail

### 4. Focus -- "Bracket a work session"

> **Design note -- reordering:** Focus moved above Snapshot Diff. Focus has a clearer use case for agent session management and uses simple before/after comparison mechanics. Snapshot Diff has significant overlap with existing Delta mode and may not need to exist at all.

**What it does:** Captures a complexity snapshot before and after a coding session, producing a session report.

> **Design note -- subcommands vs compound flags:** The original design used `--focus-start` and `--focus-end` as two separate flags. These are better modeled as `--focus start` and `--focus end` (a mode flag with a required argument), which matches the pattern of `--timetravel N` and `--delta SHA`. The argument makes it clear that `start` and `end` are values of the same mode, not independent options. This also prevents the accidental `--focus-start --focus-end` invocation, which would be meaningless.

**CLI interface:**
```
churn_vs_complexity --focus start --ruby .      # saves snapshot to .focus-baseline.json
# ... agent does work ...
churn_vs_complexity --focus end --ruby .         # compares current state to baseline
churn_vs_complexity --focus end --ruby --json .  # structured output
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

**Agent integration:** A CLAUDE.md instruction or hook runs `--focus start` at session begin and `--focus end` at session close. The end report becomes part of the session output.

**UX considerations:**
- The baseline file (`.focus-baseline.json`) should be gitignored -- it's ephemeral
- `--focus end` should work even if `--focus start` wasn't run (comparing against HEAD~1 as fallback, with a warning: "No baseline found. Comparing against previous commit.")
- The `has_tests` field requires heuristic detection (corresponding `_test.rb` / `_spec.rb` file exists)

### 5. Snapshot Diff -- "Did I make things better or worse?"

> **Design note -- priority:** Moved to last position. The overlap with existing Delta mode is substantial, and `--focus end` covers the most common "before/after" use case. Keep this in the backlog and reconsider only if `--json` on Normal mode plus agent-side diffing proves insufficient.

> **Note: Overlap with existing Delta mode.** Delta already does per-commit analysis --
> it checks out specific commits via worktrees, finds changed files, and annotates each
> with complexity. Snapshot Diff would add an *aggregate* comparison layer on top (mean
> gamma before vs. after, per-file direction). This is a convenience wrapper -- you could
> approximate it today by running Normal mode at two refs and comparing results. Consider
> whether this justifies a new mode or is better served by adding `--json` to Normal mode
> and letting agents do the comparison themselves.

**What it does:** Compares aggregate codebase health metrics between two git refs, showing overall direction and per-file changes.

**CLI interface:**
```
churn_vs_complexity --diff HEAD~10 --ruby .
churn_vs_complexity --diff v1.0.0 --ruby .
churn_vs_complexity --diff HEAD~10 --ruby --json .
```

> **Design note -- renaming:** `--snapshot-diff` renamed to `--diff`. The word "snapshot" is implementation jargon (it describes *how* the tool works internally). The user thinks "what changed?" not "compare two snapshots." `--diff` is the word every developer reaches for. It is short, unambiguous, and matches git muscle memory. The argument is the reference point to compare against (current state is always implied as HEAD).

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

**Why this matters:** After a sprint of fast prototyping, this answers "what debt did we accumulate and where?" But the unique value over Delta + Normal is thin -- it's mainly the aggregate summary and the "direction" interpretation. May not be worth building as a separate mode.

**Agent integration:** Run after a batch of changes to evaluate whether a prototyping sprint created debt worth addressing.

**UX considerations:**
- The unique value is the aggregate "direction" interpretation -- if that's all that's needed, it might be a flag on Normal mode rather than a new mode
- Could be deferred until `--json` on Normal mode proves insufficient in practice

---

## The Interpretive Layer

The deepest UX insight across all workflows: **agents don't want data, they want decisions.**

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

These defaults should be overridable via CLI flags (`--risk-low 10`, `--risk-high 25`) or a `.churn_vs_complexity.yml` config file.

> **Design note -- threshold flags:** Named `--risk-low` and `--risk-high` rather than `--threshold-low` etc. The user thinks in terms of risk levels, not thresholds. Two flags set three boundaries: below low = "low", between low and high = "medium", above high = "high".

## Implementation Priority

1. **`--json` output** -- enables everything else; touches serializer layer only
2. **Triage** -- highest per-interaction value; answers the agent's immediate question
3. **Hotspots** -- highest amortised value; one-time cost, ongoing benefit
4. **Gate** -- simplest to implement; shares threshold logic with Triage
5. **Focus** -- most ambitious; requires session state management
6. **Snapshot Diff (`--diff`)** -- lowest priority; mostly a convenience over existing Delta + Normal modes with `--json`

## Integration Patterns for Agents

### CLAUDE.md instruction (recommended starting point)
```markdown
Before modifying files with high churn and complexity, run:
  churn_vs_complexity --triage --ruby --json <files>
Files with risk "high" require tests before changes are made.
```

### Git pre-push hook
```bash
churn_vs_complexity --gate --ruby --max-gamma 25 . || echo "Quality gate failed"
```

> **Design note:** Changed `--max-gamma 30` to `--max-gamma 25` to match the default "high" risk threshold. Gate and Triage should agree on where "high risk" starts, otherwise an agent can triage a file as "medium risk" but have Gate reject it (or vice versa). Using the same number (25) across both workflows prevents this confusion.

### CI pipeline
```yaml
- name: Quality analysis
  run: churn_vs_complexity --hotspots --ruby --markdown . > HOTSPOTS.md
```

### Session wrapper (hooks or scripted)
```bash
churn_vs_complexity --focus start --ruby .
# ... agent session ...
churn_vs_complexity --focus end --ruby --json .
```

---

## Summary of CLI Surface

> **Design note:** This reference table makes the full CLI surface scannable at a glance. Useful for spotting collisions and reviewing consistency.

| Mode Flag | Argument | Output Flags | Positional Args | Exit Code |
|---|---|---|---|---|
| *(none, Normal)* | -- | `--csv`, `--graph`, `--summary`, `--json` | `folder` | 0 |
| `--timetravel` | `N` (days) | `--csv`, `--summary`, `--json` | `folder` | 0 |
| `--delta` | `SHA` (repeatable) | `--json` | `folder` | 0 |
| `--triage` | -- | `--json` | `file...` or `folder` | 0 |
| `--hotspots` | -- | `--json`, `--markdown` | `folder` | 0 |
| `--gate` | -- | `--json` | `folder` | 0 (pass) / 1 (fail) |
| `--focus` | `start` or `end` | `--json` | `folder` | 0 |
| `--diff` | `REF` | `--json` | `folder` | 0 |

**Language flag (`--ruby`, `--java`, `--js`, `--python`, `--go`) is always required and is orthogonal to mode.**
