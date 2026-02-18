# Go Cyclomatic Complexity Tools: Analysis and Recommendation

Research conducted 2026-02-18 for integration into the `churn_vs_complexity` Ruby gem.

## Context

The `churn_vs_complexity` gem currently supports:
- **Ruby** via Flog (used as a Ruby library, returns `flog.total_score` per file)
- **JavaScript** via ESLint (shells out to a Node.js script, parses JSON output)
- **Java** via PMD (shells out to `pmd check`, parses JSON output)
- **Python** via Radon (shells out to `radon cc`, parses JSON output)

For Go support, we need a tool that can:
1. Accept one or more Go file paths as input
2. Return a **single numeric complexity score per file**
3. Be invoked from Ruby via shell command (like Radon/ESLint/PMD) or produce structured output
4. Be installable via `go install`

---

## Candidates Evaluated

### 1. gocyclo

| Attribute | Detail |
|---|---|
| **GitHub** | https://github.com/fzipp/gocyclo (~1.5k stars) |
| **Latest tag** | v0.6.0 (June 2022); latest commit Dec 2025 |
| **License** | BSD-3-Clause |
| **Go requirement** | Go 1.20+ (uses `go install`) |
| **Dependencies** | None (standard library only) |

**What it measures:** Cyclomatic complexity (McCabe number). Base complexity of 1 per function, +1 for each `if`, `for`, `case`, `&&`, or `||`.

**Installation:**
```bash
go install github.com/fzipp/gocyclo/cmd/gocyclo@latest
```

**CLI usage:**
```bash
# Analyze a single file
gocyclo main.go

# Analyze a directory recursively
gocyclo .

# Show top 10 most complex functions
gocyclo -top 10 src/

# Show only functions exceeding threshold (exits code 1 if any found)
gocyclo -over 15 .

# Show average complexity
gocyclo -avg .

# Ignore files matching regex
gocyclo -ignore "_test|vendor" .

# Average as bare number (no label)
gocyclo -avg-short .
```

**Output format** (plain text, one line per function):
```
<complexity> <package> <function> <file:line:column>
```

**Example output:**
```
9 server (*Handler).ServeHTTP server.go:30:1
5 server parseRequest server.go:88:1
3 main main main.go:12:1
1 main init main.go:8:1
Average: 4.50
```

**Strengths:**
- The most widely used Go complexity tool
- Actively maintained (commits in Dec 2025)
- Simple, focused, does one thing well
- Accepts individual files and directories
- Integrated with golangci-lint
- `//gocyclo:ignore` directive for suppressing individual functions
- Zero dependencies

**Weaknesses:**
- No JSON output -- plain text only, requires parsing
- No per-file aggregation; reports per-function only
- No `-avg` per file; average is computed across all functions in all input files
- Output format requires splitting on whitespace and extracting the filename from the position field

---

### 2. gocognit

| Attribute | Detail |
|---|---|
| **GitHub** | https://github.com/uudashr/gocognit (~440 stars) |
| **Latest release** | v1.2.0 (December 2024) |
| **License** | MIT |
| **Go requirement** | Go 1.21+ |
| **Dependencies** | `golang.org/x/tools` |

**What it measures:** Cognitive complexity (based on the Sonarsource cognitive complexity paper). Unlike cyclomatic complexity which counts paths, cognitive complexity measures how hard code is to understand by humans. It penalizes nesting (nested `if` inside a `for` scores higher than a flat sequence of `if` statements).

**Installation:**
```bash
go install github.com/uudashr/gocognit/cmd/gocognit@latest
```

**CLI usage:**
```bash
# Analyze a single file
gocognit main.go

# Show top 10 most complex functions
gocognit -top 10 src/

# Show only functions exceeding threshold
gocognit -over 15 .

# Show average complexity
gocognit -avg .

# JSON output
gocognit -json .

# JSON output with diagnostics (explains how complexity was calculated)
gocognit -json -d .

# Include/exclude test files
gocognit -test=false .

# Ignore files matching regex
gocognit -ignore "_test|vendor" .
```

**Plain text output format** (same layout as gocyclo):
```
<complexity> <package> <function> <file:line:column>
```

**JSON output format** (`gocognit -json main.go`):
```json
[
    {
        "PkgName": "main",
        "FuncName": "processItems",
        "Complexity": 12,
        "Pos": {
            "Filename": "main.go",
            "Offset": 45,
            "Line": 5,
            "Column": 1
        }
    },
    {
        "PkgName": "main",
        "FuncName": "helperFunc",
        "Complexity": 2,
        "Pos": {
            "Filename": "main.go",
            "Offset": 320,
            "Line": 30,
            "Column": 1
        }
    }
]
```

