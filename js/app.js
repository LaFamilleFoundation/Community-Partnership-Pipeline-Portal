// js/app.js
// Runs only after auth.js confirms a signed-in session (see bootApp below).

const STAGES = [
  {key:'Submission Received', fr:'Demande reçue',          color:'var(--lightblue)'},
  {key:'Under Review',        fr:'Examen',                 color:'var(--teal)'},
  {key:'Due Diligence',       fr:'Vérification préalable', color:'var(--teal)'},
  {key:'Site Visit',          fr:'Visite sur site',        color:'var(--yellowgreen-dark)'},
  {key:'MOU Drafting',        fr:"Protocole d'entente",    color:'var(--forest)'},
  {key:'Active / Implementation', fr:'Mise en œuvre',      color:'var(--forest)'},
  {key:'Exit-Readiness Tracking', fr:'Suivi de sortie',    color:'var(--yellowgreen-dark)'},
  {key:'Closed / Exited',     fr:'Clôturé',                color:'#8a8f8a'},
  {key:'On Hold / Declined',  fr:'En attente / Refusé',    color:'var(--red)'},
];

let state = {
  user: null,
  communities: [],
  view: 'board', activeId: null, formMode: null,
  search: '', docSearch: '', menuOpen: false,
  loaded: false, loadError: null,
};

/* ============================= DATA LAYER (Supabase) ============================= */
function slugify(s){
  return (s||'community').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g,'')
    .replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'').slice(0,40) || 'community';
}
function newId(orgName){ return slugify(orgName) + '-' + Date.now().toString(36).slice(-5); }

function rowToCommunity(r){
  return {
    id: r.id,
    orgName: r.full_org_name || r.name || '',
    acronym: r.name || '',
    location: r.location || '',
    stage: r.stage || 'Submission Received',
    dateReceived: r.date_received || '',
    foundedYear: r.founded_year || '',
    memberCount: r.member_count || '',
    primaryContact: r.primary_contact || '',
    otherLeaders: r.other_leaders || '',
    projectType: r.project_type || '',
    waterSource: r.water_source || '',
    waterProblems: r.water_problems || '',
    beneficiaries: r.beneficiaries || '',
    impact: r.impact || '',
    proposedInfrastructure: r.proposed_infrastructure || '',
    proposedLocation: r.proposed_location || '',
    technicalSpecs: r.technical_specs || '',
    budgetEstimate: r.budget_estimate || '',
    timeline: r.timeline || '',
    managementCommittee: r.management_committee || '',
    userFees: r.user_fees || '',
    maintenancePlan: r.maintenance_plan || '',
    orgRole: r.org_role || '',
    exitVision: r.exit_vision || '',
    meCommitment: r.me_commitment || '',
    priorProjects: r.prior_projects || '',
    otherFunders: r.other_funders || '',
    referralSource: r.referral_source || '',
    references: r.org_references || '',
    communityContribution: r.community_contribution || '',
    documents: [], flags: [], comms: [],
  };
}

async function loadAll(){
  const [{data: comm, error: e1}, {data: docs, error: e2}, {data: flagRows, error: e3}, {data: commsRows, error: e4}] =
    await Promise.all([
      window.sb.from('communities').select('*').order('created_at', {ascending:true}),
      window.sb.from('documents').select('*'),
      window.sb.from('flags').select('*'),
      window.sb.from('comms').select('*'),
    ]);
  const err = e1 || e2 || e3 || e4;
  if(err) throw err;

  const byId = {};
  (comm||[]).forEach(r => byId[r.id] = rowToCommunity(r));
  (docs||[]).forEach(r => { if(byId[r.community_id]) byId[r.community_id].documents.push({id:r.id, name:r.name, status:r.status, note:r.note||'', filePath:r.file_path||'', fileName:r.file_name||''}); });
  (flagRows||[]).forEach(r => { if(byId[r.community_id]) byId[r.community_id].flags.push({id:r.id, text:r.flag_text}); });
  (commsRows||[]).forEach(r => { if(byId[r.community_id]) byId[r.community_id].comms.push({id:r.id, date:r.comm_date, channel:r.channel, by:r.logged_by||'', summary:r.summary}); });
  Object.values(byId).forEach(c => c.comms.sort((a,b)=> (b.date||'').localeCompare(a.date||'')));

  state.communities = Object.values(byId);
}

