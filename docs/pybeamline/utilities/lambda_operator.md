# lambda_operator

Allows the injection of a lambda function as an operator.

## Parameters

* **func**: `Callable[[Any], Any]`  
  The lambda function to call on each event.


## Example

```python
from pybeamline.sources import log_source
from pybeamline.algorithms.lambda_operator import lambda_operator
from pybeamline.sinks.print_sink import print_sink

log_source(["ABC","DEF"]).pipe(
	lambda_operator(lambda x: 'CURRENT ACTIVITY IS ' + x.get_event_name()),
	lambda_operator(lambda x: x.lower())
).subscribe(print_sink())
```

Output:

```
current activity is a
current activity is b
current activity is c
current activity is d
current activity is e
current activity is f
```
