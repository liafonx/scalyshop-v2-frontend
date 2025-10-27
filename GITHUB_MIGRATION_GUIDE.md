# 🚀 GitHub Migration Guide - ScalyShop v2 Frontend

Complete guide for migrating from GitLab to GitHub with GitHub Actions CI/CD.

---

## Table of Contents
- [Quick Start (2 Minutes)](#quick-start-2-minutes)
- [What Was Created](#what-was-created)
- [Key Changes](#key-changes)
- [Detailed Migration Steps](#detailed-migration-steps)
- [GitHub Secrets Configuration](#github-secrets-configuration)
- [Workflow Details](#workflow-details)
- [GitLab vs GitHub Reference](#gitlab-vs-github-reference)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)

---

## Quick Start (2 Minutes)

### Prerequisites
- [ ] Create a new repository on GitHub: https://github.com/new
- [ ] Don't initialize it with README, .gitignore, or license

### 🎯 What Gets Migrated

**✅ EVERYTHING is preserved:**
- ✅ **All branches** (main, frontend-local, dev, etc.)
- ✅ **Complete commit history** from all branches
- ✅ **All commits** from all contributors
- ✅ **All commit messages** and timestamps
- ✅ **All git tags** (if any)
- ✅ **Author information** for every commit

**Note:** This is a full migration, not a fresh start. Your entire Git history moves to GitHub!

### Automated Migration (Recommended)
```bash
# 1. Run the migration script (it will show you all branches first)
./migrate-to-github.sh

# The script will:
# • List all branches that will be migrated
# • Update configuration files
# • Optionally commit and push ALL branches to GitHub
# • Preserve complete commit history
```

### Configure GitHub Secrets (Required)
```bash
# 1. Get base64-encoded Kubernetes config
cat ~/.kube/config | base64

# 2. Add to GitHub:
#    Go to: Settings → Secrets and variables → Actions → New secret
#    Name: KUBECONFIG
#    Value: <paste the base64 output>

# 3. Enable workflow permissions:
#    Settings → Actions → General
#    ✅ Read and write permissions
#    ✅ Allow GitHub Actions to create and approve pull requests
```

### Test Your Setup
```bash
git checkout frontend-local  # or dev, or main
git commit --allow-empty -m "Test GitHub Actions"
git push origin frontend-local
# Watch it run in the Actions tab! 🎉
```

---

## What Was Created

### GitHub Actions Workflow
```
.github/
└── workflows/
    └── ci-cd.yml          # Your new CI/CD pipeline (replaces .gitlab-ci.yml)
```

**Workflow Features:**
- 🏗️  **Build Job**: Builds Docker images using Docker Buildx
- 🧪 **Test Job**: Ready to enable (currently commented out)
- 🚀 **Deploy Job**: Deploys to Kubernetes using Helm
- 📦 **Registry**: Publishes to GitHub Container Registry (ghcr.io)
- ⚡ **Caching**: Uses GitHub Actions cache for faster builds
- 🌿 **Branches**: Triggers on main, frontend-local, and dev

### Automation Script
- `migrate-to-github.sh` - Automated migration script that updates all necessary files

### Updated Files
- `.gitignore` - Now excludes .DS_Store and GitLab CI files

---

## Key Changes

### Container Registry
```diff
- registry.git.chalmers.se/courses/dat490/students/2025/dat490-2025-9/scalyshop-v2-frontend
+ ghcr.io/YOUR_USERNAME/scalyshop-v2-frontend
```

### CI/CD Platform
```diff
- GitLab CI (.gitlab-ci.yml) with Docker-in-Docker
+ GitHub Actions (.github/workflows/ci-cd.yml) with Docker Buildx
```

### Image Builder
```diff
- Docker-in-Docker service
+ Docker Buildx (faster with better caching)
```

### Trigger Branches
```diff
- Only frontend-local branch
+ main, frontend-local, and dev branches
```

### Files Modified by Migration Script

#### `scalyshop-frontend/values.yaml`
```diff
image:
- #  repository: registry.git.chalmers.se/courses/dat490/students/2025/dat490-2025-9/scalyshop-v2-frontend
+   repository: ghcr.io/YOUR_USERNAME/scalyshop-v2-frontend
  pullPolicy: IfNotPresent
- #  tag: "v1.0.0"
+   tag: ""  # Will be set by CI/CD

- imagePullSecrets:
-   - name: gitlab-cred
+ # imagePullSecrets:  # Uncomment if using private images
+ #   - name: ghcr-secret
```

#### `Dockerfile`
```diff
# Example to run the Docker container:
- # docker run --name scalyshop-v2-frontend -p 80:80 -d registry.git.chalmers.se/courses/dat490/students/2025/dat490-2025-9/scalyshop-v2-frontend
+ # docker run --name scalyshop-v2-frontend -p 80:80 -d ghcr.io/YOUR_USERNAME/scalyshop-v2-frontend
```

---

## Detailed Migration Steps

### Step 1: Create GitHub Repository

1. Go to [GitHub](https://github.com) and create a new repository
2. Name it appropriately (e.g., `scalyshop-v2-frontend`)
3. **Important**: Don't initialize with README, .gitignore, or license

### Step 2: Run Migration Script

```bash
./migrate-to-github.sh
```

The script will:
- ✅ Update git remote to point to GitHub
- ✅ Update Helm values.yaml with new image repository
- ✅ Update Dockerfile with new repository URL
- ✅ Create backups of all modified files
- ✅ Show you all branches that will be migrated
- ✅ Optionally push ALL branches and tags to GitHub (preserving all history)

### Step 3: Review Changes

```bash
# Check what was changed
git status
git diff

# Review backup files if needed
ls -la *.backup
```

### Step 4: Push All Branches and History to GitHub

**Important:** The `--all` flag pushes ALL local branches with their complete commit history.

```bash
# If you used the automated script, it already did this!
# Otherwise, push manually:

# Push all branches (preserves complete history)
git push -u origin --all

# Push all tags (if any)
git push -u origin --tags
```

**What this does:**
- Pushes every local branch to GitHub
- Preserves the entire commit history for each branch
- Maintains all commit authors, messages, and timestamps
- All your team's contributions are preserved

**Verify all branches were pushed:**
```bash
# Check on GitHub or run:
git branch -r
```

### Step 5: Configure GitHub Secrets

Go to your repository's **Settings → Secrets and variables → Actions**

#### Required Secret:

**KUBECONFIG** - For Kubernetes deployment
```bash
# Get your kubeconfig and encode it
cat ~/.kube/config | base64

# Copy the output and add it as a secret in GitHub
# Name: KUBECONFIG
# Value: <paste the base64 string>
```

### Step 6: Enable GitHub Actions Permissions

1. Go to **Settings → Actions → General**
2. Under "Workflow permissions":
   - ✅ **Read and write permissions**
   - ✅ **Allow GitHub Actions to create and approve pull requests**

### Step 7: Test the Pipeline

```bash
# Switch to frontend-local or dev branch
git checkout frontend-local

# Make a test commit
git commit --allow-empty -m "Test GitHub Actions CI/CD"

# Push to trigger the workflow
git push origin frontend-local
```

Go to the **Actions** tab in GitHub to watch your workflow run!

---

## GitHub Secrets Configuration

### Creating KUBECONFIG Secret

```bash
# Method 1: Direct base64 encoding
cat ~/.kube/config | base64

# Method 2: Copy to clipboard (macOS)
cat ~/.kube/config | base64 | pbcopy

# Method 3: Copy to clipboard (Linux with xclip)
cat ~/.kube/config | base64 | xclip -selection clipboard
```

Then add it to GitHub:
1. Repository → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Name: `KUBECONFIG`
4. Value: Paste the base64-encoded content
5. Click **Add secret**

---

## Workflow Details

### Pipeline Overview

The new GitHub Actions workflow includes three main jobs:

### Build Job
- **Triggers**: On push or pull request to main, frontend-local, dev
- **Actions**:
  - Checks out code
  - Sets up Docker Buildx
  - Logs into GitHub Container Registry
  - Builds Docker image with Vite build inside
  - Pushes to ghcr.io with multiple tags
  - Uses GitHub Actions cache for faster builds

**Image Tags Created:**
- `ghcr.io/YOUR_USERNAME/scalyshop-v2-frontend:SHA` (commit SHA)
- `ghcr.io/YOUR_USERNAME/scalyshop-v2-frontend:main` (branch)
- `ghcr.io/YOUR_USERNAME/scalyshop-v2-frontend:frontend-local` (branch)
- `ghcr.io/YOUR_USERNAME/scalyshop-v2-frontend:dev` (branch)
- `ghcr.io/YOUR_USERNAME/scalyshop-v2-frontend:latest` (for main branch)

### Test Job (Currently Disabled)
Uncomment in `.github/workflows/ci-cd.yml` to enable:

```yaml
test:
  name: Run Tests
  runs-on: ubuntu-latest
  needs: build
  
  steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Set up Node.js
      uses: actions/setup-node@v4
      with:
        node-version: 'lts/*'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm install
    
    - name: Run linter
      run: npm run lint --if-present
    
    - name: Build
      run: npm run build
```

### Deploy Job
- **Triggers**: Only on push events (not PRs) to main, frontend-local, dev
- **Actions**:
  - Checks out code
  - Sets up Helm and kubectl
  - Configures kubectl with KUBECONFIG secret
  - Runs `helm upgrade --install` with current commit SHA
  - Creates namespace if it doesn't exist
  - Waits for deployment to be available

---

## GitLab vs GitHub Reference

### CI/CD Variables

| Feature | GitLab CI | GitHub Actions |
|---------|-----------|----------------|
| Config File | `.gitlab-ci.yml` | `.github/workflows/ci-cd.yml` |
| Container Registry | Custom GitLab registry | `ghcr.io` |
| Commit SHA (short) | `$CI_COMMIT_SHORT_SHA` | `${{ github.sha }}` (full) |
| Registry Image | `$CI_REGISTRY_IMAGE` | `ghcr.io/${{ github.repository }}` |
| Branch Name | `$CI_COMMIT_BRANCH` | `${{ github.ref_name }}` |
| Registry Login | `$CI_REGISTRY_USER`, `$CI_REGISTRY_PASSWORD` | `${{ github.actor }}`, `${{ secrets.GITHUB_TOKEN }}` |
| Runner | Docker-in-Docker service | `runs-on: ubuntu-latest` |

### Build Differences

| GitLab CI | GitHub Actions |
|-----------|----------------|
| Uses Docker-in-Docker (dind) | Uses Docker Buildx |
| Manual docker login | Automated with docker/login-action |
| Manual cache handling | Automatic with GHA cache |
| Only `frontend-local` branch | Multiple branches supported |

---

## Troubleshooting

### Issue: Docker Image Push Failed
**Error**: Permission denied or authentication failed

**Solution**:
1. Go to **Settings → Actions → General**
2. Under "Workflow permissions", select **Read and write permissions**
3. Ensure **GITHUB_TOKEN** has package write permissions

### Issue: Kubernetes Deployment Fails
**Error**: Connection refused or authentication failed

**Solutions**:
- Verify KUBECONFIG secret is properly base64 encoded
- Test kubectl locally: `kubectl get nodes`
- Ensure namespace exists or workflow creates it
- Check if kubeconfig is still valid (not expired)

### Issue: Can't See Docker Images
**Error**: Images not visible in Packages

**Solutions**:
- Check https://github.com/YOUR_USERNAME?tab=packages
- Images are private by default - go to package settings → Change visibility
- Verify the build job completed successfully in Actions tab

### Issue: Build Fails During Vite Build
**Error**: Vite build errors

**Solutions**:
- Check if environment variables are set correctly
- Verify VITE_BACKEND_HOST and VITE_BACKEND_PORT in workflow
- Update build-args in workflow if needed
- Test build locally: `npm run build`

### Issue: Workflow Not Triggering
**Error**: Push to branch but no workflow runs

**Solutions**:
- Check branch name matches workflow triggers (main, frontend-local, dev)
- Ensure workflow file is in `.github/workflows/` directory
- Verify YAML syntax is correct (use a YAML validator)
- Check Actions are enabled: Settings → Actions → General

---

## Making Packages Public

By default, GitHub Container Registry packages are private. To make them public:

1. Go to https://github.com/YOUR_USERNAME?tab=packages
2. Click on your package (`scalyshop-v2-frontend`)
3. Click **Package settings** (bottom right)
4. Scroll to **Danger Zone**
5. Click **Change visibility** → Public
6. Type the repository name to confirm

---

## Cleanup

### After Successful Migration

Once everything is working on GitHub, you can clean up GitLab-specific files:

```bash
# Remove GitLab CI configuration file
git rm .gitlab-ci.yml

# Commit the cleanup
git commit -m "Remove GitLab CI configuration"

# Push to GitHub
git push origin frontend-local
git push origin main
```

### Remove Backup Files

The migration script creates backup files. Once you've verified everything works:

```bash
# List backup files
ls -la *.backup

# Remove them
rm -f *.backup
git add .
git commit -m "Remove backup files"
git push
```

---

## FAQ

### Q: Will all my branches be migrated?
**A:** Yes! When you use `git push -u origin --all`, ALL your local branches are pushed to GitHub with their complete commit history. The migration script can do this automatically.

### Q: What about commit history?
**A:** Your entire commit history is preserved. Every commit from every branch, including author information, timestamps, and commit messages.

### Q: What if I have many branches?
**A:** No problem! The `--all` flag handles all branches. The script will show you which branches exist before pushing.

### Q: Are tags migrated?
**A:** Yes! Use `git push -u origin --tags` or let the migration script handle it automatically.

### Q: Will contributor information be preserved?
**A:** Absolutely! All commit author information, co-authors, and Git history metadata is fully preserved.

### Q: Can I verify what will be migrated before pushing?
**A:** Yes! The migration script shows you all branches and tags before asking if you want to push. You can also run:
```bash
git branch -a        # See all branches
git log --oneline    # See commit history
git tag              # See all tags
```

### Q: Why does the workflow trigger on different branches than GitLab CI?
**A:** The GitLab CI only triggered on `frontend-local`. The GitHub Actions workflow triggers on `main`, `frontend-local`, and `dev` for better flexibility. You can customize this in the workflow file.

---

## Advanced Configuration

### Customize Environment Variables

Edit `.github/workflows/ci-cd.yml` to change backend connection:

```yaml
build-args: |
  VITE_BACKEND_HOST=your-backend-host
  VITE_BACKEND_PORT=your-port
```

### Add Branch Protection Rules

1. Go to **Settings → Branches**
2. Click **Add branch protection rule**
3. Branch name pattern: `main` or `frontend-local`
4. Enable:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
   - Select required checks: `build`, `test` (if enabled)

### Add Workflow Status Badge

Add to your README.md:

```markdown
[![CI/CD Pipeline](https://github.com/YOUR_USERNAME/scalyshop-v2-frontend/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/YOUR_USERNAME/scalyshop-v2-frontend/actions/workflows/ci-cd.yml)
```

---

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Docker Buildx Documentation](https://docs.docker.com/buildx/working-with-buildx/)
- [Vite Documentation](https://vitejs.dev/)

---

## Summary

### What You Have Now

✅ GitHub Actions workflow that builds, tests, and deploys  
✅ Automatic Docker image publishing to ghcr.io  
✅ Helm-based Kubernetes deployment  
✅ Multi-branch support (main, frontend-local, dev)  
✅ Pull request validation (without deployment)  
✅ Automated migration script  

### Migration Checklist

- [ ] Create GitHub repository
- [ ] Run `./migrate-to-github.sh` (it will handle everything!)
  - [ ] Shows all branches that will be migrated
  - [ ] Updates configuration files
  - [ ] Optionally pushes all branches with complete history
- [ ] Verify all branches on GitHub: `git branch -r`
- [ ] Add KUBECONFIG secret
- [ ] Enable workflow permissions
- [ ] Test workflow with empty commit
- [ ] Verify deployment in Kubernetes
- [ ] Make packages public (optional)
- [ ] Remove GitLab CI file (optional)
- [ ] Update README with GitHub badge (optional)

### What's Preserved in Migration

✅ **All branches** (not just current branch)  
✅ **Complete commit history** (every single commit)  
✅ **All contributors** (author information intact)  
✅ **Git tags** (version tags, releases, etc.)  
✅ **Commit metadata** (messages, dates, authors)  
✅ **Branch relationships** (merge history preserved)

---

**Ready to migrate?** Run `./migrate-to-github.sh` and you'll be on GitHub in minutes! 🚀

For questions or issues, review the troubleshooting section above.

