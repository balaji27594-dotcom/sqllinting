# SQLFluff Configuration Guide

This document explains the `.sqlfluff` configuration file used in this project.

## File Location
- **File**: `.sqlfluff` (in repository root)
- **Purpose**: Customizes sqlfluff linting rules and behavior

## Global Settings

```ini
dialect = oracle              # Use Oracle SQL dialect
max_line_length = 100         # Maximum line length (100 characters)
indent_unit = space           # Use spaces for indentation
indent_size = 4               # 4 spaces per indentation level
```

## Rule Categories

### 1. Core Formatting Rules (L001-L008)
These rules handle basic code formatting and are **AUTO FIXABLE**:
- **L001**: Incorrect indentation
- **L002**: Missing whitespace between tokens
- **L003**: Unnecessary whitespace
- **L004**: Indentation type (tabs vs spaces)
- **L005**: Indentation size
- **L006**: Operators need spaces
- **L007**: Operators shouldn't have spaces
- **L008**: Comparison operator spacing

### 2. Case and Naming Rules (L010-L025)
These rules enforce consistent naming conventions and are **AUTO FIXABLE**:
- **L010**: Keywords should be UPPERCASE
- **L011**: Aliases should be UPPERCASE
- **L012**: Type keywords should be UPPERCASE
- **L013**: Column references should be lowercase
- **L014**: Unquoted identifiers should be lowercase
- **L015**: DISTINCT should be UPPERCASE
- **L016**: EXCEPT should be UPPERCASE
- **L017**: Keywords should be UPPERCASE
- **L018**: Long lines (max 100 characters)
- **L019**: Whitespace after commas
- **L020**: Functions should be lowercase
- **L021**: Functions should be UPPERCASE (disabled to avoid conflicts)
- **L022-L025**: Additional whitespace and formatting rules

### 3. Semantic and Logic Rules (L026-L060)
These rules detect logical issues and are **NOT AUTO FIXABLE** (warnings only):
- **L026**: Undefined aliases
- **L027**: Undefined columns
- **L028**: Undefined table references
- **L029**: Unused SELECT clauses
- **L030**: Missing WHERE clause
- **L031**: Unused USING clause
- **L032**: Implicit casts
- **L033**: Bare functions
- **L034**: Ordering by column position
- **L035**: Unused SELECT elements
- **L036**: NULL comparisons (should use IS NULL)
- **L037**: ORDER BY items must be in SELECT
- **L038**: Inconsistent column naming
- **L039**: Unnecessary CAST
- **L040**: Inconsistent NULL style
- **L041**: Inconsistent naming style
- **L042**: Logical operator spacing
- **L043**: Comma whitespace
- **L044**: AND/OR inconsistency
- **L045**: Complex JOIN conditions
- **L046**: Ambiguous column references
- **L047**: Column naming inconsistency
- **L048**: Unnecessary explicit cast
- **L049**: Missing parentheses
- **L050**: Function definition whitespace
- **L051**: Leading/trailing whitespace
- **L052**: Parentheses inconsistency
- **L053**: Schema reference inconsistency
- **L054**: Excessive CTEs (max 3 by default)
- **L055**: CREATE INDEX style
- **L056**: Invalid escape sequences
- **L057**: Syntax inconsistency
- **L058**: Unnecessary semicolons
- **L059**: Jinja templating inconsistency
- **L060**: SQL dialect inconsistency

## Key Customizations

### 1. Disabled Rules
- **L009**: Disabled (conflicts with other naming rules)
- **L021**: Disabled (conflicts with L020 - functions lowercase)

### 2. Important Rule Configurations

#### L018 - Long Lines
```ini
max_line_length = 100
ignore_comment_lines = true
```
- Maximum line length: 100 characters
- Ignores comment lines when checking length

#### L054 - Excessive CTEs
```ini
max_cte_count = 3
```
- Warns if query has more than 3 CTEs
- Encourages breaking complex queries into simpler parts

#### L010 - Keywords Case
```ini
capitalisation_policy = upper
```
- All SQL keywords must be UPPERCASE
- Examples: SELECT, FROM, WHERE, JOIN

#### L013, L014, L047 - Column References
```ini
capitalisation_policy = lower
```
- Column names and unquoted identifiers should be lowercase
- Examples: employee_id, first_name, salary

#### L040 - NULL Style
```ini
null_style = lower
```
- Use lowercase for NULL: `IS NULL` instead of `IS null`

#### L019 - Trailing Commas
```ini
select_clause_trailing_comma = forbid
```
- No trailing commas in SELECT clauses

## How to Customize

### Enable a Disabled Rule
```ini
[sqlfluff:rules]
L021 = enable
```

### Disable an Enabled Rule
```ini
[sqlfluff:rules]
L030 = disable
```

### Adjust a Rule Parameter
```ini
[sqlfluff:rules:L054]
max_cte_count = 5  # Allow up to 5 CTEs instead of 3
```

### Change Global Settings
```ini
[sqlfluff]
max_line_length = 120  # Increase from 100 to 120
indent_size = 2        # Change from 4 to 2 spaces
```

## Integration with GitHub Actions

The workflow uses this configuration automatically:
```bash
sqlfluff fix --dialect oracle <files>
sqlfluff lint --dialect oracle <files>
```

Both commands read and apply the `.sqlfluff` configuration.

## Testing Configuration Locally

### Lint a file with configuration
```bash
sqlfluff lint --dialect oracle samples/07_queries.sql
```

### Auto-fix a file with configuration
```bash
sqlfluff fix --dialect oracle samples/07_queries.sql
```

### Check which rules are being applied
```bash
sqlfluff rules
```

## Rule Fixability Summary

| Type | Count | Auto-Fixed | Manual Review |
|------|-------|-----------|---------------|
| Formatting (L001-L008) | 8 | ✅ | - |
| Case/Naming (L010-L025) | 16 | ✅ | - |
| Semantic (L026-L060) | 35 | - | ✅ |
| **Excluded** | 1 | - | - |
| **TOTAL** | 59 | 24 | 35 |

## Next Steps

1. Commit this configuration to version control
2. The GitHub Actions workflow will automatically use it
3. Monitor PR comments for violations
4. Adjust rules as needed based on team feedback

For more information, visit: https://docs.sqlfluff.com/
