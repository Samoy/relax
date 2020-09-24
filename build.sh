#!/usr/bin/env bash
if [[ -d "build" ]]; then
    rm -rf "build"
fi
xcodebuild
if [[ ! -f build/Release/relax.app ]]; then
	exit 1
fi
if [[ ! -d tmp ]]; then
   mkdir tmp
fi
cp -r build/Release/relax.app tmp/
cd tmp
mv relax.app 休息一下吧.app
ln -s /Applications Applications
cd ..
hdiutil create -srcfolder tmp/ relax.dmg
rm -rf tmp
if [[ ! -d dist ]]; then
   mkdir dist
else
  rm -rf dist/*
fi
mv relax.dmg dist/
