const fs = require('fs');
const html = fs.readFileSync('D:/AndroidStudioProject/OnlineTravelAgent/backend/partner/index.html', 'utf8');

// There are multiple script blocks. We want the one that defines initPartner.
const match = html.match(/<script>([\s\S]*?)<\/script>/g);
if (match) {
    match.forEach((scriptTag, idx) => {
        const scriptContent = scriptTag.replace(/<\/?script>/g, '');
        fs.writeFileSync(`temp_script_${idx}.js`, scriptContent);
        try {
            require('child_process').execSync(`node -c temp_script_${idx}.js`);
            console.log(`Script ${idx} is valid.`);
        } catch(e) {
            console.log(`Script ${idx} has error:`, e.stderr.toString());
        }
    });
}
