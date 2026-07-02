# LLM Core Class - Object-Oriented Implementation
# Manages prompt, display, and API request for the LLM app
class LlmRenderer { 

    [void] RenderLlmHeader([String] $ModelName, [String] $ApiUrl) {
        Write-Host ""
        Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
        Write-Host "  ║          🤖 LLM CHAT INTERFACE                   ║" -ForegroundColor Magenta
        Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
        Write-Host ""
        Write-Host "  Model: $($ModelName)" -ForegroundColor Cyan
        Write-Host "  API:   $($ApiUrl)" -ForegroundColor White
        Write-Host ""
        Write-Host "  ──────────────────────────────────────────────────" -ForegroundColor White
      
    }
    [String] GetUserPrompt() {
        Write-Host ""
        Write-Host "  ──────── Your prompt : ────────────────────────────" -ForegroundColor White
        $prompt = read-host "  > " 
        return $prompt 
        
    }

    
    [void] RenderConfigMenu() {
        # Handle 'llm config' subcommand for customization
        Write-Host ""
        Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
        Write-Host "  ║          ⚙️  LLM CONFIGURATION                   ║" -ForegroundColor Magenta
        Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
        Write-Host ""

        # TODO: Implement interactive config menu
        Write-Host "  Current Settings:" -ForegroundColor White
        Write-Host "    API URL:   $($this.ApiUrl)" -ForegroundColor Cyan
        Write-Host "    Model:     $($this.ModelName)" -ForegroundColor Cyan
        Write-Host ""

        # TODO: Add options to update settings and save to config file
    }
    
    [void] RenderResponse([string] $response) {
        # Display API response in colorful, readable format
        $sep = "───────────────────────────────────────────────"
        Write-Host $sep  -ForegroundColor White
        Write-Host "  LLM Response: " -ForegroundColor Magenta -NoNewline
        Write-Host $response -ForegroundColor Cyan
        Write-Host $sep  -ForegroundColor White
    }

    
    [void] RenderConfigUpdate([string] $key, [string] $value) {
        # Display config update confirmation
        Write-Host "  Updated $($key): $value" -ForegroundColor Green
    }

    

    [void] RenderSystemMessage([string] $message) {
        # Display system messages (info, warnings, etc.)
        Write-Host "  ──────────────────────────────────────────────────" -ForegroundColor White
        Write-Host "  System: $message" -ForegroundColor White
    }

    
    [void] RenderError([string] $_error) {
        # Display errors in red with helpful context
        Write-Host ""
        Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
        Write-Host "  ║          ⚠️  ERROR                              ║" -ForegroundColor Red
        Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
        Write-Host ""

        # TODO: Implement error formatting and display
        Write-Host "  ──────────────────────────────────────────────────" -ForegroundColor White
        Write-Host "  Error:" + $_error -ForegroundColor Red
        Write-Host "  ──────────────────────────────────────────────────" -ForegroundColor White

        # TODO: Display error content with proper formatting
        Write-Host ""
    }

    
    [void] RenderConfigHeader() {
        # Display config menu header
        Write-Host ""
        Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
        Write-Host "  ║          ⚙️  LLM CONFIGURATION                   ║" -ForegroundColor Magenta
        Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
        Write-Host ""
    }

    
    [void] RenderConfigOption([string] $label, [string] $value) {
        # Display a single config option
        Write-Host "    $($label): $(if ($value) { $value } else { '-- (not set)' })" -ForegroundColor Cyan
    }

    
    [void] RenderHelp() {
        # Display help for LLM command usage
        Write-Host ""
        Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
        Write-Host "  ║          📚 LLM COMMAND HELP                    ║" -ForegroundColor Magenta
        Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
        Write-Host ""

        Write-Host "  Usage: llm [command]" -ForegroundColor Cyan
        Write-Host ""

        Write-Host "  Commands:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "    (no arg)     Start interactive chat with LLM" -ForegroundColor White
        Write-Host "                 Type your prompts and get AI responses" -ForegroundColor Gray
        Write-Host ""
        Write-Host "    config       Manage LLM configuration settings" -ForegroundColor White
        Write-Host "                 Options:" -ForegroundColor Gray
        Write-Host "                   a) Update API URL" -ForegroundColor Cyan
        Write-Host "                   b) Update Model Name" -ForegroundColor Cyan
        Write-Host "                   c) Save and exit" -ForegroundColor Cyan
        Write-Host ""

        Write-Host "  Examples:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "    llm              Start chat with default settings" -ForegroundColor White
        Write-Host "    llm config       Open configuration menu" -ForegroundColor White
        Write-Host ""

        Write-Host "  ──────────────────────────────────────────────────" -ForegroundColor White
    }
}


