const puppeteer = require('puppeteer');
const md5 = require('md5');
const sha1 = require('sha1');
const tmp = require('tmp');

const UAs = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36"
    ];
//const target = 'https://lucb1e.com/rp/cookielesscookies/';
var sessions = [];
var target = "";
var browser_profiles ={};

if (process.argv.length > 2) {
    target = process.argv[2]
} else {
    console.log(`Usage: ${process.argv[0]} ${process.argv[1]} <url>`)
    process.exit(1);
}

console.log(`Analyzing ${target}`)
UAs.forEach(async (UA, i) => {
    sessions.push(new Promise(async (resolve) => {
        browser_profiles[UA] =  user_data_dir = tmp.dirSync({'unsafeCleanup': true});
        const browser = await puppeteer.launch({
            headless: true,
            userDataDir: browser_profiles[UA].name,
            args: [
                `--user-agent=${UA}`,
            ]
        });
        const page = await browser.newPage();
        let urls = {};

        //connect chrome devtools protocol session and activate network interception
        const cdpsession = await page.target().createCDPSession();
        await cdpsession.send('Fetch.enable', { 'patterns': [{ 'requestStage': 'Response' }] });

        requesthandler = async (event) => {
            const requestId = event.requestId;

            if (event.responseStatusCode == 200) {
                const { body, } = await cdpsession.send('Fetch.getResponseBody', { requestId });

                let entry = event.responseHeaders.reduce((e, hdr) => {
                    ['etag', 'last_modified', 'date'].forEach(value => {
                        if (hdr.name.toLowerCase() === value) {
                            e[value] = hdr.value;
                        }
                    });
                    return e;
                }, {});
                if ('etag' in entry) {
                    entry['md5'] = md5(body);
                    entry['sha1'] = sha1(body);
                    urls[event.request.url] = entry;
                }
            }
            await cdpsession.send('Fetch.continueRequest', { requestId });
        }

        await cdpsession.on('Fetch.requestPaused', requesthandler);

        await Promise.all([
            page.waitForNavigation({ 'waitUntil': 'networkidle0' }),
            page.goto(target)
        ]).catch((err) => {
            console.warn(err);
        });

        //---
        // cleanup
        //---
        await browser.close();
        user_data_dir.removeCallback();
        resolve(urls);
    }));
});


Promise.all(sessions).then((urls) => {
    const reference = urls[0];
    const compare = urls.slice(1);
    let candidates = {};

    Object.keys(reference).forEach((url) => {
        compare.forEach((cmp)=>{
            if (url in reference && url in cmp) {
                if (reference[url].etag != cmp[url].etag) {
                    candidates[url] = {};
                    candidates[url][reference[url].etag] = reference[url];
                    candidates[url][cmp[url].etag] = cmp[url];
                    //console.log(`Possible Etag tracking candidate: ${url}\n    Etag 1: ${reference[url].etag}, last modified: ${reference[url].last_modified}\n    md5:  ${reference[url].md5}\n    sha1: ${reference[url].sha1}\n\n    Etag 2: ${cmp[url].etag}, last modified: ${cmp[url].last_modified}\n    md5:  ${cmp[url].md5}\n    sha1: ${cmp[url].sha1}`)
                }
            }
        });
    });
    if (Object.keys(candidates).length !== 0) {
        Object.entries(candidates).forEach((candidate) => {
            console.log(`  Possible Etag tracking candidate: ${candidate[0]}`);
            Object.entries(candidate[1]).forEach((etag, i) => {
                console.log(`    Etag ${i+1}: ${etag[0]}:\n      md5:  ${etag[1].md5}\n      sha1: ${etag[1].sha1}`)
                if ('date' in etag[1]) {
                    console.log(`      date: ${etag[1].date}`)
                } else if ('last_modified' in etag[1]) {
                    console.log(`      last-modified: ${etag[1].last_modified}`)
                }
            });
        });
    } else {
        console.log('  No Etag tracking candidates found');
    }
});