# Challenge 3 - Mise en place d'une stack avec Docker Compose

Reponses aux exigences du challenge, avec les commandes executees et
verifiees dans cet environnement (Docker 28.5.1, Docker Compose v2.40.2).

---

### Lancer le stack Petclinic avec Docker Compose

Depot : https://github.com/spring-petclinic/spring-petclinic-microservices.git

**Reponse :**

#### 1. Recuperer le projet

```bash
git clone https://github.com/spring-petclinic/spring-petclinic-microservices.git
cd spring-petclinic-microservices
```

Le dossier clone `spring-petclinic-microservices/` est ignore par git
(voir [.gitignore](.gitignore)) : c'est un depot externe, on ne le versionne
pas dans ce depot.

#### 2. Lancer le stack

```bash
docker compose up -d
```

- `up` cree le reseau, telecharge les images et demarre les conteneurs.
- `-d` (detached) lance les conteneurs en arriere-plan.

Les images des microservices (`springcommunity/spring-petclinic-*`) sont
deja publiees sur Docker Hub : pas besoin de compiler avec Maven. Seuls
`grafana-server` et `prometheus-server` sont construits localement
(`build: ./docker/grafana`, `build: ./docker/prometheus`).

#### 3. Architecture du `docker-compose.yml`

| Service            | Role                                         | Port hote |
|--------------------|----------------------------------------------|-----------|
| config-server      | Configuration centralisee (Spring Cloud Config) | 8888   |
| discovery-server   | Annuaire de services (Eureka)                | 8761      |
| customers-service  | API proprietaires / animaux                  | 8081      |
| visits-service     | API visites                                  | 8082      |
| vets-service       | API veterinaires                             | 8083      |
| genai-service      | Chatbot IA (necessite une cle OpenAI)        | 8084      |
| api-gateway        | Point d'entree unique + interface web        | 8080      |
| admin-server       | Spring Boot Admin (supervision)              | 9090      |
| tracing-server     | Zipkin (traces distribuees)                  | 9411      |
| grafana-server     | Tableaux de bord                             | 3030      |
| prometheus-server  | Collecte de metriques                        | 9091      |

Points Compose notables :

- **Ordre de demarrage avec `depends_on` + `condition: service_healthy`** :
  `discovery-server` attend que `config-server` soit *healthy*, et tous les
  services metier attendent `config-server` **et** `discovery-server`.
  Un simple `depends_on` n'attendrait que le *demarrage* du conteneur, pas
  que l'application soit prete.
- **`healthcheck`** : Compose execute `curl` dans le conteneur toutes les 5 s
  (10 essais max) pour determiner l'etat *healthy*.
- **`deploy.resources.limits.memory`** : chaque service est limite a 512M
  (256M pour Grafana/Prometheus) pour que le stack tienne sur un poste.
- **Reseau** : Compose cree un reseau par defaut ou chaque service est
  joignable par son nom (`http://config-server:8888`, etc.).

#### 4. Verification

```bash
docker compose ps
```

```
NAME                STATUS                        PORTS
admin-server        Up 44 seconds                 0.0.0.0:9090->9090/tcp
api-gateway         Up 44 seconds                 0.0.0.0:8080->8080/tcp
config-server       Up About a minute (healthy)   0.0.0.0:8888->8888/tcp
customers-service   Up 44 seconds                 0.0.0.0:8081->8081/tcp
discovery-server    Up About a minute (healthy)   0.0.0.0:8761->8761/tcp
genai-service       Up 44 seconds                 0.0.0.0:8084->8084/tcp
grafana-server      Up About a minute             0.0.0.0:3030->3000/tcp
prometheus-server   Up About a minute             0.0.0.0:9091->9090/tcp
tracing-server      Up About a minute (healthy)   0.0.0.0:9411->9411/tcp
vets-service        Up 44 seconds                 0.0.0.0:8083->8083/tcp
visits-service      Up 44 seconds                 0.0.0.0:8082->8082/tcp
```

Services enregistres dans Eureka (http://localhost:8761) :
`ADMIN-SERVER`, `API-GATEWAY`, `CUSTOMERS-SERVICE`, `VETS-SERVICE`,
`VISITS-SERVICE`.

Appels a travers l'API Gateway :

```bash
curl http://localhost:8080/api/customer/owners
# [{"id":1,"firstName":"George","lastName":"Franklin",...}]

curl http://localhost:8080/api/vet/vets
# [{"id":1,"firstName":"James","lastName":"Carter",...}]

curl "http://localhost:8080/api/visit/pets/visits?petId=7"
# {"items":[{"id":1,"date":"2013-01-01","description":"rabies shot","petId":7},...]}
```

Interfaces web :

- Application Petclinic : http://localhost:8080
- Eureka : http://localhost:8761
- Spring Boot Admin : http://localhost:9090
- Zipkin : http://localhost:9411
- Grafana : http://localhost:3030
- Prometheus : http://localhost:9091

> Remarque : au premier appel juste apres le demarrage, la gateway peut
> repondre une erreur (405/503) le temps que les services s'enregistrent
> dans Eureka (~30 s). Il suffit de reessayer.

#### 5. Cas de `genai-service`

Sans cle API, le conteneur reste *Up* mais l'application Spring s'arrete :

```
OpenAI API key must be set. Use the connection property: spring.ai.openai.api-key ...
```

Il n'apparait donc pas dans Eureka. Ce service est optionnel (chatbot) :
le reste de l'application fonctionne. Pour l'activer :

```bash
export OPENAI_API_KEY="sk-..."
docker compose up -d genai-service
```

Compose substitue `${OPENAI_API_KEY}` depuis l'environnement du shell (ou
depuis un fichier `.env` place a cote du `docker-compose.yml`).

#### 6. Commandes utiles

```bash
docker compose logs -f api-gateway   # suivre les logs d'un service
docker compose restart vets-service  # redemarrer un service
docker compose stop                  # arreter sans supprimer
docker compose down                  # arreter et supprimer conteneurs + reseau
```
