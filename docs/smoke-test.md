# Prueba de humo y validación — sdd-harness 0.1.0

Fecha de preparación: 2026-10-27.

## 1. Validación estática (ejecutada)

| Comando | Resultado |
|---|---|
| `claude plugin validate --strict .` | Validation passed |
| `bats tests/` | 37 pruebas, todas ok |

## 2. Evals pendientes de ejecutar

`claude plugin eval` no pudo ejecutarse desde la sesión de desarrollo (guarda de worktree y clasificador de permisos). Ejecutar desde la raíz del repo tras integrar la rama:

```bash
claude plugin eval . --runs 1 --ablation none --scaffold --allow-tools Write Edit Bash
```

Para un caso concreto: `claude plugin eval . --case <nombre> --runs 1 --ablation none --scaffold --allow-tools Write Edit Bash`.
`--scaffold` es necesario en los casos con `fixture.sh` (scaffold-existing, research-lines, design-diagrams). Si un caso falla por `when_to_use`, anotar el ajuste en la columna de notas.

| Caso | Resultado | Notas |
|---|---|---|
| scaffold-new | pendiente | |
| scaffold-existing | pendiente | |
| project-folder | pendiente | |
| research-lines | pendiente | |
| design-diagrams | pendiente | |
| workflow-routes | pendiente | |

## 3. Instalación estable local (pendiente tras integrar la rama)

No se ejecutó para no modificar la configuración global antes de que la rama esté integrada. Tras el merge:

```bash
claude plugin marketplace add ~/Documents/GitHub/sdd-harness
claude plugin install sdd-harness@sdd-harness --scope user
claude plugin list
```

Esperado: `sdd-harness` listado como enabled.

## 4. Humo en directorio vacío

Estado: **pendiente**. El 2026-10-27 se intentó la ejecución no interactiva desde la sesión de desarrollo y el entorno la rechazó antes de iniciarla ("worktree-isolated session ... what it runs cannot be shown not to be git"). No se eludió la restricción.

Comando a ejecutar por el usuario (ajustar la ruta de `--plugin-dir` a la rama integrada o al worktree):

```bash
mkdir -p /tmp/demo-sdd && cd /tmp/demo-sdd
claude -p "estructura este proyecto nuevo llamado Demo, sin cliente, stack Python" \
  --plugin-dir ~/Documents/GitHub/sdd-harness \
  --permission-mode acceptEdits \
  --allowedTools "Bash Read Write Edit Glob Grep Skill" --max-turns 40
```

Verificaciones:

- [ ] `CLAUDE.md` existe y contiene la línea `Scaffold: sdd-harness 0.1.0`
- [ ] `agent_docs/` contiene nueve archivos
- [ ] `docs/plannings/` no existe
- [ ] `README.md` presente
- [ ] Existe al menos un commit (`git log --oneline`)

Resultado: _(fecha, observaciones)_
