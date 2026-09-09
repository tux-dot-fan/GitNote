---
title: ChatWiki 运作规则（Schema）
date: 2026-09-08
tags: [chat-wiki, meta, schema]
---

# 这是什么

把**与 AI 助手对话中学到的东西**，增量沉淀为 vault 里相互链接、可长期维护的笔记。
方法论源自 Karpathy 的 LLM-wiki 模式（见 [[004_llm_wiki_method]]）：

- **人策展（放哪、要不要），LLM 维护（生成、整理、链接）**
- 知识只编译一次并持续维护，而不是每次对话后重新推导

# 目录结构（三层）

| 层 | 位置 | 职责 |
|---|---|---|
| Raw Sources（只读） | `ChatWiki/raw/` | 每次对话的原始要点快照，**append-only，事后不改** |
| Schema（规则） | `ChatWiki/schema.md` | 本文件：页面格式、流程、lint 清单 |
| Wiki 页面 | `Notes/NNN-主题/…` | 真正的知识页，按主题归入现有笔记区 |
| 目录/日志 | `ChatWiki/index.md`、`ChatWiki/log.md` | 页面索引 + 每次 ingest 的操作记录 |

# 页面规范（所有 ChatWiki 生成的笔记遵守）

每个知识页带 YAML frontmatter：

```yaml
---
title: 一句话标题
date: YYYY-MM-DD
tags: [chat, <主题标签>]
source: <会话日期/链接/作者>
---
```

命名与放置：

- 先想清楚属于哪个主题区（003-linux、006-ai …），放进去，别在 ChatWiki 里堆页面
- 用 `[[wikilink]]` 关联既有笔记；页面间互相发现靠链接，不靠文件夹
- 中文为主，命令/术语保留原文
- 内容要有"可查性"：结论 + 出处/命令 + 为什么

# Ingest 流程（每次对话后执行）

1. **Snapshot**：把本次会话学到的点写入 `ChatWiki/raw/YYYY-MM-DD-主题.md`
2. **Extract**：按主题提炼成笔记，放进 `Notes/` 对应目录（新知识建新页，增量知识追加进已有页）
3. **Index**：更新 `ChatWiki/index.md`（页面、主题、位置）
4. **Log**：向 `ChatWiki/log.md` 追加一条记录（日期/会话/产出/落点）
5. **Lint**：检查链接有效、无重复主题、frontmatter 完整

# Lint 清单

- [ ] 新页面不是已有页的重复（先 grep 主题词）
- [ ] frontmatter 齐全（title/date/tags/source）
- [ ] 至少一个 `[[wikilink]]` 指向既有笔记
- [ ] `raw/` 快照未被修改（append-only）
- [ ] `ChatWiki/index.md` 与 `log.md` 已同步
