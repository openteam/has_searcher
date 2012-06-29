class Searcher
  class Configuration
    attr_accessor :searcher

    def initialize(searcher, &block)
      self.searcher = searcher
      instance_eval &block
    end

    def keywords(field)
      @keywords = field
    end

    def read(attribute)
      instance_variable_get("@#{attribute}")
    end

    def scope(name, &block)
      searcher.scopes.class_eval do
        define_method name do
          sunspot.build do |sunspot|
            sunspot.instance_eval &block
          end
        end
      end
    end
  end

  attr_accessor :models, :params, :configuration, :sunspot, :scopes

  def initialize(model_names_or_classes, &block)
    self.models = model_names_or_classes
    self.scopes = Module.new
    self.extend self.scopes
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
