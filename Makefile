.PHONY: watch
watch:
	elmid --watched-folder=src src/DummyMain.elm

.PHONY: start
start:
	lamdera live

.PHONY: test
test:
	cp elm.json elm.json.bak
	sed -i '/.*lamdera.*/d' elm.json
	elm-test-rs
	mv elm.json.bak elm.json

.PHONY: review
review:
	rm -rf elm-stuff ~/.elm
	cp elm.json elm.json.bak
	sed -i '/.*lamdera.*/d' elm.json
	yarn elm-review || true
	mv elm.json.bak elm.json
