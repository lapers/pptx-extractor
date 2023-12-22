all: clean build run

build:
	docker build -t pptx-extractor .

.PHONY: run
run:
	[ ! -d result ] && mkdir result || true
	@read -p "Enter the path to the presentation file: " presentation_path; \
	presentation_path=$$(realpath $$presentation_path); \
	docker run -v "$$presentation_path:/data/presentation.pptx" -v "./result:/data/result" pptx-extractor /data/presentation.pptx

clean:
	[ -d result ] && rm -rf result || true