**JSON output with diagnostics** (`gocognit -json -d main.go`) adds a `Diagnostics` array to each entry explaining each complexity increment:
```json
[
    {
        "PkgName": "prime",
        "FuncName": "SumOfPrimes",
        "Complexity": 7,
        "Pos": {
            "Filename": "prime.go",
            "Offset": 15,
            "Line": 3,
            "Column": 1
        },
        "Diagnostics": [
            { "Inc": 1, "Text": "for", "Pos": { "Offset": 69, "Line": 7, "Column": 2 } },
            { "Inc": 2, "Nesting": 1, "Text": "for", "Pos": { "Offset": 104, "Line": 8, "Column": 3 } },
            { "Inc": 3, "Nesting": 2, "Text": "if", "Pos": { "Offset": 152, "Line": 9, "Column": 4 } },
            { "Inc": 1, "Text": "continue", "Pos": { "Offset": 190, "Line": 10, "Column": 5 } }
        ]
    }
]
```

Note: Without `-d`, the `Diagnostics` field is omitted from JSON output (uses `json:",omitempty"`).

**Strengths:**
- **Native JSON output via `-json` flag** -- ideal for machine consumption from Ruby
- Actively maintained (v1.2.0, December 2024)
- Cognitive complexity better reflects code understandability than pure cyclomatic complexity
- Per-function granularity with file path in each entry's `Pos.Filename`
- `//gocognit:ignore` directive for suppressing individual functions
- Integrated with golangci-lint
- MIT license
- Diagnostic mode explains every complexity increment (useful for debugging)

**Weaknesses:**
- Fewer stars/community adoption than gocyclo (~440 vs ~1500)
- Measures cognitive complexity, not cyclomatic -- different metric than what gocyclo reports
- Depends on `golang.org/x/tools` (not an issue for CLI usage, only for library embedding)
- JSON output is a flat array, not keyed by filename -- requires grouping in the consumer

---

### 3. go-complexity-analysis

| Attribute | Detail |
|---|---|
| **GitHub** | https://github.com/shoooooman/go-complexity-analysis (~25 stars) |
| **Latest release** | None published |
| **License** | Not specified in repository |
| **Go requirement** | Uses `go vet` framework |
| **Dependencies** | `golang.org/x/tools` |

**What it measures:** Cyclomatic complexity, Halstead complexity, and Maintainability Index. The Maintainability Index uses the Microsoft formula: `MAX(0, (171 - 5.2 * ln(HV) - 0.23 * CC - 16.2 * ln(LOC)) * 100 / 171)`.

**Installation:**
```bash
go install github.com/shoooooman/go-complexity-analysis/cmd/complexity@latest
```

**CLI usage** (runs via `go vet`):
```bash
# Flag functions with cyclomatic complexity > 10
go vet -vettool=$(which complexity) --cycloover 10 ./...

# Flag functions with maintainability index < 20
go vet -vettool=$(which complexity) --maintunder 20 main.go

# Both thresholds
go vet -vettool=$(which complexity) --cycloover 5 --maintunder 30 ./src
```

**Output format** (plain text, `go vet` style):
```
main.go:12:1: func processItems seems to be complex (cyclomatic complexity=15)
main.go:45:1: func helperFunc seems to have low maintainability (maintainability index=18)
```

**Strengths:**
- Multi-metric: cyclomatic, Halstead, and Maintainability Index
- GitHub Actions integration via reviewdog

**Weaknesses:**
- **Threshold-based only** -- only reports functions exceeding a threshold, not all scores
- No JSON or structured output
- Requires `go vet` framework, cannot analyze standalone files easily
- Requires a valid Go module context to run (`go vet` needs `go.mod`)
- Very small community (25 stars), no published releases
- No specified license
- Not suitable for "how complex is this?" -- only answers "is this too complex?"

---

### 4. ichiban/cyclomatic

| Attribute | Detail |
|---|---|
| **GitHub** | https://github.com/ichiban/cyclomatic |
| **License** | MIT |

**What it measures:** Cyclomatic complexity.

**CLI usage:**
```bash
cyclomatic -limit 15 ./...
```

**Strengths:**
- Integrates with Go's `analysis.Pass` framework

**Weaknesses:**
- Threshold-based only (reports violations, not all scores)
- Requires Go module context
- Very small community
- No structured output
- Not suitable for our use case

