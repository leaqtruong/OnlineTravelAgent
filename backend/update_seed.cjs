const fs = require('fs');
let c = fs.readFileSync('prisma/seed.ts', 'utf8');
c = c.replace(/price:\s*\"?(\d+(?:\.\d+)?)\"?/g, (m, p1) => {
  let v = parseFloat(p1);
  return v < 50000 ? `price: ${v * 25000}` : m;
});
c = c.replace(/priceFrom:\s*\"?(\d+(?:\.\d+)?)\"?/g, (m, p1) => {
  let v = parseFloat(p1);
  return v < 50000 ? `priceFrom: ${v * 25000}` : m;
});
c = c.replace(/originalPrice:\s*\"?(\d+(?:\.\d+)?)\"?/g, (m, p1) => {
  let v = parseFloat(p1);
  return v < 50000 ? `originalPrice: ${v * 25000}` : m;
});
fs.writeFileSync('prisma/seed.ts', c);
