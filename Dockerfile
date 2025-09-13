FROM n8nio/n8n:latest

# Install Python and extraction libraries
USER root
# Determine available package manager and install dependencies accordingly
RUN if command -v apt-get >/dev/null 2>&1 ; then \
      apt-get update && apt-get install -y --no-install-recommends python3 python3-pip && \
      rm -rf /var/lib/apt/lists/* ; \
    elif command -v apk >/dev/null 2>&1 ; then \
      apk update && apk add --no-cache python3 py3-pip ; \
    fi \
    && pip3 install --no-cache-dir pymupdf python-docx python-pptx

# Return to the default user for running n8n
USER node
