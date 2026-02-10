# Intégration SonarQube / SonarCloud

Ce document décrit comment connecter ce projet à **SonarQube** (serveur) ou **SonarCloud** (SaaS) pour l’analyse de qualité et de sécurité du code.

## 1. Créer le projet côté Sonar

- **SonarCloud** : [sonarcloud.io](https://sonarcloud.io) → Add new project → importer le dépôt GitHub et noter la **clé du projet** (ex. `vbuyakov_ocr-java-angular-project-6-back`).
- **SonarQube** : créer un projet sur votre serveur et générer un **token** (User → Security → Generate Tokens). Noter l’**URL du serveur** et la **clé du projet**.

## 2. Configurer les secrets GitHub

Dans **Settings → Secrets and variables → Actions** du dépôt :

| Secret        | Description |
|---------------|-------------|
| `SONAR_TOKEN` | Token SonarCloud ou SonarQube (obligatoire pour lancer l’analyse en CI). |.

**Variables** (Settings → Variables) selon votre cas :

| Variable             | SonarCloud | SonarQube serveur |
|----------------------|------------|--------------------|
| `SONAR_PROJECT_KEY`  | Clé affichée dans SonarCloud (ex. `vbuyakov_ocr-java-angular-project-6-back`) | Clé du projet |
| `SONAR_ORGANIZATION` | Votre organisation SonarCloud (souvent = GitHub org/user) | — |
| `SONAR_HOST_URL`     | Ne pas définir (défaut = `https://sonarcloud.io`) | `https://votre-sonar.example.com` |

## 3. Lien avec le pipeline CI

Le workflow `.github/workflows/ci.yml` contient un job **sonar** (optionnel) qui :

- s’exécute après les tests ;
- ne tourne que si le secret `SONAR_TOKEN` est défini ;
- lance l’analyse Gradle et envoie les résultats vers SonarCloud ou SonarQube.

Une fois `SONAR_TOKEN` (et éventuellement `SONAR_HOST_URL`) configurés, chaque push/PR déclenchera l’analyse et vous verrez le **Quality Gate** et les **issues** dans l’onglet **Checks** de la PR ou sur le tableau de bord Sonar.

## 4. Activer / désactiver Sonar

- **Activer** : ajoutez le secret `SONAR_TOKEN` (et la variable `SONAR_HOST_URL` si vous utilisez un serveur SonarQube).
- **Désactiver** : supprimez le secret `SONAR_TOKEN` (le job sera ignoré grâce à `if: secrets.SONAR_TOKEN != ''`).

## 5. Dépannage : "Project not found"

Si le job SonarQube échoue avec *"Project not found. Please check the 'sonar.projectKey' and 'sonar.organization'..."* :

1. **Créer le projet sur SonarCloud** (obligatoire avant la première analyse)  
   - Aller sur [sonarcloud.io](https://sonarcloud.io) → **Add new project**.  
   - Choisir l’organisation (ex. `ghazi135`) → **Import** le dépôt GitHub `p6-aj`.  
   - Noter la **clé exacte** affichée (ex. `ghazi135_p6-aj`) et la mettre dans `sonar-project.properties` :  
     `sonar.projectKey=<clé affichée>` et `sonar.organization=ghazi135`.

2. **Vérifier le token SonarCloud**  
   - SonarCloud → **My Account** → **Security** → **Generate Tokens** (nom libre, type *User Token*).  
   - Le token doit avoir le droit d’analyser les projets de l’organisation.

3. **Vérifier le secret GitHub**  
   - Dépôt GitHub → **Settings** → **Secrets and variables** → **Actions**.  
   - Un secret **`SONAR_TOKEN`** doit exister et contenir le token SonarCloud (sans espace, sans guillemets).

4. **Clé = celle de SonarCloud**  
   - La valeur de `sonar.projectKey` dans `sonar-project.properties` doit être **strictement** celle indiquée sur la page du projet dans SonarCloud (onglet *Project Settings* → *Key*).

## 6. Dépannage : "CI analysis while Automatic Analysis is enabled"

Si l’analyse échoue avec *"You are running CI analysis while Automatic Analysis is enabled. Please consider disabling one or the other"* :

- **Désactiver l’analyse automatique** (recommandé quand vous utilisez GitHub Actions) :  
  - SonarCloud → projet **p6-aj** → **Administration** → **Analysis Method**.  
  - Choisir **With GitHub Actions** (ou **CI-based**) et enregistrer, ou désactiver **Automatic Analysis** selon les options affichées.

## 7. Ressources

- [SonarCloud – GitHub Actions](https://docs.sonarsource.com/sonarcloud/advanced-setup/ci-based-analysis/github-actions-for-sonarcloud/)
- [SonarScanner for Gradle](https://docs.sonarsource.com/sonarqube-cloud/advanced-setup/ci-based-analysis/sonarscanner-for-gradle)
- [SonarQube – GitHub Integration](https://docs.sonarsource.com/sonarqube-server/latest/devops-platform-integration/github-integration/)
