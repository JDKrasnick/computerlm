# ComputerLM

Research proposal for a stateful, predictive computer-use model with asynchronous fast and slow computation paths.

**V1 goal:** complete easy and medium computer tasks faster while maintaining task success. Optimize end-to-end completion time at a matched success rate; background reasoning and total FLOPs are secondary to action latency.

**Status:** architecture and research handoff, agreed through 21 October 2026. No model implementation, trained weights, or validated performance claims yet.

## Start here

- [V1 architecture](docs/architecture-v1.md): components, state ownership, action loop, recurrence, and synchronization.
- [Implementation and evaluation plan](docs/implementation-plan.md): build sequence, training stages, and success criteria.
- [Research map](docs/research.md): primary sources, relevant mechanisms, and limits of the evidence.

## Core idea

A small recurrent path observes the UI, maintains live state, predicts short action consequences, and selects structured actions. A large VLM reasons asynchronously using persistent working memory, supplying compact guidance without blocking every interaction. Actual observations correct predictions; incompatible guidance is discarded or revised.

The paths are intended to be trained as an integrated model with learned interfaces and potentially shared parameters. The exact backbone and degree of parameter sharing remain open. The slow backbone can retain pretrained transformer layers while adding recurrence across interaction cycles.

## Earlier visual briefs

Open [architecture-decisions.html](architecture-decisions.html) or [index.html](index.html) in a browser for the original visual explorations. These predate the agreed stateful fast/slow v1 and contain alternatives that are not current decisions. **The architecture document above takes precedence.** [PRODUCT.md](PRODUCT.md), [DESIGN.md](DESIGN.md), and `.impeccable/design.json` describe those visual artifacts.

No build step is required to read the documentation or open the HTML briefs.
