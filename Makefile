##############################################################################################
# PROJECT SPECIFIC COMMANDS                                                                  #
# Make sure to prefix targets with name of project
##############################################################################################
# source .venv-win/Scripts/activate


PROJECT_NAME = FakturAI
PROJECT_DIR = .
SOURCE_DIR = fai

VENV_DIR=.venv-win

REQ_FILE=requirements.in
FROZEN_REQ_FILE=requirements.txt
PYTHON=python

PYCODESTYLE_EXCLUDE='.venv-win'

CONFIG_DIR=.config-files


########################################################
# Python formatting tools                      
########################################################

.PHONY: run
run:
	$(PYTHON) $(SOURCE_DIR)/main_gradio.py


.PHONY: clean
clean:
	find $(PROJECT_DIR) -name __pycache__ | xargs rm -rf
	find $(PROJECT_DIR) -name '*.pyc' -delete
	rm -rf .*cache

.PHONY: reformat
reformat:
	isort --sp $(CONFIG_DIR)/pyproject.toml $(SOURCE_DIR) --known-local-folder $(SOURCE_DIR)
	black --config $(CONFIG_DIR)/pyproject.toml $(SOURCE_DIR) --target-version py310


# ipython kernel install --user --name=NasdaqNordic

########################################################
# Python testing tools                      
########################################################

.PHONY: test-lint-version
test-lint-version:
	$(PYTHON) -m pycodestyle --version
	isort --version
	black --version

.PHONY: test-lint
test-lint:
	$(PYTHON) -m pycodestyle --config=$(CONFIG_DIR)/setup.cfg . --exclude $(PYCODESTYLE_EXCLUDE)
	isort -sp $(CONFIG_DIR)/pyproject.toml --recursive --check-only $(SOURCE_DIR) $(PROJECT_DIR)
	black --config $(CONFIG_DIR)/pyproject.toml --check $(SOURCE_DIR) $(PROJECT_DIR)



########################################################
# Python VENV tools                      
########################################################

.PHONY: env-create
env-create:
	python -m venv $(VENV_DIR) --prompt $(PROJECT_NAME)
	$(PYTHON) -m pip install --upgrade pip setuptools pip-tools
	make env-sync
	# source $(VENV_DIR)/bin/activate

.PHONY: env-sync
env-sync_dep:
	pip-sync --pip-args --no-deps $(FROZEN_REQ_FILE)

.PHONY: env-delete
env-delete_dep:
	rm -rf $(VENV_DIR)

.PHONY: env-freeze
env-freeze_dep:
	pip-compile --upgrade $(REQ_FILE) --annotate -o $(FROZEN_REQ_FILE)
	sed -i '/typing=/d' $(FROZEN_REQ_FILE) # package incorrectly introduced, filtered out...
	sed -i '/typing-extensions=/d' $(FROZEN_REQ_FILE) # package incorrectly introduced, filtered out...
	sed -i '/-e file:\./d' $(FROZEN_REQ_FILE) # package incorrectly introduced, filtered out...
