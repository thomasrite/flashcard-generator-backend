-- Database schema for storing flashcard jobs and flashcards
--
-- Run this SQL in your Supabase project (e.g. via the SQL editor).
-- The schema mirrors the structure described in the workflow design.

create table if not exists flashcard_jobs (
    id uuid primary key default gen_random_uuid(),
    job_id text unique not null,
    user_id uuid, -- optional user reference
    file_url text,
    status text check (status in ('queued','processing','done','error')) default 'queued',
    total_cards int,
    created_at timestamptz default now()
);

create table if not exists flashcards (
    id uuid primary key default gen_random_uuid(),
    job_id text references flashcard_jobs(job_id) on delete cascade,
    card_uid text unique not null,
    type text check (type in ('basic','cloze','multi')),
    question text,
    answer text,
    explanation text,
    bloom text,
    tags text[],
    topic_path text,
    difficulty int,
    sources jsonb,
    created_at timestamptz default now()
);
