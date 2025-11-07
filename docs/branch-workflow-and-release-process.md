# Branch Workflow and Release Process

This document explains the branch strategy and automated workflows for the OpenToken repository.

## Branch Structure

```
main (stable, production-ready)
  ↑
  | (only from release/* branches)
  |
release/x.y.z (version bump, final testing)
  ↑
  | (merge when ready for release)
  |
develop (integration, tested features)
  ↑
  | (all feature/bug PRs go here)
  |
feature/*, bugfix/*, etc. (development work)
```

## Workflow Diagrams

### Standard Feature Development Flow

```mermaid
graph TB
    A[Developer creates feature branch] --> B[Open PR to develop]
    B --> C{CI Checks Pass?}
    C -->|Yes| D[Code Review]
    C -->|No| E[Fix Issues]
    E --> B
    D -->|Approved| F[Merge to develop]
    D -->|Changes Requested| E
    F --> G[Feature available in develop]
```

### Release Process Flow (Automated)

```mermaid
graph TB
    A[develop ready for release] --> B[Create release/x.y.z branch]
    B --> C[Push to origin]
    C --> D[Open PR to main]
    D --> E["🤖 auto-version-bump workflow runs"]
    E --> F["Updates all version files<br/>Commits to release branch"]
    F --> G{All CI checks pass?}
    G -->|No| H[Fix Issues]
    H --> D
    G -->|Yes| I[Code Review & Merge to main]
    I --> J["🤖 auto-release workflow runs"]
    J --> K["Creates git tag vx.y.z<br/>Creates GitHub release<br/>Creates sync PR: main → develop"]
    K --> L[Release Published]
```

### PR Auto-Retargeting Flow

```mermaid
graph TB
    A[Developer opens PR to main] --> B{From release/* branch?}
    B -->|Yes| C[✅ PR allowed to proceed]
    B -->|No| D[PR auto-retargeted to develop]
    D --> E[Comment posted explaining change]
    E --> F[Developer continues with develop PR]
```

## Branch Descriptions

### `main`
- **Purpose**: Production-ready, stable releases only
- **Protection**: 
  - Required CI checks must pass
  - Code review required
  - Only accepts PRs from `release/*` branches
- **Merges from**: `release/*` branches only
- **Merges to**: `develop` (automatic sync after release)
- **Tagging**: Releases are automatically tagged `vx.y.z`

### `develop`
- **Purpose**: Integration branch for tested features
- **Protection** (recommended):
  - All CI checks must pass
  - Code review required
- **Merges from**: `feature/*`, `bugfix/*`, etc.
- **Merges to**: `release/*` branches (for release preparation)

### `release/*`
- **Purpose**: Final preparation and version bump before production release
- **Naming**: `release/x.y.z` (semantic versioning)
- **Lifecycle**:
  1. Branch from `develop`
  2. Push to origin
  3. Open PR to `main`
  4. `auto-version-bump` workflow runs automatically
  5. Review and merge PR
  6. `auto-release` workflow runs automatically
  7. Delete branch after release
- **Merges from**: `develop`
- **Merges to**: `main` only

### `feature/*`, `bugfix/*`, etc.
- **Purpose**: Development work
- **Lifecycle**:
  1. Branch from `develop`
  2. Develop and test locally
  3. Open PR to `develop`
  4. After merge, delete branch
- **Merges from**: `develop`
- **Merges to**: `develop`

## Automated Workflows

### auto-version-bump.yml

**Trigger**: PR opened/updated from `release/*` branch to `main`

**Actions**:
1. Extracts version from branch name (e.g., `release/1.23.4` → `1.23.4`)
2. Validates semantic versioning format (`x.y.z`)
3. Compares with current version in `.bumpversion.cfg`
4. If update needed:
   - Runs `bump2version --new-version x.y.z patch`
   - Updates all version files:
     - `.bumpversion.cfg`
     - `lib/java/pom.xml`
     - `Dockerfile`
     - `lib/java/src/main/java/com/truveta/opentoken/Metadata.java`
     - `lib/python/setup.py`
     - `lib/python/src/main/opentoken/__init__.py`
     - `lib/python/src/main/opentoken/metadata.py`
   - Commits changes to release branch
   - Comments on PR with update summary
