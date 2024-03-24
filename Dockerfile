FROM nginx:1.25.0
LABEL Name = "legendsCaching"
LABEL Version = "2.1.0"
LABEL org.label-schema.name="legendsSystems Docker FiveM Cache System" \
    org.label-schema.vendor="legendsSystems" \
    org.label-schema.url="https://hub.docker.com/u/legendssystems" \
    org.label-schema.description="Caching system using nginx and docker to stream content files for FiveM Servers" \
    org.label-schema.version="${latestArtifactNum}" \
    org.label-schema.vcs-url="${latestArtifactURL}" \
    org.opencontainers.image.title="legendsSystems Base Image" \
    org.opencontainers.image.vendor="legendsSystems" \
    org.opencontainers.image.licenses="GPL-2.0-only" \
    org.opencontainers.image.created="$(date --rfc-3339=ns)"

RUN apt-get update && \
    apt-get install --no-install-recommends -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /srv/cache
RUN mkdir -p /etc/nginx/conf.d

COPY files/nginx.conf /etc/nginx/default.conf
COPY files/sites-available.conf /etc/nginx/conf.d/sites-available.conf
COPY certs/ /etc/ssl

HEALTHCHECK CMD curl --fail http://localhost || exit 1

EXPOSE 80
EXPOSE 443
EXPOSE 30120

CMD ["nginx", "-g", "daemon off;"]