async function refresh(){
  try{ await loadAll(); state.loadError = null; }
  catch(e){ state.loadError = e.message || 'Could not load data.'; console.error(e); }
  state.loaded = true;
  render();
}

/* ============================= HELPERS ============================= */
function esc(s){ return (s===undefined||s===null||s==='') ? '' : String(s).replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }
function stageInfo(key){ return STAGES.find(s=>s.key===key) || STAGES[0]; }
function daysSince(dateStr){
  if(!dateStr) return '';
  const d = new Date(dateStr); const now = new Date();
  const days = Math.floor((now - d) / 86400000);
  return days<=0 ? 'today' : days+'d';
}
function findCommunity(id){ return state.communities.find(c=>c.id===id); }
function toast(msg){
  const el = document.createElement('div');
  el.className='toast'; el.textContent=msg;
  document.body.appendChild(el);
  setTimeout(()=>el.remove(), 2600);
}
function complianceIssues(c){
  const docIssues = (c.documents||[]).filter(d=>d.status==='expired'||d.status==='missing').length;
  return docIssues + (c.flags||[]).length;
}
async function withBusy(fn){
  try{ await fn(); }
  catch(e){ toast('Something went wrong — ' + (e.message||'try again.')); console.error(e); }
}

/* ============================= ACTIONS ============================= */
window.openDetail = function(id){ state.view='detail'; state.activeId=id; state.menuOpen=false; render(); window.scrollTo(0,0); };
window.backToBoard = function(){ state.view='board'; state.activeId=null; state.formMode=null; render(); };
window.openNewForm = function(){ state.view='form'; state.formMode='new'; state.activeId=null; render(); window.scrollTo(0,0); };
window.openEditForm = function(id){ state.view='form'; state.formMode='edit'; state.activeId=id; render(); window.scrollTo(0,0); };
window.toggleMenu = function(){ state.menuOpen = !state.menuOpen; render(); };
window.setSearch = function(v){ state.search = v; render(); };
window.openDocuments = function(){ state.view='documents'; state.menuOpen=false; render(); window.scrollTo(0,0); };
window.setDocSearch = function(v){ state.docSearch = v; render(); };

window.changeStage = async function(id, newStage){
  await withBusy(async ()=>{
    let { error } = await window.sb.from('communities').update({stage:newStage}).eq('id', id);
    if(error) throw error;
    await window.sb.from('comms').insert({
      community_id:id, comm_date:new Date().toISOString().slice(0,10), channel:'Other',
      logged_by: state.user?.email || '', summary:`Moved to "${stageInfo(newStage).key}" (${stageInfo(newStage).fr}).`
    });
    await refresh();
  });
};

window.cycleDocStatus = async function(id, docId){
  await withBusy(async ()=>{
    const c = findCommunity(id);
    const doc = c.documents.find(d=>d.id===docId);
    const order = ['valid','expired','missing'];
    const next = order[(order.indexOf(doc.status)+1)%order.length];
    const { error } = await window.sb.from('documents').update({status:next}).eq('id', docId);
    if(error) throw error;
    await refresh();
  });
};

function safeFileName(name){ return name.replace(/[^a-zA-Z0-9_.-]/g, '_'); }
function findDocument(id, docId){ return (findCommunity(id)?.documents||[]).find(d=>d.id===docId); }

// Uploads a file for a document row and records where it went. If saving the
// path fails, the uploaded object is removed so it can't be left orphaned.
async function attachFileToDocument(id, docId, file){
  const bucket = window.sb.storage.from('documents');
  const path = `${id}/${docId}-${Date.now()}-${safeFileName(file.name)}`;
  const { error: upErr } = await bucket.upload(path, file);
  if(upErr) throw upErr;
  const { error } = await window.sb.from('documents').update({file_path: path, file_name: file.name}).eq('id', docId);
  if(error){
    await bucket.remove([path]);
    throw error;
  }
  return path;
}

