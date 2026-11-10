# ComputerLM interface design: literature and recommendations

Working review, 10 November 2026. This expands the proposal's [design register](design-questions.md). The numbered interfaces below preserve the twelve questions from our discussion; Q1-Q8 remain the broader identifiers in the expanded register. The three-page proposal groups these questions more compactly.

The user has selected a custom recurrent fast controller, learned latent guidance, latent recurrent memory, one GPU initially, and faster and cheaper easy/medium task completion at comparable success. Screen encoding remains open. Everything labelled **recommended starting point** below is a proposal, not a newly confirmed design decision or an experimental result.

Latest discussion: both paths observe the screen, and only the fast path acts on it. Structured action outputs are the initial direction. Guidance fusion remains an ablation. A fast-to-slow learned feedback edge is optional; the earlier suggestion to require latent feedback and execution records together has been withdrawn pending evidence.

The [subsequent perception, training, and runtime review](perception-training-runtime-review.md) supersedes open ownership/timing questions here: observation delivery should be immediate, task state persists, prediction is fast-only, and immediate action versus learned deferral is a central ablation. It also adds closer GUI literature and a local-deployment discussion.

## What the literature establishes

There are useful precedents for the individual pieces. GUI work supplies action representations and observable state transitions. Robotics supplies asynchronous fast/slow policies with latent handoffs. Language modelling supplies learned recurrent memory. World-model work supplies action-conditioned prediction. These precedents do not establish that their combination will improve GUI task speed or total cost. That requires controlled comparisons in ComputerLM.

Sources include archival conference papers and arXiv research reports. In particular, the closest asynchronous latent-handoff precedent is a robotics report, not a GUI validation of this proposal.

## 1. What should the fast path output? (Q2)

