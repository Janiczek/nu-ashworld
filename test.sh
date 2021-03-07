#!/usr/bin/env bash
cp elm.json elm.json.bak
sed -i '/.*lamdera.*/d' elm.json
elm-test-rs --fuzz 100000
mv elm.json.bak elm.json
