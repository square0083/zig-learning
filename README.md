# 中文 Zig 练习 · zig_learning

[![CI](https://github.com/square0083/zig-learning/actions/workflows/ci.yml/badge.svg)](https://github.com/square0083/zig-learning/actions/workflows/ci.yml)

**通过修改代码、阅读诊断和逐题验证，动手学习 Zig。**

面向已有其他编程语言经验的 Zig 初学者：36 道独立练习、9 个章节、全中文题目与分层提示。从值与控制流出发，逐步掌握错误处理、指针、内存管理和编译期泛型，最后完成 CSV 与统计汇总练习。

不需要第三方依赖，也不需要专用编辑器。用你熟悉的编辑器修改代码，由本地命令行工具检查结果并保存进度。

[快速开始](#快速开始) · [学习路线](#学习路线) · [命令参考](#命令参考) · [进度与工作区](#进度与工作区) · [常见问题](#常见问题) · [开发与验收](#开发与验收)

## 你会如何学习

1. **读题**：每个练习文件都包含中文目标、前置知识和需要修改的位置。
2. **修改**：修复模板中有意保留的编译错误或行为错误。
3. **验证**：保存后自动检查，结合编译器诊断与测试结果继续调整。
4. **推进**：通过后记录进度，自动进入第一道尚未有效通过的练习。

卡住时可以逐层查看提示：先理解概念，再查语法/API，最后参考解题步骤。每道题均可单独运行，没有必须先完成前置题的限制。

> **安全提醒：这不是沙箱。** 练习会由本地 Zig 编译并执行，具有当前用户的权限。只运行你信任的代码；工具不限制执行时间。使用 Ctrl+C 结束前台程序及共享控制台的编译/测试进程。

## 快速开始

### 1. 准备环境

- **Zig 0.17.0**：先安装 [Zig 工具链](https://ziglang.org/download/)，并将可执行文件加入 `PATH`。
- **代码编辑器**：任何能编辑 UTF-8 文本的编辑器均可。
- **UTF-8 终端**：Windows 下若中文显示异常，在当前终端执行 `chcp 65001`。应用不会修改持久终端设置。

```bash
zig version
# 预期输出：0.17.0
```

**版本必须精确匹配 `0.17.0`，不是“0.17.0 或更高”。** 工具会在第一次真正检查题目前校验版本；开发版后缀或其他版本也会被拒绝。

### 2. 构建并创建学习目录

在仓库根目录打开 Bash（Linux / macOS）：

```bash
zig build
exe="$(pwd)/zig-out/bin/zig_learning"

"$exe" init ./zig-exercises
"$exe" watch --path ./zig-exercises
```

用编辑器打开新生成的 **zig-exercises/exercises/01_values.zig**，阅读文件顶部的说明，修改后保存。请修改学习目录中的文件，而不是仓库里的课程模板。

首次检查失败是正常现象：练习模板本来就是待修复的代码。

### 3. 保存、查看反馈、继续下一题

`watch` 启动后立即检查当前题，之后每 500ms 比较文件内容。内容未改变时不会重复检查；通过后自动前进。按 Ctrl+C 退出，下次启动时根据已保存的有效进度继续。

需要提示或查看进度时，可以在**另一个终端**中运行以下命令。新终端需要在仓库根目录重新设置 `exe`：

```bash
exe="$(pwd)/zig-out/bin/zig_learning"

"$exe" list --path ./zig-exercises
"$exe" hint --path ./zig-exercises
"$exe" hint 01_values --level 2 --path ./zig-exercises
```

`--level 2` 显示前两层提示，`--level 3` 显示全部三层；不记录提示查看次数。

<details>
<summary>Windows / PowerShell 命令写法</summary>

Windows 使用带 `.exe` 后缀的可执行文件，并通过 `&` 调用：

```powershell
zig build
$exe = (Resolve-Path ./zig-out/bin/zig_learning.exe).Path
& $exe init ./zig-exercises
& $exe watch --path ./zig-exercises
```

另一个 PowerShell 终端中查看提示：

```powershell
$exe = (Resolve-Path ./zig-out/bin/zig_learning.exe).Path
& $exe hint --path ./zig-exercises
```

CI 在 Linux 上运行 Bash 端到端烟测；Windows、macOS 的控制台交互行为仍需单独验收。

</details>

## 学习路线

课程按下列顺序组织，完整题号可通过 `list` 查看。建议初学者顺序完成，已有基础时也可以用 `run <id>` 跳到指定题。

| 章节 | 题号 | 学习内容 |
| --- | --- | --- |
| 基础 | 01–07 | 值与返回值、变量与可变性、整数扩宽、布尔逻辑、数组、切片、UTF-8 字符串 |
| 控制流 | 08–12 | `if` 表达式、`while` 阶乘、`for` 计数、`switch` 范围分支、函数与区间 |
| 数据建模 | 13–15 | 结构体方法、枚举映射、带标签联合 |
| 可选值与错误 | 16–20 | 可选类型、`orelse`、错误联合、`try`、`catch` |
| 指针与所有权 | 21–23 | 指针解引用、可变切片原地反转、`defer` |
| 内存与容器 | 24–28 | 分配器、`ArrayList`、`errdefer`、`HashMap`、边界检查 |
| 编译期与泛型 | 29–31 | `comptime`、泛型函数、固定容量泛型栈 |
| 数据处理 | 32–34 | 位操作、小端解码、JSON 配置与字符串内存所有权 |
| 综合练习 | 35–36 | CSV 解析求和、逐行整数统计汇总 |

这是一套动手练习，而不是完整的语言手册。遇到陌生概念时，可结合 [Zig 官方文档](https://ziglang.org/documentation/) 阅读；请注意文档与本项目要求的工具链版本是否一致。

## 命令参考

基本形式：

```text
zig_learning [选项] <命令> [参数] [选项]
```

下表中的命令均接在可执行文件之后，例如 Bash 中的 `"$exe" list --path ./zig-exercises`。

| 命令 | 行为 |
| --- | --- |
| `init [path]` | 创建学习目录，默认路径为 `zig-exercises`；不覆盖或合并已有课程 |
| `list` | 按课程顺序显示题号、中文题名、章节、状态和有效进度 |
| `run [id]` | 检查指定题；省略题号时检查第一道尚未有效通过的题 |
| `hint [id] [--level 1\|2\|3]` | 查看指定题或第一道尚未有效通过的题的提示；默认第 1 层，第 N 层显示前 N 层 |
| `watch` | 自动检查当前题，失败后等待内容变化，通过后自动前进；不带命令时默认为此模式 |
| `verify` | 顺序检查全部 36 题；练习失败时继续，环境或文件错误时停止 |
| `--help` | 显示帮助，不打开工作区、不调用编译器 |
| `--version` | 显示应用版本，不打开工作区、不调用编译器 |

### 选项与参数

| 选项 | 适用范围 | 说明 |
| --- | --- | --- |
| `--path <目录>` | 除 `init` 外的命令 | 指定学习目录，默认当前目录；不会向上搜索工作区 |
| `--zig <可执行文件>` | `run`、`watch`、`verify` | 指定 Zig 编译器，默认从 `PATH` 查找 `zig` |
| `--level <1\|2\|3>` | `hint` | 指定提示层级，默认 `1` |

- `init` 的目标目录使用位置参数，不支持 `--path`。
- 选项可以放在子命令前或后；重复选项、未知选项和缺失参数均报错。
- 题号必须完整，例如 `01_values`，不接受 `1` 或 `01`。
- 全部完成后，无题号的 `run`、`hint` 和 `watch` 输出「全部 36 道练习已完成」，不再调用编译器；仍可指定题号复习，或执行 `verify` 全量检查。

### 常用操作

以下示例沿用快速开始中设置的 `exe`，在仓库根目录运行。若 `watch` 正在运行，请先停止它，再执行会写入进度的命令。

```bash
# 单独检查某一道题，也可用于复习已通过的题
"$exe" run 18_errors --path ./zig-exercises

# 检查全部练习
"$exe" verify --path ./zig-exercises

# 使用指定位置的编译器，含空格的路径需要引号
"$exe" run 01_values --path ./zig-exercises --zig "/opt/zig tools/zig"
```

也可以通过构建系统运行 CLI，`--` 后的参数会传给应用：

```bash
zig build run -- --help
zig build run -- list --path ./zig-exercises
```

### 退出码

| 退出码 | 含义 |
| --- | --- |
| `0` | 命令成功，或所检查的练习通过 |
| `1` | 练习检查失败，或检查期间源码发生变化，未记录通过 |
| `2` | 参数、环境、文件或进度错误 |

## 进度与工作区

初始化后的学习目录如下，**日常只需编辑 exercises 中的文件**：

```text
zig-exercises/
├── exercises/
│   ├── 01_values.zig
│   ├── 02_variables.zig
│   └── …                         # 共 36 道练习
└── .zig-learning/
    ├── checks/                   # 独立判题模块，请勿修改
    └── progress.json             # 通过记录与源码哈希
```

每道题由独立检查模块通过 `@import("exercise")` 调用练习接口判题。删除练习文件里的测试不能绕过独立检查。请保留题目要求的公开接口，不要删除或修改 `.zig-learning/checks`。

### 什么是“有效进度”

通过记录保存题号及源码的 **SHA-256**。只有当前源码与通过时完全一致，该题才计入有效进度。

| 状态 | 含义 | 下一步 |
| --- | --- | --- |
| 未完成 | 没有通过记录 | 修改并检查 |
| 已通过 | 当前源码与通过记录一致 | 继续下一题，或回顾代码 |
| 已修改 | 有通过记录，但源码已经变化 | 重新检查；通过后恢复有效进度 |
| 文件缺失 | 找不到该题的源码文件 | 恢复文件后重新检查 |

检查失败会撤销该题旧的通过记录；执行前后源码不同也不会记录通过。每次检查后的进度使用同目录临时文件原子替换保存，进度格式版本和课程版本均为 `1`。

### 使用边界

- **同一学习目录只支持一个进度写入进程。** 不要同时运行多个 `run`、`watch` 或 `verify`；`list`、`hint` 可以在其他终端只读使用。
- `watch` 等待期间只监测当前题。其他题的变化，会在下次前进或启动新命令时重新计算。
- 练习文件缺失时，`run` 报错；`watch` 等待文件重建，不会自动恢复模板。
- 进度缺失、JSON 损坏、重复或未知题号、非法哈希、不支持的版本都会报错，工具不会自动清空或覆盖进度。
- 初始化发现目标目录已有 `exercises` 或 `.zig-learning` 时，会拒绝写入。初始化中途失败不会删除已写入的文件，请换一个新目标目录重试。
- 参考解不会复制到学习目录。备份学习成果时，建议同时保留 `exercises` 与 `.zig-learning`。

## 常见问题

### 提示找不到进度文件或学习目录

确认命令指向的是 `init` 创建的目录，而不是仓库根目录或其中的 `exercises` 子目录。非 `init` 命令默认使用当前目录，且不会向上搜索；最直接的方式是显式传入 `--path ./zig-exercises`。

### 已经安装 Zig，为什么仍然无法检查？

在当前终端运行 `zig version`，确认输出恰好为 `0.17.0`。若安装了多个版本，通过 `--zig` 指定正确的可执行文件。`init`、`list` 和 `hint` 不会调用编译器，因此这些命令成功并不代表编译器已配置正确。

### 保存后为什么没有重新检查？

`watch` 比较的是**当前题的文件内容**，而不是保存动作或文件时间。确认修改的是学习目录中的当前题；内容没有变化时不会重复编译。

### 通过的题为什么又变成“已修改”？

进度依据源码字节的 SHA-256 判断。即使只改了注释、空白或换行，也会使旧记录暂时失效；重新运行该题并通过即可。

### 如何重新开始，又不丢掉原来的答案？

使用 `init` 创建一个新的学习目录，例如 `"$exe" init ./zig-exercises-retry`，后续命令改用 `--path ./zig-exercises-retry`。不要对旧目录重复初始化，也不要依赖删除进度文件来重置。

## 开发与验收

### 项目结构

```text
src/
├── main.zig                      # 程序入口与退出码
├── cli.zig                       # 命令解析、分派与 watch 循环
├── workspace.zig                 # 学习目录初始化与打开
├── progress.zig                  # 进度读取、状态计算与原子保存
├── runner.zig                    # 编译器版本校验与练习执行
└── course/
    ├── catalog.zig               # 课程元数据的唯一来源
    ├── templates.zig             # 嵌入练习模板与检查模块
    ├── exercises/                # 故意有错的学习模板
    └── checks/                   # 独立行为检查
tests/
├── solutions/                    # 仅供开发验收的参考解
└── smoke.sh                      # 真实 CLI 与编译器烟测
```

应用只嵌入模板与检查，不嵌入参考解。课程顺序、题号、章节、目标和提示统一维护在 [catalog.zig](src/course/catalog.zig) 中；构建步骤见 [build.zig](build.zig)。

### 构建与自动化测试

在仓库根目录使用 Zig 0.17.0：

```bash
zig version
zig build
zig build test         # 应用边界行为 + 全部参考解检查
zig build course-test  # 仅检查全部参考解
zig build run -- --help
```

端到端烟测需要 Bash 和常见 Unix 工具（如 `realpath`、`mktemp`、`cmp`），在 Linux 上运行：

```bash
bash ./tests/smoke.sh ./zig-out/bin/zig_learning "$(command -v zig)"
```

[烟测脚本](tests/smoke.sh) 在包含随机后缀、中文和空格的系统临时目录中调用真实 CLI 与编译器，断言全部 36 个初始模板失败、全部 36 个参考解通过，并验证进度读取、修改失效、重复初始化保护、缺失文件/编译器及损坏进度等行为。脚本通过 `trap` 在退出时清理自己创建的目录，无需修改终端编码。

### 持续集成

[GitHub Actions CI](https://github.com/square0083/zig-learning/actions/workflows/ci.yml) 在每次 push、Pull Request 和手动触发时运行，配置见 [ci.yml](.github/workflows/ci.yml)。

- 环境：Linux runner（`ubuntu-latest`）、固定版本 Zig 0.17.0。
- 检查：`zig build`、`zig build test` 和完整 `tests/smoke.sh` 烟测。
- 同一分支的新运行取消旧运行，单次任务超时为 30 分钟。
- 仓库权限为只读，Actions 固定到提交 SHA，并缓存 Zig 编译缓存。

交互式 watch 与 Ctrl+C 行为仍需按下节手动验收。

### 手动验收

普通单元测试不能替代控制台交互验证，以下行为需要单独检查：

- 在 `watch` 下分别保存错误与正确代码，观察重新检查及自动前进。
- 删除并重建当前练习文件，确认工具等待重建且不覆盖用户内容。
- 保存内容不变的文件，确认不会重复编译。
- 在测试实际执行无限循环时按 Ctrl+C，确认 CLI、Zig 和测试进程均退出。
