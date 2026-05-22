function Welcome(){
    if ($Host.UI.RawUI) {
        [Welcome]::RenderLogo()
        [Welcome]::RenderSystemInfo()
        [Welcome]::RenderDiskInfo()
        if($global:welcome_location){
            [Welcome]::RenderMeteo($global:welcome_location)
        }
        if($global:welcome_message){
             [Welcome]::RenderMessage($global:welcome_message)        
        }
    }
}