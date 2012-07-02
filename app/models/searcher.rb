class Searcher

  attr_accessor :models, :params, :configuration, :sunspot
  attr_accessor :scope_chain

  delegate :inspect, :to => :all

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

  def search_object
    @search_object ||= create_search_object
  end

  private

    def create_search_object
      object = Searcher::Model.new
      object.extend configuration.search_object_methods
      object.attributes = params
      object
    end

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

    def method_missing(name, *args, &block)
      if configuration.scopes.include?(name)
        scope_chain << name
        self
      else
        super
      end
    end
end
