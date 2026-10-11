# 五层验收清单

每次变更完成后逐层走完，全部通过才算完成。

## 第 1 层 · 链接层

```bash
for d in .agents .zcode .claude .codex .workbuddy .codebuddy .cc-switch; do
  for l in ~/$d/skills/*; do [ -L "$l" ] && [ ! -e "$l" ] && echo "断链: $l -> $(readlink "$l")"; done
done
```

通过标准：零断链。发现的死链要么删除（目标已不存在），要么改指（目标被移动）。

## 第 2 层 · 发现层

模拟每个**实际已安装**工具的视角：其 skills 目录下每个条目（实体或链接）的 `SKILL.md` 可达。注意：

- 没装的工具跳过；用户没提的工具目录可顺带检查
- 无 SKILL.md 的目录不是技能（工作区、密钥库、npm 包），不算失败，但要向用户说明身份

## 第 3 层 · 内容层

```bash
grep -rl '旧路径关键字' ~/.agents/skills ~/.claude/skills ~/.codex/skills 2>/dev/null
```

通过标准：活文件零残留。历史会话日志（sessions/、rollout、traces）不算活文件，可豁免。

## 第 4 层 · 功能层

对迁移过、修过路径的关键技能做运行时实测，按技能类型选最轻的一种：

- CLI 类：`--help` 或 `--dry-run`（验证凭据识别、参数链路，不真跑）
- Python 模块类：`importlib` 加载 + 检查 `.env` 路径解析
- 纯文档类：引用的脚本、资产文件存在性检查

实测案例：image-gen `--dry-run` 确认 OPENAI_API_KEY 识别与 endpoint 正常；transcribe.py 加载后确认能从新路径读到 SILICONFLOW_API_KEY。

## 第 5 层 · 盲点层

容易漏的机制逐个扫：

- 其他工具的**记忆文件**（`~/.codex/memories/` 等）里的旧路径
- 技能商店/云同步元数据（如 `_skillhub_meta.json` 里的 iconLocalPath）
- 工具侧的技能清单文件（SKILLS-LIST.md、inventory.csv）
- 指向**项目目录**的软链接：项目一挪就断，建议真身进中心或随项目走

## 汇报格式

完成后输出前后对比：断链数、副本对数、真身位置、修复的路径数。有未处理项就明说原因，不假装完成。
