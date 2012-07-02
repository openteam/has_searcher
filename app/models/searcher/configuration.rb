class Configuration
  attr_accessor :searcher, :scopes

  attr_accessor :keywords_field, :properties, :facets

  def initialize(searcher, &block)
    self.searcher = searcher
    self.scopes = {}
    self.properties = {}
    self.facets = {}
    instance_eval &block if block
    scope do |sunspot|
      sunspot.fulltext searcher.params[searcher.configuration.keywords_field]
      searcher.configuration.properties.each do |property, options|
        if modificator = options[:modificator]
          request_field = "#{property}_#{modificator}".to_sym
          sunspot.with(property).send(modificator, searcher.params[request_field]) if searcher.params[request_field].presence
        end
      end
    end
  end

  def keywords(field)
    self.keywords_field = field
  end

  def property(field, options={})
    self.properties[field] = options
  end

  def facet(name, &block)
    self.facets[name] = block
  end

  def scope(name=:scoped, &block)
    self.scopes[name] ||= []
    self.scopes[name] << block
  end
end
