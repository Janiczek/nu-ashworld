.PHONY: watch
watch:
	elmid --watched-folder=src src/DummyMain.elm

.PHONY: start
start:
	lamdera live

.PHONY: test
test:
	gsed --in-place=.bak '/lamdera/d' elm.json
	yarn elm-test-rs || true
	mv elm.json.bak elm.json

.PHONY: test-long
test-long:
	gsed --in-place=.bak '/lamdera/d' elm.json
	yarn elm-test-rs --fuzz 10000 || true
	mv elm.json.bak elm.json

.PHONY: test-watch
test-watch:
	gsed --in-place=.bak '/lamdera/d' elm.json
	yarn elm-test-rs --watch || true
	mv elm.json.bak elm.json

.PHONY: test-watch-long
test-watch-long:
	gsed --in-place=.bak '/lamdera/d' elm.json
	yarn elm-test-rs --watch --fuzz 10000 || true
	mv elm.json.bak elm.json

.PHONY: review
review:
	yarn elm-review
