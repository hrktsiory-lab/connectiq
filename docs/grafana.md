# Grafana

C'est l'outil de supervision, avec un tableau de bord qui liste les services du projet.

## Image

grafana/grafana:11.3.0

## Ports

Interne : 3000. Publié : 3001.

## Volume

grafana_data monté sur /var/lib/grafana pour garder les dashboards.

## Lancer le conteneur

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

Les identifiants sont dans ~/secrets/grafana.env. On a changé le mot de passe par défaut après la première connexion, comme demandé dans le cahier des charges.

## Se connecter

http://192.168.3.43:3001

Utilisateur : landrie. Mot de passe : celui du fichier secret.

## Dashboard

Caleb-Leandrie a créé un dashboard nommé "Supervision ConnectiQ" avec un panneau texte qui liste les 4 services et leurs adresses.

## Persistance

Le volume grafana_data garde les dashboards même si on supprime le conteneur.
