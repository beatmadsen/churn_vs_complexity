# Python Cyclomatic Complexity Tools: Analysis and Recommendation

Research conducted 2026-02-18 for integration into the `churn_vs_complexity` Ruby gem.

## Context

The `churn_vs_complexity` gem currently supports:
- **Ruby** via Flog (used as a Ruby library, returns `flog.total_score` per file)
- **JavaScript** via ESLint (shells out to a Node.js script, parses JSON output)
- **Java** via PMD (shells out to `pmd check`, parses JSON output)

For Python support, we need a tool that can:
1. Accept one or more Python file paths as input
2. Return a **single numeric complexity score per file**
3. Be invoked from Ruby via shell command (like ESLint/PMD) or produce structured output
4. Be installable via `pip`

---

## Candidates Evaluated

### 1. Radon

| Attribute | Detail |
|---|---|
| **PyPI** | https://pypi.org/project/radon/ |
| **GitHub** | https://github.com/rubik/radon (1.9k stars) |
| **Latest version** | 6.0.1 (March 2023) |
| **License** | MIT |
| **Python requirement** | 2.7, 3.6-3.12, PyPy |
| **Dependencies** | `mando`, `colorama` (optional) |

**What it measures:** Cyclomatic complexity (McCabe number), Halstead metrics, Maintainability Index, raw metrics (SLOC, comments, etc.).

**CLI usage:**
```bash
# Per-function complexity with scores shown
radon cc myfile.py -s

# JSON output (key feature for integration)
radon cc myfile.py -j

# JSON with average complexity
radon cc myfile.py -j -a -s

# Analyze multiple files
radon cc file1.py file2.py -j
```

**JSON output format** (`radon cc myfile.py -j`):
```json
{
  "myfile.py": [
    {
      "type": "function",
      "rank": "A",
      "lineno": 1,
      "col_offset": 0,
      "endline": 10,
      "name": "my_function",
      "complexity": 3,
      "closures": []
    }
  ]
}
```

**Programmatic API:**
```python
from radon.complexity import cc_visit, cc_rank

results = cc_visit(open("myfile.py").read())
# Each result has .name, .complexity, .lineno, .classname
total = sum(block.complexity for block in results)
average = total / len(results) if results else 0
```

**Strengths:**
- Native JSON output via `-j` flag -- ideal for machine consumption
- Rich programmatic API
- Per-function granularity with easy aggregation
- Well-documented
- Most widely used Python complexity tool (Codacy, CodeFactor use it)
- Supports Maintainability Index as an alternative single-score metric

**Weaknesses:**
- Last release was March 2023 (nearly 3 years ago, though the tool is mature/stable)
- No built-in single-number-per-file output; requires summing or averaging function scores
- Python-only (not multi-language)

---

### 2. Lizard

| Attribute | Detail |
|---|---|
| **PyPI** | https://pypi.org/project/lizard/ |
| **GitHub** | https://github.com/terryyin/lizard (2.3k stars) |
| **Latest version** | ~1.17.x / 1.20.0 (Feb 2026) |
| **License** | MIT |
| **Python requirement** | >=3.8 |
| **Dependencies** | None (standalone) |

**What it measures:** Cyclomatic Complexity Number (CCN), NLOC, token count, parameter count per function.

**CLI usage:**
```bash
# Default tabular output (includes per-file summary)
lizard myfile.py

# CSV output
lizard myfile.py --csv

# XML output (cppncss style, for Jenkins)
lizard myfile.py -X

# Set CCN warning threshold
lizard myfile.py -C 10
```

**Default output format** (tabular, includes file summary):
```
  NLOC  CCN  token  PARAM  length  location
------------------------------------------------
     5    2     30      1       5 my_function@1-5@myfile.py
1 file analyzed.
==============================================================
NLOC  Avg.NLOC  AvgCCN  Avg.token  function_cnt    file
--------------------------------------------------------------
    5       5.0     2.0       30.0             1    myfile.py
```

