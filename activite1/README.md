# Activité 1 - Dockerfile

## Partie 1 - Conteneur manuel

**1. Lancer un conteneur ubuntu en mode interactif**

```bash
docker run -it --name mongo-manuel ubuntu:22.04 bash
```

**2. Installer MongoDB (doc officielle)**

```bash
apt-get update
apt-get install -y gnupg curl ca-certificates procps

curl -fsSL https://pgp.mongodb.com/server-8.0.asc | gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list

apt-get update
apt-get install -y mongodb-org
```

**3. Démarrer mongod manuellement**

```bash
mongod --config /etc/mongod.conf &
```

**4. Vérifier avec ps**

```bash
ps -ef
```

→ `mongod` apparaît bien dans la liste.

**5. Supprimer la collection Personnes**

```bash
mongosh
```

```javascript
db.Personnes.drop()
```

(Remarque : depuis MongoDB 6.0 le client s'appelle `mongosh`, il n'y a plus de `mongo`.)

**6. Sortir**

```bash
exit
exit
```

**7. Créer l'image et vérifier**

```bash
docker commit mongo-manuel mongo-manuel:v1
docker run -d --name check mongo-manuel:v1 sleep infinity
docker exec check ps -ef
```

→ `mongod` n'est **pas** relancé (le commit ne sauvegarde que les fichiers, pas les processus). On ajoute donc le correctif :

```bash
echo "/usr/bin/mongod --config /etc/mongod.conf &" >> /etc/bash.bashrc
docker commit check mongo-manuel:v2
```

En relançant un conteneur depuis `mongo-manuel:v2` avec une session bash interactive, `mongod` redémarre bien tout seul.

---

## Partie 2 - Dockerfile

**1. Créer le dossier**

```bash
mkdir mongodb && cd mongodb
```

**2. Récupérer les fichiers officiels**

```bash
curl -fsSL -o Dockerfile https://raw.githubusercontent.com/docker-library/mongo/master/7.0/Dockerfile
curl -fsSL -o docker-entrypoint.sh https://raw.githubusercontent.com/docker-library/mongo/master/7.0/docker-entrypoint.sh
```

**3. Droits sur les fichiers**

```bash
chmod 644 Dockerfile docker-entrypoint.sh
chmod +x docker-entrypoint.sh
```

**4. Construire l'image**

```bash
docker build -t mongo-atelier2:7.0 .
```

**5. Lancer et vérifier**

```bash
docker run -d --name check2 mongo-atelier2:7.0
docker exec check2 ps -ef
```

→ `mongod` tourne directement (PID 1), pas besoin de le démarrer à la main : c'est l'`ENTRYPOINT` du Dockerfile qui s'en charge.
