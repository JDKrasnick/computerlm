# Research map

Primary sources discussed during architecture exploration. Mechanisms below inform the proposal; they do not establish performance or novelty for ComputerLM. This is a curated starting point, not an exhaustive related-work review.

| Work | Relevant mechanism | Transfer limit / proposed use |
| --- | --- | --- |
| [Fast-in-Slow](https://fast-in-slow.github.io/) — [paper](https://arxiv.org/abs/2506.01953) | Embeds fast execution within a VLM by partially sharing parameters; slow latent features condition fast action generation. | Robotics. Different update frequencies in its setup should not be conflated with proof of concurrent inference. Consider block reuse, but profile width and input adaptation. |
| [DuoCore-FS](https://arxiv.org/html/2512.20188v1) | Asynchronous fast/slow robotics policy connected by a latent bridge buffer; learned fusion queries and joint training with observation delays. | Strong precedent for compact guidance and asynchronous training. Robot action chunks differ from discrete GUI operations. Preserve original task information alongside compressed guidance. |
| [StreamVLN](https://streamvln.github.io/) | Interleaved vision, language, and actions; recent sliding-window context plus slower memory updates. | Navigation. Its slow/fast context management is not identical to two execution paths. Informs recent versus historical memory. |
| [StreamingVLM](https://hanlab.mit.edu/projects/streamingvlm) — [paper](https://arxiv.org/abs/2510.09608) | Bounded streaming KV cache and training aligned with streaming visual inputs. | Video understanding does not establish action correctness or editable task-state memory. Informs always-on observation handling. |
| [Recurrent Memory Transformer](https://arxiv.org/abs/2207.06881) | Learned memory tokens pass state between transformer segments. | Supports recurrence across time without replacing all pretrained layers. Does not supply UI dynamics or prediction by itself. |
| [Perceiver IO](https://arxiv.org/abs/2107.14795) | Compact latent processing with input/output querying. | Inspiration for compact interfaces, not a ready-made computer-use policy. |
| [Computer-Using World Model](https://arxiv.org/html/2602.17365v1) | Predicts action-conditioned textual UI changes and renders next screenshots for candidate-action search in Office applications. | Direct UI-transition precedent. Our latent-only predictor and lower-latency inference remain untested; screenshot simulation adds work. |
| [DreamActVLA project report](https://dream-act-vla.github.io/) | Predicts future observations conditioned on committed actions to compensate for asynchronous inference delay. | Simulation robotics evidence; useful for aligning predictions with when a decision takes effect. Do not assume GUI transfer. |
| [DreamerV3](https://arxiv.org/abs/2301.04104) | Learns environment dynamics and improves behavior using imagined trajectories. | World-model learning precedent. Its behavior learning is not the same as our proposed online candidate scoring. |
| [UI-TARS](https://arxiv.org/abs/2501.12326) — [repository](https://github.com/bytedance/UI-TARS) | Native screenshot-based GUI action modeling and iterative collection/refinement of interaction traces. | Informs data collection, grounding, and baseline selection. Does not establish our asynchronous stateful design. |
| [OSWorld](https://github.com/xlang-ai/OSWorld) | Real desktop environments, agent interfaces, and task evaluation. | Useful evaluation infrastructure; define difficulty and held-out splits explicitly and preserve consistent tool access. |

## Backbone references

- [Qwen3-VL](https://github.com/QwenLM/Qwen3-VL): dense and MoE variants, multilevel visual feature integration. A conventional dense checkpoint was considered for easier architectural experiments.
- [Qwen3.5 architecture documentation](https://github.com/huggingface/transformers/blob/main/docs/source/en/model_doc/qwen3_5.md): hybrid Gated DeltaNet and full-attention layers. Existing token-level recurrence is not automatically an action-conditioned UI belief model.
- [UI-TARS-1.5-7B](https://huggingface.co/ByteDance-Seed/UI-TARS-1.5-7B): GUI-specialized Qwen2.5-VL checkpoint considered as a baseline or initialization.

Checkpoint examples are not a final selection or a claim of current leaderboard leadership. Verify licenses, available weights, training support, and hardware kernels for the exact revision selected.

## Research claim to investigate

Fast/slow execution, recurrent memory, streaming perception, and action-conditioned world models each have prior work. The hypothesis here is that a jointly trained combination with live belief updates, short predictive preparation, and progress-dependent synchronization improves computer-use completion time at matched success.

Test whether prediction improves over an equally asynchronous fast/slow baseline. Test whether memory preserves constraints and supports recovery. Do not infer causal understanding from plausible predictions alone; evaluate changed layouts, hidden prerequisites, alternative actions, and unfamiliar workflows.
