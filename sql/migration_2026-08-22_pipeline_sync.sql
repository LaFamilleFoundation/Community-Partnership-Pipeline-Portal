-- ============================================================
-- LFF Partnership Pipeline — data sync migration
-- Generated from the Claude working-copy artifact (lff_partnership_pipeline.html)
-- to bring production up to date through 2026-08-21 patches.
--
-- Run this ONCE in Supabase SQL Editor. It:
--   1. Updates free-text fields + stage on 4 existing communities
--   2. Replaces their documents/flags/comms with the current full set
--      (safe because production has not yet been used for direct data
--      entry outside this artifact — confirmed before generating this)
--   3. Inserts the new AHDD (Dupéron) record in full
--
-- NOTE: date_received is intentionally left untouched for existing records —
-- the artifact's own dateReceived for OAVM is computed as "today" at page-load
-- time in seedData(), not a real stored date, so it is not trustworthy here.
-- ============================================================

-- ---------- ahdd-duperon-reservoir : new community ----------
insert into communities (id, name, full_org_name, location, stage, date_received, founded_year, member_count, primary_contact, other_leaders, project_type, water_source, water_problems, beneficiaries, impact, proposed_infrastructure, proposed_location, technical_specs, budget_estimate, timeline, management_committee, user_fees, maintenance_plan, org_role, exit_vision, me_commitment, prior_projects, other_funders, referral_source, org_references, community_contribution) values
  ('ahdd-duperon-reservoir', 'AHDD — Dupéron Reservoir', 'Association Humanitaire pour le Développement Durable (AHDD)', 'Dupéron, 1ère section communale, Chantal, Département du Sud', 'Closed / Exited', '2021-11-20'::date, 'Registered association; most recent leadership election 25 July 2023. Jethro had a brief advisory relationship with AHDD early on, around this project''s 2021 launch — he was no longer involved by AHDD''s 25 July 2023 leadership election.', 'Not specified. Governed by a Conseil Administratif ("CONAD") per AHDD''s own bylaws.', 'Slande Pierre Louis Beaubrun — Présidente (as of the 25 July 2023 election)', 'Jean Gardy Pierre Louis — Vice-Président · Laure Rose Car-Négie Beaubrun — Secrétaire Générale · Katia Pierre Louis Pierre — Secrétaire adjointe · Robenson Ducé — Trésorier · Jean Maxime Pierre Louis — Conseiller · Job Calvin — Délégué', 'Water infrastructure — irrigation reservoir (closed/exited)', 'Well + reservoir built for agricultural irrigation, not domestic drinking water', 'Per farmer testimony (Aug 2026): the well was reportedly not drilled properly; the system functioned anywhere from ~1 month to about a year depending on account, with no consistent story of when or why it failed. The community now relies almost entirely on rainfall.', 'Originally intended for ~50–58 farmers in Dupéron; 9 farmers (5 men, 4 women) participated in the Aug 2026 retrospective listening meeting, with 3 additional community members stopping by while passing and listening in, not counted as formal participants', 'At time of exit: system effectively non-functional on the ground. Farmers report burned/lost crops and lost invested capital during dry periods due to the lack of working irrigation.', 'Reservoir + irrigation system with a submersible solar pump and 4-panel solar array, built on a drilled well; launched following LFF''s 2021 south peninsula earthquake relief response — LFF''s first sustainable-investment project', 'Dupéron, Chantal, Sud', 'Submersible solar pump, 4×solar panels, water canal, reservoir. Three differing, unreconciled construction cost quotes exist in the files (see budget).', 'Three separate quotes found, never reconciled to one confirmed final figure: $20,195 (Nov 2021) · $22,031 (Oct 2021) · $28,325 (2022, fully itemized — $21,000 building materials, $3,922 solar panel, $400 solar install, $2,233 water canal + contractor, $300 media coverage, $200 supervisor fee, $270 transfer fee).', 'Launched Fall 2021 (earliest quote dated 20 Nov 2021) → inaugurated Summer 2022 → Exit Readiness case study conducted Fall 2025–Spring 2026, finding the project had not achieved sustainability → LFF formally ended its institutional partnership with AHDD on 19 Aug 2026.', 'None was ever formally established for this system. A water management committee was only raised as a future idea during the Aug 2026 retrospective meeting.', 'None historically. Farmers acknowledged user fees as "necessary" only in hindsight, during the Aug 2026 meeting — never implemented while the system ran.', 'None found. No consistent account exists of who maintained the system, why it failed, or why no local action was taken once it stopped working.', 'Intended as the local implementing/oversight partner. The Aug 2026 community listening meeting found no unprompted community awareness of AHDD — notably, despite the meeting being conducted on the ground by AHDD''s own Délégué (Job Calvin) together with Sofia Chery. AHDD''s Conseiller, Maxime Pierre Louis, was not present in Chantal — he coordinated remotely from Boston, contacting a community participant to help assemble attendees. This was a deliberate methodological choice on the facilitators'' part: they did not name AHDD themselves, specifically to test whether the community would identify their local partner unprompted. They did not — which, if anything, strengthens rather than undermines the finding.', 'No documented exit plan existed at launch. LFF''s Exit Readiness Framework was applied retroactively in the Fall 2025–Spring 2026 case study, which found the project had not achieved sustainability. Following that assessment, LFF formally ended its institutional partnership with AHDD on 19 Aug 2026 — while leaving the door open to a differently-structured, community-led approach (local water committee, a present local coordinator, land secured as community property, and a per-household community contribution matched dollar-for-dollar by LFF) and to individuals from AHDD, though not to AHDD as an institution.', 'None ongoing. Note: AHDD''s own harvest/production reports (Nov 2023–Apr 2024 and May–Dec 2025) show continued crop revenue attributed to this system — in direct tension with farmer testimony that it only functioned for about a month. This discrepancy is unresolved.', 'N/A — this was LFF''s first sustainable-investment project, launched shortly after Jethro led an earthquake relief trip in 2021', 'None identified for this specific project', 'N/A — direct LFF initiative following the 2021 south peninsula earthquake response', 'None specific to this project identified in the files reviewed.', 'At the Aug 2026 retrospective meeting, one farmer proposed a future community contribution of up to 30% toward any rehabilitation, with labor viewed as more feasible than cash. No community contribution was made toward the original 2021–2022 construction based on the files reviewed.')
