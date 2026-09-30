-- ============================================================
-- LFF Partnership Pipeline — Supabase schema
-- Run this entire file once in Supabase SQL Editor (Project → SQL Editor → New query).
-- Safe to re-run: uses IF NOT EXISTS / DROP POLICY IF EXISTS guards.
-- ============================================================

create extension if not exists pgcrypto;

-- ---------- COMMUNITIES ----------
create table if not exists communities (
  id text primary key,
  name text not null,
  full_org_name text,
  location text,
  stage text not null default 'Submission Received'
    check (stage in (
      'Submission Received','Under Review','Due Diligence','Site Visit',
      'MOU Drafting','Active / Implementation','Exit-Readiness Tracking',
      'Closed / Exited','On Hold / Declined'
    )),
  date_received date,
  founded_year text,
  member_count text,
  primary_contact text,
  other_leaders text,
  project_type text,
  water_source text,
  water_problems text,
  beneficiaries text,
  impact text,
  proposed_infrastructure text,
  proposed_location text,
  technical_specs text,
  budget_estimate text,
  timeline text,
  management_committee text,
  user_fees text,
  maintenance_plan text,
  org_role text,
  exit_vision text,
  me_commitment text,
  prior_projects text,
  other_funders text,
  referral_source text,
  org_references text,
  community_contribution text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- DOCUMENTS ----------
create table if not exists documents (
  id uuid primary key default gen_random_uuid(),
  community_id text not null references communities(id) on delete cascade,
  name text not null,
  status text not null default 'missing' check (status in ('valid','expired','missing')),
  note text,
  file_path text,   -- object path in the "documents" Storage bucket
  file_name text,   -- original filename, used for downloads
  created_at timestamptz not null default now()
);
alter table documents add column if not exists file_path text;
alter table documents add column if not exists file_name text;

-- ---------- FLAGS ----------
create table if not exists flags (
  id uuid primary key default gen_random_uuid(),
  community_id text not null references communities(id) on delete cascade,
  flag_text text not null,
  created_at timestamptz not null default now()
);

-- ---------- COMMS ----------
create table if not exists comms (
  id uuid primary key default gen_random_uuid(),
  community_id text not null references communities(id) on delete cascade,
  comm_date date not null default current_date,
  channel text not null default 'Other',
  logged_by text,
  summary text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_documents_community on documents(community_id);
create index if not exists idx_flags_community on flags(community_id);
create index if not exists idx_comms_community on comms(community_id);

-- keep updated_at current on edits
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_communities_updated_at on communities;
create trigger trg_communities_updated_at
  before update on communities
  for each row execute function set_updated_at();

-- ============================================================
-- ROW LEVEL SECURITY
-- Data is private: only signed-in users may read or write anything.
-- Combine this with disabling public sign-ups in Authentication settings
-- (see README) so only people you've invited can ever sign in at all.
-- ============================================================
alter table communities enable row level security;
alter table documents   enable row level security;
alter table flags       enable row level security;
alter table comms       enable row level security;

drop policy if exists "authenticated_all_communities" on communities;
create policy "authenticated_all_communities" on communities
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "authenticated_all_documents" on documents;
create policy "authenticated_all_documents" on documents
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- Uploaded document files live in a private bucket, same signed-in-only rule.
insert into storage.buckets (id, name, public, file_size_limit)
values ('documents', 'documents', false, 26214400)
on conflict (id) do nothing;

drop policy if exists "authenticated_all_documents_bucket" on storage.objects;
create policy "authenticated_all_documents_bucket" on storage.objects
  for all using (bucket_id = 'documents' and auth.role() = 'authenticated')
  with check (bucket_id = 'documents' and auth.role() = 'authenticated');

drop policy if exists "authenticated_all_flags" on flags;
create policy "authenticated_all_flags" on flags
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "authenticated_all_comms" on comms;
create policy "authenticated_all_comms" on comms
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- ============================================================
-- SEED DATA — your 4 existing records, migrated as-is
-- ============================================================
insert into communities (id, name, full_org_name, location, stage, date_received, founded_year, member_count, primary_contact, other_leaders, project_type, water_source, water_problems, beneficiaries, impact, proposed_infrastructure, proposed_location, technical_specs, budget_estimate, timeline, management_committee, user_fees, maintenance_plan, org_role, exit_vision, me_commitment, prior_projects, other_funders, referral_source, org_references, community_contribution) values
  ('oavm', 'OAVM', 'Òganizasyon Agrikòl pou yon Vi Miyò (OAVM)', 'Douillette, 1ère Rendel, Chardonnières, Sud', 'Under Review', '2026-08-10'::date, '1997 (15 March 1997)', '58 members (23 women, 35 men)', 'Aguilnaire Seide — President — 3802-9777 — saguilnaire@gmail.com', 'Johanne Francois — Secretary — 3626-9641', 'Water infrastructure', 'Spring at Calio — ~2 km from Douillette, ~3 km from Derouze', 'Water quality issues, distance, fever/diarrhea outbreaks (waterborne illness)', '~300 households · 2,500 direct beneficiaries · 50,000 indirect beneficiaries', 'Affects livelihoods, education, and health (waterborne illness) across the community', 'Pumping system with reservoir and PVC distribution piping serving Douillette and Derouze', 'Reservoir on private land donated to the community; PVC piping to households', 'Not yet known — to be studied jointly if the dossier is of interest to LFF', 'Not yet developed — to be prepared jointly with LFF', '4–6 months execution', '3-person committee: 2 OAVM members + 1 community member, selected with local authorities', 'Yes — in-kind plus billed/invoiced payments', 'OAVM + local authorities; funded by water-use fees collected', 'Labor, materials, land, and ongoing support', 'OAVM and the steering committee take over the project long-term', 'Yes — agreed to 5–7 years of annual M&E data (system function, users, maintenance, harvests, challenges)', 'Corn mill (moulin à maïs) project — currently functional, agricultural transformation', 'PAGAI / Swiss Cooperation, 2022–2023 — 750,000 HTG (corn mill + corn/black bean storage)', 'Word of mouth — researchers visiting from Les Cayes saw families traveling long distances for water and suggested contacting LFF', 'Swiss Cooperation (PAGAI) · Fondation MACAYA · FEDER · OBALA · local CASEC', '50,000 HTG cash (~20% of total budget) + labor, materials, land. No other partners on this project.')
  on conflict (id) do nothing;
insert into communities (id, name, full_org_name, location, stage, date_received, founded_year, member_count, primary_contact, other_leaders, project_type, water_source, water_problems, beneficiaries, impact, proposed_infrastructure, proposed_location, technical_specs, budget_estimate, timeline, management_committee, user_fees, maintenance_plan, org_role, exit_vision, me_commitment, prior_projects, other_funders, referral_source, org_references, community_contribution) values
  ('teachaiti-stmichel-livestock', 'TeacHaiti — St. Michel Livestock', 'Teach Haiti', 'St. Michel — existing Teach Haiti school property (LFF education/WASH partnership site)', 'Due Diligence', '2026-07-28'::date, NULL, NULL, 'Miquette McMahon — Founder & Executive Director', NULL, 'Livestock & Food Security (agriculture / vocational education)', 'N/A — agriculture/livestock project, not water infrastructure', NULL, 'Students and families at Teach Haiti''s school; broader St. Michel community', 'Improved student/family nutrition, hands-on vocational training in animal husbandry, and a sustainable income source for the school', 'Small livestock farm — 7 roosters, 50 chickens, 4 pigs, 10 goats — plus animal housing, pens & fencing', 'On Teach Haiti''s existing, secured school property in St. Michel', 'Budget breakdown: Roosters $245 · Chickens $1,250 · Pigs $800 · Goats $1,200 · Housing/pens/fencing $500 · Initial feed $250 · Veterinary care, equipment & supplies $755', '$5,000 requested initially (28 Jul); follow-up on 5 Aug clarified total project cost is a $5,000–$7,500 range — the extra $2,500 would fund expanded shelter/fencing', 'Not yet specified', 'Overseen by a veterinary technician Teach Haiti trained several years ago — responsible for routine care, health monitoring, recordkeeping, vaccination schedules, illness identification, and coordinating outside professional help when needed', 'N/A', 'Vet tech will confirm vaccine/medication availability and identify reliable local suppliers before animals are purchased', 'Full implementation — housing, staffing, and on-site supervision on Teach Haiti''s own property', 'Designed to become self-sustaining: revenue from egg, chicken, piglet, and goat sales reinvested into feed, veterinary care, infrastructure maintenance, and growth, reducing dependency on outside funding over time', 'Will track expenses, births, losses, and sales, and provide a projection of ongoing expenses, anticipated breeding/production, and expected revenue', 'Existing LFF partner — clean water project at Teach Haiti''s St. Michel school, cited in this proposal as a past success', 'Not specified', 'Established partner — ongoing LFF relationship (St. Michel education/WASH partnership)', NULL, 'Not specified — full $5,000–$7,500 requested from LFF; no community/organizational cash or in-kind match stated')
  on conflict (id) do nothing;
insert into communities (id, name, full_org_name, location, stage, date_received, founded_year, member_count, primary_contact, other_leaders, project_type, water_source, water_problems, beneficiaries, impact, proposed_infrastructure, proposed_location, technical_specs, budget_estimate, timeline, management_committee, user_fees, maintenance_plan, org_role, exit_vision, me_commitment, prior_projects, other_funders, referral_source, org_references, community_contribution) values
  ('ojeads-laval-cistern', 'OJEADS — Laval Cistern', 'Organisation des Jeunes en Action pour le Développement du Sud (OJEADS)', 'Laval, 2ème Section, Commune des Cayes, Département du Sud', 'Due Diligence', '2025-05-07'::date, '~2018 (6 years old as of 2024 letter) — registered with the Ministère des Affaires Sociales et du Travail, N° STC-451270/MAST', 'Youth organization; membership count not specified. Includes an agronomist member (contact not yet made — see flags).', 'Osny Jacquet (Père Jacquet) — Coordonnateur — ojeads2018@gmail.com — +509 3759-0881 / 4314-2413', 'Franckel Charetier, Ing. — drew the construction plan. An agronomist member is also on OJEADS''s team but direct contact was never made.', 'Water infrastructure — cistern + fountain on an existing well', 'Existing well drilled by Water for Life Haiti in the 2010s, Laval — currently hand-pumped; reportedly one of the few wells that doesn''t dry up in drought', 'Manual pump is difficult to operate and limits daily access; households travel 700–800m between wells, more during dry season; waterborne illness/cholera risk cited; water-fetching burden falls on women and children, affecting school attendance', '120 households surveyed as eventual users', 'Food insecurity (malnutrition), elevated infant mortality, constrained agricultural productivity, water-fetching burden on women/children affecting school attendance, waterborne disease risk including cholera', '5,000–6,000 gallon cistern + fountain with 2 taps, built on the existing well. OJEADS separately equips the well with a submersible solar pump and 4×600W panels.', 'On the existing well site, Laval 2ème Section — on Catholic (church) land. Requires a notarized written agreement confirming the water assets belong to the community (not yet drafted).', 'Fully itemized devis. Civil works totals $7,707.60 + transport 1.5% + imprévu 2% + main-d''œuvre 40% = $11,060.41. Electrical/solar totals $3,082.95. Construction plan also shows a depot, reception area, chambre, and 2 WC beyond the cistern — unexplained.', 'Total project cost $14,143.36. OJEADS contributes $3,082.95 (21.79% — fully covers the solar pump, panels, and electrical installation). Requested from LFF: $11,061.41 (civil works).', 'Not yet specified', 'Not yet specified — a water committee financial model is still requested from OJEADS', 'Not yet specified — pending OJEADS''s financial model for monthly household fees', 'Not yet specified — tied to the pending financial model', 'Full financing and installation of the solar pump, panels, and electrical system (21.79% share); LFF asked to fund the civil works', 'Not yet specified', 'Not yet specified', '6-year-old organization; prior funder was Misereor (German donor) — itemized inventory of materials/equipment received still not provided', 'Misereor (Germany) — past support; details pending', 'Edy, Water for Life Haiti — email referral, Wed, May 7, 2025, 12:06 PM', 'Water for Life Haiti (Edy)', 'OJEADS: $3,082.95 cash-equivalent (21.79% of total project cost) — covers solar pump, panels, electrical materials, and that portion''s installation labor in full')
  on conflict (id) do nothing;
insert into communities (id, name, full_org_name, location, stage, date_received, founded_year, member_count, primary_contact, other_leaders, project_type, water_source, water_problems, beneficiaries, impact, proposed_infrastructure, proposed_location, technical_specs, budget_estimate, timeline, management_committee, user_fees, maintenance_plan, org_role, exit_vision, me_commitment, prior_projects, other_funders, referral_source, org_references, community_contribution) values
  ('teachaiti-stmichel-reservoir-2023', 'TeacHaiti — St. Michel Reservoir (2023)', 'Teach Haiti (School of Hope)', 'St. Michel de l''Attalaye — Teach Haiti''s school. (Proforma letterhead lists a separate contact address: Rue L''avenir, Carrefour Saint Francique.)', 'Closed / Exited', '2022-12-19'::date, NULL, NULL, 'Miquette Denie McMahon — Founder/Director — miquette27@yahoo.com', 'Cc''d throughout the funding thread: Audige Billybert, Frantzy Jean, Kens Cazeau, Manuel Jean', 'Water infrastructure — school water reservoir/cistern', NULL, NULL, 'Teach Haiti''s St. Michel school — students and staff', 'Later cited in LFF donor materials as a completed success: school saved more than $2,200 in water costs within one year — resources reinvested directly into students.', 'Reservoir/cistern sized 14 ft × 21 ft, per contractor proforma (size doubled from the original quote per Miquette''s Dec 2022 note)', 'Teach Haiti''s St. Michel school site', 'Contractor proforma ("Bos Daveus") lists: 1 tonne fer 1/2, 1 tonne fer 3/8, tie wire, 200 sacs cement, 1,000 bloc 20, sand delivery, plus lumber/formwork rental and labor.', 'Total project cost: $15,000. LFF funded $12,000 (80%); Teach Haiti contributed $3,000 (20%). Note: the original Dec 2022 contractor proforma is quoted in inconsistent currency notation — this record relies on final USD figures Jethro confirmed directly.', 'Estimate requested Dec 2022; proforma forwarded toward construction May 2023', NULL, NULL, NULL, NULL, NULL, NULL, 'N/A — this record is itself Teach Haiti''s completed prior water project, referenced as track record in their 2026 livestock proposal', NULL, 'Existing direct partner relationship (Miquette McMahon)', NULL, 'Teach Haiti: $3,000 (20% of the $15,000 total project cost)')
  on conflict (id) do nothing;

-- documents
insert into documents (community_id, name, status, note) values ('oavm', 'Ministère des Affaires Sociales — Attestation d''enregistrement', 'valid', 'N° 237-81, issued 26 May 1997 — permanent registration, no expiry');
insert into documents (community_id, name, status, note) values ('oavm', 'Carte d''Immatriculation Fiscale (NIF)', 'expired', 'NIF 000-699-208-1 — expired 30/09/2024, renewal needed before MOU stage');
insert into documents (community_id, name, status, note) values ('oavm', 'Attestation de la Mairie des Chardonnières', 'expired', 'N° 001-143, valid May 2023–May 2025 (renewable) — expired, renewal needed');
insert into documents (community_id, name, status, note) values ('oavm', 'Budget / itemized estimate', 'missing', 'To be co-developed with LFF (item 15 of the guide)');
insert into documents (community_id, name, status, note) values ('oavm', 'Technical drawings / plans', 'missing', 'Not available yet — depends on LFF interest (item 14)');
insert into documents (community_id, name, status, note) values ('oavm', 'Photos of current water source & proposed site', 'missing', 'Not included in this submission — request during follow-up');
insert into documents (community_id, name, status, note) values ('teachaiti-stmichel-livestock', 'St. Michel Livestock & Food Security Partnership Proposal (PDF)', 'valid', 'Received 28 July 2026, 9:53 PM');
insert into documents (community_id, name, status, note) values ('teachaiti-stmichel-livestock', 'Certificat de Patente (business license)', 'valid', 'Patente N° 5507076759 · NIF 000-697-087-4 — Eduquer Haiti/Teach Haiti (EH/TH), Delmas 75. Valid FY2025–2026 (expires ~30 Sept 2026). Received 11 Aug 2026.');
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'OJEADS registration & funding request letter', 'valid', 'Registered N° STC-451270/MAST; NIF 000-893-385-3; Patente 16307010297');
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'Micro-projet narrative — Construction d''une citerne pour la communauté de Laval', 'valid', 'Dated April 2025');
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'Plan de construction (floor plan)', 'valid', 'Drawn by Franckel Charetier, Ing., dated 07/06/24 — shows cistern + depot + reception + chambre + 2 WC; extra rooms unexplained');
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'Devis détaillé (itemized budget)', 'valid', 'Civil works + electrical, fully itemized with labor, transport, and contingency');
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'MOU with OJEADS', 'valid', 'Signed — referenced in the May 2026 board report');
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'Notarized written agreement — water assets belong to the community', 'missing', 'Required because the site is on Catholic land — still not drafted');
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'Well yield / pumping test results', 'missing', 'Live blocker for Due Diligence — GPM not yet measured');
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'Misereor materials inventory', 'missing', NULL);
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'GPS coordinates of well site', 'missing', NULL);
insert into documents (community_id, name, status, note) values ('teachaiti-stmichel-reservoir-2023', 'Cistern proforma — Devis pour la construction d''un réservoir', 'valid', 'Two contractor pro-forma quotes from "Bos Daveus," dated Dec 2022. Reservoir 14×21 ft.');
insert into documents (community_id, name, status, note) values ('teachaiti-stmichel-reservoir-2023', 'Email thread — "Estimate for well" (Dec 2022–May 2023)', 'valid', 'Funding negotiation between Jethro and Miquette; final figure verbally confirmed at $15,000 total.');

