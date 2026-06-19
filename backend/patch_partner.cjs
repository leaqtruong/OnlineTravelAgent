const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'partner', 'index.html');
let content = fs.readFileSync(filePath, 'utf8');

// Replace titles
content = content.replace(/TravelAgent Admin \| Awwwards/g, 'TravelAgent Partner | Extranet');
content = content.replace(/Admin Panel/g, 'Partner Dashboard');
content = content.replace(/>Admin</g, '>Partner<');

// Replace API calls
content = content.replace(/\/api\/admin\/hotels/g, '/api/partner/hotels');
content = content.replace(/\/api\/admin\/tours/g, '/api/partner/tours');

// Replace auth header
content = content.replace(/opt\.headers\['Authorization'\]='Basic '\+auth;/g, "opt.headers['Authorization']='Bearer '+auth;");
content = content.replace(/sessionStorage\.getItem\('adminAuth'\)/g, "localStorage.getItem('partner_token')");
content = content.replace(/sessionStorage\.removeItem\('adminAuth'\)/g, "localStorage.removeItem('partner_token')");

// Replace promptLogin logic
const loginLogic = `
async function promptLogin(){
  const email=prompt('Partner Email:');
  if(!email) return false;
  const pass=prompt('Partner Password:');
  if(!pass) return false;
  
  try {
    const r = await fetch(API+'/api/auth/login', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({email: email, password: pass})
    });
    const d = await r.json();
    if(!r.ok) throw new Error(d.message || 'Login failed');
    localStorage.setItem('partner_token', d.token);
    
    // Also upgrade to partner just in case
    await fetch(API+'/api/auth/become-partner', {
      method: 'POST',
      headers: {'Authorization': 'Bearer '+d.token}
    });
    
    return true;
  } catch (e) {
    alert(e.message);
    return false;
  }
}
`;

content = content.replace(/function promptLogin\(\)\{[\s\S]*?return true;\s*\}/, loginLogic);

// Hide unused menu items
content = content.replace(/onclick="nav\('destinations'\)"/g, 'onclick="nav(\'destinations\')" style="display:none"');
content = content.replace(/onclick="nav\('flights'\)"/g, 'onclick="nav(\'flights\')" style="display:none"');
content = content.replace(/onclick="nav\('trips'\)"/g, 'onclick="nav(\'trips\')" style="display:none"');
content = content.replace(/onclick="nav\('users'\)"/g, 'onclick="nav(\'users\')" style="display:none"');
content = content.replace(/onclick="nav\('documents'\)"/g, 'onclick="nav(\'documents\')" style="display:none"');
content = content.replace(/onclick="nav\('categories'\)"/g, 'onclick="nav(\'categories\')" style="display:none"');

// Fix delete URLs in confirmDel
content = content.replace(/let path=`\/api\/admin\/\$\{type\}s\/\$\{id\}`;/g, "let path=`/api/partner/${type}s/${id}`;");

fs.writeFileSync(filePath, content, 'utf8');
console.log('Partner index.html patched successfully.');
