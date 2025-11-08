use anyhow::{Context, Result, bail};
use clap::Parser;
use std::ffi::OsString;

const DEFAULT_BUNDLE_IDENTIFIER: &str = "com.andyscott.zing";
const FLASH_WINDOW_DESCRIPTION: &str =
    "Highlight or pulse the originating window when work completes.";
const CONFETTI_DESCRIPTION: &str = "Overlay celebratory confetti across the screen.";
const HAPTIC_DESCRIPTION: &str = "Trigger a playful trackpad vibration or taptic chime.";

fn main() -> Result<()> {
    let Some(segments) = collect_segments()? else {
        return Ok(());
    };
    for segment in segments {
        segment.execute()?;
    }
    Ok(())
}

#[derive(Debug)]
enum Segment {
    NotificationCenter(NotificationCenterArgs),
    FlashWindow(FlashWindowArgs),
    Confetti(ConfettiArgs),
    Haptic(HapticArgs),
}

impl Segment {
    fn parse(tokens: Vec<OsString>) -> Result<Self> {
        let mut iter = tokens.into_iter();
        let Some(command) = iter.next() else {
            bail!("expected a command name");
        };
        let command_str = command
            .to_str()
            .ok_or_else(|| anyhow::anyhow!("command name must be valid UTF-8"))?;
        let args: Vec<OsString> = iter.collect();
        match command_str {
            "notification-center" | "notification" | "nc" => Ok(Segment::NotificationCenter(
                parse_args("notification-center", args)?,
            )),
            "flash-window" | "window-flash" | "flash" => {
                Ok(Segment::FlashWindow(parse_args("flash-window", args)?))
            }
            "confetti" => Ok(Segment::Confetti(parse_args("confetti", args)?)),
            "haptic" | "haptioc" => Ok(Segment::Haptic(parse_args("haptic", args)?)),
            other => bail!("unrecognized subcommand '{other}'"),
        }
    }

    fn execute(&self) -> Result<()> {
        match self {
            Segment::NotificationCenter(args) => execute_notification_center(args.clone()),
            Segment::FlashWindow(args) => execute_flash_window(args.clone()),
            Segment::Confetti(args) => execute_confetti(args.clone()),
            Segment::Haptic(args) => execute_haptic(args.clone()),
        }
    }
}

fn collect_segments() -> Result<Option<Vec<Segment>>> {
    let raw_args: Vec<OsString> = std::env::args_os().skip(1).collect();
    if raw_args.is_empty() {
        print_usage();
        return Ok(None);
    }
    match raw_args.first().and_then(|arg| arg.to_str()) {
        Some("-h") | Some("--help") | Some("help") => {
            print_usage();
            return Ok(None);
        }
        Some("-V") | Some("--version") | Some("version") => {
            println!("{}", env!("CARGO_PKG_VERSION"));
            return Ok(None);
        }
        _ => {}
    }

    let mut segments = Vec::new();
    let mut current = Vec::new();
    for arg in raw_args {
        if arg == OsString::from("--") {
            if !current.is_empty() {
                segments.push(Segment::parse(current)?);
                current = Vec::new();
            }
            continue;
        }
        current.push(arg);
    }
    if !current.is_empty() {
        segments.push(Segment::parse(current)?);
    }
    Ok(Some(segments))
}

fn parse_args<T>(name: &str, args: Vec<OsString>) -> Result<T>
where
    T: Parser,
{
    let parser = std::iter::once(OsString::from(name)).chain(args.into_iter());
    T::try_parse_from(parser).map_err(|err| err.into())
}

fn print_usage() {
    println!(
        r#"zing {}

Usage:
  zing <command> [args] [-- <command> [args]]...

Commands:
  notification-center  macOS Notification Center alert with title/subtitle/message
  flash-window         highlight the originating terminal window (coming soon)
  confetti             overlay celebratory particles (coming soon)
  haptic               play a taptic buzz on supported hardware (coming soon)

Separate chained commands with literal `--`, e.g.:
  zing notification-center "Build done" -- confetti -- haptic --violent
"#,
        env!("CARGO_PKG_VERSION")
    );
}

