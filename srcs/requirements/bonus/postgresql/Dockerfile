
FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        postgresql \
        postgresql-contrib \
    && rm -rf /var/lib/apt/lists/*

# Prevent automatic cluster creation during image build
RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d

COPY tools/setup-postgresql.sh /usr/local/bin/setup-postgresql.sh

RUN chmod +x /usr/local/bin/setup-postgresql.sh

EXPOSE 5432

CMD ["/usr/local/bin/setup-postgresql.sh"]


# FROM debian:bookworm: uses Debian 12.
# postgresql: installs the PostgreSQL database server.
# postgresql-contrib: installs additional PostgreSQL extensions.
# COPY: copies our startup script into the image.
# EXPOSE 5432: documents PostgreSQL's internal port.
# CMD: starts our configuration script.