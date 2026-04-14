#!/home/dichotomy/ai/gemini/rdp_exec -Cf

#host=192.168.0.252
#port=9223
#url="https://missav.ai/dm19/ja/actresses/%E7%B5%90%E5%9F%8E%E3%82%8A%E3%81%AE?filters=individual&page=1"
#clean

(async () => {
    const getLinks = (doc) => Array.from(doc.querySelectorAll('.thumbnail.group a')).map(a => a.href);
    
    // 1. Calculate max page
    const pageLinks = Array.from(document.querySelectorAll('a[href*="page="]'));
    const pageMax = Math.max(1, ...pageLinks.map(a => parseInt(a.href.match(/page=(\d+)/)?.[1] || 0)));
    
    // 2. Prepare base URL (remove existing page param if any)
    const baseUrl = location.href.replace(/[&?]page=\d+/, '');
    const separator = baseUrl.includes('?') ? '&' : '?';
    
    // 3. Extract from current page
    let allLinks = getLinks(document);
    
    // 4. Fetch all other pages in parallel
    const fetchPromises = [];
    for (let i = 2; i <= pageMax; i++) {
        const url = `${baseUrl}${separator}page=${i}`;
        fetchPromises.push(
            fetch(url)
                .then(r => r.text())
                .then(html => {
                    const parser = new DOMParser();
                    const doc = parser.parseFromString(html, 'text/html');
                    return getLinks(doc);
                })
                .catch(e => {
                    console.error(`Failed to fetch page ${i}:`, e);
                    return [];
                })
        );
    }
    
    const results = await Promise.all(fetchPromises);
    allLinks = allLinks.concat(...results);
    
    // 5. Return unique links
    return [...new Set(allLinks)];
})();
