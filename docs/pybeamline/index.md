# Getting Started

In this page pyBeamline is presented.

## *Hello world* with pyBeamline

This is an example of a simple dataflow implemented in pyBeamline:

```python linenums="1"
xes_log_source_from_file("test.xes").pipe(
    simple_dfg_miner(),
    dfg_str_to_graphviz()
).subscribe(graphviz_sink())
```

This code takes an XES log file and converts it into a stream. On this stream, a simple DFG miner is executed and it's output is converted and rendered in Graphviz (in a Jupyter Notebook).



## Differences with PM4PY

PM4PY has a [package dedicated to streaming algorithms](https://processintelligence.solutions/pm4py/examples/streaming-process-mining). This package, however, does not allow the construction of [the dataflow for the processing of the events](https://en.wikipedia.org/wiki/Dataflow). Instead, it allows the application of a single algorithm on a defined stream. While this might be useful in certain situation, having the ability to construct the dataflow represents a fundamental architecture for stream processing.

???+ note "What is a dataflow?"
    Here is the definition from the [corresponding Wikipedia page](https://en.wikipedia.org/wiki/Dataflow):
    > In computing, dataflow is a broad concept, which has various meanings depending on the application and context. In the context of software architecture, data flow relates to stream processing or reactive programming.

    > [...]
    
    > Dataflow computing is a software paradigm based on the idea of representing computations as a directed graph, where nodes are computations and data flow along the edges. Dataflow can also be called stream processing or reactive programming.
    
    > There have been multiple data-flow/stream processing languages of various forms (see Stream processing). Data-flow hardware (see Dataflow architecture) is an alternative to the classic von Neumann architecture. The most obvious example of data-flow programming is the subset known as reactive programming with spreadsheets. As a user enters new values, they are instantly transmitted to the next logical "actor" or formula for calculation.
    
    > Distributed data flows have also been proposed as a programming abstraction that captures the dynamics of distributed multi-protocols. The data-centric perspective characteristic of data flow programming promotes high-level functional specifications and simplifies formal reasoning about system components.
