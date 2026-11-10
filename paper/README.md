# ComputerLM proposal

Editable source: `proposal.tex`. Generated PDF: [`../output/pdf/proposal.pdf`](../output/pdf/proposal.pdf).

Build from the repository root with `sh paper/build.sh`. Requires Tectonic; its first run may download LaTeX dependencies. The source includes its bibliography, so no separate BibTeX invocation is needed.

The [interface literature review](interface-literature-review.md) covers action outputs, feedback, observation intake, recurrent memory, guidance fusion and validity, waiting, prediction, training, and termination. It separates research evidence from recommendations; the design register records which directions have since been selected.

The [perception, training, and local-runtime review](perception-training-runtime-review.md) adds current screen-encoder designs, visual-reuse literature, iSHIFT and GUI-JEPA comparisons, staged training recommendations, and GPU scheduling/partitioning options. Training recipes and runtime performance remain unvalidated.

Draft 0.8 condenses the proposal to a maximum of three pages, including references. It retains native VLM perception with exact repeated-input caching, persistent task state, learned subgoal guidance, action feedback, fast-only actuation/prediction, and the action-versus-deferral ablation. The initial target is local inference on one GPU, potentially with a custom runtime. Evaluation seeks matched accuracy, prioritizing speed and then cost. Detailed alternatives remain in [design questions](design-questions.md); its Q1-Q8 identifiers belong to the expanded register rather than the condensed PDF. This remains a proposal for development and discussion, not a completed experimental specification.
