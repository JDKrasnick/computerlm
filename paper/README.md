# ComputerLM proposal

Editable source: `proposal.tex`. Generated PDF: [`../output/pdf/proposal.pdf`](../output/pdf/proposal.pdf).

Build from the repository root with `sh paper/build.sh`. Requires Tectonic; its first run may download LaTeX dependencies. The source includes its bibliography, so no separate BibTeX invocation is needed.

The [interface literature review](interface-literature-review.md) covers action outputs, feedback, observation intake, recurrent memory, guidance fusion and validity, waiting, prediction, training, and termination. It separates research evidence from recommendations; the design register records which directions have since been selected.

The [perception, training, and local-runtime review](perception-training-runtime-review.md) adds current screen-encoder designs, visual-reuse literature, iSHIFT and GUI-JEPA comparisons, staged training recommendations, and GPU scheduling/partitioning options. Training recipes and runtime performance remain unvalidated.

Draft 0.10 uses four pages, including references. It adds an operating-loop explanation: state ownership, both forms of recurrence, prediction before and after actions, guidance validity, a worked upload example, and the distinction between latency and computation savings. The agreed scope remains native VLM perception with exact repeated-input caching, human-style GUI actions, learned subgoal guidance/action feedback, and fast-only actuation/prediction. Evaluation targets the strongest available GUI systems at matched accuracy, prioritizing speed and then cost, with same-backbone controls and disclosed hardware differences. Local deployment prefers Apple-Silicon-class constraints without a fixed model size or serving stack. Steering is a future extension; training budgets remain unspecified. Detailed alternatives remain in [design questions](design-questions.md). Text-composition responsibility and completion/stall reporting remain behaviour choices. This is a tentative proposal, not a completed experimental specification.
