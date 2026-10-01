# Schéma d'architecture

## Vue générale

```text
                Postes clients (réseau local 192.168.3.0/24)
       ┌──────────────┬──────────────┬──────────────┐
       │              │              │              │
       ▼              ▼              ▼              ▼
  Navigateur     Navigateur     Navigateur     Client MySQL
  :8080          :8081          :3001          :3307
       │              │              │              │
       └──────────────┴──────────────┴──────────────┘
                              │
                              ▼
              Machine serveur parrot — 192.168.3.43
       ┌──────────────────────────────────────────────┐
       │  Docker                                      │
       │                                              │
       │  ┌──────────────┐    ┌──────────────┐        │
       │  │ portail-     │    │ adminer-     │        │
       │  │ connectiq    │    │ connectiq    │        │
       │  │ nginx:1.27.5 │    │ adminer:5.5.1│        │
       │  │ 8080 → 80    │    │ 8081 → 8080  │        │
       │  └──────┬───────┘    └──────┬───────┘        │
       │         │                   │                │
       │         │ bind mount        │ réseau         │
       │         ▼                   ▼ connectiq-net  │
       │  ~/connectiq/portail   ┌──────────────┐      │
       │                        │ mysql-       │      │
       │                        │ connectiq    │      │
       │                        │ mysql:8.4    │      │
       │                        │ 3307 → 3306  │      │
       │                        │ volume:      │      │
       │                        │ mysql_data   │      │
       │                        └──────────────┘      │
       │                                              │
       │  ┌──────────────┐                            │
       │  │ grafana-     │                            │
       │  │ connectiq    │                            │
       │  │ grafana:11.3 │                            │
       │  │ 3001 → 3000  │                            │
       │  │ volume:      │                            │
       │  │ grafana_data │                            │
       │  └──────────────┘                            │
       └──────────────────────────────────────────────┘
```

## Résumé

### Services

| Service | Conteneur | Image | Port interne | Port publié |
|---|---|---|---|---|
| Portail | `portail-connectiq` | `nginx:1.27.5` | 80 | 8080 |
| Adminer | `adminer-connectiq` | `adminer:5.5.1` | 8080 | 8081 |
| MySQL | `mysql-connectiq` | `mysql:8.4` | 3306 | 3307 |
| Grafana | `grafana-connectiq` | `grafana/grafana:11.3.0` | 3000 | 3001 |

### Volumes et bind mount

| Type | Nom | Monté dans | Rôle |
|---|---|---|---|
| Volume | `mysql_data` | `mysql-connectiq:/var/lib/mysql` | Persistance des données MySQL |
| Volume | `grafana_data` | `grafana-connectiq:/var/lib/grafana` | Persistance des dashboards Grafana |
| Bind mount | `~/connectiq/portail` | `portail-connectiq:/usr/share/nginx/html:ro` | Contenu de la page, modifiable à chaud |

### Réseau

- Nom : `connectiq-net`
- Type : bridge
- Sous-réseau : `172.18.0.0/16`
- Conteneurs : les 4 ci-dessus
- Permet à Adminer de joindre MySQL par le nom `mysql-connectiq`.
