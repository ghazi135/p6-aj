# Pipeline CI/CD (backend – Spring Boot)

Ce dépôt utilise un workflow GitHub Actions **générique** (`.github/workflows/ci.yml`) conçu pour fonctionner aussi pour un projet Angular avec les mêmes étapes (test, build, release), en changeant uniquement des variables.

## Jobs du pipeline

| Job     | Déclenchement | Rôle |
|---------|----------------|------|
| **test**  | À chaque push/PR | Exécute `run-tests.sh` selon `APP_TYPE`, publie le rapport JUnit et les artefacts. |
| **sonar** | Après test, si `SONAR_TOKEN` est défini | Analyse SonarQube/SonarCloud. Voir [SONARQUBE.md](SONARQUBE.md). |
| **build** | Après test | Construit l’image Docker (sans push dans ce job). |
| **release** | Push sur `main` uniquement | semantic-release (Conventional Commits) → version + release GitHub. |
| **publish** | Push sur `main`, après build + release | Pousse l’image vers Docker Hub avec les tags `sha`, `latest` et version sémantique. |

## Variables utilisées (backend)

- **APP_TYPE** : `springboot` (pour ce dépôt).
- **SONAR_*** : optionnel, voir [SONARQUBE.md](SONARQUBE.md).
- Secrets : **GITHUB_TOKEN** (fourni par défaut), **DOCKERHUB_USERNAME**, **DOCKERHUB_TOKEN**, **SONAR_TOKEN** (optionnel).

## Réutilisation pour l’application Angular

Le même fichier `.github/workflows/ci.yml` peut être utilisé dans le dépôt front-end en définissant :

- **APP_TYPE** : `angular`
- **run-tests.sh** : présent dans le dépôt et gérant le cas `angular` (Karma/Jasmine, rapport JUnit).
- **Dockerfile** : build multi-stage Angular + Nginx.
- **build** : construit l’image du front (contexte et Dockerfile du repo Angular).

Les différences entre les deux projets sont donc gérées par **APP_TYPE**, le **Dockerfile** et le **contexte de build** de chaque dépôt, sans dupliquer la logique des stages (test → build → release → publish).
