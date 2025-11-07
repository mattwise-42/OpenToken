# Branch Protection and Release Workflows

This document provides step-by-step instructions for repository administrators and developers to set up and use the branch protection rules and automated release workflows.

## Prerequisites

- Repository admin permissions (for branch protection setup)
- Git installed locally
- The workflow files have been merged to `main`

## Branch Structure

The repository uses a three-branch strategy:

- **`main`**: Production-ready releases only (protected)
- **`develop`**: Primary development branch (protected)
- **`release/*`**: Temporary release branches created from `develop`

## Setup Steps

### 1. Create the `develop` Branch

The `develop` branch serves as the primary development branch where all feature work is merged before being promoted to `main`.

#### Option A: Command Line

```bash
git clone https://github.com/mattwise-42/OpenToken.git
cd OpenToken
git checkout main
git pull origin main
git checkout -b develop
git push -u origin develop
```

#### Option B: GitHub Web UI

1. Navigate to your repository
2. Click the branch dropdown (currently showing "main")
3. Type "develop" in the search box
4. Click "Create branch: develop from main"

### 2. Configure Branch Protection for `main`

These settings ensure that only release PRs can merge to `main` and all checks pass.

1. Go to **Settings** → **Branches**
2. Click **Add rule** (or edit existing rule for `main`)
3. Enter `main` as the branch name pattern
4. Configure these settings:

#### Required

- ✅ **Require a pull request before merging**
  - ✅ Require approvals: 1
  - ✅ Dismiss stale pull request approvals when new commits are pushed
  - ✅ Require status checks to pass before merging
    - ✅ Require branches to be up to date before merging
    - Add required status checks:
      - `build` (Maven)
      - `test` (Python)
      - `interoperability-tests`
      - `build / build` (Docker)

- ✅ **Require conversation resolution before merging**
- ✅ **Require linear history** (keeps commit history clean)
- ✅ **Do not allow bypassing the above settings** (includes admins)

3. Click **Create** or **Save changes**

### 3. Configure Branch Protection for `develop`

1. **Settings** → **Branches** → **Add rule**
2. Branch name pattern: `develop`
3. Configure:
   - ✅ Require a pull request before merging (1 approval)
   - ✅ Require status checks to pass before merging
   - ✅ Require linear history
   - ✅ Include administrators

### 4. Set Default Branch (Optional)

Keep `main` as the default branch. This shows visitors the stable release version.

- To change: **Settings** → **Branches** → **Default branch**

## Release Workflow

### For Contributors

All feature/bug fix PRs should target `develop`:

```bash
git checkout develop
git pull origin develop
git checkout -b feature/your-feature
# Make changes
git push origin feature/your-feature
# Create PR to `develop` on GitHub
```

### For Release Process

1. **Prepare Release**
   - Ensure `develop` has all changes for the release
   - Create a release branch from `develop`:
     ```bash
     git checkout develop
     git pull origin develop
     git checkout -b release/x.y.z
     git push origin release/x.y.z
     ```

2. **Create Release PR**
   - Open a PR from `release/x.y.z` to `main` on GitHub
   - The `auto-version-bump` workflow will:
     - Extract version `x.y.z` from the branch name
     - Run `bump2version` to update all version files
     - Commit changes to the release branch
     - Comment on the PR with summary

3. **Review and Merge**
   - Review the auto-bumped version changes
   - Ensure all status checks pass
   - Approve and merge the PR to `main`

4. **Post-Merge (Automated)**
   - The `auto-release` workflow will:
     - Create a git tag `vx.y.z` on the merge commit
     - Generate and create a GitHub release
     - Create a PR to sync `main` back to `develop`

## Automated Workflows

### auto-version-bump.yml

**Trigger**: PR opened/updated from `release/*` branch to `main`

**Actions**:
- Extracts version from branch name (e.g., `release/1.23.4` → `1.23.4`)
- Validates semantic versioning format (`x.y.z`)
- Runs `bump2version --new-version x.y.z patch`
- Updates:
  - `.bumpversion.cfg`
  - `lib/java/pom.xml`
  - `Dockerfile`
  - `lib/java/src/main/java/com/truveta/opentoken/Metadata.java`
  - `lib/python/setup.py`
  - `lib/python/src/main/opentoken/__init__.py`
  - `lib/python/src/main/opentoken/metadata.py`
- Commits and pushes changes to release branch
- Comments on PR with update summary

**Example**: Branch `release/1.23.4` → Automatically updates all version references to `1.23.4`

### auto-release.yml

**Trigger**: Push to `main` branch

**Actions**:
1. Extracts version from `.bumpversion.cfg`
2. Creates git tag: `vx.y.z`
3. Generates release notes automatically
4. Creates GitHub release with:
   - Title: `vx.y.z` (e.g., `v1.23.4`)
   - Body: Auto-generated release notes
5. Creates PR to merge `main` back to `develop`
   - Keeps branches in sync
   - Auto-merges if possible

## Testing the Setup

### Test 1: Verify Version Bump on Release PR

```bash
git checkout develop
git checkout -b release/1.99.99
git push origin release/1.99.99
```

1. Create PR to `main`
2. Watch the Actions tab
3. ✅ `auto-version-bump` should run and update version files
4. Clean up: Delete the branch and close the PR

### Test 2: Verify Release Creation

After PR is merged:
1. ✅ `auto-release` workflow should run
2. ✅ Check the Releases page - should see `v1.99.99`
3. ✅ Git tags should include the new tag

## Troubleshooting

### auto-version-bump not running

- Verify branch name starts with `release/`
- Check Actions tab for workflow logs
- Ensure workflow file is on `main`

### auto-release not creating release

- Check Actions tab for errors in version extraction
- Verify `.bumpversion.cfg` has valid `current_version`
- Ensure GitHub token has `contents: write` permission

### Version extraction shows garbled text

- The sed parser scans only the `[bumpversion]` section
- Check `.bumpversion.cfg` for syntax errors
- Verify no stray text in the version field

## Related Documentation

- `docs/dev-guide-development.md` - Development guide
- `docs/metadata-format.md` - Metadata JSON schema
- `.github/workflows/auto-version-bump.yml` - Version bump workflow
- `.github/workflows/auto-release.yml` - Release creation workflow

## Support

For issues:
1. Check the Actions tab for workflow logs
2. Review GitHub Actions documentation: https://docs.github.com/en/actions
3. Open an issue in the repository with relevant logs
