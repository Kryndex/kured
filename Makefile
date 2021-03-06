.DEFAULT: all
.PHONY: all clean image publish-image minikube-publish

DH_ORG=weaveworks
VERSION=$(shell git symbolic-ref --short HEAD)-$(shell git rev-parse --short HEAD)

all: image

clean:
	go clean
	rm -f cmd/kured/kured
	rm -rf ./build

godeps=$(shell go get $1 && go list -f '{{join .Deps "\n"}}' $1 | grep -v /vendor/ | xargs go list -f '{{if not .Standard}}{{ $$dep := . }}{{range .GoFiles}}{{$$dep.Dir}}/{{.}} {{end}}{{end}}')

DEPS=$(call godeps,./cmd/kured)

cmd/kured/kured: $(DEPS)
cmd/kured/kured: cmd/kured/*.go
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-X main.version=$(VERSION)" -o $@ cmd/kured/*.go

build/.image.done: cmd/kured/Dockerfile cmd/kured/kured
	mkdir -p build
	cp $^ build
	sudo -E docker build -t quay.io/$(DH_ORG)/kured:$(VERSION) -f build/Dockerfile ./build
	touch $@

image: build/.image.done

publish-image: image
	sudo -E docker push quay.io/$(DH_ORG)/kured:$(VERSION)

minikube-publish: image
	sudo -E docker save quay.io/$(DH_ORG)/kured:$(VERSION) | (eval $$(minikube docker-env) && docker load)
