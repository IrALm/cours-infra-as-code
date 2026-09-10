# Activite 2 - Docker Compose avec un template Docker

### Utilisez un template propose par Docker pour lancer un stack avec Docker Compose: https://github.com/docker/awesome-compose 

**Reponse :**

Stack choisie : **spring-postgres** — une application Spring Boot (Java)
connectee a une base PostgreSQL, definie dans
[spring-postgres/compose.yaml](spring-postgres/compose.yaml).


## Composition du stack (`compose.yaml`)

```yaml
services:
  backend:
    build: backend        # image construite depuis backend/Dockerfile
    ports:
      - 8080:8080
    environment:
      - POSTGRES_DB=example
    depends_on:
      db:
        condition: service_healthy   # attend que le healthcheck de db passe au vert
  db:
    image: postgres:16
    restart: always
    secrets:
      - db-password        # mot de passe injecte via un secret Docker, pas une variable d'env en clair
    volumes:
      - db-data:/var/lib/postgresql/data   # persistance des donnees
    environment:
      - POSTGRES_DB=example
      - POSTGRES_PASSWORD_FILE=/run/secrets/db-password
    expose:
      - 5432                # port ouvert uniquement aux autres services du reseau compose, pas a l'hote
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d example"]
      interval: 2s
      timeout: 3s
      retries: 10
volumes:
  db-data:
secrets:
  db-password:
    file: db/password.txt
```

Deux services relies par un reseau Compose dedie (`spring-postgres`) : le
backend Java ne connait la base que par son nom de service (`db`), pas par
une IP, grace a la resolution DNS interne de Docker Compose.

## Lancement

```bash
cd spring-postgres
docker compose up -d --build
docker compose ps
```

## Verification

```bash
curl http://localhost:8080
```

Reponse :

```html
<p>Hello from Docker!</p>
```

Le message "Docker" est lu depuis la table `greetings` de la base
Postgres (donnee inseree au demarrage par `backend/src/main/resources/data.sql`) :

```bash
docker exec spring-postgres-db-1 psql -U postgres -d example -c "SELECT * FROM greetings;"
```

```
 id |  name
----+--------
  1 | Docker
```

Cela confirme que le backend communique bien avec la base via le reseau
Compose et affiche une donnee qui en provient reellement (pas une valeur
codee en dur).

## Nettoyage

```bash
docker compose down -v
```
