# Projet ConnectiQ / DOKODE

Serveur interne conteneurisé et inventaire du parc informatique.

Projet d'équipe — Formation Linux et Docker.

## Présentation

Ce projet met en service, sur une machine du groupe, un serveur interne hébergeant quatre services conteneurisés, accessibles depuis tous les postes de l'équipe via le réseau local.

## Équipe

| Membre | Rôle |
|---|---|
| canisfaucon | Serveur / coordination |
| Caleb-Leandrie | Supervision (Grafana) |
| Benjamin | Base de données (MySQL)+Adminer |
| Francisco | Base de données (MySQL + Adminer) |
| Rachell | Portail web (Nginx) |
| Tsiory | Documentation |

## Services

| Service | Adresse | Rôle |
|---|---|---|
| Portail | http://192.168.3.43:8080 | Page d'accueil du projet |
| Adminer | http://192.168.3.43:8081 | Interface web pour MySQL |
| Grafana | http://192.168.3.43:3001 | Supervision |
| MySQL | 192.168.3.43:3307 | Base de données de l'inventaire |

## Machine serveur

- Nom : parrot
- Adresse IP : 192.168.3.43
- Docker : 26.1.5
- Système : Parrot Security 7.4

## Documentation

- [Installation complète](docs/installation.md)
- [Plan de ports](docs/plan-ports.md)
- [Schéma d'architecture](docs/schema.md)
- [Journal de projet](docs/journal.md)
- [MySQL](docs/mysql.md)
- [Adminer](docs/adminer.md)
- [Nginx](docs/nginx.md)
- [Grafana](docs/grafana.md)
- [Répartition des tâches](docs/repartition.md)

## Reconstruction du serveur

Pour reconstruire le serveur depuis une machine vierge, suivre **intégralement** la procédure décrite dans [`docs/installation.md`](docs/installation.md).

## Outils utilisés

- Docker Engine 26.1.5
- Git 2.47.3
- Images : `nginx:1.27.5`, `mysql:8.4`, `adminer:5.5.1`, `grafana/grafana:11.3.0`

## Règles du projet

- Aucun service installé directement sur l'hôte.
- Versions explicites, jamais `latest`.
- Les données survivent à la suppression des conteneurs (volumes et bind mount).
- Aucun mot de passe dans le dépôt.
- Toute modification passe par une branche, une Pull Request et une relecture.