// Signed URLs expire quickly; a download link tells Storage to send the file
// as an attachment under its original name.
async function signedDocumentUrl(doc, download){
  const opts = download ? {download: doc.fileName || doc.filePath.split('/').pop()} : undefined;
  const { data, error } = await window.sb.storage.from('documents').createSignedUrl(doc.filePath, 300, opts);
  if(error) throw error;
  return data.signedUrl;
}

window.viewDocumentFile = async function(id, docId){
  const doc = findDocument(id, docId);
  if(!doc?.filePath) return;
  // Open the tab synchronously so Safari/Firefox don't treat it as a popup.
  const win = window.open('', '_blank');
  try{
    const url = await signedDocumentUrl(doc, false);
    if(win) win.location.href = url; else window.location.href = url;
  }catch(e){
    if(win) win.close();
    toast('Could not open file — ' + (e.message||'try again.'));
  }
};

window.downloadDocumentFile = async function(id, docId){
  const doc = findDocument(id, docId);
  if(!doc?.filePath) return;
  try{
    window.location.href = await signedDocumentUrl(doc, true);
  }catch(e){
    toast('Could not download file — ' + (e.message||'try again.'));
  }
};

window.uploadDocumentFile = async function(id, docId, inputEl){
  const file = inputEl.files[0];
  if(!file) return;
  await withBusy(async ()=>{
    const oldPath = findDocument(id, docId)?.filePath;
    await attachFileToDocument(id, docId, file);
    if(oldPath) await window.sb.storage.from('documents').remove([oldPath]);
    await refresh();
    toast('File attached.');
  });
};

function documentFileActions(c, d){
  return `${d.filePath ? `<button class="btn-link" onclick="viewDocumentFile('${c.id}','${d.id}')" title="${esc(d.fileName)}">View</button>
        <button class="btn-link" onclick="downloadDocumentFile('${c.id}','${d.id}')">Download</button>` : `<span class="nofile">No file</span>`}
        <label class="btn-link upload-label">${d.filePath ? 'Replace' : 'Attach file'}<input type="file" onchange="uploadDocumentFile('${c.id}','${d.id}', this)"></label>`;
}

window.addDocument = async function(id, prefix){
  prefix = prefix || 'newdoc-';
  const nameInput = document.getElementById(prefix+'name');
  const name = nameInput.value.trim();
  if(!name){ toast('Document name is required.'); return; }
  const status = document.getElementById(prefix+'status').value;
  const fileInput = document.getElementById(prefix+'file');
  const file = fileInput.files[0];
  await withBusy(async ()=>{
    const { data, error } = await window.sb.from('documents').insert({community_id:id, name, status}).select().single();
    if(error) throw error;
    if(file){
      try{ await attachFileToDocument(id, data.id, file); }
      catch(e){
        await refresh();
        throw new Error(`document saved, but the file didn't attach (${e.message}). Use "Attach file" on that row to retry.`);
      }
    }
    await refresh();
    toast(file ? 'Document and file added.' : 'Document added.');
  });
};

window.removeFlag = async function(id, flagId){
  await withBusy(async ()=>{
    const { error } = await window.sb.from('flags').delete().eq('id', flagId);
    if(error) throw error;
    await refresh();
  });
};
window.addFlag = async function(id){
  const input = document.getElementById('newflag-input');
  const val = input.value.trim();
  if(!val) return;
  await withBusy(async ()=>{
    const { error } = await window.sb.from('flags').insert({community_id:id, flag_text:val});
    if(error) throw error;
    await refresh();
  });
};

