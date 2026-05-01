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

- **Documentation**: See [references/vault-model.md](references/vault-model.md)
- **Prompt usage**: See [references/prompt-usage.md](references/prompt-usage.md)
- **Obsidian writing**: See [../../guides/GUIDE-obsidian-writing.md](../../guides/GUIDE-obsidian-writing.md)
