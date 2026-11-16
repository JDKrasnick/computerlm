# ComputerLM

Research and implementation work toward fast, efficient computer use through persistent learned task state, action-conditioned prediction, and asynchronous fast and slow computation paths.

**Target:** complete easy and medium workflows faster and more cheaply at comparable task success. Pure accuracy, parameter count, token throughput and price per token do not individually measure this objective.

**Status:** research proposal and early development. The full integrated architecture has not been trained or validated. Development includes evaluation infrastructure and a cache-free recurrent text-core prototype; neither demonstrates the proposed model's end-to-end speed, cost or reliability gains. This public snapshot publishes the design; additional implementation work remains in progress and is not bundled into this documentation update.

## Read the proposal

- [Research proposal](docs/research-proposal.md): motivation, intended behavior, efficiency hypothesis and scope.
- [Detailed architecture](docs/architecture-v1.md): fast/slow paths, action execution, recurrent memory, prediction and synchronization.
- [Implementation and evaluation plan](docs/implementation-plan.md): curriculum, controls, measurement and remaining milestones.
- [Research map](docs/research.md): primary sources and limits of transfer to this proposal.

## Core idea

A lightweight recurrent path observes the interface, maintains live task state, predicts short action consequences and selects actions. A deeper path reasons throughout the active task and supplies learned compact guidance that can support several interactions. Actual observations correct predictions; outdated assumptions invalidate affected guidance.

Persistent state carries useful understanding between interactions, with explicit exact values and evidence alongside learned memory. Bounded recent context and retrieval avoid replaying the whole history at every update. Task memory survives pause/resume and resets for unrelated tasks; the same model can perform different tasks.

Lower computation is an explicit goal. Reusing deeper decisions across inexpensive actions and reducing repeated history processing are intended savings mechanisms. Concurrent execution separately reduces waiting. Both paths and all overhead must be counted when testing whether the full system is cheaper.

## Earlier visual briefs

[architecture-decisions.html](architecture-decisions.html) and [index.html](index.html) are historical visual explorations. They contain alternatives superseded by the proposal linked above. [PRODUCT.md](PRODUCT.md) and [DESIGN.md](DESIGN.md) describe those earlier surfaces. No build step is needed to read the documents or open the HTML.
