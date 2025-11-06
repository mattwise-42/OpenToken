## Description
<!-- Provide a brief description of your changes -->

## Type of Change
<!-- Mark the relevant option with an 'x' -->
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Release PR (from `release/*` branch to `main`)

## Target Branch Guidelines

### 🎯 Standard Development Work → `develop`
Most PRs should target the **`develop`** branch:
- New features
- Bug fixes
- Documentation updates
- Refactoring
- Test improvements

**If you opened this PR against `main` by mistake**, it will be automatically retargeted to `develop`.

### 🚀 Release PRs → `main`
PRs to **`main`** are restricted to release branches only:
- Must come from a `release/x.y.z` branch (e.g., `release/1.2.3`)
- Used only for promoting tested code from `develop` to `main`
- Triggers production releases

**Important:** If your PR to `main` is not from a `release/*` branch, the `validate-pr-target` status check will fail, blocking the merge.

## Checklist
<!-- Mark completed items with an 'x' -->
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] I have updated the version number using `bump2version` (if applicable)
- [ ] I am targeting the correct branch (`develop` for development, `main` only for releases)

## Testing
<!-- Describe the tests you ran and how to reproduce them -->

## Additional Notes
<!-- Any additional information that reviewers should know -->
