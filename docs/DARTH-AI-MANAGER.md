# Darth AI Model Manager

Darth AI is a lightweight desktop front end for downloading GGUF model files from Hugging Face and running them locally with llama.cpp.

## Included components

- `python-huggingface-hub` provides the `hf` download command.
- `llama-cpp` provides `llama-server`, which runs the model and serves its built-in chat UI.
- Models are saved under `~/AI/models/`.
- Server logs are saved under `~/.local/state/darth-ai/llama-server.log`.

## Use

1. Open **Darth Linux → Control Center → AI Model Manager**, or run `darth-ai-manager`.
2. Find a GGUF model on Hugging Face. Read its model card, license, and hardware requirements.
3. Enter the repository ID (owner/repository) and the exact `.gguf` filename.
4. Select **Download model**. Large model files can take a long time and use substantial disk space.
5. Refresh the local model list, select the downloaded model, and choose **Run selected model**.
6. Wait for llama.cpp to load the model, then choose **Open local chat**. The local web UI is at `http://127.0.0.1:8080`.
7. Choose **Stop local AI** when finished.

Public repositories generally do not require a Hugging Face account. Private or gated repositories require access permission and Hugging Face authentication configured separately (for example, using `hf auth login` in your user account).

## Hardware guidance

The default configuration is CPU-friendly: localhost-only server binding, 2,048 context tokens, and all but one detected CPU thread. This is a conservative starting point, not a performance guarantee.

For a low-memory CPU-only computer, start with a small instruct model (around 1B–3B parameters) in a Q4 GGUF quantization. A 7B Q4 model often needs roughly 5 GB or more for weights alone, plus memory for context and the operating system. Model sizes vary; check the file size and model card before downloading. Keep enough free disk space for the download.

## Security and privacy

- The inference server binds to `127.0.0.1`, not the LAN or public internet.
- Do not change the host binding to `0.0.0.0` or expose the port through a router/firewall.
- Do not enable llama.cpp's built-in filesystem/shell tools in this manager. Treat downloaded model files and model-card instructions as untrusted.
- Inference runs locally after download. Downloading requires network access to Hugging Face.
- Model licenses and acceptable-use terms vary by repository. Review them before use.
- The app does not upload prompts to a remote inference provider. Browser extensions or other software on the computer may still observe browser activity.

## Troubleshooting

- If the app says `hf` or `llama-server` is missing, install `python-huggingface-hub` and `llama-cpp` with pacman, then reopen the app.
- If a download fails, check the exact filename, repository permissions, disk space, and network connection.
- If a model fails to load, check the server log at `~/.local/state/darth-ai/llama-server.log`. Try a smaller GGUF or lower context size.
- The default port is 8080. Stop another service using that port before starting Darth AI.
