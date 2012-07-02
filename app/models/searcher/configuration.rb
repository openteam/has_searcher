class Searcher::Configuration
  attr_accessor :searcher, :scopes

  attr_accessor :keywords_field, :properties, :facets

  attr_accessor :search_object_methods

  def initialize(searcher, &block)
    self.searcher = searcher
    self.scopes = {}
    self.properties = {}
    self.facets = {}
    self.search_object_methods = Module.new
    instance_eval &block if block
    scope do |sunspot|
      sunspot.fulltext searcher.params[searcher.configuration.keywords_field]
      searcher.configuration.properties.each do |property, options|
        if modificator = options[:modificator]
          request_field = "#{property}_#{modificator}".to_sym
          sunspot.with(property).send(modificator, searcher.search_object.send(request_field)) if searcher.search_object.send(request_field).presence
        end
      end
    end
  end

  def keywords(field)
    self.keywords_field = field
    property field
  end

  def property(field, options={})
    self.properties[field] = options
    field = [field, options[:modificator]].compact.join('_')
    search_object_methods.class_eval do
      define_method "#{field}" do
        instance_variable_get("@#{field}")
      end
      define_method "#{field}=" do |value|
        instance_variable_set("@#{field}", value)
      end
    end
  end

  def facet(name, &block)
    self.facets[name] = block
  end

  def scope(name=:default, &block)
    self.scopes[name] ||= []
    self.scopes[name] << block
  end

end
