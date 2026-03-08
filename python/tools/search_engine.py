import os
import asyncio
from python.helpers import dotenv, memory, perplexity_search, duckduckgo_search
from python.helpers.tool import Tool, Response
from python.helpers.print_style import PrintStyle
from python.helpers.errors import handle_error
from python.helpers.searxng import search as searxng

SEARCH_ENGINE_RESULTS = 10


class SearchEngine(Tool):
    async def execute(self, query="", **kwargs):
        # Try DuckDuckGo first (reliable, no local service needed)
        try:
            result = await asyncio.get_event_loop().run_in_executor(
                None, lambda: duckduckgo_search.search(query, results=SEARCH_ENGINE_RESULTS)
            )
            if result:
                return Response(message=self.format_result_ddg(result, "DuckDuckGo"), break_loop=False)
        except Exception as e:
            PrintStyle().warning(f"DuckDuckGo search failed: {e}, trying SearXNG...")

        # Fallback to SearXNG
        try:
            searxng_result = await self.searxng_search(query)
            return Response(message=searxng_result, break_loop=False)
        except Exception as e:
            return Response(message=f"All search engines failed: {str(e)}", break_loop=False)

    def format_result_ddg(self, results, source):
        outputs = []
        for item in results:
            import ast
            try:
                r = ast.literal_eval(item) if isinstance(item, str) else item
                title = r.get('title', '')
                url = r.get('href', r.get('url', ''))
                body = r.get('body', r.get('content', ''))
                outputs.append(f"{title}\n{url}\n{body}")
            except Exception:
                outputs.append(str(item))
        return "\n\n".join(outputs[:SEARCH_ENGINE_RESULTS]).strip()

    async def searxng_search(self, question):
        results = await searxng(question)
        return self.format_result_searxng(results, "Search Engine")

    def format_result_searxng(self, result, source):
        if isinstance(result, Exception):
            handle_error(result)
            return f"{source} search failed: {str(result)}"

        outputs = []
        for item in result["results"]:
            outputs.append(f"{item['title']}\n{item['url']}\n{item['content']}")

        return "\n\n".join(outputs[:SEARCH_ENGINE_RESULTS]).strip()
