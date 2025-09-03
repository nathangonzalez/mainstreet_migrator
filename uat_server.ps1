# Main Street Migrator - Network UAT HTTP Server
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "  Main Street Migrator - Network UAT HTTP Server" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ""

# Set the port number - using 8081 to avoid conflicts
$PORT = 8081

# Get the computer's IP address for network access
$IPAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -like "*Ethernet*" -or $_.InterfaceAlias -like "*Wi-Fi*" } | Select-Object -First 1).IPAddress
if (-not $IPAddress) {
    $IPAddress = "localhost"
    Write-Host "Could not determine network IP address, defaulting to localhost" -ForegroundColor Yellow
}

# Check if the static directory exists
if (-not (Test-Path "static")) {
    Write-Host "static directory not found! Make sure you're in the right directory." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Create a simple HTTP server
$Listener = New-Object System.Net.HttpListener
$Listener.Prefixes.Add("http://+:$PORT/")
try {
    $Listener.Start()
} catch {
    Write-Host "Failed to start server on all interfaces. You may need administrator privileges." -ForegroundColor Red
    Write-Host "Trying localhost only..." -ForegroundColor Yellow
    $Listener = New-Object System.Net.HttpListener
    $Listener.Prefixes.Add("http://localhost:$PORT/")
    try {
        $Listener.Start()
        $IPAddress = "localhost"
    } catch {
        Write-Host "Failed to start server. Error: $_" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host "Server started successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Access URLs:" -ForegroundColor Cyan
Write-Host "  Local:     http://localhost:$PORT/" -ForegroundColor Green
if ($IPAddress -ne "localhost") {
    Write-Host "  Network:   http://$($IPAddress):$PORT/" -ForegroundColor Green
}
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Create a default favicon.ico if it doesn't exist
if (-not (Test-Path "favicon.ico")) {
    if (Test-Path "static\favicon.ico") {
        Copy-Item "static\favicon.ico" -Destination "favicon.ico"
        Write-Host "Copied favicon.ico from static directory to root" -ForegroundColor Green
    } else {
        Write-Host "Creating default favicon.ico" -ForegroundColor Yellow
        # Create a 1x1 transparent pixel as a simple favicon
        [byte[]]$faviconBytes = @(0,0,1,0,1,0,16,16,0,0,1,0,24,0,68,3,0,0,22,0,0,0,40,0,0,0,16,0,0,0,32,0,0,0,1,0,24,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
        [System.IO.File]::WriteAllBytes("favicon.ico", $faviconBytes)
    }
}

# Handle API mocking
$ApiResponses = @{
    "/api/health" = '{"status":"UP","version":"1.0.0"}'
    "/api/auth/login" = '{"tokens":{"access_token":"mock-jwt-token"},"user":{"id":1,"username":"admin"}}'
    "/api/assets" = '[{"id":1,"name":"Google Drive","type":"document-storage"},{"id":2,"name":"Gmail","type":"email"},{"id":3,"name":"Google Calendar","type":"calendar"}]'
    "/api/discovery/systems" = '[{"id":1,"name":"Google Workspace"},{"id":2,"name":"Microsoft 365"},{"id":3,"name":"Salesforce"}]'
    "/api/migration/jobs" = '[{"id":1,"status":"pending","progress":0,"source":"Google Workspace","target":"Microsoft 365"},{"id":2,"status":"completed","progress":100,"source":"Salesforce","target":"Microsoft 365"}]'
    "/api/migration/mappings" = '{"system_mappings":[{"source":"Google Drive","target":"OneDrive"},{"source":"Gmail","target":"Outlook"},{"source":"Google Calendar","target":"Outlook Calendar"}]}'
    "/api/compliance/frameworks" = '[{"id":1,"name":"GDPR"},{"id":2,"name":"HIPAA"},{"id":3,"name":"SOX"},{"id":4,"name":"PCI DSS"}]'
}

try {
    while ($Listener.IsListening) {
        $Context = $Listener.GetContext()
        $Request = $Context.Request
        $Response = $Context.Response
        $RequestUrl = $Request.Url.LocalPath
        
        Write-Host "Request: $($RequestUrl)" -ForegroundColor Cyan
        
        # Handle API mocking
        if ($RequestUrl.StartsWith('/api/')) {
            $Response.ContentType = "application/json"
            
            # Check if we have a mock response for this endpoint
            if ($ApiResponses.ContainsKey($RequestUrl)) {
                $ResponseContent = [System.Text.Encoding]::UTF8.GetBytes($ApiResponses[$RequestUrl])
            } 
            # Handle POST requests specially
            elseif ($Request.HttpMethod -eq "POST") {
                if ($RequestUrl -eq "/api/assets/classify") {
                    $ResponseContent = [System.Text.Encoding]::UTF8.GetBytes('{"message":"Assets classified successfully","asset_count":42}')
                }
                elseif ($RequestUrl -eq "/api/discovery/scan") {
                    $ResponseContent = [System.Text.Encoding]::UTF8.GetBytes('{"message":"Discovery scan initiated","assets_discovered":18}')
                }
                elseif ($RequestUrl -eq "/api/migration/start") {
                    $ResponseContent = [System.Text.Encoding]::UTF8.GetBytes('{"message":"Migration started successfully","job_id":3}')
                }
                elseif ($RequestUrl -eq "/api/compliance/verify") {
                    $ResponseContent = [System.Text.Encoding]::UTF8.GetBytes('{"message":"Compliance verification completed","overall_score":92,"details":{"passed":38,"failed":3,"warnings":5}}')
                }
                elseif ($RequestUrl.Contains("/audit/verification/")) {
                    $Response.StatusCode = 202
                    $ResponseContent = [System.Text.Encoding]::UTF8.GetBytes('{"message":"Audit verification started","verification_id":"mock-id-12345"}')
                }
                else {
                    $Response.StatusCode = 201
                    $ResponseContent = [System.Text.Encoding]::UTF8.GetBytes('{"message":"Resource created successfully","id":99}')
                }
            }
            else {
                $ResponseContent = [System.Text.Encoding]::UTF8.GetBytes('{"message":"Mock API response - Endpoint not specifically mocked"}')
            }
            
            $Response.ContentLength64 = $ResponseContent.Length
            $Response.OutputStream.Write($ResponseContent, 0, $ResponseContent.Length)
            $Response.OutputStream.Close()
            continue
        }
        
        # Special case for favicon.ico at the root
        if ($RequestUrl -eq "/favicon.ico") {
            if (Test-Path "favicon.ico") {
                $Content = [System.IO.File]::ReadAllBytes("favicon.ico")
                $Response.ContentType = "image/x-icon"
                $Response.ContentLength64 = $Content.Length
                $Response.OutputStream.Write($Content, 0, $Content.Length)
                $Response.OutputStream.Close()
                continue
            }
        }
        
        # Default to index.html if root is requested
        if ($RequestUrl -eq "/") {
            $FilePath = "static\index.html"
        } else {
            # Remove the leading slash and use as relative path
            $FilePath = $RequestUrl.TrimStart('/')
            
            # If the path doesn't include 'static/' and it's not a special route, prepend 'static/'
            if (-not $FilePath.StartsWith("static/") -and -not $FilePath.StartsWith("static\") -and 
                -not $FilePath -eq "favicon.ico") {
                $FilePath = "static\$FilePath"
            }
        }
        
        # Normalize path separators
        $FilePath = $FilePath.Replace("/", "\")
        
        # Check if the file exists
        if (Test-Path $FilePath -PathType Leaf) {
            $Content = [System.IO.File]::ReadAllBytes($FilePath)
            $Response.ContentLength64 = $Content.Length
            
            # Set content type based on file extension
            $Extension = [System.IO.Path]::GetExtension($FilePath)
            switch ($Extension) {
                ".html" { $Response.ContentType = "text/html" }
                ".css"  { $Response.ContentType = "text/css" }
                ".js"   { $Response.ContentType = "application/javascript" }
                ".json" { $Response.ContentType = "application/json" }
                ".png"  { $Response.ContentType = "image/png" }
                ".jpg"  { $Response.ContentType = "image/jpeg" }
                ".gif"  { $Response.ContentType = "image/gif" }
                ".ico"  { $Response.ContentType = "image/x-icon" }
                default { $Response.ContentType = "application/octet-stream" }
            }
            
            $Response.OutputStream.Write($Content, 0, $Content.Length)
        } else {
            Write-Host "  File not found: $FilePath" -ForegroundColor Yellow
            $Response.StatusCode = 404
            $ResponseContent = [System.Text.Encoding]::UTF8.GetBytes("<html><body><h1>404 - File Not Found</h1><p>The requested file does not exist: $FilePath</p></body></html>")
            $Response.ContentType = "text/html"
            $Response.ContentLength64 = $ResponseContent.Length
            $Response.OutputStream.Write($ResponseContent, 0, $ResponseContent.Length)
        }
        
        $Response.OutputStream.Close()
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
} finally {
    $Listener.Stop()
    Write-Host "Server stopped" -ForegroundColor Yellow
}

Read-Host "Press Enter to exit"
