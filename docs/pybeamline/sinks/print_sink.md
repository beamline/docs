# print_sink

Converts the items into a string and prints them.

## Parameters

* *None*


## Example

```python
from pybeamline.sources import string_test_source
from pybeamline.sinks.print_sink import print_sink

string_test_source(["ABC", "ACB"]).pipe().subscribe(print_sink())
```

Output:
```
(A, case_1, Process, 2020-00-00 13:31:56.857558 - {} - {} - {})
(B, case_1, Process, 2020-00-00 13:31:56.857558 - {} - {} - {})
(C, case_1, Process, 2020-00-00 13:31:56.857558 - {} - {} - {})
(A, case_2, Process, 2020-00-00 13:31:56.857558 - {} - {} - {})
(C, case_2, Process, 2020-00-00 13:31:56.858537 - {} - {} - {})
(B, case_2, Process, 2020-00-00 13:31:56.858537 - {} - {} - {})
```
