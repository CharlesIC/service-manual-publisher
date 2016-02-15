class TopicSearchIndexer
  def initialize(topic)
    @topic = topic
  end

  def index
    rummager_index.add_batch([{
      "_type":             "edition",
      "description":       @topic.description,
      "indexable_content": @topic.title + "\n\n" + @topic.description,
      "title":             @topic.title,
      "link":              @topic.path,
      "organisations":     ["government-digital-service"],
    }])
  end

  private

    def rummager_index
      Rummageable::Index.new(
        Plek.current.find('rummager'), '/service-manual'
      )
    end
end
