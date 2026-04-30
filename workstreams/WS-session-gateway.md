# WS-session-gateway

## Identidad
- ID: `WS-session-gateway`
- Nombre: Session Gateway
- Repo: `acme-bff`
- Tipo: `execution-unit`

## Responsabilidad
Orquestar continuidad de sesión entre clientes y servicios.

## Límites
- No implementa UI
- No reemplaza contratos core

## Sistema asociado
- [[SYS-auth-platform]]

## Entradas
- [[API-auth-refresh]]

## Salidas
- coordinación de sesión

## Regla de actualización en vault
- `CHG-*.WS-session-gateway.md`
