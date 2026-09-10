# Challenge 1 - Docker / Nginx

Reponses aux exigences du challenge, avec les commandes executees et
verifiees dans cet environnement.

---

### 1. Lancez un conteneur docker se basant sur l'image *nginx* et accedez a sa page d'accueil via un navigateur web. (+1 etoile)

**Reponse :**

```bash
docker run --name nginx-basic -p 8080:80 nginx
```

Le flag `-p 8080:80` publie le port 80 du conteneur (port d'ecoute par
defaut de nginx) sur le port 8080 de l'hote. La page d'accueil est alors
accessible depuis un navigateur a l'adresse http://localhost:8080.

---

### 2. Lancez un conteneur de facon non bloquante, vous allez devoir detacher votre conteneur en arriere plan. (+1 etoile)

**Reponse :**

```bash
docker run -d --name nginx-basic -p 8080:80 nginx
docker ps --filter name=nginx-basic
```

Le flag `-d` (detached) lance le conteneur en arriere-plan : la commande
rend immediatement la main au terminal au lieu de rester attachee aux logs
du conteneur. `docker ps` confirme qu'il tourne toujours.

---

### 3. Remplacez une portion d'arborescence du conteneur par un emplacement hote afin d'ajouter une page html. (+2 etoiles)

**Reponse :**

Un fichier `html/index.html` est cree sur l'hote (dans ce dossier), puis
monte a la place du repertoire ou nginx sert son contenu statique
(`/usr/share/nginx/html`) via un bind mount (`-v hote:conteneur`) :

```bash
docker run -d --name nginx-custom -p 8081:80 \
  -v "$(pwd)/html:/usr/share/nginx/html:ro" \
  nginx
```

Verification :

```bash
curl http://localhost:8081
```

La reponse renvoie le contenu de `html/index.html` et non plus la page
"Welcome to nginx!" par defaut.

---

### 4.  Lancez un deuxieme conteneur se basant egalement sur votre fichier html et modifiez-le depuis l'emplacement hote. (+1 etoile)

**Reponse :**

```bash
docker run -d --name nginx-custom2 -p 8082:80 \
  -v "$(pwd)/html:/usr/share/nginx/html:ro" \
  nginx
```

Ce second conteneur pointe vers le meme dossier hote `html/`. En modifiant
`html/index.html` avec un simple editeur sur l'hote, le changement est
immediatement visible sur les deux conteneurs (http://localhost:8081 et
http://localhost:8082), sans redemarrage : le bind mount partage le meme
repertoire hote, il n'y a pas de copie de fichier dans l'image.

---

### 5. Supervisez votre conteneur web afin d'afficher les logs sur la console. (+1 etoile)

**Reponse :**

```bash
docker logs -f nginx-custom
```

L'image officielle nginx redirige ses logs d'acces et d'erreur vers
stdout/stderr du conteneur (au lieu d'un fichier), c'est pourquoi
`docker logs` peut les afficher. Le flag `-f` (follow) suit le flux en
continu sur la console, comme `tail -f` : chaque requete HTTP recue par le
conteneur (ex. `curl http://localhost:8081`) apparait en temps reel.

---