**Programmatic API:**
```python
import lizard

result = lizard.analyze_file("myfile.py")
# result.filename, result.nloc, result.function_list
for func in result.function_list:
    print(func.name, func.cyclomatic_complexity)

# Get average CCN for the file
avg_ccn = sum(f.cyclomatic_complexity for f in result.function_list) / len(result.function_list)
```

**Strengths:**
- Actively maintained (release Feb 2026)
- Zero dependencies
- Multi-language support (C/C++, Java, JavaScript, Python, Ruby, etc.)
- CSV output is easy to parse
- Fastest of the three tools
- Per-file summary line in default output already includes AvgCCN

**Weaknesses:**
- No native JSON output (CSV, XML, HTML only)
- CSV/tabular output requires more parsing work than JSON
- The file summary AvgCCN is in the tabular footer, not trivially machine-readable
- Less established in the Python-specific ecosystem than Radon

---

### 3. mccabe

| Attribute | Detail |
|---|---|
| **PyPI** | https://pypi.org/project/mccabe/ |
| **GitHub** | https://github.com/PyCQA/mccabe |
| **Latest version** | 0.7.0 (January 2022) |
| **License** | MIT (Expat) |
| **Python requirement** | >=3.6 |
| **Dependencies** | None |

**What it measures:** McCabe cyclomatic complexity only.

**CLI usage:**
```bash
# Reports functions exceeding threshold (default output)
python -m mccabe --min 5 myfile.py
# Output: ("1:1: 'my_function'", 12)

# Via flake8
flake8 --max-complexity=10 myfile.py
# Output: myfile.py:1:1: C901 'my_function' is too complex (12)
```

**Programmatic API:**
```python
import ast
import mccabe

code = open("myfile.py").read()
tree = compile(code, "myfile.py", "exec", ast.PyCF_ONLY_AST)
visitor = mccabe.PathGraphingAstVisitor()
visitor.preorder(tree, visitor)
for graph in visitor.graphs.values():
    print(graph.entity, graph.complexity())
```

**Strengths:**
- Lightweight, zero dependencies
- Maintained by PyCQA (official Python code quality authority)
- Integrated with flake8 ecosystem

**Weaknesses:**
- No JSON/structured output -- text only, requires regex parsing
- Designed as a flake8 plugin, not a standalone reporting tool
- `get_code_complexity` prints to stdout and returns only count of violations (awkward API)
- Last release Jan 2022 (4+ years ago)
- No per-file aggregation; only reports individual functions exceeding threshold
- Threshold-based design: it only reports functions *above* a threshold, not all scores

---

## Comparison Summary

| Feature | Radon | Lizard | mccabe |
|---|---|---|---|
| **JSON output** | Yes (`-j`) | No (CSV/XML only) | No |
| **Per-file score** | Via `-a` (average) or sum from JSON | AvgCCN in tabular output | No |
| **Programmatic API** | Excellent | Good | Poor (prints to stdout) |
| **Actively maintained** | Moderate (2023) | Yes (Feb 2026) | Low (2022) |
| **Dependencies** | `mando` | None | None |
| **License** | MIT | MIT | MIT |
| **Multi-language** | No | Yes | No |
| **Ease of parsing** | Easy (native JSON) | Moderate (CSV) | Hard (text) |

---

## Recommendation: Radon

**Radon is the best choice** for integration into the `churn_vs_complexity` gem. Here is why:

### 1. Native JSON output makes integration trivial

The `-j` flag produces well-structured JSON that maps filenames to arrays of complexity blocks. This is directly analogous to how the gem already parses PMD's JSON output and ESLint's JSON output. No fragile text parsing required.

### 2. Clean path to a single numeric score per file

While Radon reports per-function complexity, deriving a per-file score is straightforward:

