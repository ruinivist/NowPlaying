# NowPlaying

NowPlaying is a KDE Plasma 6 widget inspired by the Cleartext Rainmeter widget. It displays the current song and artist with compact media controls, and is meant to live on the desktop rather than in a panel.

https://www.pling.com/p/2195583/

> I think this is pretty much in a "done" state now feature-wise, except of course any bug fixes

## Prerequisites

You need the basic KDE and Qt 6 tools for Plasma widget development.

On Arch Linux, this is roughly:

```bash
sudo pacman -S plasma-sdk inotify-tools kirigami2 qt6-base qt6-declarative
```

## Development

Run the widget directly from the local package:

```bash
make dev
```

Other test modes are available:

```bash
make dev MODE=panel
make dev MODE=desktop
make dev MODE=hidpi
```

Use hot reload while editing:

```bash
make watch
```

Install or upgrade the widget in your local Plasma package store:

```bash
make install
```

Create a distributable package:

```bash
make package
```

## Customization

The widget appearance can be tuned from the Plasma widget settings, including:

- custom multiline label text
- independent label, title, and artist font sizes
- title/artist vertical spacing
- NOW/PLAYING label vertical spacing
- separator gap from labels
- separator gap from track text
- separator height percentage

## Release Upload

Required GitHub repository secrets:

- `PLING_PROJECT_ID`
- `PLING_USERNAME`
- `PLING_PASSWORD`

To dry run

```bash
uv run --env-file .env python scripts/pling_upload.py --dry-run
```

## Credits

Full credit to the Windows creator for the original idea. I just made a KDE clone.
