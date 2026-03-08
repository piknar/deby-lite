try:
    from ddgs import DDGS
except ImportError:
    from duckduckgo_search import DDGS

def search(query: str, results=5, region="wt-wt", time="y") -> list:
    ddgs = DDGS()
    src = ddgs.text(
        query,
        region=region,
        safesearch="off",
        timelimit=time,
        max_results=results
    )
    return list(src) if src else []