---

## Comparison Summary

| Feature | gocyclo | gocognit | go-complexity-analysis | ichiban/cyclomatic |
|---|---|---|---|---|
| **JSON output** | No | Yes (`-json`) | No | No |
| **Per-file score** | No (per-function, sum manually) | No (per-function, sum from JSON) | No | No |
| **Standalone file analysis** | Yes | Yes | Needs `go vet`/module | Needs module |
| **Reports all functions** | Yes | Yes | Only over threshold | Only over threshold |
| **Metric type** | Cyclomatic | Cognitive | Cyclomatic + Halstead + MI | Cyclomatic |
| **Actively maintained** | Yes (Dec 2025) | Yes (Dec 2024) | Low activity | Low activity |
| **Dependencies** | None | `x/tools` | `x/tools` | `x/tools` |
| **License** | BSD-3-Clause | MIT | Unspecified | MIT |
| **Community** | ~1500 stars | ~440 stars | ~25 stars | Small |
| **Ease of parsing** | Moderate (text) | Easy (native JSON) | Hard (threshold text) | Hard |

---

## Recommendation: gocognit

**gocognit is the best choice** for integration into the `churn_vs_complexity` gem. Here is why:

### 1. Native JSON output makes integration trivial

The `-json` flag produces a well-structured JSON array where each entry contains `PkgName`, `FuncName`, `Complexity`, and `Pos` (including `Filename`). This is directly analogous to how the gem already parses Radon's JSON output. No fragile text parsing required.

Without JSON, gocyclo's text output (`9 server (*Handler).ServeHTTP server.go:30:1`) would require splitting on whitespace, handling function names with special characters (methods have `(*Type).Method` format), and extracting filenames from the position field -- all fragile.

### 2. Clean path to a single numeric score per file

While gocognit reports per-function complexity, deriving a per-file score is straightforward from the JSON:

