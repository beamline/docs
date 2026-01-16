# infinite_size_directly_follows_mapper

Transforms each pair of consequent event appearing in the same case as a directly follows relation (generating a tuple with the two event names). This mapper is called *infinite* because it's memory footprint will grow as the case ids grow.

## Parameters

* *None*

## Returned type

The returned output has type `(str, str)`. The first component is the source activity, the second is the target activity.

## Example

```python
from pybeamline.sinks.print_sink import print_sink
from pybeamline.sources import log_source
from pybeamline.mappers import infinite_size_directly_follows_mapper

log_source(["ABC", "ACB"]).pipe(
    infinite_size_directly_follows_mapper()
).subscribe(print_sink())
```

Output:

```
('A', 'B')
('B', 'C')
('A', 'C')
('C', 'B')
```