#[derive(Parser, Debug, Clone)]
struct NotificationCenterArgs {
    /// Primary message body.
    #[arg(value_name = "message")]
    message: String,
    /// Notification title (first line).
    #[arg(short, long, default_value = "Zing!")]
    title: String,
    /// Optional subtitle (second line).
    #[arg(long)]
    subtitle: Option<String>,
    /// macOS bundle identifier to attribute the notification to.
    #[arg(long, default_value = DEFAULT_BUNDLE_IDENTIFIER)]
    bundle_identifier: String,
    /// Explicit sound name; defaults to the system "default" chime.
    #[arg(long)]
    sound: Option<String>,
    /// Suppress all alert sounds.
    #[arg(long, conflicts_with = "sound")]
    silent: bool,
}

impl NotificationCenterArgs {
    fn sound(&self) -> NotificationSound {
        if self.silent {
            NotificationSound::Silent
        } else if let Some(name) = &self.sound {
            NotificationSound::Named(name.clone())
        } else {
            NotificationSound::Default
        }
    }
}

#[derive(Parser, Debug, Clone)]
struct FlashWindowArgs {
    /// Optional PID of the process to highlight.
    #[arg(long)]
    pid: Option<u32>,
    /// Optional substring to match against the window title.
    #[arg(long)]
    hint: Option<String>,
    /// Run without taking action; emits the planned lookup chain.
    #[arg(long)]
    dry_run: bool,
}

#[derive(Parser, Debug, Clone)]
struct ConfettiArgs {
    /// Duration in seconds that the overlay should remain visible.
    #[arg(long, default_value_t = 1.8)]
    duration: f32,
    /// Named intensity preset (e.g. "subtle", "extra").
    #[arg(long, default_value = "standard")]
    style: String,
    /// Run without taking action; emits the planned effect parameters.
    #[arg(long)]
    dry_run: bool,
}

#[derive(Parser, Debug, Clone)]
struct HapticArgs {
    /// Choose a named pattern preset.
    #[arg(long, default_value = "default")]
    pattern: String,
    /// Dial the intensity way up.
    #[arg(long)]
    violent: bool,
    /// Run without triggering the hardware.
    #[arg(long)]
    dry_run: bool,
}

fn execute_notification_center(mut args: NotificationCenterArgs) -> Result<()> {
    let sound = args.sound();
    let spec = notification::NotificationSpec {
        title: args.title,
        body: args.message,
        subtitle: args.subtitle.take(),
        sound,
        bundle_identifier: Some(args.bundle_identifier),
    };
    notification::dispatch(spec)
}

fn execute_flash_window(args: FlashWindowArgs) -> Result<()> {
    handle_unimplemented("flash-window", args.dry_run, FLASH_WINDOW_DESCRIPTION)
}

fn execute_confetti(args: ConfettiArgs) -> Result<()> {
    handle_unimplemented("confetti", args.dry_run, CONFETTI_DESCRIPTION)
}

fn execute_haptic(args: HapticArgs) -> Result<()> {
    handle_unimplemented("haptic", args.dry_run, HAPTIC_DESCRIPTION)
}

fn handle_unimplemented(feature: &str, dry_run: bool, description: &str) -> Result<()> {
    if dry_run {
        println!("{feature}: dry-run placeholder – {description} (implementation pending).");
        return Ok(());
    }
    bail!("{feature} is not implemented yet: {description}");
}

mod notification {
    use super::*;
    #[derive(Clone)]
    pub(super) struct NotificationSpec {
        pub title: String,
        pub body: String,
        pub subtitle: Option<String>,
        pub sound: NotificationSound,
        pub bundle_identifier: Option<String>,
    }

