const fs = require('fs');

let html = fs.readFileSync('backend/admin/index.html', 'utf8');

// 1. Update Tailwind config
html = html.replace(
  /colors: \{[^}]+\}/,
  `colors: {
            white: '#FFFFFF',
            offwhite: '#F3F8FE',
            silver: '#E2E8F0',
            ink: '#212121',
            muted: '#4D5652',
            primary: '#176FF2'
          }`
);

// 2. Update style block
html = html.replace('body { background: #E6E4DF;', 'body { background: #F3F8FE;');
html = html.replace('background: rgba(230, 228, 223, 0.7);', 'background: rgba(243, 248, 254, 0.7);');
html = html.replace('.nav-item.active { background: #2C2B29; color: #FCFBF9; transform: scale(0.98); }', '.nav-item.active { background: #176FF2; color: #FFFFFF; transform: scale(0.98); }');
html = html.replace('.upload-box:hover { border-color: #2C2B29;', '.upload-box:hover { border-color: #176FF2;');

// 3. Update active nav hover
html = html.replace(/hover:text-ink/g, 'hover:text-primary');

// 4. Update save buttons and focus rings
html = html.replace(/bg-ink/g, 'bg-primary');
html = html.replace(/focus:border-ink/g, 'focus:border-primary');
html = html.replace(/focus:ring-ink/g, 'focus:ring-primary');
html = html.replace(/accent-ink/g, 'accent-primary');

// 5. Some text elements like brand and active text
html = html.replace(/text-ink/g, 'text-ink'); // actually, text-ink is fine as #212121, wait, I shouldn't replace text-ink with text-primary everywhere because text-ink is used for normal text.

// Let's change the blue color of specific icons.
html = html.replace(/"w-12 h-12 bg-primary rounded-2xl/g, '"w-12 h-12 bg-primary rounded-2xl');

fs.writeFileSync('backend/admin/index.html', html, 'utf8');
console.log('Theme updated!');
