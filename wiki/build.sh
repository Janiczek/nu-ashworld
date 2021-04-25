#!/usr/bin/env bash

if [ ! -f "./tiddlywiki.info" ]; then
    echo "File ./tiddlywiki.info doesn't exist. Trying to create a new TiddlyWiki."
    rm -rf tiddlers
    rm -rf x
    tiddlywiki x --init server
    mv x/tiddlywiki.info ./
    rm -rf x
fi

if [ ! -f "./tiddlers.json" ]; then
    echo "File ./tiddlers.json doesn't exist. Exiting."
    echo "You'll need to go to https://nu-ashworld.tiddlyhost.com/#%24%3A%2FAdvancedSearch"
    echo "and search using filter [all[tiddlers]]=[all[tags]]"
    echo "and export all the results as JSON."
    exit 1
fi

echo "1. Deleting old tiddlers from the local database"
rm -rf tiddlers
tiddlywiki --deletetiddlers "[all[tiddlers]]"
tiddlywiki --deletetiddlers "[all[tags]]"
tiddlywiki --deletetiddlers "[all[orphans]]"

echo "2. Loading new tiddlers to the local database"
tiddlywiki --load tiddlers.json

echo "3. Starting the local server"
tiddlywiki --listen &
PID="$!"

echo "4. Rendering tiddlers"
tiddlywiki --rendertiddlers "[!is[system]]" $:/core/templates/static.tiddler.html static text/plain
tiddlywiki --rendertiddler $:/core/templates/static.template.css static/static.css text/plain

echo "5. Stopping the local server at PID ${PID}"
kill "${PID}"

echo "6. Copying NuAshworld.html to index.html"
cp ./output/static/{NuAshworld,index}.html

echo "7. Copying the output folder to the repository"
rm -rf ../docs/*
cp -r ./output/static/* ../docs/
du -sh ./output/static
du -sh ../docs

echo "8. Done, feel free to review, commit and push!"
