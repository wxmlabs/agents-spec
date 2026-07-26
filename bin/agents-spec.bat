@echo off
setlocal enabledelayedexpansion

:: agents-spec - Manage the .agents/ framework (Windows batch version)
:: Usage: bin\agents-spec.bat init|validate|list [target-dir]

set "ROOT=%~dp0.."
for %%i in ("%ROOT%") do set "ROOT=%%~fi"

set "CMD=%~1"
if "%CMD%"=="" set "CMD=help"
set "TARGET=%~2"
if "%TARGET%"=="" set "TARGET=%CD%"

set "USER_AGENT=%USERPROFILE%\.agent"

if /i "%CMD%"=="init" goto :case_init
if /i "%CMD%"=="validate" goto :case_validate
if /i "%CMD%"=="list" goto :case_list
if /i "%CMD%"=="--help" goto :case_help
if /i "%CMD%"=="-h" goto :case_help
goto :case_help

:case_init
    call :init_target
    goto :eof

:case_validate
    call :validate_target
    goto :eof

:case_list
    call :list_target
    goto :eof

:case_help
:case_--help
:case_-h
    call :show_help
    goto :eof

:: ========== HELP ==========
:show_help
    echo agents-spec - Manage the .agents/ framework
    echo.
    echo Usage:
    echo   bin\agents-spec.bat init [target-dir]     Initialize .agents/
    echo   bin\agents-spec.bat validate [target-dir]  Validate .agents/
    echo   bin\agents-spec.bat list [target-dir]      List skills and rules
    echo   bin\agents-spec.bat help                   Show this help
    echo.
    echo No runtime dependencies. Pure batch + powershell.
    goto :eof

:: ========== INIT ==========
:init_target
    if not exist "%TARGET%" (
        echo Error: target directory does not exist: %TARGET%
        exit /b 1
    )

    pushd "%TARGET%"
    set "TARGET_DIR=%CD%"
    popd

    echo Initializing .agents/ framework in %TARGET_DIR%

    mkdir "%TARGET_DIR%\.agents\skills"       2>nul
    mkdir "%TARGET_DIR%\.agents\rules"        2>nul
    mkdir "%TARGET_DIR%\.agents\local\rules"  2>nul
    mkdir "%TARGET_DIR%\.agents\local\skills" 2>nul

    if exist "%ROOT%\.agents\skills\" (
        for /d %%d in ("%ROOT%\.agents\skills\*") do (
            set "name=%%~nxd"
            if /i not "!name!"=="local" (
                xcopy /e /i /q /y "%%d" "%TARGET_DIR%\.agents\skills\!name!" >nul 2>&1
            )
        )
    )

    if exist "%ROOT%\AGENTS.md" (
        copy /y "%ROOT%\AGENTS.md" "%TARGET_DIR%\AGENTS.md" >nul
    )

    call :regenerate_readme "%TARGET_DIR%\.agents"
    call :gitignore_add "%TARGET_DIR%" ".agents/local/"

    call :init_user_level

    echo.
    echo Done. The .agents/ framework is now set up.
    echo.
    echo Next steps:
    echo   1. Review AGENTS.md for project-level guidance
    echo   2. Add team skills in .agents/skills/
    echo   3. Add team rules in .agents/rules/
    echo   4. Each dev adds local skills/rules in .agents/local/
    echo   5. Add cross-project skills/rules in ~/.agent/
    goto :eof

:init_user_level
    mkdir "%USER_AGENT%\skills"       2>nul
    mkdir "%USER_AGENT%\rules"        2>nul
    mkdir "%USER_AGENT%\local\skills" 2>nul
    mkdir "%USER_AGENT%\local\rules"  2>nul
    echo   + Created user-level ~/.agent/ directories
    goto :eof

