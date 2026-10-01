# MySQL

C'est la base de données du projet. Elle contient l'inventaire des machines de l'équipe et les interventions.

## Image

mysql:8.4

## Ports

Interne : 3306. Publié : 3307.

## Volume

mysql_data monté sur /var/lib/mysql.

## Lancer le conteneur

```
docker run -d \
  --name mysql-connectiq \
  --restart unless-stopped \
  --network connectiq-net \
  -p 3307:3306 \
  -v mysql_data:/var/lib/mysql \
  --env-file ~/secrets/mysql.env \
  mysql:8.4
```

Les mots de passe sont lus depuis ~/secrets/mysql.env qui n'est pas dans le dépôt.

## Les tables

### machines

Contient les machines de l'équipe.

- id (clé primaire, auto-incrément)
- nom
- systeme_exploitation
- ram
- espace_disque
- adresse_ip
- utilisateur_responsable

### interventions

Contient les interventions faites sur les machines.

- id (clé primaire, auto-incrément)
- machine_id (clé étrangère vers machines.id, avec ON DELETE CASCADE)
- date_intervention
- nature
- personne_intervenue
- observations

## Importer le script

```
docker cp sql/inventaire.sql mysql-connectiq:/tmp/inventaire.sql
docker exec -it mysql-connectiq mysql -uroot -p -e "SOURCE /tmp/inventaire.sql;"
```

## Vérifier

```
docker exec -it mysql-connectiq mysql -uroot -p -e "USE inventaire; SHOW TABLES; SELECT * FROM machines;"
```

## Persistance

Le volume mysql_data fait que les données restent même si on supprime le conteneur. On l'a testé : stop, rm, relance, les données sont toujours là.
