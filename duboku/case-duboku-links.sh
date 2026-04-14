#!/home/dichotomy/ai/gemini/rdp_exec -Cf

#host=192.168.0.252
#port=9223
#url="https://duboku.info/voddetail/196694.html"
#clean

(async () => {
    // 1. Get the list of all GS tabs
    const tabs = Array.from(document.querySelectorAll('.myui-panel__head .nav-tabs li a'));
    const gsTab = tabs.find(t => t.textContent.includes('GS'));
    if (!gsTab) return { error: "GS tab not found" };

    const tabId = gsTab.getAttribute('href');
    const tabContent = document.querySelector(tabId);
    if (!tabContent) return { error: "GS tab content container not found" };

    const links = Array.from(tabContent.querySelectorAll('a[href*="/vodplay/"]'));
    
    // 2. Return a list of {name, url}
    return links.map(a => ({
        name: a.textContent.trim(),
        url: a.href
      }));
})();
