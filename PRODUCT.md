# ComputerLM research brief

> Historical specification for the HTML explainers. The current model proposal is [V1 architecture](docs/architecture-v1.md), which supersedes earlier choices about inference cost and prediction heads below.

<!-- impeccable:product-schema 1 -->

## Platform
web

## Stack
Standalone HTML, as requested by the user. Inline CSS and JavaScript keep the artifact portable.

## Users
The project owner wants to understand vision-language models and assess a proposed computer-use architecture.

## Product Purpose
A concise, high-level explanation of VLMs, computer-use models, the proposed architecture, existing research, expected benefits, and evaluation.

The newer architecture-decisions.html is an open-ended research brief for selecting a highly customized model. It supersedes the earlier proposal's narrow focus for this surface: compare problems, existing designs, adaptive deliberation, masking, prediction, memory and action outputs without prescribing a network structure.

## Capabilities and Constraints
- Explain VLM terminology for a reader new to the subject; distinguish the vLLM inference library.
- Prioritize benchmark success at ideally lower inference cost.
- Treat action-conditioned prediction as an architectural learning bias, with auxiliary training heads removable at inference.
- Do not present hypothetical performance as measured results or claim established novelty.
- Explain the specific network changes separately from agent and serving infrastructure.
- Use two side-by-side diagrams: baseline versus proposed network; standard agent versus external world model versus lean proposal.
- Keep training discussion conceptual. Do not include loss equations or detailed training recipes.
- Include primary research links and distinguish close prior art from the proposed contribution.

## Evidence on Hand
Primary literature checked: LLaVA, Qwen2.5-VL, UI-TARS, ShowUI, UFO2, CUWM, Latent2World, Medusa, OSWorld, and vLLM documentation. No trained model or experimental results exist in this workspace.

## Open Decisions
Base model, model size, dataset, training budget, and eventual deployment target remain undecided. The visual design is an implementation choice for this standalone explainer.
