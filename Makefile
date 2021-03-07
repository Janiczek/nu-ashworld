watch:
	elmid --watched-folder=src src/DummyMain.elm

start:
	lamdera live

test:
	cp elm.json elm.json.bak
	sed -i '/.*lamdera.*/d' elm.json
	elm-test-rs
	mv elm.json.bak elm.json
