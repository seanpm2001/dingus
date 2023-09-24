PROJECT  ?= rouge-dingus
PLATFORM ?= linux/amd64

.PHONY: build
build-%: Dockerfile
	@docker buildx build --rm --platform=$(PLATFORM) \
		-t "$(PROJECT):$(*)" \
		--target "$(*)" .

.PHONY: run
run-%:
	@docker run --rm \
		--name $(PROJECT) \
		--publish 9292:9292 \
		"$(PROJECT):$(*)"

.PHONY: test
test:
	@docker run --rm -it \
		--name $(PROJECT) \
		--volume $(PWD):/app \
		$(IMAGE) bundle exec rake test

.PHONY: shell
shell:
	@docker run --rm -it \
		--name $(PROJECT) \
		--volume $(PWD):/app \
		$(IMAGE) bash