5. If already up-to-date:
   - Posts comment confirming no changes needed

### auto-release.yml

**Trigger**: PR merged to `main` from `release/*` branch

**Actions**:
1. Extracts version from `.bumpversion.cfg`
2. Checks if release/tag already exist
3. If not existing:
   - Creates git tag `vx.y.z` at current commit
   - Generates release notes automatically
   - Creates GitHub release with:
     - Title: `vx.y.z` (e.g., `v1.23.4`)
     - Body: Auto-generated release notes
   - Creates PR to merge `main` back to `develop` (keeps branches in sync)
   - Attempts auto-merge of sync PR

## Release Process Examples

### Example 1: Making a Release (Manual Version)

```bash
# Ensure develop is up to date
git checkout develop
git pull origin develop

# Create release branch with version number in name
git checkout -b release/1.5.0
git push origin release/1.5.0

# On GitHub: Open PR from release/1.5.0 to main
# 🤖 auto-version-bump workflow runs automatically:
#    - Detects version 1.5.0 from branch name
#    - Updates all version files
#    - Commits changes to release/1.5.0
#    - Adds comment confirming update

# After approval and all CI passes, merge PR to main
# 🤖 auto-release workflow runs automatically:
#    - Creates tag v1.5.0
#    - Creates GitHub release with auto-generated notes
#    - Creates PR: main → develop (sync)
#    - Attempts auto-merge of sync PR

# Done! No manual version bumping or release creation needed
```

**Automatic:**
- ✅ Version files updated based on branch name
- ✅ Git tag created on main
- ✅ GitHub release created with notes
- ✅ Docker and Maven packages published (via their workflows)
- ✅ Main synced back to develop

**Manual:**
- Create the `release/x.y.z` branch
- Open the PR to main
- Review and approve the PR
- Merge the PR

### Example 2: Adding a New Feature

```bash
# Start from develop
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/new-token-type

# Make changes, commit
git add .
git commit -m "Add new token type T6"

# Push and open PR to develop
git push origin feature/new-token-type
# Open PR on GitHub: feature/new-token-type → develop
```

### Example 3: Accidental PR to Main

```bash
# Developer mistakenly opens PR: feature/my-work → main
# The PR is immediately auto-retargeted to develop
# Comment posted explaining the change
# Developer continues with the PR targeting develop
```

## FAQ

**Q: Why can't I open a PR to `main` from my feature branch?**  
A: Feature work should go to `develop` first. Only release branches can merge to `main`. This ensures `main` is always stable and production-ready.

**Q: My PR was auto-retargeted. Is this normal?**  
A: Yes! If you opened a PR to `main` from a non-release branch, it's automatically retargeted to `develop`. This is by design.

**Q: Do I need to manually bump versions?**  
A: No! The `auto-version-bump` workflow extracts the version from your `release/x.y.z` branch name and updates all files automatically.

**Q: How do I make a hotfix?**  
A: Hotfixes follow the same process as releases:
1. Create a `release/hotfix-x.y.z` branch from `main` (or `develop` depending on urgency)
2. Push the branch to GitHub
3. Open PR to `main`
4. The workflows handle the rest

**Q: Can I bypass branch protection?**  
A: Repository admins can override branch protection, but it's strongly discouraged. Follow the release process to maintain code quality and stability.

## Related Documentation

- [Branch Protection and Release Workflows](./branch-protection-and-release-workflows.md) - Admin setup instructions for branch protection
- [Development Guide](./dev-guide-development.md) - Development environment setup and language-specific build instructions
- Workflow files:
  - `.github/workflows/auto-version-bump.yml`
  - `.github/workflows/auto-release.yml`
