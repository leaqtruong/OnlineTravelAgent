import fs from 'fs';

let c = fs.readFileSync('D:/AndroidStudioProject/OnlineTravelAgent/backend/partner/index.html', 'utf8');

c = c.replace(/const r2 = await fetch\(API\+'\/api\/auth\/become-partner'[\s\S]*?if\(d2\.token\) localStorage\.setItem\('partner_token', d2\.token\);\s*}/, "");

fs.writeFileSync('D:/AndroidStudioProject/OnlineTravelAgent/backend/partner/index.html', c);
console.log('Removed become-partner.');
