# Plan de ports

Plan validé par l'équipe avant le premier lancement.

| Service | Image | Port interne | Port publié | Justification |
|---|---|---:|---:|---|
| Portail (Nginx) | `nginx:1.27.5` | 80 | 8080 | Port non privilégié, souvent libre |
| MySQL | `mysql:8.4` | 3306 | 3307 | Évite le conflit avec un MySQL installé sur l'hôte |
| Adminer | `adminer:5.5.1` | 8080 | 8081 | 8080 est déjà pris par le portail |
| Grafana | `grafana/grafana:11.3.0` | 3000 | 3001 | Évite le conflit avec un Grafana local |

## Vérification des conflits

Avant chaque lancement, vérifier que les ports sont libres :

```bash
ss -tulpn | grep -E ':(8080|8081|3307|3001)\b'
```

Si un port est occupé, changez-le dans ce plan **avant** de lancer le conteneur.

## Règles

- Aucun port publié ne doit être déjà utilisé sur la machine serveur.
- Les ports publiés sont non privilégiés (> 1024).
- Ce plan est tenu à jour en cas de modification.
