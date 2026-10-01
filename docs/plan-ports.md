# Plan de ports

On a choisi les ports avant de lancer quoi que ce soit, pour éviter les conflits.

| Service | Image | Port interne | Port publié |
|---|---|---|---|
| Nginx | nginx:1.27.5 | 80 | 8080 |
| MySQL | mysql:8.4 | 3306 | 3307 |
| Adminer | adminer:5.5.1 | 8080 | 8081 |
| Grafana | grafana/grafana:11.3.0 | 3000 | 3001 |

Pourquoi ces choix :

- 8080 pour Nginx parce que c'est un port non privilégié et qu'il était libre.
- 3307 pour MySQL pour éviter le conflit avec un MySQL qui serait déjà installé sur la machine.
- 8081 pour Adminer parce que 8080 était déjà pris par le portail.
- 3001 pour Grafana pour éviter un Grafana local.

Avant de lancer, on vérifie que rien n'est occupé :

```
ss -tulpn | grep -E ':(8080|8081|3307|3001)\b'
```

Si la commande ne renvoie rien, c'est bon. Sinon il faut changer le port concerné et mettre à jour ce tableau.
