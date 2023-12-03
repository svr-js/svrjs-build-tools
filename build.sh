#!/bin/bash

GLOBIGNORE=".:.."

if ! [ -d svrjs ]; then
  echo '"svrjs" directory is missing. You can obtain SVR.JS source ("svrjs" directory) using "git clone -b <branch> https://git.svrjs.org/git/svrjs.git" (where "<branch>" is a branch you want to clone).'
  exit 1
fi

rm svr.js.*.zip

pushd $(dirname $0)

cp -a svrjs svrjs-temp
rm -rf svrjs-temp/.git
find svrjs-temp -name '.gitignore' -exec rm -f {} \;

mkdir svrjs-temp/node_modules_uncompressed

mv svrjs-temp/node_modules/.bin svrjs-temp/node_modules_uncompressed
for module in $(cat uncompressed_modules); do
  mv svrjs-temp/node_modules/$module svrjs-temp/node_modules_uncompressed
done

cd svrjs-temp/node_modules
tar -czf ../modules.compressed *
tar -uzf ../modules.compressed .* 2>/dev/null

cd ..
rm -rf node_modules
mv node_modules_uncompressed node_modules

mkdir log
mkdir temp

SVRJSVERSION=$(cat svr.js | grep -E '^[ \t]*(var|const|let) *version *= *(["'"'"'])' | grep -E -o '"([^"\\]|\\.)+"|'"'"'([^'"'"'\\]|\\.)+'"'"'' | head -n 1 | sed -E 's/^.|.$//g' | sed -E 's/\\(.)/\1/g')
if [ "$SVRJSVERSION" == "" ]; then
  SVRJSVERSION=Unknown
fi
SVRJSFILENAME="svr.js.$(echo $SVRJSVERSION| tr '[:upper:]' '[:lower:]' | sed -E 's/[^0-9a-z]+/./g').zip"

gzip svr.js
mv svr.js.gz svr.compressed
cp ../unpacker.js svr.js

echo $SVRJSFILENAME
zip -r ../$SVRJSFILENAME *
zip -r ../$SVRJSFILENAME .* 2>/dev/null
echo "SVR.JS $SVRJSVERSION" > zip -z ../$SVRJSFILENAME
cd ..

rm -rf svrjs-temp

popd

echo "You have packed SVR.JS $SVRJSVERSION into \"$SVRJSFILENAME\" file."
