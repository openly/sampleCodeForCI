#! /bin/bash -e
cd ..
if [ -d current ]; then
  echo "Getting the Back Up of 'current' code"
  rm -rf old
  mv current old
fi

echo "Move the Deployed code to the 'current' directory"
mv deploy current
mkdir deploy

echo "CD to the 'current' directory"
cd current

echo "Installing the node dependencies by NPM for $NODE_ENV environment"
if [ 'production' == "$NODE_ENV" ]; then
  npm install --production
else
  npm install
fi