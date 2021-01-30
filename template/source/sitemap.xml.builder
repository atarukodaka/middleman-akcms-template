---
layout: false
---
xml.instruct!
xml.urlset 'xmlns' => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  sitemap.resources.select { |page| page.path =~ /\.html/ }.each do |page|
    next if page.data.exclude_from_sitemap
    xml.url do
      xml.loc "#{data.config.site_info.url}#{page.path}"
      lastmod = page.data.modify_date.presence || page.data.date.presence
      xml.lastmod lastmod if lastmod.present?
      xml.changefreq page.data.changefreq || "monthly"
      xml.priority page.data.priority || "0.5"
    end
  end
end