# CHG-031 - silent session renewal

## Control
> OWNER: architect
> MODE: protected

## Objetivo
Implementar renovación silenciosa de sesión

## Motivación
Evitar relogin al expirar el access token

## Alcance
- cliente web
- endpoint refresh

## No alcance
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
| `WS-web-app` | `acme-web` | Parcial | [[CHG-031.WS-web-app]] |
| `WS-api-core` | `acme-api` | Pendiente | [[CHG-031.WS-api-core]] |

## Estado transversal
> OWNER: consolidation
> MODE: replace-only

### Resumen
- WS-api-core: Pendiente
- WS-web-app: Parcial

### Riesgos abiertos
- Depende de errores consistentes desde API

### Dependencias abiertas
- Falta confirmar contrato de error refresh expirado