-- flags
insert into flags (community_id, flag_text) values ('oavm', 'NIF fiscal card expired Sept. 2024 — request renewal before drafting an MOU');
insert into flags (community_id, flag_text) values ('oavm', 'Mairie des Chardonnières attestation expired May 2025 — renewal required');
insert into flags (community_id, flag_text) values ('oavm', 'No site or water-source photos included — request at next contact');
insert into flags (community_id, flag_text) values ('teachaiti-stmichel-livestock', 'Funding ask is a range ($5,000–$7,500) — confirm final requested amount before approval');
insert into flags (community_id, flag_text) values ('teachaiti-stmichel-livestock', 'No community/organizational cash or in-kind contribution specified — confirm cost-share expectations');
insert into flags (community_id, flag_text) values ('teachaiti-stmichel-livestock', 'St. Michel security situation raised as a concern — TeacHaiti says the property is secure and will pause/adjust if risk increases');
insert into flags (community_id, flag_text) values ('teachaiti-stmichel-livestock', 'Patente valid only through FY2025–2026 (~30 Sept 2026) — renewal will be due in a few weeks');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Pumping test / well yield (GPM) not yet done — confirmed live blocker for Due Diligence');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Full Misereor materials inventory not provided');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'GPS coordinates of the well site not provided');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Solar panel theft/security plan not defined');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Cassava mill (moulin à manioc) contamination risk not assessed');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Unclear who hires/pays construction labor');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Water committee financial model (fees + maintenance reserve) not provided');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Construction plan includes a depot, reception area, chambre, and 2 WC beyond the cistern itself — unexplained');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Current water usage data from users not yet collected');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Volume of yucca being transformed not documented');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Engineer and agronomist (OJEADS member) contact never completed, as originally planned');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Notarized written agreement confirming community ownership of the water assets not yet drafted — required since the site is on Catholic land');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'No contact with Père Jacquet since June 10, 2026 — two months of silence as of Aug 10, 2026, with none of the open items resolved');
insert into flags (community_id, flag_text) values ('teachaiti-stmichel-reservoir-2023', 'No completion photos, final invoice, or closeout documentation on file for this project yet');

