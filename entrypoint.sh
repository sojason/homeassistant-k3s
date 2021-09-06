#!/bin/bash
# This script expects to be run in a dir where a python venv is setup.
# Activate python venv
source bin/activate
# Start homeassistant with arguments from pod configuration
# Hint: -c /config --runner seems like a good start
hass $@