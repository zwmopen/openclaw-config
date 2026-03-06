; 音乐模式 AutoHotkey 脚本
; 触发：用户说"音乐模式"
; 功能：音量50% + 打开网易云音乐 + 等待20秒 + 空格播放

; 热键：Ctrl+Alt+M 启动音乐模式
^!m::
{
    ; 1. 音量调到50%
    SoundSet, 50
    
    ; 2. 启动网易云音乐
    Run, D:\Program Files\Netease\CloudMusic\cloudmusic.exe
    
    ; 3. 等待20秒
    Sleep, 20000
    
    ; 4. 发送空格键播放
    WinActivate, 网易云音乐
    Send, {Space}
    
    return
}