window.addComm = async function(id){
  const channel = document.getElementById('comm-channel').value;
  const summary = document.getElementById('comm-summary').value.trim();
  const date = document.getElementById('comm-date').value || new Date().toISOString().slice(0,10);
  if(!summary){ toast('Add a short summary first.'); return; }
  await withBusy(async ()=>{
    const { error } = await window.sb.from('comms').insert({
      community_id:id, comm_date:date, channel, logged_by: state.user?.email || '', summary
    });
    if(error) throw error;
    await refresh();
    toast('Communication logged.');
  });
};

window.deleteCommunity = async function(id){
  if(!confirm('Remove this community record and all its documents, flags, and comms? This cannot be undone.')) return;
  await withBusy(async ()=>{
    const { error } = await window.sb.from('communities').delete().eq('id', id);
    if(error) throw error;
    state.view='board'; state.activeId=null;
    await refresh();
    toast('Record removed.');
  });
};

window.clearAllData = async function(){
  if(!confirm('Clear ALL records for everyone using this board? This cannot be undone.')) return;
  await withBusy(async ()=>{
    const { error } = await window.sb.from('communities').delete().neq('id', '__never_matches__');
    if(error) throw error;
    state.view='board';
    await refresh();
    toast('All data cleared.');
  });
};

window.saveForm = async function(id){
  const get = k => document.getElementById('f-'+k).value.trim();
  const orgName = get('orgName');
  if(!orgName){ toast('Organization name is required.'); return; }
  const acronym = get('acronym') || orgName;
  const fields = {
    name: acronym, full_org_name: orgName, location: get('location'),
    founded_year: get('foundedYear'), member_count: get('memberCount'),
    primary_contact: get('primaryContact'), other_leaders: get('otherLeaders'),
    project_type: get('projectType'), water_source: get('waterSource'), water_problems: get('waterProblems'),
    beneficiaries: get('beneficiaries'), impact: get('impact'),
    proposed_infrastructure: get('proposedInfrastructure'), proposed_location: get('proposedLocation'),
    technical_specs: get('technicalSpecs'), budget_estimate: get('budgetEstimate'), timeline: get('timeline'),
    management_committee: get('managementCommittee'), user_fees: get('userFees'), maintenance_plan: get('maintenancePlan'),
    org_role: get('orgRole'), exit_vision: get('exitVision'), me_commitment: get('meCommitment'),
    prior_projects: get('priorProjects'), other_funders: get('otherFunders'), referral_source: get('referralSource'),
    org_references: get('references'), community_contribution: get('communityContribution'),
  };

  await withBusy(async ()=>{
    if(state.formMode === 'new'){
      const id = newId(orgName);
      fields.id = id;
      fields.stage = 'Submission Received';
      fields.date_received = new Date().toISOString().slice(0,10);
      const { error } = await window.sb.from('communities').insert(fields);
      if(error) throw error;
      await window.sb.from('comms').insert({
        community_id:id, comm_date:new Date().toISOString().slice(0,10),
        channel:'Document received', logged_by: state.user?.email || '', summary:'New intake filed.'
      });
      toast('Community filed.');
      state.view='detail'; state.activeId=id;
    } else {
      const { error } = await window.sb.from('communities').update(fields).eq('id', id);
      if(error) throw error;
      toast('Details updated.');
      state.view='detail';
    }
    await refresh();
  });
};

