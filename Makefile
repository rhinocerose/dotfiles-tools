SHELL := /bin/bash

# The directory of this file
DIR := $(shell echo $(shell cd "$(shell  dirname "${BASH_SOURCE[0]}" )" && pwd ))

# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

deploy: ## Run all roles
	ansible-playbook --ask-become-pass -i "localhost," -c local deploy.yml

deploy-server: ## Run the server role and all included roles
	ansible-playbook --ask-become-pass -i "localhost," -c local deployServer.yml

update-dotfiles: ## Update the dotfiles
	ansible-playbook --ask-become-pass -i "localhost," -c local updateDotfiles.yml

ansible: ## Install ansible
	if which pacman; then \
		sudo pacman --noconfirm -S ansible; \
	elif which apt-add-repository; then \
		sudo apt-add-repository -y ppa:ansible/ansible && \
		sudo apt-get update && \
		sudo apt-get install -y ansible; \
	elif [[ $$(cat /etc/os-release  | grep debian | wc -l) -gt 0 ]]; then \
		sudo echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list && \
		sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 && \
		sudo apt-get update && \
		sudo apt-get -y install ansible; \
	fi


test: ## Perform travis tests
	ansible-playbook -i "localhost," -c local .deployTest.yml
