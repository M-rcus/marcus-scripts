#!/usr/bin/node

/**
 * Sort clipboard copy-paste from DIGITALCRIMINAL/OnlyFans into a unique, alphabetical list.
 * Useful when using multiple auths and a lot of shared creators (especially free ones...).
 */

const clipboardy = require('clipboardy');
const reg = / ?\| \d+ = /g;
const input = clipboardy.readSync();

if (!input) {
    console.error('[OnlyFans Sort Clipboard] Nothing in clipboard');
    process.exit(1);
}

const list = input
             // Replace the beginning part
             .replace(/^.+0 = All/g, '')
             // 'Split' the string into a newline-based list
             .replace(reg, '\n')
             // Trim the list (remove leading/trailing whitespace)
             .trim();

const unique = list
               // Split the list into an array
               .split('\n')
               // Sort it alphabetically, ascending
               .sort()
               // Filter unique values
               .filter((value, index, self) => {
                   return self.indexOf(value) === index;
               });

// Join back the filtered list into a newline-based list
const text = unique.join('\n');
// Write the filtered list to clipboard
clipboardy.writeSync(text);
console.log('[OnlyFans Sort Clipboard] Sorted/filtered list written to clipboard.');