/* ============================= RENDER: BOARD ============================= */
function renderBoard(){
  const q = state.search.toLowerCase();
  const filtered = state.communities.filter(c =>
    !q || (c.orgName||'').toLowerCase().includes(q) || (c.location||'').toLowerCase().includes(q) || (c.acronym||'').toLowerCase().includes(q)
  );
  const totalFlags = state.communities.reduce((n,c)=>n+complianceIssues(c),0);
  const inVetting = ['Submission Received','Under Review','Due Diligence','Site Visit'];

  const cols = STAGES.map(st=>{
    const items = filtered.filter(c=>c.stage===st.key);
    const cards = items.map(c=>{
      const issues = complianceIssues(c);
      return `<div class="card" style="border-left-color:${st.color}" onclick="openDetail('${c.id}')">
        <div class="org">${esc(c.acronym || c.orgName)}</div>
        <div class="loc">${esc(c.location||'')}</div>
        <div class="row">
          <span class="days mono">${daysSince(c.dateReceived)}</span>
          <span class="badges">${issues>0 ? `<span class="dot red" title="${issues} open item(s)"></span>` : ''}</span>
        </div>
      </div>`;
    }).join('') || `<div class="empty-col">No records</div>`;
    return `<div class="col">
      <div class="col-head"><span class="col-count">${items.length}</span><div class="t">${st.key}</div><div class="f">${st.fr}</div></div>
      <div class="col-cards">${cards}</div>
    </div>`;
  }).join('');

  return `
  <div class="toolbar">
    <div class="stat"><span class="n">${state.communities.length}</span><span class="l">Communities</span></div>
    <div class="stat"><span class="n">${state.communities.filter(c=>inVetting.includes(c.stage)).length}</span><span class="l">In vetting</span></div>
    <div class="stat"><span class="n">${state.communities.filter(c=>c.stage==='Active / Implementation').length}</span><span class="l">Active</span></div>
    <div class="search"><input type="text" placeholder="Search by organization or location…" value="${esc(state.search)}" oninput="setSearch(this.value)"></div>
    ${totalFlags>0 ? `<span class="flagchip">● ${totalFlags} open item${totalFlags===1?'':'s'}</span>` : ''}
  </div>
  <div class="board-wrap"><div class="board">${cols}</div></div>`;
}

