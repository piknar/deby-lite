import aiohttp

# Public SearXNG instance - change if needed
URL = "https://searx.be/search"

async def search(query: str):
    """Search using public SearXNG instance directly."""
    return await _search(query=query)

async def _search(query: str):
    headers = {
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
    }
    timeout = aiohttp.ClientTimeout(total=15)
    async with aiohttp.ClientSession(headers=headers, timeout=timeout) as session:
        async with session.post(URL, data={"q": query, "format": "json"}) as response:
            return await response.json(content_type=None)
