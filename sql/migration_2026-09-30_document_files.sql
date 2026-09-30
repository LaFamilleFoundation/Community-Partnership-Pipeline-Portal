-- ============================================================
-- Migration 2026-09-30 — attach uploaded files to document records
--
-- The app has uploaded files to the "documents" Storage bucket since the
-- 2026-08-22 release, but the documents table never had a column to record
-- where each file went, so every upload was orphaned: the file landed in
-- Storage, the path was never saved, and no row could offer View/Download.
--
-- This adds the columns, creates the bucket + policy if missing (so a fresh
-- project matches production), and re-links any already-uploaded files to
-- their document rows. Uploads are stored as
--   <community_id>/<document_id>-<timestamp>-<filename>
-- so the owning document can be recovered from the object name.
--
-- Safe to re-run.
-- ============================================================

alter table documents add column if not exists file_path text;
alter table documents add column if not exists file_name text;

-- ---------- STORAGE BUCKET ----------
insert into storage.buckets (id, name, public, file_size_limit)
values ('documents', 'documents', false, 26214400)
on conflict (id) do nothing;

drop policy if exists "authenticated_all_documents_bucket" on storage.objects;
create policy "authenticated_all_documents_bucket" on storage.objects
  for all using (bucket_id = 'documents' and auth.role() = 'authenticated')
  with check (bucket_id = 'documents' and auth.role() = 'authenticated');

-- ---------- BACKFILL ----------
-- Link each document with no file to its most recent matching upload.
update documents d
set file_path = o.name,
    file_name = regexp_replace(split_part(o.name, '/', 2), '^[0-9a-f-]{36}-[0-9]+-', '')
from (
  select distinct on (substring(split_part(name, '/', 2) from 1 for 36))
         name, substring(split_part(name, '/', 2) from 1 for 36) as doc_id
  from storage.objects
  where bucket_id = 'documents'
  order by substring(split_part(name, '/', 2) from 1 for 36), created_at desc
) o
where d.file_path is null
  and d.id::text = o.doc_id;