/* ============================= RENDER: DETAIL ============================= */
function renderDetail(id){
  const c = findCommunity(id);
  if(!c) return `<div class="page"><button class="back" onclick="backToBoard()">← Back</button><p>Record not found.</p></div>`;
  const kv = (k,v) => `<div class="kv"><div class="k">${k}</div><div class="v ${v?'':'empty'}">${v?esc(v):'Not yet provided'}</div></div>`;
  const stageOptions = STAGES.map(s=>`<option value="${esc(s.key)}" ${s.key===c.stage?'selected':''}>${s.key}</option>`).join('');

  const docs = (c.documents||[]).map(d=>`
    <div class="docrow">
      <div><div class="dn">${esc(d.name)}</div><div class="dnote">${esc(d.note||'')}</div></div>
      <div class="docactions">
        ${documentFileActions(c, d)}
        <button class="statuspill ${d.status}" onclick="cycleDocStatus('${c.id}','${d.id}')" title="Click to change status">${d.status}</button>
      </div>
    </div>`).join('') || `<div class="dnote">No documents logged yet.</div>`;

  const flags = (c.flags||[]).map(f=>`
    <div class="flagrow"><span>${esc(f.text)}</span><button onclick="removeFlag('${c.id}','${f.id}')">Clear</button></div>`).join('') || `<div class="dnote">No open flags.</div>`;

  const comms = (c.comms||[]).map(m=>`
    <div class="commrow">
      <div class="meta">${esc(m.date)} · ${esc(m.channel)}${m.by?` · ${esc(m.by)}`:''}</div>
      <div class="sum">${esc(m.summary)}</div>
    </div>`).join('') || `<div class="dnote">No communications logged yet.</div>`;

  return `<div class="page">
    <button class="back" onclick="backToBoard()">← Back to pipeline</button>
    <div class="detail-head">
      <div>
        <h2>${esc(c.orgName)}${c.acronym && c.acronym!==c.orgName?` <span style="color:var(--teal);font-size:18px;">(${esc(c.acronym)})</span>`:''}</h2>
        <div class="loc">${esc(c.location||'')} &nbsp;·&nbsp; Received ${esc(c.dateReceived||'—')}</div>
      </div>
      <div class="stagepicker">
        <select onchange="changeStage('${c.id}', this.value)">${stageOptions}</select>
        <div class="headbtns">
          <button class="btn btn-outline" onclick="openEditForm('${c.id}')">Edit details</button>
          <div class="kebabmenu">
            <button class="icon-btn" onclick="toggleMenu()">⋮</button>
            ${state.menuOpen ? `<div class="menupop"><button onclick="deleteCommunity('${c.id}')">Delete record</button></div>` : ''}
          </div>
        </div>
      </div>
    </div>

    <div class="section"><h3>Organization</h3>
      ${kv('Founded', c.foundedYear)}${kv('Members', c.memberCount)}
      ${kv('Primary contact', c.primaryContact)}${kv('Other leaders', c.otherLeaders)}
    </div>
    <div class="section"><h3>Water challenge & scale</h3>
      ${kv('Project type', c.projectType)}${kv('Current water source', c.waterSource)}
      ${kv('Problems', c.waterProblems)}${kv('Beneficiaries', c.beneficiaries)}${kv('Impact', c.impact)}
    </div>
    <div class="section"><h3>Proposed project</h3>
      ${kv('Infrastructure', c.proposedInfrastructure)}${kv('Location / land', c.proposedLocation)}
      ${kv('Technical specs', c.technicalSpecs)}${kv('Budget estimate', c.budgetEstimate)}${kv('Timeline', c.timeline)}
    </div>
    <div class="section"><h3>Sustainability & management</h3>
      ${kv('Management committee', c.managementCommittee)}${kv('User fees', c.userFees)}
      ${kv('Maintenance plan', c.maintenancePlan)}${kv("Org's role", c.orgRole)}
      ${kv('Exit vision', c.exitVision)}${kv('M&E commitment', c.meCommitment)}
    </div>
    <div class="section"><h3>Track record & references</h3>
      ${kv('Prior projects', c.priorProjects)}${kv('Other funders', c.otherFunders)}
      ${kv('Referral source', c.referralSource)}${kv('References', c.references)}
    </div>
    <div class="section"><h3>Community investment</h3>${kv('Contribution', c.communityContribution)}</div>
    <div class="section"><h3>Documents & compliance</h3>
      <div class="doclist">${docs}</div>
      <div class="adddoc">
        <input id="newdoc-name" type="text" placeholder="Document name…">
        <select id="newdoc-status"><option value="missing">missing</option><option value="valid">valid</option><option value="expired">expired</option></select>
        <input id="newdoc-file" type="file">
        <button class="btn btn-outline" onclick="addDocument('${c.id}')">Add document</button>
      </div>
    </div>
    <div class="section">
      <h3>Open flags</h3>
      <div class="flaglist">${flags}</div>
      <div class="addflag">
        <input id="newflag-input" type="text" placeholder="Add a flag or open item…" onkeydown="if(event.key==='Enter') addFlag('${c.id}')">
        <button class="btn btn-outline" onclick="addFlag('${c.id}')">Add</button>
      </div>
    </div>
    <div class="section">
      <h3>Communications log</h3>
      <div class="commlist">${comms}</div>
      <div class="addcomm">
        <div class="r">
          <input type="date" id="comm-date" value="${new Date().toISOString().slice(0,10)}">
          <select id="comm-channel">
            <option>Call</option><option>WhatsApp</option><option>Email</option>
            <option>Field visit</option><option>Partner coordination</option>
            <option>Document received</option><option>Other</option>
          </select>
        </div>
        <textarea id="comm-summary" placeholder="What happened / was discussed…"></textarea>
        <div style="text-align:right;"><button class="btn btn-primary" onclick="addComm('${c.id}')">Log communication</button></div>
      </div>
    </div>
  </div>`;
}

