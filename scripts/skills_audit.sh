#!/usr/bin/env bash
# skills-doctor v1.0 — 技能目录体检（只读，不改任何文件）
# 用法: bash skills_audit.sh
# 兼容 macOS 自带 bash 3.2（不使用关联数组）

set -uo pipefail

DIRS=".agents .zcode .claude .codex .workbuddy .codebuddy .cc-switch .opencode .gemini .iflow .trae .qwen"
CENTER="$HOME/.agents/skills"

sec() { printf "\n== %s ==\n" "$1"; }

sec "0 环境"
for d in $DIRS; do [ -d "$HOME/$d/skills" ] && echo "  [存在] ~/$d/skills"; done
if [ -d "$CENTER" ]; then
  n=$(ls -d "$CENTER"/*/ 2>/dev/null | wc -l | tr -d ' ')
  echo "  [中心] $CENTER （$n 个条目）"
else
  echo "  [提示] 中心目录 $CENTER 不存在（首次归一会创建）"
fi

sec "1 断链"
broken=0
for d in $DIRS; do
  sd="$HOME/$d/skills"; [ -d "$sd" ] || continue
  for l in "$sd"/*; do
    [ -L "$l" ] || continue
    [ -e "$l" ] || { echo "  断链: $l -> $(readlink "$l")"; broken=$((broken+1)); }
  done
done
[ $broken -eq 0 ] && echo "  无断链 ✓"

sec "2 同名实体副本（跨目录同名、且都是真实目录）"
allnames=$(for d in $DIRS; do
  sd="$HOME/$d/skills"; [ -d "$sd" ] || continue
  ls -d "$sd"/*/ 2>/dev/null
done | while :; do read -r x; [ -n "$x" ] || break; basename "${x%/}"; done | sort -u)
dups=0
for n in $allnames; do
  where=""
  for d in $DIRS; do
    p="$HOME/$d/skills/$n"
    [ -d "$p" ] && [ ! -L "$p" ] && where="$where $d"
  done
  w=$(echo $where | wc -w | tr -d ' ')
  if [ "$w" -gt 1 ]; then echo "  $n:$where"; dups=$((dups+1)); fi
done
[ $dups -eq 0 ] && echo "  无同名实体副本 ✓"

sec "3 嵌套技能（第二层及更深，任何工具都发现不了）"
nested=0
for d in $DIRS; do
  sd="$HOME/$d/skills"; [ -d "$sd" ] || continue
  for f in $(find "$sd" -mindepth 3 -maxdepth 3 -name SKILL.md 2>/dev/null); do
    echo "  ${f%/SKILL.md}"
    nested=$((nested+1))
  done
done
[ $nested -eq 0 ] && echo "  无嵌套技能 ✓"

sec "4 顶层无 SKILL.md 的目录（配套目录或半成品，需人工判断身份）"
for d in $DIRS; do
  sd="$HOME/$d/skills"; [ -d "$sd" ] || continue
  for e in "$sd"/*/; do
    p="${e%/}"
    [ -L "$p" ] && continue
    [ -d "$p" ] || continue
    [ -f "$p/SKILL.md" ] || echo "  $p"
  done
done

sec "5 硬编码绝对路径（技能内引用 \$HOME 路径，迁移易断，需人工复核）"
cnt=0
for d in $DIRS; do
  sd="$HOME/$d/skills"; [ -d "$sd" ] || continue
  for e in "$sd"/*/; do
    p="${e%/}"
    [ -L "$p" ] && continue
    [ -d "$p" ] || continue
    hits=$(grep -rIl -- "$HOME/" "$p" 2>/dev/null | grep -v '__pycache__\|\.git/\|node_modules/' | head -3)
    [ -n "$hits" ] && { echo "  [$(basename "$p")]"; echo "$hits" | sed 's/^/    /'; cnt=$((cnt+1)); }
  done
done
[ $cnt -eq 0 ] && echo "  未发现 ✓"

sec "6 汇总"
echo "  断链 $broken ｜ 同名实体副本 $dups ｜ 嵌套技能 $nested"
echo "  （本脚本只读；修复动作由 Agent 在你确认后执行）"
