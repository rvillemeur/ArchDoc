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

Seven units. Each unit ends with the five artefacts and clean critics (§7).

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

### A2 — `ArchDocComponentMap`

The whole map of a route, declared by a subclass.

- `ArchDocComponentMap class >> components` and `class >> packageNames` are the two declarations a
  subclass writes; `class >> maps` answers every concrete subclass.
- `components`, `componentOf: aClass`, `componentNamed:`, `claimedClasses`, `unmappedClasses`,
  `ambiguousClasses`, `unknownClassNames`.
- Red test: a map over `ArchDoc-Examples` answers one component per row, in declaration order; a
  class named twice is ambiguous; a class of a claimed package named nowhere is unmapped.
- `ArchDocExampleMap`, in `ArchDoc-Examples`, carries one ambiguous class and one unmapped class on
  purpose, so the checker has something to find — the same trick as `ArchDocBrokenSubject`.

### A3 — checker findings at component altitude

Fold into `ArchDocChecker >> findings` three new kinds:

- `#unmappedClass` — a class of a claimed package that no component names.
- `#ambiguousClass` — a class two components name.
- `#unknownComponentClass` — a component naming a class the image does not hold.

Red test: the example map yields exactly one finding of each kind, and `findings` holds them beside
the existing ones. The counts tab (`inspectionCounts:`) shows the new kinds without being told about
them one by one.

### A4 — the component graph

Lift the class-level edges the model already computes.
An edge whose source class sits in component X and whose target sits in component Y becomes one edge
X → Y; an edge inside a component disappears; the strongest kind wins, `#holding` over `#cache` over
`#use`; the edge carries how many class-level edges it stands for and the roles that made it, for
the popup.

- Red test: two classes of one component holding each other draw no component edge; a holding and a
  use between the same two components draw one solid edge whose count is two.
- `ArchDocComponentMap >> graph` answers an `ArchDocGraph` whose nodes are components, so the
  existing renderer draws it unchanged — this is the check that the renderer was factored right.

### A5 — drawing a component

The renderer needs no new class, but it needs two things it does not have:

- a box that holds the component name and the number of classes, with the intention and the class
  names in the popup;
- a layout that follows declaration order — components in a row, left to right, in the order
  `components` answers, with the edges attaching to the borders as they already do. A backward edge
  is drawn below the row, so that it is seen.

Resident and visitor fills apply to the packages the component's classes live in: a component wholly
outside the drawn package is a visitor.

- Red test: the box label of a component names the component and not its first class; two successive
  components sit in increasing x and share a y; the legend (`legendRows`) gains no new row, because
  the styles are the same ones.

### A6 — a click opens the component

A click on a component's shape inspects its model. The handler is one line on the shape; the test
asserts that the shape carries the component as its model and that the component's own views build,
because a test that fakes a mouse tests Roassal rather than us.

- `ArchDocComponent` gains `inspectionRelations:` — the class-level edges that cross its border, read
  from the map — beside the `inspectionClasses:` of A1, and `inspectionDiagram:` in the Roassal
  package, which draws the class graph of its own classes.
- Red test: the diagram of a component holds one node per loaded class of that component.

### A7 — the tabs, and the first real map

In `ArchDoc-Roassal` and `VectorGraphics-Documentation`:

- `ArchDocComponentMap >> inspectionComponents:` (the diagram), `inspectionFindings:` (what the
  checker says about this map), and, after Phase C, `inspectionReadingOrder:`.
- `Package >> inspectionComponents: aBuilder`, order 85, gated on a map claiming that package, so
  components come before classes. The *Architecture* tab stays, at class altitude.

In VectorGraphics itself: write `VGFontRouteMap` over `VectorGraphics-Canvas-Fonts` (13 classes) and
`VectorGraphics-Bloc-Text` (8), about five components.
`VGArchitectureTest` gains a test that every class of those packages is mapped, so a new class
cannot be added to the route silently.

**Cost: about two sessions.** This is the unit that answers the original complaint, and it should be
built before the rest of the font documentation (slice two of `FONT-ARCHDOC-PLAN.md`), because
`VectorGraphics-TrueType` has forty-four classes and would reproduce the heap of text at class
altitude however well the boxes are spaced.

## 5. Phase B — the package graph

Four units.

### B1 — `ArchDocProjectModel`

Built from a package-name prefix or a list: nodes are packages, edges are references between them,
counted.
It reuses `ArchDocModel >> classesReferencedBy:` per package rather than inventing a second scan.

- Red test: a project of the four ArchDoc packages draws an edge from `ArchDoc-Roassal` to
  `ArchDoc-Core` and none the other way, and the edge carries its count.

### B2 — forbidden edges are marked

An edge that `archDocForbiddenDependencies` forbids is drawn in red and reported by the checker,
with one source of truth: the drawn red edges and `ArchDocChecker >> forbiddenDependencies`, lifted
to packages, must be the same set.

- Red test states exactly that equality, so neither can drift.

### B3 — drawing a package

Box holds the package name and its class count; the resident fill marks the packages of the project,
the visitor fill the packages it depends on from outside.

### B4 — the tab

`Package >> inspectionNeighbours: aBuilder`, order 80, showing the project graph with this package
highlighted, and `VGDocumentationExamples class >> projectPackageGraph` as the one-click example.

**Cost: about one session.** It is cheap because every ingredient exists; it is worth having because
it is the picture that says where a package sits, which no class diagram can.

## 6. Phase C — reading order

Three units.

### C1 — the score

Archify's formula, with the one substitution the image forces:

```
score := size * (1 + (1 + fanIn) log: 2)
```

where `fanIn` is the number of classes that reference the class, and `size` is the total source size
of its methods, both sides — Pharo has no file to count lines of.
Ties break by fan-in, then fan-out, then name, as archify's do.

- Red test: a class nothing references scores below an identical class that ten reference; the order
  is stable across runs.
- The method comment carries the caveat verbatim: a reading order, not importance.

### C2 — `Where to start`

An inspector tab on a package and on a component: the classes in reading order, with score, fan-in
and size, selecting one opening it.

### C3 — the same order over components

The component a newcomer should read first, by the same formula applied to the lifted graph.

**Cost: about half a session.**

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

Phases A, B and C together are roughly three and a half to four sessions of the usual cycle, with no
new external dependency beyond Roassal, which is already pinned, and no new file format.
They reuse `ArchDocModel`, `ArchDocChecker` and `ArchDocGraphRenderer` rather than displacing them.

The benefit is one thing: a reader who opens a package sees six components with a sentence each
before seeing any class, and descends only where the question leads.
That is what makes archify's pictures readable, and it is the part that costs us the least, because
the image already knows everything the parsers in that project were written to find out.