/* ============================= RENDER: FORM ============================= */
function renderForm(id){
  const isEdit = state.formMode==='edit';
  const c = isEdit ? findCommunity(id) : {};
  const f = (key,label,hint,tag) => `<div class="field"><label>${label}${hint?` <span class="hint">${hint}</span>`:''}</label>${tag==='textarea'?`<textarea id="f-${key}">${esc(c[key])}</textarea>`:`<input id="f-${key}" type="text" value="${esc(c[key])}">`}</div>`;

  return `<div class="page">
    <button class="back" onclick="${isEdit?`openDetail('${id}')`:`backToBoard()`}">← Cancel</button>
    <h2>${isEdit ? 'Edit community record' : 'New community intake'}</h2>
    <p style="color:var(--ink-soft);font-size:13.5px;margin:6px 0 16px;">Mirrors LFF's Guide de Demande de Partenariat — Projets d'Eau. Leave anything unknown blank; that's normal at intake.</p>

    <fieldset><legend>1 · Organization</legend>
      <div class="field-grid">${f('orgName','Organization name')}${f('acronym','Short name / acronym')}</div>
      ${f('location','Location','village / section / commune / department')}
      <div class="field-grid">${f('foundedYear','Founded')}${f('memberCount','Members')}</div>
      ${f('primaryContact','Primary contact','name — role — phone — email')}
      ${f('otherLeaders','Other leaders')}
    </fieldset>
    <fieldset><legend>2 · Water challenge</legend>
      ${f('projectType','Project type')}${f('waterSource','Current water source(s)')}
      ${f('waterProblems','Problems','shortages, quality, distance, cost…','textarea')}
      ${f('beneficiaries','Who is affected','households / direct / indirect')}
      ${f('impact','Impact of the problem','textarea')}
    </fieldset>
    <fieldset><legend>3 · Proposed project</legend>
      ${f('proposedInfrastructure','Type of infrastructure')}${f('proposedLocation','Proposed location / land ownership')}
      ${f('technicalSpecs','Technical specs (if known)')}${f('budgetEstimate','Budget estimate')}${f('timeline','Timeline expectations')}
    </fieldset>
    <fieldset><legend>4 · Sustainability & management</legend>
      ${f('managementCommittee','Management committee')}${f('userFees','User contributions / fees')}
      ${f('maintenancePlan','Maintenance plan')}${f('orgRole',"Organization's role")}
      ${f('exitVision','Long-term / exit vision')}${f('meCommitment','M&E commitment')}
    </fieldset>
    <fieldset><legend>5 · Experience & references</legend>
      ${f('priorProjects','Prior projects')}${f('otherFunders','Other funders')}
      ${f('referralSource','How they heard about LFF')}${f('references','References')}
    </fieldset>
    <fieldset><legend>6 · Community investment</legend>
      ${f('communityContribution','Financial + in-kind contribution, % of total budget','textarea')}
    </fieldset>

    <div class="formbar">
      <button class="btn btn-outline" onclick="${isEdit?`openDetail('${id}')`:`backToBoard()`}">Cancel</button>
      <button class="btn btn-primary" onclick="saveForm('${isEdit?id:''}')">${isEdit?'Save changes':'File this community'}</button>
    </div>
  </div>`;
}

