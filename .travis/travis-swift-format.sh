#!/bin/bash

install_swiftformat() {
  brew install swiftformat
  # To update to the latest version once installed
  brew upgrade swiftformat
}

runSwiftFormat() {

  git checkout "$TRAVIS_BRANCH"
  # Run SwiftFormat
  swiftformat .
  # Stage the modified files
  git add .
  # Create a new commit with a custom build message
  # with "[skip ci]" to avoid a build loop
  # and Travis build number for reference
  if ! git commit -m "Travis CI - SwiftFormat [ci skip]"; then
    err "failed to commit updates"
    return 1
  fi
}

setup_git() {

  # Decrypt the file containing the private key
  openssl aes-256-cbc \
     -K $encrypted_1a1cd4d34da0_key \
     -iv $encrypted_1a1cd4d34da0_iv \
     -in ".travis/github_deploy_key.enc" \
     -out .travis/github_deploy_key -d

  # Enable SSH authentication
  chmod 600 .travis/github_deploy_key
  eval $(ssh-agent -s)
  ssh-add .travis/github_deploy_key

  git config --global user.email "$GH_USER_EMAIL"
  git config --global user.name "$GH_USER_NAME"
}

push_commit() {

  # test SSH connection 
  ssh -T git@github.com

  # set new origin to SSH
  local remote=git@github.com:$TRAVIS_REPO_SLUG.git
  git remote set-url origin "$remote"

  # push to remote
  git push --quiet origin "$TRAVIS_BRANCH"
}


echo "Starting SwiftFormat"

install_swiftformat

setup_git

runSwiftFormat

# Attempt to commit to git only if "git commit" succeeded
if [ $? -eq 0 ]; then
  echo "A new commit with SwiftFormat is created. Uploading to GitHub..."
  push_commit
else
  echo "No changes in Swiftformat. Nothing to do"
fi
exit 0