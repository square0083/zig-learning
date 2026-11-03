//! 课程元数据：所有命令和构建脚本共同使用的唯一课程来源。
//!
//! 课程的顺序就是 `exercises` 数组的顺序；题目文件名为 `<id>.zig`，
//! 因此这里不保存冗余的路径字段。

pub const Exercise = struct {
    /// 题号与文件名，例如 `01_values`。
    id: []const u8,
    /// 所属章节名称。
    chapter: []const u8,
    /// 中文题名。
    title: []const u8,
    /// 中文学习目标。
    objective: []const u8,
    /// 三个由浅入深的中文提示：概念、相关语法/API、解题步骤。
    hints: [3][]const u8,
};

pub const exercises: [36]Exercise = .{
    .{
        .id = "01_values",
        .chapter = "基础",
        .title = "值与返回值",
        .objective = "实现 `answer() u8`，用 return 返回整数 42。",
        .hints = .{
            "Zig 函数用 `return` 把一个值交还给调用者，返回值必须与签名中的类型一致。",
            "签名 `pub fn answer() u8` 表示返回值是 0 到 255 之间的无符号整数；`return 41;` 只是返回了字面量 41。",
            "检查函数体里 return 后面的数字，把它改成题目要求的 42，不要加引号或小数点。",
        },
    },
    .{
        .id = "02_variables",
        .chapter = "基础",
        .title = "变量与可变性",
        .objective = "用可变的计数器从 1 开始自增两次，使 `count() u8` 返回 3。",
        .hints = .{
            "Zig 中 `const` 绑定初始化后不能再赋值；需要再次赋值时必须使用 `var`。",
            "只有当变量用 `var` 声明时，`count = count + 1;` 这样的赋值语句才合法。",
            "找到局部计数器 `count` 的声明，把 `const` 改成 `var`，让两次自增都作用在同一个可变绑定上。",
        },
    },
    .{
        .id = "03_integers",
        .chapter = "基础",
        .title = "整数扩宽",
        .objective = "实现 `addWide(a: u8, b: u8) u16`：先把两个数扩宽为 u16，再相加。",
        .hints = .{
            "u8 只能表示 0 到 255，两个 u8 相加可能超出范围，因此计算前要先换成更宽的类型。",
            "`@as(u16, a)` 可以把 u8 值显式扩宽到 u16，让后面的加法以 u16 进行。",
            "检查相加的位置：把 a 和 b 都转换为 u16 后再相加并返回，避免 255 + 255 在 u8 阶段溢出。",
        },
    },
    .{
        .id = "04_booleans",
        .chapter = "基础",
        .title = "布尔逻辑",
        .objective = "实现 `allowed(age: u8, has_ticket: bool) bool`：年龄至少 18 且有票时才返回 true。",
        .hints = .{
            "两个条件必须同时成立时用 `and` 组合；只要一个成立就够时用 `or`。",
            "`and` 会短路求值：左侧为 false 时右侧不再计算；`or` 则在左侧为 true 时短路。",
            "本题要求“年龄足够”与“有票”同时为真，检查返回表达式里的运算符是否误写成了 `or`，应改为 `and`。",
        },
    },
    .{
        .id = "05_arrays",
        .chapter = "基础",
        .title = "固定长度数组",
        .objective = "实现 `sum(values: [4]i32) i32`，累加数组中的全部 4 个元素。",
        .hints = .{
            "数组的长度是类型的一部分，`[4]i32` 恰好有 4 个元素，索引从 0 到 3。",
            "`for (values) |value|` 可以直接遍历数组的每个元素，不必自己维护索引。",
            "如果使用索引循环，检查循环的结束条件是否覆盖到最后一个元素（索引 3），不要提前退出。",
        },
    },
    .{
        .id = "06_slices",
        .chapter = "基础",
        .title = "切片求和",
        .objective = "实现 `sum(values: []const i32) i32`，累加切片中的所有元素，空切片返回 0。",
        .hints = .{
            "切片由指针和长度组成，合法索引是 0 到 `len - 1`，空切片没有任何元素。",
            "`for (values) |value|` 会从第 0 个元素开始遍历整个切片。",
            "检查求和循环的起始下标：从 1 开始会漏掉第一个元素，应从 0 开始累加。",
        },
    },
    .{
        .id = "07_strings",
        .chapter = "基础",
        .title = "UTF-8 字符串",
        .objective = "实现 `greeting() []const u8`，返回 UTF-8 字节串 `你好，Zig！`。",
        .hints = .{
            "Zig 的字符串字面量就是 `[]const u8`，按 UTF-8 字节存储，不按“字符”计数。",
            "中文字符和全角标点各占多个字节，但书写字面量时仍然直接写可见字符即可。",
            "逐字对比返回的字面量与题目要求的文本，注意结尾应是全角感叹号「！」，不是半角 `!`。",
        },
    },
    .{
        .id = "08_if",
        .chapter = "控制流",
        .title = "if 表达式",
        .objective = "实现 `max(a: i32, b: i32) i32`，用 if 表达式返回较大值。",
        .hints = .{
            "Zig 的 `if` 是表达式，可以直接产生值并作为 return 的操作数。",
            "`return if (a > b) a else b;` 就是常见写法，条件为真时取第一个分支。",
            "检查比较方向：如果条件写反，返回的会是较小值；应为 `a > b` 时返回 a。",
        },
    },
    .{
        .id = "09_while",
        .chapter = "控制流",
        .title = "while 阶乘",
        .objective = "实现 `factorial(n: u8) u64`，用 while 计算阶乘（题目限定 n ≤ 20）。",
        .hints = .{
            "阶乘是连续乘法，`0!` 定义为 1，所以累乘的初值必须是乘法单位元。",
            "`while (i <= n) : (i += 1)` 可以配合循环体中的 `result *= i;` 完成累乘。",
            "找到累乘变量的初始值：从 0 开始会让整个结果恒为 0，应改为 1，并确认循环覆盖 1 到 n。",
        },
    },
    .{
        .id = "10_for",
        .chapter = "控制流",
        .title = "偶数计数",
        .objective = "实现 `countEven(values: []const i32) usize`，统计切片中偶数（含 0 和负数）的个数。",
        .hints = .{
            "有符号整数判断偶数用 `@mod(value, 2) == 0`，0 和负偶数同样满足。",
            "用 `for (values) |value|` 遍历，配一个 usize 计数器，命中条件时加 1。",
            "检查筛选条件里是否额外要求了 `value > 0`；那样会漏掉 0 与负偶数，应只判断奇偶。",
        },
    },
    .{
        .id = "11_switch",
        .chapter = "控制流",
        .title = "switch 范围分支",
        .objective = "实现 `isDigit(c: u8) bool`，用 switch 的范围分支判断字符是否为十进制数字。",
        .hints = .{
            "`switch` 的分支可以写范围 `'0'...'9'`，表示从字符 '0' 到 '9' 的连续区间。",
            "字符字面量用单引号书写，`'0'` 的字节值是 48，`'9'` 是 57；范围两端都要正确。",
            "检查范围分支的左端：写成 `'1'...'9'` 会把数字 '0' 误判为假，应改为从 '0' 开始。",
        },
    },
    .{
        .id = "12_functions",
        .chapter = "控制流",
        .title = "函数与区间",
        .objective = "实现 `clamp(value: i32, lo: i32, hi: i32) i32`，把值限制在 [lo, hi] 内（题目限定 lo ≤ hi）。",
        .hints = .{
            "`clamp` 需要处理三种情况：低于下限、位于区间内、高于上限。",
            "低于 `lo` 时必须返回下限 `lo`；高于 `hi` 时返回上限 `hi`；否则返回原值。",
            "检查第一个分支返回的变量：把误写的 `hi` 改成 `lo`，再确认比较符号是 `<`。",
        },
    },
    .{
        .id = "13_structs",
        .chapter = "数据建模",
        .title = "结构体方法",
        .objective = "为 `Point` 实现 `squaredLength(self: Point) i32`，返回 x² + y²（坐标绝对值 ≤ 1000）。",
        .hints = .{
            "结构体方法就是首参数为 `self: Point` 的函数，通过 `self.x` 访问字段。",
            "平方长度是坐标各自平方后相加；`self.x * self.x + self.y * self.y` 不会溢出题目给定范围。",
            "检查方法的返回表达式：把坐标直接相加 `self.x + self.y` 是错的，应分别平方。",
        },
    },
    .{
        .id = "14_enums",
        .chapter = "数据建模",
        .title = "枚举映射",
        .objective = "实现 `code(color: Color) u8`，把 red/green/blue 分别映射为 1/2/3。",
        .hints = .{
            "枚举用 `enum { ... }` 声明；对枚举做 `switch` 时必须覆盖每个成员，本题不要用 else 掩盖遗漏。",
            "每个分支只需 `return` 一个 u8 编号，例如 `.red => return 1,`。",
            "对照映射表检查分支：red→1、green→2、blue→3，red 与 blue 的编号很可能写反了。",
        },
    },
    .{
        .id = "15_unions",
        .chapter = "数据建模",
        .title = "带标签联合",
        .objective = "实现 `asInt(value: Value) i32`：整数原样返回，true 返回 1，false 返回 0。",
        .hints = .{
            "`union(enum)` 每个成员带标签，同一时刻只有一个是活动的；用 `switch` 捕获活动成员。",
            "`switch (value) { .integer => |n| ..., .flag => |b| ... }` 会把成员负载绑定到变量。",
            "检查 flag 分支：布尔值本身不是整数，需要分别处理 true 与 false，不能都返回 1。",
        },
    },
    .{
        .id = "16_optionals",
        .chapter = "可选值与错误",
        .title = "可选第一个值",
        .objective = "实现 `first(values: []const i32) ?i32`，返回首个元素，空切片返回 null。",
        .hints = .{
            "可选类型写作 `?i32`，它的值要么是整数，要么是 `null`，表达“可能没有值”。",
            "空切片没有第一个元素，访问前必须先判断 `values.len == 0`。",
            "检查空切片分支：返回 0 表示“存在一个值为 0”，与“没有值”不同，应返回 `null`。",
        },
    },
    .{
        .id = "17_orelse",
        .chapter = "可选值与错误",
        .title = "orelse 兜底",
        .objective = "实现 `orDefault(value: ?i32, fallback: i32) i32`：只有 null 时使用兜底值。",
        .hints = .{
            "`orelse` 只在左侧是 `null` 时求值右侧；非 null 的值会原样得到。",
            "`value orelse fallback` 本身就能完成本题，不需要额外的 if 判断。",
            "检查是否把合法的 0 也替换成了 fallback：0 是有效的 i32，应原样返回。",
        },
    },
    .{
        .id = "18_errors",
        .chapter = "可选值与错误",
        .title = "错误联合",
        .objective = "实现 `divide(a: u32, b: u32) error{DivisionByZero}!u32`，除数为 0 时返回该错误。",
        .hints = .{
            "错误联合的返回类型表示：成功时给 u32，失败时给错误集合中的某个错误。",
            "用 `error.DivisionByZero` 构造错误值，并在除数为 0 的分支用 `return` 返回它。",
            "检查除数为 0 的处理：返回 0 会被当成成功结果，应改为返回错误。",
        },
    },
    .{
        .id = "19_try",
        .chapter = "可选值与错误",
        .title = "try 传播错误",
        .objective = "实现 `parsePairSum(a: []const u8, b: []const u8) std.fmt.ParseIntError!u16`，解析两个 u8 后扩宽求和。",
        .hints = .{
            "`std.fmt.parseInt(u8, text, 10)` 返回 `ParseIntError!u8`，成功值藏在错误联合里。",
            "在返回错误联合的函数中，对可能失败的调用加 `try` 才能取出 u8，失败时自动向上传播。",
            "检查两处 parseInt 调用：缺少 `try` 时得到的是错误联合而不是 u8，后续相加会报类型错误。",
        },
    },
    .{
        .id = "20_catch",
        .chapter = "可选值与错误",
        .title = "catch 兜底",
        .objective = "实现 `parseOrZero(text: []const u8) u8`，解析十进制 u8，任何解析失败都返回 0。",
        .hints = .{
            "`catch` 把错误联合转成普通值：`expr catch fallback`，失败时采用 fallback。",
            "parseInt 的非法字符和溢出都属于错误，都应由同一个兜底值处理。",
            "检查 catch 后面的兜底值：返回 255 会把失败伪装成成功，应改为 0。",
        },
    },
    .{
        .id = "21_pointers",
        .chapter = "指针与所有权",
        .title = "指针解引用",
        .objective = "实现 `increment(value: *i32) void`，把指针指向的值加 1。",
        .hints = .{
            "`value: *i32` 保存的是地址；`value.*` 才表示该地址上的 i32 值。",
            "给指向的值赋值要写 `value.* += 1;`；直接写 `value += 1;` 会试图移动指针本身。",
            "检查自增表达式是否漏掉了 `.*` 解引用。",
        },
    },
    .{
        .id = "22_mutable_slices",
        .chapter = "指针与所有权",
        .title = "原地反转",
        .objective = "实现 `reverse(bytes: []u8) void`，原地反转字节切片，空切片与单元素保持不变。",
        .hints = .{
            "反转需要交换首尾两个元素，然后两个指针向中间靠拢，直到相遇。",
            "常用循环条件是 `while (i < j)`，每次交换 `bytes[i]` 与 `bytes[j]` 后同时移动 i 和 j。",
            "若只在 `i < bytes.len / 2` 内交换 i 与对应位置，奇数长度可用但偶数长度会漏掉中央一对；改用双指针条件。",
        },
    },
    .{
        .id = "23_defer",
        .chapter = "指针与所有权",
        .title = "defer 顺序",
        .objective = "实现 `readThenIncrement(value: *u8) u8`：返回旧值，并用 defer 在返回后完成自增（输入 < 255）。",
        .hints = .{
            "`defer` 语句在离开当前作用域时执行，无论函数从哪里返回。",
            "要返回的是自增前的旧值，因此递增语句必须放在 defer 中，而不是放在 return 之前。",
            "检查语句顺序：先自增会让调用者看到多 1 的值；应写成先保存旧值、注册 defer 递增，再返回旧值。",
        },
    },
    .{
        .id = "24_allocators",
        .chapter = "内存与容器",
        .title = "分配器副本",
        .objective = "实现 `copy(allocator: Allocator, input: []const u8) Allocator.Error![]u8`，返回独立副本。",
        .hints = .{
            "`allocator.alloc(u8, input.len)` 返回可写的 `[]u8`，与只读输入 `[]const u8` 是不同的类型。",
            "分配后要用 `@memcpy(copy, input)` 把字节复制进去；调用者负责在之后 free。",
            "不要直接返回 input：它既是只读类型，也不是本函数分配的内存；应先分配再复制。",
        },
    },
    .{
        .id = "25_arraylist",
        .chapter = "内存与容器",
        .title = "ArrayList 筛选",
        .objective = "实现 `evens(allocator: Allocator, input: []const i32) Allocator.Error![]i32`，保序返回偶数。",
        .hints = .{
            "`std.ArrayList(i32).empty` 创建空列表，`append(allocator, value)` 追加元素，`deinit(allocator)` 释放内部缓冲。",
            "结束时用 `toOwnedSlice(allocator)` 把数据交给调用者，之后不要再 deinit 已交出的列表。",
            "检查筛选条件：偶数应满足 `@mod(value, 2) == 0`，写成 `!= 0` 会收集奇数。",
        },
    },
    .{
        .id = "26_errdefer",
        .chapter = "内存与容器",
        .title = "errdefer 清理",
        .objective = "实现 `makePair`，复制两个字符串；第二次分配失败时必须释放第一次的结果。",
        .hints = .{
            "`errdefer` 只在函数以错误返回时执行，适合注册成对分配的清理动作。",
            "第一个 `dupe` 成功后立刻写 `errdefer allocator.free(first)`，这样后续任何失败都会回收它。",
            "检查第二次 dupe 之前是否缺少释放 first 的 errdefer；成功后不能多释放，失败时也不能泄漏。",
        },
    },
    .{
        .id = "27_hashmap",
        .chapter = "内存与容器",
        .title = "HashMap 去重",
        .objective = "实现 `uniqueCount(allocator: Allocator, words: []const []const u8) Allocator.Error!usize`，统计不重复单词数。",
        .hints = .{
            "`std.StringHashMap(void)` 只关心键是否存在；重复 `put` 同一个键不会增加条目数。",
            "可以先用 `contains` 判断是否为新词，或使用 `getOrPut` 的 `found_existing` 决定是否计数。",
            "检查插入重复词的分支：如果仍递增计数，结果会等于输入项数而不是去重后的数量。",
        },
    },
    .{
        .id = "28_bounds",
        .chapter = "内存与容器",
        .title = "边界检查",
        .objective = "实现 `at(values: []const i32, index: usize) error{OutOfBounds}!i32`，越界时返回错误而不是 panic。",
        .hints = .{
            "合法索引范围是 `0 <= index < values.len`；索引等于长度也已经越界。",
            "访问前先判断越界并 `return error.OutOfBounds`，之后才能安全地取 `values[index]`。",
            "检查判断条件：`index > values.len` 会漏掉 `index == len`，应改为 `index >= values.len`。",
        },
    },
    .{
        .id = "29_comptime",
        .chapter = "编译期与泛型",
        .title = "编译期长度",
        .objective = "实现 `repeat(comptime n: usize, value: u8) [n]u8`，返回由 n 个 value 组成的数组。",
        .hints = .{
            "数组长度必须是编译期已知的常量，`[n]u8` 只有在 n 是 comptime 值时才能成立。",
            "参数写成 `comptime n: usize` 就能让 n 参与类型计算；在函数体内可用循环填充每个元素。",
            "检查 n 参数是否漏掉了 `comptime`：缺少它时返回类型里的 `[n]u8` 无法确定长度。",
        },
    },
    .{
        .id = "30_generics",
        .chapter = "编译期与泛型",
        .title = "泛型最大值",
        .objective = "实现 `max(comptime T: type, a: T, b: T) T`，适用于整数与浮点等数值类型。",
        .hints = .{
            "`comptime T: type` 让函数在每次调用时按实际类型 T 实例化一份。",
            "比较的两个操作数必须同类型；把参数强转成 i32 会让 f64 的调用无法通过编译。",
            "去掉多余的强制转换，直接用 `if (a > b) a else b`，让比较发生在 T 上。",
        },
    },
    .{
        .id = "31_generic_stack",
        .chapter = "编译期与泛型",
        .title = "泛型栈",
        .objective = "实现 `Stack(comptime T: type, comptime capacity: usize) type`：固定容量、后进先出的栈。",
        .hints = .{
            "返回类型的函数写成 `pub fn Stack(comptime T: type, comptime capacity: usize) type { return struct { ... }; }`。",
            "结构体通常保存 `items: [capacity]T` 与 `len: usize`，默认值要能用 `.{}` 初始化。",
            "满栈时 `push` 必须返回 `error.Full` 且不改动已有元素；检查是否在满时覆盖了最后一个元素还返回成功。",
        },
    },
    .{
        .id = "32_bits",
        .chapter = "数据处理",
        .title = "位设置",
        .objective = "实现 `setBit(value: u8, bit: u3) u8`，把第 bit 位置 1 并保留其他位。",
        .hints = .{
            "置位需要构造一个只有第 bit 位为 1 的掩码，再用按位或合并到原值。",
            "掩码是 `1 << bit`；bit 是 u3，移位前可写 `@as(u8, 1) << bit` 让类型明确。",
            "检查移位的位数：`bit / 2` 会指向错误的位，应直接移动 `bit` 位。",
        },
    },
    .{
        .id = "33_endian",
        .chapter = "数据处理",
        .title = "小端解码",
        .objective = "实现 `decodeLittle(bytes: []const u8) error{InvalidLength}!u32`，恰好 4 字节时按小端解码。",
        .hints = .{
            "小端表示最低有效字节位于最低地址：`bytes[0]` 是 u32 的最低 8 位。",
            "可以用 `std.mem.readInt(u32, bytes[0..4], .little)`，也可以手工移位相加。",
            "检查解码顺序：把首个字节放到最高 8 位属于大端，应让 `bytes[0]` 位于最低位。",
        },
    },
    .{
        .id = "34_json",
        .chapter = "数据处理",
        .title = "JSON 配置",
        .objective = "实现 `parse`，解析 JSON 配置，并让结果拥有字符串内存，输入缓冲被修改后仍有效。",
        .hints = .{
            "`std.json.parseFromSlice(Config, allocator, text, options)` 返回需要 `deinit()` 的 `Parsed(Config)`。",
            "默认 `.alloc_if_needed` 可能让结果借用输入缓冲区，输入变化后字符串可能随之变化。",
            "在 options 中设置 `.allocate = .alloc_always`，让字符串归 Parsed 所有，并在用完后 deinit。",
        },
    },
    .{
        .id = "35_csv",
        .chapter = "综合练习",
        .title = "CSV 求和",
        .objective = "实现 `sumCsv`，对逗号分隔的无符号整数求和，空项与非法字符都要报错。",
        .hints = .{
            "`std.mem.splitScalar(u8, text, ',')` 会保留连续分隔符产生的空项，便于识别非法输入。",
            "每一项先 trim 空格、制表、回车和换行，再用 `parseInt(u32, item, 10)` 解析；空项直接返回 InvalidCharacter。",
            "不要用 `tokenize`：它跳过空项，会让 `\"1,,2\"` 悄悄通过；应显式判空并检查非法字符与溢出。",
        },
    },
    .{
        .id = "36_statistics",
        .chapter = "综合练习",
        .title = "统计汇总",
        .objective = "实现 `summarize`，逐行解析有符号整数，统计数量、总和、最小值与最大值。",
        .hints = .{
            "用 `std.mem.splitScalar(u8, text, '\\n')` 逐行处理，trim 后跳过空行。",
            "最小值与最大值用 `?i32` 表示“还没有数据”，空输入时保持 null，避免用 0 当哨兵。",
            "第一个有效值应同时初始化 min 与 max；检查代码是否把 min 初始化为 0，那会让全正数数据的最小值出错。",
        },
    },
};
