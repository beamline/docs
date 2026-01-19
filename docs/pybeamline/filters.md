# Filters

The [filter operator, in ReactiveX,](https://reactivex.io/documentation/operators/filter.html) does not change the stream, but filters the events so that only those passing a predicate test can pass. In Beamline there are some filters already implemented that can be used as follows:

```python
from pybeamline.sources import log_source
from pybeamline.filters import excludes_activity_filter, retains_activity_filter

log_source(["ABC", "ACB", "EFG"]).pipe(
    excludes_activity_filter("A"),
    retains_activity_filter("G")
).subscribe(lambda x: print(str(x)))
```

Filters can operate on event attributes or trace attributes. Please note that filters can be chained together in order to achieve the desired result.




## `retains_on_event_attribute_equal_filter`

Retains events based on the equality of an event attribute. Example:
```python
from pybeamline.sources import log_source
from pybeamline.filters import retains_on_event_attribute_equal_filter

log_source("test.xes").pipe(
	retains_on_event_attribute_equal_filter("event-attrib", ["ev", "ab"]),
).subscribe(lambda x: print(str(x)))
```

## `excludes_on_event_attribute_equal_filter`

Exclude events based on the equality of an event attribute.
```python
from pybeamline.sources import log_source
from pybeamline.filters import excludes_on_event_attribute_equal_filter

log_source("test.xes").pipe(
	excludes_on_event_attribute_equal_filter("event-attrib", ["ev", "ab"]),
).subscribe(lambda x: print(str(x)))
```

## `retains_on_trace_attribute_equal_filter`

Retains events based on the equality of a trace attribute.
```python
from pybeamline.sources import log_sourcelog_source
from pybeamline.filters import retains_on_trace_attribute_equal_filter

log_source("test.xes").pipe(
	retains_on_trace_attribute_equal_filter("trace-attrib", ["tv", "ab"]),
).subscribe(lambda x: print(str(x)))

```

## `excludes_on_trace_attribute_equal_filter`
    Excludes events based on the equality of a trace attribute.
    ```python
    from pybeamline.sources import log_source
    from pybeamline.filters import excludes_on_trace_attribute_equal_filter
    
    log_source("test.xes").pipe(
        excludes_on_trace_attribute_equal_filter("trace-attrib", ["tv", "ab"]),
    ).subscribe(lambda x: print(str(x)))

    ```

## `retains_activity_filter`

Retains activities base on their name (`concept:name`).
```python
from pybeamline.sources import log_source
from pybeamline.filters import retains_activity_filter

log_source(["ABC", "ACB", "EFG"]).pipe(
	retains_activity_filter("G")
).subscribe(lambda x: print(str(x)))
```

## `excludes_activity_filter`

Excludes activities base on their name (`concept:name`).
```python
from pybeamline.sources import log_source
from pybeamline.filters import excludes_activity_filter

log_source(["ABC", "ACB", "EFG"]).pipe(
	excludes_activity_filter("A"),
).subscribe(lambda x: print(str(x)))
```