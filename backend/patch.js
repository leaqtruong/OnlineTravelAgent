import fs from 'fs';
let c = fs.readFileSync('D:/AndroidStudioProject/OnlineTravelAgent/backend/partner/index.html', 'utf8');
c = c.replace(/if\(e\.message\.includes\('401'\)\|\|e\.message\.includes\('Unauthorized'\)\)\{/g, "if(e.message.includes('401')||e.message.includes('Unauthorized')||e.message.includes('403')||e.message.includes('Forbidden')){");
fs.writeFileSync('D:/AndroidStudioProject/OnlineTravelAgent/backend/partner/index.html', c);
console.log('patched');
