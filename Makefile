NAME := $(or $(NAME),$(NAME),selenium)
VERSION := $(or $(VERSION),$(VERSION),3.141.59-iron)
NAMESPACE := $(or $(NAMESPACE),$(NAMESPACE),$(NAME))
AUTHORS := $(or $(AUTHORS),$(AUTHORS),SeleniumHQ)
PLATFORM := $(shell uname -s)
BUILD_ARGS := $(BUILD_ARGS)
MAJOR := $(word 1,$(subst ., ,$(VERSION)))
MINOR := $(word 2,$(subst ., ,$(VERSION)))
MAJOR_MINOR_PATCH := $(word 1,$(subst -, ,$(VERSION)))

all: hub chromium chromium_debug standalone_chromium standalone_chromium_debug

generate_all:	\
	generate_hub \
	generate_nodebase \
	generate_chromium \
	generate_chromium_debug \
	generate_standalone_chromium \
	generate_standalone_chromium_debug

build: all

ci: build test

base:
	cd ./Base && docker build $(BUILD_ARGS) -t $(NAME)/base:$(VERSION) .

generate_hub:
	cd ./Hub && ./generate.sh $(VERSION) $(NAMESPACE) $(AUTHORS)

hub: base generate_hub
	cd ./Hub && docker build $(BUILD_ARGS) -t $(NAME)/hub:$(VERSION) .

generate_nodebase:
	cd ./NodeBase && ./generate.sh $(VERSION) $(NAMESPACE) $(AUTHORS)

nodebase: base generate_nodebase
	cd ./NodeBase && docker build $(BUILD_ARGS) -t $(NAME)/node-base:$(VERSION) .	
	
generate_chromium:
	cd ./NodeChromium && ./generate.sh $(VERSION) $(NAMESPACE) $(AUTHORS)
	
chromium: nodebase generate_chromium
	cd ./NodeChromium && docker build $(BUILD_ARGS) -t $(NAME)/node-chromium:$(VERSION) .
	
generate_standalone_chromium:
	cd ./Standalone && ./generate.sh StandaloneChromium node-chromium Chromium $(VERSION) $(NAMESPACE) $(AUTHORS)

standalone_chromium: chromium generate_standalone_chromium
	cd ./StandaloneChromium && docker build $(BUILD_ARGS) -t $(NAME)/standalone-chromium:$(VERSION) .

generate_standalone_chromium_debug:
	cd ./StandaloneDebug && ./generate.sh StandaloneChromiumDebug node-chromium-debug Chromium $(VERSION) $(NAMESPACE) $(AUTHORS)

standalone_chromium_debug: chromium_debug generate_standalone_chromium_debug
	cd ./StandaloneChromiumDebug && docker build $(BUILD_ARGS) -t $(NAME)/standalone-chromium-debug:$(VERSION) .
	
generate_chromium_debug:
	cd ./NodeDebug && ./generate.sh NodeChromiumDebug node-chromium Chromium $(VERSION) $(NAMESPACE) $(AUTHORS)

chromium_debug: generate_chromium_debug chromium
	cd ./NodeChromiumDebug && docker build $(BUILD_ARGS) -t $(NAME)/node-chromium-debug:$(VERSION) .

tag_latest:
	docker tag $(NAME)/base:$(VERSION) $(NAME)/base:latest
	docker tag $(NAME)/hub:$(VERSION) $(NAME)/hub:latest
	docker tag $(NAME)/node-base:$(VERSION) $(NAME)/node-base:latest
	docker tag $(NAME)/node-chromium:$(VERSION) $(NAME)/node-chromium:latest
	docker tag $(NAME)/node-chromium-debug:$(VERSION) $(NAME)/node-chromium-debug:latest
	docker tag $(NAME)/standalone-chromium:$(VERSION) $(NAME)/standalone-chromium:latest
	docker tag $(NAME)/standalone-chromium-debug:$(VERSION) $(NAME)/standalone-chromium-debug:latest

release_latest:
	docker push $(NAME)/base:latest
	docker push $(NAME)/hub:latest
	docker push $(NAME)/node-base:latest
	docker push $(NAME)/node-chromium:latest
	docker push $(NAME)/node-chromium-debug:latest
	docker push $(NAME)/standalone-chromium:latest
	docker push $(NAME)/standalone-chromium-debug:latest