class LlmCore {
    # Region: Properties

    [string]$ApiUrl = "http://localhost:1234/api/v1/chat"
    [string]$ModelName = "qwen/qwen3.5-9b"
    [string]$PersistentDataPath
    [object]$ConfigFile
  
    [LlmRenderer] $Renderer


    static [LlmCore] GetInstance($persistentDataPath) {

        if ($null -eq $global:llm_coreInstance) {
            Write-Host "Initializing LlmCore instance..."
            $global:llm_coreInstance = [LlmCore]::New($persistentDataPath)
        }else{
            Write-Host "Initializing LlmCore instance..."
            
        }
        return $global:llm_coreInstance
    }



    [void] Execute([String[]] $param) {
        switch ($param[0]) {
            "config" { 
                $this.ProcessConfigCommand()
            }
            "help" { 
                $this.Renderer.RenderHelp()
            }
            default { 
                $this.MainLoop()
            }
        }
    }

    # Region: Constructor

    LlmCore([string] $persistentDataPath) {
        write-host "Creating LlmCore instance with persistent data path: $persistentDataPath"
        $this.PersistentDataPath = $persistentDataPath
        $this.ConfigFile = Join-Path $this.PersistentDataPath "llm.json"

        if (Test-Path $this.ConfigFile) {
            try {
                $jsonContent = Get-Content -Path $this.ConfigFile -Raw -Encoding UTF8
                $this.ApiUrl = ($jsonContent | ConvertFrom-Json).ApiUrl
                $this.ModelName = ($jsonContent | ConvertFrom-Json).ModelName

                
                write-host "Api Url set to: $($this.ApiUrl)"
                write-host "Model Name set to: $($this.ModelName)"
            }
            catch {
                Write-Host "Failed to load config from $($this.ConfigFile). Using defaults." -ForegroundColor Yellow
            }
        }

        $this.Renderer = [LlmRenderer]::new()
    
    }

    [void] MainLoop() {
        # Display header with model and API info
        $this.Renderer.RenderLlmHeader($this.ModelName, $this.ApiUrl)

        while ($true) {
            # Get user prompt using LlmRenderer method
            $prompt = $this.Renderer.GetUserPrompt()

            if ([string]::IsNullOrWhiteSpace($prompt)) {
                break
            }

            # Send API request to get response
            $response = $this.SendApiRequest($prompt)

            # Display the response using LlmRenderer method
            $this.Renderer.RenderResponse($response)
        }
    }


 

    # Region: API Request Management
    [string] SendApiRequest([string] $prompt) {
        # Send request to configured LLM API endpoint
        try {
            $bodyJson = @{
                model       = $this.ModelName
                input       = $prompt
                temperature = 0
            } | ConvertTo-Json -Depth 10

            $response = Invoke-RestMethod `
                -Uri $this.ApiUrl `
                -Method Post `
                -ContentType "application/json" `
                -Body $bodyJson

            # Parse response output array to extract text content
            $textContent = @()
            foreach ($item in $response.output) {
                if ($item.type -eq "message") {
                    $textContent += $item.content
                }
                elseif ($item.type -eq "tool_call") {
                    # Optionally display tool calls as well
                    Write-Host "  Tool: $($item.tool)" -ForegroundColor Yellow
                    if ($item.arguments) {
                        Write-Host "    Args: $($item.arguments | ConvertTo-Json -Depth 10)" -ForegroundColor Gray
                    }
                }
            }

            # Return collected text content (or empty string if no messages)
            return $textContent -join "`n"
        }
        catch {
            Write-Host "Error: $_" -ForegroundColor Red
            if ($null -ne $_.Exception.Response.StatusCode) {
                if ($_.Exception.Response.StatusCode -eq 401) {
                    throw "Authorization failed. Check API configuration."
                }
                elseif ($_.Exception.Response.StatusCode -eq 503) {
                    throw "LLM service is not running. Start it at $($this.ApiUrl)"
                }
            }
            throw $_.Exception.Message
        }
    }

