# Branch Protection and Pre-Release Workflow Setup

This document provides step-by-step instructions for repository administrators to complete the setup of the PR retargeting and main branch validation workflows.

## Prerequisites

- Repository admin permissions
- The PR with the workflow changes has been merged to `main`

## Setup Steps

### 1. Create the `develop` Branch

The `develop` branch serves as the primary development branch where all feature work is merged before being promoted to `main`.

```bash
# Clone or update your local repository
git clone https://github.com/mattwise-42/OpenToken.git
cd OpenToken

# Ensure you're on the latest main
git checkout main
git pull origin main

# Create develop branch from main
git checkout -b develop

# Push to GitHub
git push -u origin develop
```

**Alternative**: Create the branch directly on GitHub:
1. Go to the repository on GitHub
2. Click the branch dropdown (currently showing "main")
3. Type "develop" in the search box
4. Click "Create branch: develop from main"

### 2. Configure Branch Protection for `main`

These settings ensure that only release PRs can merge to `main`.

1. Navigate to **Settings** → **Branches** in your repository
2. Click **Add rule** (or edit existing rule for `main`)
3. Enter `main` in "Branch name pattern"
4. Configure the following settings:

#### Required Settings

- ✅ **Require a pull request before merging**
  - ✅ Require approvals: 1 (or more, as preferred)
  - ✅ Dismiss stale pull request approvals when new commits are pushed

- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
  - Add the following required status checks (search for them):
    - `validate-pr-target` ← **CRITICAL** - This enforces the release branch requirement
    - `build` (from maven-build.yml)
    - `test` (from python-test.yml)
    - `interoperability-tests` (from interoperability-tests.yml)
    - `build / build` (from docker-publish.yml)
    - Any other checks you want to require

- ✅ **Require conversation resolution before merging** (recommended)

- ✅ **Do not allow bypassing the above settings** (recommended)
  - Ensures admins also follow the process

#### Optional but Recommended

- ✅ **Require linear history** - Keeps commit history clean
- ✅ **Include administrators** - Applies rules to admins too

5. Click **Create** or **Save changes**

### 3. Configure Branch Protection for `develop` (Recommended)

While not strictly required, protecting `develop` ensures code quality.

1. **Settings** → **Branches** → **Add rule**
2. Branch name pattern: `develop`
3. Configure:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
   - Add required checks (same as main, except `validate-pr-target` is not needed)

### 4. Update Default Branch (Optional)

The default branch determines which branch is shown to visitors and used for new PRs by default.

**Current Recommendation**: Keep `main` as the default branch
- Visitors see the stable release version
- The retargeting workflow will automatically redirect feature PRs to `develop`

**Alternative**: Set `develop` as default
- Developers automatically target `develop` for new PRs
- No auto-retargeting needed for most PRs
- To change: **Settings** → **Branches** → **Default branch** → Change to `develop`

### 5. Verify the Setup

Test that everything is working correctly:

#### Test 1: Feature PR Auto-Retargeting

```bash
# Create a test feature branch
git checkout develop
git pull origin develop
git checkout -b test/workflow-validation
echo "test" > test-file.txt
git add test-file.txt
git commit -m "Test workflow validation"
git push origin test/workflow-validation
```

1. Open a PR from `test/workflow-validation` to `main`
2. ✅ The `retarget-pr-to-develop` workflow should automatically:
   - Change the base branch to `develop`
   - Post a comment explaining the change
3. Close and delete the test PR/branch

#### Test 2: Release PR Validation

```bash
# Create a test release branch
git checkout develop
git pull origin develop
git checkout -b release/99.99.99
git push origin release/99.99.99
```

1. Open a PR from `release/99.99.99` to `main`
2. ✅ The `validate-pr-target` check should **pass** (green checkmark)
3. Close and delete the test PR/branch

#### Test 3: Non-Release PR Validation

```bash
# Create a test feature branch
git checkout develop
git checkout -b feature/should-fail-validation
git push origin feature/should-fail-validation
```

1. Open a PR from `feature/should-fail-validation` to `main`
2. ✅ The PR should be auto-retargeted to `develop` immediately
3. If you manually change it back to target `main`:
   - ✅ The `validate-pr-target` check should **fail** (red X)
   - ✅ The error message should explain the requirement
4. Close and delete the test PR/branch

## Workflow Behavior Summary

### For Contributors

- **Feature/Bug Fix PRs**: Target `develop` branch
  - If accidentally targeting `main`, PR will be auto-retargeted
  
- **Release PRs**: Create from `release/x.y.z` branch to `main`
  - Must follow semantic versioning in branch name
  - Required status checks must pass
  - `validate-pr-target` check enforces the branch naming

### For Maintainers

**Release Process**:
1. Ensure `develop` has all changes for the release
2. Create a release branch: `git checkout -b release/x.y.z develop`
3. Update version numbers using `bump2version`
4. Push release branch: `git push origin release/x.y.z`
5. Open PR from `release/x.y.z` to `main`
6. After PR is merged, tag the release on `main`
7. Merge `main` back to `develop` to keep them in sync

## Troubleshooting

### Issue: `validate-pr-target` check not appearing

**Solution**: 
- Ensure the workflow file is merged to `main`
- Check Actions tab for any workflow errors
- Make sure the PR is targeting `main` (the workflow only runs for PRs to main)

### Issue: Auto-retargeting not working

**Solution**:
- Verify the workflow file is merged to `main`
- Check Actions tab for any failures
- Ensure the bot has `pull-requests: write` permission (should be automatic with `GITHUB_TOKEN`)

### Issue: Can't require `validate-pr-target` as a status check

**Solution**:
- The check must run at least once before it appears in the list
- Open a test PR to `main` to trigger the workflow
- After it runs, the check will appear in the branch protection settings

### Issue: PRs being retargeted in a loop

**Solution**: The workflow has built-in loop prevention. If this occurs:
- Check the workflow logs in the Actions tab
- Ensure you're using the latest version of the workflow
- Report the issue with logs

## Support

For issues or questions:
1. Check the [GitHub Actions documentation](https://docs.github.com/en/actions)
2. Review workflow logs in the Actions tab
3. Open an issue in the repository with relevant logs

## Related Files

- `.github/workflows/retarget-pr-to-develop.yml` - Auto-retargeting logic
- `.github/workflows/validate-pr-target.yml` - Release branch validation
- `.github/pull_request_template.md` - Contributor guidance

## Automated Release Workflows

Two additional workflows automate the release process:

### Auto Version Bump

When you open a PR from a `release/*` branch to `main`, the version is automatically updated:

1. The workflow extracts the version from the branch name (e.g., `release/1.12.0` → `1.12.0`)
2. Validates the version format (must be semantic versioning: `x.y.z`)
3. Updates all version files via bump2version
4. Commits the changes to your release branch
5. Comments on the PR to confirm the update

**No manual `bump2version` command needed!**

### Auto Release Creation

When a release PR is merged to `main`, a GitHub release is automatically created:

1. Creates a git tag (e.g., `v1.12.0`)
2. Generates release notes automatically
3. Creates the GitHub release
4. Triggers Docker and Maven publish workflows
5. Creates a PR to sync `main` back to `develop`

**No manual release creation or branch syncing needed!**

### Updated Workflow

With automation, your release process becomes:

```bash
# 1. Create release branch
git checkout develop
git checkout -b release/1.12.0
git push origin release/1.12.0

# 2. Open PR to main on GitHub
# 3. Review auto-generated version changes
# 4. Approve and merge

# Done! Everything else is automated.
```