on conflict (id) do nothing;

insert into documents (community_id, name, status, note) values ('ahdd-duperon-reservoir', 'AHDD Règlements Intérieurs (bylaws)', 'valid', 'Governance structure: Conseil Administratif ("CONAD"), Coordination Directrice, Secrétariat, Comptabilité, etc.');
insert into documents (community_id, name, status, note) values ('ahdd-duperon-reservoir', 'AHDD Procès-Verbal — dernière élection (25 July 2023)', 'valid', 'Current Comité Directeur seated: Beaubrun (Présidente), J.G. Pierre Louis (VP), Beaubrun (Sec. Générale), Pierre Louis Pierre (Sec. adjointe), Ducé (Trésorier), J.M. Pierre Louis (Conseiller), Calvin (Délégué)');
insert into documents (community_id, name, status, note) values ('ahdd-duperon-reservoir', 'Construction budget — Nov 2021 ("6217")', 'valid', 'Total $20,195 US — earliest dated quote found');
insert into documents (community_id, name, status, note) values ('ahdd-duperon-reservoir', 'Construction budget — Oct 2021 ("puits"/"puits.pdf")', 'valid', 'Total $22,031 US');
insert into documents (community_id, name, status, note) values ('ahdd-duperon-reservoir', 'Construction budget — 2022 ("Water & Irrigation 70,000 Gallon")', 'valid', 'Total $28,325 US, fully itemized');
insert into documents (community_id, name, status, note) values ('ahdd-duperon-reservoir', 'AHDD Harvest Report, Nov 2023–Apr 2024', 'valid', 'Reports ≈$8,994 in crop revenue attributed to this system');
insert into documents (community_id, name, status, note) values ('ahdd-duperon-reservoir', 'AHDD Harvest Report, May–Dec 2025', 'valid', 'Reports ≈$3,665 in crop revenue attributed to this system');
insert into documents (community_id, name, status, note) values ('ahdd-duperon-reservoir', 'Dupéron Community Listening Meeting — Sofia Chery farmer report (1 Aug 2026)', 'valid', 'Kreyòl original + English translation; 9 farmers interviewed');
insert into documents (community_id, name, status, note) values ('ahdd-duperon-reservoir', 'Dupéron Community Listening Meeting — Job Calvin compte rendu (1 Aug 2026)', 'valid', NULL);
insert into documents (community_id, name, status, note) values ('ahdd-duperon-reservoir', 'LFF Executive Observations & Decision-Support Summary (Aug 2026)', 'valid', 'EN/FR/Kreyòl versions; prepared by Jethro Decimus');
insert into documents (community_id, name, status, note) values ('ahdd-duperon-reservoir', 'Follow-up meeting transcript with Job & Maxime (13 Aug 2026)', 'valid', 'Audio + transcript; reconciling inconsistent accounts of the system''s timeline');
insert into documents (community_id, name, status, note) values ('ahdd-duperon-reservoir', 'LFF Transition Letter to AHDD (French) — 19 Aug 2026', 'valid', 'Formal end of the institutional partnership on the Dupéron water project. Requests transfer of technical, land, and governance documentation plus a clear asset inventory to close the collaboration administratively. Leaves the door open to a different, community-led structure — explicitly not asking AHDD to lead it.');
insert into documents (community_id, name, status, note) values ('ahdd-duperon-reservoir', 'Talking Points — Conversation with AHDD, Kreyòl/English (13 Aug 2026 draft)', 'valid', 'Prep notes for the closure conversation with Maxime and Job. States the two structural findings (fractured leadership, weak local presence) and the conditions for any future re-engagement.');

insert into flags (community_id, flag_text) values ('ahdd-duperon-reservoir', 'System reportedly functioned for as little as ~1 month up to about a year, with no consistent account across farmer testimony of when or why it failed');
insert into flags (community_id, flag_text) values ('ahdd-duperon-reservoir', 'No management committee, maintenance plan, or user fee structure was ever established for the original system');
insert into flags (community_id, flag_text) values ('ahdd-duperon-reservoir', 'AHDD''s own harvest reports (2023–2025) show ongoing crop revenue attributed to this system, in tension with farmer testimony that it only worked briefly — unresolved');
insert into flags (community_id, flag_text) values ('ahdd-duperon-reservoir', 'Community showed no unprompted awareness of AHDD as the implementing partner during the Aug 2026 listening meeting, despite the meeting being facilitated by AHDD''s own Délégué and Conseiller — a deliberate unprompted-recall test that the community did not pass');
insert into flags (community_id, flag_text) values ('ahdd-duperon-reservoir', 'Three differing, unreconciled construction budget quotes exist for the same original build ($20,195 / $22,031 / $28,325)');
insert into flags (community_id, flag_text) values ('ahdd-duperon-reservoir', 'AHDD leadership found to be fractured, with weak/inconsistent local presence in Duperon — the structural basis for ending the institutional partnership (not a judgment of any individual)');
insert into flags (community_id, flag_text) values ('ahdd-duperon-reservoir', 'Conditions for any future water-system work at Duperon: real local leadership based in Duperon/Chantal (not Port-au-Prince), an organized multi-member water committee with defined roles, land secured as community property (not individual/family land), and a per-household community contribution matched dollar-for-dollar by LFF');
insert into flags (community_id, flag_text) values ('ahdd-duperon-reservoir', 'LFF will not re-engage AHDD as an institution even if it reorganizes; door remains open only to individuals (e.g. Sofia Chery or another Chantal-based person) willing to coordinate directly with the community');
insert into flags (community_id, flag_text) values ('ahdd-duperon-reservoir', 'No pumping test or new infrastructure investment until the community-land condition is met');

