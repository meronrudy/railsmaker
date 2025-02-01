module SeoHelper
  def meta_title(title = nil)
    content_for(:title) { title } if title.present?
    content_for?(:title) ? content_for(:title) : "RailsMaker - Ship Rails Apps in 15 Minutes"
  end

  def meta_description(desc = nil)
    content_for(:description) { desc } if desc.present?
    content_for?(:description) ? content_for(:description) : "A fully self-hosted modern Rails template with authentication, analytics and observability. Ship production-ready apps in minutes, not weeks."
  end

  def meta_image(image = nil)
    content_for(:og_image) { image } if image.present?
    content_for?(:og_image) ? content_for(:og_image) : asset_url("og-image.webp")
  end

  def meta_tags
    {
      title: meta_title,
      description: meta_description,
      image: meta_image,
      canonical: request.original_url,
      author: "RailsMaker",
      robots: "index, follow",
      type: "website"
    }
  end
end
