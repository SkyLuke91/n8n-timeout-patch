FROM n8nio/n8n:latest

USER root

# Install undici
RUN mkdir -p /opt/extra && \
    npm --prefix /opt/extra install undici@5 && \
    chown -R node:node /opt/extra

# Copy patch into image
COPY patch-http-timeouts.js /opt/patch/patch-http-timeouts.js
RUN chown -R node:node /opt/patch

# Set environment variables
ENV NODE_PATH=/opt/extra/node_modules
ENV NODE_OPTIONS="--require /opt/patch/patch-http-timeouts.js"

USER node
