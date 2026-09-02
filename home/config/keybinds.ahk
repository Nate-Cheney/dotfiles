#Requires AutoHotkey v2.0
SetTitleMatchMode 2

; No launch args
#B::FocusOrLaunch( "Zen", "zen.exe" )
#C::FocusOrLaunch( "Code", "Code.exe" )
#H::FocusOrLaunch( "Teams", "ms-teams.exe" )
#M::FocusOrLaunch( "Outlook", "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE" )
#O::FocusOrLaunch( "Obsidian", "C:\Users\ncheney\AppData\Local\Programs\Obsidian\Obsidian.exe" )

; Custom launch args
#A::FocusOrLaunch(
    "Pi Agent", 
    "C:\Program Files\Alacritty\alacritty.exe",
    'alacritty.exe --title "Pi Agent" -e wsl.exe -d FedoraLinux-43 --cd /mnt/c/Fishbeck/Dev/pi-agent -- /usr/local/sbin/devpod ssh . --command pi'
)
#T::FocusOrLaunch(
    "Alacritty", 
    "C:\Program Files\Alacritty\alacritty.exe", 
    'alacritty.exe --title "Alacritty" --working-directory "' EnvGet("USERPROFILE") '"'
)


; Focus Or Launch App Function
FocusOrLaunch(title, exePath, command := "") {
    SplitPath(exePath, &exeName)
    hwnd := WinExist(title " ahk_exe " exeName)

   if hwnd {
       if WinGetMinMax(hwnd) = -1
           WinRestore(hwnd)

       WinActivate(hwnd)
       WinWaitActive(hwnd, , 1)
   } else {
       ; If no custom command was provided, launch the executable directly.
       Run(command != "" ? command: exePath)
   }
}