- **Sum** all function complexities (analogous to Flog's `total_score`)
- **Average** them (Radon supports `--total-average` natively)

The JSON output gives us full control over the aggregation strategy.

### 3. Mature and stable

The lack of recent releases is not a concern -- Radon is a mature tool that does one thing well. Python's AST (which Radon uses internally) changes slowly. The tool works with Python 3.6 through 3.12+.

### 4. Widely adopted

Used by Codacy, CodeFactor, and many CI/CD pipelines. Well-documented with readthedocs site.

### 5. MIT license

Compatible with any gem license.

---

## Integration Plan

### Installation

```bash
pip install radon
```

### CLI usage for the gem (shell out from Ruby)

To get a single numeric complexity score per file, the gem should:

```bash
# Get JSON complexity data for a single file
radon cc path/to/file.py -j -s
```

Then parse the JSON and sum the complexity values:

```ruby
# Proposed Ruby integration (similar to ESLintCalculator pattern)
module ChurnVsComplexity
  module Complexity
    module RadonCalculator
      class << self
        def folder_based? = false

        def calculate(files:)
          files.to_h do |file|
            json_output = `radon cc #{file} -j`
            data = JSON.parse(json_output)
            blocks = data[file] || []
            total_complexity = blocks.sum { |b| b['complexity'] }
            [file, total_complexity]
          end
        end

        def check_dependencies!
          `radon --version`
        rescue Errno::ENOENT
          raise Error, 'Needs radon installed (pip install radon)'
        end
      end
    end
  end
end
```

### Batch mode (more efficient)

For analyzing many files at once, pass them all to a single radon invocation:

```bash
radon cc file1.py file2.py file3.py -j
```

This returns a JSON object keyed by filename, so one shell invocation covers all files:

```ruby
def calculate(files:)
  files_arg = files.map { |f| "'#{f}'" }.join(' ')
  json_output = `radon cc #{files_arg} -j`
  data = JSON.parse(json_output)

  files.to_h do |file|
    blocks = data[file] || []
    total_complexity = blocks.sum { |b| b['complexity'] }
    [file, total_complexity]
  end
end
```

### Alternative: use average complexity instead of sum

If average complexity per function is preferred over total file complexity:

```ruby
blocks = data[file] || []
avg = blocks.empty? ? 0 : blocks.sum { |b| b['complexity'] }.to_f / blocks.size
[file, avg]
```

### Verifying it works

```bash
# Install
pip install radon

# Test on any Python file
echo 'def foo(x):
    if x > 0:
        if x > 10:
            return "big"
        return "small"
    return "negative"

def bar():
    return 42
' > /tmp/test.py

# Get JSON complexity
radon cc /tmp/test.py -j

# Expected output (approximately):
# {"/tmp/test.py": [
#   {"type": "function", "rank": "A", "name": "foo", "complexity": 3, ...},
#   {"type": "function", "rank": "A", "name": "bar", "complexity": 1, ...}
# ]}
# Total file complexity: 4 (sum of 3 + 1)
```

---

## Why Not Lizard?

Lizard is an excellent tool and would be a reasonable second choice. Its main disadvantages for this use case:

1. **No JSON output.** CSV parsing is more fragile and the tabular summary format requires custom parsing of the footer section.
2. **Multi-language support is wasted.** We only need Python analysis, and the gem already handles other languages with dedicated tools (Flog for Ruby, ESLint for JS, PMD for Java).
3. **The programmatic API is Python-only.** Since we are shelling out from Ruby, we need clean CLI output -- and Radon's JSON wins here.

If Radon were abandoned or had compatibility issues, Lizard would be the fallback. Its CSV output could be parsed with:
```bash
lizard myfile.py --csv
```

## Why Not mccabe?

mccabe is not suitable for this use case:

1. **No structured output.** Only prints text to stdout in a format that requires regex parsing.
2. **Threshold-based design.** Only reports functions exceeding a threshold; cannot enumerate all function complexities.
3. **No per-file aggregation.** Would require significant wrapper code.
4. **Awkward programmatic API.** `get_code_complexity` prints to stdout as a side effect.

mccabe is designed as a linter plugin (flake8), not a reporting tool. It answers "is this too complex?" rather than "how complex is this?", which is the wrong question for our use case.
