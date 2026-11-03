#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.12"
# dependencies = ["parakeet-mlx", "sounddevice", "numpy", "mlx", "pyobjc-framework-AVFoundation"]
# ///
import argparse
import queue
import sys
import threading

import numpy as np
import sounddevice as sd


def authorize_microphone():
    from AVFoundation import AVCaptureDevice, AVMediaTypeAudio

    status = AVCaptureDevice.authorizationStatusForMediaType_(AVMediaTypeAudio)
    if status == 0:  # Not yet determined
        done = threading.Event()
        granted = []

        def on_authorization(allowed):
            granted.append(bool(allowed))
            done.set()

        print("Requesting microphone access from macOS...", file=sys.stderr, flush=True)
        AVCaptureDevice.requestAccessForMediaType_completionHandler_(AVMediaTypeAudio, on_authorization)
        if not done.wait(timeout=60):
            raise RuntimeError("Microphone authorization timed out. Check for a macOS permission prompt.")
        if not granted[0]:
            raise RuntimeError("Microphone access was denied. Enable it for your terminal app in System Settings → Privacy & Security → Microphone.")
    elif status != 3:  # Authorized
        raise RuntimeError("Microphone access is denied or restricted. Check your terminal app in System Settings → Privacy & Security → Microphone.")


def main():
    parser = argparse.ArgumentParser(description="Transcribe audio from a microphone.")
    parser.add_argument("--list-devices", action="store_true", help="list available audio devices")
    parser.add_argument("--device", help="input device ID or name (defaults to the system input)")
    parser.add_argument("--test-mic", action="store_true", help="show microphone levels without loading the model")
    args = parser.parse_args()

    if args.list_devices:
        print(sd.query_devices())
        return

    device = args.device
    if device is not None and device.isdecimal():
        device = int(device)

    try:
        info = sd.query_devices(device, "input")
    except (ValueError, sd.PortAudioError) as error:
        parser.exit(1, f"Cannot open input device: {error}\nUse --list-devices to choose a microphone.\n")

    try:
        authorize_microphone()
    except RuntimeError as error:
        parser.exit(1, f"{error}\n")

    if args.test_mic:
        print(f"Microphone: {info['name']}", flush=True)
        sample_rate = int(info["default_samplerate"])
        print(f"Testing at {sample_rate} Hz. Speak into the microphone; Ctrl+C to stop.", flush=True)
        try:
            with sd.InputStream(device=device, samplerate=sample_rate, channels=1, dtype="float32") as stream:
                while True:
                    chunk, overflowed = stream.read(sample_rate // 2)
                    level = float(np.max(np.abs(chunk)))
                    print(f"\r\033[KMic peak: {level:.6f}" + (" (input overflow)" if overflowed else ""),
                          end="", flush=True)
        except KeyboardInterrupt:
            print()
        except sd.PortAudioError as error:
            parser.exit(1, f"\nMicrophone error: {error}\nCheck the selected device and macOS microphone permissions.\n")
        return

    # Load MLX only for transcription, not for microphone diagnostics.
    import mlx.core as mx
    import parakeet_mlx

    model = parakeet_mlx.from_pretrained("mlx-community/parakeet-tdt-0.6b-v3")
    sample_rate = model.preprocessor_config.sample_rate
    chunk_size = int(sample_rate * 1.5)
    audio_queue = queue.Queue()

    def audio_callback(indata, frames, time, status):
        audio_queue.put((indata.copy(), str(status)))

    try:
        with model.transcribe_stream(context_size=(64, 8)) as transcriber:
            with sd.InputStream(device=device, callback=audio_callback, samplerate=sample_rate,
                                blocksize=chunk_size, channels=1, dtype="float32"):
                print("Ready. Listening... Ctrl+C to stop.", file=sys.stderr, flush=True)
                printed_tokens = 0
                printed_text = False
                try:
                    while True:
                        try:
                            chunk, status = audio_queue.get(timeout=5)
                        except queue.Empty:
                            print("\nNo audio received from the microphone yet.", file=sys.stderr, flush=True)
                            continue
                        if status:
                            print(f"\nAudio input: {status}", file=sys.stderr, flush=True)
                        transcriber.add_audio(mx.array(chunk.flatten()))
                        tokens = transcriber.finalized_tokens
                        text = "".join(token.text for token in tokens[printed_tokens:])
                        if not printed_text:
                            text = text.lstrip()
                        if text:
                            print(text, end="", flush=True)
                            printed_text = True
                        printed_tokens = len(tokens)
                except KeyboardInterrupt:
                    text = "".join(token.text for token in transcriber.draft_tokens)
                    if not printed_text:
                        text = text.lstrip()
                    if text:
                        print(text, end="", flush=True)
                    if printed_text or text:
                        print(flush=True)
    except sd.PortAudioError as error:
        parser.exit(1, f"\nMicrophone error: {error}\nCheck the selected device and macOS microphone permissions.\n")


if __name__ == "__main__":
    main()
