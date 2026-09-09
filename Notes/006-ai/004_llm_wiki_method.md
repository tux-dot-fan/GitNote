---
title: LLM Wiki 方法论（Karpathy 模式）
date: 2026-09-08
tags: [chat, ai, llm, rag, knowledge-base, mcp]
source: Karpathy gist + nashsu/llm_wiki 仓库（2026-09-08 查证）
---

# LLM Wiki：让 LLM 维护你的知识库

> 一句话：**别让 LLM 每次"现查现答"（RAG），而是让 LLM 把你的资料"编译"成一个持续维护、互相链接的 Wiki**。知识只编译一次并长期保鲜，而不是每次查询重新推导。

## 起源

Andrej Karpathy 的设计模式文档 [llm-wiki.md (gist)](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)，是一个抽象"模式"；`nashsu/llm_wiki`（17.5k★，活跃）把它做成了具体桌面应用。

## 核心结构（三层）

1. **Raw Sources**（原始资料）—— 只读、不可变，如文档、网页、**聊天记录**
2. **Wiki**（LLM 生成的页面）—— 从 Raw 提炼、互相链接、增量维护
3. **Schema**（规则/配置）—— 告诉 LLM 页面该怎么写、如何组织

## 核心操作

| 操作 | 作用 |
|---|---|
| **Ingest** | 新资料进来 → LLM 分析 → 生成/更新 wiki 页面（增量缓存） |
| **Query** | 查询时用已编译的 wiki（+必要时溯源原始资料），不是从头检索 |
| **Lint** | 周期性检查/维护：冗余、过期、断链 |

## 关键约定

- `index.md` = 内容目录，也是 LLM 的导航入口
- `log.md` = 时序操作记录（可解析格式）
- `[[wikilink]]` 交叉引用 + 每页 YAML frontmatter
- **Obsidian 兼容**：wiki 目录就是一个 Obsidian vault
- 分工：**人策展（放哪、留不留），LLM 维护（写、整理、链接）**

## 与 RAG 对比

| | 传统 RAG | LLM Wiki |
|---|---|---|
| 每次查询 | 重新检索+拼上下文+生成 | 直接查已建好的 wiki |
| 知识形态 | 碎片化召回 | 结构化、互链的页面 |
| 成本 | 每次重复 | 摄入一次，长期摊销 |
| 代价 | — | 需要持续维护（Lint） |

## 具体实现：nashsu/llm_wiki

- 跨平台桌面应用（Linux 有 .deb/AppImage；v0.6.11）
- 特性亮点：两步链式摄入、图文 PDF、Rust 后端**聊天 Agent**（工具调用）、**知识图谱**（Louvain 社区发现、4 信号相关度）、LanceDB 向量搜索、Deep Research、Chrome 剪藏、本地 HTTP API + **MCP Server** + agent skill
- 模型可配：Chat / Ingest 独立路由，任意 OpenAI 兼容端点

## 易混淆概念

- **llms.txt / llmstxt.org**：网站给 LLM 提供 Markdown 清单的规范 —— 不是这个
- **llmwiki.com**：LLM 工具/案例目录网站 —— 也不是这个

## 在本 vault 的落地

这套笔记库用 ChatWiki 控制层实践该模式：`ChatWiki/schema.md` 即 Schema 层、`ChatWiki/raw/` 即 Raw Sources（会话快照，append-only）、知识页进 `Notes/` 主题区。见 [[schema]]。

## 相关

- [[005_Agentic_workflow]]：Agent 与工具调用（MCP server 属于该话题）
- [[001_AI_basic_concepts]]：RAG 等基础概念
