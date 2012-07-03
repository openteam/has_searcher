class Searcher::Configuration
  attr_accessor :searcher, :scopes

  attr_accessor :properties, :facets

  attr_accessor :search_object_methods

  def initialize(searcher, &block)
    self.searcher = searcher
    self.scopes = {}
    self.properties = {}
    self.facets = {}
    self.search_object_methods = Module.new
    instance_eval &block if block
  end

  def keywords(field)
    add_method_to_search_object(field)
    scope do |sunspot|
      sunspot.fulltext searcher.search_object.send(field) if searcher.search_object.send(field).presence
    end
  end

  def property(field, options={})
    self.properties[field] = options

    modificator = options[:modificator]
    request_field = [field, modificator].compact.join('_')

    add_method_to_search_object(request_field)

    scope do |sunspot|
      if searcher.search_object.send(request_field).presence
        if modificator
          sunspot.with(field).send(modificator, searcher.search_object.send(request_field))
        else
          sunspot.with(field, searcher.search_object.send(request_field))
        end
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

  private

    def add_method_to_search_object(request_field)
      search_object_methods.class_eval do
        define_method "#{request_field}" do
          instance_variable_get("@#{request_field}")
        end
        define_method "#{request_field}=" do |value|
          instance_variable_set("@#{request_field}", value)
        end
      end
    end
end
