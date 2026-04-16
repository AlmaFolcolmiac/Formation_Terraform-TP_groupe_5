# Starter kit — TP05 Nextcloud sur AWS

Point de départ de votre projet d'équipe. L'arborescence, les **interfaces de modules** (variables + outputs) et les providers sont déjà écrits. **Vous n'avez qu'à remplir les corps des modules**.

🔷 **Objectif** : gagner ~1h de setup pour vous concentrer sur le code métier.

---

## Comment démarrer

### 1. Copier le starter dans votre dossier de travail

```bash
# Le starter vit dans le depot formateur. Copiez-le dans votre workspace.
cp -r /chemin/formation/corriges/jour5/tp05-starter ~/formation-terraform/jour5/tp05-nextcloud
cd ~/formation-terraform/jour5/tp05-nextcloud
```

### 2. Initialiser Git

```bash
git init
git add .
git commit -m "chore: import starter kit TP05"
```

### 3. Adapter le nom de bucket state

Ouvrez `envs/dev/backend.tf` et remplacez `TEAM` par un identifiant unique (ex: `equipe1`, `equipe2`, ...).

Le nom S3 doit être unique **au niveau mondial** (tous comptes AWS confondus) — d'où le suffixe.

### 4. Lancer le bootstrap (une seule fois, par un seul membre de l'équipe)

```bash
export AWS_PROFILE=formation
export USERNAME=equipe1    # doit matcher le TEAM que vous avez mis dans backend.tf

chmod +x bootstrap/create-state-bucket.sh
./bootstrap/create-state-bucket.sh
```

Le script crée la KMS CMK + le bucket S3 qui stockera les `terraform.tfstate`.

### 5. Chacun prend son rôle

```bash
# Chaque membre cree sa branche de rôle
git checkout -b role-2-network        # rôle 2 Network
# ou
git checkout -b role-5-security       # rôle 5 Security
```

Référez-vous à la fiche de votre rôle :

- [role-1-platform.md](../../cours/jour5/tp05-team-nextcloud/role-1-platform.md)
- [role-2-network.md](../../cours/jour5/tp05-team-nextcloud/role-2-network.md)
- [role-3-compute.md](../../cours/jour5/tp05-team-nextcloud/role-3-compute.md)
- [role-4-data.md](../../cours/jour5/tp05-team-nextcloud/role-4-data.md)
- [role-5-security.md](../../cours/jour5/tp05-team-nextcloud/role-5-security.md)

### 6. Coder son module (sprint 1)

Chaque rôle ouvre les fichiers `.tf` de son module. Ils contiennent tous :

- Un en-tête expliquant **quelles ressources déclarer**
- Des blocs `# TODO(role-N)` avec le squelette à compléter
- Des extraits d'exemple en commentaire pour ne pas chercher la syntaxe

