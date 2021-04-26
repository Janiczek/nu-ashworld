.PHONY: watch
watch:
	elmid --watched-folder=src src/DummyMain.elm

.PHONY: start
start:
	lamdera live

.PHONY: test
test:
	elm-test-rs

.PHONY: review
review:
	yarn elm-review
