---
name: workstream-coordinator
description: >
  Coordinate cross-repository work through a versioned documentation vault based
  on systems, changes, and workstreams. Trigger: when creating a cross-repo
  change, preparing a handoff for a repository, registering a new execution
  unit, validating vault structure, or consolidating progress across multiple
  workstreams.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

Use this skill when:
- work affects multiple repositories or execution units
- a change must be coordinated through a vault
- a new repository must be integrated as a reusable workstream
- sessions need a strict handoff protocol
- cross-workstream progress must be consolidated

## Critical Patterns

- Model execution around `WS-*` workstreams, not frontend/backend/bff
- Sessions may update only their authorized `CHG-*.WS-*.md` note
- Change master, ADRs, contracts, systems, guides, and templates are protected
- Missing info -> `Pendiente`
- Non-applicable section -> `No aplica`
- When editing vault notes, use Obsidian-compatible Markdown with wikilinks for internal references
- Do not let richer Obsidian syntax break templates, ownership, or allowed edit scopes
- Act as a conversational facade first, and as a command router second
- Infer `change`, `workstream`, `mode`, and validation scope before asking questions
- Ask only when ambiguity is real or a write action would be unsafe
- Always return a clear next recommended step

## Conversational Contract

The agent should tolerate human inputs such as:

```text
CHG-031
status silent-session-renewal
open CHG-031 validation
close CHG-031 parcial "Resumen técnico breve"
check web-app
sync silent-session-renewal
```

Expected behavior:
- resolve partial references when they are unique
- normalize human modes and states into valid vault values
- preserve vault safety rules even when the user speaks loosely

## Commands

```bash
/ws-register
/chg-new
/handoff-open
/handoff-close
/chg-consolidate
/vault-validate
```

## Resources

- **Agent prompt**: See [assets/agent-system-prompt.md](assets/agent-system-prompt.md)
- **Documentation**: See [references/vault-model.md](references/vault-model.md)
- **Prompt usage**: See [references/prompt-usage.md](references/prompt-usage.md)
- **Obsidian writing**: See [../../guides/GUIDE-obsidian-writing.md](../../guides/GUIDE-obsidian-writing.md)
- **Agent contract**: See [../../guides/GUIDE-coordinator-agent.md](../../guides/GUIDE-coordinator-agent.md)
