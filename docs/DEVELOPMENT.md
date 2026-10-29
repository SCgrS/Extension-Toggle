# Development

This document is for anyone who wants to build or change the program. To use it, the [README](../README.md) is enough.

## Source code

The source code is in the `src` folder: `Program.cs` holds the program, `AssemblyInfo.cs` holds its name and version
number (`AssemblyVersion`, `AssemblyFileVersion` and `AssemblyInformationalVersion`).

The program does the following, in order:

1. If another copy is already running (the shortcut was started twice very quickly), it exits without doing anything
   (a mutex named `Local\ExtensionToggle`).
2. It asks the shell whether extensions are visible (`SHGetSetSettings`, `SSF_SHOWEXTENSIONS`). The shell reads
   `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideFileExt` and gives the same answer File Explorer
   shows, even if the value was written with a broken type. The program writes the opposite to that key as a DWORD: 1 if
   extensions are visible, 0 if they are hidden. If it cannot write, it shows an error message and exits.
3. It refreshes open File Explorer windows through `Shell.Application`. Internet Explorer windows that may appear in the
   same list are left alone. The shell caches the setting in every process. Refreshing any folder view clears that cache
   in all processes, which is why writing the registry alone is not enough.
4. It sends an F5 key message to the list of desktop icons (`SysListView32`). The desktop view (`SHELLDLL_DefView`) is
   looked up in the `Progman` window, or in some layouts in a `WorkerW` window. If the list is not found, the view gets a
   refresh command (`WM_COMMAND`, `0x7103`). If the view is not found either, the shell gets a general refresh
   notification (`SHChangeNotify`).

The error message is the only text the program shows. It is Turkish on Turkish Windows and English everywhere else.

## Building

Double-click `Build.cmd`. The program is built with the C# compiler that ships with Windows (.NET Framework 4, the
64-bit `csc.exe` first, otherwise the 32-bit one) as `bin\ExtensionToggle.exe`. The `bin` folder is not tracked by Git.
When started by double-clicking, the window shows the result and waits for a key. It does not wait when started from an
open command prompt.

## Icon

`icon.ico` is created by `tools\make-icon.ps1` (a yellow folder with glasses in front of it):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\make-icon.ps1
```

Run the command in PowerShell, in the repository folder. The icon contains 16, 20, 24, 32, 40, 48, 64 and 256 pixel
sizes. The 256-pixel image is stored as PNG, the smaller ones as 32-bit BMP.