    pub(super) fn dispatch(spec: NotificationSpec) -> Result<()> {
        notifier_impl().notify(&spec)
    }

    trait Notifier {
        fn notify(&self, spec: &NotificationSpec) -> Result<()>;
    }

    #[cfg(target_os = "macos")]
    fn notifier_impl() -> impl Notifier {
        MacNotifier
    }

    #[cfg(not(target_os = "macos"))]
    fn notifier_impl() -> impl Notifier {
        FallbackNotifier
    }

    #[cfg(target_os = "macos")]
    struct MacNotifier;

    #[cfg(target_os = "macos")]
    mod fallback {
        use super::*;
        use std::process::Command;

        pub(super) fn applescript(spec: &NotificationSpec) -> Result<()> {
            let script = build_script(spec);
            let status = Command::new("osascript")
                .arg("-e")
                .arg(&script)
                .status()
                .with_context(|| format!("failed to spawn osascript for script: {script}"))?;
            if !status.success() {
                bail!("osascript exited with status {status}");
            }
            Ok(())
        }

        fn build_script(spec: &NotificationSpec) -> String {
            fn esc(input: &str) -> String {
                input.replace('\\', "\\\\").replace('"', "\\\"")
            }

            let mut parts = vec![format!(
                "display notification \"{}\" with title \"{}\"",
                esc(&spec.body),
                esc(&spec.title)
            )];

            if let Some(subtitle) = spec.subtitle.as_deref() {
                parts.push(format!("subtitle \"{}\"", esc(subtitle)));
            }

            if let Some(sound) = spec.sound.as_name() {
                parts.push(format!("sound name \"{}\"", esc(sound)));
            }

            parts.join(" ")
        }
    }

    #[cfg(target_os = "macos")]
    impl Notifier for MacNotifier {
        fn notify(&self, spec: &NotificationSpec) -> Result<()> {
            use mac_notification_sys::{Notification, set_application};

            let requested = spec
                .bundle_identifier
                .as_deref()
                .unwrap_or(DEFAULT_BUNDLE_IDENTIFIER);

            if let Err(err) = set_application(requested) {
                eprintln!(
                    "zing: unable to register bundle '{requested}', falling back to osascript: {err}"
                );
                return fallback::applescript(spec).with_context(|| {
                    format!("osascript fallback failed after bundle error: {err}")
                });
            }

            let mut notification = Notification::new();
            notification.title(&spec.title);
            notification.message(&spec.body);
            if let Some(subtitle) = spec.subtitle.as_deref() {
                notification.subtitle(subtitle);
            }

            match &spec.sound {
                NotificationSound::Silent => {}
                NotificationSound::Default => {
                    notification.default_sound();
                }
                NotificationSound::Named(name) => {
                    notification.sound(name.as_str());
                }
            }

            match notification.send() {
                Ok(_) => Ok(()),
                Err(err) => {
                    eprintln!(
                        "zing: mac_notification_sys send failed, falling back to osascript: {err}"
                    );
                    fallback::applescript(spec).with_context(|| {
                        format!("osascript fallback failed after notification send error: {err}")
                    })
                }
            }
        }
    }

    #[cfg(not(target_os = "macos"))]
    struct FallbackNotifier;

    #[cfg(not(target_os = "macos"))]
    impl Notifier for FallbackNotifier {
        fn notify(&self, spec: &NotificationSpec) -> Result<()> {
            println!(
                "[zing-notify] {title}: {body}",
                title = spec.title,
                body = spec.body
            );
            Ok(())
        }
    }
}

#[derive(Debug, Clone)]
enum NotificationSound {
    Silent,
    Default,
    Named(String),
}

impl NotificationSound {
    fn as_name(&self) -> Option<&str> {
        match self {
            NotificationSound::Silent => None,
            NotificationSound::Default => Some("default"),
            NotificationSound::Named(name) => Some(name.as_str()),
        }
    }
}
