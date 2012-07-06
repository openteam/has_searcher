class Searcher::Configuration
  attr_accessor :searcher, :scopes

  attr_accessor :facets

  attr_writer :models

  delegate :search_object, :to => :searcher

  def initialize(searcher, &block)
    self.searcher = searcher
    self.scopes = {}
    self.facets = {}
    self.models = []
    scope :runtime
    scope :default
    instance_eval &block if block
  end

  def keywords(field, options={})
    search_object.create_field(field, options)
    scope do |sunspot|
      sunspot.fulltext search_object.send(field) if search_object.send(field).presence
    end
  end

  def models(*names_or_clases)
    self.models = [*names_or_clases]
  end

  def search_models
    @search_models ||= @models.map do |name_or_class|
      name_or_class.is_a?(Class) ? name_or_class : name_or_class.to_s.classify.constantize
    end
  end

  def property(field, options={}, &block)
    modificators = [*options[:modificator]] + [*options[:modificators]]

    modificators.each do |modificator|

      request_field = [field, modificator].compact.join('_')

      search_object.create_field(request_field, options)

      if block
        scope &block
      else
        scope do |sunspot|
          sunspot.with(field).send(modificator, search_object.send(request_field)) if search_object.send(request_field).presence
        end
      end
    end

    if modificators.empty?
      search_object.create_field(field, options)
      if block
        scope &block
      else
        scope do |sunspot|
          sunspot.with(field, search_object.send(field)) if search_object.send(field).presence
        end
      end
    end
  end

  def facet(name, &block)
    facets[name] = block
  end

  def scope(name=:default, &block)
    scopes[name] ||= []
    scopes[name] << block if block
    searcher
  end
end
