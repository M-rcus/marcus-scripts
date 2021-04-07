#!/usr/bin/node
const clipboardy = require('clipboardy');

/**
 * @type {Object}
 */
const regs = {
    bold: {
        regex: /\[\/?B\]/g,
        replace: '**',
    },
    strikethrough: {
        regex: /\[\/?S\]/g,
        replace: '~~',
    },
    listItem: {
        regex: /\[\*\]/g,
        replace: '- ',
    },
    icode: {
        regex: /\[\/?\ICODE\]/gi,
        replace: '`',
    },
    code: {
        regex: /\[\/?\CODE\]/gi,
        replace: '```',
    },
    url: {
        regex: /\[URL='(.*)'](.*)\[\/URL\]/g,
        replace: '$2: <$1>',
    },
    remove: {
        regex: /\[\/?(B|LIST|COLOR|IMG|)(=rgb\([\d, ]+\))?\]/g,
        replace: '',
    },
};

const input = clipboardy.readSync();

if (!input) {
    console.error('Nothing in clipboard');
    process.exit(1);
}

const removeMatches = input.match(regs.remove.regex);
const urlsMatches = input.match(regs.url.regex);

if ((!removeMatches || !urlsMatches) || removeMatches.length < 1 && urlsMatches.length < 1) {
    console.error('Initial checks could not find any valid BBCodes in clipboard. Script may not do anything.');
}

/**
 * Order:
 * - Split string by newline into array
 * - Replace BBCode for the FIRST line.
 * - Join array by newlines
 * - Loop through `regs` to replace the rest:
 *     - strikethrough
 *     - urls
 *     - remove
 */
const split = input.split('\n');
split[0] = split[0].replace(regs.bold.regex, regs.bold.replace);
let text = split.join('\n');

delete regs.bold;

for (const name in regs)
{
    const params = regs[name];
    text = text.replace(params.regex, params.replace);
}

/**
 * Replace template text no one cares about.
 */
text = text.replace(/^Download links:/m, '');
text = text.replace(/^I highly recommend an.+$/m, '');

/**
 * Replace excessive newlines with a maximum of two.
 */
text = text.replace(/\n{2,}/g, "\n\n");

/**
 * Special handling for 'QUOTE' bbcode
 */
let inQuote = false;
const lines = text.split('\n');
for (const lineIdx in lines)
{
    let line = lines[lineIdx];
    const lower = line.toLowerCase();
    if (!inQuote && !lower.includes('[quote')) {
        continue;
    }

    inQuote = true;

    /**
     * Add quote arrows where applicable.
     *
     * First we need to remove the BBCode
     * Then all following lines also need to have quote arrows
     */
    line = line.replace(/^\[quote(=[\w\s]+\]?)/i, '');
    line = line.replace(/^/, '> ');
    line = line.replace(/\[\/quote\]/i, '');
    lines[lineIdx] = line;

    /**
     * This is the end of the quote, so we stop quoting.
     */
    if (lower.includes('[/quote]')) {
        inQuote = false;
    }
}

text = lines.join('\n');

console.log(text);
clipboardy.writeSync(text);
console.log('Written to clipboard.');