insert into comms (community_id, comm_date, channel, logged_by, summary) values ('ahdd-duperon-reservoir', '2023-07-25'::date, 'Other', NULL, 'AHDD held its most recent leadership election per its procès-verbal; new Comité Directeur seated, including Job Calvin as Délégué and Jean Gardy Pierre Louis as Vice-Président.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('ahdd-duperon-reservoir', '2026-08-01'::date, 'Other', 'Maxime Pierre Louis (AHDD Conseiller)', 'Coordinated remotely from Boston ahead of the Aug 1 meeting, contacting a community participant to help assemble attendees. Did not attend in person.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('ahdd-duperon-reservoir', '2026-08-01'::date, 'Field visit', 'Job Calvin & Sofia Chery', 'Community listening meeting in Dupéron; 9 farmers interviewed on their experience with the water system. Findings fed directly into LFF''s Exit Readiness case study.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('ahdd-duperon-reservoir', '2026-08-13'::date, 'Call', 'Jethro', 'Follow-up call with Job Calvin (AHDD Délégué) and Maxime (AHDD Conseiller), working to reconcile inconsistent farmer accounts of when and why the original system stopped functioning.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('ahdd-duperon-reservoir', '2026-08-13'::date, 'Other', 'Jethro', 'Drafted Kreyòl/English talking points ahead of the closure conversation. Core message: AHDD''s leadership is fractured and local presence in Duperon is weak — a structural finding, not a judgment of individuals. Conditions for any future work: real local leadership based in Duperon/Chantal, an organized water committee, land secured as community property, and a matched community financial contribution. AHDD as an institution won''t be re-engaged, but the door stays open to individuals willing to coordinate directly with the community.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('ahdd-duperon-reservoir', '2026-08-19'::date, 'WhatsApp', 'Jethro', 'Closure conversation with Maxime and Job (AHDD) via WhatsApp, following the formal transition letter sent the same day. Reiterated that the institutional partnership with AHDD has ended, but the door remains open to Maxime and Job personally if they''d like to learn from this experience — not as project leaders going forward.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('ahdd-duperon-reservoir', '2026-08-19'::date, 'Other', 'Jethro', 'Sent LFF''s formal letter to Maxime, Job, and AHDD leadership ending the institutional partnership on the Dupéron water project, effective 19 Aug 2026. Requested transfer of all technical/land/governance documentation and a clear inventory of infrastructure/assets. Left open the possibility of a different, community-led structure going forward — explicitly not asking AHDD to lead it.');


-- ---------- teachaiti-stmichel-reservoir-2023 : update fields + stage ----------
update communities set
  name = 'Teach Haiti (School of Hope)',
  full_org_name = 'Teach Haiti (School of Hope)',
  location = 'St. Michel de l''Attalaye — Teach Haiti''s school. (Proforma letterhead lists a separate contact address: Rue L''avenir, Carrefour Saint Francique.)',
  stage = 'Closed / Exited',
  founded_year = NULL,
  member_count = NULL,
  primary_contact = 'Miquette Denie McMahon — Founder/Director — miquette27@yahoo.com',
  other_leaders = 'Cc''d throughout the funding thread: Audige Billybert, Frantzy Jean, Kens Cazeau, Manuel Jean',
  project_type = 'Water infrastructure — school water reservoir/cistern',
  water_source = NULL,
  water_problems = NULL,
  beneficiaries = 'Teach Haiti''s St. Michel school — students and staff',
  impact = 'Later cited in LFF donor materials as a completed success: school saved more than $2,200 in water costs within one year — resources reinvested directly into students. The Aug 2026 LFF–Teach Haiti MOU independently confirms the reservoir''s capacity at 15,000 gallons and states it "has supported more than 200 students, faculty, and staff since its construction."',
  proposed_infrastructure = 'Reservoir/cistern sized 14 ft × 21 ft, per contractor proforma (size doubled from the original quote per Miquette''s Dec 2022 note)',
  proposed_location = 'Teach Haiti''s St. Michel school site',
  technical_specs = 'Contractor proforma ("Bos Daveus") lists: 1 tonne fer 1/2, 1 tonne fer 3/8, tie wire, 200 sacs cement, 1,000 bloc 20, sand delivery, plus lumber/formwork rental and labor.',
  budget_estimate = 'Total project cost: $15,000. LFF funded $12,000 (80%); Teach Haiti contributed $3,000 (20%). Note: the original Dec 2022 contractor proforma itself is quoted in inconsistent currency notation (labeled ''HT''/gourdes, with a note that the labor line was mistakenly entered in the wrong currency) — this record relies on the final USD figures Jethro confirmed directly rather than trying to reconcile the proforma''s own math.',
  timeline = 'Estimate requested Dec 2022; proforma forwarded toward construction May 2023',
  management_committee = NULL,
  user_fees = NULL,
  maintenance_plan = NULL,
  org_role = NULL,
  exit_vision = NULL,
  me_commitment = NULL,
  prior_projects = 'N/A — this record is itself Teach Haiti''s completed prior water project, referenced as track record in their 2026 livestock proposal',
  other_funders = NULL,
  referral_source = 'Existing direct partner relationship (Miquette McMahon)',
  org_references = NULL,
  community_contribution = 'Teach Haiti: $3,000 (20% of the $15,000 total project cost)'
where id = 'teachaiti-stmichel-reservoir-2023';

delete from documents where community_id = 'teachaiti-stmichel-reservoir-2023';
delete from flags where community_id = 'teachaiti-stmichel-reservoir-2023';
delete from comms where community_id = 'teachaiti-stmichel-reservoir-2023';

insert into documents (community_id, name, status, note) values ('teachaiti-stmichel-reservoir-2023', 'Cistern proforma — Devis pour la construction d''un réservoir', 'valid', 'Two contractor pro-forma quotes from "Bos Daveus," dated Dec 2022. Reservoir 14×21 ft. Currency labeling is internally inconsistent — see budget note.');
insert into documents (community_id, name, status, note) values ('teachaiti-stmichel-reservoir-2023', 'Email thread — "Estimate for well" (Dec 2022–May 2023)', 'valid', 'Funding negotiation between Jethro and Miquette; final figure verbally confirmed at $15,000 total.');
insert into documents (community_id, name, status, note) values ('teachaiti-stmichel-reservoir-2023', 'LFF–Teach Haiti Multi-Year MOU (signed 21 Aug 2026)', 'valid', 'New umbrella framework MOU; cites this reservoir by name as LFF''s prior track record with Teach Haiti ("15,000-gallon reservoir... supported more than 200 students, faculty, and staff").');

insert into flags (community_id, flag_text) values ('teachaiti-stmichel-reservoir-2023', 'No completion photos, final invoice, or closeout documentation on file for this project yet');

insert into comms (community_id, comm_date, channel, logged_by, summary) values ('teachaiti-stmichel-reservoir-2023', '2022-12-19'::date, 'Email', 'Miquette McMahon', 'Sent the initial cistern proforma for the St. Michel reservoir, noting the cistern size would double and the quoted estimate should be doubled accordingly.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('teachaiti-stmichel-reservoir-2023', '2022-12-19'::date, 'Email', 'Miquette McMahon', 'Confirmed a final verbal estimate of "roughly $15k," citing inflation, after Jethro asked whether the project would land around $12,000–$13,000.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('teachaiti-stmichel-reservoir-2023', '2023-05-16'::date, 'Email', 'Jethro', 'Forwarded the cistern proforma to Kens Cazeau to move the project toward construction.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('teachaiti-stmichel-reservoir-2023', '2026-08-21'::date, 'Other', 'Jethro', 'The new LFF–Teach Haiti umbrella MOU (signed 21 Aug 2026) cites this reservoir directly as established track record, confirming its 15,000-gallon capacity and stating it has supported more than 200 students, faculty, and staff since construction — new impact data not previously on file.');


-- ---------- ojeads-laval-cistern : update fields + stage ----------
update communities set
  name = 'OJEADS',
  full_org_name = 'Organisation des Jeunes en Action pour le Développement du Sud',
  location = 'Laval, 2ème Section, Commune des Cayes, Département du Sud',
  stage = 'Closed / Exited',
  founded_year = '~2018 (6 years old as of 2024 letter) — registered with the Ministère des Affaires Sociales et du Travail, N° STC-451270/MAST',
  member_count = 'Youth organization; membership count not specified. Includes an agronomist member (contact not yet made — see flags).',
  primary_contact = 'Osny Jacquet (Père Jacquet) — Coordonnateur — ojeads2018@gmail.com — +509 3759-0881 / 4314-2413',
  other_leaders = 'Franckel Charetier, Ing. — drew the construction plan. An agronomist member is also on OJEADS''s team but direct contact was never made (see flags).',
  project_type = 'Water infrastructure — cistern + fountain on an existing well',
  water_source = 'Existing well drilled by Water for Life Haiti in the 2010s, Laval — currently hand-pumped; described as a genuine daily hardship. Reportedly one of the few wells that doesn''t dry up in drought.',
  water_problems = 'Manual pump is difficult to operate and limits daily access; households travel 700–800m between wells, more during dry season when other wells run dry; waterborne illness/cholera risk cited; water-fetching burden falls on women and children, affecting school attendance',
  beneficiaries = '120 households surveyed as eventual users',
  impact = 'Food insecurity (malnutrition), elevated infant mortality, constrained agricultural productivity, water-fetching burden on women/children affecting school attendance, waterborne disease risk including cholera',
  proposed_infrastructure = '5,000–6,000 gallon cistern + fountain with 2 taps, built on the existing well. OJEADS separately equips the well with a submersible solar pump and 4×600W panels.',
  proposed_location = 'On the existing well site, Laval 2ème Section — on Catholic (church) land. This is why a notarized written agreement confirming the water assets belong to the community is required (see flags — not yet drafted).',
  technical_specs = 'Fully itemized devis. Civil works (terrassement, sable, gravier, roche, fer, ciment, blocs, peinture, coffrage, accessoires hydraulique/drainage) totals $7,707.60 + transport 1.5% + imprévu 2% + main-d''œuvre 40% = $11,060.41. Electrical/solar (1 pompe solaire, 4×600W panels, BigBox 4C, breakers, cable, tools, colliers) + 40% labor = $3,082.95. Note: the construction plan shows the cistern structure plus a depot/storage room, reception area, chambre, and 2 WC — more scope than ''just a cistern'' and not explained in the narrative (see flags).',
  budget_estimate = 'Total project cost $14,143.36. OJEADS contributes $3,082.95 (21.79% — fully covers the solar pump, panels, and electrical installation). Requested from LFF: $11,061.41 (civil works — cistern + fountain construction).',
  timeline = 'Not yet specified',
  management_committee = '7-member water committee shared for the first time (Aug 2026): includes Herold Darbouze, CASEC président (a political official). Did not go through the community-elected process originally envisioned — flagged as a legitimacy and power-dynamics concern in the closure review.',
  user_fees = 'Not yet specified — pending OJEADS''s financial model for monthly household fees covering operations + a repair reserve',
  maintenance_plan = 'Not yet specified — tied to the pending financial model',
  org_role = 'Full financing and installation of the solar pump, panels, and electrical system (their 21.79% share); LFF asked to fund the civil works (cistern + fountain construction)',
  exit_vision = 'File closed 21 Aug 2026 without proceeding, following a case-study review (with Ryan Rowe, Socieau Advisory) that found land tenure unresolved and committee legitimacy concerns, compounding a second instance of prolonged communication silence. No LFF funds were disbursed at any point.',
  me_commitment = 'Not yet specified',
  prior_projects = '6-year-old organization; prior funder was Misereor (German donor) — itemized inventory of materials/equipment received from Misereor still not provided',
  other_funders = 'Misereor (Germany) — past support; details pending',
  referral_source = 'Edy, Water for Life Haiti — email referral, Wed, May 7, 2025, 12:06 PM. Water for Life drilled the original well and shared Chantal''s results with OJEADS as a reference point.',
  org_references = 'Water for Life Haiti (Edy)',
  community_contribution = 'OJEADS: $3,082.95 cash-equivalent (21.79% of total project cost) — covers solar pump, panels, electrical materials, and that portion''s installation labor in full'
where id = 'ojeads-laval-cistern';

delete from documents where community_id = 'ojeads-laval-cistern';
delete from flags where community_id = 'ojeads-laval-cistern';
delete from comms where community_id = 'ojeads-laval-cistern';

insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'OJEADS registration & funding request letter', 'valid', 'Registered with Ministère des Affaires Sociales et du Travail N° STC-451270/MAST; NIF 000-893-385-3; Patente 16307010297');
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'Micro-projet narrative — Construction d''une citerne pour la communauté de Laval', 'valid', 'Dated April 2025 — needs assessment, beneficiary selection criteria, objectives');
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'Plan de construction (floor plan)', 'valid', 'Drawn by Franckel Charetier, Ing., dated 07/06/24 — shows cistern + depot + reception + chambre + 2 WC; extra rooms unexplained');
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'Devis détaillé (itemized budget)', 'valid', 'Civil works + electrical, fully itemized with labor, transport, and contingency');
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'MOU with OJEADS', 'valid', 'Signed — referenced in the May 2026 board report');
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'Notarized written agreement — water assets belong to the community', 'missing', 'Required because the site is on Catholic land — still not drafted');
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'Well yield / pumping test results', 'missing', 'Live blocker for Due Diligence — GPM not yet measured');
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'Misereor materials inventory', 'missing', NULL);
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'GPS coordinates of well site', 'missing', NULL);
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'Case study / file review with Ryan Rowe (Socieau Advisory) — Aug 2026', 'valid', 'Evaluated the OJEADS file against current LFF standards ahead of the closure decision.');
insert into documents (community_id, name, status, note) values ('ojeads-laval-cistern', 'LFF Closure Letter to Père Jacquet — 21 Aug 2026', 'valid', 'Cites land tenure policy, committee representativity, and the communication pattern. Explicitly not a judgment on Père Jacquet personally.');

insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Pumping test / well yield (GPM) not yet done — confirmed live blocker for Due Diligence');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Full Misereor materials inventory not provided');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'GPS coordinates of the well site not provided');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Solar panel theft/security plan not defined');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Cassava mill (moulin à manioc) contamination risk not assessed');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Unclear who hires/pays construction labor');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Water committee financial model (fees + maintenance reserve) not provided');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Construction plan includes a depot, reception area, chambre, and 2 WC beyond the cistern itself — unexplained, needs clarification with Père Jacquet');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Current water usage data from users not yet collected');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Volume of yucca being transformed not documented — needed to size the water need against production, and for future M&E storytelling');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Engineer and agronomist (OJEADS member) contact never completed, as originally planned');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Notarized written agreement confirming community ownership of the water assets not yet drafted — required since the site is on Catholic land — never resolved; verbal Church authorization only. This was a primary basis for closing the file 21 Aug 2026.');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Contact with Père Jacquet resumed 14 Aug 2026 after the extended silence — second instance of prolonged unresponsiveness (following the earlier June–Aug 2026 gap); cited health issues and competing obligations (school construction oversight, school year closeout).');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'Water committee (7 members, incl. CASEC président Herold Darbouze) shared for the first time Aug 2026 — did not go through the community-elected process originally envisioned; inclusion of a political official flagged as a power-dynamics risk');
insert into flags (community_id, flag_text) values ('ojeads-laval-cistern', 'File closed 21 Aug 2026 — no LFF funds were ever disbursed toward this project');

