import os
import re

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

def fix_html(filepath, is_partner):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Inject HTML
    if 'id="login-screen"' not in content:
        content = content.replace('<body class="flex">', f'<body class="flex">\n{login_html}', 1)
        if is_partner:
             content = content.replace('id="login-title">LOGIN', 'id="login-title">Partner Dashboard')
        else:
             content = content.replace('id="login-title">LOGIN', 'id="login-title">Admin Portal')
             
    # Remove old promptLogin
    content = re.sub(r'async function promptLogin\(\)\{[\s\S]*?return (true|false);\s*\}', '', content)
    
    # Remove any other duplicate promptLogin
    content = re.sub(r'function promptLogin\(\)\{ return false; \}', '', content)
    
    # In checkHealth, since we removed the old promptLogin, we should make sure it shows the login screen instead of doing nothing!
    # Wait, checkHealth just does location.reload() which will reload and show the login screen!
    
    # One more thing: the initAdmin catch block
    catch_block = """catch(e){
    // Show login
    document.getElementById('login-screen').style.display='flex';
    document.getElementById('login-screen').style.opacity='1';
  }"""
    content = re.sub(r'catch\(e\)\{\s*// Show login\s*\}', catch_block, content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

base = "D:/AndroidStudioProject/OnlineTravelAgent/backend"
fix_html(f"{base}/admin/index.html", False)
fix_html(f"{base}/partner/index.html", True)

print("Fixed HTML injection.")
