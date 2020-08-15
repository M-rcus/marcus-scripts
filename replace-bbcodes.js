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
    console.log('Could not find any valid BBCodes in clipboard.');
    process.exit(0);
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

console.log(text);
clipboardy.writeSync(text);
console.log('Written to clipboard.');