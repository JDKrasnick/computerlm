# Design questions

This is the expanded working decision register for the ComputerLM proposal. Questions remain open until discussed or resolved through development evidence. Options are candidates, not commitments. Q1-Q8 were introduced in the expanded proposal; the three-page Draft 0.8 groups them more compactly and retains this register for detail.

The [interface literature review](interface-literature-review.md) expands the twelve interfaces discussed in conversation, with published precedents, recommended starting points, and specific comparisons. Its recommendations remain candidates until accepted or supported by development evidence.

## Confirmed decisions

- Target easy and medium workflows in a balanced browser and desktop suite.
- Observe screenshots plus available accessibility/UI text under a common baseline contract.
- Match verified task accuracy first, improve complete-task speed as the primary objective, and reduce total inference cost as the secondary objective. Capability is not traded away merely to minimize cost.
- Build a small custom recurrent fast controller trained to use slow-path guidance.
- Both paths observe the screen/UI. Only the fast path issues executable UI actions; the slow path supplies guidance to the fast path and has no direct UI actuation route.
- Use structured fast-path actions with conditional arguments as the initial design direction. Exact output heads and arbitrary-text handling remain open.
- Communicate guidance as learned latent vectors, with explicit exact values and evidence available alongside them.
- Maintain recurrent memory as learned latent representations. The cell, capacity, update rule, and division between paths remain experimental choices; exact records remain available alongside the latent state.
- Target one GPU first, measuring contention and total allocation cost.
- Use native pretrained VLM screen encoding with exact repeated-input feature caching. Fully encode changed screens. Image/token budget and feature sharing remain open; approximate reuse and alternative encoders are optional later comparisons.
- Preserve the proposal's continuous slow reasoning during active tasks and recurrent state across interactions; these are distinct from deeper internal recurrent computation.
- Deliver fresh observations to both paths immediately, without intentional intake delay. Preserve living recurrent state through the task and pause/resume; reset between unrelated tasks. Actual encoding/incorporation latency remains measurable engineering work.
- Use a trained learned latent guidance interface; its encoder/adapter and fusion are experimental choices.
- Place action-conditioned prediction in the fast path. Slow reasoning advises execution and does not own executable control or the predictor.
- Treat immediate highest-scoring executable action selection versus learned deferral for further computation or updated slow guidance as a central autonomy ablation. Keep continuous slow reasoning in both conditions.
- Prefer local inference. Keep the one-GPU initial target while investigating fit and scheduling on the chosen local hardware; local full-model training is not assumed.
- Slow guidance should communicate subgoals and dependencies in latent space, with fast control responsible for grounding them into execution. Guidance encoder capacity and fusion remain ablations.
- Prefer action embeddings from fast to slow, covering actual action type and arguments. These do not encode all possible environment states. Retain exact payloads and execution evidence where needed; structured action inputs are the fallback if embeddings lose essential information.

## Latest discussion: interfaces still to resolve

- Fast-to-slow learned latent feedback is optional, not a required edge. Investigate screen observations alone, observations plus execution records, observations plus fast-state latents, and all three. The existing proposal's exact-value/evidence access does not establish that both feedback channels must be consumed at runtime.
- Keep guidance fusion as an ablation: concatenation/gating versus attention, with capacity and cost recorded.
- Clarify recurrence by state lifetime: existing recurrent LLM machinery may be reused, but shared-block iteration within one inference does not by itself preserve task state between observations. No separate bespoke memory module is selected.
- Immediate observation delivery and fast-only prediction are now selected. Resolve the implementation of continuous intake, compatibility of fast actions with slow guidance, waiting/termination ownership, training scope, screen encoding, and the one-GPU compute schedule through targeted development comparisons. Keep Q1-Q8 as the broader experiment register below.
- The [perception, training, and runtime review](perception-training-runtime-review.md) surveys current published screen encoders, closer GUI comparisons, a staged training proposal, and local GPU options. It is a research recommendation, not evidence that training or runtime fit has been established.
- New intake candidates: fresh evidence at the next recurrent cycle, or a learned adapter at early/middle/late block boundaries. Both preserve task state and may be combined. Compare fixed insertion sites before learned routing.
- Tentative feedback direction: send actual fast-path actions to slow reasoning as they are issued. Discrete/structured versus latent encoding remains open; this does not require the full fast hidden state.

## Q1. How should native screen encoding be budgeted and reused?

**Status: native VLM encoding and exact repeated-input caching selected; budget and feature sharing remain open.**

Candidates: a dedicated lightweight visual encoder; shared early visual features that do not require a full slow pass; a hybrid with cheap routine updates and selective detailed perception. Determine how UI/accessibility text is fused and whether cached features remain valid after interface changes.

Latest user direction: prefer established, generalizable visual reuse. Cache features only for identical encoder inputs under matching weights, preprocessing, and any relevant temporal context; fully re-encode changed screens. Bound caches to the task and preserve fresh observation/action/timing events even on a visual cache hit. Approximate token/patch reuse and earlier JEPA-style alternatives remain optional research comparisons. No assumption of reusing language-model activations across modified recurrent states is introduced.

