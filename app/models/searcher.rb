class Searcher
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

  attr_accessor :models, :params, :configuration, :sunspot
  attr_accessor :scope_chain

  def initialize(model_names_or_classes, &block)
    self.models = model_names_or_classes
    self.params = {}
    self.scope_chain = [:scoped]
    self.configure(&block)
  end

  def models=(names_or_clases)
    @models = [names_or_clases].map do |name_or_class|
      name_or_class.is_a?(Class) ? name_or_class : name_or_class.to_s.classify.constantize
    end
  end

  def configure(&block)
    self.configuration = Configuration.new(self, &block)
  end

  def sunspot
    @sunspot ||= Sunspot.new_search models
  end

  def all
    execute
    sunspot.results
  end

  def execute
    build_query
    set_facets
    sunspot.execute
  end

  def search(params)
    self.params = params
    all
  end

  delegate :inspect, :to => :all

  def method_missing(name, *args, &block)
    if configuration.scopes.include?(name)
      scope_chain << name
      self
    else
      super
    end
  end

  private

    def build_query
      scope_chain.uniq.each do |scope_name|
        configuration.scopes[scope_name].each do |block|
          sunspot.build do |sunspot|
            sunspot.instance_eval &block
          end
        end
      end
    end

    def set_facets
      configuration.facets.each_pair do |facet_name, block|
        sunspot.build do |search|
          search.instance_eval do |search|
            search.facet facet_name, &block
          end
        end
      end
    end
end
