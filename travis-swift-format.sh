#!/bin/bash

install_swiftformat() {
  brew install swiftformat
  # To update to the latest version once installed
  brew upgrade swiftformat
}

setup_git() {

  # Decrypt the file containing the private key
  openssl aes-256-cbc \
     -K $encrypted_1a1cd4d34da0_key \
     -iv $encrypted_1a1cd4d34da0_iv \
     -in "github_deploy_key.enc" \
     -out github_deploy_key -d

  # Enable SSH authentication
  chmod 600 github_deploy_key
  eval $(ssh-agent -s)
  ssh-add github_deploy_key

  git config --global user.email "$GH_USER_EMAIL"
  git config --global user.name "$GH_USER_NAME"
}

runSwiftFormat() {
  git checkout "$TRAVIS_BRANCH"
  # Run SwiftFormat
  swiftformat . --exclude Carthage
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

push_commit() {

  # test SSH connection 
  ssh -T git@github.com

  # set new origin to SSH
  local remote=git@github.com:$TRAVIS_REPO_SLUG.git
  git remote set-url origin "$remote"
  # list origins
  git remote -v
  # push to remote
  git push --quiet origin "$TRAVIS_BRANCH"
}


if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
  echo "This is a pull request. Starting SwiftFormat."

  install_swiftformat

  setup_git

  runSwiftFormat

  # Attempt to commit to git only if "git commit" succeeded
  if [ $? -eq 0 ]; then
    echo "A new commit with SwiftFormat changes exists. Uploading to GitHub"
    push_commit
  else
    echo "No changes in Swiftformat. Nothing to do"
  fi
  exit 0
else
  echo "This is not a pull request. SwiftFormat is run on pull request only"
fi