**Existing practice.** Many LLM/VLM GUI agents generate serialized commands with arguments. Internally, an autoregressive model predicts vocabulary-token logits; the executor ultimately receives a command such as `click(x, y)` or `type(text)`. These are different levels of description. [UI-TARS](https://arxiv.org/abs/2501.12326) defines click, drag, scroll, type, hotkey, wait, finished, and user-intervention actions. Its action vocabulary alone does not determine how a custom controller should implement its output heads.

**Recommended starting point.** One structured action per controller decision, with a small action-type head and conditional argument heads. Choose coordinates or an available UI target, key combinations, and a text payload according to the action type. Compare a coordinate head with a pointer over permitted UI elements. Accessibility targets cannot replace visual grounding where no suitable element exists.

Text needs an explicit design: copying an exact task value is different from composing a paragraph. Give the controller access to original exact strings. A copy/generate text head or a prepared text payload from the slow path are candidates; benchmark free-form typing separately. A finite action classifier cannot produce arbitrary text by itself.

**Experiment.** Compare structured heads with a short constrained action decoder at matched controller capacity. Then compare single actions with bounded, interruptible action chunks. [CUA-Speedrun](https://arxiv.org/html/2609.40284v1) finds batching can reduce task time, but the benefit depends on sequence quality. Start with individual decisions to isolate controller latency; do not make that a permanent restriction.

## 2. What should travel from fast to slow? (Q3-Q4)

**Evidence.** In [DuoCore-FS](https://arxiv.org/html/2512.20188v1), the slow VLM receives visual observations and task inputs, while the fast policy combines buffered latent guidance with current perception. This supports giving each path access to relevant evidence rather than forcing the slow path to rely entirely on a controller's summary. It does not settle ComputerLM's feedback protocol.

**Revised recommendation: investigate rather than require both.** Execution records describe what the executor actually attempted, dispatched, or completed. Learned fast-state latents might summarize the controller's current interpretation, uncertainty, or intended continuation. These are different information sources, but they need not be separate physical channels: records can themselves be embedded into model inputs. Neither representation is inherently guaranteed to be sufficient.

[DreamerV3's recurrent state update](https://arxiv.org/html/2301.04104v2) explicitly uses previous actions alongside sensory representations. This is a precedent for action-aware state estimation, not evidence that slow reasoning must additionally receive another controller's hidden state. DuoCore-FS describes direct observations and a slow-to-fast latent buffer; it does not establish a requirement for the proposed reverse learned-feedback edge. The reviewed evidence therefore does not justify making both forms mandatory.

Keep the corresponding screenshot and permitted UI text accessible to slow reasoning. Treat a receipt as evidence that an operation was dispatched or executed, not proof that the user's intended effect occurred.

Example: after Save, the record says the click completed; a later screen establishes whether the document was actually saved. Preserve that distinction in both paths' state.

**Experiment.** Keep screen/UI observations in every condition. Compare observations alone, plus execution records, plus learned fast-state feedback, and plus both. Match training effort and report differences in available information and inference cost. A separate comparison can hold record content fixed while changing its encoding, to distinguish information benefits from representation benefits. Measure omitted evidence, delayed/missing actions, duplicate actions, and time/cost at comparable success. Shared visual features remain conditional on the open encoder decision.

## 3. Which path takes in new evidence? (Q3-Q4)

**Recommended starting point: both, for different purposes.** The fast path updates its live UI belief when a new observation arrives. The slow path incorporates the relevant event into its persistent reasoning state at a supported recurrent-step boundary. A changed screen can require immediate fast-path correction without requiring a complete new strategy.

**Confirmed actuation boundary.** Observation access is not action authority. The runtime loop is screen/UI to both paths, slow guidance to fast, and fast actions to the executor/environment. Slow output never directly executes a click, keypress, or other UI action. Optional action feedback does not change this boundary.

Use a versioned event queue. At each slow boundary, distinguish the last consumed event from newly available events. Preserve ordered action receipts and consequential changes; coalesce redundant frames when appropriate. Bound the queue, record what was dropped, and measure how long important evidence waits. Publishing guidance is separate from consuming evidence.

This is an engineering recommendation, not a capability that an unmodified autoregressive LLM automatically has. An ongoing decode does not automatically ingest a later screenshot. The proposed recurrent slow path needs an explicit input/update boundary and training that covers new observations arriving during reasoning. DuoCore-FS supports the broader asynchronous arrangement, not this exact continuous recurrent update rule.

**Experiment.** Vary event intake frequency and update granularity. Measure fast reaction time, slow evidence delay, progress between updates, and recovery when an action changes the situation mid-cycle. Avoid restarting all slow computation on every frame, which could prevent useful progress.

## 4. What should recurrent memory contain? (Q4)

**Confirmed direction: learned latent representation.** Representation and update architecture are separate choices. Selecting latent memory does not select a GRU, a particular linear recurrence, memory tokens, state width, or training horizon.

Existing recurrent LLM machinery can supply this representation; a separate memory network is not a requirement. The important distinction is persistence: recurrent state must carry useful information into later observation updates. Repeating a shared block several times and resetting its state for each new screen supplies internal depth, not persistent task memory. A conventional Transformer KV cache instead retains prior token features; it is not the same as a bounded recurrent state updated across observations.

**Evidence.** [Recurrent Memory Transformer](https://arxiv.org/abs/2207.06881) learns memory passed between sequence segments. [RecurrentGemma](https://arxiv.org/abs/2404.07839) combines linear recurrence with local attention and uses fixed-size state to reduce long-sequence memory requirements. These establish workable recurrent representations; they do not guarantee correct task-state maintenance.

**Recommended starting point.** Separate fast UI memory from slow task/reasoning memory. Retain exact constraints, text values, execution records, and source references outside the compressed vectors. Keep the original instruction available. Latents can summarize relevance and progress; they should not be the only way to recover an exact filename or verify an earlier claim.

**Experiment.** Compare simple gated recurrence with the intended recurrent block, using matched budgets. Test delayed constraints, interrupted tasks, stale beliefs, exact copying, and reset between unrelated tasks. Compare against bounded history and an explicit-state baseline. [Task-State Representation](https://arxiv.org/html/2607.00502v1) warns that state-updater mistakes can propagate and that an extra LLM call per step adds latency and cost. Maintained state must earn its overhead.

## 5. How should latent guidance enter the controller? (Q3)

**Evidence.** [Flamingo](https://arxiv.org/abs/2204.14198) uses gated cross-attention to condition a language model on compact visual representations. This is a conditioning precedent, not a GUI slow-to-fast result. DuoCore-FS is closer: its latent buffer includes learned fusion queries trained through an action-generation objective.

**Recommended starting point.** Let the controller attend to a small set of slow-guidance vectors while also receiving fresh observation features and the task anchor. Compare this against concatenation followed by a gated MLP, a cheaper and simpler alternative. Start with small bounded vector counts and increase capacity only when useful.

**Discussion status:** the user leaves fusion as an ablation. Neither attention nor concatenation/gating is selected as the final architecture.

The important question is whether action training makes the vectors useful. An arbitrary hidden state from a pretrained model is not automatically understandable to a new controller. Train the bridge and controller together, then decide how much of the slow model must adapt. No named semantic meaning needs to be assigned to individual latent dimensions.

**Experiment.** Remove, shuffle, delay, and swap guidance while preserving other inputs. Measure downstream completion and latency, not just whether a probe can decode a plan. Include missing-guidance training so the controller has a defined initial and recovery behaviour.

## 6. When should slow reasoning publish guidance? (Q3, Q6)

**Recommended starting point.** Publish an atomic, versioned packet after a completed slow update. Keep the last compatible packet available during the next update. Continue slow reasoning while the task remains active, as intended by the proposal; publication frequency and computation frequency are separate controls.

DuoCore-FS provides a periodically refreshed latent-buffer precedent. It does not establish an optimal GUI publication schedule or prove that indefinitely running the slow path is the cheapest policy.

**Experiment.** Compare regular publication, meaningful-change publication, and controller-requested publication while recording the slow computation actually performed. Study no-publication reasoning separately from reduced-compute reasoning. Measure how often packets help, overwrite useful guidance, or arrive after the relevant action.

## 7. When is guidance no longer valid? (Q3)

**Recommended starting point.** Separate provenance from validity. Packet age, source frame, and task version identify where guidance came from. They do not prove its semantic assumptions still hold. A later observation can support old guidance, while a fresh packet can already be wrong.

Use explicit checks for changed task constraints and observable action preconditions. Add learned compatibility/effect checks where validity depends on meaning. Invalidate the whole packet when contradictory evidence makes its assumptions unreliable, then use a defined conservative fallback while slow reasoning updates it. Ordinary expected navigation should not invalidate useful task-level guidance solely because the screenshot identifier changed.

**Experiment.** Introduce unexpected dialogs, target movement, navigation failure, task corrections, and loading delays. Measure stale-guidance actions, false invalidations, recovery time, and success. None of the reviewed papers supplies a ready-made validity oracle for arbitrary ComputerLM latents. This is a central experimental question.

## 8. Who decides to wait and resume? (Q2-Q3)

**Recommended starting point.** The fast controller handles short operational waits using live observations and pending-action records. The slow path can advise waiting or a change of strategy. The executor reports completion/error events but does not independently interpret task success. Waiting for the UI and pausing the task are different states.

Do not equate a tool response with a settled screen. CUA-Speedrun reports that faster infrastructure can expose partially updated interfaces and lead to redundant actions. UI-TARS includes an explicit wait action. These support treating waiting as part of control rather than only adding a universal sleep.

**Experiment.** Compare fixed waits, observable-change waits, and learned wait/resume decisions under variable UI delay. Test whether the fast controller repeats a pending click, waits forever, or resumes on irrelevant animation. Measure total task time and errors together.

## 9. What should prediction represent? (Q5)

**Evidence.** [DreamerV3](https://arxiv.org/abs/2301.04104) learns environment models and uses imagined futures to improve behaviour. [Computer-Using World Model](https://arxiv.org/abs/2602.17365) predicts action-conditioned UI changes, first textually and then as screenshots, for test-time action search. Their prediction targets and costs differ.

**Recommended starting point.** Predict one-step, action-conditioned latent changes relevant to the next decision, with simple auxiliary targets such as target visibility, navigation, or completion cues. Avoid requiring screenshot synthesis initially. Train against actual next observations and keep predicted and observed state distinct.

**Experiment.** Compare target representations, horizons, and prediction compute. Guard against a representation that is easy to predict because it discards important details. Prediction accuracy is insufficient evidence unless it improves real actions or saves work.

## 10. What may prediction do before confirmation? (Q5)

**Recommended starting point.** Prediction may prepare likely next targets, reusable computation, or a bounded set of candidates. Dependent actions should use actual observation to confirm their preconditions. A predicted dialog must not become a recorded observed dialog.

CUWM supports studying candidate-action simulation. It does not establish that such search is cheaper than direct action, and its screenshot-based method is not the proposed latent predictor.

**Experiment.** Compare the same asynchronous architecture with prediction disabled, prediction used only for preparation, and bounded candidate selection. Count wasted preparation, extra prediction work, verification overhead, and recovery. The key test is whether useful preparation exceeds its cost on easy/medium tasks.

## 11. How do the parts learn to cooperate? (Q7)

**Recommended starting point.** Establish action imitation first. Train the guidance bridge and fast controller together with actual action targets; gradually adapt the slow model if needed while monitoring retained capability. Train recurrent state on chronological sequences, not shuffled isolated screenshots. Introduce realistic guidance delays, missing guidance, and UI changes during training.

DuoCore-FS uses end-to-end co-training, providing a relevant precedent for a learned handoff. [DAgger](https://arxiv.org/abs/1011.0686) addresses the distribution shift caused by an imitation learner's own actions. Its lesson here is to collect training corrections on states the controller actually visits, rather than training only on flawless demonstrations.

**Experiment.** Compare freeze/adapt scopes and staged versus joint training. Include recovery data and guidance-use controls. An action label does not uniquely specify the best latent message. The latent interface must be learned through useful downstream behaviour. Keep held-out tasks and evaluator corrections out of training. RL remains an optional refinement, not an assumed efficiency result.

## 12. Who declares completion or asks for help? (Q2, Q8)

**Recommended starting point.** Give the fast controller explicit candidate-done and needs-input actions. It can stop dispatching UI actions immediately. Require evidence-based slow confirmation for final task completion in the initial prototype, and measure that confirmation's cost. A missing login or ambiguous instruction should produce a distinct input request rather than a success claim. UI-TARS provides finished and user-intervention action precedents.

Keep runtime verification within the model's permitted observations. Independent benchmark success checks remain offline; privileged answer checks must not be fed to the actor.

**Experiment.** Compare fast-only termination with slow confirmation. Measure premature completion, unnecessary additional actions, escalation accuracy, and confirmation latency. Completion logic can dominate a short task's runtime, so it belongs in the cost accounting.

## Cross-cutting decisions to investigate

| Decision | Recommended next investigation | Why it matters |
|---|---|---|
| Screen encoding (Q1) | Profile dedicated lightweight, shared early features, and hybrid designs with equivalent observation access. | The controller cannot be faster than the features it waits for. Sharing saves work only if scheduling permits timely access. |
| One GPU scheduling (Q6) | Prioritize fast deadlines at supported slow boundaries; measure each path alone and combined. | Software concurrency does not guarantee useful GPU overlap. Slow progress and fast tail latency can both degrade through contention. |
| Controller independence (Q2-Q3) | Train with absent/stale guidance and compare unguided, guided, and delayed-guidance conditions. | A controller that stalls until every slow update loses the intended latency benefit. |
| Exact text (Q2, Q4) | Separate copying, short text generation, and long composition in design and reporting. | A tiny motor controller's grounding ability does not imply full language-generation ability. |
| Efficiency claim (Q8) | Report success, wall time, full GPU allocation cost, and compute for all attempts, with training cost separately. | A faster task on the same billed GPU can cost less while still consuming more computation. Both claims need measurement. |

For inference compute, the intended saving is the large-model work avoided on routine actions, minus the cost of continuous slow reasoning, fast control, perception, prediction, and verification. Asynchrony alone does not make this balance positive. The continuous slow design should therefore be compared with a synchronous baseline and an intermittent-slow baseline under the same task and hardware contract. The latter is an experimental control, not a replacement for the proposed architecture.

## Recommended order

1. Specify one-action outputs, exact-text access, execution records, and event intake. These make the system's behaviour observable and debuggable.
2. Build recurrent fast control with a learned latent handoff and explicit compatibility checks. Establish useful cooperation before adding speculative work.
3. Profile encoder choices and one-GPU scheduling using the intended slow workload. Choose capacities from measured latency, memory, and success.
4. Add action-conditioned prediction and adaptive publication as controlled increments. Compare against the identical model with each increment disabled.

The remaining uncertainty is not a list of questions the user must answer from intuition. It is an experiment plan: choose simple interfaces first, then spend complexity only where measured failures justify it.
