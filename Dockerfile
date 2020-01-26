FROM ubuntu:19.04
RUN mkdir -p /opt/sqlitye/
ARG BINARY_PATH
WORKDIR /opt/sqlitye
RUN apt-get update && apt-get install -y \
  ca-certificates \
  libgmp-dev
COPY "$BINARY_PATH" /opt/sqlitye
CMD ["/opt/sqlitye/sqlitye-exe"]