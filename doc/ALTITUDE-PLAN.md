# Altitude plan: components, package graph and reading order

This plan answers one complaint and one wish.

The complaint: the *Architecture* tab of `VectorGraphics-Canvas-Fonts` drew thirty-one boxes and
forty-three lines, and read as a heap of text.
Filtering the diagram to the classes the package defines and the classes its declarations point at
brought it to seventeen boxes, which is legible but still the wrong altitude: seventeen class names
do not say what the font engine *is*.

The wish: something closer to [archify](https://github.com/tt-a1i/archify), which draws a system as
eight to twelve components with drill-down, reach and a reading order.

This document says what of archify is worth copying, what is not, and in what order we build it.

## 1. What archify actually does, and what we keep

Archify is two tools under one skill.

**The diagram half** has no parser at all.
An agent reads the repository and writes a typed JSON intermediate representation; bundled
validators check schema, layout and label clearance; `deliver` renders one self-contained HTML file
with pan and zoom, node focus, upstream and downstream reach, route probes, lenses and exports.
Its quality comes from the instruction *"show 8–12 core components"* — from a human-chosen altitude,
not from a layout algorithm.

**The code-analysis half** is deterministic static analysis, one adapter per language: a bundled
TypeScript parser, a transplanted Pyright, `java-parser`, compiled Go and Rust helpers, libclang for
C and C++.
It produces a module graph, findings, an overview and an Atlas workbench, plus a `check` command
with CI exit codes and baselines, and a `drift` command that compares the authored IR against the
code at a given commit.

What this means for us:

| Archify feature | Our position |
| --- | --- |
| Per-language parser adapters | Not needed. The image holds the AST, the senders, the references and the package graph already. |
| Authored JSON IR plus schema validators | Not needed as a file. Our declarations are pragmas on the accessors, and the test suite is the validator. |
| `drift --ir` against a commit | Not needed. A declaration that lives on the accessor cannot drift from the accessor; the checker reports a declaration whose target has gone. |
| `check` CI gate with exit codes | Already held, in a better form: `VGArchitectureTest` fails the suite. |
| Self-contained HTML viewer, story video, share cards | Declined. The reader is working inside the image, where the inspector already gives pan, zoom and live objects. |
| Ten diagram types, lenses, route cards | Declined. One class diagram, one component diagram and one package diagram answer the questions we actually ask. |
| **Component altitude, authored by hand** | **Copied. This is the idea worth having.** |
| **Module-level graph (their Atlas ring)** | **Copied, as a package graph.** |
| **Hotspot ordering as a reading order** | **Copied, formula and caveat alike.** |

Archify's own caveat about its hotspot ordering — *"a reading order, not inferred business
importance"* — is repeated here because it is the honest claim, and the one we can keep.

## 2. Vocabulary

**Component.** A named part of a design, holding one or more classes, with a one-line statement of
what it is for. A component is authored, never inferred: inferring it is what produced the heap of
text in the first place.

**Resident and visitor.** Already drawn: a class the drawn package defines is a resident, a class a
declaration reaches into another package for is a visitor.

**Altitude.** Which of the three diagrams a reader is looking at: packages, components, or classes.
A fourth, the object graph of one live instance, already exists.

**Reading order.** The order in which the classes of a component, or the components of a project,
repay being read. A hint for a newcomer, not a ranking of importance.

## 3. The decisions, settled on 2026-11-27

Eight decisions, taken in the interview that preceded the first unit. They are stated here as
decided, because every unit below reads them.

1. **A map is project-scoped.** One map covers a route across packages. The font route spans
   `VectorGraphics-Canvas-Fonts`, `VectorGraphics-Bloc-Text` and `VectorGraphics-TrueType`, and a
   component that stopped at a package boundary would cut the route in three. A package tab shows
   the slice of the map that touches that package.
2. **A map is a class.** `VGFontRouteMap`, a subclass of `ArchDocComponentMap`, in the project's
   documentation package. `class >> packageNames` states the packages it claims and
   `class >> components` holds the rows. Maps are found by `ArchDocComponentMap allSubclasses`, so a
   project may hold several routes. The manifest was the alternative, and it was declined because a
   map that spans three packages has no manifest it belongs to.
3. **Coverage is total and components are disjoint**, over the packages a map claims. A class in no
   component is `#unmappedClass`; a class in two is `#ambiguousClass`; a name the image does not
   hold is `#unknownComponentClass`. All three are findings, so a class added to the route turns the
   architecture test red until someone says where it belongs.
4. **Drill-down is by inspecting the component.** A click on a node inspects that
   `ArchDocComponent`, which carries its own tabs. There is no breadcrumb and no second canvas: the
   inspector's own history is the way back.
5. **All three edge kinds lift.** One edge per ordered pair of components, styled by the strongest
   kind it carries — `#holding` over `#cache` over `#use` — labelled with how many class-level
   edges it stands for, with the roles in the popup. An inferred use between two components that no
   declaration explains stays visible, faintly, because that is what says a declaration is missing.
6. **Declaration order lays out the component diagram.** Components are drawn left to right in the
   order the map declares them, so the route reads from its input to its output and a backward edge
   is visibly backward. No force layout at component altitude, which makes the picture the same on
   every open. Class altitude keeps the force layout, because a package has no inherent order.
7. **Two entry points.** Inspecting the map class gives Components, Findings and Reading order;
   every claimed package gains a Components tab showing its slice, beside the Architecture tab it
   already has.
8. **The first map claims `VectorGraphics-Canvas-Fonts` and `VectorGraphics-Bloc-Text`** — 21
   classes, about five components. `VectorGraphics-TrueType` and its 44 classes join once its own
   declarations exist, and draw as visitor boxes until then.

## 4. Phase A — component altitude

Seven units, all done. Each unit ended with the five artefacts and clean critics (§7).

### A1 — `ArchDocComponent` (done)

A value object over one row of the authored map: name, class names, intention, declaring class.

```smalltalk
VGFontRouteMap class >> components
	^ {
		#( 'Glyph cache' #( VGGlyphAtlas VGGlyphMask ) 'keeps the rasterised mask of a glyph so a
			 character is drawn once and blitted thereafter' ) .
		#( 'Font face' #( VGFontFace VGFontOptions ) 'the parsed font and the options a scaled font
			 is built with' ) }
```

- `ArchDocComponent class >> fromTableRow: declaredIn:`, mirroring
  `ArchDocRelation class >> fromTableRow:declaredIn:`.
- `classes` answers only the names the image holds; `unknownClassNames` answers the rest, so a
  renamed or unloaded class is a finding of the checker rather than a silent gap in the diagram.
- Example: `ArchDocComponentExamples class >> glyphCache`, which names one class the image does not
  hold on purpose.
- View: `inspectionClasses:` — every name of the row with what the image says about it.

### A2 — `ArchDocComponentMap` (done)

The whole map of a route, declared by a subclass.

- `ArchDocComponentMap class >> components` and `class >> packageNames` are the two declarations a
  subclass writes; `class >> maps` answers every concrete subclass.
- `components`, `componentOf: aClass`, `componentNamed:`, `claimedClasses`, `unmappedClasses`,
  `ambiguousClasses`, `unknownClassNames`.
- `claimedClasses` drops a class that describes a package rather than belongs to its design, which
  is a package manifest or a map, through `describesRatherThanBelongs:`.
- `ArchDocExampleMap`, in `ArchDoc-Examples`, carries one ambiguous class, one unknown class name and
  one unmapped class on purpose — the same trick as `ArchDocBrokenSubject` — and is marked
  `<archDocDeliberatelyBroken>` so that no reader repairs it.
- Views: `inspectionComponents:` (the parts, their size and their intention), `inspectionCoverage:`
  and, from A7, `inspectionPackages:`.

### A3 — checker findings at component altitude (done)

Three new kinds, answered by the map about itself and folded into the checker of every package the
map claims:

- `#unmappedClass` — a class of a claimed package that no component names.
- `#ambiguousClass` — a class two components name.
- `#unknownComponentClass` — a component naming a class the image does not hold.

`ArchDocChecker >> maps` answers the maps claiming the package it reads, and `componentFindings`
folds their findings in, so a reader opening a package is told its classes are unmapped without
knowing a map exists. `ArchDocChecker >> countRows` reads the kinds off the findings themselves, so
a kind written later appears in the summary tab with no line added for it.

### A4 — the component graph (done)

`ArchDocComponentMap >> classEdges` reads every edge of every claimed package through the models that
already compute them, and `edges` lifts them: one edge per ordered pair of components, the strongest
kind winning (`#holding` over `#cache` over `#use`), an edge inside one component dropped, an edge
touching a class no component names dropped too.

As built, the lifted edge is its own class, `ArchDocLiftedEdge`, a subclass of `ArchDocEdge` holding
the count and the roles; a plain edge answers a count of one, which is what it stands for.
`ArchDocComponent` gained `=` and `hash` over the part it names, so a map read twice answers
components an edge and a set can match.

`ArchDocComponentMap >> graph` answers an `ArchDocGraph` whose nodes are components.

### A5 — drawing a component (done)

As built, this is a new class after all: `ArchDocComponentRenderer`, a subclass of
`ArchDocGraphRenderer`. The class diagram keeps its force layout, which suits a graph of self
holdings and cycles; a handful of parts in a declared order must not be laid out by one, because the
picture would differ every time it is drawn.

- The boxes lie on one row, left to right, in declaration order. `labelFor:` is a hook on the base
  renderer, so the component boxes name the part and its size where the class boxes name the class.
- An edge pointing at a part declared earlier is routed below the row as an `RSPolyline`, each
  backward edge at its own depth.
- Every line carries the number of class edges it stands for, drawn beside it in the line's own
  colour at full opacity.
- `inspectionReadingOrder:` says the same thing in words: each part numbered as it is drawn, with the
  number of its arrows that read against the order.

### A6 — a click opens the component (done)

Each box is wired with `when: RSMouseClick send: #openNodeFrom: to: self`, which opens the part as an
object. The test reads the subscription rather than delivering a click, since delivering one opens a
window, and a second test states that the object a click opens is the part the box draws.

`ArchDocComponent` answers the questions that need the map itself: `map`, `edges` (the lifted arrows
touching it), `classEdges` (the edges between its own classes) and `graph`. Its `inspectionRelations:`
reads the arrows from where the part stands, and `inspectionDiagram:`, in the Roassal package, draws
its own classes.

### A7 — the tabs, and the first real map (done)

- `ArchDocComponentMap >> inspectionDiagram:`, order 0, in `ArchDoc-Roassal`: the picture the whole
  altitude is for. The name `inspectionComponents:` was already the parts table of A2, so the diagram
  took the name every other diagram tab of this project has.
- `ArchDocComponentMap >> inspectionPackages:`: the packages the map claims, each with the number of
  classes it is answerable for there.
- `Package >> inspectionComponents:`, order 85, in `VectorGraphics-Documentation`, gated by
  `inspectionComponentsContext:` on `Package >> archDocComponentMap` being non-nil, so components come
  before classes and the tab appears nowhere a map does not claim. The *Architecture* tab stays, at
  class altitude.
- `VGFontRouteMap` maps `VectorGraphics-Canvas-Fonts` and `VectorGraphics-Bloc-Text` in six parts —
  the face, the scaled font, the glyph cache, the measurements, the Bloc seat and the Cairo route —
  which is one more than this plan guessed, because the Bloc seat and the Cairo route are two
  different routes and not one.
- The coverage test went to `VGFontArchitectureTest`, which already holds `fontPackageNames`, rather
  than to `VGArchitectureTest`: every class of the two packages is in exactly one part, no part names
  a class the image does not hold, and the map reports no finding. `VGArchitectureTest
  allowedDependencies` gained the two edges the new test and the new example make.

**Cost: about two sessions.** This is the unit that answers the original complaint, and it should be
built before the rest of the font documentation (slice two of `FONT-ARCHDOC-PLAN.md`), because
`VectorGraphics-TrueType` has forty-four classes and would reproduce the heap of text at class
altitude however well the boxes are spaced.

## 5. Phase B — the package graph

Four units, all done.

### B1 — `ArchDocProjectModel` (done)

Built from a package-name prefix or a list of names: nodes are packages, edges are references
between them, counted. It reuses the class-altitude models rather than inventing a second scan —
one `ArchDocModel` per package answers `allEdges`, and `liftClassEdges` lifts them onto the packages
the two ends live in, the same lifting a component map does over its parts.

As built, two things the plan did not say:

- The diagram draws every arrow between two packages of the project, and of the arrows pointing
  outside it only the ones a declaration states. Every package reaches the kernel and the
  collections, so a picture holding all of that answers no question about where the project sits.
  `edges` keeps the complete set for the tables and the checker; `drawnEdges` is what the picture
  shows, and `ArchDocPackageRenderer` says in its *Left out* tab what was dropped.
- Naming a node moved to `ArchDocGraph class >> describe:`, which both the graph and the edge ask.
  Each said it for itself before, and both said it of classes alone, so a package node read as
  `a Package(ArchDoc-Core)` in a box. Anything that answers `name` is called by it; a live object in
  an object graph prints itself. The first attempt was an `archDocDescription` extension on `Object`,
  `Class` and `Package`, which was withdrawn: an extension pulls Pharo's own class into this
  package, and `run_critics` on `ArchDoc-Core` then reported thirty-four critiques of the kernel.

`title` is the beginning every package name shares, without the separating dash, so the project is
called `ArchDoc` and `VectorGraphics` with nothing declared.

### B2 — forbidden edges are marked (done)

A package arrow whose source manifest forbids its target is `#forbidden`, a kind of its own rather
than a flag beside one, so the style and the legend row are read off the kind like every other.
Being a kind and not a use, such an arrow is also drawn when it points out of the project: a
forbidden reach is the reason to look outside.

The manifest reading moved to `ArchDocChecker class >> forbiddenPatternsOf:` and
`class >> package:forbids:`, which the checker's own instance side now asks as well, so there is one
place to read it. `ArchDocProjectModelTest` holds the red lines and the checker's findings to the
same set of package pairs, which is the equality this unit was for.

### B3 — drawing a package (done)

`ArchDocPackageRenderer`, a subclass of `ArchDocGraphRenderer`. A box names the package and how many
classes it holds; the fill marks a package of the project against one it depends on. It keeps the
force layout, because a project holds cycles between its own packages.

It keeps the project beside the graph, for the question this picture provokes: what is not drawn.
Its *Left out* tab names every reference out of the project that no declaration states, with the
count of class references behind each.

### B4 — the tab (done)

- `ArchDocPackageRenderer class >> onProject:focusing:` and `focusColor`: the package a reader came
  from is filled apart from the other residents, and the legend says so when there is one.
- `Package >> inspectionNeighbours:`, order 80, with `Package >> archDocProject` and the gate
  `inspectionNeighboursContext:` on this project's own package prefix. It lives in
  `VectorGraphics-Documentation` beside the architecture and components tabs, and not in
  `ArchDoc-Roassal`: an extension of `Package` pulls Pharo's class into the extending package's
  critics, and `ArchDoc-Roassal` is held to none.
- The three altitudes now read widest first on a package of the project: the project at 80, the
  components at 85, the classes at 90.
- `VGDocumentationExamples class >> projectPackageGraph` is the one-click example, with
  `VectorGraphics-Canvas-Fonts` in focus.

**Cost: about one session.** It is cheap because every ingredient exists; it is worth having because
it is the picture that says where a package sits, which no class diagram can.

## 6. Phase C — reading order

Three units, all done.

### C1 — the score (done)

`ArchDocReadingOrder on: aGraph` answers `nodesInOrder`, `scoreOf:`, `fanInOf:`, `fanOutOf:` and
`sizeOf:`. Archify's formula, with the one substitution the image forces:

```
score := size * (1 + (1 + fanIn) log: 2)
```

`size` is the characters of source of a node's methods, both sides — Pharo has no file to count the
lines of. `fanIn` is how many other nodes of the *same graph* point at the node. Ties break by
fan-in, then fan-out, then name, as archify's do, so the order is total and a reader who asks twice
reads the same list. The method comment of `scoreOf:` carries the caveat verbatim: a reading order,
not importance.

Two deviations from this section as it was written.

- **Fan-in is counted inside the graph being ordered, not across the project or the image.** The
  question the tab answers is where to start reading *this* package; a reference from another
  package belongs to that package's reading order. An image-wide count would also rank whatever the
  test packages touch most.
- **The red test could not say "a class nothing references scores below an identical class that ten
  reference", because no two classes of this image are identical in size.** It states the fan-in
  term alone instead, by scoring each of two classes against its own size, and a second test states
  that the node ten others reach is read first and that the order does not change on a second
  asking.

A node of any kind answers a size, in one `sizeOf:` asking `respondsTo:` — a class by its methods on
both sides, a package by its classes, a component by the classes it names, anything else by one.
That is the precedent `ArchDocGraph class >> describe:` set: one place deciding, and no extension
method on a kernel class, which Phase B withdrew after it cost 34 critiques.

### C2 — `Where to start` (done)

`ArchDocReadingOrder >> inspectionWhereToStart:` builds the table: reading position, node, score,
how many nodes reach it, and its source size. The order is read once into a local, because a column
block runs per drawn row and the sort costs 26 ms on a package of twelve classes.

The tab is offered at two altitudes by delegation — `ArchDocComponent` and, in
`VectorGraphics-Documentation`, `Package >> inspectionWhereToStart:` at order 95, after *Neighbours*
(80), *Components* (85) and *Architecture* (90). Each builds the order's own table through the
builder it was handed, so the rows are the same rows everywhere and nothing is scored twice. The
three tabs gated on this project's own packages asked the same question in three copies; they now
ask `Package >> isDocumentedByThisProject`.

### C3 — the same order over components (done)

`ArchDocComponentMap >> inspectionWhereToStart:` orders the parts of the map by the same formula
over the lifted graph: a part weighs what the classes it names weigh, and is reached by the parts
the lifted arrows come from.

Not built: the same tab on `ArchDocProjectModel`. A reader asking which *package* of a project to
read first is a reasonable question, but nothing has asked it yet, and the project tab already
answers where a package sits.

**Cost: about half a session, as estimated.**

## 7. Acceptance, per unit

No unit is done until all of this holds:

1. the failing test was written first and was seen to fail;
2. the smallest code that passes it is in the image, and the suite is green;
3. the duplication the green step introduced has been removed, and the names say what the code
   means;
4. a class-side `<sampleInstance>` example exists in `ArchDoc-Examples`, rebuilding its object every
   call, asserting nothing, runnable with one click;
5. a custom `inspection<Name>: aBuilder` view exists, taking the builder, mutating nothing, asking
   the real rule rather than restating it;
6. `run_critics` is clean on every class the unit touched;
7. the work is committed in Iceberg at that green step.

`ArchDoc-Tests` must be green at the end of every unit, and `VectorGraphics-Documentation-Tests`
and `VGArchitectureTest` at the end of every unit that touches VectorGraphics.

## 8. Deferred, with the condition that would start it

- **Mermaid or SVG export.** Start it when something outside the image has to read a diagram — a
  README, the book, a pull request. Write it as text out of `ArchDocGraph`, not as a viewer.
- **Narrative architecture prose in the manifests.** Slice two of `FONT-ARCHDOC-PLAN.md`; the
  component map should exist first, because the prose will be organised by component.
- **A route view traced from a real run** (`AlgoTrace`, MetaLinks). Start it only after two or three
  real component diagrams have been read and found useful. It is the largest piece of new machinery
  in either plan and the least proven.
- **PharoVulkan.** After the font route is documented end to end.
- **Anything from archify's delivery chrome** — HTML viewer, story video, share cards, route cards,
  presentation stage. Start it when a reader without a Pharo image has to be served, and not before.

## 9. Cost and benefit, stated plainly

All three phases are built. They came to roughly the estimate — three and a half to four sessions of
the usual cycle — with no new external dependency beyond Roassal, which was already pinned, and no
new file format.
They reuse `ArchDocModel`, `ArchDocChecker` and `ArchDocGraphRenderer` rather than displacing them.

The benefit is one thing: a reader who opens a package sees six components with a sentence each
before seeing any class, and descends only where the question leads.
That is what makes archify's pictures readable, and it is the part that costs us the least, because
the image already knows everything the parsers in that project were written to find out.
