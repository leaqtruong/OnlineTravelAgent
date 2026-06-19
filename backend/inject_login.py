import os

login_html = """
<div id="login-screen" class="fixed inset-0 z-[999] bg-offwhite flex items-center justify-center transition-all duration-700">
  <div class="doppelrand w-full max-w-sm">
    <div class="doppelrand-inner p-10 flex flex-col items-center">
      <div class="w-16 h-16 bg-primary rounded-2xl flex items-center justify-center text-white text-2xl mb-6 shadow-xl"><i class="fa-solid fa-plane"></i></div>
      <h2 class="text-2xl font-extrabold text-ink mb-2 text-center" id="login-title">LOGIN</h2>
      <p class="text-sm text-muted mb-8 text-center" id="login-subtitle">Vui lòng đăng nhập để tiếp tục</p>
      
      <div class="w-full mb-4">
        <input type="text" id="login-user" class="w-full bg-silver/30 border border-silver rounded-xl px-5 py-3 text-sm font-semibold outline-none focus:border-primary transition-colors" placeholder="Email / Username" />
      </div>
      <div class="w-full mb-8">
        <input type="password" id="login-pass" class="w-full bg-silver/30 border border-silver rounded-xl px-5 py-3 text-sm font-semibold outline-none focus:border-primary transition-colors" placeholder="Mật khẩu" />
      </div>
      
      <button id="login-btn" class="w-full bg-primary hover:bg-ink text-white font-bold py-4 rounded-xl transition-all shadow-glass" onclick="doLogin()">
        Đăng nhập <i class="fa-solid fa-arrow-right ml-2"></i>
      </button>
    </div>
  </div>
</div>
"""

def patch_file(filepath, is_partner):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Inject HTML right after <body>
    if 'id="login-screen"' not in content:
        content = content.replace('<body>', f'<body>\n{login_html}', 1)
    
    # Inject doLogin and modify promptLogin
    if is_partner:
        # For partner
        title = "Partner Extranet"
        login_js = """
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
    localStorage.setItem('partner_token', d.token);
    await fetch(API+'/api/auth/become-partner', { method: 'POST', headers: {'Authorization': 'Bearer '+d.token} });
    
    document.getElementById('login-screen').style.opacity = '0';
    setTimeout(()=>document.getElementById('login-screen').style.display='none', 700);
    toast('Đăng nhập thành công!','success');
    
    checkHealth(); loadDashboard(); setInterval(checkHealth, 30000);
  } catch (e) {
    document.getElementById('login-btn').innerHTML = 'Đăng nhập <i class="fa-solid fa-arrow-right ml-2"></i>';
    toast(e.message, 'error');
  }
}
function promptLogin(){ return false; } // Replaced by UI
"""
    else:
        # For admin
        title = "Admin Portal"
        login_js = """
async function doLogin(){
  const user = document.getElementById('login-user').value.trim();
  const pass = document.getElementById('login-pass').value.trim();
  if(!user || !pass) return toast('Vui lòng nhập đủ thông tin','error');
  document.getElementById('login-btn').innerText = 'Đang xử lý...';
  const auth = btoa(user+':'+pass);
  
  try {
    const r = await fetch(API+'/api/admin/stats', {
      headers: {'Authorization': 'Basic '+auth}
    });
    if(!r.ok) throw new Error('Sai Username hoặc Password');
    sessionStorage.setItem('adminAuth', auth);
    
    document.getElementById('login-screen').style.opacity = '0';
    setTimeout(()=>document.getElementById('login-screen').style.display='none', 700);
    toast('Đăng nhập thành công!','success');
    
    checkHealth(); loadDashboard(); setInterval(checkHealth, 30000);
  } catch (e) {
    document.getElementById('login-btn').innerHTML = 'Đăng nhập <i class="fa-solid fa-arrow-right ml-2"></i>';
    toast(e.message, 'error');
  }
}
function promptLogin(){ return false; } // Replaced by UI
"""

    # Inject JS
    if 'async function doLogin' not in content:
        content = content.replace('// ── USERS ──', f'{login_js}\n// ── USERS ──', 1)
        
    # Set titles
    content = content.replace('id="login-title">LOGIN', f'id="login-title">{title}')
    
    # Hide login screen if auth already valid
    init_logic = """
async function initAdmin(){
  try{
    await req(API_URL_TEST);
    document.getElementById('login-screen').style.display='none';
    checkHealth(); loadDashboard(); setInterval(checkHealth, 30000);
  }catch(e){
    // Show login
  }
}
"""
    api_test = "'/api/partner/stats'" if is_partner else "'/api/admin/stats'"
    init_logic = init_logic.replace('API_URL_TEST', api_test)
    
    # Regex replace initAdmin
    import re
    content = re.sub(r'async function initAdmin\(\)\{[\s\S]*?\}[\s\n]*initAdmin\(\);', init_logic + "\ninitAdmin();", content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

base = "D:/AndroidStudioProject/OnlineTravelAgent/backend"
patch_file(f"{base}/admin/index.html", False)
patch_file(f"{base}/partner/index.html", True)

print("Injected Login UI into both Admin and Partner pages.")
