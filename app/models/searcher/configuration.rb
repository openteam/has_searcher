class Searcher::Configuration
  attr_accessor :searcher, :scopes

  attr_accessor :properties, :facets

  attr_accessor :search_object_methods

  delegate :search_object, :to => :searcher

  def initialize(searcher, &block)
    self.searcher = searcher
    self.scopes = {}
    self.properties = {}
    self.facets = {}
    instance_eval &block if block
  end

  def keywords(field)
    search_object.create_field(field)
    scope do |sunspot|
      sunspot.fulltext search_object.send(field) if search_object.send(field).presence
    end
  end

  def property(field, options={})
    self.properties[field] = options

    modificator = options[:modificator]
    request_field = [field, modificator].compact.join('_')

    search_object.create_field(request_field)

    scope do |sunspot|
      if search_object.send(request_field).presence
        if modificator
          sunspot.with(field).send(modificator, search_object.send(request_field))
        else
          sunspot.with(field, search_object.send(request_field))
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

end
