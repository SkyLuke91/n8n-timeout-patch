# Patch for getting n8n to use LLM without Timeouts

This comes WITHOUT WARRANTY to work nor to not delete your data!
You have been warned!

I'm not involved in n8n, and I'm not an expert in TypeScript whatsoever - so use at your own risk!

# Prereqs

n8n has two timeouts that don't work with long running LLMs.
First, node.js introduced an http timeout value, which is actually (AUG 25) not set and there fore times out at 5 minutes.
http-Requests taking longer as this will time out (so for the frontend of n8n).

The second one is with undici used for the connection between n8n and the LLM.

Both need to be enhanced.

# Docker image

Enhance the docker image by undici - see the Dockerfile in the repo here.
It will just install unidici in the image.
Make sure to use that image build further on!

# Patch

Use the patch given in this repo and mount it into a running container - that also might be done just read only.

You may also push that file into your docker image - I didn't as I would like to be able to configure / change things later without having to rebuild the image again.

## Build image

```
docker build -t my_n8n:latest .
```

# Change / Add your docker environment variables

Add the following values to your docker environment variables, either in a docker compose or your .env file.

Make sure to replace the /path/to/your/mount with the path where you mounted the patch at.

```
      # make sure undici is accessible (if you installed it into /opt/extra in your image)
      - NODE_PATH=/opt/extra/node_modules
      - NODE_FUNCTION_ALLOW_EXTERNAL=undici

      # require the patch at node startup
      - NODE_OPTIONS=--require /opt/patch/patch-http-timeouts.js

      # n8n HTTP / keepalive tuning from the repo
      - N8N_HTTP_REQUEST_TIMEOUT=0       # 0 = disable per-request timeout
      - N8N_HTTP_HEADERS_TIMEOUT=120000  # 2 minutes; must be > keep-alive
      - N8N_HTTP_KEEPALIVE_TIMEOUT=65000 # 65 seconds

      # undici / outbound fetch timeouts
      - FETCH_HEADERS_TIMEOUT=1800000   # time allowed to receive response headers (ms)
      - FETCH_BODY_TIMEOUT=12000000     # total time allowed to receive full body/stream (ms)
      - FETCH_CONNECT_TIMEOUT=600000    # total time for waiting for a connect (ms)
      - FETCH_KEEPALIVE_TIMEOUT=65000   # keepalive for outbound fetch
```


---

That's it - now your long running LLM-Calls should go through when the docker container is restarted.
