BINARY := bin/labcheck
PKG := ./cmd/labcheck

.PHONY: build run watch fmt vet clean

build:
	@mkdir -p bin
	go build -o $(BINARY) $(PKG)

run: build
	./$(BINARY)

# Rebuilds the executable every time a .go file changes. Requires entr
# (apt install entr). If you add a new .go file, restart `make watch` so
# it picks it up — entr only watches the files it was started with.
watch:
	@mkdir -p bin
	find . -name '*.go' -not -path './bin/*' | entr sh -c \
		'go build -o $(BINARY) $(PKG) && echo "[$$(date +%H:%M:%S)] build ok -> $(BINARY)" || echo "[$$(date +%H:%M:%S)] build failed"'

fmt:
	gofmt -l .

vet:
	go vet ./...

clean:
	rm -rf bin