- Parse JSON array
- Group entries by `Pos.Filename`
- **Sum** all function complexities per file (analogous to Flog's `total_score` and the Radon integration)

### 3. Cognitive complexity is a better metric for code quality analysis

Cognitive complexity (what gocognit measures) better reflects human perception of code difficulty than cyclomatic complexity. For example:

- A `switch` with 10 flat cases: cyclomatic = 11, cognitive = 1 (easy to read)
- Three nested `if` statements: cyclomatic = 4, cognitive = 6 (hard to read)

This makes cognitive complexity more meaningful when correlating with churn -- files that are hard to understand are more likely to be changed frequently.

### 4. Actively maintained with proper releases

gocognit has tagged releases (v1.2.0, December 2024), proper semantic versioning, and recent development activity. The `-json` flag was thoughtfully designed with `omitempty` for optional diagnostics.

### 5. Accepts individual files

Unlike `go-complexity-analysis` and `ichiban/cyclomatic` which require a Go module context and `go vet`, gocognit works directly on individual `.go` files -- essential for the gem's use case where it analyzes specific changed files.

### 6. MIT license

Compatible with any gem license.

---

## Integration Plan

### Installation

```bash
go install github.com/uudashr/gocognit/cmd/gocognit@latest
```

Users need Go installed and `$GOPATH/bin` (or `$HOME/go/bin`) in their `PATH`.

### CLI usage for the gem (shell out from Ruby)

To get complexity scores for Go files, the gem should:

```bash
# Analyze specific files, get JSON output
gocognit -json path/to/file1.go path/to/file2.go
```

Then parse the JSON and sum the complexity values per file:

```ruby
# Proposed Ruby integration (following the PythonCalculator pattern)
module ChurnVsComplexity
  module Complexity
    module GoCalculator
      class << self
        def folder_based? = false

        def calculate(files:)
          json_output = run_gocognit(files)
          parse_gocognit_output(json_output, files:)
        end

        def parse_gocognit_output(json_output, files:)
          stats = JSON.parse(json_output)
          # Group by filename and sum complexity per file
          scores = stats.group_by { |s| s.dig('Pos', 'Filename') }
                        .transform_values { |funcs| funcs.sum { |f| f['Complexity'] } }

          files.to_h do |file|
            [file, scores[file] || 0]
          end
        end

        def check_dependencies!
          `gocognit -h 2>&1`
        rescue Errno::ENOENT
          raise Error, 'Needs gocognit installed (go install github.com/uudashr/gocognit/cmd/gocognit@latest)'
        end

        private

        def run_gocognit(files)
          files_arg = files.map { |f| "'#{f}'" }.join(' ')
          `gocognit -json #{files_arg}`
        end
      end
    end
  end
end
```

### Handling file path matching

One subtlety: gocognit's JSON output uses `Pos.Filename` which reflects the path as passed to the tool. If we pass absolute paths, we get absolute paths back. If we pass relative paths, we get relative paths. The gem should ensure consistency by passing the same path format it uses internally.

### Batch mode

Unlike Radon (which returns a dict keyed by filename), gocognit returns a flat array. Multiple files can be passed in one invocation:

```bash
gocognit -json file1.go file2.go file3.go
```

This returns a single JSON array containing entries from all files. The `Pos.Filename` field identifies which file each function belongs to.

### Edge cases

- **Files with no functions:** gocognit outputs an empty array `[]`. The gem should return complexity 0 for such files.
- **Build errors:** gocognit may fail to parse files with syntax errors. The gem should handle non-zero exit codes gracefully.
- **Generated files:** Go codebases often contain generated files (protobuf, etc.). The gem's existing file selection mechanism should handle exclusion, but `gocognit -ignore` is also available.

### Verifying it works

```bash
# Install
go install github.com/uudashr/gocognit/cmd/gocognit@latest

# Create a test file
cat > /tmp/test.go << 'EOF'
package main

func simple() int {
    return 42
}

func complex(x int) string {
    if x > 0 {
        for i := 0; i < x; i++ {
            if i%2 == 0 {
                if i > 10 {
                    return "big even"
                }
            }
        }
        return "positive"
    }
    return "negative"
}
EOF

# Get JSON complexity
gocognit -json /tmp/test.go

# Expected output (approximately):
# [
#     {
#         "PkgName": "main",
#         "FuncName": "simple",
#         "Complexity": 0,
#         "Pos": {
#             "Filename": "/tmp/test.go",
#             "Offset": 14,
#             "Line": 3,
#             "Column": 1
#         }
#     },
#     {
#         "PkgName": "main",
#         "FuncName": "complex",
#         "Complexity": 9,
#         "Pos": {
#             "Filename": "/tmp/test.go",
#             "Offset": 52,
#             "Line": 7,
#             "Column": 1
#         }
#     }
# ]
# Total file complexity: 9 (sum of 0 + 9)
```

---

## Why Not gocyclo?

gocyclo is the most popular Go complexity tool and would be a reasonable second choice. Its main disadvantages for this use case:

1. **No JSON output.** The plain text format (`9 server (*Handler).ServeHTTP server.go:30:1`) requires fragile text parsing. Method names can contain parentheses and asterisks (e.g., `(*Type).Method`), making regex-based parsing error-prone.
2. **Cyclomatic complexity is less meaningful for quality analysis.** Cyclomatic complexity counts paths, not understandability. A long `switch` statement with simple cases gets a high cyclomatic score despite being easy to read. Cognitive complexity (what gocognit measures) better captures the kind of complexity that correlates with bugs and churn.
3. **No `-avg-short` per file.** The `-avg-short` flag computes an average across all functions in all input -- it cannot produce per-file averages.

If gocognit's JSON output proves problematic in practice, gocyclo's text output could be parsed with:
```ruby
# Fallback: parsing gocyclo text output
output = `gocyclo #{files_arg}`
scores = Hash.new(0)
output.each_line do |line|
  parts = line.strip.split(/\s+/)
  complexity = parts[0].to_i
  # Position is the last field: "file.go:line:col"
  pos = parts.last
  filename = pos.split(':').first
  scores[filename] += complexity
end
```

## Why Not go-complexity-analysis?

go-complexity-analysis is not suitable for this use case:

1. **Threshold-based only.** It only reports functions exceeding a threshold; it cannot enumerate all function complexities. This is the same fundamental problem as `mccabe` for Python -- it answers "is this too complex?" rather than "how complex is this?"
2. **Requires `go vet` and a Go module context.** The tool cannot analyze standalone files without a `go.mod` file, making it unsuitable for analyzing individual files in a git worktree.
3. **No structured output.** Only produces `go vet`-style text diagnostics.
4. **No license specified.** This is a risk for inclusion in a published gem.
5. **Very small community.** Only ~25 stars, no published releases.

## Why Not ichiban/cyclomatic?

ichiban/cyclomatic shares the same fundamental problems as go-complexity-analysis: threshold-based reporting only, requires Go module context, no structured output. It is designed for use within Go's analysis framework, not as a standalone reporting tool.