:: ========== REGENERATE README ==========
:regenerate_readme
    set "AGENTS_DIR=%~1"
    set "README=%AGENTS_DIR%\README.md"

    >"%README%" (
        echo # .agents Directory
        echo.
        echo Stores AI Agent skills and rules for this project.
        echo For the full framework definition, see the skill: `skills/agents-spec/SKILL.md`.
        echo.
        echo Upstream: https://github.com/wxmlabs/agents-spec
        echo.
        echo ## Directory Structure
        echo.
        echo ```
        echo .agents/
        echo   README.md
        echo   rules/
        echo   skills/
        echo     agents-spec/
        echo   local/
        echo     rules/
        echo     skills/
        echo ```
        echo.
        echo ## This Project's Inventory
        echo.
        echo ### Shared Skills
        echo.
    )

    set "HAS_SKILLS=0"
    if exist "%AGENTS_DIR%\skills\" (
        for /d %%d in ("%AGENTS_DIR%\skills\*") do (
            set "HAS_SKILLS=1"
        )
    )
    if "!HAS_SKILLS!"=="1" (
        >>"%README%" echo ^| Skill ^| Path ^| Purpose ^|
        >>"%README%" echo ^|-------^|------^|---------^|
        for /d %%d in ("%AGENTS_DIR%\skills\*") do (
            set "name=%%~nxd"
            >>"%README%" call echo ^| %%name%% ^| `skills/%%name%%/` ^| ^(see SKILL.md^) ^|
        )
    ) else (
        >>"%README%" echo (none yet^)
    )

    >>"%README%" echo.
    >>"%README%" echo ### Shared Rules
    >>"%README%" echo.

    set "HAS_RULES=0"
    if exist "%AGENTS_DIR%\rules\" (
        for %%f in ("%AGENTS_DIR%\rules\*.md") do set "HAS_RULES=1"
    )
    if "!HAS_RULES!"=="1" (
        >>"%README%" echo ^| Rule ^| Path ^| Purpose ^|
        >>"%README%" echo ^|------^|------^|---------^|
        for %%f in ("%AGENTS_DIR%\rules\*.md") do (
            set "name=%%~nf"
            >>"%README%" call echo ^| %%name%% ^| `rules/%%name%%.md` ^| ^(see file^) ^|
        )
    ) else (
        >>"%README%" echo (none yet^)
    )
    goto :eof

:: ========== GITIGNORE ADD ==========
:gitignore_add
    set "GI_DIR=%~1"
    set "PATTERN=%~2"
    set "GI_FILE=%GI_DIR%\.gitignore"

    if exist "%GI_FILE%" (
        findstr /x /c:"%PATTERN%" "%GI_FILE%" >nul 2>&1
        if not errorlevel 1 goto :eof

        for %%a in ("%GI_FILE%") do set "GI_SIZE=%%~za"
        if !GI_SIZE! gtr 0 (
            >>"%GI_FILE%" echo.
        )
    )

    >>"%GI_FILE%" echo # Local-only agent files
    >>"%GI_FILE%" echo %PATTERN%
    echo   + Added %PATTERN% to .gitignore
    goto :eof

:: ========== VALIDATE ==========
:validate_target
    set "AGENTS_DIR=%TARGET%\.agents"
    set ERRORS=0

    if not exist "%AGENTS_DIR%" (
        echo Error: .agents/ directory not found in %TARGET%
        echo Run "bin\agents-spec.bat init" first.
        exit /b 1
    )

    if not exist "%AGENTS_DIR%\rules" (
        echo   Missing directory: .agents/rules
        set /a ERRORS=ERRORS+1
    )
    if not exist "%AGENTS_DIR%\skills" (
        echo   Missing directory: .agents/skills
        set /a ERRORS=ERRORS+1
    )
    if not exist "%AGENTS_DIR%\local\rules" (
        echo   Missing directory: .agents/local/rules
        set /a ERRORS=ERRORS+1
    )
    if not exist "%AGENTS_DIR%\local\skills" (
        echo   Missing directory: .agents/local/skills
        set /a ERRORS=ERRORS+1
    )

    if not exist "%USER_AGENT%\rules" (
        echo   Missing user directory: ~/.agent/rules
        set /a ERRORS=ERRORS+1
    )
    if not exist "%USER_AGENT%\skills" (
        echo   Missing user directory: ~/.agent/skills
        set /a ERRORS=ERRORS+1
    )
    if not exist "%USER_AGENT%\local\rules" (
        echo   Missing user directory: ~/.agent/local/rules
        set /a ERRORS=ERRORS+1
    )
    if not exist "%USER_AGENT%\local\skills" (
        echo   Missing user directory: ~/.agent/local/skills
        set /a ERRORS=ERRORS+1
    )

    call :check_encoding "%AGENTS_DIR%"

    if not exist "%TARGET%\AGENTS.md" (
        echo   Missing AGENTS.md
        set /a ERRORS=ERRORS+1
    )

    if !ERRORS! equ 0 (
        echo All checks passed. The .agents/ framework is valid.
    ) else (
        echo.
        echo !ERRORS! issue(s^) found.
        exit /b 1
    )
    goto :eof

