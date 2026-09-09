# plain_md_pages.rb — 无 frontmatter 的 .md 也生成 HTML 页面（默认 layout）
# 保护：
#   1) 超大文件(>1.5MB)、含 "{%" 模板语法、非 UTF-8 文件 -> 保持静态 .md
#   2) 转换前用 Timeout 试渲染，kramdown 会卡死的文件(如病态下划线列表) -> 跳过
# 调试开关：ENV['PLAIN_ONLY']="a,b" 只转换匹配前缀目录
require 'timeout'
begin
  require 'kramdown'
rescue LoadError
end

MAX_MD_SIZE = 1_500_000
LIQUID_MARK = '{%'
only = (ENV['PLAIN_ONLY'] || '').split(',').reject(&:empty?)

def utf8?(path)
  File.open(path, 'rb') { |io| io.read.force_encoding(Encoding::UTF_8).valid_encoding? }
rescue StandardError
  false
end

Jekyll::Hooks.register :site, :post_read do |site|
  site.static_files.select { |f|
    f.path =~ /\.(md|markdown)$/i &&
      !Jekyll::Utils.has_yaml_header?(f.path) &&
      File.size(f.path) <= MAX_MD_SIZE &&
      utf8?(f.path) &&
      !(File.read(f.path, 600) || '').include?(LIQUID_MARK)
  }.each do |sf|
    rel = sf.path.sub(%r{^#{Regexp.escape(site.source)}/}, '')
    next unless only.empty? || only.any? { |p| rel.start_with?(p) }
    begin
      content = File.read(sf.path, encoding: 'UTF-8')
      Timeout.timeout(5) { Kramdown::Document.new(content, input: 'GFM').to_html }
    rescue Timeout::Error
      Jekyll.logger.info 'Skipping (slow markdown):', rel
      next
    rescue StandardError
      next
    end
    dir = File.dirname(rel); dir = '' if dir == '.'
    page = Jekyll::Page.new(site, site.source, dir, File.basename(sf.path))
    site.pages << page
    site.static_files.delete(sf)
  end
end