insert into comms (community_id, comm_date, channel, logged_by, summary) values ('ojeads-laval-cistern', '2025-05-07'::date, 'Email', 'Edy (Water for Life Haiti)', 'Edy referred OJEADS to LFF, sharing the original funding request letter, micro-projet narrative, construction plan, and itemized devis for a cistern + fountain project in Laval.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('ojeads-laval-cistern', '2026-05-01'::date, 'Other', NULL, 'MOU signed with OJEADS (per the May 2026 board report); project development and baseline work described as underway at that time.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('ojeads-laval-cistern', '2026-06-05'::date, 'Document received', NULL, 'Prep document with pending items (Misereor inventory, well yield cost, GPS coordinates) and new questions (solar panel security, cassava mill contamination, other wells in the area, construction labor responsibility, water committee financial model) sent to Père Jacquet ahead of a planned call.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('ojeads-laval-cistern', '2026-06-10'::date, 'Call', NULL, 'Père Jacquet cancelled a scheduled meeting. No further contact since — as of Aug 10, 2026 this is two months of silence with none of the outstanding items resolved.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('ojeads-laval-cistern', '2026-08-14'::date, 'Call', 'Jethro', 'Père Jacquet resumed contact after an extended silence — the second such occurrence — citing health issues and competing obligations (school construction oversight, school year closeout). Shared the water management committee composition for the first time: 7 members, including Herold Darbouze, CASEC président.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('ojeads-laval-cistern', '2026-08-21'::date, 'Email', 'Jethro', 'Sent formal closure letter to Père Jacquet citing land tenure policy, committee representativity, and the communication pattern — explicitly not a judgment on him personally. File closed; not proceeding with the Laval cistern project at this time. No LFF funds were disbursed at any point. No reopening clause — no scheduled follow-up.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('ojeads-laval-cistern', '2026-08-21'::date, 'Other', 'Jethro', 'Case study review with Ryan Rowe (Socieau Advisory) evaluated the file against current standards. Findings: land tenure remains unresolved (verbal Catholic Church authorization only, no notarized agreement — doesn''t meet LFF''s land-tenure policy); the water committee (7 members, including CASEC président Herold Darbouze) did not go through the originally-envisioned community-elected process, and including a political official was flagged as a power-dynamics risk; this is also OJEADS''s second instance of prolonged, unexplained silence, raised as a partnership-viability concern rather than a scheduling issue. Board Chair Aldreka consulted; recommendation was to close rather than extend with another deadline, consistent with the AHDD approach.');


-- ---------- teachaiti-stmichel-livestock : update fields + stage ----------
update communities set
  name = 'Teach Haiti',
  full_org_name = 'Teach Haiti',
  location = 'St. Michel — existing Teach Haiti school property (LFF education/WASH partnership site)',
  stage = 'Due Diligence',
  founded_year = NULL,
  member_count = NULL,
  primary_contact = 'Miquette McMahon — Executive Director — miquette@teachhaiti.org',
  other_leaders = 'LFF primary contact per MOU: Jethro Decimus, Executive Director, decimusj@lafamillefoundation.org',
  project_type = 'Livestock & Food Security (agriculture / vocational education)',
  water_source = 'N/A — agriculture/livestock project, not water infrastructure',
  water_problems = NULL,
  beneficiaries = 'Students and families at Teach Haiti''s school; broader St. Michel community',
  impact = 'Improved student/family nutrition, hands-on vocational training in animal husbandry, and a sustainable income source for the school',
  proposed_infrastructure = 'Small livestock farm — 7 roosters, 50 chickens, 4 pigs, 10 goats — plus animal housing, pens & fencing',
  proposed_location = 'On Teach Haiti''s existing, secured school property in St. Michel',
  technical_specs = 'Budget breakdown: Roosters $245 · Chickens $1,250 · Pigs $800 · Goats $1,200 · Housing/pens/fencing $500 · Initial feed $250 · Veterinary care, equipment & supplies $755',
  budget_estimate = '$5,000 requested initially (28 Jul); follow-up on 5 Aug clarified total project cost is a $5,000–$7,500 range — the extra $2,500 would fund expanded shelter/fencing',
  timeline = 'Not yet specified',
  management_committee = 'Overseen by a veterinary technician Teach Haiti trained several years ago — responsible for routine care, health monitoring, recordkeeping, vaccination schedules, illness identification, and coordinating outside professional help when needed',
  user_fees = 'N/A',
  maintenance_plan = 'Vet tech will confirm vaccine/medication availability and identify reliable local suppliers before animals are purchased',
  org_role = 'Full implementation — housing, staffing, and on-site supervision on Teach Haiti''s own property',
  exit_vision = 'Designed to become self-sustaining: revenue from egg, chicken, piglet, and goat sales reinvested into feed, veterinary care, infrastructure maintenance, and growth, reducing dependency on outside funding over time',
  me_commitment = 'Will track expenses, births, losses, and sales, and provide a projection of ongoing expenses, anticipated breeding/production, and expected revenue',
  prior_projects = 'Existing LFF partner — clean water project at Teach Haiti''s St. Michel school, cited in this proposal as a past success',
  other_funders = 'Not specified',
  referral_source = 'Established partner — ongoing LFF relationship (St. Michel education/WASH partnership)',
  org_references = NULL,
  community_contribution = 'Not specified — full $5,000–$7,500 requested from LFF; no community/organizational cash or in-kind match stated'
where id = 'teachaiti-stmichel-livestock';

delete from documents where community_id = 'teachaiti-stmichel-livestock';
delete from flags where community_id = 'teachaiti-stmichel-livestock';
delete from comms where community_id = 'teachaiti-stmichel-livestock';

insert into documents (community_id, name, status, note) values ('teachaiti-stmichel-livestock', 'St. Michel Livestock & Food Security Partnership Proposal (PDF)', 'valid', 'Received 28 July 2026, 9:53 PM');
insert into documents (community_id, name, status, note) values ('teachaiti-stmichel-livestock', 'Certificat de Patente (business license)', 'valid', 'Patente N° 5507076759 · NIF 000-697-087-4 — issued to Eduquer Haiti / Teach Haiti (EH/TH), Rue Lafosa, Delmas 75, Port-au-Prince. Valid for fiscal year 2025–2026 (Haiti''s fiscal year runs Oct–Sept, so this expires ~30 Sept 2026). Received directly from Miquette on 11 Aug 2026.');
insert into documents (community_id, name, status, note) values ('teachaiti-stmichel-livestock', 'LFF–Teach Haiti Multi-Year MOU (signed 21 Aug 2026)', 'valid', '3-year umbrella framework (agriculture/livestock, water, education, community development) in St. Michel. Explicitly non-binding and does not approve, fund, or authorize any specific project — each project still requires its own separate written addendum/grant agreement per Section 4.');

insert into flags (community_id, flag_text) values ('teachaiti-stmichel-livestock', 'Funding ask is a range ($5,000–$7,500) — confirm final requested amount before approval');
insert into flags (community_id, flag_text) values ('teachaiti-stmichel-livestock', 'No community/organizational cash or in-kind contribution specified — confirm cost-share expectations');
insert into flags (community_id, flag_text) values ('teachaiti-stmichel-livestock', 'St. Michel security situation raised as a concern — TeacHaiti says the property is secure and will pause/adjust if risk increases; keep monitoring before and after disbursement');
insert into flags (community_id, flag_text) values ('teachaiti-stmichel-livestock', 'Patente valid only through FY2025–2026 (~30 Sept 2026) — renewal will be due in a few weeks');
insert into flags (community_id, flag_text) values ('teachaiti-stmichel-livestock', 'Even with the umbrella MOU signed, this livestock project still requires its own separate written project addendum before any funding is approved (MOU Section 4) — the funding-range and cost-share flags above remain unresolved');

insert into comms (community_id, comm_date, channel, logged_by, summary) values ('teachaiti-stmichel-livestock', '2026-07-28'::date, 'Document received', NULL, 'Partnership proposal received from Teach Haiti (Miquette McMahon), requesting $5,000 for a livestock & food security project at their St. Michel school — builds on the existing water project partnership.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('teachaiti-stmichel-livestock', '2026-08-05'::date, 'Email', 'Miquette McMahon', 'Follow-up response to Jethro''s questions (received 4:28 PM): budget clarified as a $5,000–$7,500 range (extra $2,500 covers shelter/fencing); a Teach Haiti-trained veterinary technician will oversee animal care — health monitoring, recordkeeping, vaccination schedule, illness ID, coordinating outside professional help; he''ll confirm vaccine/medication availability and local suppliers before purchase; committed to tracking expenses, births, losses, and sales, and providing revenue/expense projections; addressed St. Michel security concerns — property is secure, animals supervised on-site, will monitor and pause/adjust if risk increases.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('teachaiti-stmichel-livestock', '2026-08-11'::date, 'Document received', 'Miquette McMahon', 'Received Teach Haiti''s Certificat de Patente (business license) directly from Miquette — Patente N° 5507076759, NIF 000-697-087-4, registered under Eduquer Haiti/Teach Haiti (EH/TH) in Delmas. Valid for fiscal year 2025–2026.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('teachaiti-stmichel-livestock', '2026-08-21'::date, 'Other', 'Jethro', 'Multi-year MOU signed with Teach Haiti (Miquette McMahon''s signature dated 21 Aug 2026) — establishes a 3-year umbrella framework for collaboration across agriculture/livestock, water, education, and community development in St. Michel. Non-binding; explicitly does not approve, fund, or authorize any specific project. This livestock proposal still needs its own written project addendum per Section 4 before it can move to funding.');


-- ---------- oavm : update fields + stage ----------
update communities set
  name = 'OAVM',
  full_org_name = 'Òganizasyon Agrikòl pou yon Vi Miyò',
  location = 'Douillette, 1ère Rendel, Chardonnières, Sud',
  stage = 'Due Diligence',
  founded_year = '1997 (15 March 1997)',
  member_count = '58 members (23 women, 35 men)',
  primary_contact = 'Aguilnaire Seide — President — 3802-9777 — saguilnaire@gmail.com',
  other_leaders = 'Johanne Francois — Secretary — 3626-9641',
  project_type = 'Water infrastructure',
  water_source = 'Spring at Calio — ~2 km from Douillette, ~3 km from Derouze. This is a spring, not a well — assessment differs from a pumping/GPM test; need a dry-season flow rate (débit) measurement at the point of emergence, plus a sense of wet-vs-dry seasonal variability.',
  water_problems = 'Water quality issues, distance, fever/diarrhea outbreaks (waterborne illness)',
  beneficiaries = '~300 households · 2,500 direct beneficiaries · 50,000 indirect beneficiaries (indirect figure not yet verified)',
  impact = 'Affects livelihoods, education, and health (waterborne illness) across the community',
  proposed_infrastructure = 'Pumping system with reservoir and PVC distribution piping serving Douillette and Derouze',
  proposed_location = 'Reservoir on private land donated to the community; PVC piping to households',
  technical_specs = 'Not yet known — to be studied jointly if the dossier is of interest to LFF',
  budget_estimate = 'Not yet developed — to be prepared jointly with LFF',
  timeline = '4–6 months execution',
  management_committee = '3-person committee: 2 OAVM members + 1 community member, selected with local authorities',
  user_fees = 'Yes — in-kind plus billed/invoiced payments (amount and collection frequency not yet specified)',
  maintenance_plan = 'OAVM + local authorities; funded by water-use fees collected',
  org_role = 'Labor, materials, land, and ongoing support',
  exit_vision = 'OAVM and the steering committee take over the project long-term',
  me_commitment = 'Yes — agreed to 5–7 years of annual M&E data (system function, users, maintenance, harvests, challenges)',
  prior_projects = 'Corn mill (moulin à maïs) project — currently functional, agricultural transformation',
  other_funders = 'PAGAI / Swiss Cooperation, 2022–2023 — 750,000 HTG (corn mill + corn/black bean storage)',
  referral_source = 'Word of mouth — researchers visiting from Les Cayes saw families traveling long distances for water and suggested contacting LFF. Note: this is not a direct invitation from community leadership — invitation legitimacy is an open due-diligence question per LFF''s community-invitation model. The specific referring contact''s name has not yet been identified.',
  org_references = 'Swiss Cooperation (PAGAI) · Fondation MACAYA · FEDER · OBALA · local CASEC',
  community_contribution = '50,000 HTG cash (~20% of total budget) + labor, materials, land. No other partners on this project.'
where id = 'oavm';

delete from documents where community_id = 'oavm';
delete from flags where community_id = 'oavm';
delete from comms where community_id = 'oavm';

insert into documents (community_id, name, status, note) values ('oavm', 'Ministère des Affaires Sociales — Attestation d''enregistrement', 'valid', 'N° 237-81, issued 26 May 1997 — permanent registration, no expiry');
insert into documents (community_id, name, status, note) values ('oavm', 'Carte d''Immatriculation Fiscale (NIF)', 'expired', 'NIF 000-699-208-1 — expired 30/09/2024, renewal needed before MOU stage');
insert into documents (community_id, name, status, note) values ('oavm', 'Attestation de la Mairie des Chardonnières', 'expired', 'N° 001-143, valid May 2023–May 2025 (renewable) — expired, renewal needed');
insert into documents (community_id, name, status, note) values ('oavm', 'Budget / itemized estimate', 'missing', 'To be co-developed with LFF (item 15 of the guide)');
insert into documents (community_id, name, status, note) values ('oavm', 'Technical drawings / plans', 'missing', 'Not available yet — depends on LFF interest (item 14)');
insert into documents (community_id, name, status, note) values ('oavm', 'Photos of current water source & proposed site', 'missing', 'Not included in this submission — request during follow-up');
insert into documents (community_id, name, status, note) values ('oavm', 'OAVM Follow-up Letter (French) — Aug 2026', 'valid', 'Sent to Aguilnaire Seide: land tenure is the sole blocking requirement (notarized don to a community/public entity, all owners/heirs/spouses signing before CASEC/ASEC/local authority, notarized act, plus documented infrastructure ownership separate from land). Response requested by 31 Dec 2026. Referral contact name and NIF renewal deferred, not blocking.');

insert into flags (community_id, flag_text) values ('oavm', 'Land tenure is the primary blocker (per LFF policy: no funding/construction on privately-owned land). Required before further review: notarized transfer (don) of the land to a community/public entity — all owners/heirs/spouses signing, before a CASEC/ASEC/local authority — a notarized act confirming the transfer, and documented ownership of the infrastructure itself, separate from the land.');
insert into flags (community_id, flag_text) values ('oavm', 'NIF fiscal card expired Sept. 2024 — request renewal before drafting an MOU (renewal deferred — not currently being chased; will follow up once land tenure resolves, not a blocker on its own)');
insert into flags (community_id, flag_text) values ('oavm', 'Mairie des Chardonnières attestation expired May 2025 — renewal required');
insert into flags (community_id, flag_text) values ('oavm', 'No site or water-source photos included — request at next contact');
insert into flags (community_id, flag_text) values ('oavm', 'Community mandate unclear — OAVM was introduced via researchers from Les Cayes, not a direct invitation from community leadership; confirm invitation legitimacy per LFF''s community-invitation model');
insert into flags (community_id, flag_text) values ('oavm', 'Referral contact name not yet identified — who specifically from the Les Cayes researcher group suggested LFF (deferred — not currently being chased; will follow up once land tenure resolves, not a blocker on its own)');
insert into flags (community_id, flag_text) values ('oavm', 'Indirect beneficiary figure (50,000) not yet verified');
insert into flags (community_id, flag_text) values ('oavm', 'Bank account or equivalent structure for maintenance/repair funds not yet confirmed');
insert into flags (community_id, flag_text) values ('oavm', 'Simple financial model showing user fees will cover O&M + reserve not yet provided');
insert into flags (community_id, flag_text) values ('oavm', 'Site visit / call with OAVM leadership not yet conducted');
insert into flags (community_id, flag_text) values ('oavm', 'Board/Treasurer notification (Carver alignment) pending until technical study and budget are scoped');
insert into flags (community_id, flag_text) values ('oavm', 'Response requested from OAVM by 31 Dec 2026 — if no word by then, dossier moves to On Hold. Next checkpoint: 31 Dec 2026, or sooner if OAVM responds.');

insert into comms (community_id, comm_date, channel, logged_by, summary) values ('oavm', '2026-08-10'::date, 'Document received', NULL, 'Completed partnership request form received from OAVM (Douillette/Derouze, Chardonnières) — water infrastructure project. Filed and placed under review.');
insert into comms (community_id, comm_date, channel, logged_by, summary) values ('oavm', '2026-08-14'::date, 'Email', 'Jethro', 'Reviewed OAVM''s intake form and registration documents (Mairie attestation #001-143, NIF 000-699-208-1 [expired], Ministère des Affaires Sociales attestation No. 237-81). Identified land tenure as the primary blocker — the proposed reservoir site is private land only described as "offered to the population," with no documentation of transfer or ownership. Applied LFF''s policy against funding or constructing on privately-owned land. Sent a formal letter to Aguilnaire Seide requiring, before any further review: a notarized transfer (don) of the land to a community/public entity — all owners, heirs, and spouses signing, in the presence of a CASEC, ASEC, or local/communal authority — a notarized act confirming that transfer, and documented ownership of the built infrastructure itself, separate from land ownership. Response requested by 31 Dec 2026, or the dossier moves to On Hold (LFF remains open to resuming later). Referral contact name and NIF renewal deferred until land tenure resolves — not blocking on their own.');

