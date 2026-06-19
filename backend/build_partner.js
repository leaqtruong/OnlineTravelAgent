import fs from 'fs';

let content = fs.readFileSync('admin/index.html', 'utf8');

// 1. Replace Titles
content = content.replace(/TravelAgent Admin \| Awwwards/g, "TravelAgent Partner");
content = content.replace(/id="login-title">Admin Portal/g, 'id="login-title">Partner Dashboard');

// 2. Sidebar items: remove unnecessary menus.
// We only want: dashboard, hotels, tours
content = content.replace(/<div class="nav-item[^>]*onclick="nav\('destinations'\)"[\s\S]*?<\/div>/, '');
content = content.replace(/<div class="nav-item[^>]*onclick="nav\('flights'\)"[\s\S]*?<\/div>/, '');
content = content.replace(/<div class="nav-item[^>]*onclick="nav\('trips'\)"[\s\S]*?<\/div>/, '');
content = content.replace(/<div class="nav-item[^>]*onclick="nav\('users'\)"[\s\S]*?<\/div>/, '');
content = content.replace(/<div class="nav-item[^>]*onclick="nav\('documents'\)"[\s\S]*?<\/div>/, '');
content = content.replace(/<div class="nav-item[^>]*onclick="nav\('categories'\)"[\s\S]*?<\/div>/, '');
// For settings, it's at the bottom
content = content.replace(/<div class="mt-auto[^>]*onclick="nav\('settings'\)"[\s\S]*?<\/div>/, '');

// 3. Pages: remove unnecessary page contents
content = content.replace(/<div id="page-destinations"[\s\S]*?<!-- ── HOTELS ── -->/, '<!-- ── HOTELS ── -->');
content = content.replace(/<div id="page-flights"[\s\S]*?<!-- ── TOURS ── -->/, '<!-- ── TOURS ── -->');
content = content.replace(/<div id="page-trips"[\s\S]*?<!-- ── CATEGORIES ── -->/, '<!-- ── CATEGORIES ── -->');
content = content.replace(/<!-- ── CATEGORIES ── -->[\s\S]*?<\/main>/, '</main>');

// 4. Modals: remove unnecessary modals
content = content.replace(/<div id="modal-destination"[\s\S]*?<!-- HOTEL MODAL -->/, '<!-- HOTEL MODAL -->');
content = content.replace(/<div id="modal-flight"[\s\S]*?<!-- TOUR MODAL -->/, '<!-- TOUR MODAL -->');
content = content.replace(/<div id="modal-trip"[\s\S]*?<!-- END MODALS -->/, '<!-- END MODALS -->');

// 5. Replace API paths globally
content = content.replace(/\/api\/admin/g, '/api/partner');

// 6. Rewrite Auth & API functions
const newAuthLogic = `
  const API = window.location.hostname==='localhost'?'http://localhost:3000':'';
  
  function getAuth(){
    return localStorage.getItem('partner_token')||'';
  }

  async function req(path,method='GET',body=null){
    const opt={method,headers:{}};
    const auth=getAuth();
    if(auth) opt.headers['Authorization']='Bearer '+auth;
    if(body){opt.headers['Content-Type']='application/json';opt.body=JSON.stringify(body);}
    const r=await fetch(API+path,opt);
    if(!r.ok) {
      const msg = await r.text() || r.statusText;
      throw new Error(msg);
    }
    return r.json();
  }

  async function checkHealth(){
    try{
      await req('/health');
      document.getElementById('statusDot').className='w-2 h-2 rounded-full bg-emerald-500 shadow-[0_0_12px_rgba(16,185,129,0.8)]';
      document.getElementById('statusText').textContent='Online';
    }catch(e){
      document.getElementById('statusDot').className='w-2 h-2 rounded-full bg-red-500';
      document.getElementById('statusText').textContent='Offline';
    }
  }

  async function doLogin(){
    const user = document.getElementById('login-user').value.trim();
    const pass = document.getElementById('login-pass').value.trim();
    if(!user || !pass) return toast('Vui lòng nhập đủ thông tin','error');
    document.getElementById('login-btn').innerText = 'Đang xử lý...';
    try {
      const r = await fetch(API+'/api/auth/login', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({email: user, password: pass})
      });
      const d = await r.json();
      if(!r.ok) throw new Error(d.message || 'Sai thông tin đăng nhập');
      if(d.user.role !== 'PARTNER' && d.user.role !== 'ADMIN') {
        throw new Error('Tài khoản không có quyền Đối tác');
      }
      localStorage.setItem('partner_token', d.token);
      
      document.getElementById('login-screen').style.opacity = '0';
      setTimeout(()=>document.getElementById('login-screen').style.display='none', 700);
      toast('Đăng nhập thành công!','success');
      
      checkHealth(); loadDashboard(); setInterval(checkHealth, 30000);
    } catch (e) {
      document.getElementById('login-btn').innerHTML = 'Đăng nhập <i class="fa-solid fa-arrow-right ml-2"></i>';
      toast(e.message, 'error');
    }
  }
`;

// Instead of string replacement which is brittle to whitespace, use regex.
// The regex matches everything from const API to the end of doLogin()
content = content.replace(/const API='http:\/\/localhost:3000';[\s\S]*?async function doLogin\(\)\{[\s\S]*?\} catch \(e\) \{[\s\S]*?\}[\s\n]*\}/, newAuthLogic + "\n");

// Then, we need to replace initAdmin
const newInit = `
  async function initPartner(){
    try{
      await req('/api/partner/stats');
      document.getElementById('login-screen').style.display='none';
      checkHealth(); loadDashboard(); setInterval(checkHealth, 30000);
    }catch(e){
      document.getElementById('login-screen').style.display='flex';
      document.getElementById('login-screen').style.opacity='1';
    }
  }
  initPartner();
`;
content = content.replace(/async function initAdmin\(\)\{[\s\S]*?\}[\s\n]*initAdmin\(\);/, newInit);
content = content.replace(/function promptLogin\(\)\{[\s\S]*?\}/, '');

// Fix loaders
const newLoaders = `
    const loaders={
      dashboard:loadDashboard, hotels:loadHotels, tours:loadTours
    };
    if(loaders[page]) loaders[page]().catch(e=>{
      console.error('Load error:',e);
      if(e.message.includes('401')||e.message.includes('Unauthorized')||e.message.includes('Forbidden')||e.message.includes('403')||e.message.includes('Token missing')){
        localStorage.removeItem('partner_token');
        toast('Phiên đã hết hạn, vui lòng đăng nhập lại','error');
        setTimeout(()=>location.reload(),1500);
      }else{
        toast('Lỗi: '+e.message,'error');
      }
    });
`;
content = content.replace(/const loaders=\{[\s\S]*?\}\);/, newLoaders);

// Fix refreshData and openAddModal
content = content.replace(/function refreshData\(\)[\s\S]*?function openAddModal\(\)\{[\s\S]*?\}/, `function refreshData(){loadPage(curPage);}
  function openAddModal(){
    if(curPage==='hotels') openHotelModal();
    if(curPage==='tours') openTourModal();
  }`);

// Remove old JS logic for users, destinations, flights, trips
content = content.replace(/\/\/ ── USERS ──[\s\S]*?\/\/ ── DESTINATIONS ──[\s\S]*?\/\/ ── FLIGHTS ──[\s\S]*?\/\/ ── TRIPS ──[\s\S]*?\/\/ ── SETTINGS ──[\s\S]*?(?=<\/script>)/, '');

// Also remove category related UI/JS since partners don't manage categories
content = content.replace(/<div id="modal-category"[\s\S]*?<!-- END MODALS -->/, '<!-- END MODALS -->');
content = content.replace(/\/\/ ── CATEGORIES ──[\s\S]*?(?=\/\/ ── USERS ──)/, '');


fs.writeFileSync('partner/index.html', content);
console.log("Successfully rebuilt partner/index.html from admin/index.html");
