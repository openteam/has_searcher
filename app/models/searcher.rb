class Searcher

  attr_accessor :configuration, :sunspot, :search_object
  attr_accessor :scope_chain

  delegate :current_page, :num_pages, :limit_value, :to => :results

  def initialize(&block)
    self.scope_chain = [:default, :runtime]
    self.search_object = Searcher::Model.new(self)
    self.configuration = Configuration.new(self, &block)
  end

  def sunspot
    @sunspot ||= Sunspot.new_search configuration.search_models
  end

  def each(&block)
    results.each(&block)
  end

  delegate :results, :total, :facet, :to => :executed_sunspot
  alias_method :all, :results

  def result_ids
    executed_sunspot.hits.map(&:primary_key)
  end

  def order_by(name, type=:asc)
    configuration.scope :runtime do |sunspot|
      sunspot.order_by(name)
    end
  end
  alias_method :order, :order_by

  def limit(number)
    paginate(:per_page => number)
  end
  alias_method :per_page, :limit
  alias_method :per, :limit

  def page(number)
    paginate(:page => number)
  end

  def paginate(params)
    configuration.scope :runtime do |sunspot|
      sunspot.paginate(params)
    end
  end

  def scoped
    default.runtime
  end

  def boost_by(field, options={})
    boostificator = Boostificator.new(field, options)
    configuration.scope :runtime do |sunspot|
      boostificator.adjust_solr_params(sunspot)
    end
  end

  def execute
    unless @executed
      build_query
      set_facets
      sunspot.execute
      @executed = true
    end
  end

  def executed_sunspot
    execute
    sunspot
  end

  private

    def build_query
      scope_chain.uniq.each do |scope_name|
        configuration.scopes[scope_name].each do |block|
          sunspot.build do |sunspot|
            case block.arity
            when 0
              sunspot.instance_eval(&block)
            when 1
              block.call(sunspot)
            else
              raise ArgumentError.new "arity > 1 not supported"
            end
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
        return self
      end
      return results.send(name, *args, &block) if results.respond_to?(name)
      super
    end
end