-- comms
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('oavm', '2026-08-10'::date, 'Document received', NULL, 'Completed partnership request form received from OAVM (Douillette/Derouze, Chardonnières) — water infrastructure project. Filed and placed under review.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('teachaiti-stmichel-livestock', '2026-08-05'::date, 'Email', 'Miquette McMahon', 'Follow-up response to Jethro''s questions: budget clarified as a $5,000–$7,500 range; a trained veterinary technician will oversee animal care; committed to tracking expenses, births, losses, and sales; addressed St. Michel security concerns.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('teachaiti-stmichel-livestock', '2026-07-28'::date, 'Document received', NULL, 'Partnership proposal received from Teach Haiti (Miquette McMahon), requesting $5,000 for a livestock & food security project at their St. Michel school.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('teachaiti-stmichel-livestock', '2026-08-11'::date, 'Document received', 'Miquette McMahon', 'Received Teach Haiti''s Certificat de Patente (business license) — Patente N° 5507076759, NIF 000-697-087-4. Valid for fiscal year 2025–2026.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('ojeads-laval-cistern', '2026-06-10'::date, 'Call', NULL, 'Père Jacquet cancelled a scheduled meeting. No further contact since — as of Aug 10, 2026 this is two months of silence with none of the outstanding items resolved.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('ojeads-laval-cistern', '2026-06-05'::date, 'Document received', NULL, 'Prep document with pending items and new questions sent to Père Jacquet ahead of a planned call.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('ojeads-laval-cistern', '2026-05-01'::date, 'Other', NULL, 'MOU signed with OJEADS (per the May 2026 board report); project development and baseline work described as underway at that time.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('ojeads-laval-cistern', '2025-05-07'::date, 'Email', 'Edy (Water for Life Haiti)', 'Edy referred OJEADS to LFF, sharing the original funding request letter, micro-projet narrative, construction plan, and itemized devis.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('teachaiti-stmichel-reservoir-2023', '2023-05-16'::date, 'Email', 'Jethro', 'Forwarded the cistern proforma to Kens Cazeau to move the project toward construction.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('teachaiti-stmichel-reservoir-2023', '2022-12-19'::date, 'Email', 'Miquette McMahon', 'Confirmed a final verbal estimate of "roughly $15k," citing inflation, after Jethro asked whether the project would land around $12,000–$13,000.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('teachaiti-stmichel-reservoir-2023', '2022-12-19'::date, 'Email', 'Miquette McMahon', 'Sent the initial cistern proforma for the St. Michel reservoir, noting the cistern size would double and the quoted estimate should be doubled accordingly.');
