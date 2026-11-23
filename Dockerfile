# Add build args to allow easy version updates
ARG NGINX_BUILD_IMAGE=nginx:1.29.2-alpine
ARG NGINX_RUN_IMAGE=nginx/nginx-unprivileged:1.30.7-alpine
ARG OPA_IMAGE=openpolicyagent/opa:1.9.0-static@sha256:60b6af32b58377718546ac7d4634eecbfe50ec36f7d3ca3f8ebf515f9826c2ac

FROM ${OPA_IMAGE} AS opa

FROM ${NGINX_BUILD_IMAGE} AS build

COPY --from=opa /opa /usr/local/bin/opa
COPY ./policies /usr/share/nginx/html/bundles/policies

WORKDIR /usr/share/nginx/html/bundles

RUN opa build -b policies && rm -r policies

# package to rootless image
FROM ${NGINX_RUN_IMAGE}

LABEL org.opencontainers.image.authors="ILM <ilm@omnitrust.com>"

COPY --from=build /usr/share/nginx/html /usr/share/nginx/html
