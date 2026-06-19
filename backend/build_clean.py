import os
import re

admin_path = 'D:/AndroidStudioProject/OnlineTravelAgent/backend/admin/index.html'
partner_path = 'D:/AndroidStudioProject/OnlineTravelAgent/backend/partner/index.html'

with open(admin_path, 'r', encoding='utf-8') as f:
    html = f.read()

# Replace API URL
html = html.replace("const API='http://localhost:3000';", "const API = window.location.hostname==='localhost'?'http://localhost:3000':'';")

# Replace getAuth
html = re.sub(r'function getAuth\(\)\{\s*return sessionStorage\.getItem\(\'adminAuth\'\)\|\|\'\';\s*\}', 'function getAuth(){ return localStorage.getItem("partner_token")||""; }', html)

# Replace Authorization Header in req() and handleUpload()
html = html.replace("if(auth) opt.headers['Authorization']='Basic '+auth;", "if(auth) opt.headers['Authorization']='Bearer '+auth;")
html = html.replace("'Authorization':'Basic '+getAuth()", "'Authorization':'Bearer '+getAuth()")

# Replace sessionStorage.removeItem('adminAuth')
html = html.replace("sessionStorage.removeItem('adminAuth')", "localStorage.removeItem('partner_token')")

# Replace Admin endpoints with Partner endpoints
html = html.replace('/api/admin', '/api/partner')

# Replace UI texts
html = html.replace('id="login-btn">Đăng nhập', 'id="login-btn">Đăng nhập Partner')
html = html.replace('<h1>Admin Panel</h1>', '<h1>Partner Portal</h1>')

# Hide admin-only tabs
html = html.replace('<div class="nav-item flex items-center justify-between p-4 rounded-[1rem] cursor-pointer text-sm font-semibold text-muted hover:text-primary hover:bg-silver" onclick="navigate(\'destinations\')" id="nav-destinations">', '<div class="nav-item flex items-center justify-between p-4 rounded-[1rem] cursor-pointer text-sm font-semibold text-muted hover:text-primary hover:bg-silver" style="display:none" onclick="navigate(\'destinations\')" id="nav-destinations">')
html = html.replace('<div class="nav-item flex items-center justify-between p-4 rounded-[1rem] cursor-pointer text-sm font-semibold text-muted hover:text-primary hover:bg-silver" onclick="navigate(\'flights\')" id="nav-flights">', '<div class="nav-item flex items-center justify-between p-4 rounded-[1rem] cursor-pointer text-sm font-semibold text-muted hover:text-primary hover:bg-silver" style="display:none" onclick="navigate(\'flights\')" id="nav-flights">')
html = html.replace('<div class="nav-item flex items-center justify-between p-4 rounded-[1rem] cursor-pointer text-sm font-semibold text-muted hover:text-primary hover:bg-silver" onclick="navigate(\'trips\')" id="nav-trips">', '<div class="nav-item flex items-center justify-between p-4 rounded-[1rem] cursor-pointer text-sm font-semibold text-muted hover:text-primary hover:bg-silver" style="display:none" onclick="navigate(\'trips\')" id="nav-trips">')
html = html.replace('<div class="nav-item flex items-center justify-between p-4 rounded-[1rem] cursor-pointer text-sm font-semibold text-muted hover:text-primary hover:bg-silver" onclick="navigate(\'users\')" id="nav-users">', '<div class="nav-item flex items-center justify-between p-4 rounded-[1rem] cursor-pointer text-sm font-semibold text-muted hover:text-primary hover:bg-silver" style="display:none" onclick="navigate(\'users\')" id="nav-users">')
html = html.replace('<div class="nav-item flex items-center gap-4 p-4 rounded-[1rem] cursor-pointer text-sm font-semibold text-muted hover:text-primary hover:bg-silver" onclick="navigate(\'categories\')" id="nav-categories">', '<div class="nav-item flex items-center gap-4 p-4 rounded-[1rem] cursor-pointer text-sm font-semibold text-muted hover:text-primary hover:bg-silver" style="display:none" onclick="navigate(\'categories\')" id="nav-categories">')
html = html.replace('<div class="nav-item flex items-center gap-4 p-4 rounded-[1rem] cursor-pointer text-sm font-semibold text-muted hover:text-primary hover:bg-silver" onclick="navigate(\'documents\')" id="nav-documents">', '<div class="nav-item flex items-center gap-4 p-4 rounded-[1rem] cursor-pointer text-sm font-semibold text-muted hover:text-primary hover:bg-silver" style="display:none" onclick="navigate(\'documents\')" id="nav-documents">')

# Hide dashboard quick links
html = html.replace('<div class="doppelrand cursor-pointer group" onclick="navigate(\'destinations\')">', '<div class="doppelrand cursor-pointer group" style="display:none" onclick="navigate(\'destinations\')">')
html = html.replace('<div class="doppelrand cursor-pointer group" onclick="navigate(\'flights\')">', '<div class="doppelrand cursor-pointer group" style="display:none" onclick="navigate(\'flights\')">')
html = html.replace('<div class="doppelrand cursor-pointer group" onclick="navigate(\'trips\')">', '<div class="doppelrand cursor-pointer group" style="display:none" onclick="navigate(\'trips\')">')

# Replace doLogin
old_do_login_start = html.find('async function doLogin(){')
old_do_login_end = html.find('// ── USERS ──', old_do_login_start)

if old_do_login_start != -1 and old_do_login_end != -1:
    new_logic = """
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
      if(d.user.role !== 'partner' && d.user.role !== 'PARTNER' && d.user.role !== 'admin' && d.user.role !== 'ADMIN') {
        throw new Error('Tài khoản không có quyền đối tác');
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

  async function checkHealth(){
    try{
      await req('/health');
      const dot = document.getElementById('status-dot');
      if (dot) dot.className = 'w-3 h-3 rounded-full bg-green-500 shadow-[0_0_10px_rgba(34,197,94,0.5)]';
      const text = document.getElementById('status-text');
      if (text) text.textContent = 'System Online';
    }catch(e){
      const dot = document.getElementById('status-dot');
      if (dot) dot.className = 'w-3 h-3 rounded-full bg-red-500 shadow-[0_0_10px_rgba(239,68,68,0.5)]';
      const text = document.getElementById('status-text');
      if (text) text.textContent = 'System Offline';
      if(e.message && (e.message.includes('401')||e.message.includes('Unauthorized'))){
        localStorage.removeItem('partner_token');
        location.reload();
      }
    }
  }

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
  
  window.onload = initPartner;
"""
    html = html[:old_do_login_start] + new_logic + html[old_do_login_end:]

with open(partner_path, 'w', encoding='utf-8') as f:
    f.write(html)
print('Partner portal generated successfully.')
