#!/home/dichotomy/ai/gemini/rdp_exec -Cf

#host=192.168.0.252
#port=9223
#url="https://duboku.info/voddetail/196694.html"
#clean

(async () => {
    // 1. Get the list of all GS tabs
    const tabs = Array.from(document.querySelectorAll('.myui-panel__head .nav-tabs li a'));
    const gsTab = tabs.find(t => t.textContent.includes('GS'));
    if (!gsTab) {
        remoteLog("GS tab not found");
        return { error: "GS tab not found" };
    }

    const tabId = gsTab.getAttribute('href');
    const tabContent = document.querySelector(tabId);
    if (!tabContent) {
        remoteLog("GS tab content container not found");
        return { error: "GS tab content container not found" };
    }

    const links = Array.from(tabContent.querySelectorAll('a[href*="/vodplay/"]'));
    remoteLog(`Found ${links.length} links`);
    
    // 2. Process the first link as a test
    const v = {
        name: links[0].textContent.trim(),
        url: links[0].href
    };

    remoteLog(`Fetching URL: ${v.url}`);
    
    // The reason res.text() failed in an object return is usually:
    // 1. Missing parentheses around the object literal: res => ({ t: ... })
    // 2. Not awaiting res.text() which is a promise.
    
    try {
        const res = await fetch(v.url);
        const text = await res.text();
        
        const r = /player_[a-z]+/i;
        const match = r.exec(text);
        
        remoteLog(`Match found: ${!!match}`);

        return {
            url: v.url,
            match: match ? match[0] : null,
            text_length: text.length,
            // Returning a snippet of text to confirm it's working
            snippet: text.substring(0, 100) 
        };
    } catch (e) {
        remoteLog(`Fetch error: ${e.message}`);
        return { error: e.message };
    }
})();
