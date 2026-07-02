#############
# modules   #
#############

### core
$llmCoreClassPath = Join-Path $global:llm_core_path "LlmCore.ps1"
Write-Host $llmCoreClassPath
. $llmCoreClassPath
function llm {
    $persistentDataPath = Join-Path $global:persistent_data "llm"
    $instance = [LlmCore]::GetInstance($persistentDataPath) 
    if($null -eq $instance) {
        Write-Host "Failed to initialize LlmCore instance."
    }
    $instance.Execute($args)
}
