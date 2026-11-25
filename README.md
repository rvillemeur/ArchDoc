# ArchDoc

ArchDoc documents the architecture of a Pharo project from the project's own code, so that the
documentation cannot drift away from what the code does.

A project declares its relations where the code already is: a pragma on the accessor that reads the
instance variable, or — for a class that deliberately exposes no accessor — a class-side table. The
declarations cost the declaring package no dependency, because a pragma is a literal.

From those declarations ArchDoc generates:

- a class diagram of a package, with the declared holdings drawn as edges and the undeclared static
  references drawn as inferred uses;
- an object graph of a live instance, read through slot reflection;
- a checker, whose findings are the material of an architecture test: declarations that resolve to
  nothing, opposites that are missing or not reciprocal, sample instances whose actual holdings
  contradict their declarations, and forbidden dependencies between packages.

## Packages

| Package | Holds |
|---|---|
| `ArchDoc-Core` | The model: relations, edges, graphs, the object graph and the checker. No UI dependency. |
| `ArchDoc-Roassal` | The renderers of the class diagram and the object graph. |
| `ArchDoc-Examples` | One `<sampleInstance>` example per class of the library. |
| `ArchDoc-Tests` | The suite. |

## Loading

```smalltalk
Metacello new
	baseline: 'ArchDoc';
	repository: 'gitlocal:///home/me/workspace/iceberg/rvillemeur/ArchDoc/src';
	onConflictUseIncoming;
	load
```