Evidence: grounded action quality, screenshot-to-action latency, visual encoding compute, peak memory, shared-GPU contention, and behavior under changed layouts. Account for shared encoding work once, without treating it as free. Compare equivalent observations and update readiness.

## Q2. What controller architecture and capacity are sufficient?

Candidates: different recurrent cells/state structures, controller widths, depths, and initialization strategies. The custom-controller decision does not select a particular cell or require training every component from scratch.

Priority ablation: immediate executable argmax versus learned action deferral. Additional fast computation and waiting for newer slow guidance are distinct variants; both retain the continuous slow path. Include arbitrary-text handling and operational wait/termination in the action specification.

Evidence: action quality, constraint retention, guidance use, recovery, inference latency, training stability, and total cost on common tasks. Inspect exact-text access separately from target selection.

## Q3. What is the latent guidance interface?

Open: number and width of vectors, fusion into the controller, update/publication rule, initialization when guidance is unavailable, and training signals that make the vectors useful. Candidate fusion methods include conditioning, gating, or attention. These are experiments, not selected mechanisms.

Guidance semantics are selected at the responsibility level: communicate subgoals and dependencies such as submitting an order or finding X to obtain Y. Those examples do not require a prose channel or named latent slots. The controller learns how to turn guidance into actual actions.

Evidence: downstream action success, reuse across interactions, reaction to new evidence, communication overhead, and removal/shuffling controls. Source-state metadata and invalidation checks remain explicit; latent dimensions need not correspond to named semantic slots. Structured training readouts are not the final runtime channel.

## Q4. How is memory divided and updated?

Open: learned memory capacity, recent context budget, explicit record schema, retrieval interface and budget, write/update mechanism, and gradient windows. Determine what each path retains and how to preserve task state across pause/resume.

Evidence: delayed constraints, exact-value copying, outcome verification, stale facts, recovery after interruptions, memory growth, and retrieval overhead. Compare with external-state and bounded-history baselines using equivalent information. Do not confuse memory across events with additional internal reasoning depth.

## Q5. What should prediction prepare?

Candidates: compact future interface/state features, action-relevant changes, or bounded candidate transitions. Open: candidate count, prediction horizon, supervision, usefulness gating, and correction policy.

Ownership is selected: fast path only. Slow guidance may advise which consequences matter; it does not implement the predictor or act directly.

Group prediction with Q2's action-versus-deliberation decision. Keep prediction-disabled controls to distinguish prediction benefit from learned deferral, rather than treating their usefulness as the same empirical claim.

Evidence: end-to-end time and compute versus the same asynchronous architecture without prediction, changed outcomes, loading screens, and recovery cost. Prediction error alone is not sufficient; the predicted representation must help real actions. Alternative-action outcomes need executed or separately validated evidence.

## Q6. How should one GPU serve both paths?

Open: GPU model and precision, memory fit, scheduling/granularity, resource priority, feature reuse, and supported event boundaries. Compare each path alone with the combined workload to quantify contention.

Custom inference software on standard GPU/CPU hardware is in scope: persistent state management, immediate event delivery, guidance/action exchange, and cooperative or supported partitioned scheduling. Do not assume a stock chat-serving loop implements these requirements.

Evidence: fast-path tail latency, slow-cycle progress, bandwidth and memory pressure, utilization, complete task time, total compute, and full allocation cost. Do not assume asynchronous software execution guarantees overlapping GPU kernels. Separate-GPU deployment is deferred, not part of the initial target.

## Q7. How should the components be trained together?

Open: freeze/adapt scope, controller initialization, memory-write objectives, recurrent-depth schedule, curriculum mixture, guidance supervision, and joint-training timing. Exact losses and budgets are not decided.

Evidence: numerical stability, retained pretrained ability, downstream guidance utility, controller grounding, and controlled nonrecurrent comparisons. Keep chronological prefixes, source lineage, licenses, and task-family splits. Teacher outputs provide observable targets, not hidden activations or private reasoning. RL may be evaluated as refinement; it is not excluded as a source of efficiency improvements.

## Q8. What establishes the intended result?

Open: task roster and balance, difficulty definition, reference protocol, success tolerance, required speed/cost improvements, repeated-run budget, and uncertainty method. Freeze evaluation decisions before held-out testing.

Priority order is fixed: matched verified accuracy, then faster completion, then lower cost. Operational accuracy tolerance and improvement thresholds remain to be declared. A speed result can be reported on its own; a joint cheaper-and-faster claim requires both measurements.

Evidence: verified exact completion, partial credit separately, success over elapsed time, jointly solved-task timing, all-attempt cost, recovery and failures, and full-system compute. Declare tool and observation access. Count training and inference separately, and disclose fixed hardware allocation costs as well as useful computation. Do not infer latent mechanisms from qualitative prose.

## Decision record format

For each resolution, record the question ID, decision/date, alternatives considered, supporting discussion or experiment, tradeoffs, affected components, and conditions that would justify revisiting it. Link measured evidence when available. A user-selected direction is a design decision, not empirical proof.
