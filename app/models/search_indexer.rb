class SearchIndexer
  def initialize(guide)
    @guide = guide
    @edition = guide.latest_edition
  end

  def index
    index = Rummageable::Index.new(
      Plek.current.find('rummager'), '/mainstream'
    )
    index.add_batch([{
      "format":            "service_manual_guide",
      "_type":             "service_manual_guide",
      "description":       @edition.description,
      "indexable_content": @edition.body,
      "title":             @edition.title,
      "link":              @guide.slug,
      "manual":            "service-manual",
      "organisations":     ["government-digital-service"],
    }])
  end
end
