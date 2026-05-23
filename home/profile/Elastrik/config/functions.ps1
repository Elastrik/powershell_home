function codeWS ($workspace) {
    switch ($workspace) {
        'EXT' { $path = "D:\documents\VSCODE\VSCODE_EXTENSIONS.code-workspace" }
        'PSH' { $path = "D:\documents\VSCODE\powershell.code-workspace" }
        Default { $path = "D:\documents\VSCODE\powershell.code-workspace" }
    }
    code --new-window $path
}
