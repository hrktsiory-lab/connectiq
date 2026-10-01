# ConnectiQ / DOKODE

Projet d'équipe pour la formation Linux et Docker.

On devait mettre en place un petit serveur interne avec 4 services en conteneurs, accessibles depuis les postes de tout le monde sur le réseau local. Plus un inventaire du parc dans une base MySQL, une interface web pour la consulter, et un outil de supervision.

## L'équipe

- canisfaucon : serveur et coordination
- Caleb-Leandrie : supervision Grafana
- Benjamin : base de données
- Francisco : base de données et Adminer
- Rachell : portail Nginx
- Tsiory : documentation

## Les services

| Service | Adresse |
|---|---|
| Portail | http://192.168.3.43:8080 |
| Adminer | http://192.168.3.43:8081 |
| Grafana | http://192.168.3.43:3001 |
| MySQL | 192.168.3.43:3307 |

## Le serveur

C'est la machine de canisfaucon qui sert de serveur. Parrot Security, IP 192.168.3.43. Docker 26.1.5.

Aucun logiciel n'est installé directement sur le système. Tout tourne en conteneurs.

## Documentation

Le plus important c'est `docs/installation.md`, qui explique comment tout remonter depuis une machine vierge. Le reste détaille chaque service séparément.

- [Installation complète](docs/installation.md)
- [Plan de ports](docs/plan-ports.md)
- [Schéma](docs/schema.md)
- [Journal de projet](docs/journal.md)
- [MySQL](docs/mysql.md)
- [Adminer](docs/adminer.md)
- [Nginx](docs/nginx.md)
- [Grafana](docs/grafana.md)
- [Répartition des tâches](docs/repartition.md)

## Images utilisées

On a fixé les versions pour que tout le monde ait la même chose :

- nginx:1.27.5
- mysql:8.4
- adminer:5.5.1
- grafana/grafana:11.3.0

Pas de `latest`, c'est une règle du projet.

## Comment on travaille

Chacun a sa branche, on pousse, on ouvre une Pull Request, un autre relit et approuve avant de fusionner. Les mots de passe ne sont jamais dans le dépôt, ils sont dans `~/secrets/` sur le serveur.
