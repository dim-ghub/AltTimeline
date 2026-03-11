# AGENTS.md - Agentic Coding Guidelines

This document provides guidelines for AI agents working on this codebase.

## Project Overview

- **Project Type**: C++ Windows desktop application (Minecraft Legacy Console Edition)
- **Build System**: CMake (Windows x64 only) or Visual Studio 2022
- **C++ Standard**: C++17
- **Test Framework**: None currently

---

## Build Commands

### Visual Studio (Recommended)

1. Open `MinecraftConsoles.sln` in Visual Studio 2022
2. Set `Minecraft.Client` as Startup Project
3. Select configuration: `Debug` or `Release`
4. Select platform: `Windows64`
5. Build: `Build > Build Solution` (Ctrl+Shift+B)
6. Run: `F5` (Debug) or Ctrl+F5 (Release)

### CMake (Windows x64)

Configure:
```powershell
cmake -S . -B build -G "Visual Studio 17 2022" -A x64 -DCMAKE_GENERATOR_INSTANCE="C:/Program Files/Microsoft Visual Studio/2022/Community"
```

Build Debug:
```powershell
cmake --build build --config Debug --target MinecraftClient
```

Build Release:
```powershell
cmake --build build --config Release --target MinecraftClient
```

Run executable:
```powershell
cd build\Debug
.\MinecraftClient.exe
```

### MSBuild (Command Line)

```powershell
msbuild MinecraftConsoles.sln /p:Configuration=Debug /p:Platform="Windows64"
```

### Single Test

**No test framework currently exists in this project.**

---

## Code Style Guidelines

### Formatting

- **Formatter**: clang-format with Microsoft base style (`.clang-format`)
- Run `clang-format -i <file>` to format code
- Configuration in `.clang-format`:
  - Indent width: 4 spaces
  - Tab width: 4
  - Pointer alignment: Right (`Type*`)
  - Brace wrapping: After control statements, functions, classes
  - Column limit: 0 (unlimited line length)
  - Use tabs: Never

### Linting

- **Linter**: clang-tidy (`.clang-tidy`)
- Enable all `modernize-*` checks except `modernize-use-trailing-return-type`
- Run: `clang-tidy <file> -- -std=c++14`
- Notable checks enabled:
  - `google-readability-casting`
  - `cppcoreguidelines-pro-type-cstyle-cast`

### Naming Conventions

- **Classes**: PascalCase (e.g., `Achievement`, `ChatScreen`)
- **Methods/Functions**: PascalCase (e.g., `getDescription()`, `isGolden()`)
- **Variables**: camelCase (e.g., `message`, `cursorIndex`)
- **Member variables**: Often prefixed with `m_` or Hungarian notation (e.g., `isGoldenVar`)
- **Constants**: PascalCase (e.g., `CHAT_HISTORY_MAX`)
- **Static variables**: Prefix with `s_` (e.g., `s_chatHistory`)

### Headers

- Use `#pragma once` for header guards (not `#ifndef`/`#define`)
- Order includes:
  1. Project's `stdafx.h`
  2. Other project headers (quoted)
  3. Standard library headers
- Many files use `using namespace std;` at file scope in headers

### Types

- Use `std::wstring` for wide strings
- Use `std::string` for narrow strings
- Use `std::vector`, `std::shared_ptr`, `std::unique_ptr` from `<memory>`/`<vector>`
- Use `bool` for booleans
- Prefer `int` for integers unless specific width needed
- Use `size_t` for sizes and indices

### Code Patterns

- **Constructors**: Use member initializer lists
- **Getters**: Return by value or const reference, named `getXxx()`
- **Setters**: Named `setXxx()`, often return `this` for chaining
- **Boolean getters**: Named `isXxx()` or `hasXxx()`
- **Null checks**: Use `nullptr` (not NULL)
- **Virtual functions**: Use `virtual` keyword, override with `override` suffix

### Error Handling

- No exceptions (project predates widespread C++ exception usage)
- Check for null pointers explicitly
- Use return codes for error conditions where appropriate

### Class Layout

```cpp
class ClassName : public BaseClass
{
public:
    // constructors, destructors
    // public methods

private:
    // private data members
    // private methods
};
```

### Access Modifiers

Order in class:
1. `public:`
2. `protected:`
3. `private:`

---

## Git Workflow

- Pull requests should focus on one general topic
- All changes must be documented
- Follow the PR template

---

## Important Notes

- **Windows-only build**: This project only builds on Windows x64
- **Runtime requirements**: Game uses relative paths, must run from output directory
- **Parity focus**: Maintain visual/behavioral parity with original LCE

---

## File Extensions

- Headers: `.h`
- Source: `.cpp`
- Precompiled header: `stdafx.h`

