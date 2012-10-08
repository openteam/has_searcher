require "has_searcher/engine"

module HasSearcher
  @@searchers = {}
  def self.create_searcher(name, &block)
    @@searchers[name] = block
  end

  def self.searcher(name, params={})
    (Searcher.new &@@searchers[name]).tap do |searcher|
      searcher.search_object.attributes = params
    end
  end

  def self.cacheable_now
    1.minute.since.change(:sec => 0)
  end
end
