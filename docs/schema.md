# Schéma

Voilà comment les services sont organisés.

```
Postes clients sur le réseau 192.168.3.0/24
   |
   |  navigateur / client mysql
   v
Machine serveur parrot — 192.168.3.43
   |
   |  Docker
   |
   +-- portail-connectiq   nginx:1.27.5      8080 -> 80
   |     bind mount ~/connectiq/portail
   |
   +-- adminer-connectiq   adminer:5.5.1     8081 -> 8080
   |
   +-- mysql-connectiq     mysql:8.4         3307 -> 3306
   |     volume mysql_data
   |
   +-- grafana-connectiq   grafana:11.3.0    3001 -> 3000
         volume grafana_data
```

Les conteneurs sont tous sur le réseau `connectiq-net` (bridge, 172.18.0.0/16).

## Détail par service

Nginx sert les fichiers du dossier `~/connectiq/portail` qui est monté en lecture seule dans le conteneur. C'est pour ça qu'on peut modifier la page sans redémarrer.

Adminer se connecte à MySQL par le nom de conteneur `mysql-connectiq`, ils sont sur le même réseau.

MySQL stocke ses données dans le volume `mysql_data`, qui survit à la suppression du conteneur.

Grafana stocke ses dashboards dans `grafana_data`, pareil.

## Ports publiés

| Service | Port sur la machine |
|---|---|
| Nginx | 8080 |
| Adminer | 8081 |
| MySQL | 3307 |
| Grafana | 3001 |

## Volumes

| Nom | Monté dans | Rôle |
|---|---|---|
| mysql_data | mysql-connectiq:/var/lib/mysql | Données MySQL |
| grafana_data | grafana-connectiq:/var/lib/grafana | Dashboards Grafana |

## Bind mount

`~/connectiq/portail` est monté en `:ro` dans `/usr/share/nginx/html` du conteneur Nginx.
