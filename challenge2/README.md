# Challenge 2 - Creation d'un Dockerfile

Reponses aux exigences du challenge, avec les commandes executees et
verifiees dans cet environnement.

---

### 1. Creez un fichier script shell permettant de realiser l'emission d'un message regulier.

**Reponse :**

Fichier [emit-message.sh](emit-message.sh) :

```sh
#!/bin/sh
MESSAGE="${1:-Hello from container}"

while true; do
  echo "$(date '+%Y-%m-%d %H:%M:%S') - ${MESSAGE}"
  sleep 5
done
```

Le script tourne en boucle infinie et affiche un message horodate toutes
les 5 secondes sur la sortie standard. `$1` est le premier argument passe
au script ; s'il est absent, `${MESSAGE:-...}` fournit une valeur par
defaut ("Hello from container").

---

### 2. Creez un Dockerfile permettant de creer une image lancant le script.

**Reponse :**

Fichier [Dockerfile](Dockerfile) :

```dockerfile
FROM alpine:latest

COPY emit-message.sh /usr/local/bin/emit-message.sh
RUN chmod +x /usr/local/bin/emit-message.sh

ENTRYPOINT ["/usr/local/bin/emit-message.sh"]
```

- `FROM alpine:latest` : image de base minimale (contient `/bin/sh`).
- `COPY` copie le script depuis l'hote vers l'image.
- `RUN chmod +x` le rend executable.
- `ENTRYPOINT` (forme exec, en tableau) fait du script le point d'entree du
  conteneur : tout argument passe a `docker run <image> <arg>` est transmis
  au script comme `$1` (voir exigence 5).

---

### 3. Generez l'image realisee avec le Dockerfile et lancez un conteneur.

**Reponse :**

```bash
docker build -t message-emitter .
docker run --rm message-emitter
```

`docker build -t message-emitter .` lit le `Dockerfile` du repertoire
courant et construit l'image taguee `message-emitter`. `docker run` lance
ensuite un conteneur a partir de cette image ; le script s'execute et
affiche ses messages directement dans le terminal (mode attache) :

```
2026-09-10 14:01:36 - Hello from container
2026-09-10 14:01:41 - Hello from container
```

---

### 4. Lancez un conteneur a partir de votre image en mode detache et supervisez votre conteneur afin de voir les emissions des messages.

**Reponse :**

```bash
docker run -d --name emitter message-emitter
docker logs -f emitter
```

Le flag `-d` detache le conteneur (execution en arriere-plan, terminal
libere immediatement). `docker logs -f` (follow) affiche ensuite en direct
la sortie standard du conteneur, donc les messages emis par le script au
fil du temps :

```
2026-09-10 14:01:46 - Hello from container
2026-09-10 14:01:51 - Hello from container
```

---

### 5. Donnez la possibilite de passer en parametre le message au lancement du conteneur.

**Reponse :**

Grace a la forme `ENTRYPOINT ["/usr/local/bin/emit-message.sh"]` du
Dockerfile, tout argument supplementaire donne a `docker run` est transmis
au script :

```bash
docker run -d --name emitter-custom message-emitter "Coucou depuis mon conteneur perso"
docker logs emitter-custom
```

```
2026-09-10 14:01:56 - Coucou depuis mon conteneur perso
2026-09-10 14:02:01 - Coucou depuis mon conteneur perso
```

Sans argument, le script retombe sur le message par defaut defini dans
`emit-message.sh` (`Hello from container`).

---
