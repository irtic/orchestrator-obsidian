# GUIDE - Naming Conventions

## Principios
1. Los nombres deben ser estables.
2. Los IDs deben ser explícitos.
3. El nombre debe indicar tipo de entidad.
4. Evitar nombres ambiguos o demasiado narrativos.
5. El mismo concepto debe conservar el mismo nombre en todo el vault.

## Prefijos permitidos
| Entidad | Prefijo | Ejemplo |
|---|---|---|
| System | `SYS-` | `SYS-auth-platform` |
| Workstream | `WS-` | `WS-api-core` |
| Change | `CHG-` | `CHG-025-refresh-token` |
| ADR | `ADR-` | `ADR-010-session-strategy` |
| API Contract | `API-` | `API-auth-refresh` |
| DTO | `DTO-` | `DTO-session-state` |
| Event | `EVT-` | `EVT-user-authenticated` |
| Guide | `GUIDE-` | `GUIDE-change-lifecycle` |
| Session Log | `SES-` | `SES-2026-04-30-WS-api-core` |

## Regla de slug
- minúsculas
- guiones medios
- sin espacios
- sin sufijos raros como `-final` o `-v2`
