#!/home/dichotomy/ai/gemini/rdp_exec -Cf

#host=192.168.0.252
#port=9223
#url="https://duboku.info/voddetail/196694.html"
#clean

(async () => {
    // Wait for the iframe to load (often where the actual player is)
    await new Promise(r => setTimeout(r, 4000));
    
    // The m3u8 is likely in one of the iframes
    const iframes = Array.from(document.querySelectorAll('iframe'));
    
    // Function to search an iframe
    // Note: Cross-origin restrictions might prevent us from reading iframe.contentDocument
    // But we have the src URLs
    return {
        iframes: iframes.map(i => i.src)
    };
})();
