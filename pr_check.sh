#!/bin/bash
podman build --tag egress .
podman run --rm -it egress pipenv run aws --version
