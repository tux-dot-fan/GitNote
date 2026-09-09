"""自动给标题编号（页内标题 + 右侧 TOC 同步带号）。

规则：
- h1 视为页标题，不加号；从 h2 开始编 "1 / 1.1 / 1.1.1"
- 已有手工编号（如 "1.1 引言"）的标题跳过，避免重复
- 代码围栏 / 缩进代码里的 "#" 不处理
"""
import re

SKIP_RE = re.compile(r'^\s{0,3}#+\s*(\d+(?:[.．]\d+)*)\s*[)、.:：-]?\s')
HEAD_RE = re.compile(r'^(\s{0,3})(#{2,6})\s+(.*\S.*)$')


def on_page_markdown(markdown, page, config, files):
    out = []
    fence = None
    counters = [0] * 7

    for line in markdown.split('\n'):
        stripped = line.strip()

        # 代码围栏状态
        if fence:
            out.append(line)
            if stripped.startswith(fence):
                fence = None
            continue
        fm = re.match(r'^(```+|~~~+)\s*\S*$', stripped)
        if fm:
            fence = fm.group(1)
            out.append(line)
            continue
        # 缩进代码块 / 空行原样保留
        if not stripped or line.startswith(('    ', '\t')):
            out.append(line)
            continue

        m = HEAD_RE.match(line)
        if m and not SKIP_RE.match(line):
            level = len(m.group(2))
            # 遇到更浅的标题时，深层计数清零
            for d in range(level + 1, 7):
                counters[d] = 0
            counters[level] += 1
            parts = [str(counters[d]) for d in range(2, level + 1)]
            # 文档若直接从 h3 开始，去掉前导 0
            while parts and parts[0] == '0':
                parts.pop(0)
            if parts:
                line = f'{m.group(1)}{m.group(2)} {".".join(parts)} {m.group(3)}'
        out.append(line)

    return '\n'.join(out)
