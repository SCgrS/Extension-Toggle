# Extension Toggle

[Türkçe](README.tr.md)

### [⬇ Download for Windows (ExtensionToggle.exe)](https://github.com/SCgrS/Extension-Toggle/releases/latest/download/ExtensionToggle.exe)

A small **Windows program** that shows or hides file name extensions (.pdf, .docx, .txt and so on) with a single double-click.

Windows hides file extensions by default. Changing that means opening the View menu in File Explorer every time.
Extension Toggle flips the same setting from a shortcut on your desktop and refreshes open folder windows and the
desktop. It opens no window, does its job and closes right away.

## Installation

Requirements: Windows 10 or 11. Nothing else is needed. The program runs on the .NET Framework that ships with Windows.

1. Download `ExtensionToggle.exe` from the link above and move it to a permanent folder on your PC.
2. Right-click the file and choose **Show more options › Send to › Desktop (create shortcut)**. On Windows 10, **Send to**
   is directly in the right-click menu.
3. If Windows SmartScreen shows a warning the first time you double-click the shortcut, click **More info** › **Run
   anyway**. The warning appears because the program is not signed. If **Smart App Control** is turned on in Windows 11,
   Windows does not run unsigned programs at all, and the program will not open on that PC.

There is no installer and no administrator rights are needed. To build the program from its source code, see
[docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).

## Highlights

- **One double-click:** Hidden extensions become visible, visible ones get hidden.
- **Instant refresh:** Open folder windows and the desktop refresh on their own.
- **No window:** The program does its job and closes right away.
- **No installation:** It is a single file and needs no administrator rights.
- **One setting:** It changes only the extension setting and touches nothing else.

## What it does

### Showing and hiding extensions

Double-click the shortcut on your desktop. If extensions are hidden they become visible, if they are visible they get
hidden. Open folder windows and the desktop refresh on their own. The setting is the same as **View › Show › File name
extensions** in File Explorer (on Windows 10, the **File name extensions** box on the View tab). When one changes, so
does the other.

If the setting cannot be changed, the program says so in a small message box. If you delete the program and its
shortcut, extensions stay the way you last left them.

### How it works

The program changes only this registry value for the current user:

```
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideFileExt
```

If extensions are currently visible, the value becomes 1. If they are hidden, it becomes 0. The program then refreshes
open File Explorer windows and sends a refresh (F5) to the desktop.

## Updating

The program does not update itself. When a new version comes out, download it from the link above and put it in place
of the old `ExtensionToggle.exe`. The shortcut on your desktop keeps working unchanged.

## Privacy

The program collects and stores no data, has no telemetry and does not connect to the internet. It installs nothing on
your PC.

## Third-party components

None. The program only uses Windows and the .NET Framework that ships with Windows.

## Automated checks

[![CodeQL Advanced](https://github.com/SCgrS/Extension-Toggle/actions/workflows/codeql.yml/badge.svg?branch=main)](https://github.com/SCgrS/Extension-Toggle/actions/workflows/codeql.yml)\
[![Dependency Review](https://github.com/SCgrS/Extension-Toggle/actions/workflows/dependency-review.yml/badge.svg?branch=main)](https://github.com/SCgrS/Extension-Toggle/actions/workflows/dependency-review.yml)

---

Questions and feedback: [x.com/CgrShn](https://x.com/CgrShn)

License: AGPL-3.0. See the [LICENSE](LICENSE) file for details.
