# Installation du serveur ConnectiQ

Procédure complète pour reconstruire le serveur depuis une machine vierge.

## Prérequis

- Une machine sous Linux (Parrot, Kali, Ubuntu, Debian)
- Docker Engine 26 ou supérieur
- Git installé
- Accès au réseau local (`192.168.3.0/24`)
- Un éditeur de texte (nano, VS Code)

Vérifier Docker :

```bash
docker --version
docker run hello-world
```

Vérifier Git :

```bash
git --version
```

## 1. Créer la structure de travail

```bash
mkdir -p ~/connectiq
mkdir -p ~/secrets
chmod 700 ~/secrets
```

- `~/connectiq` : le projet (dépôt Git, portail, SQL, docs).
- `~/secrets` : les fichiers de mots de passe, **jamais dans Git**.

## 2. Cloner le dépôt

```bash
cd ~/connectiq
git clone https://github.com/hrktsiory-lab/connectiq.git .
```

Le `.` final est important : il clone dans le dossier courant.

## 3. Créer les secrets

### `~/secrets/mysql.env`

```bash
nano ~/secrets/mysql.env
```

Contenu :

```env
MYSQL_ROOT_PASSWORD=<mot_de_passe_root>
MYSQL_DATABASE=inventaire
MYSQL_USER=Francisco
MYSQL_PASSWORD=<mot_de_passe_utilisateur>
```

### `~/secrets/grafana.env`

```bash
nano ~/secrets/grafana.env
```

Contenu :

```env
GF_SECURITY_ADMIN_USER=landrie
GF_SECURITY_ADMIN_PASSWORD=<mot_de_passe_grafana>
```

Protéger les fichiers :

```bash
chmod 600 ~/secrets/*.env
```

## 4. Créer le réseau Docker

```bash
docker network create connectiq-net
```

Ce réseau relie les 4 conteneurs entre eux. MySQL et Adminer communiquent par leur nom de conteneur.

## 5. Lancer MySQL

```bash
docker run -d \
  --name mysql-connectiq \
  --restart unless-stopped \
  --network connectiq-net \
  -p 3307:3306 \
  -v mysql_data:/var/lib/mysql \
  --env-file ~/secrets/mysql.env \
  mysql:8.4
```

Rôle de chaque option :

| Option | Rôle |
|---|---|
| `-d` | Exécution en arrière-plan |
| `--name mysql-connectiq` | Nom explicite du conteneur |
| `--restart unless-stopped` | Redémarrage automatique au boot |
| `--network connectiq-net` | Rejoint le réseau du projet |
| `-p 3307:3306` | Port publié 3307 → port interne 3306 |
| `-v mysql_data:/var/lib/mysql` | Volume nommé pour la persistance |
| `--env-file ~/secrets/mysql.env` | Injection des variables secrètes |
| `mysql:8.4` | Image et version explicite |

Attendre que MySQL soit prêt :

```bash
docker logs -f mysql-connectiq
```

Attendre la ligne :

```text
[Server] /usr/sbin/mysqld: ready for connections.
```

Puis `Ctrl+C`.

## 6. Lancer Adminer

```bash
docker run -d \
  --name adminer-connectiq \
  --restart unless-stopped \
  --network connectiq-net \
  -p 8081:8080 \
  adminer:5.5.1
```

Vérifier :

```bash
docker ps | grep adminer
```

## 7. Lancer Nginx (portail)

```bash
mkdir -p ~/connectiq/portail
```

```bash
docker run -d \
  --name portail-connectiq \
  --restart unless-stopped \
  --network connectiq-net \
  -p 8080:80 \
  -v ~/connectiq/portail:/usr/share/nginx/html:ro \
  nginx:1.27.5
```

Le bind mount `~/connectiq/portail` permet de modifier la page **sans redémarrer** le conteneur.

## 8. Lancer Grafana

```bash
docker run -d \
  --name grafana-connectiq \
  --restart unless-stopped \
  --network connectiq-net \
  -p 3001:3000 \
  -v grafana_data:/var/lib/grafana \
  --env-file ~/secrets/grafana.env \
  grafana/grafana:11.3.0
```

## 9. Importer le script SQL

Le script `sql/inventaire.sql` crée la base et les tables.

```bash
docker cp ~/connectiq/sql/inventaire.sql mysql-connectiq:/tmp/inventaire.sql
docker exec -it mysql-connectiq mysql -uroot -p -e "SOURCE /tmp/inventaire.sql;"
```

Mot de passe : `MYSQL_ROOT_PASSWORD` du fichier `~/secrets/mysql.env`.

Vérifier :

```bash
docker exec -it mysql-connectiq mysql -uroot -p -e "USE inventaire; SHOW TABLES; SELECT * FROM machines;"
```

## 10. Vérifications finales

### Conteneurs

```bash
docker ps
```

Attendu : 4 conteneurs `Up`.

### Versions explicites

```bash
docker ps --format "table {{.Names}}\t{{.Image}}"
```

Attendu : `nginx:1.27.5`, `mysql:8.4`, `adminer:5.5.1`, `grafana/grafana:11.3.0`.

### Réseau

```bash
docker network inspect connectiq-net
```

Attendu : les 4 conteneurs dans `Containers`.

### Volumes

```bash
docker volume ls
```

Attendu : `mysql_data`, `grafana_data`.

### Accès depuis un autre poste

- http://IP_SERVEUR:8080 → portail
- http://IP_SERVEUR:8081 → Adminer
- http://IP_SERVEUR:3001 → Grafana
- `mysql -h IP_SERVEUR -P 3307 -u Francisco -p` → MySQL

## 11. Test de persistance

### Portail

```bash
docker stop portail-connectiq
docker rm portail-connectiq
```

Relancer :

```bash
docker run -d \
  --name portail-connectiq \
  --restart unless-stopped \
  --network connectiq-net \
  -p 8080:80 \
  -v ~/connectiq/portail:/usr/share/nginx/html:ro \
  nginx:1.27.5
```

Vérifier : la page est toujours servie.

### MySQL

```bash
docker stop mysql-connectiq
docker rm mysql-connectiq
```

Relancer :

```bash
docker run -d \
  --name mysql-connectiq \
  --restart unless-stopped \
  --network connectiq-net \
  -p 3307:3306 \
  -v mysql_data:/var/lib/mysql \
  --env-file ~/secrets/mysql.env \
  mysql:8.4
```

Attendre `ready for connections`, puis vérifier via Adminer : les données sont toujours là.

## 12. Dépannage

### `403 Forbidden` sur Nginx

Le dossier `~/connectiq/portail` est vide. Créer `index.html`.

### `Access denied` sur Adminer

Vérifier que `MYSQL_USER` et `MYSQL_PASSWORD` dans `~/secrets/mysql.env` correspondent à ceux utilisés au lancement.

### `Unknown server host 'mysql-connectiq'`

Vérifier que MySQL et Adminer sont sur le même réseau :

```bash
docker network inspect connectiq-net
```

### Le conteneur ne démarre pas

Consulter les logs :

```bash
docker logs <nom_du_conteneur>
```

Lire le message d'erreur en entier, vérifier l'état des conteneurs, puis se référer à la documentation officielle de l'image.
