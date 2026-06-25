const fs=require('fs');
function fix(p){
  if(fs.existsSync(p)){
    let c=fs.readFileSync(p,'utf8');
    c=c.replace(/process\.env\.JWT_SECRET(?!\s*as\s*string)/g,'(process.env.JWT_SECRET as string)');
    c=c.replace(/const \{ (.*?) \} = req\.params;/g, (m, p1)=>{
      return p1.split(',').map(v => {
        let vT = v.trim();
        return `const ${vT} = req.params.${vT} as string;`;
      }).join('\n    ');
    });
    fs.writeFileSync(p,c);
  }
}
const d='src/controllers/';
fs.readdirSync(d).forEach(f => f.endsWith('.ts') && fix(d+f));
fix('src/middlewares/auth.ts');
