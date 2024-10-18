# Configuration, override port with usage: make PORT=4200
PORT ?= 4100
REPO_NAME ?= portfolio_2025
LOG_FILE = /tmp/jekyll$(PORT).log

SHELL = /bin/bash -c
.SHELLFLAGS = -e # Exceptions will stop make, works on MacOS

# Phony Targets, makefile housekeeping for below definitions
.PHONY: default server clean stop

# Call server, then verify and start logging
default: server
	@echo "Terminal logging starting, watching server..."
	@(tail -f $(LOG_FILE)) &

# Start the local web server
server: stop
	@echo "Starting server..."
	@@nohup bundle exec jekyll serve -H 127.0.0.1 -P $(PORT) > $(LOG_FILE) 2>&1 & \
		PID=$$!; \
		echo "Server PID: $$PID"
	@@until [ -f $(LOG_FILE) ]; do sleep 1; done

# Stop the server and kill processes
stop:
	@echo "Stopping server..."
	@@lsof -ti :$(PORT) | xargs kill >/dev/null 2>&1 || true
	@echo "Stopping logging process..."
	@@ps aux | awk -v log_file=$(LOG_FILE) '$$0 ~ "tail -f " log_file { print $$2 }' | xargs kill >/dev/null 2>&1 || true
	@# removes log
	@rm -f $(LOG_FILE)

# Clean up project derived files, to avoid run issues stop is dependency
clean: stop
	@echo "Removing _site directory..."
	@rm -rf _site
