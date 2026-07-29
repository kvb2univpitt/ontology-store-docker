FROM postgres:14.19-alpine3.22

ENV PGDATA=/var/lib/postgresql/pgdata

COPY resources/i2b2-data-demo_1.8.3.dump /var/lib/postgresql/i2b2-data-demo_1.8.3.dump
COPY resources/test_cases/ /var/lib/postgresql/

COPY resources/init-db.sh /docker-entrypoint-initdb.d/init-db.sh
