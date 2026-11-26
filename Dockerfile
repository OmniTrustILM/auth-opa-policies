# Add build args to allow easy version updates
ARG NGINX_BUILD_IMAGE=nginx:1.31.10-alpine
ARG NGINX_RUN_IMAGE=nginx/nginx-unprivileged:1.30.8-alpine
ARG OPA_IMAGE=openpolicyagent/opa:1.10.0-static@sha256:32f1544858be83d51ba15838ba0fca19235e260a4fb46b52fe3c977f6a131e40

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
