#!/bin/bash

# Migration Script: GitLab to GitHub (Frontend)
# This script helps automate the migration process

set -e  # Exit on error

echo "═══════════════════════════════════════════════════════════"
echo "  ScalyShop v2 Frontend - GitHub Migration Script"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Please install git first."
    exit 1
fi

print_success "Git is installed"

# Get GitHub username
echo ""
print_status "Please enter your GitHub username:"
read -r GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    print_error "GitHub username cannot be empty"
    exit 1
fi

# Get repository name
echo ""
print_status "Please enter your GitHub repository name (default: scalyshop-v2-frontend):"
read -r REPO_NAME
REPO_NAME=${REPO_NAME:-scalyshop-v2-frontend}

print_status "Using repository: ${GITHUB_USERNAME}/${REPO_NAME}"

# Ask for SSH or HTTPS
echo ""
print_status "Do you want to use SSH or HTTPS for GitHub? (ssh/https, default: https):"
read -r GIT_PROTOCOL
GIT_PROTOCOL=${GIT_PROTOCOL:-https}

if [ "$GIT_PROTOCOL" = "ssh" ]; then
    GITHUB_URL="git@github.com:${GITHUB_USERNAME}/${REPO_NAME}.git"
else
    GITHUB_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
fi

echo ""
print_status "GitHub URL: $GITHUB_URL"

# Confirm before proceeding
echo ""
print_warning "This script will:"
echo "  1. Update git remote to point to GitHub"
echo "  2. Update Helm values.yaml with new image repository"
echo "  3. Update Dockerfile comment with new repository URL"
echo ""
echo "Current git remotes:"
git remote -v
echo ""
read -p "Do you want to proceed? (yes/no): " -r CONFIRM

if [ "$CONFIRM" != "yes" ] && [ "$CONFIRM" != "y" ]; then
    print_warning "Migration cancelled"
    exit 0
fi

echo ""
print_status "Starting migration..."

# Step 1: Update git remote
echo ""
print_status "Step 1: Updating git remote..."

# Check if origin exists
if git remote | grep -q "^origin$"; then
    print_status "Removing old 'origin' remote..."
    git remote remove origin
fi

print_status "Adding new GitHub remote..."
git remote add origin "$GITHUB_URL"
print_success "Git remote updated"

# Verify
echo ""
print_status "New git remotes:"
git remote -v

# Step 2: Update Helm values.yaml
echo ""
print_status "Step 2: Updating Helm values.yaml..."

HELM_VALUES_FILE="scalyshop-frontend/values.yaml"

if [ -f "$HELM_VALUES_FILE" ]; then
    # Backup original file
    cp "$HELM_VALUES_FILE" "${HELM_VALUES_FILE}.backup"
    print_status "Created backup: ${HELM_VALUES_FILE}.backup"
    
    # Update image repository (uncomment and set)
    sed -i.tmp "s|#  repository:.*|  repository: ghcr.io/${GITHUB_USERNAME}/${REPO_NAME}|g" "$HELM_VALUES_FILE"
    sed -i.tmp "s|  # repository:.*|  repository: ghcr.io/${GITHUB_USERNAME}/${REPO_NAME}|g" "$HELM_VALUES_FILE"
    
    # Update image tag to empty (will be set by CI/CD)
    sed -i.tmp 's|#  tag: "v1.0.0"|  tag: ""|g' "$HELM_VALUES_FILE"
    sed -i.tmp 's|  # tag: "v1.0.0"|  tag: ""|g' "$HELM_VALUES_FILE"
    
    # Comment out imagePullSecrets
    sed -i.tmp 's|imagePullSecrets:|# imagePullSecrets: # Uncomment if using private images|g' "$HELM_VALUES_FILE"
    sed -i.tmp 's|  - name: gitlab-cred|#  - name: ghcr-secret|g' "$HELM_VALUES_FILE"
    
    # Clean up temporary file
    rm -f "${HELM_VALUES_FILE}.tmp"
    
    print_success "Updated $HELM_VALUES_FILE"
else
    print_warning "Helm values file not found: $HELM_VALUES_FILE"
fi

# Step 3: Update Dockerfile
echo ""
print_status "Step 3: Updating Dockerfile..."

if [ -f "Dockerfile" ]; then
    # Backup original file
    cp "Dockerfile" "Dockerfile.backup"
    print_status "Created backup: Dockerfile.backup"
    
    # Update the example comment with new registry
    sed -i.tmp "s|registry.git.chalmers.se/courses/dat490/students/2025/dat490-2025-9/scalyshop-v2-frontend|ghcr.io/${GITHUB_USERNAME}/${REPO_NAME}|g" "Dockerfile"
    
    # Clean up temporary file
    rm -f "Dockerfile.tmp"
    
    print_success "Updated Dockerfile"
else
    print_warning "Dockerfile not found"
fi

