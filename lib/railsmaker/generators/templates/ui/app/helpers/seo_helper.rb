module SeoHelper
  def meta_title(title = nil)
    content_for(:title) { title } if title.present?
    content_for?(:title) ? content_for(:title) : 'RailsMaker - Ship Rails Apps in 15 Minutes'
  end

  def meta_description(desc = nil)
    content_for(:description) { desc } if desc.present?
    content_for?(:description) ? content_for(:description) : 'A fully self-hosted modern Rails template with authentication, analytics and observability. Ship production-ready apps in minutes, not weeks.'
  end

  def meta_image(image = nil)
    content_for(:og_image) { image } if image.present?
    content_for?(:og_image) ? content_for(:og_image) : asset_url('og-image.webp')
  end

  def meta_keywords(keywords = nil)
    content_for(:keywords) { keywords } if keywords.present?
    content_for?(:keywords) ? content_for(:keywords) : 'rails 8, ruby on rails, daisyui, tailwind, web development, starter template, template'
  end

  def meta_tags
    {
      title: meta_title,
      description: meta_description,
      image: meta_image,
      keywords: meta_keywords,
      canonical: request.original_url,
      author: 'RailsMaker',
      robots: 'index, follow',
      type: 'website',
      twitter_card: 'summary_large_image',
      twitter_site: '@sgerov',
      og_site_name: 'RailsMaker',
      article_published_time: Time.current.iso8601,
      article_modified_time: Time.current.iso8601
    }
  end
end
