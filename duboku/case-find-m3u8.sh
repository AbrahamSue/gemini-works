#!/home/dichotomy/ai/gemini/rdp_exec -Cf

#host=192.168.0.252
#port=9223
#url="https://duboku.info/vodplay/196694-3-1.html"
#clean

(async () => {
    // 1. Wait for player to load (Duboku often uses a secondary iframe or dynamic player)
    await new Promise(r => setTimeout(r, 5000));
    
    // 2. Look for .m3u8 in the DOM or window object
    // Duboku typically embeds the playlist in a global variable or a source tag
    let m3u8Url = null;

    // Check common window objects or global variables
    const searchString = (str) => {
        if (!str) return null;
        const match = str.match(/https?:\/\/[^"']+\.m3u8/);
        return match ? match[0] : null;
    };

    // Look in script tags
    document.querySelectorAll('script').forEach(s => {
        if (!m3u8Url) m3u8Url = searchString(s.textContent);
    });

    // Look in the entire body as a last resort
    if (!m3u8Url) m3u8Url = searchString(document.body.innerHTML);

    // 3. Return the discovered URL
    return {
        url: window.location.href,
        m3u8: m3u8Url
    };
})();
