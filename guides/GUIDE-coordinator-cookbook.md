# GUIDE - Coordinator Cookbook

## Objetivo
Dar ejemplos cortos y reales para usar `workstream-coordinator` en el día a día sin pensar en scripts internos.

## Regla rápida
- usa intención humana primero
- usa referencias parciales si son únicas
- deja que la fachada infiera antes de escribir más

---

## 1. Ver el estado de un change

### Forma explícita
```text
/change-status CHG-031
```

### Forma corta
```text
CHG-031
status silent-session-renewal
```

### Cuándo usarlo
- cuando retomas un change
- cuando quieres ver workstreams, riesgos y siguiente paso

---

## 2. Validar todo el vault

```text
check
```

O si prefieres la forma larga:

```text
/check-vault
```

### Cuándo usarlo
- antes de cambios importantes
- después de consolidar

---

## 3. Validar un change

```text
check CHG-031
check silent-session-renewal
```

### Cuándo usarlo
- para ver warnings semánticos
- para detectar workstreams sin progreso real o sin evidencia

---

## 4. Validar un workstream

```text
check WS-web-app
check web-app
```

### Cuándo usarlo
- para revisar si una línea de trabajo quedó bien documentada

---

## 5. Abrir trabajo para el workstream más probable

```text
open CHG-031
```

### Qué hace
- intenta inferir el workstream activo o pendiente más razonable
- devuelve lecturas, escrituras y siguiente paso

---

## 6. Abrir trabajo con modo explícito

```text
open CHG-031 validation
open CHG-031 web-app documentation
```

### Modos útiles
- `implementation`
- `validation`
- `documentation`
- `closure`

También acepta abreviados como `review`, `docs`, `impl`.

---

## 7. Cerrar una sesión con workstream explícito

```text
close CHG-031 WS-web-app Parcial "Se agregó consumo del endpoint|Se implementó renovación silenciosa"
```

### Cuándo usarlo
- cuando quieres máxima precisión
- cuando hay varios workstreams posibles

---

## 8. Cerrar una sesión dejando que la fachada infiera

```text
close CHG-031 parcial "Se agregó consumo del endpoint"
```

### Cuándo usarlo
- cuando solo hay un workstream razonable para continuar

### Importante
Si falta contexto o hay ambigüedad real, conviene indicar `WS-xxx` explícitamente.

---

## 9. Consolidar un change

```text
sync CHG-031
sync silent-session-renewal
```

### Qué hace
- actualiza `Estado transversal`
- sincroniza estados de la tabla principal
- consolida riesgos y dependencias

---

## 10. Flujo diario mínimo

```text
CHG-031
open CHG-031
close CHG-031 parcial "Resumen técnico breve"
sync CHG-031
check CHG-031
```

### Cuándo usarlo
- para una iteración normal de trabajo sobre un change ya existente

---

## 11. Flujo de revisión rápida

```text
status silent-session-renewal
open CHG-031 validation
check CHG-031
```

### Cuándo usarlo
- cuando quieres inspeccionar estado y warnings sin editar demasiado

---

## 12. Crear un change nuevo

```text
new CHG-040 token-rotation SYS-auth-platform WS-web-app,WS-api-core
```

### Cuándo usarlo
- cuando empieza un trabajo transversal nuevo

---

## Errores comunes

### 1. Referencia parcial ambigua
Si `web-app` o un slug corto coincide con más de una opción, la fachada te pedirá más precisión.

### 2. Cerrar sin resumen
`close` necesita estado y resumen técnico mínimo.

### 3. Asumir que validar significa editar
`open ... validation` prepara lectura y revisión; no debería implicar escritura salvo instrucción explícita.

---

## Recomendación final

Empieza por la forma corta.
Si hay ambigüedad, añade solo la precisión mínima necesaria.
