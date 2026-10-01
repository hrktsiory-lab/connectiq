# Nginx

C'est le serveur web qui affiche la page d'accueil du projet.

## Image

nginx:1.27.5

## Ports

Interne : 80. Publié : 8080.

## Bind mount

Le dossier ~/connectiq/portail de la machine serveur est monté dans le conteneur sur /usr/share/nginx/html en lecture seule. Comme ça on peut modifier la page sans redémarrer le conteneur, et Nginx ne peut pas écrire dedans.

## Lancer le conteneur

```
docker run -d \
  --name portail-connectiq \
  --restart unless-stopped \
  --network connectiq-net \
  -p 8080:80 \
  -v ~/connectiq/portail:/usr/share/nginx/html:ro \
  nginx:1.27.5
```

## La page

Le fichier portail/index.html contient le nom du projet, l'équipe, la liste des services et la date de mise à jour.

## Accès

http://192.168.3.43:8080

## Persistance

Comme le fichier est sur la machine et pas dans le conteneur, si on supprime et recrée le conteneur la page est toujours là. On l'a testé.
