# Journal de projet

Projet ConnectiQ / DOKODE — 3 jours.

Équipe : canisfaucon, Caleb-Leandrie, Benjamin, Francisco, Rachell, Tsiory.

---

## Jour 1 — 2026-10-01

On a commencé par relire le cahier des charges ensemble pour être sûrs de comprendre ce qui était demandé. On a vite vu qu'il fallait tout faire en conteneurs, avec des versions précises, et que la doc devait permettre à n'importe qui de tout remonter.

On a choisi la machine de canisfaucon comme serveur, parce qu'elle reste allumée et qu'elle est sur le réseau de la salle. Son IP c'est 192.168.3.43.

Ensuite on a listé les ports qu'on voulait utiliser : 8080 pour le portail, 8081 pour Adminer, 3307 pour MySQL et 3001 pour Grafana. On a vérifié qu'aucun n'était déjà pris avec `ss -tulpn`, c'était bon.

canisfaucon a créé le dépôt GitHub `connectiq` et a protégé la branche main pour qu'on soit obligés de passer par des Pull Requests. On a eu un peu de mal au début parce que le ruleset était créé mais ne s'appliquait à rien, il fallait ajouter la cible `main` dans les branches. Une fois compris, c'était bon.

On a créé les fichiers de secrets dans `~/secrets/`, en dehors du dépôt, avec un chmod 600. On a décidé que les mots de passe ne passeraient jamais par Git ni par le groupe WhatsApp.

L'après-midi on a téléchargé les 4 images Docker avec des versions précises, pas de `latest`. On a choisi `nginx:1.27.5`, `mysql:8.4`, `adminer:5.5.1` et `grafana/grafana:11.3.0`.

On a lancé MySQL, Adminer, Grafana et Nginx. MySQL a démarré sans problème. Adminer a posé souci : on l'avait lancé deux fois, du coup Docker refusait de recréer un conteneur avec le même nom. On l'a supprimé et recréé en le mettant sur le réseau `connectiq-net` qu'on avait créé entre-temps.

Grafana a démarré mais on a oublié de le mettre sur le réseau au lancement, donc il a fallu le reconnecter après coup.

Nginx renvoyait une erreur 403 parce que le dossier `portail` était vide, il manquait le `index.html`. On a laissé comme ça pour l'instant, c'était à Rachell de s'en occuper.

En fin de journée on a créé les Issues GitHub pour chaque service, avec les responsables assignés.

---

## Jour 2 — 2026-10-02

Francisco a commencé par créer les tables `machines` et `interventions` directement dans Adminer. Il a repris les colonnes du cahier des charges, mais il a raccourci certains noms (`nom` au lieu de `nom_machine`, `ram` au lieu de `ram_go`, etc.). On a décidé de garder comme ça, ça reste lisible.

Il a ensuite saisi une première machine pour tester. On a remarqué qu'il manquait les IP des autres membres, donc canisfaucon a envoyé un message au groupe pour demander à chacun de lancer une commande et de renvoyer le résultat.

On a essayé d'exporter le script SQL depuis Adminer, mais Chrome bloquait le téléchargement parce que la page est en HTTP. Du coup on est passés par la ligne de commande avec `mysqldump`, c'était plus rapide :

```
docker exec mysql-connectiq mysqldump -uroot -p011024 --databases inventaire --skip-comments > sql/inventaire.sql
```

Le fichier a été mis dans le dépôt sur une branche `feature/sql-inventaire`, puis PR.

Rachell a écrit la page `portail/index.html` sur sa machine, avec le nom du projet, l'équipe et les 4 services. Elle l'a poussée sur une branche et on a fusionné. Dès que canisfaucon a fait `git pull` sur le serveur, la page s'est affichée sans qu'on ait besoin de redémarrer Nginx. C'était la preuve que le bind mount fonctionnait.

Caleb-Leandrie a créé le dashboard Grafana `Supervision ConnectiQ` avec un panneau texte qui liste les services.

On a testé l'accès depuis les autres postes : portail, Adminer et Grafana s'ouvraient bien. Pour Adminer il fallait se connecter avec `Francisco` / le mot de passe du fichier secret, et choisir le serveur `mysql-connectiq`.

En fin de journée on a fait un premier test de persistance sur MySQL. On a supprimé le conteneur, on l'a recréé, et les données étaient toujours là grâce au volume `mysql_data`.

---

## Jour 3 — 2026-10-03

Journée documentation et recette.

Tsiory a rédigé le `README.md` à la racine du dépôt et `docs/installation.md` avec toute la procédure : prérequis, création des secrets, réseau Docker, lancement des 4 conteneurs, import du SQL, vérifications, test de persistance, dépannage.

canisfaucon a fait le schéma d'architecture dans `docs/schema.md`, avec les 4 services, leurs ports et les volumes.

Benjamin et Francisco ont écrit `docs/mysql.md` et `docs/adminer.md`. Rachell a fait `docs/nginx.md`. Caleb-Leandrie a fait `docs/grafana.md`.

Pour la recette, on a vérifié chaque point du cahier des charges :

- Les 4 conteneurs tournent, versions explicites, pas de latest.
- Aucun service installé directement sur l'hôte.
- Le portail, Adminer et Grafana sont accessibles depuis chaque poste du réseau.
- On a supprimé et recréé les conteneurs MySQL et Nginx : les données et la page sont toujours là.
- On a importé le script SQL dans une base de test pour vérifier qu'il était complet, puis on a supprimé la base de test.

Dernier point : la reconstruction à l'identique. On a tiré un membre au sort, il a suivi `docs/installation.md` à la lettre sur une machine vierge et tout est remonté. C'est ce qui compte le plus pour la validation du projet.

---

## Ce qui nous a posé problème

- Les mots de passe ont été collés dans un chat au début, on a dû les changer et reprendre proprement avec les fichiers secrets.
- Adminer lancé deux fois, conteneur en conflit de nom.
- Grafana pas connecté au réseau `connectiq-net` au premier lancement.
- Nginx en 403 parce que le dossier portail était vide.
- Chrome qui bloquait le téléchargement du dump SQL, réglé avec mysqldump.

---

## Ce qu'on a décidé

- Une seule machine serveur.
- Versions explicites partout.
- Un réseau Docker `connectiq-net` pour relier les conteneurs.
- Volumes nommés pour MySQL et Grafana, bind mount pour le portail.
- Secrets dans `~/secrets/` avec chmod 600, jamais dans Git.
- Toute modif passe par une branche et une PR relue par un autre membre.
