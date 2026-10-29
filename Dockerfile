ARG PYTHON_BUILDER=registry.access.redhat.com/ubi9/python-39@sha256:72e8ed5f454c640a2509bb9ee696bedb54b5cf503eb913cdfa0b32ce0dfd5f6c

FROM ${PYTHON_BUILDER} AS python-deps
USER 0
COPY requirements.txt /tmp/requirements.txt
# Hermetic: source Hermeto env so pip uses the offline index.
RUN set -eux; \
  if [ -f /cachi2/cachi2.env ]; then . /cachi2/cachi2.env; \
  elif [ -f /cachi2/output/cachi2.env ]; then . /cachi2/output/cachi2.env; fi; \
  pip3 install --no-cache-dir --prefix=/opt/egress -r /tmp/requirements.txt; \
  find /opt/egress/bin -type f -exec sed -i '1s|^#!.*|#!/usr/libexec/platform-python|' {} \;

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
COPY --from=python-deps /opt/egress /opt/egress
ENV PATH="/opt/egress/bin:${PATH}"
ENV PYTHONPATH="/opt/egress/lib/python3.9/site-packages:/opt/egress/lib64/python3.9/site-packages"

USER 1001
CMD ["/bin/bash"]
