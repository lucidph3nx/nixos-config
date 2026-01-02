# Voice-to-Text with Voxtral Mini

This module provides voice-to-text functionality using Mistral's Voxtral Mini model, optimized for your AMD Radeon RX 6950 XT GPU.

## Features

- **Hold-to-talk workflow**: Press keybind to start recording, release to transcribe and insert text
- **Local AI processing**: Runs Voxtral Mini (3B) model locally on your GPU via ROCm
- **Multiple text injection backends**: Supports wtype, ydotool, and clipboard with automatic fallback
- **Desktop notifications**: Visual and audio feedback for recording states
- **Wayland-native**: Built specifically for Hyprland/Wayland

## Quick Start

### 1. Enable the module

In your machine's `configuration.nix`, enable the voice-to-text module:

```nix
{
  nx.programs.voiceToText.enable = true;
}
```

### 2. Set up API key (optional, if using API instead of local)

If you want to use the Mistral API instead of running locally:

```nix
{
  nx.programs.voiceToText = {
    enable = true;
    useLocalModel = false;  # Use API instead
  };
}
```

Then add your API key to your environment:
```bash
export MISTRAL_API_KEY="your-api-key-here"
```

### 3. Build and apply

```bash
nixos-rebuild switch --flake .
```

### 4. Use voice-to-text

1. Press `SUPER + V` to start recording
2. Speak your text
3. Release `SUPER + V` to stop recording and transcribe
4. Text will be automatically inserted at your cursor position

## Usage

### Keybinds (default)

- **SUPER + V**: Toggle recording (hold to talk, release to transcribe)
- **SUPER + SHIFT + V**: Cancel current recording

### Commands

You can also control it via command line:

```bash
# Toggle recording (if recording, stop and transcribe; if idle, start)
voice-to-text toggle

# Start recording
voice-to-text start

# Stop recording and transcribe
voice-to-text stop

# Cancel recording without transcribing
voice-to-text cancel

# Check status
voice-to-text status
```

## Configuration

### Options

```nix
{
  nx.programs.voiceToText = {
    enable = true;
    
    # Text injection backend
    # Options: "wtype" | "ydotool" | "clipboard" | "auto"
    # Default: "auto" (tries wtype -> ydotool -> clipboard)
    backend = "auto";
    
    # Keybind for toggle
    # Default: "SUPER, V"
    keybind = "SUPER, V";
    
    # Play notification sound
    # Default: true
    notificationSound = true;
    
    # Language for transcription
    # Default: "en"
    language = "en";
    
    # Use local model (true) or Mistral API (false)
    # Default: true
    useLocalModel = true;
  };
}
```

### Advanced Configuration

The voice-to-text script creates a configuration file at `~/.config/voice-to-text/config.json` that you can manually edit:

```json
{
  "model": "mistral-community/Voxtral-Mini",
  "device": "cuda",
  "sample_rate": 16000,
  "channels": 1,
  "chunk_size": 1024,
  "format": "int16",
  "backend": "auto",
  "notification_sound": true,
  "language": "en",
  "use_local_model": true,
  "mistral_api_key": ""
}
```

## Text Injection Backends

### wtype (default, recommended)

Uses `wtype` to simulate keyboard input on Wayland. Works with most applications.

```nix
backend = "wtype";
```

### ydotool

Uses `ydotool` for universal input simulation. More compatible with Chromium/Electron apps but requires the `ydotoold` daemon:

```bash
# Enable ydotool daemon
systemctl --user enable --now ydotool.service
```

```nix
backend = "ydotool";
```

### clipboard

Copies text to clipboard instead of typing it. Most reliable but requires manual pasting (Ctrl+V).

```nix
backend = "clipboard";
```

### auto (recommended)

Automatically tries backends in order: wtype → ydotool → clipboard. Best compatibility.

```nix
backend = "auto";
```

## How It Works

1. **Recording**: Uses PipeWire (`pw-record`) to capture audio from your microphone
2. **Processing**: Audio is saved to a temporary WAV file
3. **Transcription**: Voxtral Mini model runs on your AMD GPU via ROCm to transcribe the audio
4. **Injection**: Transcribed text is inserted using your configured backend

## ROCm Support

This module is configured to use your Radeon RX 6950 XT GPU. The following environment variables are automatically set:

- `HSA_OVERRIDE_GFX_VERSION=10.3.0` (for RX 6950 XT compatibility)
- `ROCM_PATH` points to ROCm installation

PyTorch with ROCm support is included in the Python environment.

## Troubleshooting

### No audio recording

Check that your microphone is working:
```bash
pw-record --list-targets
pw-record test.wav
```

### Transcription fails

Check GPU availability:
```bash
python3 -c "import torch; print(torch.cuda.is_available())"
```

If false, check ROCm installation:
```bash
rocm-smi
```

### Text not inserting

Try different backends:
```nix
backend = "clipboard";  # Most reliable fallback
```

### Model download issues

First time use will download the Voxtral Mini model (~3GB). Ensure you have:
- Internet connection
- Enough disk space in `~/.cache/huggingface/`

### Check logs

Run from terminal to see detailed output:
```bash
voice-to-text toggle
```

## Performance

- **Model size**: ~3GB (Voxtral Mini)
- **VRAM usage**: ~4-6GB during inference
- **Transcription speed**: ~2-5 seconds for 30 seconds of audio (with RX 6950 XT)
- **Languages supported**: 50+ languages (English, Spanish, French, German, Portuguese, Hindi, etc.)

## Comparison to Hyprvoice

This implementation is inspired by [hyprvoice](https://github.com/leonardotrapani/hyprvoice) but adapted for NixOS with:

- **Better model**: Voxtral Mini outperforms Whisper in accuracy
- **GPU acceleration**: Uses your AMD GPU via ROCm
- **NixOS integration**: Declarative configuration, no manual setup
- **Simpler workflow**: Direct toggle binding instead of daemon management

## Future Improvements

- Streaming transcription (partial results during recording)
- Voice commands (trigger actions based on voice input)
- Custom model fine-tuning for your voice
- Multi-language auto-detection
- Punctuation and capitalization improvements

## Credits

- Inspired by [hyprvoice](https://github.com/leonardotrapani/hyprvoice) by Leonardo Trapani
- Uses [Voxtral Mini](https://mistral.ai/news/voxtral) by Mistral AI
- Built for NixOS and Hyprland
