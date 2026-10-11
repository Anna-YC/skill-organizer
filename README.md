# skills-doctor — 技能目录体检与归一

一个可安装的 Agent 技能：让 AI 帮你把散落在各工具目录的 skills 收敛成**真身唯一、软链接桥接**的架构，支持断链检测、同名副本去重、嵌套技能发现、硬编码路径修复。

**首次运行只读体检**，任何修改都先给清单、经你确认。

## 安装（一条命令）

```bash
git clone --depth 1 https://github.com/Anna-YC/skills-doctor ~/.agents/skills/skills-doctor
```

- **ZCode**：装完即用（原生读 `~/.agents/skills`）
- **Claude Code / Codex 等其他工具**：补一条软链接桥接，例如：

```bash
ln -s ~/.agents/skills/skills-doctor ~/.claude/skills/skills-doctor
```

## 使用

对 Agent 说任意一句：

- 「帮我体检一下技能目录」
- 「运行 skills-doctor，看看我的 skills 有没有问题」
- 「把这些工具里的技能去重、整理到 .agents」

Agent 会先跑只读脚本出报告，你确认方案后才执行修复。

## 里面有什么

```
skills-doctor/
├── SKILL.md                        # 主流程：体检 → 报告 → 确认 → 执行 → 五层验收
├── scripts/skills_audit.sh         # 只读体检脚本（兼容 macOS 自带 bash 3.2）
└── references/
    ├── methodology.md              # 方法论全文（为什么这样做）
    ├── migration-playbook.md       # 迁移/去重 SOP（怎么做的细节与坑）
    └── audit-checklist.md          # 五层验收清单（怎么算做完）
```

## 安全边界

- 脚本只读，不改任何文件
- 所有 mv / rm / rsync 均需你逐项确认
- 拿不准的技能进 `skills.disabled/` 存档区，不做删除
- 合并时自动保护 `.env` 密钥、`.git` 历史、生成产物

## 方法论一句话

真身唯一 · 链接桥接 · 分类安置 · 就近覆盖 · 迁移体检 · 五层验收

## License

MIT
