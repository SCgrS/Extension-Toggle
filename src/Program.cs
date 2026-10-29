// Extension Toggle: Shows or hides file name extensions, then refreshes open File Explorer windows and the desktop.
//
// Built with the C# compiler that ships with Windows (C# 5, .NET Framework 4): Build.cmd.
using System;
using System.Globalization;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;
using Microsoft.Win32;

namespace ExtensionToggle
{
    static class Program
    {
        const string SettingsKey = @"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced";

        const uint WM_KEYDOWN = 0x0100;
        const uint WM_KEYUP = 0x0101;
        const uint WM_COMMAND = 0x0111;
        const int VK_F5 = 0x74;
        const int SFVIDM_MISC_REFRESH = 0x7103;
        const uint SSF_SHOWEXTENSIONS = 0x0002;
        const int SHCNE_ASSOCCHANGED = 0x08000000;
        const uint SHCNF_IDLIST = 0x0000;

        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        static extern IntPtr FindWindowEx(IntPtr parent, IntPtr childAfter, string className, string windowName);

        [DllImport("user32.dll")]
        static extern bool PostMessage(IntPtr window, uint message, IntPtr wParam, IntPtr lParam);

        [DllImport("user32.dll")]
        static extern bool SetProcessDPIAware();

        [DllImport("shell32.dll")]
        static extern void SHChangeNotify(int eventId, uint flags, IntPtr item1, IntPtr item2);

        // SHELLSTATE is 32 bytes. Bit 1 of its first DWORD is fShowExtensions.
        [DllImport("shell32.dll")]
        static extern void SHGetSetSettings(int[] state, uint mask, bool set);

        [STAThread]
        static void Main()
        {
            // If the shortcut is started twice within milliseconds, both copies read the same value and write the same
            // value, so one toggle is lost. The second copy does nothing.
            bool firstInstance;
            using (Mutex instanceLock = new Mutex(true, @"Local\ExtensionToggle", out firstInstance))
            {
                if (!firstInstance) return;
                try
                {
                    ToggleExtensions();
                }
                catch (Exception error)
                {
                    SetProcessDPIAware();
                    Application.EnableVisualStyles();
                    MessageBox.Show(ErrorPrefix() + error.Message, "Extension Toggle",
                        MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
                RefreshExplorerWindows();
                RefreshDesktop();
            }
        }

        // The only text the program shows: Turkish on Turkish Windows, English everywhere else.
        static string ErrorPrefix()
        {
            return CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "tr"
                ? "Ayar değiştirilemedi: "
                : "Could not change the setting: ";
        }

        // Asks the shell whether extensions are visible: If HideFileExt was written with a broken type, the answer still
        // matches what File Explorer shows. Then writes the opposite as a DWORD.
        static void ToggleExtensions()
        {
            int[] state = new int[16];
            SHGetSetSettings(state, SSF_SHOWEXTENSIONS, false);
            bool visible = (state[0] & 0x2) != 0;
            using (RegistryKey key = Registry.CurrentUser.CreateSubKey(SettingsKey))
            {
                key.SetValue("HideFileExt", visible ? 1 : 0, RegistryValueKind.DWord);
            }
        }

        // Refreshes open File Explorer windows. The list may also contain Internet Explorer windows, which are left alone.
        static void RefreshExplorerWindows()
        {
            try
            {
                dynamic shell = Activator.CreateInstance(Type.GetTypeFromProgID("Shell.Application"));
                foreach (dynamic window in shell.Windows())
                {
                    try
                    {
                        string program = window.FullName;
                        if (program != null && program.EndsWith("explorer.exe", StringComparison.OrdinalIgnoreCase))
                            window.Refresh();
                    }
                    catch { }
                }
            }
            catch { }
        }

        // Sends F5 to the desktop. If the icon list is not found, the desktop view gets a refresh command. If the view is
        // not found either, the shell gets a general refresh notification.
        static void RefreshDesktop()
        {
            IntPtr view = DesktopView();
            IntPtr list = view == IntPtr.Zero ? IntPtr.Zero : FindWindowEx(view, IntPtr.Zero, "SysListView32", null);
            if (list != IntPtr.Zero)
            {
                PostMessage(list, WM_KEYDOWN, (IntPtr)VK_F5, (IntPtr)0x003F0001);
                PostMessage(list, WM_KEYUP, (IntPtr)VK_F5, new IntPtr(unchecked((int)0xC03F0001)));
            }
            else if (view != IntPtr.Zero)
            {
                PostMessage(view, WM_COMMAND, (IntPtr)SFVIDM_MISC_REFRESH, IntPtr.Zero);
            }
            else
            {
                SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, IntPtr.Zero, IntPtr.Zero);
            }
        }

        // The desktop view (SHELLDLL_DefView) sits in the Progman window, or in some layouts in a WorkerW window.
        static IntPtr DesktopView()
        {
            IntPtr progman = FindWindowEx(IntPtr.Zero, IntPtr.Zero, "Progman", null);
            IntPtr view = FindWindowEx(progman, IntPtr.Zero, "SHELLDLL_DefView", null);
            IntPtr worker = IntPtr.Zero;
            while (view == IntPtr.Zero)
            {
                worker = FindWindowEx(IntPtr.Zero, worker, "WorkerW", null);
                if (worker == IntPtr.Zero) return IntPtr.Zero;
                view = FindWindowEx(worker, IntPtr.Zero, "SHELLDLL_DefView", null);
            }
            return view;
        }
    }
}