# Step 4: Show branches and tags
echo ""
print_status "Step 4: Checking your branches and tags..."
echo ""
print_status "Local branches found:"
git branch -a | grep -v "remote/" | sed 's/*/  -/' | sed 's/^  //'

echo ""
TAGS_COUNT=$(git tag | wc -l | xargs)
if [ "$TAGS_COUNT" -gt 0 ]; then
    print_status "Git tags found: $TAGS_COUNT"
    git tag | head -5
    if [ "$TAGS_COUNT" -gt 5 ]; then
        echo "  ... and $(($TAGS_COUNT - 5)) more"
    fi
else
    print_status "No git tags found"
fi

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════"
print_success "Migration preparation complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
print_warning "IMPORTANT: All branches and complete commit history will be migrated!"
echo ""
print_status "What will be migrated:"
echo "  • All local branches and their complete commit history"
echo "  • All tags (if any)"
echo "  • All commits from all contributors"
echo "  • All commit messages and timestamps"
echo ""

# Offer to show diff first
echo ""
read -p "Would you like to see the changes made to files? (yes/no): " -r SHOW_DIFF

if [ "$SHOW_DIFF" = "yes" ] || [ "$SHOW_DIFF" = "y" ]; then
    echo ""
    print_status "Changes made:"
    git diff
    echo ""
fi

# Ask if user wants to commit and push now
echo ""
print_status "Do you want to commit these changes and push to GitHub now?"
echo ""
print_warning "Make sure you have created the GitHub repository first!"
echo "  Repository URL: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
echo ""
read -p "Commit and push all branches to GitHub? (yes/no): " -r PUSH_NOW

if [ "$PUSH_NOW" = "yes" ] || [ "$PUSH_NOW" = "y" ]; then
    echo ""
    print_status "Committing changes..."
    
    git add .
    git commit -m "Migrate to GitHub with GitHub Actions" || {
        print_warning "Nothing to commit (files may already be committed)"
    }
    
    echo ""
    print_status "Pushing all branches to GitHub..."
    print_status "This will preserve ALL commit history from ALL branches"
    echo ""
    
    # Push all branches
    if git push -u origin --all; then
        print_success "All branches pushed successfully!"
        
        # Push tags if any exist
        if [ "$TAGS_COUNT" -gt 0 ]; then
            echo ""
            print_status "Pushing tags..."
            if git push -u origin --tags; then
                print_success "All tags pushed successfully!"
            else
                print_error "Failed to push tags. You can push them later with: git push origin --tags"
            fi
        fi
        
        echo ""
        echo "═══════════════════════════════════════════════════════════"
        print_success "🎉 Migration to GitHub complete!"
        echo "═══════════════════════════════════════════════════════════"
        echo ""
        print_status "Your repository is now on GitHub:"
        echo "  🔗 https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
        echo ""
        print_status "Next steps:"
        echo ""
        echo "  1. Configure GitHub Secrets:"
        echo "     - Go to: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}/settings/secrets/actions"
        echo "     - Add KUBECONFIG secret (base64 encoded): cat ~/.kube/config | base64"
        echo ""
        echo "  2. Enable workflow permissions:"
        echo "     - Go to: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}/settings/actions"
        echo "     - Select 'Read and write permissions'"
        echo ""
        echo "  3. Test the workflow:"
        echo "     - Go to: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}/actions"
        echo "     - Or push a test commit: git commit --allow-empty -m 'Test CI' && git push"
        echo ""
        
    else
        print_error "Failed to push to GitHub!"
        echo ""
        print_status "This might be because:"
        echo "  • The GitHub repository doesn't exist yet"
        echo "  • You don't have permission to push"
        echo "  • Authentication failed"
        echo ""
        print_status "To push manually later:"
        echo "  git push -u origin --all"
        echo "  git push -u origin --tags"
    fi
else
    echo ""
    print_status "Manual migration steps:"
    echo ""
    echo "  1. Review the changes:"
    echo "     git status"
    echo "     git diff"
    echo ""
    echo "  2. Commit the changes:"
    echo "     git add ."
    echo "     git commit -m 'Migrate to GitHub'"
    echo ""
    echo "  3. Push ALL branches to GitHub (preserves all history):"
    echo "     git push -u origin --all"
    echo ""
    if [ "$TAGS_COUNT" -gt 0 ]; then
        echo "  4. Push all tags:"
        echo "     git push -u origin --tags"
        echo ""
    fi
    echo "  5. Configure GitHub Secrets:"
    echo "     - Go to: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}/settings/secrets/actions"
    echo "     - Add KUBECONFIG secret (base64 encoded)"
    echo ""
    echo "  6. Enable workflow permissions:"
    echo "     - Go to: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}/settings/actions"
    echo "     - Select 'Read and write permissions'"
    echo ""
fi

echo ""
print_status "For more details, see GITHUB_MIGRATION_GUIDE.md"
echo ""
print_success "Script completed successfully!"

