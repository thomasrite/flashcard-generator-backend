# Flashcard Generator Backend

This repository contains everything you need to deploy a high‑quality AI‑powered flashcard generator on [n8n](https://n8n.io) using [Railway](https://railway.app) as the hosting platform and [Supabase](https://supabase.com) as your data store.  
The backend consists of:

* A **Dockerfile** that builds n8n with the necessary Python libraries for extracting text from PDF, DOCX and PPTX documents and performing OCR on images and scanned PDFs.
* A **Supabase database schema** (`supabase_schema.sql`) that defines the tables for flashcard jobs and individual flashcards.
* A **minimal n8n workflow** (`workflow.json`) implementing a three‑stage AI pipeline:
  1. **Generate** flashcards from the uploaded document.
  2. **Audit** the generated cards against the source text to find missing topics or weak cards.
  3. **Fill** gaps by generating additional cards only where necessary.

You can deploy this backend on Railway and connect it to your Supabase project.  Once running, you can upload any document via an HTTP webhook and receive a JSON response with comprehensive, high‑quality flashcards.

## Prerequisites

* A Railway account (free tier is sufficient for testing).
* A Supabase project with a Postgres database.  Run the SQL in `supabase_schema.sql` inside the Supabase SQL editor to create the required tables.
* An API key for your preferred LLM provider (e.g. OpenAI).  This is used by n8n’s OpenAI nodes.

## Directory structure

```
flashcard_generator_backend/
├── Dockerfile            # Custom image for n8n with OCR and text extraction support
├── workflow.json         # n8n workflow implementing the three‑AI pipeline
├── supabase_schema.sql   # SQL to create the flashcard tables in Supabase
└── README.md             # This file
```

## Deploying on Railway

1. **Create a new project** in Railway and select “Deploy from GitHub.”  Point Railway at this repository.

2. Railway will detect the `Dockerfile` and build a custom n8n image.  Set the following **environment variables** in your Railway project (via the Variables tab):

   | Name                    | Description |
   | ---------------------- | ----------- |
   | `N8N_ENCRYPTION_KEY`   | A random long string used to encrypt credentials (generate yourself, e.g. with `openssl rand -hex 32`). |
   | `N8N_HOST`             | The Railway project domain (e.g. `myproject.up.railway.app`). |
   | `WEBHOOK_URL`          | The full base URL of your service (e.g. `https://myproject.up.railway.app/`). |
   | `OPENAI_API_KEY`       | Your OpenAI API key (or other provider’s key, depending on your n8n nodes). |
   | `SUPABASE_URL`         | Your Supabase project URL (e.g. `https://xyzcompany.supabase.co`). |
   | `SUPABASE_ANON_KEY`    | Supabase anon key or service role key (depending on how you query). |
   | `SUPABASE_SECRET_KEY`  | Optional: service role key if you wish to perform inserts/updates from n8n. |

3. **Deploy** the project.  After the first deployment finishes, Railway will assign a domain and start n8n.  Open the Railway URL in your browser and complete the initial n8n onboarding (create an admin user).

4. In the n8n dashboard, **import** the workflow: click the menu icon → “Import” → paste the JSON from `workflow.json`.  Save and activate the workflow.

5. Copy the generated **webhook URL** from the Webhook node in the workflow (it will look like `https://myproject.up.railway.app/webhook/flashcards`).  You can now send POST requests to this endpoint with a JSON body containing:

```json
{
  "fileUrl": "https://example.com/your-document.pdf",
  "depth": "detailed",        // optional: "concise" or "detailed" (default: detailed)
  "targetCount": 120,          // optional: desired number of cards
  "bloomLevel": "understand/analyze",  // optional: target Bloom’s taxonomy level
  "clozeRatio": 0.25,          // optional: fraction of cards to be cloze deletions
  "courseTag": "Biology_Unit1"   // optional: top‑level tag for all cards
}
```

The workflow will download the file, extract text, run the three‑stage AI pipeline, and respond with a JSON object containing the generated cards and an audit summary.  You can then use additional n8n nodes (e.g. HTTP Request) to persist the cards into your Supabase tables using the `SUPABASE_*` environment variables.

## Connecting to Supabase

The supplied workflow does not automatically write to Supabase because the credentials are environment‑specific.  To persist results:

1. In the n8n editor, insert an **HTTP Request** node after the final Merge step.  Configure it to **POST** to your Supabase REST endpoint (e.g. `{{ $env.SUPABASE_URL }}/rest/v1/flashcards`) with appropriate headers (`apikey: {{$env.SUPABASE_ANON_KEY}}`, `Content-Type: application/json`) and the body containing the cards.

2. Alternatively, use n8n’s built‑in Supabase node (if available) to connect via the `SUPABASE_URL` and service role key.

Refer to the Supabase docs for details on interacting with PostgREST endpoints.

## Developing locally

If you wish to run this project locally, install [n8n](https://docs.n8n.io/getting-started/installation/) and run:

```bash
docker build -t flashcard-n8n .
docker run -p 5678:5678 --env-file .env -it flashcard-n8n
```

Create a `.env` file with the environment variables listed above.  Once running, open `http://localhost:5678` to access the n8n UI, import the workflow and start testing.

## Next steps

* Expand the workflow to save the generated cards and job status directly into Supabase using the HTTP Request node.
* Add email notifications (e.g. using Resend or another SMTP service) after the cards are generated.
* Build a frontend (for example with Lovable) that allows users to upload documents and receive flashcards.

This backend provides a strong foundation for an automated flashcard generator and can be extended to suit your specific needs.
