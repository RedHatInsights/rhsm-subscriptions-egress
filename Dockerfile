FROM registry.redhat.io/rhel8/postgresql-10
USER root
RUN curl https://raw.githubusercontent.com/pypa/pipenv/master/get-pipenv.py | /usr/libexec/platform-python
ADD Pipfile.lock .
ADD Pipfile .
RUN pipenv sync --python /usr/libexec/platform-python
USER 1001
CMD /bin/bash
