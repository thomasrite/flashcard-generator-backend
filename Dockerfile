FROM n8nio/n8n:latest

# Install system packages necessary for PDF/PPTX/DOCX extraction and OCR
# - tesseract‑ocr and poppler-utils provide OCR and PDF to text conversion
# - python3 and pip are installed to use Python extraction libraries
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
        tesseract-ocr tesseract-ocr-eng poppler-utils python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages for extracting text from various document formats
# - PyMuPDF for PDF
# - python-docx for DOCX
# - python-pptx for PPTX
RUN pip3 install --no-cache-dir pymupdf python-docx python-pptx

# Drop back to the default non-root user for running n8n
USER node
