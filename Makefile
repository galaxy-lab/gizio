UNAME = $(shell uname)
ifeq ($(UNAME),Darwin)
	OPEN = open
endif
ifeq ($(UNAME),Linux)
	OPEN = xdg-open
endif

.PHONY: help
help:
	cat Makefile

# env

.PHONY: init
init: env
env:
	conda env create -f environment.yml -p env
	env/bin/pip install -e .

.PHONY: up
up:
	conda env update -f environment.yml -p env
	env/bin/pip install -e .

# code

.PHONY: fmt
fmt:
	black src tests setup.py

.PHONY: lint
lint:
	pylint src

.PHONY: test
test: data
	pytest tests

# doc

.PHONY: doc
doc: data
	# Strip notebook output
	jupyter nbconvert --to notebook --inplace --ClearOutputPreprocessor.enabled=True docs/*.ipynb
	# Remove existing API docs to build from scratch
	rm -rf docs/api
	# Build HTML output
	cd docs && make html
	# Open to review
	$(OPEN) docs/_build/html/index.html

# misc

.PHONY: data
data: data/FIRE_M12i_ref11
data/FIRE_M12i_ref11:
	mkdir -p data
	cd data && curl http://yt-project.org/data/FIRE_M12i_ref11.tar.gz | tar xz
