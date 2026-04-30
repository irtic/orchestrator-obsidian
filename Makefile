.PHONY: validate vault-validate chg-new handoff-open handoff-close chg-consolidate coordinator

validate:
	bash scripts/validate-structure.sh

vault-validate:
	bash scripts/vault-validate.sh

chg-new:
	@printf "Uso: bash scripts/chg-new.sh <change-id> <slug> --system <system-id> --workstreams <ws1,ws2,...>\n"

handoff-open:
	@printf "Uso: bash scripts/handoff-open.sh <change-id> <workstream-id> <mode>\n"

handoff-close:
	@printf "Uso: bash scripts/handoff-close.sh <change-id> <workstream-id> <status> --summary \"texto|texto\" [--files \"ruta1|ruta2\"] ...\n"

chg-consolidate:
	@printf "Uso: bash scripts/chg-consolidate.sh <change-id>\n"

coordinator:
	@printf "Uso: bash scripts/workstream-coordinator.sh /change-new|/work-open|/work-close|/change-sync|/change-status|/check-vault ...\n"
