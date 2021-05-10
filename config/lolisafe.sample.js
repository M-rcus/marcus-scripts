/**
 * !! COPY/RENAME THIS FILE
 *
 * Make sure to copy and rename this file to `lolisafe.js`
 * Or else the `lolisafe-create-albums.js` script will fail.
 */
module.exports = {
    /**
     * Token used for API requests
     */
    TOKEN: process.env.CD_TOKEN,

    /**
     * Prefix of every album name
     */
    prefix: '[Prefix] CreatorName - ',

    /**
     * List of album names (added after prefix)
     */
    albums: [],

    /**
     * Base URL for API/album links
     * Technically this should be compatible with any other hosted versions
     * of https://github.com/BobbyWibowo/lolisafe
     */
    baseUrl: 'https://cyberdrop.me',

    /**
     * Print out each created album with the following format.
     * Available formats:
     * - {name} (Album name)
     * - {base_url}
     * - {slug}
     * - {id}
     * - {files} (number of files)
     */
    printFormat: '- [{name}]({base_url}/a/{slug})',

    /**
     * Similar to `printFormat`, except for the search albums script.
     * @type {String}
     */
    searchPrintFormat: '{base_url}/a/{slug}',
};