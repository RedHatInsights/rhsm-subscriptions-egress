FROM registry.redhat.io/rhel9/postgresql-13
USER root
RUN curl https://raw.githubusercontent.com/pypa/pipenv/refs/tags/v2025.0.2/get-pipenv.py | /usr/libexec/platform-python
ADD Pipfile.lock .
ADD Pipfile .
RUN pipenv sync --python /usr/libexec/platform-python
USER 1001
CMD /bin/bash
