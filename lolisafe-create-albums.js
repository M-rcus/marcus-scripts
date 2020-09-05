const axios = require('axios');
const config = require('./config/lolisafe');
const signale = require('signale');

const token = config.TOKEN;

/**
 * Configure signale logger with custom settings
 */
signale.config({
    displayDate: true,
    displayTimestamp: true,
});

(async() => {
    const client = new axios.create({
        baseURL: config.baseUrl,
        responseType: 'json',
        headers: {
            token,
        },
    });

    const body = {
        name: '',
        description: '',
        download: true,
        public: true,
    };

    config.albums.sort()
    const albumNames = config.albums;

    const albumIds = [];
    for (const album of albumNames)
    {
        body.name = config.prefix + album;
        const response = await client.post('/api/albums', body);
        const data = response.data;

        if (data.success)
        {
            signale.info(`Successfully created album with name: ${body.name} - ID: ${data.id}`);
            albumIds.push(data.id);
            continue;
        }

        signale.error(data);
    }

    signale.info('Created the following albums:');
    signale.info(albumNames);

    const getAlbums = await client.get('/api/albums');
    const data = getAlbums.data;

    if (!data.success)
    {
        signale.error('Unable to retrieve albums');
        signale.error(data);
        return;
    }

    /**
     * Only list those albums that we just created.
     */
    const albums = data.albums.filter((album) => {
        return albumIds.includes(album.id);
    });

    /**
     * For reference, each album object looks like:
     * {
     *      "id": 1,
     *      "name": "Album name",
     *      "timestamp": 0,
     *      "identifier": "ABCDEF12",
     *      "editedAt": 123,
     *      "download": true,
     *      "public": true,
     *      "description": "Description",
     *      "files": 1337
     * }
     */
    const format = config.printFormat;
    const printList = [];
    for (const album of albums)
    {
        const {name, id, description, files} = album;
        const slug = album.identifier;
        const templates = {
            base_url: config.baseUrl,
            name,
            id,
            description,
            files,
            slug,
        };
        
        let albumFormat = format;
        for (const key in templates)
        {
            const reg = new RegExp(`{${key}}`, 'g');
            albumFormat = albumFormat.replace(reg, templates[key]);
        }

        printList.push(albumFormat);
    }

    signale.info(`Formatted print list:\n${printList.join('\n')}`);
})();