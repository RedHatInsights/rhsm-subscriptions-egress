rhsm-subscriptions-egress
-------------------------

Dockerfile for RHEL-based build of the service started in https://github.com/tumido/egress

Note that anywhere the `aws` command is is needed, it should be run as `pipenv run aws`.

If you wish to use the environment locally, you can use the included `Pipfile/Pipfile.lock`, as long as the local environment has a Python 3.6 interpreter available (`pipenv sync`)
