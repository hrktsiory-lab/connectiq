# Installation du serveur

Ce document explique comment remonter tout le projet depuis une machine vierge. Si tu suis les étapes dans l'ordre, tu dois arriver au même résultat que nous.

## Ce qu'il faut avant de commencer

Une machine Linux avec Docker installé. On a utilisé la version 26.1.5. Git aussi, pour récupérer le dépôt.

Pour vérifier que Docker fonctionne :

```
docker --version
docker run hello-world
```

Si `hello-world` s'affiche, c'est bon.

## Créer les dossiers

```
mkdir -p ~/connectiq
mkdir -p ~/secrets
chmod 700 ~/secrets
```

Le dossier `connectiq` contiendra le projet cloné depuis GitHub. `secrets` contient les mots de passe et ne doit jamais aller dans Git.

## Récupérer le dépôt

```
cd ~/connectiq
git clone https://github.com/hrktsiory-lab/connectiq.git .
```

Le point à la fin c'est pour cloner dans le dossier courant.

## Créer les fichiers de secrets

Il faut deux fichiers.

`~/secrets/mysql.env` :

```
MYSQL_ROOT_PASSWORD=ton_mot_de_passe_root
MYSQL_DATABASE=inventaire
MYSQL_USER=Francisco
MYSQL_PASSWORD=ton_mot_de_passe_utilisateur
```

`~/secrets/grafana.env` :

```
GF_SECURITY_ADMIN_USER=landrie
GF_SECURITY_ADMIN_PASSWORD=ton_mot_de_passe_grafana
```

Puis on protège les fichiers :

```
chmod 600 ~/secrets/*.env
```

Ces mots de passe doivent être transmis aux membres de l'équipe par un canal privé, pas dans le groupe ni dans Git.

## Créer le réseau Docker

```
docker network create connectiq-net
```

Tous les conteneurs vont dessus. Ça permet à Adminer de joindre MySQL par son nom.

## Lancer MySQL

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

Le `-d` c'est pour tourner en arrière-plan. `--name` donne un nom au conteneur. `--restart unless-stopped` fait qu'il redémarre tout seul si la machine reboot. `-p 3307:3306` publie le port 3307 de la machine vers le 3306 du conteneur. `-v mysql_data:/var/lib/mysql` crée un volume pour que les données survivent. Et `--env-file` lit les mots de passe depuis le fichier secret.

Il faut attendre quelques secondes que MySQL s'initialise. On peut suivre avec :

```
docker logs -f mysql-connectiq
```

Quand on voit `ready for connections`, on peut faire Ctrl+C.

## Lancer Adminer

```
docker run -d \
  --name adminer-connectiq \
  --restart unless-stopped \
  --network connectiq-net \
  -p 8081:8080 \
  adminer:5.5.1
```

Pas besoin de volume, Adminer ne stocke rien, il lit juste MySQL.

## Lancer Nginx

D'abord créer le dossier du portail :

```
mkdir -p ~/connectiq/portail
```

Puis :

```
docker run -d \
  --name portail-connectiq \
  --restart unless-stopped \
  --network connectiq-net \
  -p 8080:80 \
  -v ~/connectiq/portail:/usr/share/nginx/html:ro \
  nginx:1.27.5
```

Le bind mount permet de modifier les fichiers de la page sans redémarrer le conteneur. Le `:ro` c'est pour que Nginx ne puisse pas écrire dedans.

## Lancer Grafana

```
docker run -d \
  --name grafana-connectiq \
  --restart unless-stopped \
  --network connectiq-net \
  -p 3001:3000 \
  -v grafana_data:/var/lib/grafana \
  --env-file ~/secrets/grafana.env \
  grafana/grafana:11.3.0
```

## Importer le SQL

Le script `sql/inventaire.sql` crée la base et les tables.

```
docker cp ~/connectiq/sql/inventaire.sql mysql-connectiq:/tmp/inventaire.sql
docker exec -it mysql-connectiq mysql -uroot -p -e "SOURCE /tmp/inventaire.sql;"
```

Il demande le mot de passe root. On vérifie après :

```
docker exec -it mysql-connectiq mysql -uroot -p -e "USE inventaire; SHOW TABLES; SELECT * FROM machines;"
```

On doit voir les tables `machines` et `interventions` plus les données.

## Vérifier que tout tourne

```
docker ps
```

On doit voir 4 conteneurs en `Up`.

Pour vérifier que les versions sont bonnes :

```
docker ps --format "table {{.Names}}\t{{.Image}}"
```

On doit voir les versions précises, pas de `latest`.

## Vérifier les volumes

```
docker volume ls
```

`mysql_data` et `grafana_data` doivent apparaître.

## Vérifier depuis un autre poste

Depuis une autre machine du réseau, il faut pouvoir ouvrir :

- http://192.168.3.43:8080 pour le portail
- http://192.168.3.43:8081 pour Adminer
- http://192.168.3.43:3001 pour Grafana

Et pour MySQL en ligne de commande :

```
mysql -h 192.168.3.43 -P 3307 -u Francisco -p
```

## Tester la persistance

C'est important : les données doivent survivre à la suppression des conteneurs.

Pour le portail :

```
docker stop portail-connectiq
docker rm portail-connectiq
```

Puis on relance avec la même commande qu'avant. La page doit toujours s'afficher.

Pour MySQL :

```
docker stop mysql-connectiq
docker rm mysql-connectiq
```

Et on relance pareil. Il faut attendre `ready for connections`, puis vérifier dans Adminer que les données sont toujours là.

## Si ça ne marche pas

Erreur 403 sur Nginx : le dossier portail est vide, il manque `index.html`.

`Access denied` sur Adminer : les identifiants ne correspondent pas à ceux utilisés au lancement de MySQL.

`Unknown server host 'mysql-connectiq'` : les conteneurs ne sont pas sur le même réseau, vérifier avec `docker network inspect connectiq-net`.

Un conteneur ne démarre pas : regarder les logs avec `docker logs <nom>`, lire le message en entier.
