class Searcher
  class Configuration
    def initialize(&block)
      instance_eval &block
    end

    def keywords(field)
      @keywords = field
    end

    def read(attribute)
      instance_variable_get("@#{attribute}")
    end
  end

  attr_accessor :models, :params, :configuration, :sunspot

  def initialize(model_names_or_classes, &block)
    self.models = model_names_or_classes
    self.configure(&block)
  end

  def models=(names_or_clases)
    @models = [names_or_clases].map do |name_or_class|
      name_or_class.is_a?(Class) ? name_or_class : name_or_class.to_s.classify.constantize
    end
  end

  def configure(&block)
    self.configuration = Configuration.new(&block)
  end

  def params=(params)
    @params = params
    self.sunspot = nil
  end

  def sunspot
    @sunspot ||= Sunspot.new_search models
  end

  def fulltext
    sunspot.build do
      fulltext params[configuration.read(:keywords)]
    end
  end

  def execute
    fulltext
  end
end
