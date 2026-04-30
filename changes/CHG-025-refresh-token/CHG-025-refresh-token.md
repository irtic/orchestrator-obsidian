# CHG-025 - Refresh Token

## Control
> OWNER: architect
> MODE: protected

## Objetivo
Implementar refresh token.

## Motivación
Evitar relogin frecuente.

## Alcance
- endpoint refresh
- continuidad de sesión

## No alcance
- SSO
- OAuth externo

## Sistema
- [[SYS-auth-platform]]

## Referencias
### Contratos
- [[API-auth-refresh]]

### ADRs
- [[ADR-010-session-strategy]]

## Workstreams impactados
| Workstream | Repo | Estado | Nota |
|---|---|---|---|
| `WS-web-app` | `acme-web` | Pendiente | [[CHG-025.WS-web-app]] |
| `WS-api-core` | `acme-api` | Pendiente | [[CHG-025.WS-api-core]] |
| `WS-session-gateway` | `acme-bff` | Pendiente | [[CHG-025.WS-session-gateway]] |

## Estado transversal
> OWNER: consolidation
> MODE: replace-only

### Resumen
Pendiente
