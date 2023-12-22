# PPTX Extractor

This project contains a Dockerized script for extracting content from PPTX files.

### Prerequisites

- Docker
- Make

### Building

1. Clone the repository:

~~~bash
git clone https://github.com/yourusername/pptx-extractor.git
cd pptx-extractor
~~~

2. Build the Docker image using the Makefile:

~~~bash
make build
~~~

### Running

1. Run the Docker container with the Makefile:

~~~bash
make run
~~~

Extracted text and images content from the PPTX file will be placed into the `result` directory.

### Cleaning

~~~bash
make clean
~~~

### License

This project is licensed under the GPL v3.0 - see the [LICENSE.md](LICENSE.md) file for details.
