# zing

`zing` is a playful CLI that celebrates background work finishing. The first implementation focuses on macOS notification-center alerts while stubbing future visual effects.

## Usage

Each effect is its own subcommand. Chain as many as you like, separating them with literal `--`.

```bash
# Single notification-center alert
zing notification-center "Tests are green" \
  --title "Zing!" \
  --subtitle "pack-build" \
  --sound Pop \
  --bundle-identifier com.andyscott.zing

# Fan-out to confetti and haptics after the alert
zing notification-center "Workload finished" \
  --title "Render" \
  --silent \
  -- confetti --style extra \
  -- haptic --violent
```

Use `notification-center --silent` for visual-only alerts. `confetti`, `flash-window`, and `haptic` can also be run on their own while those implementations are still baking (pass `--dry-run` to preview intent).

> macOS quirk: when running from `nix run` (or any context without an `.app` bundle), Notification Center cannot attribute alerts to `com.andyscott.zing`. In that case Zing transparently falls back to `osascript display notification`, so you should still see the banner as long as macOS allows Terminal-style notifications.

## Roadmap

- `flash-window`: follow the process tree to locate the originating terminal window and briefly pulse its bounds.
- `confetti`: fullscreen overlay inspired by Raycast celebrations.
- Cross-platform backends: keep the Rust CLI front-end while swapping out platform implementations per effect.
