# rejseplanen_source

???+ warning "Extra package required!"
	To use this source you need to install package `pybeamline-real-sources` with:
	```
	pip install pybeamline-real-sources
	```

This source provides the data from the Danish railway system. Traces are represented as individual trains and events are trains reaching a certain station. The data is continuously generate (updated every 5 seconds, see <https://www.rejseplanen.dk/bin/help.exe/mn?L=vs_dot.vs_livemap&tpl=fullscreenmap>). The current source retrieves information about regional and light train (letbane).


## Parameters

* *None*


## Example

```python
from pybeamline.sinks.print_sink import print_sink
from pybeamline_real_sources.rejseplanen import rejseplanen_source

rejseplanen_source().pipe(

).subscribe(print_sink())
```

Output:

```
(Skibstrup St., 84/46798/18/19/86, Rejseplanen, 2020-00-00 14:53:54.051580 - {'train-delay': 2, 'train-previous-stop': 'Saunte St.'} - {'destination': 'Helsingør St.', 'train-name': 'Lokalbane 940R'} - {})
(Favrholm St., 84/23923/18/27/86, Rejseplanen, 2020-00-00 14:53:54.051580 - {'train-delay': 4, 'train-previous-stop': 'Skævinge St.'} - {'destination': 'Hillerød St.', 'train-name': 'Lokalbane 920E'} - {})
(Vig St., 84/23881/18/24/86, Rejseplanen, 2020-00-00 14:53:54.051580 - {'train-delay': 1, 'train-previous-stop': 'Grevinge St.'} - {'destination': 'Nykøbing Sj St.', 'train-name': 'Lokalbane 510R'} - {})
(Nr. Asmindrup St., 84/23879/18/24/86, Rejseplanen, 2020-00-00 14:53:54.051580 - {'train-delay': 0, 'train-previous-stop': 'Sommerland Sj. St.'} - {'destination': 'Holbæk St.', 'train-name': 'Lokalbane 510R'} - {})
(Vallø St., 84/23818/18/38/86, Rejseplanen, 2020-00-00 14:53:54.051580 - {'train-delay': 2, 'train-previous-stop': 'Grubberholm St.'} - {'destination': 'Roskilde St.', 'train-name': 'Lokalbane 210R'} - {})
(Li.Linde St., 84/23794/18/38/86, Rejseplanen, 2020-00-00 14:53:54.051580 - {'train-delay': 2, 'train-previous-stop': 'Karise St.'} - {'destination': 'Køge St.', 'train-name': 'Lokalbane 110R'} - {})
(Lille Kregme St., 84/23663/18/27/86, Rejseplanen, 2020-00-00 14:53:54.051580 - {'train-delay': 1, 'train-previous-stop': 'Kregme St.'} - {'destination': 'Hundested Havn St.', 'train-name': 'Lokalbane 920R'} - {})
(Brede St., 84/23622/18/47/86, Rejseplanen, 2020-00-00 14:53:54.051580 - {'train-delay': 0, 'train-previous-stop': 'Fuglevad St.'} - {'destination': 'Nærum St.', 'train-name': 'Lokalbane 910'} - {})
(Jyderup St., 84/1883/18/20/86, Rejseplanen, 2020-00-00 14:53:54.051580 - {'train-delay': 0, 'train-previous-stop': 'Svebølle St.'} - {'destination': 'Østerport St.', 'train-name': 'Re 1540'} - {})
(Humlebæk St., 84/1697/18/19/86, Rejseplanen, 2020-00-00 14:53:54.051580 - {'train-delay': 0, 'train-previous-stop': 'Espergærde St.'} - {'destination': 'Holbæk St.', 'train-name': 'Re 4561'} - {})
(Hellerup St., 84/1681/18/19/86, Rejseplanen, 2020-00-00 14:53:54.051580 - {'train-delay': 0, 'train-previous-stop': 'Klampenborg St.'} - {'destination': 'Holbæk St.', 'train-name': 'Re 2559'} - {})
(Trekroner St., 84/1631/18/19/86, Rejseplanen, 2020-00-00 14:53:54.051580 - {'train-delay': 0, 'train-previous-stop': 'Roskilde St.'} - {'destination': 'Helsingør St.', 'train-name': 'Re 4536'} - {})
(København H, 84/1430/18/19/86, Rejseplanen, 2020-00-00 14:53:54.051580 - {'train-delay': 0, 'train-previous-stop': 'Nørreport St.'} - {'destination': 'Næstved St.', 'train-name': 'Re 2257'} - {})
(Vedbæk St., 84/1426/18/19/86, Rejseplanen, 2020-00-00 14:53:54.051580 - {'train-delay': 0, 'train-previous-stop': 'Rungsted Kyst St.'} - {'destination': 'Næstved St.', 'train-name': 'Re 4259'} - {})
(Bedsted Thy St., 84/48192/18/19/86, Rejseplanen, 2020-00-00 14:53:54.051580 - {'train-delay': 0, 'train-previous-stop': 'Hurup Thy St.'} - {'destination': 'Thisted St.', 'train-name': 'RA 5541'} - {})
```