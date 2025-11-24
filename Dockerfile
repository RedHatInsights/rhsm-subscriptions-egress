FROM registry.redhat.io/rhel9/postgresql-13

ARG VERSION=1.0.0

# Required labels for Enterprise Contract
LABEL name="rhsm-subscriptions-egress"
LABEL maintainer="Red Hat, Inc."
LABEL version="rhel9"
LABEL release="${VERSION}"
LABEL vendor="Red Hat, Inc."
LABEL url="https://github.com/RedHatInsights/rhsm-subscriptions-egress"
LABEL com.redhat.component="rhsm-subscriptions-egress"
LABEL distribution-scope="public"
LABEL io.k8s.description="RHSM Subscriptions Egress service based on RHEL9 PostgreSQL."
LABEL description="RHSM Subscriptions Egress service based on RHEL9 PostgreSQL."

#label for EULA
LABEL com.redhat.license_terms="https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI"

USER root
RUN curl https://raw.githubusercontent.com/pypa/pipenv/refs/tags/v2025.0.2/get-pipenv.py | /usr/libexec/platform-python
ADD Pipfile.lock .
ADD Pipfile .
RUN pipenv sync --python /usr/libexec/platform-python
USER 1001
CMD /bin/bash
