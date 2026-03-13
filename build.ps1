param(
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release",

    [ValidateSet("msbuild", "cmake")]
    [string]$Method = "msbuild",

    [switch]$Clean
)

$ErrorActionPreference = "Stop"

$SolutionFile = "MinecraftConsoles.sln"
$ProjectName = "Minecraft.Client"
$Platform = "Windows64"

function Invoke-MSBuild {
    Write-Host "Building with MSBuild..." -ForegroundColor Cyan

    $msbuild = Get-Command msbuild -ErrorAction SilentlyContinue
    if (-not $msbuild) {
        Write-Host "MSBuild not found in PATH. Attempting to locate Visual Studio..." -ForegroundColor Yellow
        $vsPath = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe 2>$null
        if ($vsPath) {
            $msbuild = $vsPath
        } else {
            Write-Error "MSBuild not found. Please install Visual Studio 2022 with MSBuild component."
            exit 1
        }
    } else {
        $msbuild = $msbuild.Source
    }

    Write-Host "Using MSBuild: $msbuild" -ForegroundColor Gray
    Write-Host "Configuration: $Configuration | Platform: $Platform" -ForegroundColor Gray

    & $msbuild $SolutionFile /p:Configuration=$Configuration /p:Platform=$Platform /m

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Build failed with exit code $LASTEXITCODE"
        exit $LASTEXITCODE
    }

    Write-Host "Build completed successfully!" -ForegroundColor Green
    Write-Host "Output: x64\$Configuration\Minecraft.Client.exe" -ForegroundColor Gray
}

function Invoke-CMake {
    Write-Host "Building with CMake..." -ForegroundColor Cyan

    $cmake = Get-Command cmake -ErrorAction SilentlyContinue
    if (-not $cmake) {
        Write-Error "CMake not found in PATH. Please install CMake."
        exit 1
    }

    $buildDir = "build"

    if ($Clean -and (Test-Path $buildDir)) {
        Write-Host "Cleaning build directory..." -ForegroundColor Yellow
        Remove-Item -Recurse -Force $buildDir
    }

    if (-not (Test-Path $buildDir)) {
        Write-Host "Configuring CMake..." -ForegroundColor Gray

        $vsInstance = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath 2>$null
        if (-not $vsInstance) {
            Write-Error "Visual Studio 2022 not found."
            exit 1
        }

        $generator = "Visual Studio 17 2022"
        $arch = "-A x64"

        cmake -S . -B $buildDir -G $generator $arch -DCMAKE_GENERATOR_INSTANCE="$vsInstance"

        if ($LASTEXITCODE -ne 0) {
            Write-Error "CMake configuration failed."
            exit $LASTEXITCODE
        }
    }

    Write-Host "Building $Configuration..." -ForegroundColor Gray
    cmake --build $buildDir --config $Configuration --target MinecraftClient

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Build failed with exit code $LASTEXITCODE"
        exit $LASTEXITCODE
    }

    Write-Host "Build completed successfully!" -ForegroundColor Green
    Write-Host "Output: build\$Configuration\MinecraftClient.exe" -ForegroundColor Gray
}

if ($Clean) {
    Write-Host "Cleaning..." -ForegroundColor Yellow
    $pathsToClean = @("x64", "build", "bin", "obj")
    foreach ($path in $pathsToClean) {
        if (Test-Path $path) {
            Write-Host "  Removing $path..." -ForegroundColor Gray
            Remove-Item -Recurse -Force $path
        }
    }
    Write-Host "Clean completed." -ForegroundColor Green
    exit 0
}

switch ($Method) {
    "msbuild" { Invoke-MSBuild }
    "cmake" { Invoke-CMake }
}