tag_major_minor:
	docker tag $(NAME)/base:$(VERSION) $(NAME)/base:$(MAJOR)
	docker tag $(NAME)/hub:$(VERSION) $(NAME)/hub:$(MAJOR)
	docker tag $(NAME)/node-base:$(VERSION) $(NAME)/node-base:$(MAJOR)
	docker tag $(NAME)/node-chromium:$(VERSION) $(NAME)/node-chromium:$(MAJOR)
	docker tag $(NAME)/node-chromium-debug:$(VERSION) $(NAME)/node-chromium-debug:$(MAJOR)
	docker tag $(NAME)/standalone-chromium:$(VERSION) $(NAME)/standalone-chromium:$(MAJOR)
	docker tag $(NAME)/standalone-chromium-debug:$(VERSION) $(NAME)/standalone-chromium-debug:$(MAJOR)
	docker tag $(NAME)/base:$(VERSION) $(NAME)/base:$(MAJOR).$(MINOR)
	docker tag $(NAME)/hub:$(VERSION) $(NAME)/hub:$(MAJOR).$(MINOR)
	docker tag $(NAME)/node-base:$(VERSION) $(NAME)/node-base:$(MAJOR).$(MINOR)
	docker tag $(NAME)/node-chromium:$(VERSION) $(NAME)/node-chromium:$(MAJOR).$(MINOR)
	docker tag $(NAME)/node-chromium-debug:$(VERSION) $(NAME)/node-chromium-debug:$(MAJOR).$(MINOR)
	docker tag $(NAME)/standalone-chromium:$(VERSION) $(NAME)/standalone-chromium:$(MAJOR).$(MINOR)
	docker tag $(NAME)/standalone-chromium-debug:$(VERSION) $(NAME)/standalone-chromium-debug:$(MAJOR).$(MINOR)
	docker tag $(NAME)/base:$(VERSION) $(NAME)/base:$(MAJOR_MINOR_PATCH)
	docker tag $(NAME)/hub:$(VERSION) $(NAME)/hub:$(MAJOR_MINOR_PATCH)
	docker tag $(NAME)/node-base:$(VERSION) $(NAME)/node-base:$(MAJOR_MINOR_PATCH)
	docker tag $(NAME)/node-chromium:$(VERSION) $(NAME)/node-chromium:$(MAJOR_MINOR_PATCH)
	docker tag $(NAME)/node-chromium-debug:$(VERSION) $(NAME)/node-chromium-debug:$(MAJOR_MINOR_PATCH)
	docker tag $(NAME)/standalone-chromium:$(VERSION) $(NAME)/standalone-chromium:$(MAJOR_MINOR_PATCH)
	docker tag $(NAME)/standalone-chromium-debug:$(VERSION) $(NAME)/standalone-chromium-debug:$(MAJOR_MINOR_PATCH)

release: tag_major_minor
	@if ! docker images $(NAME)/base | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/base version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/hub | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/hub version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/node-base | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/node-base version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/node-chromium | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/node-chromium version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/node-chromium-debug | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/node-chromium-debug version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/standalone-chromium | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/standalone-chromium version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)/standalone-chromium-debug | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)/standalone-chromium-debug version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	docker push $(NAME)/base:$(VERSION)
	docker push $(NAME)/hub:$(VERSION)
	docker push $(NAME)/node-base:$(VERSION)
	docker push $(NAME)/node-chromium:$(VERSION)
	docker push $(NAME)/node-chromium-debug:$(VERSION)
	docker push $(NAME)/standalone-chromium:$(VERSION)
	docker push $(NAME)/standalone-chromium-debug:$(VERSION)
	docker push $(NAME)/base:$(MAJOR)
	docker push $(NAME)/hub:$(MAJOR)
	docker push $(NAME)/node-base:$(MAJOR)
	docker push $(NAME)/node-chromium:$(MAJOR)
	docker push $(NAME)/node-firefox:$(MAJOR)
	docker push $(NAME)/standalone-chromium:$(MAJOR)
	docker push $(NAME)/standalone-chromium-debug:$(MAJOR)
	docker push $(NAME)/base:$(MAJOR).$(MINOR)
	docker push $(NAME)/hub:$(MAJOR).$(MINOR)
	docker push $(NAME)/node-base:$(MAJOR).$(MINOR)
	docker push $(NAME)/node-chromium:$(MAJOR).$(MINOR)
	docker push $(NAME)/node-chromium-debug:$(MAJOR).$(MINOR)
	docker push $(NAME)/standalone-chromium:$(MAJOR).$(MINOR)
	docker push $(NAME)/standalone-chromium-debug:$(MAJOR).$(MINOR)
	docker push $(NAME)/base:$(MAJOR_MINOR_PATCH)
	docker push $(NAME)/hub:$(MAJOR_MINOR_PATCH)
	docker push $(NAME)/node-base:$(MAJOR_MINOR_PATCH)
	docker push $(NAME)/node-chromium:$(MAJOR_MINOR_PATCH)
	docker push $(NAME)/node-chromium-debug:$(MAJOR_MINOR_PATCH)
	docker push $(NAME)/standalone-chromium:$(MAJOR_MINOR_PATCH)
	docker push $(NAME)/standalone-chromium-debug:$(MAJOR_MINOR_PATCH)

test: test_chrome \
 test_chromium \
 test_chromium_debug \
 test_chromium_standalone \
 test_chromium_standalone_debug
	
test_chromium:
	VERSION=$(VERSION) NAMESPACE=$(NAMESPACE) ./tests/bootstrap.sh NodeChromium

test_chromium_debug:
	VERSION=$(VERSION) NAMESPACE=$(NAMESPACE) ./tests/bootstrap.sh NodeChromiumDebug

test_chromium_standalone:
	VERSION=$(VERSION) NAMESPACE=$(NAMESPACE) ./tests/bootstrap.sh StandaloneChromium

test_chromium_standalone_debug:
	VERSION=$(VERSION) NAMESPACE=$(NAMESPACE) ./tests/bootstrap.sh StandaloneChromiumDebug

.PHONY: \
	all \
	base \
	build \
	chromium \
	chromium_debug \
	ci \
	generate_all \
	generate_hub \
	generate_nodebase \
	generate_chromium \
	generate_chromium_debug \
	generate_standalone_chromium \
	generate_standalone_chromium_debug \
	hub \
	nodebase \
	release \
	standalone_chromium \
	standalone_chromium_debug \
	tag_latest \
	test