    [string] SendStreamRequest([string] $prompt, [scriptblock] $onToken) {
        # Send streaming request to LLM API (if supported)
        try {
            # TODO: Implement streaming request handling
            # Example structure:
            # $response = Invoke-RestMethod -Uri $this.ApiUrl `
            #     -Method Post `
            #     -ContentType "application/json" `
            #     -Body ($prompt | ConvertTo-Json) `
            #     -Stream

            return ""  # TODO: Return actual response content
        }
        catch {
            throw $_.Exception.Message
        }
    }

    [void] SaveConfig([string] $apiUrl, [string] $modelName) {
        # Save configuration to persistent data folder
        try {
            $config = @{
                ApiUrl    = $apiUrl
                ModelName = $modelName
            } | ConvertTo-Json -Depth 2

            if (-not (Test-Path $this.PersistentDataPath)) {
                New-Item -ItemType Directory -Path $this.PersistentDataPath -Force | Out-Null
            }

            Set-Content -Path $this.ConfigFile -Value $config -Encoding UTF8
            Write-Host "  Config saved to: $($this.ConfigFile)" -ForegroundColor Green
        }
        catch {
            throw $_.Exception.Message
        }
    }

    [hashtable] LoadConfig() {
        # Load configuration from persistent data folder
        if (Test-Path $this.ConfigFile) {
            try {
                return (Get-Content -Path $this.ConfigFile -Raw -Encoding UTF8 | ConvertFrom-Json)
            }
            catch {
                Write-Host "  Warning: Could not load config, using defaults" -ForegroundColor Yellow
            }
        }

        return @{
            ApiUrl    = $this.ApiUrl
            ModelName = $this.ModelName
        }
    }

    [void] ProcessConfigCommand() {
        # Handle 'llm config' subcommand for customization
        $this.Renderer.RenderConfigHeader()

        Write-Host "  Current Settings:" -ForegroundColor White
        $this.Renderer.RenderConfigOption("API URL:", $this.ApiUrl)
        $this.Renderer.RenderConfigOption("Model:", $this.ModelName)
        Write-Host ""

        # Display update options menu
        Write-Host "  Options:" -ForegroundColor White
        Write-Host "    a) Update API URL" -ForegroundColor Cyan
        Write-Host "    b) Update Model" -ForegroundColor Cyan
        Write-Host "    c) Save and exit" -ForegroundColor Cyan
        Write-Host ""

        # Read user choice
        $choice = Read-Host "  > Select option (a/b/c)"

        if ($choice -eq 'a') {
            # Update API URL
            Write-Host ""
            $newApiUrl = Read-Host "  > Enter new API URL"
            
            if ([string]::IsNullOrWhiteSpace($newApiUrl)) {
                return
            }

            try {
                [System.Uri]::new($newApiUrl).AbsolutePath
                $this.ApiUrl = $newApiUrl
                $this.Renderer.RenderConfigUpdate("API URL", $this.ApiUrl)
            }
            catch {
                Write-Host "  Invalid API URL format" -ForegroundColor Red
            }
        }
        elseif ($choice -eq 'b') {
            # Update Model Name
            Write-Host ""
            $newModel = Read-Host "  > Enter new model name"
            
            if ([string]::IsNullOrWhiteSpace($newModel)) {
                return
            }

            $this.ModelName = $newModel
            $this.Renderer.RenderConfigUpdate("Model", $this.ModelName)
        }
        elseif ($choice -eq 'c') {
            # Save and exit
            try {
                $this.SaveConfig($this.ApiUrl, $this.ModelName)
                Write-Host "  Configuration saved successfully" -ForegroundColor Green
            }
            catch {
                $this.Renderer.RenderError("Failed to save configuration: $_")
            }
            break
        }

        Write-Host ""
    }
}