/* ============================= RENDER: DOCUMENTS (all communities) ============================= */
function renderDocumentsView(){
  const q = state.docSearch.toLowerCase();
  const rows = [];
  state.communities.forEach(c=>{
    (c.documents||[]).forEach(d=>{
      if(!q || (c.orgName||'').toLowerCase().includes(q) || (c.acronym||'').toLowerCase().includes(q) || (d.name||'').toLowerCase().includes(q)){
        rows.push({community:c, doc:d});
      }
    });
  });
  const counts = {valid:0, expired:0, missing:0};
  state.communities.forEach(c=>(c.documents||[]).forEach(d=>{ counts[d.status] = (counts[d.status]||0)+1; }));

  const communityOptions = state.communities.map(c=>`<option value="${c.id}">${esc(c.acronym||c.orgName)}</option>`).join('');

  const rowsHtml = rows.map(({community:c, doc:d})=>`
    <div class="docrow">
      <div>
        <div class="dn">${esc(d.name)}</div>
        <div class="dnote">
          <a href="#" onclick="openDetail('${c.id}');return false;" style="color:var(--teal);font-weight:700;text-decoration:none;">${esc(c.acronym||c.orgName)}</a>
          ${d.note?` · ${esc(d.note)}`:''}
        </div>
      </div>
      <div class="docactions">
        ${documentFileActions(c, d)}
        <button class="statuspill ${d.status}" onclick="cycleDocStatus('${c.id}','${d.id}')" title="Click to change status">${d.status}</button>
      </div>
    </div>`).join('') || `<div class="dnote" style="padding:20px 0;text-align:center;">No documents match.</div>`;

  return `<div class="page" style="max-width:920px;">
    <h2 style="margin-bottom:4px;">All Documents & Forms</h2>
    <p style="color:var(--ink-soft);font-size:13.5px;margin:0 0 16px;">Every document logged across every community, in one place.</p>

    <div class="toolbar" style="border:1px solid var(--line);border-radius:12px;margin-bottom:16px;background:#fff;">
      <div class="stat"><span class="n">${rows.length}</span><span class="l">Total docs</span></div>
      <div class="stat"><span class="n" style="color:#2c6e3a;">${counts.valid||0}</span><span class="l">Valid</span></div>
      <div class="stat"><span class="n" style="color:var(--red);">${counts.expired||0}</span><span class="l">Expired</span></div>
      <div class="stat"><span class="n" style="color:var(--amber);">${counts.missing||0}</span><span class="l">Missing</span></div>
      <div class="search"><input type="text" placeholder="Search by community or document name…" value="${esc(state.docSearch)}" oninput="setDocSearch(this.value)"></div>
    </div>

    <div class="section">
      <div class="doclist">${rowsHtml}</div>
    </div>

    <div class="section">
      <h3>Add a document</h3>
      <div class="adddoc">
        <select id="gdoc-community" style="min-width:220px;">${communityOptions}</select>
        <input type="text" id="gdoc-name" placeholder="Document name">
        <select id="gdoc-status"><option value="valid">valid</option><option value="expired">expired</option><option value="missing" selected>missing</option></select>
        <input type="file" id="gdoc-file">
        <button class="btn btn-outline" onclick="addDocument(document.getElementById('gdoc-community').value, 'gdoc-')">Add document</button>
      </div>
    </div>
  </div>`;
}

/* ============================= MASTER RENDER ============================= */
function render(){
  const root = document.getElementById('root');
  if(!state.loaded){ root.innerHTML = `<div class="loading">Loading pipeline…</div>`; return; }

  const header = `
    <div class="topbar">
      <div class="brand"><h1>La Famille Foundation</h1><div class="sub">Community Partnership Pipeline</div></div>
      <div class="actions">
        <div class="userchip"><span class="email">${esc(state.user?.email||'')}</span></div>
        ${state.view==='board' || state.view==='documents' ? `<button class="btn btn-outline" style="background:rgba(255,255,255,.12);color:#fff;border-color:transparent;" onclick="${state.view==='documents'?'backToBoard()':'openDocuments()'}">${state.view==='documents'?'← Pipeline board':'📄 Documents'}</button>` : ''}
        ${state.view==='board' ? `<button class="btn btn-primary" onclick="openNewForm()">+ New intake</button>` : ''}
        <div class="kebabmenu">
          <button class="icon-btn btn-ghost" onclick="toggleMenu()" style="border-radius:8px;">⋮</button>
          ${state.menuOpen ? `<div class="menupop"><button onclick="clearAllData()">Clear all data</button><button onclick="signOut()">Sign out</button></div>` : ''}
        </div>
      </div>
    </div>`;

  const errorBanner = state.loadError ? `<div class="error-banner">Couldn't load live data: ${esc(state.loadError)}</div>` : '';

  let body = '';
  if(state.view==='board') body = renderBoard();
  else if(state.view==='detail') body = renderDetail(state.activeId);
  else if(state.view==='form') body = renderForm(state.activeId);
  else if(state.view==='documents') body = renderDocumentsView();

  root.innerHTML = header + errorBanner + body;
}

/* Called by auth.js once a session exists */
async function bootApp(session){
  state.user = session.user;
  await refresh();
}
