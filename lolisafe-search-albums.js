#!/usr/bin/env node
const axios = require('axios');
const config = require('./config/lolisafe');
const meow = require('meow');
const clipboardy = require('clipboardy');

const token = config.TOKEN;


const cli = meow(`
    Usage
      $ lolisafe-search-albums <search text>

    Options
      --sensitive, -s  Do a case sensitive search instead

    Examples
        - Only searches album names including "MEMES HERE" in all caps
              $ lolisafe-search-albums MEMES HERE -s
`, {
    flags: {
        sensitive: {
            type: 'boolean',
            alias: 's'
        }
    }
});


(async() => {
    let search = cli.input.join(' ').trim();
    if (search.length === 0) {
        console.error('No search text provided');
        return;
    }

    const sensitive = cli.flags.sensitive;
    if (!sensitive) {
        search = search.toLowerCase();
    }
    else {
        console.info('--sensitive flag provided - doing case sensitive search');
    }

    const client = new axios.create({
        baseURL: config.baseUrl,
        responseType: 'json',
        headers: {
            token,
        },
    });

    const response = await client.get('/api/albums');
    const data = response.data;
    let albums = data.albums.filter((album) => {
        let albumName = album.name;

        if (!sensitive) {
            albumName = albumName.toLowerCase();
        }

        return albumName.includes(search);
    });

    albums = albums.sort((a, b) => {
        if (a.name < b.name) {
            return -1;
        }

        if (b.name < a.name) {
            return 1;
        }

        return 0;
    })

    /**
     * Yoinked from the create albums script.
     */
    const printFormat = config.searchPrintFormat || config.printFormat;
    const copyFormat = config.searchCopyFormat;
    const printList = [];
    const copyList = [];
    for (const album of albums)
    {
        const {name, id, description, files} = album;
        const slug = album.identifier;
        const templates = {
            base_url: data.baseUrl || config.baseUrl,
            name,
            id,
            description,
            files,
            slug,
        };
        
        let albumPrintFormat = printFormat;
        let albumCopyFormat = copyFormat;
        for (const key in templates)
        {
            const reg = new RegExp(`{${key}}`, 'g');
            albumPrintFormat = albumPrintFormat.replace(reg, templates[key]);
            albumCopyFormat = albumCopyFormat.replace(reg, templates[key]);
        }

        printList.push(albumPrintFormat);
        copyList.push(albumCopyFormat);
    }

    const print = printList.join('\n');
    console.log(print);

    const copyText = copyList.join('\n');
    await clipboardy.write(copyText);
    console.log('Written to clipboard.');
})();