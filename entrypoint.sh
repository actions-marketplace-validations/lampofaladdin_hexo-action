#!/bin/sh

set -e

echo "set key"
# setup ssh-private-key
mkdir -p /root/.ssh/
echo "$INPUT_DEPLOY_KEY" > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

echo "set git"
# setup deploy git account
git config --global user.name "$INPUT_USER_NAME"
git config --global user.email "$INPUT_USER_EMAIL"

echo "set hexo-cli"
# install hexo env
npm install hexo-cli -g

echo "set hexo-cli-git"
npm install hexo-deployer-git --save

echo "set file permission"
chown -R `whoami` /usr/local/lib/node_modules

# deployment
if [ "$INPUT_COMMIT_MSG" = "none" ]
then
    hexo g -d
elif [ "$INPUT_COMMIT_MSG" = "" ] || [ "$INPUT_COMMIT_MSG" = "default" ]
then
    # pull original publish repo
    NODE_PATH=$NODE_PATH:$(pwd)/node_modules node /sync_deploy_history.js
    hexo g -d
else
    NODE_PATH=$NODE_PATH:$(pwd)/node_modules node /sync_deploy_history.js
    hexo g -d -m "$INPUT_COMMIT_MSG"
fi

echo ::set-output name=notify::"Deploy complate."
