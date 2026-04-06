const fs = require('fs');
const path = require('path');

const dir = path.join(__dirname, 'Ficha_do_Parceiro');
const files = fs.readdirSync(dir).filter(f => f.endsWith('.jrxml'));

let md = '# JRXML Analysis\n\n';

files.forEach(f => {
    const p = path.join(dir, f);
    const content = fs.readFileSync(p, 'utf-8');
    
    let qsMatch = content.match(/<queryString[^>]*>([\s\S]*?)<\/queryString>/);
    let qs = qsMatch ? qsMatch[1] : 'No query string found';
    qs = qs.replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, '$1').trim();
    
    let fieldRegex = /<field name="([^"]+)" class="([^"]+)"\/>/g;
    let fields = [];
    let match;
    while((match = fieldRegex.exec(content)) !== null) {
        fields.push(`- ${match[1]} (${match[2].split('.').pop()})`);
    }
    
    md += `## ${f}\n\n### Fields\n${fields.join('\n')}\n\n### Query\n\`\`\`sql\n${qs}\n\`\`\`\n\n`;
});

fs.writeFileSync(path.join(__dirname, 'parsed_ireports.md'), md);
console.log('Done parsing.');
