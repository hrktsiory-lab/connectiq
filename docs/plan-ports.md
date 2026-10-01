# Plan de ports

| Service | Image | Port interne | Port publié | Justification |
|---|---|---:|---:|---|
| Portail | nginx | 80 | 8080 | non privilégié, souvent libre |
| MySQL | mysql | 3306 | 3307 | évite un MySQL déjà installé |
| Adminer | adminer | 8080 | 8081 | 8080 pris par le portail |
| Grafana | grafana/grafana | 3000 | 3001 | évite un Grafana local |
