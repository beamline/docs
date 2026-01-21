# wikimedia_source

???+ warning "Extra package required!"
	To use this source you need to install package `pybeamline-real-sources` with:
	```
	pip install pybeamline-real-sources
	```

Source that connects to the stream of recent change operations happening on the Media Wiki websites (see <https://wikitech.wikimedia.org/wiki/Event_Platform/EventStreams_HTTP_Service> and <https://www.mediawiki.org/wiki/Manual:RCFeed>).

**ATTENTION:** it is advisable to apply a filter operation to consider only events relevant to one of the websites.


## Parameters

* *None*


## Example

```python
from pybeamline.filters import retains_on_event_attribute_equal_filter
from pybeamline.sinks.print_sink import print_sink
from pybeamline_real_sources.wikimedia import wikimedia_source

wikimedia_source().pipe(
	retains_on_event_attribute_equal_filter("wiki", ["dewiki"])
).subscribe(print_sink())
```

Output:

```
(edit, f7ed88659d276caef4e00a0fabb6c3bd, dewiki, 2020-00-00 15:23:19.704655 - {'user': 'Tohma', 'revision': {'old': 263529160, 'new': 263529200}, 'comment': '/* Redakteur des verschwörungstheoretischen Blogs NachDenkSeiten. */', 'server_name': 'de.wikipedia.org', 'server_url': 'https://de.wikipedia.org', 'namespace': 1, 'timestamp': 1769005398, 'wiki': 'dewiki', 'bot': False, 'length': {'old': 5727, 'new': 5843}, 'title': 'Diskussion:Florian Warweg'} - {} - {})
(edit, 5d668c42da72ea67bcc61ed3209efdde, dewiki, 2020-00-00 15:23:22.484338 - {'user': 'Urmelbeauftragter', 'revision': {'old': 263529080, 'new': 263529197}, 'comment': '/* 56. Jahrestreffen 2026 */ Update', 'server_name': 'de.wikipedia.org', 'server_url': 'https://de.wikipedia.org', 'namespace': 0, 'timestamp': 1769005389, 'wiki': 'dewiki', 'bot': False, 'length': {'old': 244004, 'new': 245149}, 'title': 'Weltwirtschaftsforum'} - {} - {})
(edit, 73a2f591a258857bc8c56334a1df47dc, dewiki, 2020-00-00 15:23:26.428809 - {'user': 'Kriddl', 'revision': {'old': 263529045, 'new': 263529201}, 'comment': '/* Oscarverleihung 1988 */', 'server_name': 'de.wikipedia.org', 'server_url': 'https://de.wikipedia.org', 'namespace': 100, 'timestamp': 1769005404, 'wiki': 'dewiki', 'bot': False, 'length': {'old': 27431, 'new': 27440}, 'title': 'Portal:Film und Fernsehen/Fehlende Oscar-Artikel'} - {} - {})
(edit, 2667808e53e036566cd4f1a4792a7bd6, dewiki, 2020-00-00 15:23:28.048902 - {'user': '~2026-45554-3', 'revision': {'old': 262793578, 'new': 263529202}, 'comment': '', 'server_name': 'de.wikipedia.org', 'server_url': 'https://de.wikipedia.org', 'namespace': 0, 'timestamp': 1769005405, 'wiki': 'dewiki', 'bot': False, 'length': {'old': 328988, 'new': 328980}, 'title': 'Liste griechischer Sagen'} - {} - {})
(edit, 1d119f1541ad69b9ebdddfbc21ca717f, dewiki, 2020-00-00 15:23:29.800785 - {'user': 'Spürnase2013', 'revision': {'old': 263529171, 'new': 263529203}, 'comment': '', 'server_name': 'de.wikipedia.org', 'server_url': 'https://de.wikipedia.org', 'namespace': 2, 'timestamp': 1769005408, 'wiki': 'dewiki', 'bot': False, 'length': {'old': 806, 'new': 2114}, 'title': 'Benutzer:Spürnase2013/Mailand–Sanremo 1957'} - {} - {})
(edit, 227de05cfe03a8b4bfe29cdfd9103a7a, dewiki, 2020-00-00 15:23:35.704019 - {'user': '~2026-35153-1', 'revision': {'old': 263528936, 'new': 263529204}, 'comment': 'Amt ihres Bruders hinzugefügt', 'server_name': 'de.wikipedia.org', 'server_url': 'https://de.wikipedia.org', 'namespace': 0, 'timestamp': 1769005414, 'wiki': 'dewiki', 'bot': False, 'length': {'old': 11176, 'new': 11212}, 'title': 'Désirée Silfverschiöld'} - {} - {})
(categorize, dd49cdd04189d39f52fbac66c34e022e, dewiki, 2020-00-00 15:23:36.159790 - {'user': 'Urmelbeauftragter', 'comment': '[[:Weltwirtschaftsforum]] zur Kategorie hinzugefügt', 'server_name': 'de.wikipedia.org', 'server_url': 'https://de.wikipedia.org', 'namespace': 14, 'timestamp': 1769005389, 'wiki': 'dewiki', 'bot': False, 'title': 'Kategorie:Wikipedia:Vorlagenfehler/Vorlage:Internetquelle'} - {} - {})
(edit, 23e6825eec7f2b30aa0f9abb80299990, dewiki, 2020-00-00 15:23:36.695967 - {'user': 'Bernd Rohlfs', 'revision': {'old': 263529131, 'new': 263529205}, 'comment': '/* Strafverfahren */', 'server_name': 'de.wikipedia.org', 'server_url': 'https://de.wikipedia.org', 'namespace': 0, 'timestamp': 1769005414, 'wiki': 'dewiki', 'bot': False, 'length': {'old': 22962, 'new': 23095}, 'title': 'Christina Block'} - {} - {})

```