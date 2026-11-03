# 中文 Zig 练习

[![CI](https://github.com/square0083/zig-learning/actions/workflows/ci.yml/badge.svg)](https://github.com/square0083/zig-learning/actions/workflows/ci.yml)

面向已有其他语言经验的 Zig 初学者。36 道独立练习，覆盖基础、控制流、数据建模、可选值与错误、指针与所有权、内存与容器、编译期与泛型、数据处理和综合练习。

## 开始学习

使用 **Zig 0.17.0**，不需要第三方依赖。Windows 终端请使用 UTF-8；中文显示异常时，在当前终端运行 `chcp 65001`。应用不会修改持久终端设置。

```powershell
zig build
$exe = (Resolve-Path ./zig-out/bin/zig_learning.exe).Path
& $exe init ./zig-exercises
& $exe watch --path ./zig-exercises
```

用外部编辑器打开 `zig-exercises/exercises/01_values.zig`，根据中文说明修改并保存。watch 启动后立即检查当前题，之后每 500ms 比较文件内容；内容未改变不会重复检查。通过后自动进入第一道尚未有效通过的题。另一个终端可以查看提示：

```powershell
& $exe hint --path ./zig-exercises
& $exe hint 01_values --level 3 --path ./zig-exercises
```

**这不是沙箱。** 练习通过本地 Zig 编译和执行，具有当前用户权限；只运行你信任的代码。不限制执行时间，Ctrl+C 用于结束前台程序及共享控制台的编译/测试进程。

## 命令

|命令|行为|
|---|---|
|`init [path]`|默认创建 `zig-exercises`；已存在 `exercises` 或 `.zig-learning` 就拒绝写入，不覆盖、不合并|
|`list`|显示题号、中文题名、章节、状态和有效进度|
|`run [id]`|检查指定题；省略题号时检查第一道未完成题，无前置题限制|
|`hint [id] [--level 1\|2\|3]`|默认显示第一道未完成题的第一层提示；第 N 层显示前 N 层，不保存提示次数|
|`watch`|保存后自动检查；不带命令时默认运行 watch|
|`verify`|顺序检查全部 36 题；练习失败继续，环境或文件错误停止|
|`--help` / `--version`|不打开工作区、不调用编译器|

- 非 `init` 命令支持 `--path <目录>`，默认当前目录，不向上搜索工作区。
- `run/watch/verify` 支持 `--zig <可执行文件>`，默认从 PATH 查找 `zig`。第一次真正执行题目前验证版本恰好为 `0.17.0`。
- 选项可以在子命令前后出现；重复选项、未知选项、缺失参数均报错。
- 题号必须完整，例如 `01_values`，不接受数字简称。
- 退出码：`0` 成功，`1` 练习检查失败或执行期间源码改变，`2` 参数、环境、文件或进度错误。
- 全部完成时，无题号 `run/hint/watch` 输出「全部 36 道练习已完成」，不再调用编译器。

## 工作区与进度

初始化写入 `exercises/*.zig`、`.zig-learning/checks/*.zig`，最后创建 `.zig-learning/progress.json`。初始化失败不会删除已经写入的文件；请使用新目标目录重试。参考解不会复制到学习目录。

每道练习通过独立检查模块的 `@import("exercise")` 接口判题；删除练习自己的测试不能绕过检查。不要删除或修改 `.zig-learning/checks`。

通过记录保存题号和源码的 SHA-256，格式版本及课程版本均为 1。进度在每次检查后通过同目录临时文件原子替换保存：

- 源码改动后，旧通过记录显示「已修改」，不计入有效进度；重新检查通过后恢复。
- 检查失败撤销该题旧通过记录；执行前后源码不同则不会记录通过。
- 文件缺失时显示「文件缺失」；单次 run 报错，watch 等待用户重建，不自动恢复模板。
- 进度缺失、JSON 损坏、重复/未知题号、非法哈希或不支持的版本均报错，绝不自动清空或覆盖。
- **同一目录只支持一个进度写入进程**，不要同时运行多个 run、watch 或 verify；list/hint 可以另开终端只读使用。
- watch 等待期间仅监测当前题；其他题的变化在下一次前进或新命令时重新计算。

## 开发与验收

`src/course/catalog.zig` 是课程元数据的唯一来源。`src/course/exercises` 是故意有错的学习模板；`src/course/checks` 是独立行为检查；`tests/solutions` 是仅供开发验收的参考解。应用仅嵌入模板与检查，不嵌入参考解。

```powershell
zig version
zig build
zig build test         # 应用边界行为 + 全部参考解检查
zig build course-test  # 仅检查全部参考解
zig build run -- --help
$exe = (Resolve-Path ./zig-out/bin/zig_learning.exe).Path
$zig = (Get-Command zig).Source
pwsh -NoProfile -File ./tests/smoke.ps1 -Exe $exe -Zig $zig
```

烟测在带 GUID、中文和空格的系统临时目录运行真实 CLI/编译器，逐项断言退出码：全部初始题失败、全部参考解通过、进度恢复与修改失效、重复初始化保护、缺失文件/编译器和损坏进度等。脚本只清理自己创建的目录，并在结束时恢复当前进程输出编码。

控制台交互需要单独验收：watch 下保存错误/正确代码、删除并重建当前文件、确认未改内容不重复编译，以及在测试实际运行无限循环时按 Ctrl+C，检查 CLI、Zig 和测试进程均退出。普通单元测试不替代这些控制台行为验证。

### 持续集成

[GitHub Actions CI](https://github.com/square0083/zig-learning/actions/workflows/ci.yml) 在每次 push、Pull Request 和手动触发时运行，配置见 [ci.yml](.github/workflows/ci.yml)。

- 环境：Windows runner、固定版本 Zig 0.17.0。
- 检查：`zig build`、`zig build test` 和完整 `tests/smoke.ps1` 烟测。
- 同一分支的新运行取消旧运行，单次任务超时为 30 分钟。
- 仓库权限为只读，Actions 固定到提交 SHA，并缓存 Zig 编译缓存。

交互式 watch 与 Ctrl+C 行为仍需按下节手动验收。

