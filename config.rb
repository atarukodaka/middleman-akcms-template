###
# Page options, layouts, aliases and proxies
###

# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# General configuration
set :layout, "layout"

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

# akcms settings
activate :akcms do |akcms|
  akcms.layout = "article"

  akcms.directory_summary_template = "templates/directory_summary_template.html"
  akcms.archive_month_template = "templates/archive_template.html"
  akcms.archive_month_link = 'archives/%<year>04d-%<month>02d.html'
  akcms.tag_template = "templates/tag_template.html"
  akcms.pagination_per_page = 10
  akcms.series_title_template = "%{name} [%{number}]: %{article_title}" 
end

## other extensions
activate :syntax

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :autolink => true,
  :smartypants => true, :tables => true, :with_toc_data => true

