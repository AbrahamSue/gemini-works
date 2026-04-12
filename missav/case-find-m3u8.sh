#!/home/dichotomy/ai/gemini/rdp_exec -Cf

#host=192.168.0.252
#port=9223
#url="https://missav.ai/dm41/ja/hmn-030-uncensored-leak"
#clean

(async () => {
    // If a URL was passed as a positional argument, it's already used by rdp_exec to load the page.
    // We just need to extract the data from the current page.

    // 1. Metadata Collection
    const originalName = document.querySelector('meta[property="og:title"]')?.content || document.title;
    const referer = window.location.href;
    const userAgent = navigator.userAgent;

    // 2. Name Sanitization
    let rawName = originalName.split(' - ')[0].trim();
    const sanitize = (str) => str.replace(/[\\\/:*?"<>|]/g, '_').replace(/\s+/g, ' ').trim();
    const parts = rawName.split(/\s+/);
    let name = "";

    if (parts.length > 1) {
        const actress = parts.pop();
        const title = parts.join(' ');
        const safeTitle = sanitize(title).substring(0, 100);
        const safeActress = sanitize(actress);
        name = `${safeTitle} ${safeActress}`;
    } else {
        name = sanitize(rawName);
    }

    // 3. Unpacking function for p,a,c,k,e,d
    function unpack(p, a, c, k, e, d) {
        e = function (c) {
            return (c < a ? "" : e(parseInt(c / a))) + ((c = c % a) > 35 ? String.fromCharCode(c + 29) : c.toString(36))
        };
        if (!''.replace(/^/, String)) {
            while (c--) d[e(c)] = k[c] || e(c);
            k = [function (e) { return d[e] }];
            e = function () { return '\\w+' };
            c = 1;
        };
        while (c--) if (k[c]) p = p.replace(new RegExp('\\b' + e(c) + '\\b', 'g'), k[c]);
        return p;
    }

    // 4. Find the script and extract parameters
    const script = Array.from(document.querySelectorAll('script')).find(s => s.textContent.includes('eval(function(p,a,c,k,e,d)'));
    if (!script) return { error: "Packed script not found on " + referer };

    const match = script.textContent.match(/}\s*\('(.*)',\s*(\d+),\s*(\d+),\s*'(.*)'\.split\('\|'\),\s*(\d+),\s*({.*})\)\)/);
    if (!match) return { error: "Parameters not matched" };

    const [_, p, a, c, k, e, d] = match;
    const unpacked = unpack(p, parseInt(a), parseInt(c), k.split('|'), parseInt(e), JSON.parse(d));

    // 5. Extract the Playlist URL
    const urlRegex = /https?:\/\/[^"']+\/playlist\.m3u8[^"']*/g;
    const urlMatch = unpacked.match(urlRegex);
    if (!urlMatch) return { error: "Playlist URL not found in unpacked code" };

    let playlistUrl = urlMatch[0].replace(/\\/g, '');

    // 6. Fetch playlist and get best quality
    try {
        const response = await fetch(playlistUrl);
        const text = await response.text();
        
        const lines = text.split('\n');
        let bestQualityFile = '';
        let maxRes = 0;

        for (let i = 0; i < lines.length; i++) {
            if (lines[i].includes('RESOLUTION=')) {
                const resMatch = lines[i].match(/RESOLUTION=(\d+)x(\d+)/);
                if (resMatch) {
                    const res = parseInt(resMatch[1]) * parseInt(resMatch[2]);
                    if (res >= maxRes) {
                        maxRes = res;
                        bestQualityFile = lines[i+1].trim();
                    }
                }
            }
        }

        if (!bestQualityFile) {
            const m3u8Files = lines.filter(l => l.endsWith('.m3u8') && !l.includes('playlist.m3u8'));
            bestQualityFile = m3u8Files[m3u8Files.length - 1];
        }

        const finalUrl = new URL(bestQualityFile, playlistUrl).href;

        return {
            name: name,
            original_name: originalName,
            referer: referer,
            user_agent: userAgent,
            playlist_url: playlistUrl,
            best_m3u8: finalUrl
        };
    } catch (err) {
        return {
            name: name,
            original_name: originalName,
            referer: referer,
            user_agent: userAgent,
            playlist_url: playlistUrl,
            error: "Failed to fetch/parse playlist: " + err.message
        };
    }
})();