:check_encoding
    where powershell >nul 2>&1
    if errorlevel 1 goto :eof

    set "CHK_DIR=%~1"
    set "PS_FILE=%TEMP%\_agents_check.ps1"

    >"%PS_FILE%" echo $dir = '%CHK_DIR%'
    >>"%PS_FILE%" echo $files = Get-ChildItem -Path $dir -Recurse -Filter '*.md' ^| Where-Object { $_.FullName -notmatch '\\local\\' }
    >>"%PS_FILE%" echo foreach ($f in $files^) {
    >>"%PS_FILE%" echo   $txt = Get-Content -Path $f.FullName -Raw
    >>"%PS_FILE%" echo   $found = $false
    >>"%PS_FILE%" echo   for ($i = 0; $i -lt $txt.Length; $i++^) {
    >>"%PS_FILE%" echo     if ([int]$txt[$i] -gt 127^) { $found = $true; break }
    >>"%PS_FILE%" echo   }
    >>"%PS_FILE%" echo   if ($found^) {
    >>"%PS_FILE%" echo     $rel = $f.FullName.Substring($dir.Length + 1^)
    >>"%PS_FILE%" echo     Write-Host ('  Non-ASCII char in .agents/' + $rel^)
    >>"%PS_FILE%" echo   }
    >>"%PS_FILE%" echo }

    powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_FILE%" 2>nul
    del "%PS_FILE%" 2>nul
    goto :eof

:: ========== LIST ==========
:list_target
    set "AGENTS_DIR=%TARGET%\.agents"

    if not exist "%AGENTS_DIR%" (
        echo Error: .agents/ directory not found.
        exit /b 1
    )

    echo === Project-level (.agents/^) ===
    echo.

    call :list_cat "Shared Skills" 0 "%AGENTS_DIR%\skills"
    call :list_cat "Shared Rules"  1 "%AGENTS_DIR%\rules"
    call :list_cat "Local Skills"  0 "%AGENTS_DIR%\local\skills"
    call :list_cat "Local Rules"   1 "%AGENTS_DIR%\local\rules"

    echo.
    echo === User-level (~/.agent/^) ===
    echo.

    call :list_cat "User Skills"       0 "%USER_AGENT%\skills"
    call :list_cat "User Rules"        1 "%USER_AGENT%\rules"
    call :list_cat "User Local Skills" 0 "%USER_AGENT%\local\skills"
    call :list_cat "User Local Rules"  1 "%USER_AGENT%\local\rules"
    goto :eof

:list_cat
    set "LABEL=%~1"
    set "IS_RULES=%~2"
    set "DIR=%~3"
    set COUNT=0

    if not exist "%DIR%" (
        echo   %LABEL% (0^)
        goto :eof
    )

    for /d %%d in ("%DIR%\*") do set /a COUNT=COUNT+1
    echo   %LABEL% (!COUNT!^)

    if "!COUNT!"=="0" goto :eof

    for /d %%d in ("%DIR%\*") do (
        set "name=%%~nxd"
        if exist "%%d\SKILL.md" (
            echo     - !name! ^(skill^)
        ) else (
            echo     - !name!
        )
    )
    goto :eof
