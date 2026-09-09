# nav_tree.rb — 按仓库目录结构生成侧栏导航树（写入 site.data.nav_tree）
# 不转换页面、不触碰内容；只遍历 .md 文件与子目录。
SKIP_DIRS = %w[assets].freeze

def build_nav(src, rel)
  abs = File.join(src, rel)
  list = []
  Dir.children(abs).sort.each do |name|
    next if name.start_with?('.')
    p = File.join(abs, name)
    if File.directory?(p)
      next if SKIP_DIRS.include?(name)
      sub = build_nav(src, File.join(rel, name))
      has_index = File.exist?(File.join(p, 'index.md'))
      next if sub.empty? && !has_index
      url = has_index ? '/' + File.join(rel, name, 'index.md') : nil
      list << { 't' => name, 'u' => url, 'c' => sub }
    elsif name =~ /\.(md|markdown)$/i
      next if name == 'index.md'
      list << { 't' => name.sub(/\.(md|markdown)$/i, ''), 'u' => '/' + File.join(rel, name) }
    end
  end
  list
end

Jekyll::Hooks.register :site, :post_read do |site|
  src = site.source
  roots = []
  %w[ChatWiki BotReports].each do |top|
    next unless Dir.exist?(File.join(src, top))
    url = File.exist?(File.join(src, top, 'index.md')) ? "/#{top}/index.md" : nil
    roots << { 't' => top, 'u' => url, 'c' => build_nav(src, top) }
  end
  roots += build_nav(src, 'Notes') # 每个主题目录直接作为顶层项
  site.data['nav_tree'] = roots
end