**Les fichiers `variables.tf`, `outputs.tf` et `versions.tf` sont déjà écrits** — ne pas les modifier (ce sont les **contrats d'interface** figés au kick-off).

```bash
# Valider au fur et a mesure
cd modules/networking      # ou security, data, compute
terraform init -backend=false
terraform validate
terraform fmt
```

### 7. Intégration (sprint 2)

Le Rôle 1 (Platform Lead) pilote :

```bash
cd envs/dev
terraform init
terraform plan    # doit afficher Plan: ~70 to add
terraform apply
```

---

## Arborescence fournie

```text
tp05-starter/
├── README.md                              # Ce fichier
├── .gitignore                             # Exclure .terraform/, *.tfstate, *.tfvars
│
├── bootstrap/
│   └── create-state-bucket.sh             # 🟢 PRÊT A EXÉCUTER
│
├── modules/
│   ├── networking/                        # 🟡 A COMPLÉTER — Rôle 2
│   │   ├── versions.tf                    # 🟢 écrit
│   │   ├── variables.tf                   # 🟢 écrit (interface figée)
│   │   ├── outputs.tf                     # 🟢 écrit (interface figée)
│   │   ├── locals.tf                      # 🟢 écrit (cidrsubnet helpers)
│   │   ├── main.tf                        # 🟡 squelette + TODO
│   │   └── README.md                      # 🟢 écrit
│   │
│   ├── security/                          # 🟡 A COMPLÉTER — Rôle 5
│   │   ├── versions.tf                    # 🟢 écrit
│   │   ├── variables.tf                   # 🟢 écrit (interface figée)
│   │   ├── outputs.tf                     # 🟢 écrit (interface figée)
│   │   ├── main.tf                        # 🟡 squelette + TODO (data sources)
│   │   ├── kms.tf                         # 🟡 squelette + TODO
│   │   ├── sg.tf                          # 🟡 squelette + TODO
│   │   ├── iam.tf                         # 🟡 squelette + TODO
│   │   ├── secrets.tf                     # 🟡 squelette + TODO
│   │   └── README.md                      # 🟢 écrit
│   │
│   ├── data/                              # 🟡 A COMPLÉTER — Rôle 4
│   │   ├── versions.tf                    # 🟢 écrit
│   │   ├── variables.tf                   # 🟢 écrit (interface figée)
│   │   ├── outputs.tf                     # 🟢 écrit (interface figée)
│   │   ├── main.tf                        # 🟡 squelette (data sources)
│   │   ├── rds.tf                         # 🟡 squelette + TODO
│   │   ├── s3.tf                          # 🟡 squelette + TODO
│   │   └── README.md                      # 🟢 écrit
│   │
│   └── compute/                           # 🟡 A COMPLÉTER — Rôle 3
│       ├── versions.tf                    # 🟢 écrit
│       ├── variables.tf                   # 🟢 écrit (interface figée)
│       ├── outputs.tf                     # 🟢 écrit (interface figée)
│       ├── locals.tf                      # 🟢 écrit
│       ├── main.tf                        # 🟡 squelette (AMI + TLS cert)
│       ├── alb.tf                         # 🟡 squelette + TODO
│       ├── asg.tf                         # 🟡 squelette + TODO
│       ├── templates/
│       │   └── nextcloud-user-data.sh.tftpl  # 🟡 squelette + TODO
│       └── README.md                      # 🟢 écrit
│
├── envs/
│   └── dev/
│       ├── backend.tf                     # 🟡 A ADAPTER (nom bucket)
│       ├── providers.tf                   # 🟢 écrit
│       ├── variables.tf                   # 🟢 écrit
│       ├── outputs.tf                     # 🟢 écrit
│       ├── main.tf                        # 🟡 A COMPLÉTER — Rôle 1 (4 modules)
│       └── terraform.tfvars.example       # 🟢 écrit
│
└── docs/
    ├── RENDU.md                           # 🟡 A REMPLIR (rendu noté)
    └── screenshots/                       # 🟡 5 captures obligatoires à déposer
        └── .gitkeep
```

**Légende** :

- 🟢 écrit = fichier prêt, ne pas modifier (sauf backend.tf)
- 🟡 à compléter = contient un squelette et des TODO à remplir

---

## Ce qui est déjà prêt pour vous

### Providers configurés

- AWS `~> 5.0`
- TLS `~> 4.0` (pour le cert self-signed)
- Random `~> 3.6` (pour les mots de passe)
- `default_tags` dans `envs/dev/providers.tf` (Project, Environment, ManagedBy, Team)

### Backend S3 préconfiguré

- Chiffrement KMS avec l'alias créé par le bootstrap
- Locking natif S3 (`use_lockfile = true`, TF ≥ 1.10)
- Vous adaptez juste le nom du bucket après bootstrap.

### Interfaces figées

Les `variables.tf` et `outputs.tf` de chaque module contiennent **exactement** les inputs et outputs définis dans le doc maître. Les rôles se parlent via ces interfaces. **Ne les modifiez pas sans PR** validée par l'équipe.

### Helpers

- `modules/networking/locals.tf` : calcul des 3 maps AZ→CIDR via `cidrsubnet()` (offsets +1/+11/+21)
- `modules/compute/locals.tf` : `name_prefix`
- `bootstrap/create-state-bucket.sh` : KMS CMK + bucket S3 sécurisé, idempotent

---

## Commandes utiles

```bash
# Formatter tout le code (fonctionne meme sur starter vide)
terraform fmt -recursive

# Verifier que les providers sont OK (fonctionne meme sur starter vide)
cd modules/networking && terraform init -backend=false

# Valider un module (echoue sur starter vide — normal, voir ci-dessous)
cd modules/networking && terraform validate

# Valider l environnement complet
cd envs/dev && terraform init && terraform validate

# Plan complet
cd envs/dev && terraform plan     # objectif : Plan: ~70 to add

# Destroy (obligatoire en fin de TP)
cd envs/dev && terraform destroy
```

🟡 **Normal au démarrage** : `terraform validate` échoue sur un module **vide** parce que `outputs.tf` référence des ressources pas encore déclarées (ex: `aws_vpc.main.id`). **C'est attendu** — au fur et à mesure que vous écrivez les ressources, validate passe.

Pour vérifier que votre **setup est bon** sans écrire de ressources :

```bash
cd modules/networking
terraform init -backend=false    # doit afficher "Terraform has been successfully initialized!"
terraform fmt -check             # doit retourner rien
```

Quand vous aurez écrit les ressources, `terraform validate` passera — et vous saurez que votre code est syntaxiquement correct.

---

## Livraison du TP

1. Remplissez `docs/RENDU.md`
2. Déposez vos 5 screenshots dans `docs/screenshots/`
3. `terraform destroy` dans `envs/dev/`
4. Supprimez les artefacts : `find . -name ".terraform" -type d -exec rm -rf {} +` et `find . -name "terraform.tfstate*" -delete`
5. Zippez : `cd .. && zip -r tp05-nextcloud-equipe1.zip tp05-nextcloud/`

Voir le [template de rendu détaillé](../../cours/jour5/tp05-team-nextcloud/template-rendu.md) et le [barème](../../cours/jour5/tp05-team-nextcloud/bareme-formateur.md) pour les critères de notation.

**Bon TP.**
