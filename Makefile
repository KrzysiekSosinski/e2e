export APP_NAME = ngfp-web
export APP_PORT = 8081
export SONAR_BRANCH_NAME = $(shell git branch --show-current)
export SHA_TAG = $(shell git rev-parse --short HEAD)

AWS_ACCOUNT_ID_EEC_SHARED_SERVICES = 957766590265
AWS_REGION = us-west-2
DOCKER_RUN_ALPINE = docker run --rm -v $(PWD):/opt/app -w /opt/app alpine

# Split Docker run command for flexibility
DOCKER_RUN_CMD = docker run --env-file .env -e GRADLE_USER_HOME --rm -v $(PWD):/app -w /app
DOCKER_RUN_SONAR_PARAMS = -e SONAR_BRANCH_NAME
DOCKER_RUN_NETWORK_PARAMS = --network frontend

help:
	@grep -E '^[1-9a-zA-Z_-]+:.*?## .*$$|(^#--)' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m %-43s\033[0m %s\n", $$1, $$2}' \
	| sed -e 's/\[32m #-- /[33m/'

# Extract first target passed to make
CMD := $(wordlist 1,1,$(MAKECMDGOALS))

# Parse additional arguments beyond the first target and store them in a variable for later use
CMD_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

# Don't define any targets if we're just trying to invoke a shell on a compose service (avoids make redefine warnings)
ifneq ($(CMD),gradle)

#-- Application | Build:
install: ## Install npm
	npm install

docker-build: install ## Build Docker image
	docker build -t $(APP_NAME):$(SHA_TAG) .

#-- Application | Test:
test: ## Run unit tests
	npm run test

test-smoke: ## Run functional smoke tests
	TEST_TAG=smoke docker compose up e2e-test

test-e2e: ## Run functional smoke tests
	TEST_TAG=${TEST_TAG} docker compose up e2e-test

#-- Application | Scan:
sonar: ## Run SonarQube analysis
	$(DOCKER_RUN_CMD) $(DOCKER_RUN_SONAR_PARAMS) $(BASE_IMAGE) $(DOCKER_RUN_GRADLE) sonar

#-- Application | Run:
up: ## Run the application
	docker compose up ngfp-web

fakebackend: ## run fakebackend
	npm run fakebackend

#-- Application | Stop:
down: ## Stop the application
	docker compose down -v

endif

#-- Local Development Setup
deps_check: envfile local-git-hooks ## Check that dependencies are installed and configured correctly

envfile: ## Create .env file from .env.template
	@echo "Checking for existing .env file..."; \
	HAS_ERROR=false; \
	if [ ! -f ./.env ]; then \
		echo "$(COLOR_YELLOW)No .env file found. Copying from '.env.template'...$(COLOR_RESET)"; \
		cp ./env.template ./.env; \
		echo "$(COLOR_GREEN).env file (.env.template) copied into place (.env)!$(COLOR_RESET) $(CHECKMARK)"; \
	else \
	  	echo "Environment file found! $(CHECKMARK)"; \
	  	echo "Checking for missing keys..."; \
		ENV_TEMPLATE_KEYS=$$(grep -v '^#' ./env.template | cut -d '=' -f 1); \
		ENV_KEYS=$$(grep -v '^#' ./.env | cut -d '=' -f 1); \
		echo "$$ENV_TEMPLATE_KEYS" | sort > .env_template_keys_sorted; \
		echo "$$ENV_KEYS" | sort > .env_keys_sorted; \
		ENV_TEMPLATE_KEYS_SUBSET=$$(comm -23 .env_template_keys_sorted .env_keys_sorted); \
		rm .env_template_keys_sorted .env_keys_sorted; \
		if [ -n "$$ENV_TEMPLATE_KEYS_SUBSET" ]; then \
			echo "$(COLOR_RED)Environment file is missing the following keys: $(COLOR_RESET)"; \
			echo "$(COLOR_RED)$$ENV_TEMPLATE_KEYS_SUBSET$(COLOR_RESET)"; \
			HAS_ERROR=true; \
		else \
			echo "Environment file has all required keys! $(CHECKMARK)"; \
		fi; \
	fi; \
	if [ "$$HAS_ERROR" = "false" ]; then \
		echo "$(COLOR_GREEN)Environment file is good to go!$(COLOR_RESET) $(TADA)"; \
	else \
		echo "$(HAS_ERROR)"; \
		echo "$(COLOR_RED)Environment file is not configured correctly!$(COLOR_RESET)"; \
		echo "$(COLOR_RED)Please fix the errors above and try again.$(COLOR_RESET)"; \
		exit 1; \
	fi;

local-git-hooks: ## Setup local Git hooks (see https://pre-commit.com/#install for pre-commit installation instructions)
ifeq ($(CI),true)
	@echo "Running in CI, skipping dependency check"
else
	@echo "Checking for pre-commit hook..."; \
	HAS_ERROR=false; \
	if [ ! -f ./.git/hooks/pre-commit ]; then \
		echo "$(COLOR_YELLOW)No pre-commit hook file found. Copying from 'hooks/pre-commit'...$(COLOR_RESET)"; \
		cp ./hooks/pre-commit ./.git/hooks/pre-commit; \
		chmod +x ./.git/hooks/pre-commit; \
		echo "$(COLOR_GREEN)Pre-commit hook file (hooks/pre-commit) copied into place (.git/hooks/pre-commit)!$(COLOR_RESET) $(CHECKMARK)"; \
	else \
		if diff -q ./hooks/pre-commit ./.git/hooks/pre-commit >/dev/null; then \
			echo "Pre-commit hook file is up to date! $(CHECKMARK)"; \
		else \
			echo "$(COLOR_YELLOW)Pre-commit hook file is out of date or has been modified. Replacing...$(COLOR_RESET)"; \
			cp ./hooks/pre-commit ./.git/hooks/pre-commit; \
			chmod +x ./.git/hooks/pre-commit; \
			echo "$(COLOR_GREEN)Pre-commit hook file replaced!$(COLOR_RESET) $(CHECKMARK)"; \
		fi \
	fi; \
	echo "Checking for pre-commit binary..."; \
	if [ -z $$(which pre-commit) ]; then \
		echo "$(COLOR_RED)No pre-commit binary found in PATH ($(PATH)).$(COLOR_RESET)"; \
		echo "$(COLOR_GREEN)Please install the pre-commit binary using Homebrew or Python's package manager pip or pip3.$(COLOR_RESET)"; \
		echo "\t$(COLOR_GREEN)brew install pre-commit$(COLOR_RESET)"; \
		echo "\t$(COLOR_GREEN)pip3 install pre-commit$(COLOR_RESET)"; \
		echo "$(COLOR_GREEN)See https://pip.pypa.io/en/stable/installation/ if you don't have pip or pip3$(COLOR_RESET)"; \
		HAS_ERROR=true; \
	else \
		echo "Pre-commit binary found in '$$(which pre-commit)'! $(CHECKMARK)"; \
	fi; \
	if [ "$$HAS_ERROR" = "false" ]; then \
		echo "$(COLOR_GREEN)Git hooks are good to go!$(COLOR_RESET) $(TADA)"; \
	else \
		echo "$(HAS_ERROR)"; \
		echo "$(COLOR_RED)Git hooks are not configured correctly!$(COLOR_RESET)"; \
		echo "$(COLOR_RED)Please fix the errors above and try again.$(COLOR_RESET)"; \
		exit 1; \
	fi
endif

# NOTE .PHONY denotes that the target does _not_ correspond to any local file of the same name (true of all our targets)
.PHONY: $(MAKECMDGOALS)

# Define color escape codes
COLOR_RESET = \033[0m
COLOR_GREEN = \033[32m
COLOR_YELLOW = \033[33m
COLOR_RED = \033[31m

# Define Unicode characters for emojis
CHECKMARK = \xE2\x9C\x85  # Checkmark emoji
TADA = \xF0\x9F\x8E\x89 # Tada emoji
