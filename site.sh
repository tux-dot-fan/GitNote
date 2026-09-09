#!/usr/bin/env bash
# GitNote 站点工具（MkDocs Material）
# 用法:
#   ./site.sh build    静态构建到 mkdocs_site/
#   ./site.sh serve    开发预览 http://127.0.0.1:8000 （改笔记自动刷新）
#   ./site.sh preview  构建后用静态服务器预览 http://127.0.0.1:8000
#   ./site.sh publish  构建并推送到 gh-pages 分支（需已安装 ghp-import）
set -euo pipefail
cd "$(dirname "$0")"
VENV="$PWD/.mkdocs-venv/bin"
if [ ! -x "$VENV/mkdocs" ]; then
  echo "未找到 $VENV/mkdocs，请先执行: python3 -m venv .mkdocs-venv && .mkdocs-venv/bin/pip install mkdocs-material mkdocs-awesome-pages-plugin"
  exit 1
fi

case "${1:-build}" in
  build)
    "$VENV/mkdocs" build
    ;;
  serve)
    exec "$VENV/mkdocs" serve -a 127.0.0.1:8000
    ;;
  preview)
    "$VENV/mkdocs" build
    exec python3 -m http.server 8000 --directory mkdocs_site
    ;;
  publish)
    "$VENV/mkdocs" build
    if ! python3 -c "import ghp_import" 2>/dev/null; then
      echo "缺少 ghp-import，先执行: $VENV/pip install ghp-import"
      exit 1
    fi
    exec python3 -m ghp_import -p -f mkdocs_site
    ;;
  *)
    echo "未知参数: $1（支持 build/serve/preview/publish）"; exit 1
    ;;
esac
