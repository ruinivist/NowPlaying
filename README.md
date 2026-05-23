# NowPlaying

NowPlaying is a KDE Plasma 6 widget inspired by the Cleartext Rainmeter widget. It displays the current song and artist with compact media controls, and is meant to live on the desktop rather than in a panel.

Now on KDE 6: https://www.pling.com/p/2195583/

> Too little too late but I plan to update it regularly now if any issues are created - ruinivist

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

The package is written to `build/org.ruiny.NowPlaying.plasmoid`.

## Project Structure

```text
.
├── package/
│   ├── metadata.json
│   └── contents/
│       ├── config/
│       │   ├── config.qml
│       │   └── main.xml
│       └── ui/
│           ├── configGeneral.qml
│           ├── main.qml
│           ├── Player.qml
│           └── Representation.qml
├── scripts/
│   └── watch.sh
└── Makefile
```

## Maintenance

Format files:

```bash
make format
```

Run lint checks:

```bash
make lint
```

Enable the repository pre-commit hook:

```bash
make hooks-install
```

## Customization

The widget appearance can be tuned from the Plasma widget settings, including:

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
