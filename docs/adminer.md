# Adminer

C'est l'interface web pour consulter et modifier la base MySQL sans passer par la ligne de commande.

## Image

adminer:5.5.1

## Ports

Interne : 8080. Publié : 8081.

## Lancer le conteneur

```
docker run -d \
  --name adminer-connectiq \
  --restart unless-stopped \
  --network connectiq-net \
  -p 8081:8080 \
  adminer:5.5.1
```

Pas de volume, Adminer ne stocke rien.

## Se connecter

URL : http://192.168.3.43:8081

Sur l'écran de connexion :

- Système : MySQL
- Serveur : mysql-connectiq
- Utilisateur : Francisco
- Mot de passe : celui du fichier ~/secrets/mysql.env
- Base : inventaire

Le serveur c'est `mysql-connectiq` et pas une adresse IP parce que les deux conteneurs sont sur le même réseau Docker.

## Ce qu'on peut faire

Consulter les tables, ajouter des lignes, en modifier, en supprimer. Il y a aussi un onglet SQL command pour taper des requêtes, et Import/Export pour les fichiers.

L'interface est accessible depuis n'importe quel poste de l'équipe avec l'adresse du serveur.
