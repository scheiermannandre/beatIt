.PHONY: test lint format generate wgenerate help run locale coverage prepareCommit

.DEFAULT_GOAL := help

help: ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

test: ## run tests
	dlcov --lcov-gen="flutter test --coverage"

lint: ## lint and autoformat this project
	flutter analyze
	dart format --set-exit-if-changed .

format: ## lint and autoformat this project
	dart format .

locale: ## generate locale files
	flutter gen-l10n

coverage: ## generate coverage report
	flutter test --coverage
	genhtml coverage/lcov.info -o coverage/html
	open coverage/html/index.html

generate: ## run build runner
	dart run build_runner build

wgenerate: ## run build runner in watch mode
	dart run build_runner watch -d

prepareCommit: ## prepare commit
	flutter analyze
	dart format --set-exit-if-changed .
	flutter test --coverage