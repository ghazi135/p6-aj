# Fiche de vérification – Projet P6 Backend (Spring Boot)

Vérification du projet **ocr-java-angular-project-6-back-main** par rapport aux indicateurs de réussite de la fiche P6.

---

## Étape 1 – Environnement de travail

| Critère | Statut | Détail |
|--------|--------|--------|
| Les deux applications s'exécutent localement sans erreur | ⚠️ Partiel | Ce dépôt est le **backend uniquement**. L’API Spring Boot tourne en local (./gradlew bootRun) avec une base PostgreSQL (ex. docker compose pour la DB). |
| Les commandes du README fonctionnent | ✅ | build.gradle, Gradle wrapper, docker-compose pour l’app + DB. |
| Ports identifiés et disponibles | ✅ | 8080 (app), 5432 (PostgreSQL). `.env.example` documente APP_PORT et variables DB. |
| Versions des outils (Node, Java, Docker) | ✅ | Java 21 (Temurin) dans Dockerfile et CI. PostgreSQL 16-alpine en dev, postgres:13 dans .env.example. |

---

## Étape 2 – Dockerfile et Docker Compose du front-end Angular

| Critère | Statut | Détail |
|--------|--------|--------|
| (Tous les indicateurs) | ➖ N/A | Ce dépôt est le **backend**. À vérifier dans le repo front. |

---

## Étape 3 – Dockerfile et Docker Compose du back-end Spring Boot

| Critère | Statut | Détail |
|--------|--------|--------|
| Le Dockerfile compile l'application avec Gradle | ✅ | Stage 1 : `eclipse-temurin:21-jdk`, `./gradlew bootJar --no-daemon -x test`. |
| L'image finale utilise une JRE (pas un JDK complet) | ✅ | Stage 2 : `eclipse-temurin:21-jre`, seul le JAR est copié. |
| Le docker-compose contient deux services (application + PostgreSQL) | ✅ | `app` (Spring Boot) et `db` (PostgreSQL). Service `init-db` pour l’init des scripts SQL. |
| Les variables d'environnement de connexion à la base sont configurées | ✅ | `SPRING_DATASOURCE_URL`, `USERNAME`, `PASSWORD` pour l’app ; `POSTGRES_*` pour `db`. Fichier `.env.example` fourni. |
| Un volume est défini pour la persistance PostgreSQL | ✅ | `volumes: postgres_data:/var/lib/postgresql/data` dans `docker-compose.yml` et `docker-compose.dev.yml`. |
| Un health check est configuré pour orchestrer le démarrage | ✅ | `db` : `healthcheck` avec `pg_isready`. `init-db` dépend de `db` avec `condition: service_healthy`. `app` dépend de `init-db` avec `condition: service_completed_successfully`. |
| L'API répond sur http://localhost:8080 après docker compose up -d | ✅ | Port mappé `${APP_PORT:-8080}:8080`. Avec `.env` (APP_PORT=8080) ou défaut : `http://localhost:8080`. |

---

## Étape 1 (tests) – Script d’exécution des tests unifié

| Critère | Statut | Détail |
|--------|--------|--------|
| Le script détecte automatiquement le type de projet | ⚠️ Partiel | Même principe que le front : type passé en argument `./run-tests.sh springboot`. Variable `APP_TYPE` en CI (défaut `springboot`). |
| Les tests s'exécutent correctement | ✅ | `./gradlew test` (JUnit 5), sortie JUnit XML dans `build/test-results/test/`, copiée dans `test-results/`. |
| Un rapport JUnit XML est généré | ✅ | Gradle `useJUnitPlatform()`, rapports dans `build/test-results/test/` puis copiés dans `test-results/`. |
| Le rapport est placé dans test-results/ | ✅ | `run_spring_boot_tests` copie `build/test-results/test/*` vers `${RESULTS_DIR}` (test-results). |
| Code de sortie approprié (0 = succès, autre = échec) | ✅ | `exit 0` / `exit 1` dans `run-tests.sh`. |
| Les artefacts de tests précédents sont nettoyés avant l'exécution | ✅ | `clean_test_artifacts()` en début de run. |

---

## Étape 2 (CI) – Pipeline GitHub Actions

| Critère | Statut | Détail |
|--------|--------|--------|
| .github/workflows/ci.yml contient un stage test | ✅ | Job `test` : checkout, JDK 21, `./run-tests.sh`, rapport JUnit, upload artefact. |
| Le job de test s'adapte aux deux projets | ⚠️ Partiel | Backend seul ici : `APP_TYPE` (vars) défaut `springboot`. Pas de choix Angular dans ce repo. |
| Le rapport de test est intégré au pipeline | ✅ | `dorny/test-reporter` (JUnit) + `actions/upload-artifact` (test-results). |
| Les dépendances sont mises en cache | ✅ | `actions/setup-java` avec `cache: 'gradle'`. |
| Le pipeline se déclenche sur push/MR | ✅ | `on: push`, `pull_request` (toutes branches). |

---

## Étape 3 – Stage build

| Critère | Statut | Détail |
|--------|--------|--------|
| Un stage build est ajouté | ✅ | Job `build` (après `test`). |
| Le job construit l'image Docker | ✅ | `docker/build-push-action`, build sans push, image sauvegardée en artefact. |
| L'image est poussée vers un registry | ✅ | Job `publish` : Docker Hub (DOCKERHUB_USERNAME / DOCKERHUB_TOKEN). |
| L'image est taguée avec le SHA et le nom de la branche | ✅ | SHA ✅. Tag par branche ajouté dans le job `publish` (voir correction ci-dessous). |
| Le pipeline fonctionne sur l’application | ✅ | Un seul type d’app (Spring Boot) dans ce repo. |

---

## Étape 4 – semantic-release

| Critère | Statut | Détail |
|--------|--------|--------|
| semantic-release installé et configuré pour GitHub | ✅ | Job `release` avec `cycjimmy/semantic-release-action`, plugins commit-analyzer, release-notes, exec, git, github. |
| Un stage release dans le pipeline | ✅ | Job `release` (dépend de `build`), sur push `master`. |
| Convention Conventional Commits | ✅ | Gérée par la config semantic-release. |
| Releases GitHub avec changelog | ✅ | Plugin GitHub. |
| Images Docker taguées avec la version sémantique | ✅ | Job `publish` : tags avec `new_release_version` et `v${version}`. |
| Déclenchement du job de release selon la stratégie | ✅ | Automatique sur push vers `master`. |
| Version synchronisée dans les fichiers du projet | ✅ | Plugin `@semantic-release/exec` + `@semantic-release/git` (à confirmer dans release.config.js pour ce repo). |

---

## Synthèse backend

- **Étape 3 (Docker Spring Boot)** : Tous les critères sont remplis (Gradle, JRE, 2 services app+PostgreSQL, variables d’env, volume, healthcheck, API sur 8080).
- **Tests** : Script unifié, JUnit XML dans `test-results/`, nettoyage, code de sortie.
- **CI** : Stage test (avec rapport + cache), stage build, Sonar dans un job dédié, release + publish avec tags (SHA, latest, version sémantique).
- **Correction suggérée** : Ajouter le tag par **nom de branche** sur l’image dans le job `publish` pour alignement avec la fiche (SHA + branche + latest + version).
